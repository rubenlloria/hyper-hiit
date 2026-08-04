
/****************************************************************************
** File: main.cpp
** Date: 18/2/2026
** Author: Rubén Llòria
**
** This program is free software: you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 3 of the License, or
** any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
** or see <http://www.gnu.org/licenses/>.
**
** Copyright (C) 2026 Rubén Llòria
****************************************************************************/

// #define HH_DEBUG
#define HH_INFO
#define HH_WARNING
#define HH_CRITICAL

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QLocale>
#include <QTranslator>

// Project components
#include "src/SystemManager.h"
#include "src/Chronometer.h"
#include "src/DatabaseManager.h"
#include "src/SystemLog.h"
#include "src/SessionManager.h"
#include "src/AchievementManager.h"
#include "src/MediaController.h"

int main(int argc, char *argv[])
{
    bool isSystemReady = false;
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

#ifdef NDEBUG
    const bool isDebugBuild = false;
#else
    const bool isDebugBuild = true;
#endif

#ifdef Q_OS_ANDROID
    // Evita que el plugin d'Android cride exit() en tancar l'app.
    // exit() dispara __cxa_finalize, que destrueix objectes globals de TOT
    // el procés i entra en carrera amb els threads propis del sistema
    // (p. ex. CommonPool / hwuiTaskN de libhwui.so), provocant un
    // SIGABRT per "pthread_mutex_lock on a destroyed mutex".
    // Ref: QTBUG-82617
    qputenv("QT_ANDROID_NO_EXIT_CALL", "1");
#endif

    // Force the scaling to be smooth and respect the system's density
    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(
        Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);

    QGuiApplication app(argc, argv);

#ifdef Q_OS_ANDROID
    // Set the window to immersive mode to hide status and navigation bars
    QNativeInterface::QAndroidApplication::runOnAndroidMainThread([](){
        QJniObject activity = QNativeInterface::QAndroidApplication::context();
        QJniObject window = activity.callObjectMethod("getWindow", "()Landroid/view/Window;");
        QJniObject decorView = window.callObjectMethod("getDecorView", "()Landroid/view/View;");

        // Define the flags for SYSTEM_UI_FLAG_FULLSCREEN and IMMERSIVE_STICKY
        const int SYSTEM_UI_FLAG_FULLSCREEN = 4;
        const int SYSTEM_UI_FLAG_HIDE_NAVIGATION = 2;
        const int SYSTEM_UI_FLAG_IMMERSIVE_STICKY = 4096;

        int flags = SYSTEM_UI_FLAG_FULLSCREEN | SYSTEM_UI_FLAG_HIDE_NAVIGATION | SYSTEM_UI_FLAG_IMMERSIVE_STICKY;

        decorView.callMethod<void>("setSystemUiVisibility", "(I)V", flags);
    });
#endif

    DatabaseManager dbManager;

    if (!dbManager.initDatabase()){
        hCritical() << "Database initialization failed. Aborting startup.";
        return 20;
    }
    SystemManager systemManager(&dbManager);
    SessionManager sessionManager(&dbManager);
    int activeDirId = sessionManager.getActiveDirectiveId();

    QTranslator translator;

    if (systemManager.systemLanguage()) {
        const QStringList uiLanguages = QLocale::system().uiLanguages();
        for (const QString &locale : uiLanguages) {
            const QString baseName = "hyper-hiit_" + QLocale(locale).name();
            hInfo() << "Loading language file " << baseName;
            if (translator.load(":/i18n/" + baseName)) {
                app.installTranslator(&translator);
                hInfo() << "Language file " << baseName << " loaded";
                break;
            }
        }
    }

    ModuleModel moduleModel;
    DirectiveModel directiveModel(&dbManager);
    ProtocolModel protocolModel(&dbManager);
    ProtocolModel architectProtocolModel(&dbManager);

    // Neural Sync: Fetching data from SQLite and injecting into the Model
    moduleModel.setModules(dbManager.getAllModules());
    directiveModel.setDirectives(dbManager.getAllDirectives());

    // protocolModel.
    protocolModel.setProtocols(dbManager.getProtocolsByDirective(activeDirId));
    architectProtocolModel.setProtocols(dbManager.getProtocolsByDirective(activeDirId));
    hDebug() << "Resuming Directive:" << activeDirId;

    AchievementManager achievementManager(&dbManager);
    MediaController mediaController;

    qmlRegisterType<Chronometer>("org.aic.hyperhiit", 1, 0, "Chronometer");
    Chronometer chronometer;

    // 1. Initialize the QML engine
    QQmlApplicationEngine engine;
    engine.addImportPath("qrc:/qt/qml"); // CRITICAL: This allows 'import org.aic.hyperhiit 1.0' to work

    // 2. Register Context Properties (Neural Sync)
    // We inject the version defined in CMake so the HUD can display it
    engine.rootContext()->setContextProperty("appVersion", APP_VERSION_STR);
    engine.rootContext()->setContextProperty("isDebugBuild", isDebugBuild);
    engine.rootContext()->setContextProperty("dbManager", &dbManager);
    engine.rootContext()->setContextProperty("moduleModel", &moduleModel);
    engine.rootContext()->setContextProperty("directiveModel", &directiveModel);
    engine.rootContext()->setContextProperty("protocolModel", &protocolModel);
    engine.rootContext()->setContextProperty("architectProtocolModel", &architectProtocolModel);
    engine.rootContext()->setContextProperty("chronometer", &chronometer);
    engine.rootContext()->setContextProperty("systemManager", &systemManager);
    engine.rootContext()->setContextProperty("sessionManager", &sessionManager);
    engine.rootContext()->setContextProperty("achievementManager", &achievementManager);
    engine.rootContext()->setContextProperty("mediaController", &mediaController);

    const QUrl url(QStringLiteral("qrc:/qt/qml/org/aic/hyperhiit/ui/main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url, &systemManager](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl) {
            QCoreApplication::exit(-1);
        } else if (obj) {
            // UI handshake successful: Setting operational state to ONLINE
            // This triggers the NOTIFY signal for isSystemReady
            QTimer::singleShot(2000, [&systemManager]() {
                systemManager.setSystemReady(true);
                hDebug() << "Application connected to engine";
            });
        }
    }, Qt::QueuedConnection);

    // Clean exit logic
    QObject::connect(&app, &QCoreApplication::aboutToQuit, [&dbManager]() {
        // Force the DB to sync and close properly to prevent Android crash reports
        hInfo() << "Application is shutting down. Closing database connections...";
        dbManager.closeDatabase();
    });


    engine.load(url);

    return app.exec();
}
