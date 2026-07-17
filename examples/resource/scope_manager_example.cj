package cjqt6.resource.example

import cjqt6.resource.*
import cjqt6.widgets.{QPushButton, QLabel}
import cjqt6.core.QApplication

main() {
    let args = ["ScopeManagerExample"]
    let app = QApplication(args)
    
    example1BasicUsage()
    example2ChainCall()
    example3PreventDoubleManagement()
    example4TryWithResources()
    example5Config()
    
    app.exec()
}

func example1BasicUsage() {
    println("\n=== 示例1：基本用法 ===")
    
    let scope = ScopeManager()
    
    let btn1 = QPushButton()
    let btn2 = QPushButton()
    let label = QLabel()
    
    scope.register(btn1)
    scope.register(btn2)
    scope.register(label)
    
    let stats = scope.getStats()
    println("作用域ID: ${stats.scopeId}")
    println("控件数量: ${stats.widgetCount}")
    
    let result = scope.releaseAll()
    println("释放结果: 总数=${result.totalCount}, 成功=${result.successCount}")
}

func example2ChainCall() {
    println("\n=== 示例2：链式调用 ===")
    
    let scope = ScopeManager()
    
    scope
        .register(QPushButton())
        .register(QPushButton())
        .register(QLabel())
    
    println("链式注册后控件数: ${scope.getStats().widgetCount}")
    
    scope.close()
}

func example3PreventDoubleManagement() {
    println("\n=== 示例3：防止重复管理 ===")
    
    let scope1 = ScopeManager()
    let scope2 = ScopeManager()
    let btn = QPushButton()
    
    scope1.register(btn)
    
    scope2.register(btn)
    
    println("作用域1控件数: ${scope1.getStats().widgetCount}")
    println("作用域2控件数: ${scope2.getStats().widgetCount}")
    
    scope1.close()
    scope2.close()
}

func example4TryWithResources() {
    println("\n=== 示例4：try-with-resources自动管理 ===")
    
    try (scope = ScopeManager()) {
        scope
            .register(QPushButton())
            .register(QLabel())
        
        println("作用域内控件数: ${scope.getStats().widgetCount}")
    }
    
    println("退出作用域后自动释放")
}

func example5Config() {
    println("\n=== 示例5：自定义配置 ===")
    
    let config = ScopeConfig(false, true, false, 2, 500)
    let scope = ScopeManager(config)
    
    let btn = QPushButton()
    scope.register(btn)
    
    println("autoRelease=false，关闭作用域不会自动释放控件")
    scope.close()
    
    println("按钮是否已关闭: ${btn.isClosed()}")
    
    btn.close()
}
