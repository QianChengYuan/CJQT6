package CJQT6.core

// ============================================================
// 资源管理模块 - RAII 支持和错误处理
// ============================================================

// ============================================================
// 自定义异常
// ============================================================

/// Qt组件操作异常
public open class QtException <: Exception {
    public init(message: String) {
        super(message)
    }
}

/// 资源已释放异常
public open class ResourceDisposedException <: QtException {
    public init(message: String) {
        super(message)
    }
}

/// 空指针异常
public open class NullPointerException <: QtException {
    public init(message: String) {
        super(message)
    }
}

/// 创建失败异常
public open class CreateFailedException <: QtException {
    public init(message: String) {
        super(message)
    }
}

// ============================================================
// QtResource 接口 - 资源管理接口
// ============================================================

/// Qt资源接口，支持 try-with-resources 模式
public interface QtResource {
    /// 资源是否已关闭
    func isClosed(): Bool
    
    /// 关闭资源，释放底层Qt对象
    func close(): Unit
    
    /// 获取原生指针
    func getPtr(): Int64
    
    /// 检查对象有效性
    func isValid(): Bool
    
    /// 检查有效性，无效时抛出异常
    func checkValid(): Unit
}

// ============================================================
// 辅助函数
// ============================================================

/// 安全执行操作，捕获异常并返回 Option
public func safeExecute<T>(action: () -> T): ?T {
    try {
        return Some(action())
    } catch (e: Exception) {
        println("Warning: ${e}")
        return None<T>
    }
}

/// 安全执行无返回值操作
public func safeRun(action: () -> Unit): Bool {
    try {
        action()
        return true
    } catch (e: Exception) {
        println("Warning: ${e}")
        return false
    }
}