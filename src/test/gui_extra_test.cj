package cjqt6.test

import cjqt6.core.*
import cjqt6.gui.*
import cjqt6.paint.*
import std.math.*
import std.unittest.*

// =====================================================================
// 全局状态（CFunc 回调不捕获局部变量，只能用全局变量）
// =====================================================================
var gHighlightCalled: Bool = false

func highlightCallback(selfId: Int64, text: CString): Unit {
    gHighlightCalled = true
}

// CFunc 必须用 lambda 显式标注参数类型（参考 src/core/callback.cj 的 gVoidDispatcher 模式）
let gHighlightCb: CFunc<(Int64, CString) -> Unit> = { selfId: Int64, text: CString =>
    gHighlightCalled = true
}

// =====================================================================
// QCursor 测试
// =====================================================================
@Test
class QCursorTests {
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
        let cur = QCursor()
        @Expect(cur.getPtr() != 0, true)
        // Qt 默认光标为箭头
        @Expect(cur.shape(), CursorShape.arrow())
        cur.close()
    }

    @TestCase
    func testCreateWithShape() {
        let cur = QCursor(CursorShape.pointingHand())
        @Expect(cur.getPtr() != 0, true)
        @Expect(cur.shape(), CursorShape.pointingHand())
        cur.close()
    }

    @TestCase
    func testSetShape() {
        let cur = QCursor()
        cur.setShape(CursorShape.cross())
        @Expect(cur.shape(), CursorShape.cross())
        cur.setShape(CursorShape.waitCursor())
        @Expect(cur.shape(), CursorShape.waitCursor())
        cur.close()
    }

    @TestCase
    func testShapeConstants() {
        @Expect(CursorShape.arrow(), 0)
        @Expect(CursorShape.iBeam(), 4)
        @Expect(CursorShape.sizeAll(), 9)
        @Expect(CursorShape.blank(), 10)
        @Expect(CursorShape.forbidden(), 14)
        @Expect(CursorShape.dragCopy(), 19)
    }

    @TestCase
    func testGlobalPos() {
        // 仅验证静态方法可调用（不崩溃），不依赖具体坐标值
        QCursor.setPos(100, 100)
        @Assert(true)
    }

    @TestCase
    func testPosXPosY() {
        let x = QCursor.posX()
        let y = QCursor.posY()
        // 屏幕坐标通常为正或 0
        @Expect(x >= -10000, true)
        @Expect(y >= -10000, true)
    }

    @TestCase
    func testDoubleClose() {
        let cur = QCursor()
        cur.close()
        cur.close()  // 安全
        @Expect(cur.getPtr(), 0)
    }

    @TestCase
    func testOperationsAfterClose() {
        let cur = QCursor()
        cur.close()
        @ExpectThrows[ResourceDisposedException](cur.shape())
        @ExpectThrows[ResourceDisposedException](cur.setShape(CursorShape.arrow()))
    }
}

// =====================================================================
// QFontMetrics 测试
// =====================================================================
@Test
class QFontMetricsTests {
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
        let font = QFont("Arial", 12)
        let fm = QFontMetrics(font.getPtr())
        @Expect(fm.getPtr() != 0, true)
        fm.close()
        font.delete()
    }

    @TestCase
    func testHeights() {
        let font = QFont("Arial", 12)
        let fm = QFontMetrics(font.getPtr())
        @Expect(fm.height() > 0, true)
        @Expect(fm.ascent() > 0, true)
        @Expect(fm.descent() >= 0, true)
        @Expect(fm.leading() >= 0, true)
        @Expect(fm.lineSpacing() > 0, true)
        fm.close()
        font.delete()
    }

    @TestCase
    func testWidths() {
        let font = QFont("Arial", 12)
        let fm = QFontMetrics(font.getPtr())
        @Expect(fm.averageCharWidth() >= 0, true)
        @Expect(fm.maxWidth() >= 0, true)
        @Expect(fm.horizontalAdvance("Hello") > 0, true)
        fm.close()
        font.delete()
    }

    @TestCase
    func testHorizontalAdvanceMonotonic() {
        let font = QFont("Arial", 12)
        let fm = QFontMetrics(font.getPtr())
        // 更长文本宽度更大
        let w1 = fm.horizontalAdvance("A")
        let w2 = fm.horizontalAdvance("AAAA")
        @Expect(w2 >= w1, true)
        fm.close()
        font.delete()
    }

    @TestCase
    func testFontFamily() {
        let font = QFont("Arial", 12)
        let fm = QFontMetrics(font.getPtr())
        @Expect(fm.fontFamily().size > 0, true)
        fm.close()
        font.delete()
    }

    @TestCase
    func testOperationsAfterClose() {
        let font = QFont("Arial", 12)
        let fm = QFontMetrics(font.getPtr())
        fm.close()
        @ExpectThrows[ResourceDisposedException](fm.height())
        @ExpectThrows[ResourceDisposedException](fm.ascent())
        font.delete()
    }
}

// =====================================================================
// QFontInfo 测试
// =====================================================================
@Test
class QFontInfoTests {
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
        let font = QFont("Arial", 12)
        let info = QFontInfo(font.getPtr())
        @Expect(info.getPtr() != 0, true)
        info.close()
        font.delete()
    }

    @TestCase
    func testFamily() {
        let font = QFont("Arial", 12)
        let info = QFontInfo(font.getPtr())
        @Expect(info.family().size > 0, true)
        info.close()
        font.delete()
    }

    @TestCase
    func testPointSize() {
        let font = QFont("Arial", 12)
        let info = QFontInfo(font.getPtr())
        @Expect(info.pointSize() > 0, true)
        @Expect(info.pointSizeF() > 0.0, true)
        info.close()
        font.delete()
    }

    @TestCase
    func testPixelSize() {
        let font = QFont("Arial", 12)
        let info = QFontInfo(font.getPtr())
        @Expect(info.pixelSize() > 0, true)
        info.close()
        font.delete()
    }

    @TestCase
    func testStyles() {
        let font = QFont("Arial", 12)
        font.setBold(true)
        font.setItalic(true)
        let info = QFontInfo(font.getPtr())
        @Expect(info.bold(), true)
        @Expect(info.italic(), true)
        @Expect(info.underline(), false)
        @Expect(info.strikeOut(), false)
        info.close()
        font.delete()
    }

    @TestCase
    func testWeight() {
        let font = QFont("Arial", 12)
        font.setBold(true)
        let info = QFontInfo(font.getPtr())
        @Expect(info.weight() >= 400, true)
        info.close()
        font.delete()
    }

    @TestCase
    func testOperationsAfterClose() {
        let font = QFont("Arial", 12)
        let info = QFontInfo(font.getPtr())
        info.close()
        @ExpectThrows[ResourceDisposedException](info.family())
        @ExpectThrows[ResourceDisposedException](info.pointSize())
        font.delete()
    }
}

// =====================================================================
// QIcon 测试
// =====================================================================
@Test
class QIconTests {
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
        let icon = QIcon()
        @Expect(icon.getPtr() != 0, true)
        @Expect(icon.isNull(), true)
        icon.close()
    }

    @TestCase
    func testCreateFromFileMissing() {
        // 不存在的文件 → 空图标，但不崩溃
        let icon = QIcon("C:/nonexistent/icon.png")
        @Expect(icon.getPtr() != 0, true)
        icon.close()
    }

    @TestCase
    func testAddFileMissing() {
        let icon = QIcon()
        icon.addFile("C:/nonexistent/icon.png")
        @Assert(true)
        icon.close()
    }

    @TestCase
    func testDeleteCompatibility() {
        let icon = QIcon()
        @Expect(icon.isNull(), true)
        icon.delete()
        @Expect(icon.getPtr(), 0)
    }

    @TestCase
    func testOperationsAfterClose() {
        let icon = QIcon()
        icon.close()
        @ExpectThrows[ResourceDisposedException](icon.isNull())
        @ExpectThrows[ResourceDisposedException](icon.addFile("C:/x.png"))
    }
}

// =====================================================================
// QPalette 测试
// =====================================================================
@Test
class QPaletteTests {
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

    // Qt 标准枚举值：ColorGroup: Active=0, Disabled=1, Inactive=2
    // ColorRole: Window=0, WindowText=1, Base=2, Text=6, Button=7, Highlight=15
    static let GroupActive: Int32 = 0
    static let RoleWindow: Int32 = 0
    static let RoleButton: Int32 = 7
    static let RoleHighlight: Int32 = 15

    @TestCase
    func testCreate() {
        let pal = QPalette()
        @Expect(pal.getPtr() != 0, true)
        pal.close()
    }

    @TestCase
    func testDefaultColorNonZero() {
        let pal = QPalette()
        let c = pal.color(QPaletteTests.GroupActive, QPaletteTests.RoleWindow)
        // 默认调色板窗口色应为有效 ARGB（非 0）
        @Expect(c != 0, true)
        pal.close()
    }

    @TestCase
    func testSetColor() {
        let pal = QPalette()
        pal.setColor(QPaletteTests.GroupActive, QPaletteTests.RoleButton, 255, 0, 0, 255)
        let c = pal.color(QPaletteTests.GroupActive, QPaletteTests.RoleButton)
        @Expect(c != 0, true)
        pal.close()
    }

    @TestCase
    func testSetColorChangesValue() {
        let pal = QPalette()
        let before = pal.color(QPaletteTests.GroupActive, QPaletteTests.RoleHighlight)
        pal.setColor(QPaletteTests.GroupActive, QPaletteTests.RoleHighlight, 0, 0, 255, 255)
        let after = pal.color(QPaletteTests.GroupActive, QPaletteTests.RoleHighlight)
        @Expect(after != before, true)
        pal.close()
    }

    @TestCase
    func testSetColorDisabledGroup() {
        let pal = QPalette()
        pal.setColor(1, QPaletteTests.RoleWindow, 128, 128, 128, 255)
        let c = pal.color(1, QPaletteTests.RoleWindow)
        @Expect(c != 0, true)
        pal.close()
    }

    @TestCase
    func testDoubleClose() {
        let pal = QPalette()
        pal.close()
        pal.close()
        @Expect(pal.getPtr(), 0)
    }

    @TestCase
    func testOperationsAfterClose() {
        let pal = QPalette()
        pal.close()
        @ExpectThrows[ResourceDisposedException](pal.color(QPaletteTests.GroupActive, QPaletteTests.RoleWindow))
        @ExpectThrows[ResourceDisposedException](pal.setColor(QPaletteTests.GroupActive, QPaletteTests.RoleWindow, 0, 0, 0, 255))
    }
}

// =====================================================================
// QStyleHelper 测试（静态方法）
// =====================================================================
@Test
class QStyleHelperTests {
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
    func testApplicationStyle() {
        let stylePtr = QStyleHelper.applicationStyle()
        @Expect(stylePtr != 0, true)
    }

    @TestCase
    func testWidgetStyle() {
        let w = QWidget()
        let stylePtr = QStyleHelper.widgetStyle(w.getPtr())
        @Expect(stylePtr != 0, true)
        w.close()
    }

    @TestCase
    func testPixelMetric() {
        let stylePtr = QStyleHelper.applicationStyle()
        let size = QStyleHelper.pixelMetric(stylePtr, PixelMetric.buttonIconSize())
        @Expect(size > 0, true)
    }

    @TestCase
    func testWidgetPixelMetric() {
        let w = QWidget()
        let size = QStyleHelper.widgetPixelMetric(w.getPtr(), PixelMetric.smallIconSize())
        @Expect(size > 0, true)
        w.close()
    }

    @TestCase
    func testConvenienceSizes() {
        let w = QWidget()
        @Expect(QStyleHelper.buttonIconSize(w.getPtr()) > 0, true)
        @Expect(QStyleHelper.smallIconSize(w.getPtr()) > 0, true)
        @Expect(QStyleHelper.largeIconSize(w.getPtr()) > 0, true)
        w.close()
    }

    @TestCase
    func testStandardIcon() {
        let stylePtr = QStyleHelper.applicationStyle()
        let iconPtr = QStyleHelper.standardIcon(stylePtr, StyleStandardIcon.infoIcon())
        // 标准图标应由 QApplication 样式提供（共享图标，不 delete）
        @Expect(iconPtr != 0, true)
    }

    @TestCase
    func testWidgetStandardIcon() {
        let w = QWidget()
        let iconPtr = QStyleHelper.widgetStandardIcon(w.getPtr(), StyleStandardIcon.warningIcon())
        @Expect(iconPtr != 0, true)
        w.close()
    }
}

// =====================================================================
// QSyntaxHighlighter 测试
// =====================================================================
@Test
class QSyntaxHighlighterTests {
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
        let doc = QTextDocument("hello")
        let hl = QSyntaxHighlighter(doc.getPtr())
        @Expect(hl.getPtr() != 0, true)
        hl.close()
        doc.close()
    }

    @TestCase
    func testDocumentPointer() {
        let doc = QTextDocument("hello")
        let hl = QSyntaxHighlighter(doc.getPtr())
        @Expect(hl.document(), doc.getPtr())
        hl.close()
        doc.close()
    }

    @TestCase
    func testSetOnHighlight() {
        gHighlightCalled = false
        let doc = QTextDocument("line one\nline two")
        let hl = QSyntaxHighlighter(doc.getPtr())
        hl.setOnHighlight(gHighlightCb)
        hl.rehighlight()
        @Expect(gHighlightCalled, true)
        hl.close()
        doc.close()
    }

    @TestCase
    func testSetFormat() {
        let doc = QTextDocument("hello world")
        let hl = QSyntaxHighlighter(doc.getPtr())
        let color = QColor(255, 0, 0)
        hl.setFormat(0, 5, color.getPtr())
        hl.setFormat(0, 5, color.getPtr(), true, false, false)
        @Assert(true)
        color.delete()
        hl.close()
        doc.close()
    }

    @TestCase
    func testRehighlight() {
        let doc = QTextDocument("abc")
        let hl = QSyntaxHighlighter(doc.getPtr())
        hl.setOnHighlight(gHighlightCb)
        gHighlightCalled = false
        hl.rehighlight()
        @Expect(gHighlightCalled, true)
        hl.close()
        doc.close()
    }

    @TestCase
    func testOperationsAfterClose() {
        let doc = QTextDocument("x")
        let hl = QSyntaxHighlighter(doc.getPtr())
        hl.close()
        @ExpectThrows[ResourceDisposedException](hl.document())
        @ExpectThrows[ResourceDisposedException](hl.rehighlight())
        doc.close()
    }
}

// =====================================================================
// QTextDocument 测试
// =====================================================================
@Test
class QTextDocumentTests {
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
    func testCreateEmpty() {
        let doc = QTextDocument()
        @Expect(doc.getPtr() != 0, true)
        @Expect(doc.isEmpty(), true)
        doc.close()
    }

    @TestCase
    func testCreateWithText() {
        let doc = QTextDocument("hello")
        @Expect(doc.toPlainText(), "hello")
        @Expect(doc.isEmpty(), false)
        doc.close()
    }

    @TestCase
    func testSetPlainText() {
        let doc = QTextDocument()
        doc.setPlainText("first line\nsecond line")
        @Expect(doc.toPlainText(), "first line\nsecond line")
        doc.close()
    }

    @TestCase
    func testCounts() {
        let doc = QTextDocument("line1\nline2\nline3")
        @Expect(doc.blockCount() >= 3, true)
        @Expect(doc.lineCount() >= 3, true)
        @Expect(doc.characterCount() > 0, true)
        doc.close()
    }

    @TestCase
    func testModifiedState() {
        let doc = QTextDocument()
        @Expect(doc.isModified(), false)
        doc.setModified(true)
        @Expect(doc.isModified(), true)
        doc.setModified(false)
        @Expect(doc.isModified(), false)
        doc.close()
    }

    @TestCase
    func testHtmlRoundTrip() {
        let doc = QTextDocument()
        doc.setHtml("<b>bold</b>")
        let html = doc.toHtml()
        @Expect(html.size > 0, true)
        doc.close()
    }

    @TestCase
    func testClear() {
        let doc = QTextDocument("some text")
        doc.clear()
        @Expect(doc.isEmpty(), true)
        doc.close()
    }

    @TestCase
    func testDefaultFont() {
        let doc = QTextDocument()
        doc.setDefaultFont("Arial", 14)
        @Assert(true)
        doc.close()
    }

    @TestCase
    func testOperationsAfterClose() {
        let doc = QTextDocument("x")
        doc.close()
        @ExpectThrows[ResourceDisposedException](doc.toPlainText())
        @ExpectThrows[ResourceDisposedException](doc.setPlainText("y"))
        @ExpectThrows[ResourceDisposedException](doc.isEmpty())
        @ExpectThrows[ResourceDisposedException](doc.blockCount())
    }
}

// =====================================================================
// QTextCursor 测试
// =====================================================================
@Test
class QTextCursorTests {
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
        let doc = QTextDocument("hello")
        let cur = QTextCursor(doc)
        @Expect(cur.getPtr() != 0, true)
        @Expect(cur.isNull(), false)
        cur.close()
        doc.close()
    }

    @TestCase
    func testPosition() {
        let doc = QTextDocument("hello")
        let cur = QTextCursor(doc)
        @Expect(cur.position(), 0)
        cur.setPosition(2)
        @Expect(cur.position(), 2)
        cur.close()
        doc.close()
    }

    @TestCase
    func testInsertText() {
        let doc = QTextDocument("")
        let cur = QTextCursor(doc)
        cur.insertText("abc")
        @Expect(doc.toPlainText(), "abc")
        cur.close()
        doc.close()
    }

    @TestCase
    func testMovePosition() {
        let doc = QTextDocument("hello")
        let cur = QTextCursor(doc)
        let moved = cur.movePosition(MoveOperation.nextCharacter())
        @Expect(moved, true)
        @Expect(cur.position(), 1)
        cur.close()
        doc.close()
    }

    @TestCase
    func testSelectAndSelectedText() {
        let doc = QTextDocument("hello world")
        let cur = QTextCursor(doc)
        cur.setPosition(0)
        cur.movePositionEx(MoveOperation.nextWord(), MoveMode.keepAnchor(), 1)
        @Expect(cur.hasSelection(), true)
        @Expect(cur.selectedText().size > 0, true)
        cur.clearSelection()
        @Expect(cur.hasSelection(), false)
        cur.close()
        doc.close()
    }

    @TestCase
    func testDeleteChar() {
        let doc = QTextDocument("ab")
        let cur = QTextCursor(doc)
        cur.setPosition(0)
        cur.deleteChar()
        @Expect(doc.toPlainText(), "b")
        cur.close()
        doc.close()
    }

    @TestCase
    func testDeletePreviousChar() {
        let doc = QTextDocument("ab")
        let cur = QTextCursor(doc)
        cur.setPosition(1)
        cur.deletePreviousChar()
        @Expect(doc.toPlainText(), "b")
        cur.close()
        doc.close()
    }

    @TestCase
    func testInsertNewBlock() {
        let doc = QTextDocument("ab")
        let cur = QTextCursor(doc)
        cur.setPosition(1)
        cur.insertNewBlock()
        @Expect(doc.blockCount() >= 2, true)
        cur.close()
        doc.close()
    }

    @TestCase
    func testOperationsAfterClose() {
        let doc = QTextDocument("x")
        let cur = QTextCursor(doc)
        cur.close()
        @ExpectThrows[ResourceDisposedException](cur.position())
        @ExpectThrows[ResourceDisposedException](cur.insertText("y"))
        @ExpectThrows[ResourceDisposedException](cur.hasSelection())
        doc.close()
    }
}

// =====================================================================
// GUI 类型测试（纯数据结构，无需 QApplication）
// =====================================================================
@Test
class GuiTypesTests {

    @TestCase
    func testAlignment() {
        @Expect(Alignment.Center.isCenter(), true)
        @Expect(Alignment.TopLeft.isHCenter(), false)
        @Expect(Alignment.TopLeft.has(Alignment.Left), true)
        @Expect(Alignment.Default.isVCenter(), true)
        let combined = Alignment.Left | Alignment.Top
        @Expect(combined.has(Alignment.Left), true)
        @Expect(combined.has(Alignment.Top), true)
    }

    @TestCase
    func testOrientation() {
        @Expect(Orientation.Horizontal.value(), 1)
        @Expect(Orientation.Vertical.value(), 2)
        @Expect(Orientation.fromValue(2).value(), 2)
        @Expect(Orientation.fromValue(99).value(), 1)
        @Expect(Orientation.Horizontal == Orientation.Horizontal, true)
        @Expect(Orientation.Horizontal != Orientation.Vertical, true)
    }

    @TestCase
    func testMargins() {
        let m = Margins(1, 2, 3, 4)
        @Expect(m.left, 1)
        @Expect(m.top, 2)
        @Expect(m.right, 3)
        @Expect(m.bottom, 4)
        let all = Margins(5, 5, 5, 5)
        @Expect(all.left, 5)
        @Expect(all.bottom, 5)
    }

    @TestCase
    func testPointSizeRect() {
        let p = Point(3, 4)
        @Expect(p.x, 3)
        @Expect(p.y, 4)
        let s = Size(10, 20)
        @Expect(s.width, 10)
        @Expect(s.height, 20)
        let r = Rect(0, 0, 10, 10)
        @Expect(r.left(), 0)
        @Expect(r.top(), 0)
        @Expect(r.right(), 10)
        @Expect(r.bottom(), 10)
        @Expect(r.center().x, 5)
        @Expect(r.center().y, 5)
    }

    @TestCase
    func testTickPosition() {
        @Expect(TickPosition.NoTicks, 0)
        @Expect(TickPosition.TicksAbove, 1)
        @Expect(TickPosition.TicksBelow, 2)
        @Expect(TickPosition.TicksBothSides, 5)
    }

    @TestCase
    func testFrameConstants() {
        @Expect(FrameShape.NoFrame, 0)
        @Expect(FrameShape.Box, 1)
        @Expect(FrameShape.Panel, 2)
        @Expect(FrameShape.StyledPanel, 6)
        @Expect(FrameShadow.Plain, 16)
        @Expect(FrameShadow.Raised, 32)
        @Expect(FrameShadow.Sunken, 48)
    }
}
