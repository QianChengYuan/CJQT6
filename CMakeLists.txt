cmake_minimum_required(VERSION 3.20)
project(CJQT6 VERSION 1.0.0 LANGUAGES CXX)

# 设置 C++ 标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# 设置输出目录
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# 查找 Qt6 包
find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets)

# 设置 Qt6 自动 MOC、UIC、RCC
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

# 添加编译选项
if(MSVC)
    add_compile_options(/W4)
else()
    add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# 预编译头文件
set(PCH_HEADER ${CMAKE_SOURCE_DIR}/native/includes/cjqt6_pch.h)

# 包含目录
include_directories(
    ${CMAKE_SOURCE_DIR}/native/includes
)

# ============================================================
# CJQT6 桥接库 (用于仓颉语言FFI)
# ============================================================

# 按模块组织源文件
set(CORE_SOURCES
    native/src/core/string.cpp
    native/src/core/core.cpp
)

set(GUI_SOURCES
    native/src/gui/gui.cpp
)

set(WIDGETS_SOURCES
    native/src/widgets/widgets.cpp
)

set(TOOLS_SOURCES
    native/src/tools/bridge.cpp
)

# 创建共享库
add_library(cjqt6_bridge SHARED
    ${CORE_SOURCES}
    ${GUI_SOURCES}
    ${WIDGETS_SOURCES}
    ${TOOLS_SOURCES}
    # 头文件 (用于MOC处理)
    native/includes/gui.h
    native/includes/widgets.h
)

# 链接 Qt6 库
target_link_libraries(cjqt6_bridge PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
)

# 设置输出名称
set_target_properties(cjqt6_bridge PROPERTIES
    OUTPUT_NAME "cjqt6_bridge"
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
)

# ============================================================
# 安装
# ============================================================

install(TARGETS cjqt6_bridge
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

# 安装头文件
install(DIRECTORY native/includes/
    DESTINATION include/cjqt6
    FILES_MATCHING PATTERN "*.h"
)

# ============================================================
# 打印配置信息
# ============================================================

message(STATUS "======================================")
message(STATUS "CJQT6 Configuration")
message(STATUS "======================================")
message(STATUS "Version: ${PROJECT_VERSION}")
message(STATUS "C++ Standard: ${CMAKE_CXX_STANDARD}")
message(STATUS "Qt6 Version: ${Qt6_VERSION}")
message(STATUS "Build Type: ${CMAKE_BUILD_TYPE}")
message(STATUS "Install Prefix: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "======================================")