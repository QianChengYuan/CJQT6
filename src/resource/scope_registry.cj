package cjqt6.resource

import std.collection.{HashMap, ArrayList}

// ============================================================
// 作用域管理器全局注册表
// ============================================================

/// 作用域管理器全局注册表
/// 
/// 用于追踪所有控件被哪个作用域管理
/// 防止同一控件被多个作用域重复管理
/// 
/// 注意事项：
/// - 这是一个全局静态类，所有数据在进程级别共享
/// - 线程不安全，多线程环境需要外部同步
/// - 在作用域关闭时必须调用unregisterScope清理
class ScopeManagerRegistry {
    /// 控件指针 -> 作用域ID的映射
    /// 用于快速查找控件被哪个作用域管理
    private static var managedWidgets: HashMap<Int64, String> = HashMap<Int64, String>()
    
    /// 所有活跃作用域ID列表
    /// 用于追踪当前活跃的作用域
    private static var scopeIds: ArrayList<String> = ArrayList<String>()
    
    /// 注册作用域
    /// 
    /// 在创建ScopeManager时调用
    /// 将作用域ID添加到活跃列表
    /// 
    /// 参数:
    ///   scopeId - 作用域唯一标识
    public static func registerScope(scopeId: String): Unit {
        scopeIds.add(scopeId)
    }
    
    /// 注销作用域
    /// 
    /// 在ScopeManager关闭时调用
    /// 清理该作用域管理的所有控件标记
    /// 从活跃列表中移除作用域ID
    /// 
    /// 参数:
    ///   scopeId - 要注销的作用域ID
    public static func unregisterScope(scopeId: String): Unit {
        // 收集要移除的控件指针
        let keysToRemove = ArrayList<Int64>()
        for ((ptr, sid) in managedWidgets) {
            if (sid == scopeId) {
                keysToRemove.add(ptr)
            }
        }
        
        // 批量移除控件标记
        for (ptr in keysToRemove) {
            managedWidgets.remove(ptr)
        }
        
        // 从作用域列表中移除
        for (i in 0..scopeIds.size) {
            if (scopeIds[i] == scopeId) {
                scopeIds.remove(at: i)
                break
            }
        }
    }
    
    /// 标记控件为已管理
    /// 
    /// 将控件指针映射到作用域ID
    /// 
    /// 参数:
    ///   ptr - 控件的底层指针
    ///   scopeId - 管理该控件的作用域ID
    public static func markManaged(ptr: Int64, scopeId: String): Unit {
        managedWidgets[ptr] = scopeId
    }
    
    /// 取消控件的管理标记
    /// 
    /// 从注册表中移除控件
    /// 
    /// 参数:
    ///   ptr - 要取消标记的控件指针
    public static func unmarkManaged(ptr: Int64): Unit {
        managedWidgets.remove(ptr)
    }
    
    /// 检查控件是否已被管理
    /// 
    /// 参数:
    ///   ptr - 控件指针
    /// 返回:
    ///   true表示已被管理，false表示未被管理
    public static func isManaged(ptr: Int64): Bool {
        return managedWidgets.contains(ptr)
    }
    
    /// 获取管理该控件的作用域ID
    /// 
    /// 参数:
    ///   ptr - 控件指针
    /// 返回:
    ///   作用域ID，如果未被管理则返回空字符串
    public static func getManagerId(ptr: Int64): String {
        if (let Some(sid) <- managedWidgets.get(ptr)) {
            return sid
        }
        return ""
    }
    
    /// 清空所有注册信息
    /// 
    /// 用于测试环境的清理
    /// 危险操作，生产环境慎用
    public static func clear(): Unit {
        managedWidgets.clear()
        scopeIds.clear()
    }
    
    /// 获取活跃作用域数量
    /// 
    /// 返回:
    ///   当前活跃的作用域数量
    public static func activeScopeCount(): Int64 {
        return scopeIds.size
    }
    
    /// 获取已管理控件数量
    /// 
    /// 返回:
    ///   当前被管理的控件总数
    public static func managedWidgetCount(): Int64 {
        return managedWidgets.size
    }
}
