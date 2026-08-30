package cjqt6.gui

import cjqt6.core.*

// ============================================================
// QFontMetrics / QFontInfo - 字体度量与信息
// ============================================================

foreign func qFontMetricsCreate(fontPtr: Int64): Int64
foreign func qFontMetricsDelete(ptr: Int64): Unit
foreign func qFontMetricsHeight(ptr: Int64): Int32
foreign func qFontMetricsAscent(ptr: Int64): Int32
foreign func qFontMetricsDescent(ptr: Int64): Int32
foreign func qFontMetricsLeading(ptr: Int64): Int32
foreign func qFontMetricsLineSpacing(ptr: Int64): Int32
foreign func qFontMetricsAverageCharWidth(ptr: Int64): Int32
foreign func qFontMetricsHorizontalAdvance(ptr: Int64, text: CString): Int32
foreign func qFontMetricsMaxWidth(ptr: Int64): Int32
foreign func qFontMetricsFontFamily(ptr: Int64): CString

foreign func qFontInfoCreate(fontPtr: Int64): Int64
foreign func qFontInfoDelete(ptr: Int64): Unit
foreign func qFontInfoFamily(ptr: Int64): CString
foreign func qFontInfoPointSize(ptr: Int64): Int32
foreign func qFontInfoPointSizeF(ptr: Int64): Float64
foreign func qFontInfoPixelSize(ptr: Int64): Int32
foreign func qFontInfoBold(ptr: Int64): Bool
foreign func qFontInfoItalic(ptr: Int64): Bool
foreign func qFontInfoUnderline(ptr: Int64): Bool
foreign func qFontInfoStrikeOut(ptr: Int64): Bool
foreign func qFontInfoFixedPitch(ptr: Int64): Bool
foreign func qFontInfoWeight(ptr: Int64): Int32
foreign func qFontInfoStyleHint(ptr: Int64): Int32

/// 字体度量信息，提供指定字体下文本的宽度、高度、行距等测量数据（用于精确排版）
public class QFontMetrics {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    private func checkValid(): Unit {
        if (ptr == 0 || closed) { throw ResourceDisposedException("QFontMetrics already deleted") }
    }

    /// 创建字体度量对象，fontPtr 为 QFont 指针
    public init(fontPtr: Int64) {
        unsafe { ptr = qFontMetricsCreate(fontPtr) }
    }

    /// 字体总高度（ascent + descent + leading）
    public func height(): Int32 { checkValid(); unsafe { qFontMetricsHeight(ptr) } }
    /// 上伸部分高度（基线以上的最大高度）
    public func ascent(): Int32 { checkValid(); unsafe { qFontMetricsAscent(ptr) } }
    /// 下伸部分高度（基线以下的最大深度）
    public func descent(): Int32 { checkValid(); unsafe { qFontMetricsDescent(ptr) } }
    /// 行距（两行文本基线之间的额外间距）
    public func leading(): Int32 { checkValid(); unsafe { qFontMetricsLeading(ptr) } }
    /// 行间距（ascent + descent + leading，用于多行文本排版）
    public func lineSpacing(): Int32 { checkValid(); unsafe { qFontMetricsLineSpacing(ptr) } }
    /// 字符平均宽度
    public func averageCharWidth(): Int32 { checkValid(); unsafe { qFontMetricsAverageCharWidth(ptr) } }

    /// 指定文本的水平宽度（像素）
    public func horizontalAdvance(text: String): Int32 {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(text)
            let result = qFontMetricsHorizontalAdvance(ptr, cstr)
            LibC.free(cstr)
            result
        }
    }

    /// 字体中字符的最大宽度
    public func maxWidth(): Int32 { checkValid(); unsafe { qFontMetricsMaxWidth(ptr) } }

    /// 字体族名称（如 "Microsoft YaHei"）
    public func fontFamily(): String {
        checkValid()
        unsafe {
            let cstr = qFontMetricsFontFamily(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            result
        }
    }

    /// 获取底层指针
    public func getPtr(): Int64 { ptr }

    /// 释放资源
    public func close(): Unit {
        if (!closed && ptr != 0) { unsafe { qFontMetricsDelete(ptr) }; ptr = 0; closed = true }
    }
}

/// 字体信息，提供字体实际解析后的属性（如实际使用的字体族、字号、样式等）
public class QFontInfo {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    private func checkValid(): Unit {
        if (ptr == 0 || closed) { throw ResourceDisposedException("QFontInfo already deleted") }
    }

    /// 创建字体信息对象，fontPtr 为 QFont 指针
    public init(fontPtr: Int64) {
        unsafe { ptr = qFontInfoCreate(fontPtr) }
    }

    /// 实际使用的字体族名称
    public func family(): String {
        checkValid()
        unsafe {
            let cstr = qFontInfoFamily(ptr)
            let result = cstr.toString()
            freeBridgeString(cstr)
            result
        }
    }
    /// 字号（磅，整数）
    public func pointSize(): Int32 { checkValid(); unsafe { qFontInfoPointSize(ptr) } }
    /// 字号（磅，浮点精度）
    public func pointSizeF(): Float64 { checkValid(); unsafe { qFontInfoPointSizeF(ptr) } }
    /// 像素字号
    public func pixelSize(): Int32 { checkValid(); unsafe { qFontInfoPixelSize(ptr) } }
    /// 是否加粗
    public func bold(): Bool { checkValid(); unsafe { qFontInfoBold(ptr) } }
    /// 是否斜体
    public func italic(): Bool { checkValid(); unsafe { qFontInfoItalic(ptr) } }
    /// 是否有下划线
    public func underline(): Bool { checkValid(); unsafe { qFontInfoUnderline(ptr) } }
    /// 是否有删除线
    public func strikeOut(): Bool { checkValid(); unsafe { qFontInfoStrikeOut(ptr) } }
    /// 是否等宽字体
    public func fixedPitch(): Bool { checkValid(); unsafe { qFontInfoFixedPitch(ptr) } }
    /// 字重（QFont::Weight 值，400 为常规，700 为粗体）
    public func weight(): Int32 { checkValid(); unsafe { qFontInfoWeight(ptr) } }
    /// 字体风格提示（QFont::StyleHint）
    public func styleHint(): Int32 { checkValid(); unsafe { qFontInfoStyleHint(ptr) } }

    /// 获取底层指针
    public func getPtr(): Int64 { ptr }

    /// 释放资源
    public func close(): Unit {
        if (!closed && ptr != 0) { unsafe { qFontInfoDelete(ptr) }; ptr = 0; closed = true }
    }
}
