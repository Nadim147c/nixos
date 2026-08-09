cmake_minimum_required(VERSION 3.16)
project(OkLabPlugin LANGUAGES CXX)

if(POLICY QTP0001)
    qt_policy(SET QTP0001 NEW)
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

# FIX: Force CMake to set RPATH properly without relying on build paths
set(CMAKE_SKIP_BUILD_RPATH FALSE)
set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE)
set(CMAKE_INSTALL_RPATH "$ORIGIN")

find_package(Qt6 REQUIRED COMPONENTS Quick Qml)

qt_add_qml_module(OkLabPlugin
    URI "OkLab"
    VERSION 1.0
    SOURCES
        oklabcolors.h
        oklabcolors.cpp
)

target_link_libraries(OkLabPlugin PRIVATE Qt6::Quick Qt6::Qml)
