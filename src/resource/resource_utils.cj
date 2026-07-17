package cjqt6.resource

import cjqt6.core.QtResource

// ============================================================
// 释放结果类
// ============================================================

/// 资源释放结果类
/// 记录批量释放操作的统计信息
public class ReleaseResult {
    /// 总控件数量
    public let totalCount: Int32
    
    /// 成功释放的数量
    public let successCount: Int32
    
    /// 释放失败的数量
    public let failedCount: Int32
    
    /// 跳过的数量（已关闭的控件）
    public let skippedCount: Int32
    
    /// 释放耗时（毫秒）
    public let elapsedTime: Int64
    
    /// 构造函数
    public init(totalCount: Int32, successCount: Int32, failedCount: Int32, skippedCount: Int32, elapsedTime: Int64) {
        this.totalCount = totalCount
        this.successCount = successCount
        this.failedCount = failedCount
        this.skippedCount = skippedCount
        this.elapsedTime = elapsedTime
    }
    
    /// 检查是否全部释放成功
    /// 返回: true表示没有失败，false表示有失败
    public func isAllSuccess(): Bool {
        return failedCount == 0
    }
    
    /// 检查是否有失败
    /// 返回: true表示有失败，false表示全部成功
    public func hasFailure(): Bool {
        return failedCount > 0
    }
    
    /// 计算成功率（百分比）
    /// 返回: 成功释放的比例（0-100）
    public func successRate(): Int32 {
        if (totalCount == 0) {
            return 100
        }
        return (successCount * 100) / totalCount
    }
    
    /// 转换为字符串表示
    public func toString(): String {
        return "ReleaseResult(total=${totalCount}, success=${successCount}, failed=${failedCount}, skipped=${skippedCount}, rate=${successRate()}%)"
    }
}

// ============================================================
// 资源释放工具类
// ============================================================

/// 资源释放工具类
/// 提供静态方法用于批量释放Qt控件资源
/// 
/// 使用场景：
/// - 需要一次性释放多个控件
/// - 处理可能为null的Option类型控件
/// - 快速释放固定数量的控件
public class ResourceUtils {
    
    /// 批量释放控件（数组版本）
    /// 
    /// 遍历数组中的所有控件并尝试释放
    /// 已关闭的控件会被跳过
    /// 释放失败的控件会捕获异常并计数
    /// 
    /// 参数:
    ///   widgets - 要释放的控件数组
    /// 返回:
    ///   ReleaseResult 包含释放统计信息
    public static func releaseAll(widgets: Array<QtResource>): ReleaseResult {
        var total: Int32 = 0
        var success: Int32 = 0
        var failed: Int32 = 0
        var skipped: Int32 = 0
        
        for (i in 0..widgets.size) {
            let widget = widgets[i]
            total += 1
            
            // 检查控件是否已关闭
            if (widget.isClosed()) {
                skipped += 1
            } else {
                // 尝试释放控件
                try {
                    widget.close()
                    success += 1
                } catch (ex: Exception) {
                    failed += 1
                    // 注意：失败时继续处理其他控件
                }
            }
        }
        
        return ReleaseResult(total, success, failed, skipped, 0)
    }
    
    /// 安全释放控件（处理Option类型）
    /// 
    /// 处理可能为None的控件数组
    /// None值会被跳过并计入skipped
    /// 
    /// 参数:
    ///   widgets - Option类型的控件数组
    /// 返回:
    ///   ReleaseResult 包含释放统计信息
    public static func releaseSafe(widgets: Array<?QtResource>): ReleaseResult {
        var total: Int32 = 0
        var success: Int32 = 0
        var failed: Int32 = 0
        var skipped: Int32 = 0
        
        for (i in 0..widgets.size) {
            let widgetOpt = widgets[i]
            total += 1
            
            // 解构Option类型
            if (let Some(widget) <- widgetOpt) {
                if (widget.isClosed()) {
                    skipped += 1
                } else {
                    try {
                        widget.close()
                        success += 1
                    } catch (ex: Exception) {
                        failed += 1
                    }
                }
            } else {
                // None值跳过
                skipped += 1
            }
        }
        
        return ReleaseResult(total, success, failed, skipped, 0)
    }
    
    /// 释放两个控件
    /// 快捷方法，避免创建数组的开销
    public static func releaseTwo(w1: QtResource, w2: QtResource): ReleaseResult {
        return releaseAll([w1, w2])
    }
    
    /// 释放三个控件
    /// 快捷方法，避免创建数组的开销
    public static func releaseThree(w1: QtResource, w2: QtResource, w3: QtResource): ReleaseResult {
        return releaseAll([w1, w2, w3])
    }
    
    /// 释放四个控件
    /// 快捷方法，避免创建数组的开销
    public static func releaseFour(w1: QtResource, w2: QtResource, w3: QtResource, w4: QtResource): ReleaseResult {
        return releaseAll([w1, w2, w3, w4])
    }
}
