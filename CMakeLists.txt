cmake_minimum_required(VERSION 3.16)

# 1. Políticas de Qt 6 para asegurar consistencia en rutas de recursos
set(QT_POLICY_QTP0001 NEW)
set(QT_POLICY_QTP0004 NEW)

project(hyper-hiit VERSION 0.1.1 LANGUAGES CXX)
set(APP_VERSION_STR "0.1.1-alpha")

# 2. Configuración automática de Qt (Necesario para Q_OBJECT)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 3. Buscar paquetes de Qt 6
find_package(Qt6 REQUIRED COMPONENTS Core Quick Sql LinguistTools Core5Compat)

# 4. Listar fuentes de C++ (SIN main.cpp)
set(PROJECT_SOURCES
    src/DatabaseManager.h
    src/DatabaseManager.cpp
    src/Chronometer.h
    src/Chronometer.cpp
    src/ThemeManager.h
    src/ThemeManager.cpp
)

# 5. Definir el ejecutable base (Solo con main.cpp)
qt_add_executable(hyper-hiit main.cpp)

# 6. Registrar el módulo QML vinculado al ejecutable
# Definimos el RESOURCE_PREFIX para que coincida con la carga en main.cpp
qt_add_qml_module(hyper-hiit
    URI org.aic.hyperhiit
    VERSION 1.0
    RESOURCE_PREFIX "/qt/qml"
    SOURCES ${PROJECT_SOURCES}
    QML_FILES
        ui/main.qml
        ui/Constants.qml
        ui/CyberButton.qml
        ui/ProgressDial.qml
        # screens
        ui/views/Architect.qml
        ui/views/ArchitectForm.ui.qml
        ui/views/Dashboard.qml
        ui/views/DashboardForm.ui.qml
        ui/views/Testboard.qml
        ui/views/ProtocolForm.ui.qml
        # Visual components
        ui/components/AppHeader.ui.qml
        ui/components/NeonAccordion.ui.qml
        ui/components/NeonDirective.ui.qml
        ui/components/NeonIcon.ui.qml
        ui/components/NeonIndicator.ui.qml
        ui/components/NeonText.ui.qml
        ui/components/ProtocolList.ui.qml
    RESOURCES
        res/background_tech.png
        gpl2_header.txt
        authors.txt
        ui/assets/fonts/Orbitron-VariableFont_wght.ttf
        ui/assets/fonts/lucide.ttf
        ui/assets/fonts/Orbit-Regular.ttf
        ui/assets/fonts/ShareTechMono-Regular.ttf
        RESOURCES ui/qmldir
        QML_FILES ui/components/NeonProtocol.ui.qml
        QML_FILES ui/components/NeonButton.ui.qml
)

# 7. Definiciones de compilación
target_compile_definitions(hyper-hiit PRIVATE APP_VERSION_STR="${APP_VERSION_STR}")

# 8. Enlazar librerías
target_link_libraries(hyper-hiit PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::Sql
    Qt6::Core5Compat
)

# 9. Propiedades específicas (Android y otros)
set_target_properties(hyper-hiit PROPERTIES
    QT_ANDROID_PACKAGE_NAME "com.aic.hyperhiit.app"
    QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android"
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

# 10. Finalizar ejecutable (Genera los metadatos necesarios para QML)
qt_finalize_executable(hyper-hiit)
