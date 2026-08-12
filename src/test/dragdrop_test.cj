package cjqt6.test

// =====================================================================
// 拖放模块测试（src/core/dragdrop.cj）
// 覆盖：DropActionCopy/Move/Link/Ignore 函数 + QMimeData + QDrag
//      + startTextDrag / startFileDrag 辅助函数
// 注意：QDrag.exec 会进入拖放事件循环阻塞，标注 @Tag[requires_gui_drag]
// =====================================================================

import cjqt6.core.*
import std.unittest.*

// ---------------------------------------------------------------------
// DropAction 常量函数测试
// ---------------------------------------------------------------------
@Test
class DropActionTests {
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
    func testCopyAction() {
        // Qt::CopyAction = 1
        @Expect(DropActionCopy(), 1)
    }

    @TestCase
    func testMoveAction() {
        // Qt::MoveAction = 2
        @Expect(DropActionMove(), 2)
    }

    @TestCase
    func testLinkAction() {
        // Qt::LinkAction = 4
        @Expect(DropActionLink(), 4)
    }

    @TestCase
    func testIgnoreAction() {
        // Qt::IgnoreAction = 0
        @Expect(DropActionIgnore(), 0)
    }

    @TestCase
    func testDistinctValues() {
        @Expect(DropActionCopy() != DropActionMove(), true)
        @Expect(DropActionMove() != DropActionLink(), true)
        @Expect(DropActionCopy() != DropActionIgnore(), true)
    }
}

// ---------------------------------------------------------------------
// QMimeData 测试
// ---------------------------------------------------------------------
@Test
class QMimeDataTests {
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
        let m = QMimeData()
        @Assert(m.getPtr() != 0)
        @Expect(m.hasText(), false)
        @Expect(m.hasHtml(), false)
        @Expect(m.hasUrls(), false)
        @Expect(m.hasImage(), false)
        m.delete()
    }

    @TestCase
    func testSetTextAndRetrieve() {
        let m = QMimeData()
        m.setText("hello world")
        @Expect(m.hasText(), true)
        @Expect(m.text(), "hello world")
        m.delete()
    }

    @TestCase
    func testSetHtmlAndRetrieve() {
        let m = QMimeData()
        m.setHtml("<b>bold</b>")
        @Expect(m.hasHtml(), true)
        @Expect(m.html(), "<b>bold</b>")
        m.delete()
    }

    @TestCase
    func testSetTextAndHtmlCombined() {
        let m = QMimeData()
        m.setText("plain")
        m.setHtml("<i>rich</i>")
        @Expect(m.hasText(), true)
        @Expect(m.hasHtml(), true)
        @Expect(m.text(), "plain")
        @Expect(m.html(), "<i>rich</i>")
        m.delete()
    }

    @TestCase
    func testUrlsCountEmpty() {
        let m = QMimeData()
        @Expect(m.urlsCount(), 0)
        m.delete()
    }

    @TestCase
    func testClear() {
        let m = QMimeData()
        m.setText("x")
        m.setHtml("y")
        @Expect(m.hasText(), true)
        m.clear()
        @Expect(m.hasText(), false)
        @Expect(m.hasHtml(), false)
        m.delete()
    }

    @TestCase
    func testDoubleDelete() {
        let m = QMimeData()
        m.delete()
        m.delete()  // 安全
        @Assert(true)
    }

    @TestCase
    func testCreateFromPtrNoOwnership() {
        // 创建一个 QMimeData，再用其指针构造一个不拥有的实例
        let original = QMimeData()
        original.setText("data")
        let nonOwning = QMimeData(original.getPtr(), false)
        @Expect(nonOwning.text(), "data")
        // 不拥有的实例 delete 不释放底层
        nonOwning.delete()
        // 原实例仍有效
        @Expect(original.text(), "data")
        original.delete()
        @Assert(true)
    }
}

// ---------------------------------------------------------------------
// QDrag 测试（不调用 exec，避免阻塞）
// ---------------------------------------------------------------------
@Test
class QDragTests {
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
        let d = QDrag(0)
        @Assert(d.getPtr() != 0)
        // QDrag 没有 close/delete API，靠 GC（桥接层 QDrag 由 parent 管理）
        @Assert(true)
    }

    @TestCase
    func testSetMimeData() {
        let d = QDrag(0)
        let m = QMimeData()
        m.setText("drag content")
        d.setMimeData(m)
        m.delete()
        @Assert(true)
    }

    @TestCase
    func testSetPixmap() {
        let d = QDrag(0)
        d.setPixmap(0)
        @Assert(true)
    }

    @TestCase
    func testSetHotSpot() {
        let d = QDrag(0)
        d.setHotSpot(10, 20)
        @Assert(true)
    }

    @TestCase
    func testSource() {
        let d = QDrag(0)
        @Expect(d.source(), 0)
    }

    @TestCase
    func testTarget() {
        let d = QDrag(0)
        // 未开始拖放时 target 为 0
        @Expect(d.target(), 0)
    }

    @TestCase
    func testCancelStatic() {
        QDrag.cancel()
        @Assert(true)
    }
}

// ---------------------------------------------------------------------
// QDrag.exec 测试（阻塞，标注 requires_gui_drag）
// ---------------------------------------------------------------------
@Test
@Tag[requires_gui_drag]
class QDragExecTests {
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
        let d = QDrag(0)
        let r = d.exec(DropActionCopy())
        @Expect(r, DropActionIgnore())
    }

    @TestCase
    func testExecWithDefault() {
        let d = QDrag(0)
        let r = d.exec(DropActionCopy(), DropActionCopy())
        @Expect(r, DropActionIgnore())
    }
}

// ---------------------------------------------------------------------
// 拖放辅助函数测试（会调用 exec 阻塞，标注 requires_gui_drag）
// ---------------------------------------------------------------------
@Test
@Tag[requires_gui_drag]
class DragHelperTests {
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
    func testStartTextDrag() {
        let r = startTextDrag(0, "drag text", DropActionCopy())
        @Expect(r, DropActionIgnore())
    }

    @TestCase
    func testStartFileDrag() {
        let r = startFileDrag(0, "C:\\tmp\\file.txt", DropActionMove())
        @Expect(r, DropActionIgnore())
    }
}