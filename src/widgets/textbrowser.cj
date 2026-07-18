package cjqt6.widgets

import cjqt6.core.*

// QTextBrowser - 富文本浏览器（支持HTML、导航）
foreign func qTextBrowserCreate(): Int64
foreign func qTextBrowserSetText(ptr: Int64, text: CString): Unit
foreign func qTextBrowserToPlainText(ptr: Int64): CString
foreign func qTextBrowserSetHtml(ptr: Int64, html: CString): Unit
foreign func qTextBrowserToHtml(ptr: Int64): CString
foreign func qTextBrowserSetSource(ptr: Int64, url: CString): Unit
foreign func qTextBrowserBackward(ptr: Int64): Unit
foreign func qTextBrowserForward(ptr: Int64): Unit
foreign func qTextBrowserHome(ptr: Int64): Unit
foreign func qTextBrowserReload(ptr: Int64): Unit
foreign func qTextBrowserSetOpenLinks(ptr: Int64, open: Bool): Unit
foreign func qTextBrowserSetOpenExternalLinks(ptr: Int64, open: Bool): Unit
foreign func qTextBrowserClear(ptr: Int64): Unit
foreign func qTextBrowserSetPlainText(ptr: Int64, text: CString): Unit
foreign func qTextBrowserDelete(ptr: Int64): Unit

/// 富文本浏览器
/// 支持HTML内容显示、超链接导航、前进/后退浏览历史
public class QTextBrowser {
    private var ptr: Int64 = 0

    public init(parent!: Int64 = 0) {
        unsafe {
            ptr = qTextBrowserCreate()
            if (parent != 0) {
                setWidgetParent(ptr, parent)
            }
        }
    }

    /// 显示
    public func show(): Unit {
        unsafe { qWidgetShow(ptr) }
    }

    /// 隐藏
    public func hide(): Unit {
        unsafe { qWidgetHide(ptr) }
    }

    /// 调整大小
    public func resize(width: Int32, height: Int32): Unit {
        unsafe { qWidgetResize(ptr, width, height) }
    }

    /// 设置样式表
    public func setStyleSheet(style: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(style)
            qWidgetSetStyleSheet(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 设置纯文本内容
    public func setText(text: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(text)
            qTextBrowserSetText(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 获取纯文本内容
    public func toPlainText(): String {
        unsafe {
            let cstr = qTextBrowserToPlainText(ptr)
            return cstr.toString()
        }
    }

    /// 设置HTML内容
    public func setHtml(html: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(html)
            qTextBrowserSetHtml(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 获取HTML内容
    public func toHtml(): String {
        unsafe {
            let cstr = qTextBrowserToHtml(ptr)
            return cstr.toString()
        }
    }

    /// 导航到指定源URL
    public func setSource(url: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(url)
            qTextBrowserSetSource(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 后退到上一个浏览历史
    public func backward(): Unit { unsafe { qTextBrowserBackward(ptr) } }

    /// 前进到下一个浏览历史
    public func forward(): Unit { unsafe { qTextBrowserForward(ptr) } }

    /// 导航到首页
    public func home(): Unit { unsafe { qTextBrowserHome(ptr) } }

    /// 重新加载当前页面
    public func reload(): Unit { unsafe { qTextBrowserReload(ptr) } }

    /// 设置是否允许打开链接
    public func setOpenLinks(open: Bool): Unit { unsafe { qTextBrowserSetOpenLinks(ptr, open) } }

    /// 设置是否允许打开外部链接
    public func setOpenExternalLinks(open: Bool): Unit { unsafe { qTextBrowserSetOpenExternalLinks(ptr, open) } }

    /// 清空内容
    public func clear(): Unit { unsafe { qTextBrowserClear(ptr) } }

    /// 设置纯文本
    public func setPlainText(text: String): Unit {
        unsafe {
            let cstr = LibC.mallocCString(text)
            qTextBrowserSetPlainText(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 设置最小尺寸
    public func setMinimumSize(minw: Int32, minh: Int32): Unit {
        unsafe {
            qWidgetSetMinimumSize(ptr, minw, minh)
        }
    }

    /// 获取原生指针
    public func getPtr(): Int64 {
        return ptr
    }

    /// 删除文本浏览器
    public func delete(): Unit {
        if (ptr != 0) {
            unsafe {
                qTextBrowserDelete(ptr)
            }
            ptr = 0
        }
    }
}
