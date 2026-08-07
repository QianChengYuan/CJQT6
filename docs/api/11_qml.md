# CJQT6 QML模块

QML 模块提供 Qt Quick / QML 的封装，覆盖引擎、视图、窗口、组件、上下文与 QML 项，支持属性操作与信号回调。

```cangjie
import cjqt6.qml.*

let engine = QQmlApplicationEngine()
engine.loadData("import QtQuick\nItem { width: 100; height: 100 }")
engine.delete()
```

> 所有类均实现 `QtResource` 接口，用完必须显式 `close()` / `delete()`，不要依赖 GC。

## QQmlApplicationEngine

QML 应用引擎，负责加载 QML 并管理根对象与上下文。

| 方法 | 说明 |
|------|------|
| `init()` | 创建引擎 |
| `loadFile(filePath: String)` | 加载 QML 文件 |
| `loadUrl(url: String)` | 加载 URL |
| `loadData(qmlData: String)` | 加载内联 QML 代码 |
| `clearComponentCache()` | 清理组件缓存 |
| `rootObjectsCount(): Int32` | 获取根对象数量 |
| `rootObject(): QQuickItem` | 获取第一个根对象（借用，不拥有所有权） |
| `rootContext(): QQmlContext` | 获取根上下文（借用，不拥有所有权） |
| `setContextProperty(name: String, valuePtr: Int64)` | 设置上下文属性（对象指针） |
| `setContextPropertyString(name: String, value: String)` | 设置字符串上下文属性 |
| `setContextPropertyInt(name: String, value: Int32)` | 设置整数上下文属性 |
| `setContextPropertyDouble(name: String, value: Float64)` | 设置浮点上下文属性 |
| `setContextPropertyBool(name: String, value: Bool)` | 设置布尔上下文属性 |
| `addImportPath(path: String)` | 添加导入路径 |
| `showRootWindow()` | 显示根窗口 |
| `isClosed(): Bool` / `isValid(): Bool` | 资源状态检查 |
| `checkValid()` | 校验指针有效，无效抛异常 |
| `close()` / `delete()` | 释放资源 |

## QQuickView

QML 视图窗口（基于 QWindow 的顶层窗口）。

| 方法 | 说明 |
|------|------|
| `init()` | 创建 QML 视图窗口 |
| `setSource(source: String)` | 设置 QML 源文件 |
| `setSourceUrl(url: String)` | 设置 QML URL |
| `show()` / `hide()` | 显示或隐藏窗口 |
| `setTitle(title: String)` | 设置标题 |
| `resize(width: Int32, height: Int32)` | 设置窗口尺寸 |
| `rootObject(): QQuickItem` | 获取根对象（借用） |
| `setResizeMode(mode: Int32)` | 设置大小调整模式 |
| `status(): Int32` | 获取加载状态（见 Status） |
| `hasErrors(): Bool` | 是否存在错误 |
| `isReady(): Bool` | 是否已就绪 |
| `engine(): Int64` | 获取引擎指针 |
| `getPtr(): Int64` | 获取原生指针 |
| `close()` / `delete()` | 释放资源 |

## QQuickWidget

嵌入式 QML Widget，可放入普通 Widget 布局中使用。

| 方法 | 说明 |
|------|------|
| `init()` | 创建嵌入式 QML Widget |
| `setSource(source: String)` | 设置 QML 源文件 |
| `setSourceUrl(url: String)` | 设置 QML URL |
| `show()` | 显示控件 |
| `resize(width: Int32, height: Int32)` | 设置控件尺寸 |
| `rootObject(): QQuickItem` | 获取根对象（借用） |
| `setResizeMode(mode: Int32)` | 设置大小调整模式 |
| `engine(): Int64` | 获取引擎指针 |
| `getPtr(): Int64` | 获取底层指针（用于布局） |
| `close()` / `delete()` | 释放资源 |

## QQuickWindow

独立的 QQuickWindow 窗口（不依赖 QQuickView/Engine 封装），支持窗口属性与信号。

```cangjie
let window = QQuickWindow()
window.setTitle("QQuickWindow 示例")
window.setColor(240, 248, 255, 255)  // 淡蓝背景
window.resize(400, 300)
window.show()
```

| 方法 | 说明 |
|------|------|
| `init()` | 创建窗口 |
| `show()` / `hide()` | 显示或隐藏窗口 |
| `setTitle(title: String)` | 设置标题 |
| `resize(width: Int32, height: Int32)` | 设置窗口尺寸 |
| `width(): Int32` / `height(): Int32` | 获取窗口尺寸 |
| `setColor(r: Int32, g: Int32, b: Int32, a: Int32)` | 设置背景色（RGBA 0~255） |
| `isVisible(): Bool` | 是否可见 |
| `contentItem(): QQuickItem` | 获取内容项（借用） |
| `setOnWidthChanged(cb: Int32Callback)` | 宽度变化回调（新宽度） |
| `setOnHeightChanged(cb: Int32Callback)` | 高度变化回调（新高度） |
| `setOnVisibleChanged(cb: Int32Callback)` | 可见性变化回调（1/0） |
| `disconnectWidthChanged()` 等 | 断开单个信号 |
| `disconnect()` | 断开全部信号 |
| `close()` / `delete()` | 释放资源 |

## QQmlComponent

QML 组件，可从 URL 或字符串数据创建，用于动态创建 QML 对象。

```cangjie
let component = QQmlComponent(engine.getPtr())
component.setData("import QtQuick\nRectangle { width: 50; height: 50; color: 'red' }")
if (component.isReady()) {
    let item = component.createObject(0, 0)  // 创建的项拥有所有权
    item.setVisible(true)
}
```

| 方法 | 说明 |
|------|------|
| `init(enginePtr: Int64)` | 创建组件（绑定指定引擎） |
| `loadUrl(url: String)` | 从 URL 加载组件 |
| `setData(data: String, url!: String = "")` | 从字符串加载（url 为可选的来源标识） |
| `status(): Int32` | 获取状态（见 Status） |
| `isReady(): Bool` | 是否加载就绪 |
| `isError(): Bool` | 是否加载出错 |
| `errorString(): String` | 获取错误描述 |
| `createObject(contextPtr: Int64, parentPtr: Int64): QQuickItem` | 创建对象实例（contextPtr/parentPtr 传 0 使用默认） |
| `setOnStatusChanged(cb: Int32Callback)` | 状态变化回调（新状态值） |
| `disconnectStatusChanged()` | 断开状态信号 |
| `close()` / `delete()` | 释放资源 |

## QQmlContext

QML 上下文，用于向 QML 暴露 C++ 对象与值。

```cangjie
// 借用引擎根上下文
let ctx = engine.rootContext()
ctx.setContextPropertyInt("count", 42)

// 独立创建子上下文（拥有所有权）
let sub = QQmlContext.create(0)
sub.setContextPropertyString("name", "CJQT6")
```

| 方法 | 说明 |
|------|------|
| `static fromPtr(p: Int64): QQmlContext` | 从已有指针借用（不拥有所有权） |
| `static create(parentContextPtr: Int64): QQmlContext` | 创建子上下文（拥有所有权，传 0 为顶层） |
| `setContextProperty(name: String, valuePtr: Int64)` | 设置上下文属性（对象指针） |
| `setContextPropertyString(name: String, value: String)` | 设置字符串属性 |
| `setContextPropertyInt(name: String, value: Int32)` | 设置整数属性 |
| `setContextPropertyDouble(name: String, value: Float64)` | 设置浮点属性 |
| `setContextPropertyBool(name: String, value: Bool)` | 设置布尔属性 |
| `setContextObject(objPtr: Int64)` | 设置上下文对象 |
| `contextObject(): Int64` | 获取上下文对象指针 |
| `parentContext(): Int64` | 获取父上下文指针 |
| `close()` / `delete()` | 释放资源（仅拥有的上下文会删除对象） |

## QQuickItem

QML 项，QML 中的可视元素基类，支持属性、动态属性与信号回调。

```cangjie
// 创建独立项（拥有所有权）
let item = QQuickItem.create()
item.setX(10.0f32)
item.setWidth(120.0f32)
item.setOpacity(0.8f32)
item.setVisible(true)

// 借用引擎中的项（不拥有所有权）
let root = engine.rootObject()
root.setOnWidthChanged({ => println("宽度变化") })
```

> 所有权说明：`create()` / `createObject()` 创建的项拥有所有权，`close()` 会删除对象；`fromPtr()` / `rootObject()` 等借用的项由 Qt 管理，`close()` 只标记关闭并断开信号。

### 静态工厂

| 方法 | 说明 |
|------|------|
| `static create(): QQuickItem` | 创建独立 QML 项（拥有所有权） |
| `static fromPtr(p: Int64): QQuickItem` | 从指针借用（不拥有所有权） |

### 通用属性

| 方法 | 说明 |
|------|------|
| `setVisible(v: Bool)` / `isVisible(): Bool` | 可见性 |
| `setEnabled(e: Bool)` / `isEnabled(): Bool` | 启用状态 |
| `setX(x: Float32)` / `setY(y: Float32)` | 设置坐标 |
| `x(): Float32` / `y(): Float32` | 获取坐标 |
| `setWidth(w: Float32)` / `setHeight(h: Float32)` | 设置尺寸 |
| `width(): Float32` / `height(): Float32` | 获取尺寸 |
| `setOpacity(o: Float32)` / `opacity(): Float32` | 不透明度（0~1） |
| `setRotation(r: Float32)` / `rotation(): Float32` | 旋转角度 |
| `setScale(s: Float32)` / `scale(): Float32` | 缩放比例 |
| `setZ(z: Float32)` / `z(): Float32` | 层级（z 值） |
| `setObjectName(name: String)` / `objectName(): String` | 对象名 |
| `setFocus(f: Bool)` / `hasFocus(): Bool` | 焦点 |
| `setParentItem(parent: QQuickItem)` / `parentItem(): Int64` | 父项 |
| `findChild(name: String): QQuickItem` | 按对象名查找子项 |

### 动态属性（QML 自定义属性）

| 方法 | 说明 |
|------|------|
| `setProperty(name: String, value: String)` | 设置字符串属性 |
| `setPropertyInt(name: String, value: Int32)` | 设置整数属性 |
| `setPropertyDouble(name: String, value: Float64)` | 设置浮点属性 |
| `setPropertyBool(name: String, value: Bool)` | 设置布尔属性 |
| `getPropertyString(name: String): String` | 获取字符串属性 |
| `getPropertyInt(name: String): Int32` | 获取整数属性 |
| `getPropertyDouble(name: String): Float64` | 获取浮点属性 |
| `getPropertyBool(name: String): Bool` | 获取布尔属性 |

### 信号回调

| 信号 | 回调类型 | 说明 |
|------|---------|------|
| `setOnXChanged` / `disconnectXChanged` | `VoidCallback` | x 变化 |
| `setOnYChanged` / `disconnectYChanged` | `VoidCallback` | y 变化 |
| `setOnWidthChanged` / `disconnectWidthChanged` | `VoidCallback` | 宽度变化 |
| `setOnHeightChanged` / `disconnectHeightChanged` | `VoidCallback` | 高度变化 |
| `setOnOpacityChanged` / `disconnectOpacityChanged` | `VoidCallback` | 不透明度变化 |
| `setOnRotationChanged` / `disconnectRotationChanged` | `VoidCallback` | 旋转变化 |
| `setOnScaleChanged` / `disconnectScaleChanged` | `VoidCallback` | 缩放变化 |
| `setOnZChanged` / `disconnectZChanged` | `VoidCallback` | z 变化 |
| `setOnVisibleChanged` / `disconnectVisibleChanged` | `VoidCallback` | 可见性变化 |
| `setOnEnabledChanged` / `disconnectEnabledChanged` | `VoidCallback` | 启用状态变化 |
| `setOnFocusChanged` / `disconnectFocusChanged` | `Int32Callback` | 焦点变化（1/0） |
| `setOnParentChanged` / `disconnectParentChanged` | `Int64Callback` | 父项变化（新父指针） |
| `setOnChildrenChanged` / `disconnectChildrenChanged` | `VoidCallback` | 子项变化 |
| `disconnect()` | - | 断开全部信号 |

> 回调可重复设置，新回调会替换旧回调（替换式连接）。回调必须定义为顶层 `let` 绑定 + 全局变量共享状态，不能捕获局部变量。

## 常量

### ResizeMode（视图大小调整模式）

```cangjie
ResizeMode.SizeViewToRootObject   // 视图大小跟随根对象
ResizeMode.SizeRootObjectToView   // 根对象大小跟随视图
```

### Status（组件状态）

```cangjie
Status.Null      // 未加载
Status.Ready     // 加载就绪
Status.Loading   // 加载中
Status.Error     // 加载出错
```

## 完整示例

```cangjie
import cjqt6.core.*
import cjqt6.qml.*

// 全局回调状态（CFunc 不能捕获局部变量）
var gWidth: Float32 = 0.0f32

let onWidthChanged = { =>
    println("宽度变为: ${gWidth}")
}

main(): Int32 {
    let app = QApplication()

    let engine = QQmlApplicationEngine()
    engine.loadData(
        "import QtQuick\n" +
        "Rectangle { width: 200; height: 150; color: 'lightblue' }"
    )

    let root = engine.rootObject()
    root.setOnWidthChanged(onWidthChanged)
    root.setWidth(300.0f32)   // 触发宽度变化回调

    let window = QQuickWindow()
    window.setTitle("QML 模块示例")
    window.resize(400, 300)
    window.show()

    let code = app.exec()

    window.delete()
    root.delete()      // 借用项，仅断开信号
    engine.delete()    // 引擎销毁，释放所有 QML 对象
    return code
}
```

## 说明与限制

- 借用指针（`rootObject()`、`fromPtr()`、`rootContext()`、`contentItem()` 等）不拥有所有权，引擎销毁后不可再使用。
- QML 运行时依赖 Qt Quick 相关插件与环境变量；如果加载失败，可优先使用 QWidget / QQuickWidget 的方式做兼容方案。
- `QQuickView` / `QQuickWidget` / `QQuickWindow` 需要 `QApplication` 实例，否则创建失败。
- 信号回调通过 FFI 从 Qt 事件循环触发，回调中不要执行耗时操作或触碰已释放对象。
