cmake_minimum_required(VERSION 3.14)

project(hyper-hiit VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# --- CAMBIO 1: Añadimos 'Sql' a los componentes buscados ---
find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core Quick Sql LinguistTools Core5Compat)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Quick Sql LinguistTools)

set(TS_FILES hyper-hiit_es_ES.ts)

# --- CAMBIO 2: Incluimos tus archivos de lógica en el proyecto ---
set(PROJECT_SOURCES
        main.cpp
        src/DatabaseManager.h
        src/DatabaseManager.cpp
        src/Chronometer.h
        src/Chronometer.cpp
        qml.qrc
        ${TS_FILES}
)

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_add_executable(hyper-hiit
        MANUAL_FINALIZATION
        ${PROJECT_SOURCES}
    )
    set_property(TARGET hyper-hiit PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
    qt_create_translation(QM_FILES ${CMAKE_SOURCE_DIR} ${TS_FILES})
else()
    if(ANDROID)
        add_library(hyper-hiit SHARED ${PROJECT_SOURCES})
    else()
        add_executable(hyper-hiit ${PROJECT_SOURCES})
    endif()
    qt5_create_translation(QM_FILES ${CMAKE_SOURCE_DIR} ${TS_FILES})
endif()

# --- CAMBIO 3: Enlazamos la librería SQL ---
target_link_libraries(hyper-hiit
  PRIVATE Qt${QT_VERSION_MAJOR}::Core
          Qt${QT_VERSION_MAJOR}::Quick
          Qt${QT_VERSION_MAJOR}::Sql)

set_target_properties(hyper-hiit PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER com.hyperhiit.app
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
    QT_ANDROID_PACKAGE_NAME "com.aic.hyperhiit.app"
)

install(TARGETS hyper-hiit
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})

if(QT_VERSION_MAJOR EQUAL 6)
    qt_import_qml_plugins(hyper-hiit)
    qt_finalize_executable(hyper-hiit)
endif()
