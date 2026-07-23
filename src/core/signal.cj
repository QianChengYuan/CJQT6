package cjqt6.core

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

/// 双 Int32 参数回调（如 rangeChanged(min,max)）
public type Int32Int32Callback = CFunc<(Int32, Int32) -> Unit>

/// Int64 + Int32 参数回调（如 buttonToggled(button, checked)）
public type Int64Int32Callback = CFunc<(Int64, Int32) -> Unit>

/// Bool 参数回调
public type BoolCallback = CFunc<(Bool) -> Unit>

/// 字符串 + Int32 参数回调（如 currentTextChanged(text,index)）
public type CStringInt32Callback = CFunc<(CString, Int32) -> Unit>

/// Int32 + Bool 参数回调
public type Int32BoolCallback = CFunc<(Int32, Bool) -> Unit>

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
// QWidget::destroyed 信号连接
// ============================================================

foreign func qWidgetConnectDestroyed(ptr: Int64, callback: VoidCallback): Unit
foreign func qWidgetDisconnectDestroyed(ptr: Int64): Unit

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
// QSlider::sliderMoved 信号连接
// ============================================================

foreign func qSliderConnectSliderMoved(ptr: Int64, callback: Int32Callback): Unit
foreign func qSliderDisconnectSliderMoved(ptr: Int64): Unit

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
// QComboBox::currentTextChanged 信号连接
// ============================================================

foreign func qComboBoxConnectCurrentTextChanged(ptr: Int64, callback: CStringCallback): Unit
foreign func qComboBoxDisconnectCurrentTextChanged(ptr: Int64): Unit

// ============================================================
// QLineEdit 信号连接
// ============================================================

foreign func qLineEditConnectTextChanged(ptr: Int64, callback: CStringCallback): Unit
foreign func qLineEditDisconnectTextChanged(ptr: Int64): Unit

// ============================================================
// QLineEdit::returnPressed 信号连接
// ============================================================

foreign func qLineEditConnectReturnPressed(ptr: Int64, callback: VoidCallback): Unit
foreign func qLineEditDisconnectReturnPressed(ptr: Int64): Unit

// ============================================================
// QLineEdit::editingFinished 信号连接
// ============================================================

foreign func qLineEditConnectEditingFinished(ptr: Int64, callback: VoidCallback): Unit
foreign func qLineEditDisconnectEditingFinished(ptr: Int64): Unit

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

// 控件类型常量
public const WIDGET_TYPE_BUTTON: String = "button"
public const WIDGET_TYPE_TOOL_BUTTON: String = "toolbutton"
public const WIDGET_TYPE_SLIDER: String = "slider"
public const WIDGET_TYPE_SPINBOX: String = "spinbox"
public const WIDGET_TYPE_DOUBLE_SPINBOX: String = "doublespinbox"
public const WIDGET_TYPE_DIAL: String = "dial"
public const WIDGET_TYPE_CHECKBOX: String = "checkbox"
public const WIDGET_TYPE_RADIOBUTTON: String = "radiobutton"
public const WIDGET_TYPE_COMBOBOX: String = "combobox"
public const WIDGET_TYPE_LINEEDIT: String = "lineedit"
public const WIDGET_TYPE_TIMER: String = "timer"
public const WIDGET_TYPE_ACTION: String = "action"

/// 信号连接句柄，用于管理和断开信号连接
public class SignalConnection {
    private var ptr: Int64 = 0
    private var signalType: String = ""
    private var widgetType: String = ""  // 新增：控件类型，用于正确断开信号
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
    
    /// 创建连接句柄（带控件类型）
    public static func createWithWidgetType(ptr: Int64, signalType: String, widgetType: String): SignalConnection {
        let conn = SignalConnection()
        conn.ptr = ptr
        conn.signalType = signalType
        conn.widgetType = widgetType
        conn.connected = true
        return conn
    }
    
    /// 断开连接
    public func disconnect(): Unit {
        if (connected && ptr != 0) {
            unsafe {
                // 优先根据控件类型断开，确保调用正确的断开函数
                if (widgetType == WIDGET_TYPE_BUTTON) {
                    qButtonDisconnectClicked(ptr)
                } else if (widgetType == WIDGET_TYPE_TOOL_BUTTON) {
                    qToolButtonDisconnectClicked(ptr)
                } else if (widgetType == WIDGET_TYPE_SLIDER) {
                    qSliderDisconnectValueChanged(ptr)
                } else if (widgetType == WIDGET_TYPE_SPINBOX) {
                    qSpinBoxDisconnectValueChanged(ptr)
                } else if (widgetType == WIDGET_TYPE_DOUBLE_SPINBOX) {
                    qDoubleSpinBoxDisconnectValueChanged(ptr)
                } else if (widgetType == WIDGET_TYPE_DIAL) {
                    qDialDisconnectValueChanged(ptr)
                } else if (widgetType == WIDGET_TYPE_CHECKBOX) {
                    qCheckBoxDisconnectStateChanged(ptr)
                } else if (widgetType == WIDGET_TYPE_RADIOBUTTON) {
                    qRadioButtonDisconnectToggled(ptr)
                } else if (widgetType == WIDGET_TYPE_COMBOBOX) {
                    qComboBoxDisconnectCurrentIndexChanged(ptr)
                } else if (widgetType == WIDGET_TYPE_LINEEDIT) {
                    qLineEditDisconnectTextChanged(ptr)
                } else if (widgetType == WIDGET_TYPE_TIMER) {
                    qTimerDisconnectTimeout(ptr)
                } else if (widgetType == WIDGET_TYPE_ACTION) {
                    qActionDisconnectTriggered(ptr)
                } else if (signalType == SIGNAL_CLICKED) {
                    // 兼容旧逻辑：根据信号类型断开
                    qButtonDisconnectClicked(ptr)
                } else if (signalType == SIGNAL_VALUE_CHANGED) {
                    qSliderDisconnectValueChanged(ptr)
                } else if (signalType == SIGNAL_STATE_CHANGED) {
                    qCheckBoxDisconnectStateChanged(ptr)
                } else if (signalType == SIGNAL_TOGGLED) {
                    qRadioButtonDisconnectToggled(ptr)
                } else if (signalType == SIGNAL_CURRENT_CHANGED) {
                    qComboBoxDisconnectCurrentIndexChanged(ptr)
                } else if (signalType == SIGNAL_TEXT_CHANGED) {
                    qLineEditDisconnectTextChanged(ptr)
                } else if (signalType == SIGNAL_TIMEOUT) {
                    qTimerDisconnectTimeout(ptr)
                } else if (signalType == SIGNAL_TRIGGERED) {
                    qActionDisconnectTriggered(ptr)
                } else {
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
