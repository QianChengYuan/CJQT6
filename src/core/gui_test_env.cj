package cjqt6.core

// ============================================================
// GUITestEnvironment - GUI 测试环境
// ============================================================

/// GUI 测试环境管理器，为单元测试提供 QApplication 实例的创建/销毁与事件循环控制（单例）
public class GUITestEnvironment {
    private static var instance: ?GUITestEnvironment = None
    private var qappInstance: ?QApplication = None
    private var refCount: Int32 = 0
    private var ready: Bool = false
    
    private init() {}
    
    public static func getInstance(): GUITestEnvironment {
        if (let Some(env) <- instance) {
            return env
        }
        let env = GUITestEnvironment()
        instance = Some(env)
        return env
    }
    
    public func setupEnvironment(): Unit {
        refCount += 1
        // 桥接层 qApplicationCreate 会在跨线程时自动销毁旧 app 并在当前线程重建，
        // 同线程复用返回同一指针。总是调用以正确处理测试框架跨线程跑测试类的场景，
        // 避免后续测试类持有悬垂的旧 app 指针。
        createAppInstance()
        ready = true
        println("[GUI测试] QApplication实例已创建")
    }
    
    public func teardownEnvironment(): Unit {
        refCount -= 1
        if (refCount > 0) {
            return
        }
        
        if (let Some(_) <- qappInstance) {
            destroyAppInstance()
            println("[GUI测试] QApplication实例已销毁")
        }
        ready = false
    }
    
    private func createAppInstance(): Unit {
        qappInstance = Some(QApplication())
    }
    
    private func destroyAppInstance(): Unit {
        if (let Some(app) <- qappInstance) {
            app.delete()
        }
        qappInstance = None
    }
    
    public func isAppInstanceValid(): Bool {
        match (qappInstance) {
            case Some(_) => return true
            case None => return false
        }
    }
    
    public func isReady(): Bool {
        return ready
    }
    
    /// 运行 Qt 事件循环（阻塞），直到某处调用 QApp.quit()
    /// 供信号槽测试确定性触发定时器/信号使用
    public func exec(): Unit {
        if (let Some(app) <- qappInstance) {
            app.exec()
        }
    }
}
