package CJQT6.core

// QApplication - 应用程序主类
foreign func qApplicationCreate(): Int64
foreign func qApplicationExec(): Int32
foreign func qApplicationQuit(): Unit
foreign func qApplicationDelete(ptr: Int64): Unit

public class QApplication {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            ptr = qApplicationCreate()
        }
    }
    
    public func exec(): Int32 {
        unsafe {
            qApplicationExec()
        }
    }
    
    public func quit() {
        unsafe {
            qApplicationQuit()
        }
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe {
                qApplicationDelete(ptr)
            }
            ptr = 0
        }
    }
}
