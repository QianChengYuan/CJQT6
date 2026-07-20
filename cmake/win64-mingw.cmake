# Windows x64 交叉编译工具链 (MinGW-w64)
# 注意: 本项目在 Windows 上的主要构建方式为 MSVC 2022。
# 此文件仅用于在 Linux 上通过 MinGW-w64 交叉编译 Windows 桥接库的场景。
# Windows 原生构建请直接在 native/build_windows 目录中使用 MSVC 2022。
# 使用方法: cmake -DCMAKE_TOOLCHAIN_FILE=cmake/win64-mingw.cmake ..

set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR x86_64)

# 设置 MinGW-w64 编译器
set(CMAKE_C_COMPILER x86_64-w64-mingw32-gcc)
set(CMAKE_CXX_COMPILER x86_64-w64-mingw32-g++)
set(CMAKE_RC_COMPILER x86_64-w64-mingw32-windres)

# 设置查找路径
set(CMAKE_FIND_ROOT_PATH /usr/x86_64-w64-mingw32)

# 禁止系统默认包含路径，只使用 MinGW 路径
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -nostdinc -nostdinc++ -isystem /usr/lib/gcc/x86_64-w64-mingw32/13-win32/include/c++ -isystem /usr/lib/gcc/x86_64-w64-mingw32/13-win32/include/c++/x86_64-w64-mingw32 -isystem /usr/x86_64-w64-mingw32/include")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -nostdinc -isystem /usr/x86_64-w64-mingw32/include")

# 调整默认行为 - 允许在 Windows Qt 路径中查找
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE BOTH)

# Qt6 路径 - Windows Qt MinGW 安装目录 (WSL 路径)
# 注意: 交叉编译需要 MinGW 版本的 Qt，不能使用 MSVC 版本的 Qt。
# 请根据实际安装路径修改 Qt6_WIN_PATH。
set(QT6_WIN_PATH "/mnt/c/Qt/6.10.3/mingw_64")
set(CMAKE_PREFIX_PATH "${QT6_WIN_PATH}")
set(Qt6_DIR "${QT6_WIN_PATH}/lib/cmake/Qt6")

# 添加 Qt6 库路径
set(CMAKE_LIBRARY_PATH "${QT6_WIN_PATH}/lib" ${CMAKE_LIBRARY_PATH})
set(CMAKE_INCLUDE_PATH "${QT6_WIN_PATH}/include" ${CMAKE_INCLUDE_PATH})

message(STATUS "Cross-compiling for Windows x64 (MinGW-w64)")
message(STATUS "Qt6 path: ${QT6_WIN_PATH}")
