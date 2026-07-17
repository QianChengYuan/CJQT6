# CJQT6 QML模块

QML模块提供Qt Quick/QML支持，允许使用声明式QML语言构建现代UI。

## QQmlApplicationEngine - QML应用引擎

```cangjie
import cjqt6.qml.*

// 创建引擎
let engine = QQmlApplicationEngine()

// 加载内联QML代码
let qmlCode = """
import QtQuick
import QtQuick.Controls

ApplicationWindow {
    visible: true
    width: 400
    height: 300
    title: "QML Demo"
    
    Button {
        text: "Click Me"
        anchors.centerIn: parent
        onClicked: console.log("Clicked!")
    }
}
"""
engine.loadData(qmlCode)
```

**QQmlApplicationEngine 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建QML引擎 |
| `loadFile(path: String)` | 加载QML文件 |
| `loadUrl(url: String)` | 加载QML URL |
| `loadData(qmlCode: String)` | 加载内联QML代码 |
| `setContextProperty(name: String, value: Int64)` | 设置上下文对象 |
| `setContextPropertyString(name, value)` | 设置上下文字符串 |
| `setContextPropertyInt(name, value)` | 设置上下文整数 |
| `setContextPropertyDouble(name, value)` | 设置上下文浮点数 |
| `setContextPropertyBool(name, value)` | 设置上下文布尔值 |
| `rootObjects(): Int64` | 获取根对象列表 |
| `rootObjectsCount(): Int32` | 获取根对象数量 |
| `clearComponentCache()` | 清除组件缓存 |
| `addImportPath(path: String)` | 添加导入路径 |
| `delete()` | 释放资源 |

---

## QQuickView - QML视图窗口

```cangjie
let view = QQuickView()
view.setTitle("QML View")
view.resize(400, 300)
view.setResizeMode(ResizeMode.SizeRootObjectToView)
view.setSourceUrl("qrc:/main.qml")  // 或内联QML
view.show()
```

**QQuickView 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建QML视图 |
| `setSource(path: String)` | 设置QML源文件 |
| `setSourceUrl(url: String)` | 设置QML URL |
| `show()` | 显示窗口 |
| `hide()` | 隐藏窗口 |
| `setTitle(title: String)` | 设置标题 |
| `resize(width, height)` | 设置大小 |
| `setResizeMode(mode: Int32)` | 设置调整模式 |
| `rootObject(): Int64` | 获取根对象 |
| `delete()` | 释放资源 |

**ResizeMode 常量**:
```cangjie
ResizeMode.SizeViewToRootObject    // 视图跟随根项
ResizeMode.SizeRootObjectToView    // 根项跟随视图
```

---

## QQuickItem - QML项操作

```cangjie
// 获取QML项
let item = QQuickItem(itemPtr)

// 设置属性
item.setPropertyString("text", "Hello")
item.setPropertyInt("value", 42)
item.setPropertyBool("visible", true)

// 获取属性
let text = item.getPropertyString("text")
let value = item.getPropertyInt("value")
```

**QQuickItem 方法**:
| 方法 | 说明 |
|------|------|
| `setVisible(visible: Bool)` | 设置可见性 |
| `isVisible(): Bool` | 是否可见 |
| `setEnabled(enabled: Bool)` | 设置启用状态 |
| `isEnabled(): Bool` | 是否启用 |
| `setX(x: Float32)` | 设置X坐标 |
| `setY(y: Float32)` | 设置Y坐标 |
| `setWidth(w: Float32)` | 设置宽度 |
| `setHeight(h: Float32)` | 设置高度 |
| `x(): Float32` | 获取X坐标 |
| `y(): Float32` | 获取Y坐标 |
| `width(): Float32` | 获取宽度 |
| `height(): Float32` | 获取高度 |
| `findChild(name: String): Int64` | 查找子项 |
| `setProperty(name, value: String)` | 设置字符串属性 |
| `setPropertyInt(name, value: Int32)` | 设置整数属性 |
| `setPropertyDouble(name, value: Float64)` | 设置浮点属性 |
| `setPropertyBool(name, value: Bool)` | 设置布尔属性 |
| `getPropertyString(name): String` | 获取字符串属性 |
| `getPropertyInt(name): Int32` | 获取整数属性 |
| `getPropertyDouble(name): Float64` | 获取浮点属性 |
| `getPropertyBool(name): Bool` | 获取布尔属性 |

---

## 已知限制

**QML 模块状态**: ⚠️ 部分功能不可用（2026-03-20 测试）

**QQmlApplicationEngine**: 
- ✅ 创建引擎成功
- ❌ `loadFile()` 和 `loadData()` 调用后程序卡住无响应
- 可能原因：Qt Quick 插件与仓颉运行时兼容性问题

**QQuickView**: 
- ❌ 创建时程序崩溃
- 暂时不可用

**QWidget**: ✅ 正常工作，可作为替代方案

**运行环境**: 运行 QML 应用需要设置 `QML2_IMPORT_PATH` 环境变量：
```bash
# Windows
set QML2_IMPORT_PATH=C:\Qt\6.10.2\mingw_64\qml

# Linux
export QML2_IMPORT_PATH=/usr/lib/x86_64-linux-gnu/qt6/qml
```

**临时解决方案**: 如需 QML 功能，建议使用 QWidget + QQuickWidget 嵌入方式，或等待后续修复。
