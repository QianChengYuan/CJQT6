package table_demo

import CJQT6.core.*
import CJQT6.widgets.*
import CJQT6.gui.*
import CJQT6.views.*

main(): Int32 {
    let app = QApplication()
    let window = QWidget()
    window.setTitle("QTableWidget 表格演示")
    window.resize(600, 400)
    
    // 创建主布局
    let mainLayout = QVBoxLayout()
    
    // 创建表格 (5行3列)
    let table = QTableWidget(5, 3)
    
    // 设置表头
    table.setHorizontalHeaderLabel(0, "姓名")
    table.setHorizontalHeaderLabel(1, "年龄")
    table.setHorizontalHeaderLabel(2, "城市")
    
    // 填充数据
    table.setItem(0, 0, "张三")
    table.setItem(0, 1, "25")
    table.setItem(0, 2, "北京")
    
    table.setItem(1, 0, "李四")
    table.setItem(1, 1, "30")
    table.setItem(1, 2, "上海")
    
    table.setItem(2, 0, "王五")
    table.setItem(2, 1, "28")
    table.setItem(2, 2, "广州")
    
    table.setItem(3, 0, "赵六")
    table.setItem(3, 1, "35")
    table.setItem(3, 2, "深圳")
    
    table.setItem(4, 0, "钱七")
    table.setItem(4, 1, "22")
    table.setItem(4, 2, "杭州")
    
    // 设置表格属性
    table.setAlternatingRowColors(true)
    table.setShowGrid(true)
    table.setSelectionBehavior(SelectRows)
    table.setSelectionMode(SingleSelection)
    
    // 自动填充窗口宽度（所有列平均分配）
    table.setAutoFillWidth()
    
    // 或者设置最后一列拉伸填充剩余空间
    // table.setHorizontalHeaderStretchLastSection(true)
    
    mainLayout.addWidget(table.getPtr())
    
    // 设置窗口布局
    window.setLayout(mainLayout.getPtr())
    
    // 显示窗口
    window.show()
    
    // 运行应用
    let result = app.exec()
    
    // 清理资源
    table.delete()
    window.delete()
    app.delete()
    
    return result
}
