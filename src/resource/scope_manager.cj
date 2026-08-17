package cjqt6.resource

import cjqt6.core.{QtResource, ResourceDisposedException}
import std.collection.{ArrayList, HashMap}

// ============================================================
// 作用域管理器
// ============================================================

/// 作用域资源管理器
/// 
/// 基于代码块作用域自动管理Qt控件资源（RAII模式）
/// 通过全局注册表防止控件被多个作用域重复管理
/// 
/// 主要特性：
/// - 自动释放：作用域关闭时自动释放所有管理的控件
/// - 防重复管理：全局注册表确保每个控件只被一个作用域管理
/// - 链式调用：register()返回this，支持流畅API
/// - 统计信息：可查看作用域状态和控件数量
/// 
/// 使用示例：
/// ```cangjie
/// try (scope = ScopeManager()) {
///     scope.register(btn1).register(btn2).register(label)
///     // 使用控件...
/// } // 自动释放所有控件
/// ```
public class ScopeManager <: QtResource {
    /// 管理的控件列表
    private let widgets: ArrayList<QtResource>
    
    /// 控件详细信息映射（指针 -> 信息）
    private let widgetInfos: HashMap<Int64, WidgetInfo>
    
    /// 作用域唯一标识
    private let scopeId: String
    
    /// 是否已关闭
    private var closed: Bool
    
    /// 配置选项
    private let config: ScopeConfig
    
    /// 创建时间（毫秒时间戳）
    private let createdTime: Int64
    
    /// 默认构造函数
    /// 
    /// 使用默认配置创建作用域管理器
    /// 自动生成唯一作用域ID并注册到全局注册表
    public init() {
        this.widgets = ArrayList<QtResource>()
        this.widgetInfos = HashMap<Int64, WidgetInfo>()
        this.scopeId = ScopeManager.generateScopeId()
        this.closed = false
        this.config = ScopeConfig()
        this.createdTime = currentTimeMillis()
        
        // 注册到全局注册表
        ScopeManagerRegistry.registerScope(this.scopeId)
    }
    
    /// 带配置的构造函数
    /// 
    /// 参数:
    ///   config - 作用域配置选项
    public init(config: ScopeConfig) {
        this.widgets = ArrayList<QtResource>()
        this.widgetInfos = HashMap<Int64, WidgetInfo>()
        this.scopeId = ScopeManager.generateScopeId()
        this.closed = false
        this.config = config
        this.createdTime = currentTimeMillis()
        
        ScopeManagerRegistry.registerScope(this.scopeId)
    }
    
    /// 注册控件到作用域
    /// 
    /// 将控件添加到管理列表，并记录详细信息
    /// 如果控件已被其他作用域管理，则忽略
    /// 
    /// 参数:
    ///   widget - 要注册的控件
    /// 返回:
    ///   this，支持链式调用
    /// 异常:
    ///   ResourceDisposedException - 作用域已关闭
    public func register(widget: QtResource): ScopeManager {
        // 检查作用域是否已关闭
        if (this.closed) {
            throw ResourceDisposedException("ScopeManager already closed")
        }
        
        // 检查控件是否已关闭
        if (widget.isClosed()) {
            return this
        }
        
        // 检查控件是否已被其他作用域管理
        let ptr = widget.getPtr()
        if (ScopeManagerRegistry.isManaged(ptr)) {
            let managerId = ScopeManagerRegistry.getManagerId(ptr)
            if (managerId != this.scopeId) {
                // 控件被其他作用域管理，忽略并记录日志
                if (this.config.logEnabled) {
                    println("Warning: Widget already managed by scope ${managerId}")
                }
                return this
            }
            // 控件已在当前作用域，重复注册，忽略
            return this
        }
        
        // 添加到控件列表
        this.widgets.add(widget)
        
        // 记录控件详细信息
        let info = WidgetInfo(
            ptr,
            getTypeName(widget),
            currentTimeMillis(),
            ReleaseStatus.Pending
        )
        this.widgetInfos[ptr] = info
        
        // 在全局注册表标记
        ScopeManagerRegistry.markManaged(ptr, this.scopeId)
        
        return this
    }
    
    /// 从作用域移除控件（不释放）
    /// 
    /// 将控件从管理列表移除，但不调用close()
    /// 清理全局注册表标记
    /// 
    /// 参数:
    ///   widget - 要移除的控件
    /// 返回:
    ///   true表示成功移除，false表示控件不在作用域中
    public func unregister(widget: QtResource): Bool {
        if (this.closed) {
            return false
        }
        
        let ptr = widget.getPtr()
        let index = findWidgetIndex(widget)
        
        if (index >= 0) {
            this.widgets.remove(at: index)
            this.widgetInfos.remove(ptr)
            ScopeManagerRegistry.unmarkManaged(ptr)
            return true
        }
        return false
    }
    
    /// 手动释放所有控件
    /// 
    /// 提前触发释放，不等作用域关闭
    /// 释放后清空控件列表和注册表
    /// 
    /// 返回:
    ///   ReleaseResult 包含释放统计信息
    public func releaseAll(): ReleaseResult {
        return doRelease()
    }
    
    /// 内部释放实现
    /// 
    /// 遍历所有控件并释放，更新状态信息
    /// 清理所有内部数据结构
    private func doRelease(): ReleaseResult {
        var total: Int32 = 0
        var success: Int32 = 0
        var failed: Int32 = 0
        var skipped: Int32 = 0
        
        for (widget in this.widgets) {
            total += 1
            let ptr = widget.getPtr()
            
            // 获取控件详细信息
            let infoOpt = this.widgetInfos.get(ptr)
            if (let Some(info) <- infoOpt) {
                if (widget.isClosed()) {
                    // 控件已关闭，跳过
                    skipped += 1
                    info.status = ReleaseStatus.Skipped
                } else {
                    // 尝试释放控件
                    try {
                        widget.close()
                        success += 1
                        info.status = ReleaseStatus.Released
                    } catch (ex: Exception) {
                        failed += 1
                        info.status = ReleaseStatus.Failed
                        
                        if (this.config.logEnabled) {
                            println("Failed to release widget: ${info.typeName}, reason: ${ex}")
                        }
                    }
                }
            }
        }
        
        // 清理所有数据结构
        this.widgets.clear()
        this.widgetInfos.clear()
        ScopeManagerRegistry.unregisterScope(this.scopeId)
        
        return ReleaseResult(total, success, failed, skipped, 0)
    }
    
    /// 获取作用域统计信息
    /// 
    /// 返回:
    ///   ScopeStats 包含作用域ID、状态、控件数量等信息
    public func getStats(): ScopeStats {
        let closedTime = if (this.closed) { currentTimeMillis() } else { 0 }
        
        return ScopeStats(
            this.scopeId,
            !this.closed,
            this.widgets.size,
            this.createdTime,
            closedTime
        )
    }
    
    /// 检查作用域是否已关闭
    public func isClosed(): Bool {
        return this.closed
    }
    
    /// 关闭作用域
    /// 
    /// 根据配置决定是否自动释放所有控件
    /// 标记作用域为已关闭状态
    /// 支持重复调用（幂等）
    public func close(): Unit {
        if (this.closed) {
            return
        }
        
        // 根据配置决定是否自动释放
        if (this.config.autoRelease) {
            doRelease()
        }
        
        this.closed = true
    }
    
    /// 获取底层指针
    /// 
    /// 注意：ScopeManager不是Qt对象，返回0
    public func getPtr(): Int64 {
        return 0
    }
    
    /// 检查作用域是否有效
    /// 
    /// 返回: true表示未关闭，false表示已关闭
    public func isValid(): Bool {
        return !this.closed
    }
    
    /// 检查有效性，无效时抛出异常
    /// 
    /// 异常:
    ///   ResourceDisposedException - 作用域已关闭
    public func checkValid(): Unit {
        if (this.closed) {
            throw ResourceDisposedException("ScopeManager already closed")
        }
    }
    
    /// 获取控件的类型名称
    /// 
    /// 注意：当前返回固定值"QtResource"
    /// 未来可通过反射获取实际类型名
    private func getTypeName(_: QtResource): String {
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
    
    /// 生成唯一作用域ID
    /// 
    /// 格式：scope_${时间戳}
    /// 注意：当前时间戳实现返回固定值，生产环境需要真实时间戳
    private static func generateScopeId(): String {
        return "scope_${currentTimeMillis()}"
    }
}

/// 获取当前时间戳（毫秒）
/// 
/// 注意：当前返回固定值0
/// 生产环境需要调用系统时间API
private func currentTimeMillis(): Int64 {
    return 0
}
