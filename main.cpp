#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QLocale>
#include <QTranslator>

// Project components
#include "src/SystemManager.h"
#include "src/Chronometer.h"
#include "src/DatabaseManager.h"

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
    dbManager.initDatabase();

    Chronometer chronometer;

    SystemManager systemManager;

    // 1. Initialize the QML engine
    QQmlApplicationEngine engine;

    // 2. Register Context Properties (Neural Sync)
    // We inject the version defined in CMake so the HUD can display it
    engine.rootContext()->setContextProperty("appVersion", APP_VERSION_STR);
    engine.rootContext()->setContextProperty("DatabaseManager", &dbManager);
    engine.rootContext()->setContextProperty("chronometer", &chronometer);
    engine.rootContext()->setContextProperty("SystemManager", &systemManager);

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
