# ResourceContainer 使用指南

## 概述

`ResourceContainer` 是资源容器类，用于统一管理多个Qt控件的释放。它提供：

- **链式调用**：支持流畅的API风格
- **批量释放**：一次性释放所有管理的控件
- **分类管理**：按类型分组，支持按类型释放
- **自动释放**：可配置关闭时自动释放
- **统计信息**：实时查看容器状态

## 基本用法

### 1. 创建和添加控件

```cangjie
let container = ResourceContainer()

let btn = QPushButton()
let label = QLabel()

container.add(btn)
container.add(label)

// 查看统计信息
let stats = container.getStats()
println("总控件数: ${stats.totalCount}")
println("活跃控件数: ${stats.activeCount}")
```

### 2. 链式调用

```cangjie
let container = ResourceContainer()

container
    .add(QPushButton())
    .add(QPushButton())
    .add(QLabel())
    .add(QLineEdit())
```

### 3. 批量添加

```cangjie
let container = ResourceContainer()
let widgets = [QPushButton(), QLabel(), QLineEdit()]

container.addAll(widgets)
```

### 4. 移除控件

```cangjie
let container = ResourceContainer()
let btn = QPushButton()

container.add(btn)

// 从容器移除（不释放）
let removed = container.remove(btn)
println("移除成功: ${removed}")
```

## 批量释放

### 释放所有控件

```cangjie
let container = ResourceContainer()
container.addAll([btn1, btn2, label])

let result = container.releaseAll()

println("总数: ${result.totalCount}")
println("成功: ${result.successCount}")
println("失败: ${result.failedCount}")
println("跳过: ${result.skippedCount}")

if (result.isAllSuccess()) {
    println("所有控件释放成功")
}
```

### 按类型释放

```cangjie
let container = ResourceContainer()
container.addAll([btn1, btn2, label])

// 只释放特定类型的控件
let result = container.releaseByType("QtResource")
```

## 自动释放配置

### 默认配置（关闭时自动释放）

```cangjie
let container = ResourceContainer()
container.add(btn)

// 关闭容器时自动释放所有控件
container.close()

println(btn.isClosed()) // true
```

### 禁用自动释放

```cangjie
let config = ContainerConfig(
    logEnabled: false,
    autoReleaseOnClose: false
)
let container = ResourceContainer(config)
container.add(btn)

// 关闭容器不会释放控件
container.close()

println(btn.isClosed()) // false

// 需要手动释放
btn.close()
```

## try-with-resources 模式

```cangjie
try (container = ResourceContainer()) {
    container
        .add(QPushButton())
        .add(QLabel())
    
    // 在作用域内使用控件...
    
} // 退出作用域时自动调用container.close()，释放所有控件
```

## 统计信息

```cangjie
let container = ResourceContainer()
container.addAll([btn1, btn2, label1, label2])

let stats = container.getStats()

println("总控件数: ${stats.totalCount}")
println("活跃控件数: ${stats.activeCount}")
println("已释放控件数: ${stats.releasedCount}")

// 按类型统计
for ((typeName, count) in stats.typeCounts) {
    println("${typeName}: ${count}")
}
```

## API 参考

### ContainerConfig

| 字段 | 类型 | 说明 | 默认值 |
|------|------|------|--------|
| logEnabled | Bool | 是否启用日志 | false |
| autoReleaseOnClose | Bool | 关闭时是否自动释放 | true |

### ContainerStats

| 字段 | 类型 | 说明 |
|------|------|------|
| totalCount | Int32 | 总控件数 |
| activeCount | Int32 | 活跃控件数 |
| releasedCount | Int32 | 已释放控件数 |
| typeCounts | HashMap<String, Int32> | 按类型统计 |

### ResourceContainer 方法

| 方法 | 说明 |
|------|------|
| `add(widget: QtResource)` | 添加单个控件，返回this |
| `addAll(widgets: Array<QtResource>)` | 批量添加控件，返回this |
| `remove(widget: QtResource)` | 移除控件（不释放），返回是否成功 |
| `releaseAll()` | 释放所有控件，返回ReleaseResult |
| `releaseByType(typeName: String)` | 按类型释放控件，返回ReleaseResult |
| `getStats()` | 获取统计信息 |
| `close()` | 关闭容器（根据配置决定是否自动释放） |
| `isClosed()` | 检查容器是否已关闭 |

## 使用场景

### 适合使用ResourceContainer的场景

1. **对话框管理**：对话框中有多个控件，关闭对话框时统一释放
2. **动态UI**：运行时创建多个控件，需要批量管理
3. **临时资源**：某段代码中创建多个临时控件，使用try-with-resources自动管理

### 不适合的场景

1. **单个控件**：直接使用控件的close()方法
2. **parent-child关系**：Qt的parent-child机制已足够
3. **生命周期很长**：控件生命周期与应用相同，无需管理

## 最佳实践

1. **优先使用try-with-resources**：确保资源自动释放
2. **配置日志**：开发阶段启用日志便于调试
3. **及时释放**：不再使用的控件尽早释放
4. **避免重复管理**：不要将同一控件添加到多个容器

## 相关资源

- [ResourceUtils 使用指南](./resource-utils-guide.md) - 批量释放工具
- [资源管理最佳实践](./best-practices.md) - 完整资源管理策略
