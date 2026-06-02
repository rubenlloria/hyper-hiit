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

#ifdef Q_OS_ANDROID
    // Kep Android screen on
    QNativeInterface::QAndroidApplication::runOnAndroidMainThread([](){
        QJniObject activity = QNativeInterface::QAndroidApplication::context();
        QJniObject window = activity.callObjectMethod("getWindow", "()Landroid/view/Window;");
        const int FLAG_KEEP_SCREEN_ON = 128; // Constante de Android
        window.callMethod<void>("addFlags", "(I)V", FLAG_KEEP_SCREEN_ON);
    });
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

    QTranslator translator;
    const QStringList uiLanguages = QLocale::system().uiLanguages();
    for (const QString &locale : uiLanguages) {
        const QString baseName = "hyper-hiit_" + QLocale(locale).name();
        if (translator.load(":/i18n/" + baseName)) {
            app.installTranslator(&translator);
            break;
        }
    }

    DatabaseManager dbManager;
    ModuleModel moduleModel;
    DirectiveModel directiveModel;
    ProtocolModel protocolModel(&dbManager);
    SystemManager systemManager;
    SessionManager sessionManager(&dbManager);
    AchievementManager achievementManager(&dbManager);
    MediaController mediaController;

    if (dbManager.initDatabase()) {
        // Neural Sync: Fetching data from SQLite and injecting into the Model
        moduleModel.setModules(dbManager.getAllModules());
        directiveModel.setDirectives(dbManager.getAllDirectives());
        int activeDirId = dbManager.getActiveDirectiveId();

        // protocolModel.
        protocolModel.setProtocols(dbManager.getProtocolsByDirective(activeDirId));
        hDebug() << "Resuming Directive:" << activeDirId;

    }

    qmlRegisterType<Chronometer>("org.aic.hyperhiit", 1, 0, "Chronometer");
    Chronometer chronometer;

    // 1. Initialize the QML engine
    QQmlApplicationEngine engine;
    engine.addImportPath("qrc:/qt/qml"); // CRITICAL: This allows 'import org.aic.hyperhiit 1.0' to work

    // 2. Register Context Properties (Neural Sync)
    // We inject the version defined in CMake so the HUD can display it
    engine.rootContext()->setContextProperty("appVersion", APP_VERSION_STR);
    engine.rootContext()->setContextProperty("dbManager", &dbManager);
    engine.rootContext()->setContextProperty("moduleModel", &moduleModel);
    engine.rootContext()->setContextProperty("directiveModel", &directiveModel);
    engine.rootContext()->setContextProperty("protocolModel", &protocolModel);
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
            systemManager.setSystemReady(true);
        }
    }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
