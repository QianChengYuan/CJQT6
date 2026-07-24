# CJQT6 QML模块

QML 模块提供 Qt Quick / QML 的轻量封装，当前实现以 QQmlApplicationEngine、QQuickView、QQuickWidget 和 QQuickItem 为主。

```cangjie
import cjqt6.qml.*

let engine = QQmlApplicationEngine()
engine.loadData("import QtQuick\nItem { width: 100; height: 100 }")
engine.delete()
```

## QQmlApplicationEngine

| 方法 | 说明 |
|------|------|
| `init()` | 创建引擎 |
| `loadFile(filePath: String)` | 加载 QML 文件 |
| `loadUrl(url: String)` | 加载 URL |
| `loadData(qmlData: String)` | 加载内联 QML 代码 |
| `clearComponentCache()` | 清理组件缓存 |
| `rootObjectsCount(): Int32` | 获取根对象数量 |
| `rootObject(): QQuickItem` | 获取根对象 |
| `setContextProperty(name: String, valuePtr: Int64)` | 设置上下文属性（对象指针） |
| `setContextPropertyString(name: String, value: String)` | 设置字符串上下文属性 |
| `setContextPropertyInt(name: String, value: Int32)` | 设置整数上下文属性 |
| `setContextPropertyDouble(name: String, value: Float64)` | 设置浮点上下文属性 |
| `setContextPropertyBool(name: String, value: Bool)` | 设置布尔上下文属性 |
| `addImportPath(path: String)` | 添加导入路径 |
| `showRootWindow()` | 显示根窗口 |
| `delete()` | 释放资源 |

## QQuickView

| 方法 | 说明 |
|------|------|
| `init()` | 创建 QML 视图窗口 |
| `setSource(source: String)` | 设置 QML 源文件 |
| `setSourceUrl(url: String)` | 设置 QML URL |
| `show()` / `hide()` | 显示或隐藏窗口 |
| `setTitle(title: String)` | 设置标题 |
| `resize(width: Int32, height: Int32)` | 设置窗口尺寸 |
| `rootObject(): QQuickItem` | 获取根对象 |
| `setResizeMode(mode: Int32)` | 设置大小调整模式 |
| `status(): Int32` | 获取加载状态 |
| `hasErrors(): Bool` | 是否存在错误 |
| `isReady(): Bool` | 是否已就绪 |
| `delete()` | 释放资源 |

### ResizeMode

```cangjie
ResizeMode.SizeViewToRootObject
ResizeMode.SizeRootObjectToView
```

## QQuickWidget

| 方法 | 说明 |
|------|------|
| `init()` | 创建嵌入式 QML Widget |
| `setSource(source: String)` | 设置 QML 源文件 |
| `setSourceUrl(url: String)` | 设置 QML URL |
| `show()` | 显示控件 |
| `resize(width: Int32, height: Int32)` | 设置控件尺寸 |
| `rootObject(): QQuickItem` | 获取根对象 |
| `setResizeMode(mode: Int32)` | 设置大小调整模式 |
| `getPtr(): Int64` | 获取底层指针 |
| `delete()` | 释放资源 |

## QQuickItem

```cangjie
let item = QQuickItem.fromPtr(ptr)
item.setVisible(true)
item.setX(10.0f32)
item.setWidth(120.0f32)
item.setProperty("text", "Hello")
```

| 方法 | 说明 |
|------|------|
| `fromPtr(p: Int64): QQuickItem` | 从已有指针创建对象 |
| `isValid(): Bool` | 检查对象是否有效 |
| `setVisible(visible: Bool)` | 设置可见性 |
| `isVisible(): Bool` | 是否可见 |
| `setEnabled(enabled: Bool)` | 设置启用状态 |
| `isEnabled(): Bool` | 是否启用 |
| `setX(x: Float32)` / `setY(y: Float32)` | 设置坐标 |
| `setWidth(width: Float32)` / `setHeight(height: Float32)` | 设置尺寸 |
| `x(): Float32` / `y(): Float32` | 获取坐标 |
| `width(): Float32` / `height(): Float32` | 获取尺寸 |
| `findChild(name: String): QQuickItem` | 查找子项 |
| `setProperty(name: String, value: String)` | 设置字符串属性 |
| `setPropertyInt(name: String, value: Int32)` | 设置整数属性 |
| `setPropertyDouble(name: String, value: Float64)` | 设置浮点属性 |
| `setPropertyBool(name: String, value: Bool)` | 设置布尔属性 |
| `getPropertyString(name: String): String` | 获取字符串属性 |
| `getPropertyInt(name: String): Int32` | 获取整数属性 |
| `getPropertyDouble(name: String): Float64` | 获取浮点属性 |
| `getPropertyBool(name: String): Bool` | 获取布尔属性 |

## 说明与限制

- 当前 QML 绑定主要偏向“可调用接口”封装，适合做轻量集成和脚本式交互。 
- QML 运行时依赖 Qt Quick 相关插件与环境变量；如果加载失败，可优先使用 QWidget / QQuickWidget 的方式做兼容方案。 
- 由于该模块的实际可用性和运行环境依赖较强，建议先在最小示例中验证后再迁移到正式应用。
