package cjqt6.resource.example

import cjqt6.resource.*
import cjqt6.widgets.{QPushButton, QLabel}
import cjqt6.core.QApplication

main() {
    let args = ["ResourceContainerExample"]
    let app = QApplication(args)
    
    example1BasicUsage()
    example2ChainCall()
    example3TypeRelease()
    example4TryWithResources()
    example5Config()
    
    app.exec()
}

func example1BasicUsage() {
    println("\n=== 示例1：基本用法 ===")
    
    let container = ResourceContainer()
    
    let btn1 = QPushButton()
    let btn2 = QPushButton()
    let label = QLabel()
    
    container.add(btn1)
    container.add(btn2)
    container.add(label)
    
    let stats = container.getStats()
    println("总控件数: ${stats.totalCount}")
    println("活跃控件数: ${stats.activeCount}")
    
    let result = container.releaseAll()
    println("释放结果: 总数=${result.totalCount}, 成功=${result.successCount}")
}

func example2ChainCall() {
    println("\n=== 示例2：链式调用 ===")
    
    let container = ResourceContainer()
    
    container
        .add(QPushButton())
        .add(QPushButton())
        .add(QLabel())
        .add(QLabel())
    
    println("链式添加后控件数: ${container.getStats().totalCount}")
    
    container.close()
}

func example3TypeRelease() {
    println("\n=== 示例3：按类型释放 ===")
    
    let container = ResourceContainer()
    
    let btn1 = QPushButton()
    let btn2 = QPushButton()
    let label = QLabel()
    
    container.addAll([btn1, btn2, label])
    
    println("释放前总数: ${container.getStats().totalCount}")
    
    let result = container.releaseByType("QtResource")
    println("按类型释放: 成功=${result.successCount}")
    println("释放后总数: ${container.getStats().totalCount}")
}

func example4TryWithResources() {
    println("\n=== 示例4：try-with-resources自动管理 ===")
    
    try (container = ResourceContainer()) {
        container
            .add(QPushButton())
            .add(QLabel())
        
        println("容器内控件数: ${container.getStats().totalCount}")
    }
    
    println("退出作用域后容器自动关闭")
}

func example5Config() {
    println("\n=== 示例5：自定义配置 ===")
    
    let config = ContainerConfig(logEnabled: true, autoReleaseOnClose: false)
    let container = ResourceContainer(config)
    
    let btn = QPushButton()
    container.add(btn)
    
    println("autoReleaseOnClose=false，关闭容器不会自动释放控件")
    container.close()
    
    println("按钮是否已关闭: ${btn.isClosed()}")
    
    btn.close()
}
