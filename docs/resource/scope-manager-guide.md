# ScopeManager 使用指南

## 概述

`ScopeManager` 是作用域资源管理器，用于基于代码块作用域自动管理资源。它提供：

- **RAII模式**：基于作用域的自动资源管理
- **防止重复管理**：全局注册表防止控件被多个作用域管理
- **作用域隔离**：嵌套作用域内层先释放
- **提前释放**：支持手动提前释放所有资源
- **统计信息**：查看作用域状态和控件数量

## 核心概念

### 全局注册表

ScopeManager 使用全局注册表来追踪每个控件被哪个作用域管理：

- 当控件被注册到作用域时，全局注册表记录映射关系
- 尝试将同一控件注册到另一作用域时会被忽略
- 作用域关闭时自动清理注册表

### 作用域生命周期

```cangjie
try (scope = ScopeManager()) {
    // 创建和注册控件
    scope.register(btn1).register(btn2)
    
    // 使用控件...
    
} // 退出作用域时自动调用 scope.close()
  // 所有控件被自动释放
```

## 基本用法

### 1. 创建作用域

```cangjie
let scope = ScopeManager()

// 查看统计信息
let stats = scope.getStats()
println("作用域ID: ${stats.scopeId}")
println("是否活跃: ${stats.isActive}")
println("控件数量: ${stats.widgetCount}")
```

### 2. 注册控件

```cangjie
let scope = ScopeManager()

let btn = QPushButton()
let label = QLabel()

scope.register(btn)
scope.register(label)

// 链式调用
scope.register(btn1).register(btn2).register(label)
```

### 3. 移除控件

```cangjie
let scope = ScopeManager()
let btn = QPushButton()

scope.register(btn)

// 从作用域移除（不释放）
let removed = scope.unregister(btn)
println("移除成功: ${removed}")
```

## 批量释放

### 手动释放所有控件

```cangjie
let scope = ScopeManager()
scope.register(btn1).register(btn2).register(label)

let result = scope.releaseAll()

println("总数: ${result.totalCount}")
println("成功: ${result.successCount}")
println("失败: ${result.failedCount}")

if (result.isAllSuccess()) {
    println("所有控件释放成功")
}
```

### 自动释放（关闭作用域时）

```cangjie
let scope = ScopeManager()
scope.register(btn)

// 关闭作用域时自动释放所有控件
scope.close()

println(btn.isClosed()) // true
```

## 防止重复管理

```cangjie
let scope1 = ScopeManager()
let scope2 = ScopeManager()
let btn = QPushButton()

// 控件被 scope1 管理
scope1.register(btn)

// 尝试注册到 scope2 会被忽略
scope2.register(btn)

println(scope1.getStats().widgetCount) // 1
println(scope2.getStats().widgetCount) // 0

scope1.close()
scope2.close()
```

## 配置选项

### ScopeConfig 参数

```cangjie
let config = ScopeConfig(
    autoRelease: true,      // 关闭作用域时是否自动释放（默认true）
    logEnabled: false,      // 是否启用日志（默认false）
    throwOnFailure: false,  // 释放失败时是否抛出异常（默认false）
    maxRetries: 0,          // 最大重试次数（默认0）
    releaseTimeout: 1000    // 单个控件释放超时（毫秒，默认1000）
)

let scope = ScopeManager(config)
```

### 禁用自动释放

```cangjie
let config = ScopeConfig(false, false, false, 0, 1000)
let scope = ScopeManager(config)

scope.register(btn)
scope.close()

// 控件未被释放
println(btn.isClosed()) // false

// 需要手动释放
btn.close()
```

## try-with-resources 模式

```cangjie
// 推荐：使用 try-with-resources 自动管理
try (scope = ScopeManager()) {
    scope
        .register(QPushButton())
        .register(QLabel())
    
    // 在作用域内使用控件...
    
} // 自动调用 scope.close()，释放所有控件
```

## 统计信息

```cangjie
let scope = ScopeManager()
scope.register(btn1).register(btn2).register(label)

let stats = scope.getStats()

println("作用域ID: ${stats.scopeId}")
println("是否活跃: ${stats.isActive}")
println("控件数量: ${stats.widgetCount}")
println("创建时间: ${stats.createdTime}")
```

## API 参考

### ScopeConfig

| 字段 | 类型 | 说明 | 默认值 |
|------|------|------|--------|
| autoRelease | Bool | 关闭时是否自动释放 | true |
| logEnabled | Bool | 是否启用日志 | false |
| throwOnFailure | Bool | 释放失败时是否抛出异常 | false |
| maxRetries | Int32 | 最大重试次数 | 0 |
| releaseTimeout | Int64 | 单个控件释放超时（毫秒） | 1000 |

### ScopeStats

| 字段 | 类型 | 说明 |
|------|------|------|
| scopeId | String | 作用域唯一标识 |
| isActive | Bool | 是否活跃（未关闭） |
| widgetCount | Int64 | 控件数量 |
| createdTime | Int64 | 创建时间 |
| closedTime | Int64 | 关闭时间 |

### WidgetInfo 类

ScopeManager 内部登记控件的元数据类，记录每个注册控件的底层指针、类型与释放状态（由 ScopeManager 内部维护，一般无需直接构造）。

| 字段 | 类型 | 说明 |
|------|------|------|
| ptr | Int64 | 控件的底层指针 |
| typeName | String | 控件的类型名称 |
| registerTime | Int64 | 注册时间（毫秒时间戳） |
| status | ReleaseStatus | 当前释放状态（Pending/Released/Failed/Skipped） |

### ScopeManager 方法

| 方法 | 说明 |
|------|------|
| `register(widget: QtResource)` | 注册控件到作用域，返回this |
| `unregister(widget: QtResource)` | 移除控件（不释放），返回是否成功 |
| `releaseAll()` | 释放所有控件，返回ReleaseResult |
| `getStats()` | 获取作用域统计信息 |
| `close()` | 关闭作用域（根据配置决定是否自动释放） |
| `isClosed()` | 检查作用域是否已关闭 |

### ReleaseStatus 枚举

| 值 | 说明 |
|------|------|
| Pending | 待释放 |
| Released | 已释放 |
| Failed | 释放失败 |
| Skipped | 已跳过（控件已关闭） |

## 使用场景

### 适合使用ScopeManager的场景

1. **函数级资源管理**：函数内创建多个临时控件，函数结束时自动释放
2. **嵌套作用域**：需要明确资源生命周期的层次结构
3. **防止重复管理**：需要确保控件不会被多个管理器管理
4. **异常安全**：即使发生异常，资源也会正确释放

### 与ResourceContainer的区别

| 特性 | ScopeManager | ResourceContainer |
|------|--------------|-------------------|
| 核心用途 | 基于作用域的RAII | 长期持有的资源集合 |
| 防重复管理 | ✅ 全局注册表 | ❌ 无 |
| 嵌套支持 | ✅ 作用域隔离 | ❌ 无 |
| 动态管理 | ❌ 主要用于固定集合 | ✅ 动态增删 |
| 分类管理 | ❌ 无 | ✅ 按类型分组 |

## 最佳实践

1. **优先使用try-with-resources**：确保资源自动释放
2. **避免混用多个管理器**：同一控件不要同时用ScopeManager和ResourceContainer管理
3. **配置日志**：开发阶段启用日志便于调试
4. **作用域粒度**：作用域粒度不宜过大，按功能模块划分

## 相关资源

- [ResourceContainer 使用指南](./resource-container-guide.md) - 资源容器
- [ResourceUtils 使用指南](./resource-utils-guide.md) - 批量释放工具
- [资源管理最佳实践](./resource-management.md) - 完整资源管理策略
