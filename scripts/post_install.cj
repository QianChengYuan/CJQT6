#!/usr/bin/env cjc
// 安装后脚本

import std.os.*
import std.io.*

main() {
    println("执行CJQT6安装后配置...")
    println("=====================================")
    
    // 1. 显示欢迎信息
    println("")
    println("欢迎使用CJQT6 - 仓颉语言的Qt6封装库!")
    println("")
    
    // 2. 平台检测
    println("正在检测您的平台...")
    // 调用 detect_platform.cj
    // run("cjc scripts/detect_platform.cj")
    
    // 3. Qt6检测
    println("")
    println("正在检测Qt6安装...")
    // 调用 check_qt6.cj
    // run("cjc scripts/check_qt6.cj")
    
    // 4. 配置提示
    println("")
    println("=====================================")
    println("安装后建议:")
    println("")
    println("1. 确保Qt6已正确安装 (版本 >= 6.2)")
    println("2. 设置环境变量 (如需要):")
    println("   Linux:   export LD_LIBRARY_PATH=/path/to/qt6/lib:\$LD_LIBRARY_PATH")
    println("   Windows: set PATH=C:\\Qt\\6.5.0\\msvc2019_64\\bin;%PATH%")
    println("   macOS:   Qt6通常自动配置")
    println("")
    println("3. 运行验证: cjc scripts/verify_install.cj")
    println("")
    println("快速开始示例:")
    println("  import CJQT6.core.*")
    println("  import CJQT6.widgets.*")
    println("  ")
    println("  main() {")
    println("      let app = QApplication()")
    println("      let window = QWidget()")
    println("      window.setWindowTitle(\"Hello CJQT6\")")
    println("      window.show()")
    println("      app.exec()")
    println("  }")
    println("")
}
