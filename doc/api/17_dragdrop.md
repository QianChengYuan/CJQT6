# CJQT6 拖放支持模块

本模块提供拖放（Drag & Drop）支持，包括 MIME 数据封装和拖放操作。

## 模块导入

```cangjie
import cjqt6.core.*
```

## QMimeData - MIME 数据

用于拖放操作中传递数据的容器，支持文本、HTML、URL、图像等多种格式。

```cangjie
// 创建 MIME 数据
let mimeData = QMimeData()

// 设置文本数据
mimeData.setText("拖放文本内容")

// 设置 HTML 数据
mimeData.setHtml("<h1>拖放HTML内容</h1>")

// 检查数据类型
if (mimeData.hasText()) {
    let text = mimeData.text()
}

if (mimeData.hasHtml()) {
    let html = mimeData.html()
}

if (mimeData.hasUrls()) {
    let count = mimeData.urlsCount()
    for (i in 0..count) {
        let url = mimeData.urlAt(i)
    }
}

if (mimeData.hasImage()) {
    // 包含图像数据
}
```

**QMimeData 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建 MIME 数据 |
| `init(ptr: Int64, owned: Bool)` | 从指针创建 |
| `setText(text: String)` | 设置文本数据 |
| `text(): String` | 获取文本数据 |
| `setHtml(html: String)` | 设置 HTML 数据 |
| `html(): String` | 获取 HTML 数据 |
| `urlsCount(): Int32` | 获取 URL 数量 |
| `urlAt(index: Int32): String` | 获取指定索引的 URL |
| `hasText(): Bool` | 是否包含文本 |
| `hasHtml(): Bool` | 是否包含 HTML |
| `hasUrls(): Bool` | 是否包含 URL |
| `hasImage(): Bool` | 是否包含图像 |
| `clear()` | 清空所有数据 |
| `getPtr(): Int64` | 获取指针 |
| `delete()` | 释放资源 |

---

## QDrag - 拖放操作

执行拖放操作的核心类，支持设置拖放数据、拖动图像和热点。

```cangjie
// 创建拖放操作
let drag = QDrag(sourceWidgetPtr)
let mimeData = QMimeData()
mimeData.setText("拖放数据")
drag.setMimeData(mimeData)

// 设置拖动时显示的图像
drag.setPixmap(pixmapPtr)

// 设置热点位置（相对于拖动图像左上角）
drag.setHotSpot(16, 16)

// 执行拖放操作
let result = drag.exec(DropActionCopy())
if (result == DropActionCopy()) {
    println("执行了复制操作")
}

// 获取源和目标
let sourcePtr = drag.source()
let targetPtr = drag.target()

// 静态取消当前拖放操作
QDrag.cancel()
```

**QDrag 方法**:
| 方法 | 说明 |
|------|------|
| `init(sourcePtr: Int64)` | 创建拖放操作 |
| `setMimeData(mimeData: QMimeData)` | 设置 MIME 数据 |
| `setPixmap(pixmapPtr: Int64)` | 设置拖动图像 |
| `setHotSpot(x: Int32, y: Int32)` | 设置热点位置 |
| `exec(supportedActions: Int32): Int32` | 执行拖放操作 |
| `exec(supportedActions, defaultAction): Int32` | 执行拖放操作（带默认动作） |
| `source(): Int64` | 获取源控件指针 |
| `target(): Int64` | 获取目标控件指针 |
| `cancel()` | 静态方法，取消当前拖放操作 |
| `getPtr(): Int64` | 获取指针 |

---

## 拖放辅助函数

提供快速开始拖放的便捷函数。

```cangjie
// 开始文本拖放
let action = startTextDrag(sourcePtr, "要拖放的文本", DropActionCopy())

// 开始文件拖放
let fileAction = startFileDrag(sourcePtr, "文件路径", DropActionCopy())
```

**辅助函数**:
| 函数 | 说明 |
|------|------|
| `startTextDrag(sourcePtr, text, supportedActions): Int32` | 开始文本拖放 |
| `startFileDrag(sourcePtr, filePath, supportedActions): Int32` | 开始文件拖放 |

---

## 拖放动作常量

| 常量 | 说明 |
|------|------|
| `DropActionCopy()` | 复制动作 |
| `DropActionMove()` | 移动动作 |
| `DropActionLink()` | 链接动作 |
| `DropActionIgnore()` | 忽略动作 |
