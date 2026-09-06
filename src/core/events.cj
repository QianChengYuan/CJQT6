package cjqt6.core

// ============================================================
// 事件处理 FFI声明
// ============================================================

// EventWidget 创建和管理
foreign func qEventWidgetCreate(): Int64
foreign func qEventWidgetGetPtr(id: Int64): Int64
foreign func qEventWidgetDelete(ptr: Int64): Unit

// 鼠标事件回调 (button/buttons, x, y)
foreign func qEventWidgetSetOnMousePress(ptr: Int64, callback: CFunc<(Int32, Int32, Int32) -> Unit>): Unit
foreign func qEventWidgetSetOnMouseMove(ptr: Int64, callback: CFunc<(Int32, Int32, Int32) -> Unit>): Unit
foreign func qEventWidgetSetOnMouseRelease(ptr: Int64, callback: CFunc<(Int32, Int32, Int32) -> Unit>): Unit

// 键盘事件回调 (key, modifiers, unicode)
foreign func qEventWidgetSetOnKeyPress(ptr: Int64, callback: CFunc<(Int32, Int32, Int32) -> Unit>): Unit
foreign func qEventWidgetSetOnKeyRelease(ptr: Int64, callback: CFunc<(Int32, Int32, Int32) -> Unit>): Unit

// 绘制事件回调 (painterPtr)
foreign func qEventWidgetSetOnPaint(ptr: Int64, callback: CFunc<(Int64) -> Unit>): Unit

// 回调清理函数
foreign func qEventWidgetClearPaintCallback(ptr: Int64): Unit
foreign func qEventWidgetClearMousePressCallback(ptr: Int64): Unit
foreign func qEventWidgetClearMouseMoveCallback(ptr: Int64): Unit
foreign func qEventWidgetClearMouseReleaseCallback(ptr: Int64): Unit
foreign func qEventWidgetClearKeyPressCallback(ptr: Int64): Unit
foreign func qEventWidgetClearKeyReleaseCallback(ptr: Int64): Unit
foreign func qEventWidgetClearAllCallbacks(ptr: Int64): Unit
foreign func qEventWidgetSetFocus(ptr: Int64): Unit

// 鼠标按钮常量
foreign func qMouseButtonLeft(): Int32
foreign func qMouseButtonRight(): Int32
foreign func qMouseButtonMiddle(): Int32

// 键盘按键常量
foreign func qKeyEscape(): Int32
foreign func qKeyTab(): Int32
foreign func qKeyBackspace(): Int32
foreign func qKeyReturn(): Int32
foreign func qKeyEnter(): Int32
foreign func qKeyInsert(): Int32
foreign func qKeyDelete(): Int32
foreign func qKeyPause(): Int32
foreign func qKeyPrint(): Int32
foreign func qKeyHome(): Int32
foreign func qKeyEnd(): Int32
foreign func qKeyLeft(): Int32
foreign func qKeyUp(): Int32
foreign func qKeyRight(): Int32
foreign func qKeyDown(): Int32
foreign func qKeyPageUp(): Int32
foreign func qKeyPageDown(): Int32
foreign func qKeyShift(): Int32
foreign func qKeyControl(): Int32
foreign func qKeyMeta(): Int32
foreign func qKeyAlt(): Int32
foreign func qKeyCapsLock(): Int32
foreign func qKeyNumLock(): Int32
foreign func qKeyScrollLock(): Int32
foreign func qKeyF1(): Int32
foreign func qKeyF2(): Int32
foreign func qKeyF3(): Int32
foreign func qKeyF4(): Int32
foreign func qKeyF5(): Int32
foreign func qKeyF6(): Int32
foreign func qKeyF7(): Int32
foreign func qKeyF8(): Int32
foreign func qKeyF9(): Int32
foreign func qKeyF10(): Int32
foreign func qKeyF11(): Int32
foreign func qKeyF12(): Int32
foreign func qKeySpace(): Int32

// 修饰键常量
foreign func qModifierShift(): Int32
foreign func qModifierControl(): Int32
foreign func qModifierAlt(): Int32
foreign func qModifierMeta(): Int32

// ============================================================
// 鼠标按钮常量类
// ============================================================
public class MouseButton {
    public static func left(): Int32 {
        unsafe { qMouseButtonLeft() }
    }
    
    public static func right(): Int32 {
        unsafe { qMouseButtonRight() }
    }
    
    public static func middle(): Int32 {
        unsafe { qMouseButtonMiddle() }
    }
}

// ============================================================
// 键盘按键常量类
// ============================================================
public class Key {
    public static func escape(): Int32 { unsafe { qKeyEscape() } }
    public static func tab(): Int32 { unsafe { qKeyTab() } }
    public static func backspace(): Int32 { unsafe { qKeyBackspace() } }
    public static func enter(): Int32 { unsafe { qKeyReturn() } }
    public static func returnKey(): Int32 { unsafe { qKeyEnter() } }
    public static func insert(): Int32 { unsafe { qKeyInsert() } }
    public static func delete(): Int32 { unsafe { qKeyDelete() } }
    public static func pause(): Int32 { unsafe { qKeyPause() } }
    public static func print(): Int32 { unsafe { qKeyPrint() } }
    public static func home(): Int32 { unsafe { qKeyHome() } }
    public static func end(): Int32 { unsafe { qKeyEnd() } }
    public static func left(): Int32 { unsafe { qKeyLeft() } }
    public static func up(): Int32 { unsafe { qKeyUp() } }
    public static func right(): Int32 { unsafe { qKeyRight() } }
    public static func down(): Int32 { unsafe { qKeyDown() } }
    public static func pageUp(): Int32 { unsafe { qKeyPageUp() } }
    public static func pageDown(): Int32 { unsafe { qKeyPageDown() } }
    public static func shift(): Int32 { unsafe { qKeyShift() } }
    public static func control(): Int32 { unsafe { qKeyControl() } }
    public static func meta(): Int32 { unsafe { qKeyMeta() } }
    public static func alt(): Int32 { unsafe { qKeyAlt() } }
    public static func capsLock(): Int32 { unsafe { qKeyCapsLock() } }
    public static func numLock(): Int32 { unsafe { qKeyNumLock() } }
    public static func scrollLock(): Int32 { unsafe { qKeyScrollLock() } }
    public static func space(): Int32 { unsafe { qKeySpace() } }
    
    // F键
    public static func f1(): Int32 { unsafe { qKeyF1() } }
    public static func f2(): Int32 { unsafe { qKeyF2() } }
    public static func f3(): Int32 { unsafe { qKeyF3() } }
    public static func f4(): Int32 { unsafe { qKeyF4() } }
    public static func f5(): Int32 { unsafe { qKeyF5() } }
    public static func f6(): Int32 { unsafe { qKeyF6() } }
    public static func f7(): Int32 { unsafe { qKeyF7() } }
    public static func f8(): Int32 { unsafe { qKeyF8() } }
    public static func f9(): Int32 { unsafe { qKeyF9() } }
    public static func f10(): Int32 { unsafe { qKeyF10() } }
    public static func f11(): Int32 { unsafe { qKeyF11() } }
    public static func f12(): Int32 { unsafe { qKeyF12() } }
    
    // 字母键 (ASCII码)
    public static func a(): Int32 { 65 }
    public static func b(): Int32 { 66 }
    public static func c(): Int32 { 67 }
    public static func d(): Int32 { 68 }
    public static func e(): Int32 { 69 }
    public static func f(): Int32 { 70 }
    public static func g(): Int32 { 71 }
    public static func h(): Int32 { 72 }
    public static func i(): Int32 { 73 }
    public static func j(): Int32 { 74 }
    public static func k(): Int32 { 75 }
    public static func l(): Int32 { 76 }
    public static func m(): Int32 { 77 }
    public static func n(): Int32 { 78 }
    public static func o(): Int32 { 79 }
    public static func p(): Int32 { 80 }
    public static func q(): Int32 { 81 }
    public static func r(): Int32 { 82 }
    public static func s(): Int32 { 83 }
    public static func t(): Int32 { 84 }
    public static func u(): Int32 { 85 }
    public static func v(): Int32 { 86 }
    public static func w(): Int32 { 87 }
    public static func x(): Int32 { 88 }
    public static func y(): Int32 { 89 }
    public static func z(): Int32 { 90 }
    
    // 数字键
    public static func num0(): Int32 { 48 }
    public static func num1(): Int32 { 49 }
    public static func num2(): Int32 { 50 }
    public static func num3(): Int32 { 51 }
    public static func num4(): Int32 { 52 }
    public static func num5(): Int32 { 53 }
    public static func num6(): Int32 { 54 }
    public static func num7(): Int32 { 55 }
    public static func num8(): Int32 { 56 }
    public static func num9(): Int32 { 57 }
}

// ============================================================
// 修饰键常量类
// ============================================================
public class Modifier {
    public static func shift(): Int32 { unsafe { qModifierShift() } }
    public static func control(): Int32 { unsafe { qModifierControl() } }
    public static func alt(): Int32 { unsafe { qModifierAlt() } }
    public static func meta(): Int32 { unsafe { qModifierMeta() } }
    
    // 检查是否包含Shift
    public static func hasShift(modifiers: Int32): Bool {
        (modifiers & shift()) != 0
    }
    
    // 检查是否包含Ctrl
    public static func hasControl(modifiers: Int32): Bool {
        (modifiers & control()) != 0
    }
    
    // 检查是否包含Alt
    public static func hasAlt(modifiers: Int32): Bool {
        (modifiers & alt()) != 0
    }
    
    // 检查是否包含Meta
    public static func hasMeta(modifiers: Int32): Bool {
        (modifiers & meta()) != 0
    }
}

// ============================================================
// QEventWidget - 支持事件的Widget
// ============================================================
public class QEventWidget {
    private let id: Int64
    private var ptr: Int64 = 0
    
    public init() {
        unsafe {
            id = qEventWidgetCreate()
            ptr = qEventWidgetGetPtr(id)
        }
    }
    
    public func getPtr(): Int64 {
        ptr
    }
    
    public func getId(): Int64 {
        id
    }
    
    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qEventWidgetClearAllCallbacks(ptr)
                qEventWidgetDelete(ptr)
            }
            ptr = 0
        }
    }
    
    // ========== 继承自QWidget的方法 ==========
    
    public func show(): Unit {
        unsafe {
            qWidgetShow(ptr)
        }
    }
    
    public func hide(): Unit {
        unsafe {
            qWidgetHide(ptr)
        }
    }
    
    public func setTitle(title: String): Unit {
        unsafe {
            var cstr = LibC.mallocCString(title)
            qWidgetSetTitle(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func resize(width: Int32, height: Int32): Unit {
        unsafe {
            qWidgetResize(ptr, width, height)
        }
    }
    
    public func setGeometry(x: Int32, y: Int32, width: Int32, height: Int32): Unit {
        unsafe {
            qWidgetSetGeometry(ptr, x, y, width, height)
        }
    }
    
    public func setLayout(layoutPtr: Int64): Unit {
        unsafe {
            qWidgetSetLayout(ptr, layoutPtr)
        }
    }
    
    // ========== 鼠标事件 ==========
    
    public func setOnMousePress(callback: CFunc<(Int32, Int32, Int32) -> Unit>): Unit {
        unsafe {
            qEventWidgetSetOnMousePress(ptr, callback)
        }
    }
    
    public func setOnMouseMove(callback: CFunc<(Int32, Int32, Int32) -> Unit>): Unit {
        unsafe {
            qEventWidgetSetOnMouseMove(ptr, callback)
        }
    }
    
    public func setOnMouseRelease(callback: CFunc<(Int32, Int32, Int32) -> Unit>): Unit {
        unsafe {
            qEventWidgetSetOnMouseRelease(ptr, callback)
        }
    }
    
    // ========== 键盘事件 ==========
    
    public func setOnKeyPress(callback: CFunc<(Int32, Int32, Int32) -> Unit>): Unit {
        unsafe {
            qEventWidgetSetOnKeyPress(ptr, callback)
        }
    }
    
    public func setOnKeyRelease(callback: CFunc<(Int32, Int32, Int32) -> Unit>): Unit {
        unsafe {
            qEventWidgetSetOnKeyRelease(ptr, callback)
        }
    }
    
    // ========== 绘制事件 ==========
    
    public func setOnPaint(callback: CFunc<(Int64) -> Unit>): Unit {
        unsafe {
            qEventWidgetSetOnPaint(ptr, callback)
        }
    }
    
    // ========== 清除回调方法 ==========

    public func clearPaintCallback(): Unit {
        unsafe { qEventWidgetClearPaintCallback(ptr) }
    }

    public func clearMousePressCallback(): Unit {
        unsafe { qEventWidgetClearMousePressCallback(ptr) }
    }

    public func clearMouseMoveCallback(): Unit {
        unsafe { qEventWidgetClearMouseMoveCallback(ptr) }
    }

    public func clearMouseReleaseCallback(): Unit {
        unsafe { qEventWidgetClearMouseReleaseCallback(ptr) }
    }

    public func clearKeyPressCallback(): Unit {
        unsafe { qEventWidgetClearKeyPressCallback(ptr) }
    }

    public func clearKeyReleaseCallback(): Unit {
        unsafe { qEventWidgetClearKeyReleaseCallback(ptr) }
    }

    public func clearAllCallbacks(): Unit {
        unsafe { qEventWidgetClearAllCallbacks(ptr) }
    }
    
    // ========== 更新重绘 ==========
    
    public func update(): Unit {
        unsafe {
            qWidgetUpdate(ptr)
        }
    }

    // ========== 焦点 ==========
    
    public func setFocus(): Unit {
        unsafe {
            qEventWidgetSetFocus(ptr)
        }
    }
}
