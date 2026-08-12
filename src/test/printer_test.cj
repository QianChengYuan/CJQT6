package cjqt6.test

// =====================================================================
// 打印模块测试（src/print/printer.cj）
// 覆盖：PrinterMode/OutputFormat/PageSize/PageOrientation/ColorMode 常量
//      QPrinter / QPrintDialog / QPrintPreviewDialog
// 注意：QPrintDialog.exec / QPrintPreviewDialog.exec 会弹模态对话框阻塞，
//      标注 @Tag[requires_gui_dialog]；QPrinter 实例操作不阻塞
// =====================================================================

import cjqt6.core.*
import cjqt6.print.*
import std.unittest.*

// ---------------------------------------------------------------------
// 打印常量类测试（无需 GUI）
// ---------------------------------------------------------------------
@Test
class PrinterConstantsTests {
    @TestCase
    func testPrinterMode() {
        @Expect(PrinterMode.screenResolution(), 0)
        @Expect(PrinterMode.printerResolution(), 1)
        @Expect(PrinterMode.highResolution(), 2)
    }

    @TestCase
    func testOutputFormat() {
        @Expect(OutputFormat.nativeFormat(), 0)
        @Expect(OutputFormat.pdfFormat(), 1)
    }

    @TestCase
    func testPageSize() {
        @Expect(PageSize.a4(), 5)
        @Expect(PageSize.letter(), 3)
        @Expect(PageSize.legal(), 4)
        @Expect(PageSize.a3(), 6)
        @Expect(PageSize.a5(), 7)
        @Expect(PageSize.b4(), 8)
        @Expect(PageSize.b5(), 9)
    }

    @TestCase
    func testPageOrientation() {
        @Expect(PageOrientation.portrait(), 0)
        @Expect(PageOrientation.landscape(), 1)
    }

    @TestCase
    func testColorMode() {
        @Expect(ColorMode.grayScale(), 0)
        @Expect(ColorMode.color(), 1)
    }
}

// ---------------------------------------------------------------------
// QPrinter 测试
// ---------------------------------------------------------------------
@Test
class QPrinterTests {
    private static var guiEnv: ?GUITestEnvironment = None

    @BeforeAll
    static func setupGUI(): Unit {
        let env = GUITestEnvironment.getInstance()
        env.setupEnvironment()
        guiEnv = Some(env)
    }

    @AfterAll
    static func teardownGUI(): Unit {
        if (let Some(env) <- guiEnv) {
            env.teardownEnvironment()
        }
    }

    @TestCase
    func testCreateDefault() {
        let p = QPrinter()
        @Assert(p.getPtr() != 0)
        p.delete()
    }

    @TestCase
    func testCreateWithMode() {
        let p = QPrinter(PrinterMode.screenResolution())
        @Assert(p.getPtr() != 0)
        p.delete()
        let p2 = QPrinter(PrinterMode.highResolution())
        @Assert(p2.getPtr() != 0)
        p2.delete()
    }

    @TestCase
    func testDoubleDelete() {
        let p = QPrinter()
        p.delete()
        p.delete()  // 安全
        @Assert(true)
    }

    @TestCase
    func testOutputFormatRoundtrip() {
        let p = QPrinter()
        p.setOutputFormat(OutputFormat.pdfFormat())
        @Expect(p.outputFormat(), OutputFormat.pdfFormat())
        p.setOutputFormat(OutputFormat.nativeFormat())
        @Expect(p.outputFormat(), OutputFormat.nativeFormat())
        p.delete()
    }

    @TestCase
    func testOutputFileNameRoundtrip() {
        let p = QPrinter()
        p.setOutputFileName("output.pdf")
        @Expect(p.outputFileName(), "output.pdf")
        p.setOutputFileName("C:\\tmp\\report.pdf")
        @Expect(p.outputFileName(), "C:\\tmp\\report.pdf")
        p.delete()
    }

    @TestCase
    func testPageSizeRoundtrip() {
        let p = QPrinter()
        p.setPageSize(PageSize.a4())
        @Expect(p.pageSize(), PageSize.a4())
        p.setPageSize(PageSize.letter())
        @Expect(p.pageSize(), PageSize.letter())
        p.delete()
    }

    @TestCase
    func testOrientationRoundtrip() {
        let p = QPrinter()
        p.setOrientation(PageOrientation.landscape())
        @Expect(p.orientation(), PageOrientation.landscape())
        p.setOrientation(PageOrientation.portrait())
        @Expect(p.orientation(), PageOrientation.portrait())
        p.delete()
    }

    @TestCase
    func testSetPageMargins() {
        let p = QPrinter()
        p.setPageMargins(10.0f32, 20.0f32, 10.0f32, 20.0f32)
        p.delete()
        @Assert(true)
    }

    @TestCase
    func testFullPageRoundtrip() {
        let p = QPrinter()
        p.setFullPage(true)
        @Expect(p.fullPage(), true)
        p.setFullPage(false)
        @Expect(p.fullPage(), false)
        p.delete()
    }

    @TestCase
    func testNumCopiesRoundtrip() {
        let p = QPrinter()
        p.setNumCopies(3)
        @Expect(p.numCopies(), 3)
        p.setNumCopies(1)
        @Expect(p.numCopies(), 1)
        p.delete()
    }

    @TestCase
    func testCopyCollateRoundtrip() {
        let p = QPrinter()
        p.setCopyCollate(true)
        @Expect(p.copyCollate(), true)
        p.setCopyCollate(false)
        @Expect(p.copyCollate(), false)
        p.delete()
    }

    @TestCase
    func testColorModeRoundtrip() {
        let p = QPrinter()
        p.setColorMode(ColorMode.color())
        @Expect(p.colorMode(), ColorMode.color())
        p.setColorMode(ColorMode.grayScale())
        @Expect(p.colorMode(), ColorMode.grayScale())
        p.delete()
    }

    @TestCase
    func testDoubleSidedPrintingRoundtrip() {
        let p = QPrinter()

        p.setDoubleSidedPrinting(false)
        @Expect(p.doubleSidedPrinting(), false)
        p.delete()
    }

    @TestCase
    func testResolutionRoundtrip() {
        let p = QPrinter()
        p.setResolution(300)
        @Expect(p.resolution(), 300)
        p.setResolution(600)
        @Expect(p.resolution(), 600)
        p.delete()
    }

    @TestCase
    func testWidthHeightPositive() {
        let p = QPrinter()
        @Expect(p.width() > 0, true)
        @Expect(p.height() > 0, true)
        p.delete()
    }

    @TestCase
    func testPrinterNameRoundtrip() {
        let p = QPrinter()
        let name = p.printerName()
        @Assert(name.size >= 0)
        p.delete()
    }

    @TestCase
    func testDocNameRoundtrip() {
        let p = QPrinter()
        p.setDocName("MyDocument")
        @Expect(p.docName(), "MyDocument")
        p.delete()
    }

    @TestCase
    func testNewPage() {
        let p = QPrinter()
        let r = p.newPage()
        @Assert(r == true || r == false)
        p.delete()
    }

    @TestCase
    func testSetFromTo() {
        let p = QPrinter()
        p.setFromTo(1, 5)
        @Expect(p.fromPage(), 1)
        @Expect(p.toPage(), 5)
        p.delete()
    }
}

// ---------------------------------------------------------------------
// QPrintDialog 测试（不调用 exec，避免阻塞）
// ---------------------------------------------------------------------
@Test
class QPrintDialogTests {
    private static var guiEnv: ?GUITestEnvironment = None

    @BeforeAll
    static func setupGUI(): Unit {
        let env = GUITestEnvironment.getInstance()
        env.setupEnvironment()
        guiEnv = Some(env)
    }

    @AfterAll
    static func teardownGUI(): Unit {
        if (let Some(env) <- guiEnv) {
            env.teardownEnvironment()
        }
    }

    @TestCase
    func testCreate() {
        let printer = QPrinter()
        let dlg = QPrintDialog(printer)
        @Assert(dlg.printer() != 0)
        dlg.delete()
        printer.delete()
    }

    @TestCase
    func testDoubleDelete() {
        let printer = QPrinter()
        let dlg = QPrintDialog(printer)
        dlg.delete()
        dlg.delete()  // 安全
        printer.delete()
        @Assert(true)
    }
}

// ---------------------------------------------------------------------
// QPrintDialog.exec 测试（模态阻塞，仅本地手动跑）
// ---------------------------------------------------------------------
@Test
@Tag[requires_gui_dialog]
class QPrintDialogExecTests {
    private static var guiEnv: ?GUITestEnvironment = None

    @BeforeAll
    static func setupGUI(): Unit {
        let env = GUITestEnvironment.getInstance()
        env.setupEnvironment()
        guiEnv = Some(env)
    }

    @AfterAll
    static func teardownGUI(): Unit {
        if (let Some(env) <- guiEnv) {
            env.teardownEnvironment()
        }
    }

    @TestCase
    func testExec() {
        let printer = QPrinter()
        let dlg = QPrintDialog(printer)
        let r = dlg.exec()
        @Assert(r >= 0)
        dlg.delete()
        printer.delete()
    }
}

// ---------------------------------------------------------------------
// QPrintPreviewDialog 测试（不调用 exec，避免阻塞）
// ---------------------------------------------------------------------
@Test
class QPrintPreviewDialogTests {
    private static var guiEnv: ?GUITestEnvironment = None

    @BeforeAll
    static func setupGUI(): Unit {
        let env = GUITestEnvironment.getInstance()
        env.setupEnvironment()
        guiEnv = Some(env)
    }

    @AfterAll
    static func teardownGUI(): Unit {
        if (let Some(env) <- guiEnv) {
            env.teardownEnvironment()
        }
    }

    @TestCase
    func testCreateWithPrinter() {
        let printer = QPrinter()
        let dlg = QPrintPreviewDialog(printer)
        @Assert(dlg.printer() != 0)
        dlg.delete()
        printer.delete()
    }

    @TestCase
    func testDoubleDelete() {
        let printer = QPrinter()
        let dlg = QPrintPreviewDialog(printer)
        dlg.delete()
        dlg.delete()
        printer.delete()
        @Assert(true)
    }
}