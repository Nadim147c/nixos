cmake_minimum_required(VERSION 3.16)
project(CavaPlugin LANGUAGES CXX)

if(POLICY QTP0001)
    qt_policy(SET QTP0001 NEW)
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

set(CMAKE_SKIP_BUILD_RPATH FALSE)
set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE)
set(CMAKE_INSTALL_RPATH "$ORIGIN")

set(CAVA_BAR_COUNT 16 CACHE STRING "Number of Cava audio bars to read")
set(CAVA_BIN "cava" CACHE STRING "Name or executable path of the cava binary")

add_compile_definitions(CAVA_BAR_COUNT=${CAVA_BAR_COUNT})
add_compile_definitions(CAVA_BIN="${CAVA_BIN}")

find_package(Qt6 REQUIRED COMPONENTS Quick Qml)

qt_add_qml_module(CavaPlugin
    URI "Cava"
    VERSION 1.0
    SOURCES
        cavaprovider.h
        cavaprovider.cpp
)

target_link_libraries(CavaPlugin PRIVATE Qt6::Quick Qt6::Qml)
