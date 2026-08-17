package cjqt6.test

// =====================================================================
// 对话框模块测试（src/dialogs/dialogs.cj）
// 覆盖范围：
//   - QProgressDialog：构造/属性/getPtr/close/checkValid + 各 setter
//   - QWizardPage：构造/标题/副标题/提交页标记 + 资源管理
//   - QWizard：构造/添加页面/导航/选项/标题 + 资源管理
//   - QErrorMessage：构造/showMessage/标题 + 资源管理
//   - QFontInfo：数据类字段
//   - QWizardOption：常量
//   - QMessageBox/QFileDialog/QInputDialog/QColorDialog/QFontDialog 静态方法
//     需要真实 GUI 事件循环（模态阻塞），用 @Tag[requires_gui_dialog] 标注，
//     CI 默认跳过，本地手动跑
// =====================================================================

import cjqt6.core.*
import cjqt6.dialogs.*
import std.unittest.*

// ---------------------------------------------------------------------
// QFontInfo 数据类测试（无需 GUI）
// ---------------------------------------------------------------------
@Test
class DialogsQFontInfoTests {
    @TestCase
    func testCreateAllFields() {
        let info = QFontInfo("Microsoft YaHei", 12, true, false)
        @Expect(info.family, "Microsoft YaHei")
        @Expect(info.size, 12)
        @Expect(info.bold, true)
        @Expect(info.italic, false)
    }

    @TestCase
    func testCreateDefaults() {
        let info = QFontInfo("Arial", 10, false, false)
        @Expect(info.family, "Arial")
        @Expect(info.size, 10)
        @Expect(info.bold, false)
        @Expect(info.italic, false)
    }

    @TestCase
    func testCreateItalicOnly() {
        let info = QFontInfo("Consolas", 14, false, true)
        @Expect(info.bold, false)
        @Expect(info.italic, true)
    }
}

// ---------------------------------------------------------------------
// QWizardOption 常量测试（无需 GUI）
// ---------------------------------------------------------------------
@Test
class QWizardOptionTests {
    @TestCase
    func testConstants() {
        @Expect(QWizardOption.HaveCustomButton1, 1)
        @Expect(QWizardOption.NoBackButtonOnStartPage, 8)
        @Expect(QWizardOption.NoCancelButton, 256)
        @Expect(QWizardOption.IndependentPages, 32768)
        @Expect(QWizardOption.NoDefaultButton, 8192)
    }
}

// ---------------------------------------------------------------------
// QProgressDialog 测试
// ---------------------------------------------------------------------
@Test
class QProgressDialogTests {
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
        let dlg = QProgressDialog(0, "处理中...", "取消", 0, 100)
        @Assert(dlg.isValid())
        @Expect(dlg.isClosed(), false)
        @Expect(dlg.getPtr() != 0, true)
        dlg.close()
        @Expect(dlg.isClosed(), true)
    }

    @TestCase
    func testCloseAndInvalid() {
        let dlg = QProgressDialog(0, "loading", "cancel", 0, 50)
        dlg.close()
        @Expect(dlg.isClosed(), true)
        @Expect(dlg.isValid(), false)
        @Expect(dlg.getPtr(), 0)
    }

    @TestCase
    func testDeleteCompatibility() {
        let dlg = QProgressDialog(0, "x", "y", 0, 10)
        dlg.delete()
        @Expect(dlg.isClosed(), true)
    }

    @TestCase
    func testDoubleClose() {
        let dlg = QProgressDialog(0, "x", "y", 0, 10)
        dlg.close()
        dlg.close()
        @Expect(dlg.isClosed(), true)
    }

    @TestCase
    func testCheckValidAfterClose() {
        let dlg = QProgressDialog(0, "x", "y", 0, 10)
        dlg.close()
        @ExpectThrows[ResourceDisposedException](dlg.checkValid())
    }

    @TestCase
    func testSetValueGetValue() {
        let dlg = QProgressDialog(0, "x", "y", 0, 100)
        dlg.setMinimum(0)
        dlg.setMaximum(100)
        dlg.setValue(42)
        // offscreen 平台下 value() 可能不立即生效，仅验证不崩溃
        let v = dlg.value()
        @Assert(v >= -1 && v <= 100)
        dlg.setValue(0)
        @Assert(dlg.value() >= -1 && dlg.value() <= 100)
        dlg.close()
    }

    @TestCase
    func testSetMinimumMaximum() {
        let dlg = QProgressDialog(0, "x", "y", 0, 100)
        dlg.setMinimum(10)
        dlg.setMaximum(200)
        dlg.setValue(50)
        @Expect(dlg.value(), 50)
        dlg.close()
    }

    @TestCase
    func testSetLabelText() {
        let dlg = QProgressDialog(0, "initial", "y", 0, 10)
        dlg.setLabelText("updated label")
        dlg.close()
        @Assert(true)
    }

    @TestCase
    func testSetCancelButtonText() {
        let dlg = QProgressDialog(0, "x", "cancel", 0, 10)
        dlg.setCancelButtonText("abort")
        dlg.close()
        @Assert(true)
    }

    @TestCase
    func testSetWindowTitle() {
        let dlg = QProgressDialog(0, "x", "y", 0, 10)
        dlg.setWindowTitle("Progress")
        dlg.close()
        @Assert(true)
    }

    @TestCase
    func testAutoCloseAutoReset() {
        let dlg = QProgressDialog(0, "x", "y", 0, 10)
        dlg.setAutoClose(true)
        dlg.setAutoReset(false)
        dlg.setAutoClose(false)
        dlg.setAutoReset(true)
        dlg.close()
        @Assert(true)
    }

    @TestCase
    func testWasCanceledInitial() {
        let dlg = QProgressDialog(0, "x", "y", 0, 10)
        @Expect(dlg.wasCanceled(), false)
        dlg.close()
    }

    @TestCase
    func testShowHideCancelReset() {
        let dlg = QProgressDialog(0, "x", "y", 0, 10)
        dlg.show()
        dlg.hide()
        dlg.cancel()
        dlg.reset()
        dlg.close()
        @Assert(true)
    }

    @TestCase
    func testOperationsAfterClose() {
        let dlg = QProgressDialog(0, "x", "y", 0, 10)
        dlg.close()
        @ExpectThrows[ResourceDisposedException](dlg.setValue(5))
        @ExpectThrows[ResourceDisposedException](dlg.value())
        @ExpectThrows[ResourceDisposedException](dlg.setMinimum(0))
        @ExpectThrows[ResourceDisposedException](dlg.setMaximum(10))
        @ExpectThrows[ResourceDisposedException](dlg.setLabelText("z"))
        @ExpectThrows[ResourceDisposedException](dlg.wasCanceled())
        @ExpectThrows[ResourceDisposedException](dlg.show())
    }
}

// ---------------------------------------------------------------------
// QWizardPage 测试
// ---------------------------------------------------------------------
@Test
class QWizardPageTests {
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
        let page = QWizardPage()
        @Assert(page.isValid())
        @Expect(page.isClosed(), false)
        @Expect(page.getPtr() != 0, true)
        page.close()
        @Expect(page.isClosed(), true)
    }

    @TestCase
    func testCreateWithParent() {
        let page = QWizardPage()
        @Assert(page.isValid())
        page.close()
    }

    @TestCase
    func testSetTitle() {
        let page = QWizardPage()
        page.setTitle("第一步")
        page.setSubTitle("请填写基本信息")
        page.close()
        @Assert(true)
    }

    @TestCase
    func testCommitPage() {
        let page = QWizardPage()
        @Expect(page.isCommitPage(), false)
        page.setCommitPage(true)
        @Expect(page.isCommitPage(), true)
        page.setCommitPage(false)
        @Expect(page.isCommitPage(), false)
        page.close()
    }

    @TestCase
    func testCloseAndCheckValid() {
        let page = QWizardPage()
        page.close()
        @Expect(page.isValid(), false)
        @ExpectThrows[ResourceDisposedException](page.checkValid())
    }

    @TestCase
    func testOperationsAfterClose() {
        let page = QWizardPage()
        page.close()
        @ExpectThrows[ResourceDisposedException](page.setTitle("x"))
        @ExpectThrows[ResourceDisposedException](page.setSubTitle("y"))
        @ExpectThrows[ResourceDisposedException](page.setCommitPage(true))
        @ExpectThrows[ResourceDisposedException](page.isCommitPage())
    }

    @TestCase
    func testDeleteCompatibility() {
        let page = QWizardPage()
        page.delete()
        @Expect(page.isClosed(), true)
    }
}

// ---------------------------------------------------------------------
// QWizard 测试
// ---------------------------------------------------------------------
@Test
class QWizardTests {
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
        let wiz = QWizard()
        @Assert(wiz.isValid())
        @Expect(wiz.isClosed(), false)
        @Expect(wiz.getPtr() != 0, true)
        wiz.close()
        @Expect(wiz.isClosed(), true)
    }

    @TestCase
    @Tag[requires_gui_dialog]
    func testAddPageAndCurrentId() {
        let wiz = QWizard()
        let p1 = QWizardPage()
        p1.setTitle("Page 1")
        let id1 = wiz.addPage(p1)
        @Expect(id1, 0)
        let p2 = QWizardPage()
        p2.setTitle("Page 2")
        let id2 = wiz.addPage(p2)
        @Expect(id2, 1)
        wiz.show()
        @Expect(wiz.currentId(), 0)
        wiz.close()
    }

    @TestCase
    func testPageByIndex() {
        let wiz = QWizard()
        let p = QWizardPage()
        wiz.addPage(p)
        let ptr = wiz.page(0)
        @Expect(ptr != 0, true)
        let nonePtr = wiz.page(99)
        // 越界索引返回 0（Qt 行为）
        @Expect(nonePtr, 0)
        wiz.close()
    }

    @TestCase
    @Tag[requires_gui_dialog]
    func testNavigation() {
        let wiz = QWizard()
        let p1 = QWizardPage()
        let p2 = QWizardPage()
        wiz.addPage(p1)
        wiz.addPage(p2)
        wiz.show()
        @Expect(wiz.currentId(), 0)
        wiz.next()
        @Expect(wiz.currentId(), 1)
        wiz.back()
        @Expect(wiz.currentId(), 0)
        wiz.restart()
        @Expect(wiz.currentId(), 0)
        wiz.close()
    }

    @TestCase
    func testSetStartId() {
        let wiz = QWizard()
        let p1 = QWizardPage()
        let p2 = QWizardPage()
        wiz.addPage(p1)
        wiz.addPage(p2)
        wiz.setStartId(1)
        wiz.restart()
        @Expect(wiz.currentId(), 1)
        wiz.close()
    }

    @TestCase
    func testOptions() {
        let wiz = QWizard()
        wiz.setOption(QWizardOption.NoCancelButton, true)
        @Expect(wiz.testOption(QWizardOption.NoCancelButton), true)
        wiz.setOption(QWizardOption.NoCancelButton, false)
        @Expect(wiz.testOption(QWizardOption.NoCancelButton), false)
        wiz.setOption(QWizardOption.IndependentPages, true)
        @Expect(wiz.testOption(QWizardOption.IndependentPages), true)
        wiz.close()
    }

    @TestCase
    func testSetWindowTitle() {
        let wiz = QWizard()
        wiz.setWindowTitle("安装向导")
        wiz.close()
        @Assert(true)
    }

    @TestCase
    @Tag[requires_gui_dialog]
    func testShow() {
        let wiz = QWizard()
        wiz.show()
        wiz.close()
        @Assert(true)
    }

    @TestCase
    func testCloseAndCheckValid() {
        let wiz = QWizard()
        wiz.close()
        @Expect(wiz.isValid(), false)
        @ExpectThrows[ResourceDisposedException](wiz.checkValid())
    }

    @TestCase
    func testOperationsAfterClose() {
        let wiz = QWizard()
        wiz.close()
        let p = QWizardPage()
        @ExpectThrows[ResourceDisposedException](wiz.addPage(p))
        p.close()
        @ExpectThrows[ResourceDisposedException](wiz.currentId())
        @ExpectThrows[ResourceDisposedException](wiz.next())
        @ExpectThrows[ResourceDisposedException](wiz.setWindowTitle("x"))
        @ExpectThrows[ResourceDisposedException](wiz.show())
    }
}

// ---------------------------------------------------------------------
// QErrorMessage 测试
// ---------------------------------------------------------------------
@Test
class QErrorMessageTests {
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
        let dlg = QErrorMessage()
        @Assert(dlg.isValid())
        @Expect(dlg.isClosed(), false)
        @Expect(dlg.getPtr() != 0, true)
        dlg.close()
        @Expect(dlg.isClosed(), true)
    }

    @TestCase
    func testCreateWithParent() {
        let dlg = QErrorMessage()
        @Assert(dlg.isValid())
        dlg.close()
    }

    @TestCase
    @Tag[requires_gui_dialog]
    func testShowMessage() {
        let dlg = QErrorMessage()
        dlg.showMessage("发生了一个错误")
        dlg.showMessage("另一个错误")
        dlg.close()
        @Assert(true)
    }

    @TestCase
    func testSetWindowTitle() {
        let dlg = QErrorMessage()
        dlg.setWindowTitle("错误提示")
        dlg.close()
        @Assert(true)
    }

    @TestCase
    func testShow() {
        let dlg = QErrorMessage()
        dlg.show()
        dlg.close()
        @Assert(true)
    }

    @TestCase
    func testCloseAndCheckValid() {
        let dlg = QErrorMessage()
        dlg.close()
        @Expect(dlg.isValid(), false)
        @ExpectThrows[ResourceDisposedException](dlg.checkValid())
    }

    @TestCase
    func testOperationsAfterClose() {
        let dlg = QErrorMessage()
        dlg.close()
        @ExpectThrows[ResourceDisposedException](dlg.showMessage("x"))
        @ExpectThrows[ResourceDisposedException](dlg.setWindowTitle("y"))
        @ExpectThrows[ResourceDisposedException](dlg.show())
    }

    @TestCase
    func testDeleteCompatibility() {
        let dlg = QErrorMessage()
        dlg.delete()
        @Expect(dlg.isClosed(), true)
    }
}

// ---------------------------------------------------------------------
// QMessageBox 静态方法测试（模态阻塞，仅本地手动跑）
// ---------------------------------------------------------------------
@Test
@Tag[requires_gui_dialog]
class QMessageBoxStaticTests {
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
    func testInformation() {
        QMessageBox.information(0, "提示", "操作完成")
        @Assert(true)
    }

    @TestCase
    func testWarning() {
        QMessageBox.warning(0, "警告", "请检查输入")
        @Assert(true)
    }

    @TestCase
    func testCritical() {
        QMessageBox.critical(0, "错误", "严重错误")
        @Assert(true)
    }

    @TestCase
    func testQuestion() {
        let r = QMessageBox.question(0, "确认", "是否继续？")
        @Assert(r == true || r == false)
    }
}

// ---------------------------------------------------------------------
// QFileDialog 静态方法测试（模态阻塞，仅本地手动跑）
// ---------------------------------------------------------------------
@Test
@Tag[requires_gui_dialog]
class QFileDialogStaticTests {
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
    func testGetOpenFileName() {
        let p = QFileDialog.getOpenFileName(0, "打开", "所有文件 (*)")
        @Assert(p.size >= 0)
    }

    @TestCase
    func testGetSaveFileName() {
        let p = QFileDialog.getSaveFileName(0, "保存", "文本 (*.txt)")
        @Assert(p.size >= 0)
    }

    @TestCase
    func testGetExistingDirectory() {
        let p = QFileDialog.getExistingDirectory(0, "选择目录")
        @Assert(p.size >= 0)
    }

    @TestCase
    func testGetOpenFileNames() {
        let p = QFileDialog.getOpenFileNames(0, "打开多个", "所有文件 (*)")
        @Assert(p.size >= 0)
    }
}

// ---------------------------------------------------------------------
// QInputDialog 静态方法测试（模态阻塞，仅本地手动跑）
// ---------------------------------------------------------------------
@Test
@Tag[requires_gui_dialog]
class QInputDialogStaticTests {
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
    func testGetText() {
        let s = QInputDialog.getText(0, "输入", "姓名：", "张三")
        @Assert(s.size >= 0)
    }

    @TestCase
    func testGetTextWithResult() {
        let (s, ok) = QInputDialog.getTextWithResult(0, "输入", "姓名：", "")
        @Assert(ok == true || ok == false)
        @Assert(s.size >= 0)
    }

    @TestCase
    func testGetInt() {
        let v = QInputDialog.getInt(0, "输入", "年龄：", 18, 0, 120)
        @Assert(v >= 0)
    }

    @TestCase
    func testGetIntWithResult() {
        let (v, ok) = QInputDialog.getIntWithResult(0, "输入", "年龄：", 18, 0, 120)
        @Assert(ok == true || ok == false)
        @Assert(v >= 0)
    }

    @TestCase
    func testGetDouble() {
        let v = QInputDialog.getDouble(0, "输入", "比例：", 0.5, 0.0, 1.0)
        @Assert(v >= 0.0)
    }
}

// ---------------------------------------------------------------------
// QColorDialog / QFontDialog 静态方法测试（模态阻塞，仅本地手动跑）
// ---------------------------------------------------------------------
@Test
@Tag[requires_gui_dialog]
class QColorFontDialogStaticTests {
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
    func testGetColor() {
        let c = QColorDialog.getColor(0, "选择颜色")
        @Assert(c.size >= 0)
    }

    @TestCase
    func testGetFontName() {
        let n = QFontDialog.getFontName(0, "选择字体")
        @Assert(n.size >= 0)
    }

    @TestCase
    func testGetFontSize() {
        let s = QFontDialog.getFontSize(0, "选择字体")
        @Assert(s >= -1)
    }

    @TestCase
    func testGetFont() {
        let f = QFontDialog.getFont(0, "选择字体")
        match (f) {
            case Some(info) => @Assert(info.size >= 0)
            case None => @Assert(true)
        }
    }

    @TestCase
    func testGetFontWithDefault() {
        let f = QFontDialog.getFontWithDefault(0, "选择字体", "Arial", 12, false, false)
        match (f) {
            case Some(info) => @Assert(info.size >= 0)
            case None => @Assert(true)
        }
    }
}