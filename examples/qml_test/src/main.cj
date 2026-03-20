package qml_test

import CJQT6.core.*
import CJQT6.qml.*

main(): Int32 {
    println("=== QML 测试开始 ===")
    
    println("创建 QApplication...")
    let app = QApplication()
    println("QApplication 创建成功")

    // 使用 QQmlApplicationEngine
    println("创建 QQmlApplicationEngine...")
    let engine = QQmlApplicationEngine()
    let enginePtr = engine.getPtr()
    println("Engine 指针: ${enginePtr}")
    
    if (enginePtr == 0) {
        println("QQmlApplicationEngine 创建失败!")
        return 1
    }

    // 最简单的 QML - 使用 QtObject 作为根，不需要 import
    let qmlCode = """QtObject { property string test: "hello" }"""

    println("加载内联 QML...")
    engine.loadData(qmlCode)

    let count = engine.rootObjectsCount()
    println("根对象数量: ${count}")
    
    println("测试完成")
    return 0
}
