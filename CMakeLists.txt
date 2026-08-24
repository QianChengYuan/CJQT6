cmake_minimum_required(VERSION 3.20)
project(CJQT6 VERSION 1.0.0 LANGUAGES CXX)

# MSVC 下导出符号策略：
# 不使用 CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS（会导出 C 运行时函数 fprintf/vfprintf 等，
# 导致仓颉 main.exe 链接时从 cjqt6_bridge.dll 导入 fprintf 而非 msvcrt.dll，
# 运行时报 STATUS_ENTRYPOINT_NOT_FOUND=0xC0000139）。
# 改用自定义 .def 文件只导出 q* 桥接函数。
# 新增桥接函数后，重新生成：从 build 目录的 exports.def 提取 q 开头行。
if(MSVC)
    set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS OFF)
endif()

# 设置 C++ 标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# 设置输出目录（使用生成器表达式确保单配置和多配置生成器行为一致）
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
# 多配置生成器（如 MSVC）默认追加配置子目录，在此覆盖为平级输出
foreach(CONFIG RELEASE DEBUG MINSIZEREL RELWITHDEBINFO)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${CONFIG} ${CMAKE_BINARY_DIR}/bin)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${CONFIG} ${CMAKE_BINARY_DIR}/lib)
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${CONFIG} ${CMAKE_BINARY_DIR}/lib)
endforeach()

# 查找 Qt6 包
# CorePrivate 在部分 Linux 发行版（如 Ubuntu 22.04 的 Qt 6.4.2）不提供独立 cmake 配置，
# 改为可选：找到则链接私有库，找不到时桥接代码用平台宏守卫跳过私有 API。
find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets Qml Quick QuickWidgets Sql PrintSupport Network UiTools)
# CorePrivate / Multimedia / MultimediaWidgets 是可选的
find_package(Qt6 COMPONENTS CorePrivate QUIET)
find_package(Qt6 COMPONENTS Multimedia QUIET)
find_package(Qt6 COMPONENTS MultimediaWidgets QUIET)

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
# CJQT 桥接库 (用于仓颉语言FFI)
# ============================================================

# 核心模块 - QApplication, QWidget, QTimer, Events, Signal/Slot, Drag&Drop, Animation, Undo, Thread
set(CORE_SOURCES
    native/src/core/string.cpp
    native/src/core/core.cpp
    native/src/core/bridge_core.cpp
    native/src/core/bridge_events.cpp
    native/src/core/bridge_signal.cpp
    native/src/core/bridge_dragdrop.cpp
    native/src/core/bridge_animation.cpp
    native/src/core/bridge_undostack.cpp
    native/src/core/bridge_thread.cpp
    native/src/core/bridge_itemselection.cpp
    native/src/core/bridge_json.cpp
    native/src/core/bridge_ui_poster.cpp
)

# GUI模块 - 布局、对话框、菜单、样式、文本文档
set(GUI_SOURCES
    native/src/gui/gui.cpp
    native/src/gui/bridge_layout.cpp
    native/src/gui/bridge_dialogs.cpp
    native/src/gui/bridge_menu.cpp
    native/src/gui/bridge_style.cpp
    native/src/gui/bridge_textdoc.cpp
    native/src/gui/bridge_font.cpp
    native/src/gui/bridge_syntax.cpp
)

# Widgets模块 - 基础部件、选择部件、数值部件、容器、日期时间
set(WIDGETS_SOURCES
    native/src/widgets/widgets.cpp
    native/src/widgets/bridge_widgets.cpp
    native/src/widgets/bridge_selectors.cpp
    native/src/widgets/bridge_values.cpp
    native/src/widgets/bridge_containers.cpp
    native/src/widgets/bridge_datetime.cpp
    native/src/widgets/bridge_ext_new.cpp
    native/src/widgets/bridge_ext_wcore.cpp
    native/src/widgets/bridge_ext_wtext.cpp
    native/src/widgets/bridge_ext_wselect.cpp
    native/src/widgets/bridge_ext_wrange.cpp
    native/src/widgets/bridge_ext_wlayout.cpp
    native/src/widgets/bridge_ext_wmisc.cpp
    native/src/widgets/bridge_ext_apicomplete.cpp
    native/src/widgets/bridge_graphicsitem.cpp
    native/src/widgets/bridge_uiloader.cpp
)

# Views模块 - 表格视图、列表视图、树形视图、排序过滤代理、抽象模型
set(VIEWS_SOURCES
    native/src/views/bridge_table.cpp
    native/src/views/bridge_list.cpp
    native/src/views/bridge_tree.cpp
    native/src/views/bridge_modelview.cpp
    native/src/views/bridge_ext_views.cpp
    native/src/views/bridge_sortfilterproxymodel.cpp
    native/src/views/bridge_abstractmodel.cpp
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

# Network模块 - 网络支持
set(NETWORK_SOURCES
    native/src/network/bridge_network.cpp
    native/src/network/bridge_network_access.cpp
)

# Multimedia模块 - 多媒体支持 (可选)
set(MULTIMEDIA_SOURCES)
if(Qt6Multimedia_FOUND)
    set(MULTIMEDIA_SOURCES
        native/src/multimedia/bridge_multimedia.cpp
        native/src/multimedia/bridge_videowidget.cpp
        native/src/multimedia/bridge_camera.cpp
    )
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
    ${NETWORK_SOURCES}
    # 头文件 (用于MOC处理)
    native/includes/gui.h
    native/includes/widgets.h
    native/includes/signalemitter.h
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
    Qt6::Network
    Qt6::UiTools
)
# CorePrivate 可选链接（Windows / 自编译 Qt6 提供，部分 Linux 发行版缺失）
if(TARGET Qt6::CorePrivate)
    target_link_libraries(cjqt6_bridge PRIVATE Qt6::CorePrivate)
endif()

# 可选链接 Multimedia / MultimediaWidgets
if(TARGET Qt6::Multimedia)
    target_link_libraries(cjqt6_bridge PRIVATE Qt6::Multimedia)
endif()
if(TARGET Qt6::MultimediaWidgets)
    target_link_libraries(cjqt6_bridge PRIVATE Qt6::MultimediaWidgets)
endif()

# 设置输出名称
set_target_properties(cjqt6_bridge PROPERTIES
    OUTPUT_NAME "cjqt6_bridge"
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib
)
# MSVC 下用自定义 .def 文件只导出 q* 桥接函数（避免导出 C 运行时函数）
if(MSVC)
    target_sources(cjqt6_bridge PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/native/cjqt6_bridge_exports.def")
endif()

# ============================================================
# 桥接层 C++ 单元测试（P0-3）
# 默认关闭；CI / 本机验证时用 -DCJQT6_BUILD_TESTS=ON 开启，
# 配合 -DCJQT6_NATIVE_TESTS_ASAN=ON 可做字符串泄漏检测。
# ============================================================
option(CJQT6_BUILD_TESTS "构建桥接层 C++ 单元测试" OFF)
if(CJQT6_BUILD_TESTS)
    enable_testing()
    add_executable(bridge_core_tests
        native/tests/bridge_core_test.cpp
    )
    target_link_libraries(bridge_core_tests PRIVATE
        cjqt6_bridge
        Qt6::Core
        Qt6::Widgets
    )
    option(CJQT6_NATIVE_TESTS_ASAN "桥接层测试启用 AddressSanitizer" OFF)
    if(CJQT6_NATIVE_TESTS_ASAN)
        if(MSVC)
            target_compile_options(bridge_core_tests PRIVATE /fsanitize=address)
            target_link_options(bridge_core_tests PRIVATE /fsanitize=address)
        else()
            target_compile_options(bridge_core_tests PRIVATE
                -fsanitize=address -fno-omit-frame-pointer)
            target_link_options(bridge_core_tests PRIVATE -fsanitize=address)
        endif()
    endif()
    add_test(NAME bridge_core_tests COMMAND bridge_core_tests)
endif()

# ============================================================
# 安装
# ============================================================

install(TARGETS cjqt6_bridge
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

# 安装头文件
install(DIRECTORY native/includes/
    DESTINATION include/cjfw
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