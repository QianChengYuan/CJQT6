package cjqt6.resource

import cjqt6.core.{QtResource, ResourceDisposedException}
import std.collection.{ArrayList, HashMap}

/// 资源容器配置类
/// 用于配置ResourceContainer的行为
public class ContainerConfig {
    /// 是否启用日志输出
    public let logEnabled: Bool
    
    /// 关闭容器时是否自动释放所有管理的控件
    public let autoReleaseOnClose: Bool
    
    /// 默认构造函数
    /// logEnabled=false, autoReleaseOnClose=true
    public init() {
        this.logEnabled = false
        this.autoReleaseOnClose = true
    }
    
    /// 自定义配置构造函数
    public init(logEnabled: Bool, autoReleaseOnClose: Bool) {
        this.logEnabled = logEnabled
        this.autoReleaseOnClose = autoReleaseOnClose
    }
    
    /// 获取默认配置
    public static func defaultConfig(): ContainerConfig {
        return ContainerConfig()
    }
}

/// 资源容器统计信息类
/// 用于获取容器的当前状态
public class ContainerStats {
    /// 总控件数量
    public let totalCount: Int32
    
    /// 活跃控件数量（未释放）
    public let activeCount: Int32
    
    /// 已释放控件数量
    public let releasedCount: Int32
    
    /// 按类型统计的控件数量
    public let typeCounts: HashMap<String, Int32>
    
    public init(totalCount: Int32, activeCount: Int32, releasedCount: Int32, typeCounts: HashMap<String, Int32>) {
        this.totalCount = totalCount
        this.activeCount = activeCount
        this.releasedCount = releasedCount
        this.typeCounts = typeCounts
    }
    
    /// 转换为字符串表示
    public func toString(): String {
        return "ContainerStats(total=${totalCount}, active=${activeCount}, released=${releasedCount})"
    }
}

/// 资源容器类
/// 
/// 用于统一管理多个Qt控件的释放
/// 提供链式调用、批量释放、分类管理等特性
/// 
/// 主要特性：
/// - 链式调用：add()返回this，支持流畅API
/// - 批量管理：一次性添加或释放多个控件
/// - 分类管理：按类型分组，支持按类型释放
/// - 自动释放：可配置关闭时自动释放
/// - 统计信息：实时查看容器状态
/// 
/// 使用示例：
/// ```cangjie
/// let container = ResourceContainer()
/// container.add(btn1).add(btn2).add(label)
/// container.releaseAll() // 或 container.close()
/// ```
public class ResourceContainer <: QtResource {
    /// 控件列表
    private let widgets: ArrayList<QtResource>
    
    /// 按类型分组的控件映射
    private let typeGroups: HashMap<String, ArrayList<QtResource>>
    
    /// 容器是否已关闭
    private var closed: Bool
    
    /// 容器配置
    private let config: ContainerConfig
    
    /// 默认构造函数
    public init() {
        this.widgets = ArrayList<QtResource>()
        this.typeGroups = HashMap<String, ArrayList<QtResource>>()
        this.closed = false
        this.config = ContainerConfig()
    }
    
    /// 带配置的构造函数
    /// 
    /// 参数:
    ///   config - 容器配置选项
    public init(config: ContainerConfig) {
        this.widgets = ArrayList<QtResource>()
        this.typeGroups = HashMap<String, ArrayList<QtResource>>()
        this.closed = false
        this.config = config
    }
    
    /// 添加控件到容器
    /// 
    /// 将控件添加到管理列表，并按类型分组
    /// 已关闭的控件会被忽略
    /// 
    /// 参数:
    ///   widget - 要添加的控件
    /// 返回:
    ///   this，支持链式调用
    /// 异常:
    ///   ResourceDisposedException - 容器已关闭
    public func add(widget: QtResource): ResourceContainer {
        if (this.closed) {
            throw ResourceDisposedException("Container already closed")
        }
        
        // 检查控件是否已关闭
        if (widget.isClosed()) {
            if (this.config.logEnabled) {
                println("Warning: Adding already closed widget")
            }
            return this
        }
        
        // 添加到控件列表
        this.widgets.add(widget)
        
        // 按类型分组
        let typeName = getTypeName(widget)
        if (!this.typeGroups.contains(typeName)) {
            this.typeGroups[typeName] = ArrayList<QtResource>()
        }
        this.typeGroups[typeName].add(widget)
        
        return this
    }
    
    /// 批量添加控件
    /// 
    /// 遍历数组并逐个添加控件
    /// 支持链式调用
    /// 
    /// 参数:
    ///   widgets - 要添加的控件数组
    /// 返回:
    ///   this，支持链式调用
    public func addAll(widgets: Array<QtResource>): ResourceContainer {
        for (i in 0..widgets.size) {
            this.add(widgets[i])
        }
        return this
    }
    
    /// 从容器移除控件（不释放）
    /// 
    /// 将控件从管理列表移除，但不调用close()
    /// 同时从类型分组中移除
    /// 
    /// 参数:
    ///   widget - 要移除的控件
    /// 返回:
    ///   true表示成功移除，false表示控件不在容器中
    public func remove(widget: QtResource): Bool {
        if (this.closed) {
            return false
        }
        
        let index = findWidgetIndex(widget)
        if (index < 0) {
            return false
        }
        
        // 从主列表移除
        this.widgets.remove(at: index)
        
        // 从类型分组移除
        let typeName = getTypeName(widget)
        if (this.typeGroups.contains(typeName)) {
            let group = this.typeGroups[typeName]
            let groupIndex = findWidgetIndexInGroup(widget, group)
            if (groupIndex >= 0) {
                group.remove(at: groupIndex)
            }
        }
        
        return true
    }
    
    /// 释放所有控件
    /// 
    /// 遍历所有控件并调用close()
    /// 已关闭的控件会被跳过
    /// 释放后清空控件列表和类型分组
    /// 
    /// 返回:
    ///   ReleaseResult 包含释放统计信息
    public func releaseAll(): ReleaseResult {
        var total: Int32 = 0
        var success: Int32 = 0
        var failed: Int32 = 0
        var skipped: Int32 = 0
        
        for (widget in this.widgets) {
            total += 1
            
            if (widget.isClosed()) {
                skipped += 1
            } else {
                try {
                    widget.close()
                    success += 1
                } catch (ex: Exception) {
                    failed += 1
                    if (this.config.logEnabled) {
                        println("Failed to release widget: ${ex}")
                    }
                }
            }
        }
        
        // 清空所有数据结构
        this.widgets.clear()
        this.typeGroups.clear()
        
        return ReleaseResult(total, success, failed, skipped, 0)
    }
    
    /// 按类型释放控件
    /// 
    /// 只释放指定类型的控件
    /// 释放后从容器中移除这些控件
    /// 
    /// 参数:
    ///   typeName - 类型名称
    /// 返回:
    ///   ReleaseResult 包含释放统计信息
    public func releaseByType(typeName: String): ReleaseResult {
        // 检查类型是否存在
        if (!this.typeGroups.contains(typeName)) {
            return ReleaseResult(0, 0, 0, 0, 0)
        }
        
        let group = this.typeGroups[typeName]
        var total: Int32 = 0
        var success: Int32 = 0
        var failed: Int32 = 0
        var skipped: Int32 = 0
        
        // 释放该类型的所有控件
        for (widget in group) {
            total += 1
            
            if (widget.isClosed()) {
                skipped += 1
            } else {
                try {
                    widget.close()
                    success += 1
                } catch (ex: Exception) {
                    failed += 1
                    if (this.config.logEnabled) {
                        println("Failed to release widget of type ${typeName}: ${ex}")
                    }
                }
            }
        }
        
        // 从主列表中移除已释放的控件
        let widgetsToRemove = ArrayList<QtResource>()
        for (widget in group) {
            widgetsToRemove.add(widget)
        }
        
        for (widget in widgetsToRemove) {
            let index = findWidgetIndex(widget)
            if (index >= 0) {
                this.widgets.remove(at: index)
            }
        }
        
        // 移除类型分组
        this.typeGroups.remove(typeName)
        
        return ReleaseResult(total, success, failed, skipped, 0)
    }
    
    /// 获取容器统计信息
    /// 
    /// 统计总控件数、活跃控件数、已释放控件数
    /// 按类型统计各类型的控件数量
    /// 
    /// 返回:
    ///   ContainerStats 包含统计信息
    public func getStats(): ContainerStats {
        let typeCounts = HashMap<String, Int32>()
        var activeCount: Int32 = 0
        
        // 统计各类型的活跃控件数
        for ((typeName, group) in this.typeGroups) {
            var count: Int32 = 0
            for (widget in group) {
                if (!widget.isClosed()) {
                    count += 1
                    activeCount += 1
                }
            }
            if (count > 0) {
                typeCounts[typeName] = count
            }
        }
        
        let releasedCount = Int32(this.widgets.size) - activeCount
        
        return ContainerStats(Int32(this.widgets.size), activeCount, releasedCount, typeCounts)
    }
    
    /// 检查容器是否已关闭
    public func isClosed(): Bool {
        return this.closed
    }
    
    /// 关闭容器
    /// 
    /// 根据配置决定是否自动释放所有控件
    /// 标记容器为已关闭状态
    /// 支持重复调用（幂等）
    public func close(): Unit {
        if (this.closed) {
            return
        }
        
        if (this.config.autoReleaseOnClose) {
            this.releaseAll()
        }
        
        this.closed = true
    }
    
    /// 获取底层指针
    /// 
    /// 注意：ResourceContainer不是Qt对象，返回0
    public func getPtr(): Int64 {
        return 0
    }
    
    /// 检查容器是否有效
    /// 
    /// 返回: true表示未关闭，false表示已关闭
    public func isValid(): Bool {
        return !this.closed
    }
    
    /// 检查有效性，无效时抛出异常
    /// 
    /// 异常:
    ///   ResourceDisposedException - 容器已关闭
    public func checkValid(): Unit {
        if (this.closed) {
            throw ResourceDisposedException("Container already closed")
        }
    }
    
    /// 获取控件的类型名称
    /// 
    /// 注意：当前返回固定值"QtResource"
    /// 未来可通过反射获取实际类型名
    private func getTypeName(widget: QtResource): String {
        return "QtResource"
    }
    
    /// 查找控件在列表中的索引
    /// 
    /// 参数:
    ///   widget - 要查找的控件
    /// 返回:
    ///   索引位置，未找到返回-1
    private func findWidgetIndex(widget: QtResource): Int64 {
        for (i in 0..this.widgets.size) {
            if (this.widgets[i].getPtr() == widget.getPtr()) {
                return i
            }
        }
        return -1
    }
    
    /// 查找控件在类型分组中的索引
    /// 
    /// 参数:
    ///   widget - 要查找的控件
    ///   group - 类型分组列表
    /// 返回:
    ///   索引位置，未找到返回-1
    private func findWidgetIndexInGroup(widget: QtResource, group: ArrayList<QtResource>): Int64 {
        for (i in 0..group.size) {
            if (group[i].getPtr() == widget.getPtr()) {
                return i
            }
        }
        return -1
    }
}
