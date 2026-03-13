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
find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets Qml Quick QuickWidgets Sql PrintSupport)
# Multimedia 是可选的
find_package(Qt6 COMPONENTS Multimedia QUIET)

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

# 包含目录
include_directories(
    ${CMAKE_SOURCE_DIR}/native/includes
)

# ============================================================
# CJQT6 桥接库 (用于仓颉语言FFI)
# ============================================================

# 核心模块 - QApplication, QWidget, QTimer, Events, Signal/Slot, Drag&Drop
set(CORE_SOURCES
    native/src/core/string.cpp
    native/src/core/core.cpp
    native/src/core/bridge_core.cpp
    native/src/core/bridge_events.cpp
    native/src/core/bridge_signal.cpp
    native/src/core/bridge_dragdrop.cpp
)

# GUI模块 - 布局、对话框、菜单
set(GUI_SOURCES
    native/src/gui/gui.cpp
    native/src/gui/bridge_layout.cpp
    native/src/gui/bridge_dialogs.cpp
    native/src/gui/bridge_menu.cpp
)

# Widgets模块 - 基础部件、选择部件、数值部件、容器、日期时间
set(WIDGETS_SOURCES
    native/src/widgets/widgets.cpp
    native/src/widgets/bridge_widgets.cpp
    native/src/widgets/bridge_selectors.cpp
    native/src/widgets/bridge_values.cpp
    native/src/widgets/bridge_containers.cpp
    native/src/widgets/bridge_datetime.cpp
)

# Views模块 - 表格视图、列表视图、树形视图
set(VIEWS_SOURCES
    native/src/views/bridge_table.cpp
    native/src/views/bridge_list.cpp
    native/src/views/bridge_tree.cpp
)

# Paint模块 - 绘图相关类
set(PAINT_SOURCES
    native/src/paint/bridge_painter.cpp
)

# Process模块 - 进程管理
set(PROCESS_SOURCES
    native/src/process/bridge_process.cpp
)

# QML模块 - Qt Quick/QML支持
set(QML_SOURCES
    native/src/qml/bridge_qml.cpp
)

# Sql模块 - 数据库支持
set(SQL_SOURCES
    native/src/sql/bridge_sql.cpp
)

# Print模块 - 打印支持
set(PRINT_SOURCES
    native/src/print/bridge_print.cpp
)

# Multimedia模块 - 多媒体支持 (可选)
set(MULTIMEDIA_SOURCES)
if(Qt6Multimedia_FOUND)
    set(MULTIMEDIA_SOURCES native/src/multimedia/bridge_multimedia.cpp)
    message(STATUS "Qt6 Multimedia: Found")
else()
    message(STATUS "Qt6 Multimedia: Not found, multimedia support disabled")
endif()

# 创建共享库
add_library(cjqt6_bridge SHARED
    ${CORE_SOURCES}
    ${GUI_SOURCES}
    ${WIDGETS_SOURCES}
    ${VIEWS_SOURCES}
    ${PAINT_SOURCES}
    ${PROCESS_SOURCES}
    ${QML_SOURCES}
    ${MULTIMEDIA_SOURCES}
    ${SQL_SOURCES}
    ${PRINT_SOURCES}
    # 头文件 (用于MOC处理)
    native/includes/gui.h
    native/includes/widgets.h
)

# 链接 Qt6 库
target_link_libraries(cjqt6_bridge PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickWidgets
    Qt6::Sql
    Qt6::PrintSupport
)

# 可选链接 Multimedia
if(TARGET Qt6::Multimedia)
    target_link_libraries(cjqt6_bridge PRIVATE Qt6::Multimedia)
endif()

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