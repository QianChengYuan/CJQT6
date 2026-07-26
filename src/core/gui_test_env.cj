package cjqt6.core

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
        if (refCount > 1) {
            return
        }
        
        if (!isAppInstanceValid()) {
            createAppInstance()
        }
        
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
