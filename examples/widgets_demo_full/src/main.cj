package widgets_demo_full

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*

main(): Int32 {
    let app = QApplication()
    let window = QWidget()
    window.setTitle("CJQT6 Widgets Demo - All Controls")
    window.resize(800, 700)

    let mainLayout = QVBoxLayout()
    mainLayout.setMargin(10)
    mainLayout.setSpacing(0)

    let title = QLabel()
    title.setText("CJQT6 Widgets Demo")
    title.setAlignment(Int32(132))
    title.setStyleSheet("font-size: 18px; font-weight: bold; padding: 8px;")
    mainLayout.addWidget(title.getPtr())

    let tabs = QTabWidget()

    let basicTab = createBasicTab()
    tabs.addTab(basicTab.getPtr(), "Basic")

    let selectorsTab = createSelectorsTab()
    tabs.addTab(selectorsTab.getPtr(), "Selectors")

    let containersTab = createContainersTab()
    tabs.addTab(containersTab.getPtr(), "Containers")

    let newWidgetsTab = createNewWidgetsTab()
    tabs.addTab(newWidgetsTab.getPtr(), "New Widgets")

    let modelViewTab = createModelViewTab()
    tabs.addTab(modelViewTab.getPtr(), "Model/View")

    mainLayout.addWidget(tabs.getPtr())

    let footer = QLabel()
    footer.setText("CJQT6 - Cangjie Qt6 Binding Library")
    footer.setAlignment(Int32(132))
    footer.setStyleSheet("color: gray; padding: 4px;")
    mainLayout.addWidget(footer.getPtr())

    window.setLayout(mainLayout.getPtr())
    window.show()

    let result = app.exec()
    return result
}
