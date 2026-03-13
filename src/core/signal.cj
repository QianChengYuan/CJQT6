package CJQT6.core

// ============================================================
// 信号与槽 - 统一回调机制
// ============================================================

// ============================================================
// 回调函数类型定义
// ============================================================

/// 无参数回调
public type VoidCallback = CFunc<() -> Unit>

/// Int32参数回调
public type Int32Callback = CFunc<(Int32) -> Unit>

/// Int64参数回调  
public type Int64Callback = CFunc<(Int64) -> Unit>

/// Float64参数回调
public type Float64Callback = CFunc<(Float64) -> Unit>

/// 字符串回调
public type CStringCallback = CFunc<(CString) -> Unit>

// ============================================================
// 信号常量
// ============================================================

public const SIGNAL_CLICKED: String = "clicked"
public const SIGNAL_TEXT_CHANGED: String = "textChanged"
public const SIGNAL_VALUE_CHANGED: String = "valueChanged"
public const SIGNAL_STATE_CHANGED: String = "stateChanged"
public const SIGNAL_CURRENT_CHANGED: String = "currentChanged"
public const SIGNAL_TIMEOUT: String = "timeout"
public const SIGNAL_CLOSE: String = "close"
public const SIGNAL_TRIGGERED: String = "triggered"
public const SIGNAL_TOGGLED: String = "toggled"

// ============================================================
// QPushButton 信号连接
// ============================================================

foreign func qButtonConnectClicked(ptr: Int64, callback: VoidCallback): Unit
foreign func qButtonDisconnectClicked(ptr: Int64): Unit

// ============================================================
// QToolButton 信号连接
// ============================================================

foreign func qToolButtonConnectClicked(ptr: Int64, callback: VoidCallback): Unit
foreign func qToolButtonDisconnectClicked(ptr: Int64): Unit

// ============================================================
// QSlider 信号连接
// ============================================================

foreign func qSliderConnectValueChanged(ptr: Int64, callback: Int32Callback): Unit
foreign func qSliderDisconnectValueChanged(ptr: Int64): Unit

// ============================================================
// QSpinBox 信号连接
// ============================================================

foreign func qSpinBoxConnectValueChanged(ptr: Int64, callback: Int32Callback): Unit
foreign func qSpinBoxDisconnectValueChanged(ptr: Int64): Unit

// ============================================================
// QDoubleSpinBox 信号连接
// ============================================================

foreign func qDoubleSpinBoxConnectValueChanged(ptr: Int64, callback: Float64Callback): Unit
foreign func qDoubleSpinBoxDisconnectValueChanged(ptr: Int64): Unit

// ============================================================
// QDial 信号连接
// ============================================================

foreign func qDialConnectValueChanged(ptr: Int64, callback: Int32Callback): Unit
foreign func qDialDisconnectValueChanged(ptr: Int64): Unit

// ============================================================
// QCheckBox 信号连接
// ============================================================

foreign func qCheckBoxConnectStateChanged(ptr: Int64, callback: Int32Callback): Unit
foreign func qCheckBoxDisconnectStateChanged(ptr: Int64): Unit

// ============================================================
// QRadioButton 信号连接
// ============================================================

foreign func qRadioButtonConnectToggled(ptr: Int64, callback: Int32Callback): Unit
foreign func qRadioButtonDisconnectToggled(ptr: Int64): Unit

// ============================================================
// QComboBox 信号连接
// ============================================================

foreign func qComboBoxConnectCurrentIndexChanged(ptr: Int64, callback: Int32Callback): Unit
foreign func qComboBoxDisconnectCurrentIndexChanged(ptr: Int64): Unit

// ============================================================
// QLineEdit 信号连接
// ============================================================

foreign func qLineEditConnectTextChanged(ptr: Int64, callback: CStringCallback): Unit
foreign func qLineEditDisconnectTextChanged(ptr: Int64): Unit

// ============================================================
// QTimer 信号连接
// ============================================================

foreign func qTimerConnectTimeout(ptr: Int64, callback: VoidCallback): Unit
foreign func qTimerDisconnectTimeout(ptr: Int64): Unit

// ============================================================
// QAction 信号连接
// ============================================================

foreign func qActionConnectTriggered(ptr: Int64, callback: VoidCallback): Unit
foreign func qActionDisconnectTriggered(ptr: Int64): Unit

// ============================================================
// 清理函数
// ============================================================

foreign func qSignalCleanup(ptr: Int64): Unit

// ============================================================
// SignalConnection - 信号连接句柄
// ============================================================

/// 信号连接句柄，用于管理和断开信号连接
public class SignalConnection {
    private var ptr: Int64 = 0
    private var signalType: String = ""
    private var connected: Bool = false
    
    private init() {}
    
    /// 创建连接句柄
    public static func create(ptr: Int64, signalType: String): SignalConnection {
        let conn = SignalConnection()
        conn.ptr = ptr
        conn.signalType = signalType
        conn.connected = true
        return conn
    }
    
    /// 断开连接
    public func disconnect(): Unit {
        if (connected && ptr != 0) {
            unsafe {
                match (signalType) {
                    case SIGNAL_CLICKED =>
                        qButtonDisconnectClicked(ptr)
                    case SIGNAL_VALUE_CHANGED =>
                        qSliderDisconnectValueChanged(ptr)
                        qSpinBoxDisconnectValueChanged(ptr)
                    case SIGNAL_STATE_CHANGED =>
                        qCheckBoxDisconnectStateChanged(ptr)
                    case SIGNAL_TOGGLED =>
                        qRadioButtonDisconnectToggled(ptr)
                    case SIGNAL_CURRENT_CHANGED =>
                        qComboBoxDisconnectCurrentIndexChanged(ptr)
                    case SIGNAL_TEXT_CHANGED =>
                        qLineEditDisconnectTextChanged(ptr)
                    case SIGNAL_TIMEOUT =>
                        qTimerDisconnectTimeout(ptr)
                    case SIGNAL_TRIGGERED =>
                        qActionDisconnectTriggered(ptr)
                    case _ =>
                        qSignalCleanup(ptr)
                }
            }
            connected = false
        }
    }
    
    /// 是否已连接
    public func isConnected(): Bool {
        return connected
    }
    
    /// 获取对象指针
    public func getPtr(): Int64 {
        return ptr
    }
    
    /// 获取信号类型
    public func getSignalType(): String {
        return signalType
    }
}

// ============================================================
// 注意：CFunc 不能捕获外部变量
// 使用示例：
// button.setOnClick({ => println("clicked!") })
// slider.setOnValueChanged({ v => println("value: ${v}") })
// ============================================================
