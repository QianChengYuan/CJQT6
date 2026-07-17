package cjqt6.resource

/// 释放状态枚举
/// 用于标识控件的释放状态
public enum ReleaseStatus {
    | Pending    // 待释放
    | Released   // 已释放
    | Failed     // 释放失败
    | Skipped    // 已跳过（控件已关闭）
}

/// 控件信息类
/// 记录注册到作用域的控件详细信息
public class WidgetInfo {
    /// 控件的底层指针
    public let ptr: Int64
    
    /// 控件的类型名称
    public let typeName: String
    
    /// 注册时间（毫秒时间戳）
    public let registerTime: Int64
    
    /// 当前释放状态
    public var status: ReleaseStatus
    
    public init(ptr: Int64, typeName: String, registerTime: Int64, status: ReleaseStatus) {
        this.ptr = ptr
        this.typeName = typeName
        this.registerTime = registerTime
        this.status = status
    }
}

/// 作用域管理器配置类
/// 用于配置ScopeManager的行为
public class ScopeConfig {
    /// 关闭作用域时是否自动释放所有控件
    public let autoRelease: Bool
    
    /// 是否启用日志输出
    public let logEnabled: Bool
    
    /// 释放失败时是否抛出异常
    public let throwOnFailure: Bool
    
    /// 最大重试次数
    public let maxRetries: Int32
    
    /// 单个控件释放超时时间（毫秒）
    public let releaseTimeout: Int64
    
    /// 默认构造函数
    /// autoRelease=true, logEnabled=false, throwOnFailure=false, maxRetries=0, releaseTimeout=1000
    public init() {
        this.autoRelease = true
        this.logEnabled = false
        this.throwOnFailure = false
        this.maxRetries = 0
        this.releaseTimeout = 1000
    }
    
    /// 自定义配置构造函数
    public init(autoRelease: Bool, logEnabled: Bool, throwOnFailure: Bool, maxRetries: Int32, releaseTimeout: Int64) {
        this.autoRelease = autoRelease
        this.logEnabled = logEnabled
        this.throwOnFailure = throwOnFailure
        this.maxRetries = maxRetries
        this.releaseTimeout = releaseTimeout
    }
    
    /// 获取默认配置
    public static func defaultConfig(): ScopeConfig {
        return ScopeConfig()
    }
}

/// 作用域统计信息类
/// 用于获取作用域的当前状态
public class ScopeStats {
    /// 作用域唯一标识
    public let scopeId: String
    
    /// 作用域是否活跃（未关闭）
    public let isActive: Bool
    
    /// 管理的控件数量
    public let widgetCount: Int64
    
    /// 作用域创建时间（毫秒时间戳）
    public let createdTime: Int64
    
    /// 作用域关闭时间（毫秒时间戳）
    public let closedTime: Int64
    
    public init(scopeId: String, isActive: Bool, widgetCount: Int64, createdTime: Int64, closedTime: Int64) {
        this.scopeId = scopeId
        this.isActive = isActive
        this.widgetCount = widgetCount
        this.createdTime = createdTime
        this.closedTime = closedTime
    }
    
    /// 转换为字符串表示
    public func toString(): String {
        return "ScopeStats(id=${scopeId}, active=${isActive}, widgets=${widgetCount})"
    }
}
