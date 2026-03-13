package CJQT6.print

// QPrinter - 打印机
foreign func qPrinterCreate(): Int64
foreign func qPrinterCreateWithMode(mode: Int32): Int64
foreign func qPrinterSetOutputFormat(ptr: Int64, format: Int32): Unit
foreign func qPrinterOutputFormat(ptr: Int64): Int32
foreign func qPrinterSetOutputFileName(ptr: Int64, name: CString): Unit
foreign func qPrinterOutputFileName(ptr: Int64): CString
foreign func qPrinterSetPageSize(ptr: Int64, pageSize: Int32): Unit
foreign func qPrinterPageSize(ptr: Int64): Int32
foreign func qPrinterSetOrientation(ptr: Int64, orientation: Int32): Unit
foreign func qPrinterOrientation(ptr: Int64): Int32
foreign func qPrinterSetPageMargins(ptr: Int64, left: Float32, top: Float32, right: Float32, bottom: Float32): Unit
foreign func qPrinterSetFullPage(ptr: Int64, fullPage: Bool): Unit
foreign func qPrinterFullPage(ptr: Int64): Bool
foreign func qPrinterSetNumCopies(ptr: Int64, copies: Int32): Unit
foreign func qPrinterNumCopies(ptr: Int64): Int32
foreign func qPrinterSetCopyCollate(ptr: Int64, collate: Bool): Unit
foreign func qPrinterCopyCollate(ptr: Int64): Bool
foreign func qPrinterSetColorMode(ptr: Int64, mode: Int32): Unit
foreign func qPrinterColorMode(ptr: Int64): Int32
foreign func qPrinterSetDoubleSidedPrinting(ptr: Int64, enable: Bool): Unit
foreign func qPrinterDoubleSidedPrinting(ptr: Int64): Bool
foreign func qPrinterWidth(ptr: Int64): Int32
foreign func qPrinterHeight(ptr: Int64): Int32
foreign func qPrinterResolution(ptr: Int64): Int32
foreign func qPrinterSetResolution(ptr: Int64, dpi: Int32): Unit
foreign func qPrinterPrinterName(ptr: Int64): CString
foreign func qPrinterSetPrinterName(ptr: Int64, name: CString): Unit
foreign func qPrinterDocName(ptr: Int64): CString
foreign func qPrinterSetDocName(ptr: Int64, name: CString): Unit
foreign func qPrinterNewPage(ptr: Int64): Int32
foreign func qPrinterFromPage(ptr: Int64): Int32
foreign func qPrinterToPage(ptr: Int64): Int32
foreign func qPrinterSetFromTo(ptr: Int64, from: Int32, to: Int32): Unit
foreign func qPrinterDelete(ptr: Int64): Unit

// QPrintDialog - 打印对话框
foreign func qPrintDialogCreate(printerPtr: Int64): Int64
foreign func qPrintDialogExec(ptr: Int64): Int32
foreign func qPrintDialogPrinter(ptr: Int64): Int64
foreign func qPrintDialogDelete(ptr: Int64): Unit

// QPrintPreviewDialog - 打印预览对话框
foreign func qPrintPreviewDialogCreate(printerPtr: Int64): Int64
foreign func qPrintPreviewDialogExec(ptr: Int64): Int32
foreign func qPrintPreviewDialogPrinter(ptr: Int64): Int64
foreign func qPrintPreviewDialogDelete(ptr: Int64): Unit

// 打印机模式
public class PrinterMode {
    public static func screenResolution(): Int32 { 0 }
    public static func printerResolution(): Int32 { 1 }
    public static func highResolution(): Int32 { 2 }
}

// 输出格式
public class OutputFormat {
    public static func nativeFormat(): Int32 { 0 }
    public static func pdfFormat(): Int32 { 1 }
}

// 页面大小
public class PageSize {
    public static func a4(): Int32 { 5 }
    public static func letter(): Int32 { 3 }
    public static func legal(): Int32 { 4 }
    public static func a3(): Int32 { 6 }
    public static func a5(): Int32 { 7 }
    public static func b4(): Int32 { 8 }
    public static func b5(): Int32 { 9 }
}

// 页面方向
public class PageOrientation {
    public static func portrait(): Int32 { 0 }
    public static func landscape(): Int32 { 1 }
}

// 颜色模式
public class ColorMode {
    public static func grayScale(): Int32 { 0 }
    public static func color(): Int32 { 1 }
}

/// 打印机
public class QPrinter {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe { ptr = qPrinterCreate() }
    }
    
    public init(mode: Int32) {
        unsafe { ptr = qPrinterCreateWithMode(mode) }
    }
    
    public func setOutputFormat(format: Int32): Unit {
        unsafe { qPrinterSetOutputFormat(ptr, format) }
    }
    
    public func outputFormat(): Int32 {
        unsafe { qPrinterOutputFormat(ptr) }
    }
    
    public func setOutputFileName(name: String): Unit {
        unsafe {
            var cstr = LibC.mallocCString(name)
            qPrinterSetOutputFileName(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func outputFileName(): String {
        unsafe {
            let cstr = qPrinterOutputFileName(ptr)
            return cstr.toString()
        }
    }
    
    public func setPageSize(pageSize: Int32): Unit {
        unsafe { qPrinterSetPageSize(ptr, pageSize) }
    }
    
    public func pageSize(): Int32 {
        unsafe { qPrinterPageSize(ptr) }
    }
    
    public func setOrientation(orientation: Int32): Unit {
        unsafe { qPrinterSetOrientation(ptr, orientation) }
    }
    
    public func orientation(): Int32 {
        unsafe { qPrinterOrientation(ptr) }
    }
    
    public func setPageMargins(left: Float32, top: Float32, right: Float32, bottom: Float32): Unit {
        unsafe { qPrinterSetPageMargins(ptr, left, top, right, bottom) }
    }
    
    public func setFullPage(fullPage: Bool): Unit {
        unsafe { qPrinterSetFullPage(ptr, fullPage) }
    }
    
    public func fullPage(): Bool {
        unsafe { qPrinterFullPage(ptr) }
    }
    
    public func setNumCopies(copies: Int32): Unit {
        unsafe { qPrinterSetNumCopies(ptr, copies) }
    }
    
    public func numCopies(): Int32 {
        unsafe { qPrinterNumCopies(ptr) }
    }
    
    public func setCopyCollate(collate: Bool): Unit {
        unsafe { qPrinterSetCopyCollate(ptr, collate) }
    }
    
    public func copyCollate(): Bool {
        unsafe { qPrinterCopyCollate(ptr) }
    }
    
    public func setColorMode(mode: Int32): Unit {
        unsafe { qPrinterSetColorMode(ptr, mode) }
    }
    
    public func colorMode(): Int32 {
        unsafe { qPrinterColorMode(ptr) }
    }
    
    public func setDoubleSidedPrinting(enable: Bool): Unit {
        unsafe { qPrinterSetDoubleSidedPrinting(ptr, enable) }
    }
    
    public func doubleSidedPrinting(): Bool {
        unsafe { qPrinterDoubleSidedPrinting(ptr) }
    }
    
    public func width(): Int32 {
        unsafe { qPrinterWidth(ptr) }
    }
    
    public func height(): Int32 {
        unsafe { qPrinterHeight(ptr) }
    }
    
    public func resolution(): Int32 {
        unsafe { qPrinterResolution(ptr) }
    }
    
    public func setResolution(dpi: Int32): Unit {
        unsafe { qPrinterSetResolution(ptr, dpi) }
    }
    
    public func printerName(): String {
        unsafe {
            let cstr = qPrinterPrinterName(ptr)
            return cstr.toString()
        }
    }
    
    public func setPrinterName(name: String): Unit {
        unsafe {
            var cstr = LibC.mallocCString(name)
            qPrinterSetPrinterName(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func docName(): String {
        unsafe {
            let cstr = qPrinterDocName(ptr)
            return cstr.toString()
        }
    }
    
    public func setDocName(name: String): Unit {
        unsafe {
            var cstr = LibC.mallocCString(name)
            qPrinterSetDocName(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func newPage(): Bool {
        unsafe { qPrinterNewPage(ptr) != 0 }
    }
    
    public func fromPage(): Int32 {
        unsafe { qPrinterFromPage(ptr) }
    }
    
    public func toPage(): Int32 {
        unsafe { qPrinterToPage(ptr) }
    }
    
    public func setFromTo(from: Int32, to: Int32): Unit {
        unsafe { qPrinterSetFromTo(ptr, from, to) }
    }
    
    public func getPtr(): Int64 { ptr }
    
    public func delete() {
        if (ptr != 0) {
            unsafe { qPrinterDelete(ptr) }
            ptr = 0
        }
    }
}

/// 打印对话框
public class QPrintDialog {
    private var ptr: Int64 = 0
    
    public init(printer: QPrinter) {
        unsafe { ptr = qPrintDialogCreate(printer.getPtr()) }
    }
    
    public func exec(): Int32 {
        unsafe { qPrintDialogExec(ptr) }
    }
    
    public func printer(): Int64 {
        unsafe { qPrintDialogPrinter(ptr) }
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe { qPrintDialogDelete(ptr) }
            ptr = 0
        }
    }
}

/// 打印预览对话框
public class QPrintPreviewDialog {
    private var ptr: Int64 = 0
    
    public init(printer: QPrinter) {
        unsafe { ptr = qPrintPreviewDialogCreate(printer.getPtr()) }
    }
    
    public func exec(): Int32 {
        unsafe { qPrintPreviewDialogExec(ptr) }
    }
    
    public func printer(): Int64 {
        unsafe { qPrintPreviewDialogPrinter(ptr) }
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe { qPrintPreviewDialogDelete(ptr) }
            ptr = 0
        }
    }
}
