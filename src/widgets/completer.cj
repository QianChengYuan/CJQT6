package cjqt6.widgets

import cjqt6.core.*

// QCompleter - 自动补全
foreign func qCompleterCreate(): Int64
foreign func qCompleterCreateWithStrings(items: CString): Int64
foreign func qCompleterSetModel(ptr: Int64, items: CString): Unit
foreign func qCompleterSetCaseSensitivity(ptr: Int64, caseSensitive: Bool): Unit
foreign func qCompleterSetFilterMode(ptr: Int64, mode: Int32): Unit
foreign func qCompleterSetCompletionMode(ptr: Int64, mode: Int32): Unit
foreign func qCompleterSetMaxVisibleItems(ptr: Int64, maxItems: Int32): Unit
foreign func qCompleterMaxVisibleItems(ptr: Int64): Int32
foreign func qCompleterSetCompletionPrefix(ptr: Int64, prefix: CString): Unit
foreign func qCompleterCompletionPrefix(ptr: Int64): CString
foreign func qCompleterCompletionCount(ptr: Int64): Int32
foreign func qCompleterComplete(ptr: Int64): Unit
foreign func qCompleterDelete(ptr: Int64): Unit

/// 补全模式常量
public class CompletionMode {
    /// 弹出补全列表
    public static let Popup: Int32 = 0
    /// 内联补全（直接补全到文本中）
    public static let Inline: Int32 = 1
    /// 弹出并内联
    public static let UnfilteredPopup: Int32 = 2
}

/// 过滤模式常量
public class FilterMode {
    /// 前缀匹配
    public static let StartsWith: Int32 = 0
    /// 包含匹配
    public static let Contains: Int32 = 1
    /// 模糊匹配
    public static let Fuzzy: Int32 = 2
}

/// 自动补全器
/// 用于为 QLineEdit 等输入控件提供自动补全功能
///
/// 使用示例：
/// let completer = QCompleter(["苹果", "香蕉", "樱桃"])
/// completer.setCaseSensitivity(false)  // 忽略大小写
/// lineEdit.setCompleter(completer)     // 需要 QLineEdit 有 setCompleter 方法
public class QCompleter {
    private var ptr: Int64 = 0

    /// 创建空补全器
    public init() {
        unsafe {
            ptr = qCompleterCreate()
        }
    }

    /// 从字符串列表创建补全器
    /// items: 用换行符分隔的候选词列表
    public init(items: String) {
        unsafe {
            let cstr = LibC.mallocCString(items)
            ptr = qCompleterCreateWithStrings(cstr)
            LibC.free(cstr)
        }
    }

    /// 从字符串数组创建补全器
    public static func fromArray(items: Array<String>): QCompleter {
        let combined = StringBuilder()
        for (i in 0..items.size) {
            if (i > 0) { combined.append("\n") }
            combined.append(items[i])
        }
        return QCompleter(combined.toString())
    }

    /// 更新候选词列表
    public func setModel(items: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(items)
            qCompleterSetModel(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 设置是否区分大小写
    public func setCaseSensitivity(caseSensitive: Bool): Unit {
        unsafe {
            qCompleterSetCaseSensitivity(ptr, caseSensitive)
        }
    }

    /// 设置过滤模式
    public func setFilterMode(mode: Int32): Unit {
        unsafe {
            qCompleterSetFilterMode(ptr, mode)
        }
    }

    /// 设置补全模式
    public func setCompletionMode(mode: Int32): Unit {
        unsafe {
            qCompleterSetCompletionMode(ptr, mode)
        }
    }

    /// 设置最大可见项数
    public func setMaxVisibleItems(maxItems: Int32): Unit {
        unsafe {
            qCompleterSetMaxVisibleItems(ptr, maxItems)
        }
    }

    /// 获取最大可见项数
    public func maxVisibleItems(): Int32 {
        unsafe {
            return qCompleterMaxVisibleItems(ptr)
        }
    }

    /// 设置补全前缀
    public func setCompletionPrefix(prefix: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(prefix)
            qCompleterSetCompletionPrefix(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 获取补全前缀
    public func completionPrefix(): String {
        unsafe {
            let cstr = qCompleterCompletionPrefix(ptr)
            return cstr.toString()
        }
    }

    /// 获取补全候选数量
    public func completionCount(): Int32 {
        unsafe {
            return qCompleterCompletionCount(ptr)
        }
    }

    /// 弹出补全列表
    public func complete(): Unit {
        unsafe {
            qCompleterComplete(ptr)
        }
    }

    /// 获取原生指针
    public func getPtr(): Int64 {
        return ptr
    }

    /// 删除补全器
    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qCompleterDelete(ptr)
            }
            ptr = 0
        }
    }
}
