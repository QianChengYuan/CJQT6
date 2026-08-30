package cjqt6.test

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import cjqt6.paint.*
import std.math.*
import std.unittest.*

// =====================================================================
// 全局状态（CFunc 回调不捕获局部变量，只能用全局变量）
// =====================================================================
var gSbValue: Int32 = -1
let gSbValueCb: Int32Callback = { v: Int32 =>
    gSbValue = v
}

var gStackIndex: Int32 = -1
let gStackIndexCb: Int32Callback = { v: Int32 =>
    gStackIndex = v
}

var gToolBoxIndex: Int32 = -1
let gToolBoxIndexCb: Int32Callback = { v: Int32 =>
    gToolBoxIndex = v
}

var gTabIndex: Int32 = -1
let gTabIndexCb: Int32Callback = { v: Int32 =>
    gTabIndex = v
}

var gBgClickedId: Int64 = 0
let gBgClickedCb: Int64Callback = { v: Int64 =>
    gBgClickedId = v
}

var gDlgAccepted: Bool = false
let gDlgAcceptedCb: VoidCallback = { =>
    gDlgAccepted = true
}

var gKeySeq: String = ""
let gKeySeqCb: CStringCallback = { v: CString =>
    gKeySeq = v.toString()
}

// =====================================================================
// QButtonGroup 测试
// =====================================================================
@Test
class QButtonGroupTests {
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
        let bg = QButtonGroup()
        @Expect(bg.getPtr() != 0, true)
        bg.delete()
    }

    @TestCase
    func testAddButtonAndCount() {
        let bg = QButtonGroup()
        let rb1 = QRadioButton()
        let rb2 = QRadioButton()
        bg.addButton(rb1.getPtr(), 1)
        bg.addButton(rb2.getPtr(), 2)
        @Expect(bg.buttonsCount(), 2)
        bg.removeButton(rb2.getPtr())
        @Expect(bg.buttonsCount(), 1)
        bg.delete()
        rb1.close()
        rb2.close()
    }

    @TestCase
    func testCheckedId() {
        let bg = QButtonGroup()
        let rb1 = QRadioButton()
        let rb2 = QRadioButton()
        bg.addButton(rb1.getPtr(), 1)
        bg.addButton(rb2.getPtr(), 2)
        @Expect(bg.checkedId(), -1)  // 默认无选中
        rb1.setChecked(true)
        @Expect(bg.checkedId(), 1)
        @Expect(bg.checkedButton(), rb1.getPtr())
        @Expect(bg.button(2), rb2.getPtr())
        bg.delete()
        rb1.close()
        rb2.close()
    }

    @TestCase
    func testSetId() {
        let bg = QButtonGroup()
        let rb = QRadioButton()
        bg.addButton(rb.getPtr(), 1)
        bg.setId(rb.getPtr(), 20)
        @Expect(bg.id(rb.getPtr()), 20)
        @Expect(bg.checkedId(), -1)
        bg.delete()
        rb.close()
    }

    @TestCase
    func testExclusive() {
        let bg = QButtonGroup()
        @Expect(bg.isExclusive(), true)  // 默认互斥
        bg.setExclusive(false)
        @Expect(bg.isExclusive(), false)
        bg.delete()
    }

    @TestCase
    func testCallback() {
        let bg = QButtonGroup()
        bg.setOnButtonClicked(gBgClickedCb)
        @Assert(bg.getPtr() != 0)
        bg.delete()
    }
}

// =====================================================================
// QCommandLinkButton 测试
// =====================================================================
@Test
class QCommandLinkButtonTests {
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
        let btn = QCommandLinkButton()
        @Expect(btn.getPtr() != 0, true)
        btn.delete()
    }

    @TestCase
    func testDescription() {
        let btn = QCommandLinkButton()
        btn.setText("标题")
        btn.setDescription("描述文字")
        @Expect(btn.description(), "描述文字")
        btn.delete()
    }

    @TestCase
    func testFlat() {
        let btn = QCommandLinkButton()
        btn.setFlat(true)
        @Expect(btn.isFlat(), true)
        btn.setFlat(false)
        @Expect(btn.isFlat(), false)
        btn.delete()
    }

    @TestCase
    func testEnabled() {
        let btn = QCommandLinkButton()
        btn.setEnabled(false)
        @Assert(btn.getPtr() != 0)
        btn.setEnabled(true)
        btn.delete()
    }
}

// =====================================================================
// QCompleter 测试
// =====================================================================
@Test
class QCompleterTests {
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
        let c = QCompleter()
        @Expect(c.getPtr() != 0, true)
        c.delete()
    }

    @TestCase
    func testFromArray() {
        let c = QCompleter.fromArray(["苹果", "香蕉", "樱桃"])
        @Expect(c.getPtr() != 0, true)
        c.setCompletionPrefix("苹")
        @Expect(c.completionCount() > 0, true)
        c.delete()
    }

    @TestCase
    func testCompletionMode() {
        let c = QCompleter("one\ntwo\nthree")
        c.setCompletionMode(CompletionMode.Inline)
        @Expect(c.completionMode(), CompletionMode.Inline)
        c.setCompletionMode(CompletionMode.Popup)
        @Expect(c.completionMode(), CompletionMode.Popup)
        c.delete()
    }

    @TestCase
    func testCaseSensitivity() {
        let c = QCompleter.fromArray(["Apple", "Banana"])
        c.setCaseSensitivity(false)
        @Expect(c.caseSensitivity(), 0)
        c.setCaseSensitivity(true)
        @Expect(c.caseSensitivity(), 1)
        c.delete()
    }

    @TestCase
    func testMaxVisibleItems() {
        let c = QCompleter.fromArray(["a", "b", "c", "d"])
        c.setMaxVisibleItems(3)
        @Expect(c.maxVisibleItems(), 3)
        c.delete()
    }
}

// =====================================================================
// QDialogButtonBox 测试
// =====================================================================
@Test
class QDialogButtonBoxTests {
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
        let box = QDialogButtonBox()
        @Expect(box.getPtr() != 0, true)
        box.delete()
    }

    @TestCase
    func testStandardButtons() {
        let box = QDialogButtonBox()
        box.setStandardButtons(makeStandardButtons([StandardButtons.Ok, StandardButtons.Cancel]))
        @Expect(box.standardButtons() != 0, true)
        let okPtr = box.button(StandardButtons.Ok)
        @Expect(okPtr != 0, true)
        @Expect(box.buttonRole(okPtr), ButtonRole.AcceptRole)
        box.delete()
    }

    @TestCase
    func testAddButton() {
        let box = QDialogButtonBox()
        box.addButton("自定义", ButtonRole.ActionRole)
        @Assert(box.getPtr() != 0)
        box.delete()
    }

    @TestCase
    func testCallback() {
        let box = QDialogButtonBox()
        box.setOnAccepted(gDlgAcceptedCb)
        @Assert(box.getPtr() != 0)
        box.delete()
    }
}

// =====================================================================
// QDockWidget 测试
// =====================================================================
@Test
class QDockWidgetTests {
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
        let dock = QDockWidget("停靠窗口")
        @Expect(dock.getPtr() != 0, true)
        dock.delete()
    }

    @TestCase
    func testSetWidget() {
        let dock = QDockWidget("停靠窗口")
        let inner = QLabel()
        dock.setWidget(inner.getPtr())
        @Expect(dock.widget(), inner.getPtr())
        inner.close()  // 先从 dock 移除，避免双重释放
        dock.delete()
    }

    @TestCase
    func testAllowedAreas() {
        let dock = QDockWidget("停靠窗口")
        dock.setAllowedAreas(DockWidgetArea.Left)
        @Expect(dock.allowedAreas(), DockWidgetArea.Left)
        dock.setAllowedAreas(DockWidgetArea.All)
        @Expect(dock.allowedAreas(), DockWidgetArea.All)
        dock.delete()
    }

    @TestCase
    func testFeatures() {
        let dock = QDockWidget("停靠窗口")
        dock.setFeatures(DockWidgetFeature.AllFeatures)
        @Expect(dock.features(), DockWidgetFeature.AllFeatures)
        dock.setFeatures(DockWidgetFeature.NoFeature)
        @Expect(dock.features(), DockWidgetFeature.NoFeature)
        dock.delete()
    }

    @TestCase
    func testFloating() {
        let dock = QDockWidget("停靠窗口")
        // Qt 语义：isFloating() 等价于 isWindow()；
        // 无父窗口的 QDockWidget 恒为顶层窗口，故 isFloating() 恒为 true
        @Expect(dock.isFloating(), true)
        dock.setFloating(true)
        @Expect(dock.isFloating(), true)
        // 无 QMainWindow 托管时 setFloating(false) 不改变 isWindow() 状态（Qt 6 行为）
        dock.setFloating(false)
        @Expect(dock.toggleViewAction() != 0, true)
        dock.delete()
    }
}

// =====================================================================
// QFontComboBox 测试
// =====================================================================
@Test
class QFontComboBoxTests {
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
        let fc = QFontComboBox()
        @Expect(fc.getPtr() != 0, true)
        fc.delete()
    }

    @TestCase
    func testCurrentFont() {
        let fc = QFontComboBox()
        fc.setCurrentFont("Arial")
        let fam = fc.currentFont()
        @Expect(fam != "", true)
        fc.delete()
    }

    @TestCase
    func testWritingSystem() {
        let fc = QFontComboBox()
        fc.setWritingSystem(FontWritingSystem.Any)
        @Expect(fc.writingSystem(), FontWritingSystem.Any)
        fc.setWritingSystem(FontWritingSystem.SimplifiedChinese)
        @Expect(fc.writingSystem(), FontWritingSystem.SimplifiedChinese)
        fc.delete()
    }

    @TestCase
    func testFontFilters() {
        let fc = QFontComboBox()
        fc.setFontFilters(FontFilters.MonospacedFonts)
        @Expect(fc.fontFilters(), FontFilters.MonospacedFonts)
        fc.delete()
    }
}

// =====================================================================
// QGraphicsOpacityEffect / QGraphicsDropShadowEffect 测试
// =====================================================================
@Test
class QGraphicsEffectTests {
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
    func testOpacityEffect() {
        let e = QGraphicsOpacityEffect()
        e.setOpacity(0.5)
        @Expect(abs(e.opacity() - 0.5) < 0.001, true)
        e.setEnabled(true)
        @Expect(abs(e.opacity() - 0.5) < 0.001, true)
        e.delete()
    }

    @TestCase
    func testOpacityChain() {
        let e = QGraphicsOpacityEffect()
        e.setOpacity(0.3).setEnabled(false)
        @Expect(abs(e.opacity() - 0.3) < 0.001, true)
        e.setOpacity(0.9)
        @Expect(abs(e.opacity() - 0.9) < 0.001, true)
        e.delete()
    }

    @TestCase
    func testDropShadowOffset() {
        let e = QGraphicsDropShadowEffect()
        e.setOffset(3.0, 4.0)
        @Expect(abs(e.xOffset() - 3.0) < 0.001, true)
        @Expect(abs(e.yOffset() - 4.0) < 0.001, true)
        e.setXOffset(1.5)
        e.setYOffset(2.5)
        @Expect(abs(e.xOffset() - 1.5) < 0.001, true)
        @Expect(abs(e.yOffset() - 2.5) < 0.001, true)
        e.delete()
    }

    @TestCase
    func testDropShadowBlurColor() {
        let e = QGraphicsDropShadowEffect()
        e.setBlurRadius(8.0)
        @Expect(abs(e.blurRadius() - 8.0) < 0.001, true)
        e.setColor(100, 50, 200, 128)
        e.setEnabled(true)
        @Expect(abs(e.blurRadius() - 8.0) < 0.001, true)
        e.delete()
    }
}

// =====================================================================
// QGraphicsItem 子类测试（矩形/椭圆/线段/文本/图像/路径/组）
// =====================================================================
@Test
class QGraphicsItemTests {
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
    func testRectItem() {
        let item = QGraphicsRectItem(0.0, 0.0, 100.0, 50.0)
        @Expect(item.getPtr() != 0, true)
        @Expect(item.itemType() > 0, true)
        item.setPos(10.0, 20.0)
        @Expect(abs(item.posX() - 10.0) < 0.001, true)
        @Expect(abs(item.posY() - 20.0) < 0.001, true)
        item.setRect(1.0, 2.0, 30.0, 40.0)
        @Expect(item.rect().contains("30"), true)
        item.setPen(255, 0, 0, 2)
        item.setBrush(0, 0, 255)
        item.close()
    }

    @TestCase
    func testEllipseItem() {
        let item = QGraphicsEllipseItem(0.0, 0.0, 80.0, 60.0)
        @Expect(item.getPtr() != 0, true)
        item.setStartAngle(0)
        item.setSpanAngle(90)
        item.setRect(5.0, 5.0, 50.0, 30.0)
        @Expect(item.rect().contains("50"), true)
        item.close()
    }

    @TestCase
    func testLineItem() {
        let item = QGraphicsLineItem(0.0, 0.0, 100.0, 100.0)
        @Expect(item.getPtr() != 0, true)
        item.setLine(1.0, 2.0, 3.0, 4.0)
        @Expect(item.line().contains("3"), true)
        item.setPen(0, 255, 0, 1)
        item.close()
    }

    @TestCase
    func testTextItem() {
        let item = QGraphicsTextItem("hello")
        @Expect(item.getPtr() != 0, true)
        @Expect(item.text(), "hello")
        item.setText("world")
        @Expect(item.text(), "world")
        item.setFont("Arial", 12.0, true)
        item.setDefaultTextColor(10, 20, 30)
        item.setTextWidth(200.0)
        item.close()
    }

    @TestCase
    func testPixmapItem() {
        let pm = QPixmap.withSize(20, 20)
        let item = QGraphicsPixmapItem()
        item.setPixmap(pm.getPtr())
        item.setOffset(1.0, 2.0)
        @Expect(item.getPtr() != 0, true)
        item.close()
        pm.delete()
    }

    @TestCase
    func testItemTransform() {
        let item = QGraphicsRectItem()
        item.setZValue(5.0)
        @Expect(item.zValue(), 5.0)
        item.setRotation(45.0)
        @Expect(abs(item.rotation() - 45.0) < 0.001, true)
        item.setScale(2.0)
        @Expect(item.scale(), 2.0)
        item.setEnabled(false)
        @Expect(item.isEnabled(), false)
        item.setOpacity(0.8)
        @Expect(abs(item.opacity() - 0.8) < 0.001, true)
        item.setVisible(true)
        @Expect(item.isVisible(), true)
        item.close()
    }

    @TestCase
    func testItemGroup() {
        let group = QGraphicsItemGroup()
        let r1 = QGraphicsRectItem()
        let r2 = QGraphicsRectItem()
        group.addToGroup(r1.getPtr())
        group.addToGroup(r2.getPtr())
        @Expect(group.getPtr() != 0, true)
        group.removeFromGroup(r2.getPtr())
        r1.close()
        r2.close()
        group.close()
    }
}

// =====================================================================
// QGraphicsScene / QGraphicsView 测试
// =====================================================================
@Test
class QGraphicsSceneViewTests {
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
    func testSceneCreate() {
        let scene = QGraphicsScene()
        @Expect(scene.getPtr() != 0, true)
        @Expect(scene.isValid(), true)
        scene.close()
        @Expect(scene.isClosed(), true)
    }

    @TestCase
    func testSceneAddRect() {
        let scene = QGraphicsScene()
        let itemPtr = scene.addRect(0.0, 0.0, 100.0, 50.0, 0, 0, 0, 1.0, 200, 200, 200)
        @Expect(itemPtr != 0, true)
        @Expect(scene.itemAt(10.0, 10.0) != 0, true)
        scene.setSceneRect(0.0, 0.0, 200.0, 200.0)
        @Expect(scene.sceneRect().contains("200"), true)
        scene.clear()
        scene.close()
    }

    @TestCase
    func testSceneAddText() {
        let scene = QGraphicsScene()
        let itemPtr = scene.addText("hello")
        @Expect(itemPtr != 0, true)
        scene.close()
    }

    @TestCase
    func testViewCreate() {
        let view = QGraphicsView()
        @Expect(view.getPtr() != 0, true)
        @Expect(view.isValid(), true)
        view.close()
    }

    @TestCase
    func testViewSetScene() {
        let scene = QGraphicsScene()
        let view = QGraphicsView()
        view.setScene(scene)
        @Expect(view.scene(), scene.getPtr())
        view.close()
        scene.close()
    }

    @TestCase
    func testViewMode() {
        let view = QGraphicsView()
        view.setDragMode(GraphicsViewDragMode.ScrollHandDrag)
        @Expect(view.dragMode(), GraphicsViewDragMode.ScrollHandDrag)
        view.setRenderHint(GraphicsViewRenderHint.Antialiasing, enabled: true)
        view.setRenderHints(GraphicsViewRenderHint.TextAntialiasing)
        view.setViewportUpdateMode(GraphicsViewViewportUpdateMode.SmartViewportUpdate)
        view.setInteractive(true)
        @Expect(view.isInteractive(), true)
        view.close()
    }

    @TestCase
    func testViewTransform() {
        let view = QGraphicsView()
        view.scale(2.0, 2.0)
        view.rotate(45.0)
        view.translate(10.0, 10.0)
        let mapped = view.mapToScene(0.0, 0.0)
        @Expect(mapped.contains(","), true)
        view.resetTransform()
        @Assert(view.getPtr() != 0)
        view.close()
    }

    @TestCase
    func testViewBackground() {
        let view = QGraphicsView()
        view.setBackgroundBrush(30, 30, 30)
        view.setForegroundBrush(255, 255, 255)
        view.setSceneRect(0.0, 0.0, 400.0, 300.0)
        view.centerOn(200.0, 150.0)
        view.fitInView(0.0, 0.0, 100.0, 100.0)
        @Assert(view.getPtr() != 0)
        view.close()
    }
}

// =====================================================================
// QKeySequenceEdit 测试
// =====================================================================
@Test
class QKeySequenceEditTests {
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
        let kse = QKeySequenceEdit()
        @Expect(kse.getPtr() != 0, true)
        kse.delete()
    }

    @TestCase
    func testSetKeySequence() {
        let kse = QKeySequenceEdit()
        kse.setKeySequence("Ctrl+C")
        let seq = kse.keySequence()
        // macOS NativeFormat 下 Qt::CTRL 显示为 "⌘" 而非 "Ctrl"，用字母键名做平台无关断言
        @Expect(seq.contains("C"), true)
        kse.delete()
    }

    @TestCase
    func testClear() {
        let kse = QKeySequenceEdit()
        kse.setKeySequence("Alt+Shift+X")
        kse.clear()
        let seq = kse.keySequence()
        @Expect(seq == "", true)
        kse.delete()
    }

    @TestCase
    func testCallback() {
        let kse = QKeySequenceEdit()
        kse.setOnKeySequenceChanged(gKeySeqCb)
        kse.setKeySequence("Ctrl+Z")
        // macOS NativeFormat 下 Qt::CTRL 显示为 "⌘" 而非 "Ctrl"，用字母键名做平台无关断言
        @Expect(gKeySeq.contains("Z"), true)
        kse.delete()
    }
}

// =====================================================================
// QMdiArea / QMdiSubWindow 测试
// =====================================================================
@Test
class QMdiAreaTests {
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
        let area = QMdiArea()
        @Expect(area.getPtr() != 0, true)
        area.delete()
    }

    @TestCase
    func testAddSubWindow() {
        let area = QMdiArea()
        let label = QLabel()
        let subPtr = area.addSubWindow(label.getPtr())
        @Expect(subPtr != 0, true)
        @Expect(area.subWindowCount(), 1)
        @Expect(area.currentSubWindow() != 0, true)
        label.close()
        area.delete()
    }

    @TestCase
    func testViewMode() {
        let area = QMdiArea()
        area.setViewMode(MdiAreaViewMode.TabbedView)
        @Expect(area.viewMode(), MdiAreaViewMode.TabbedView)
        area.setViewMode(MdiAreaViewMode.SubWindowView)
        @Expect(area.viewMode(), MdiAreaViewMode.SubWindowView)
        area.delete()
    }

    @TestCase
    func testActivationOrder() {
        let area = QMdiArea()
        area.setActivationOrder(MdiAreaActivationOrder.StackingOrder)
        @Expect(area.activationOrder(), MdiAreaActivationOrder.StackingOrder)
        area.setActivationOrder(MdiAreaActivationOrder.ActivationHistoryOrder)
        @Expect(area.activationOrder(), MdiAreaActivationOrder.ActivationHistoryOrder)
        area.delete()
    }

    @TestCase
    func testSubWindowOperations() {
        let area = QMdiArea()
        let label = QLabel()
        let subPtr = area.addSubWindow(label.getPtr())
        let sub = QMdiSubWindow(subPtr)
        @Expect(sub.getPtr() != 0, true)
        @Expect(sub.widget(), label.getPtr())
        sub.showShaded()
        @Assert(sub.getPtr() != 0)
        label.close()
        sub.delete()
        area.delete()
    }

    @TestCase
    func testTileCascade() {
        let area = QMdiArea()
        let l1 = QLabel()
        let l2 = QLabel()
        area.addSubWindow(l1.getPtr())
        area.addSubWindow(l2.getPtr())
        @Expect(area.subWindowCount(), 2)
        area.cascadeSubWindows()
        area.tileSubWindows()
        @Assert(area.getPtr() != 0)
        l1.close()
        l2.close()
        area.closeAllSubWindows()
        area.delete()
    }
}

// =====================================================================
// QPlainTextEdit 测试
// =====================================================================
@Test
class QPlainTextEditTests {
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
        let edit = QPlainTextEdit()
        @Expect(edit.getPtr() != 0, true)
        edit.delete()
    }

    @TestCase
    func testSetPlainText() {
        let edit = QPlainTextEdit()
        edit.setPlainText("第一行\n第二行")
        @Expect(edit.toPlainText(), "第一行\n第二行")
        @Expect(edit.lineCount() >= 2, true)
        edit.delete()
    }

    @TestCase
    func testAppend() {
        let edit = QPlainTextEdit()
        edit.setPlainText("hello")
        edit.appendPlainText("world")
        let text = edit.toPlainText()
        @Expect(text.contains("world"), true)
        edit.delete()
    }

    @TestCase
    func testReadOnly() {
        let edit = QPlainTextEdit()
        edit.setReadOnly(true)
        @Expect(edit.isReadOnly(), true)
        edit.setReadOnly(false)
        @Expect(edit.isReadOnly(), false)
        edit.delete()
    }

    @TestCase
    func testLineWrap() {
        let edit = QPlainTextEdit()
        edit.setLineWrapMode(PlainTextLineWrap.WidgetWidth)
        @Expect(edit.lineWrapMode(), PlainTextLineWrap.WidgetWidth)
        edit.setLineWrapMode(PlainTextLineWrap.NoWrap)
        @Expect(edit.lineWrapMode(), PlainTextLineWrap.NoWrap)
        edit.delete()
    }

    @TestCase
    func testClear() {
        let edit = QPlainTextEdit()
        edit.setPlainText("待清空")
        edit.clear()
        @Expect(edit.toPlainText(), "")
        edit.delete()
    }

    @TestCase
    func testModified() {
        let edit = QPlainTextEdit()
        edit.setModified(true)
        @Expect(edit.isModified(), true)
        edit.setModified(false)
        @Expect(edit.isModified(), false)
        edit.delete()
    }
}

// =====================================================================
// QRubberBand 测试
// =====================================================================
@Test
class QRubberBandTests {
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
        let parent = QWidget()
        let band = QRubberBand(RubberBandShape.Rectangle, parent)
        @Expect(band.getPtr() != 0, true)
        band.delete()
        parent.close()
    }

    @TestCase
    func testGeometry() {
        let parent = QWidget()
        let band = QRubberBand(RubberBandShape.Rectangle, parent)
        band.setGeometry(10, 20, 100, 50)
        @Expect(band.x(), 10)
        @Expect(band.y(), 20)
        @Expect(band.width(), 100)
        @Expect(band.height(), 50)
        band.move(30, 40)
        @Expect(band.x(), 30)
        band.resize(200, 100)
        @Expect(band.width(), 200)
        band.delete()
        parent.close()
    }

    @TestCase
    func testShape() {
        let parent = QWidget()
        // QRubberBand 的 shape 只能在构造时指定（Qt 无运行时 setter）
        let bandLine = QRubberBand(RubberBandShape.Line, parent)
        @Expect(bandLine.shape(), RubberBandShape.Line)
        bandLine.delete()
        let bandRect = QRubberBand(RubberBandShape.Rectangle, parent)
        @Expect(bandRect.shape(), RubberBandShape.Rectangle)
        bandRect.delete()
        parent.close()
    }
}

// =====================================================================
// QScrollBar 测试
// =====================================================================
@Test
class QScrollBarTests {
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
        let sb = QScrollBar(ScrollBarOrientation.Horizontal)
        @Expect(sb.getPtr() != 0, true)
        @Expect(sb.value(), 0)
        sb.delete()
    }

    @TestCase
    func testRange() {
        let sb = QScrollBar(ScrollBarOrientation.Vertical)
        sb.setRange(0, 100)
        @Expect(sb.minimum(), 0)
        @Expect(sb.maximum(), 100)
        sb.setMinimum(10)
        @Expect(sb.minimum(), 10)
        sb.setMaximum(200)
        @Expect(sb.maximum(), 200)
        sb.delete()
    }

    @TestCase
    func testValue() {
        let sb = QScrollBar(ScrollBarOrientation.Horizontal)
        sb.setRange(0, 100)
        sb.setValue(42)
        @Expect(sb.value(), 42)
        @Expect(sb.sliderPosition(), 42)
        sb.setSliderPosition(60)
        @Expect(sb.value(), 60)
        sb.delete()
    }

    @TestCase
    func testStep() {
        let sb = QScrollBar(ScrollBarOrientation.Horizontal)
        sb.setSingleStep(5)
        sb.setPageStep(10)
        @Assert(sb.getPtr() != 0)
        sb.delete()
    }

    @TestCase
    func testTracking() {
        let sb = QScrollBar(ScrollBarOrientation.Horizontal)
        @Expect(sb.isTracking(), true)  // 默认跟踪
        sb.setTracking(false)
        @Expect(sb.isTracking(), false)
        sb.delete()
    }

    @TestCase
    func testInverted() {
        let sb = QScrollBar(ScrollBarOrientation.Horizontal)
        sb.setInvertedAppearance(true)
        @Expect(sb.invertedAppearance(), true)
        sb.setInvertedControls(true)
        @Expect(sb.invertedControls(), true)
        sb.delete()
    }

    @TestCase
    func testOrientation() {
        let sb = QScrollBar(ScrollBarOrientation.Horizontal)
        sb.setOrientation(ScrollBarOrientation.Vertical)
        @Assert(sb.getPtr() != 0)
        sb.delete()
    }

    @TestCase
    func testValueChangedCallback() {
        let sb = QScrollBar(ScrollBarOrientation.Horizontal)
        sb.setOnValueChanged(gSbValueCb)
        sb.setRange(0, 100)
        sb.setValue(50)
        @Expect(gSbValue, 50)
        sb.delete()
    }

    @TestCase
    func testRepeatAction() {
        let sb = QScrollBar(ScrollBarOrientation.Horizontal)
        sb.setRepeatAction(ScrollBarRepeatAction.SingleStep)
        @Expect(sb.repeatAction(), ScrollBarRepeatAction.SingleStep)
        sb.triggerAction(ScrollBarRepeatAction.PageStep)
        @Assert(sb.getPtr() != 0)
        sb.delete()
    }
}

// =====================================================================
// QSizeGrip 测试
// =====================================================================
@Test
class QSizeGripTests {
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
        let parent = QWidget()
        let grip = QSizeGrip(parent)
        @Expect(grip.getPtr() != 0, true)
        grip.delete()
        parent.close()
    }

    @TestCase
    func testSetVisible() {
        let parent = QWidget()
        let grip = QSizeGrip(parent)
        grip.setVisible(true)
        grip.setVisible(false)
        @Assert(grip.getPtr() != 0)
        grip.delete()
        parent.close()
    }
}

// =====================================================================
// QStackedWidget 测试
// =====================================================================
@Test
class QStackedWidgetTests {
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
        let sw = QStackedWidget()
        @Expect(sw.getPtr() != 0, true)
        sw.delete()
    }

    @TestCase
    func testAddWidget() {
        let sw = QStackedWidget()
        let p1 = QLabel()
        let p2 = QLabel()
        let idx1 = sw.addWidget(p1.getPtr())
        let idx2 = sw.addWidget(p2.getPtr())
        @Expect(idx1, 0)
        @Expect(idx2, 1)
        @Expect(sw.count(), 2)
        @Expect(sw.currentIndex(), 0)
        p1.close()
        p2.close()
        sw.delete()
    }

    @TestCase
    func testSetCurrentIndex() {
        let sw = QStackedWidget()
        let p1 = QLabel()
        let p2 = QLabel()
        sw.addWidget(p1.getPtr())
        sw.addWidget(p2.getPtr())
        sw.setCurrentIndex(1)
        @Expect(sw.currentIndex(), 1)
        @Expect(sw.currentWidget(), p2.getPtr())
        @Expect(sw.widget(0), p1.getPtr())
        sw.setCurrentWidget(p1.getPtr())
        @Expect(sw.currentIndex(), 0)
        p1.close()
        p2.close()
        sw.delete()
    }

    @TestCase
    func testInsertRemove() {
        let sw = QStackedWidget()
        let p1 = QLabel()
        let p2 = QLabel()
        sw.addWidget(p1.getPtr())
        let idx = sw.insertWidget(0, p2.getPtr())
        @Expect(idx, 0)
        @Expect(sw.count(), 2)
        sw.removeWidget(p2.getPtr())
        @Expect(sw.count(), 1)
        p1.close()
        p2.close()
        sw.delete()
    }

    @TestCase
    func testCurrentChangedCallback() {
        let sw = QStackedWidget()
        sw.setOnCurrentChanged(gStackIndexCb)
        let p1 = QLabel()
        let p2 = QLabel()
        sw.addWidget(p1.getPtr())
        sw.addWidget(p2.getPtr())
        sw.setCurrentIndex(1)
        @Expect(gStackIndex, 1)
        p1.close()
        p2.close()
        sw.delete()
    }
}

// =====================================================================
// QSystemTrayIcon 测试
// =====================================================================
@Test
class QSystemTrayIconTests {
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
        let tray = QSystemTrayIcon()
        @Expect(tray.getPtr() != 0, true)
        tray.delete()
    }

    @TestCase
    func testToolTip() {
        let tray = QSystemTrayIcon()
        tray.setToolTip("托盘提示")
        tray.show()
        tray.hide()
        @Assert(tray.getPtr() != 0)
        tray.delete()
    }

    @TestCase
    func testShowMessage() {
        let tray = QSystemTrayIcon()
        tray.showMessage("标题", "消息内容", iconType: MessageIcon.Info, duration: 100)
        @Assert(tray.getPtr() != 0)
        tray.delete()
    }

    @TestCase
    func testSetIcon() {
        let tray = QSystemTrayIcon()
        tray.setIcon("")
        @Assert(tray.getPtr() != 0)
        tray.delete()
    }
}

// =====================================================================
// QTextBrowser 测试
// =====================================================================
@Test
class QTextBrowserTests {
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
        let tb = QTextBrowser()
        @Expect(tb.getPtr() != 0, true)
        tb.delete()
    }

    @TestCase
    func testSetText() {
        let tb = QTextBrowser()
        tb.setText("纯文本")
        @Expect(tb.toPlainText(), "纯文本")
        tb.delete()
    }

    @TestCase
    func testHtml() {
        let tb = QTextBrowser()
        tb.setHtml("<b>粗体</b>")
        let html = tb.toHtml()
        @Expect(html.contains("粗体"), true)
        tb.delete()
    }

    @TestCase
    func testOpenLinks() {
        let tb = QTextBrowser()
        @Expect(tb.isOpenLinks(), true)  // 默认打开链接
        tb.setOpenLinks(false)
        @Expect(tb.isOpenLinks(), false)
        tb.setOpenExternalLinks(true)
        @Expect(tb.isOpenExternalLinks(), true)
        tb.delete()
    }

    @TestCase
    func testSource() {
        let tb = QTextBrowser()
        tb.setSource("http://example.com") // cjlint-ignore !G.OTH.03 测试用示例URL
        let src = tb.source()
        @Expect(src.contains("example.com"), true)
        tb.delete()
    }

    @TestCase
    func testNavigation() {
        let tb = QTextBrowser()
        tb.setSource("page1")
        tb.setSource("page2")
        tb.backward()
        tb.forward()
        tb.home()
        tb.reload()
        tb.clearHistory()
        @Assert(tb.getPtr() != 0)
        tb.delete()
    }
}

// =====================================================================
// QToolBox 测试
// =====================================================================
@Test
class QToolBoxTests {
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
        let tb = QToolBox()
        @Expect(tb.getPtr() != 0, true)
        tb.delete()
    }

    @TestCase
    func testAddItem() {
        let tb = QToolBox()
        let p1 = QLabel()
        let p2 = QLabel()
        let idx1 = tb.addItem(p1.getPtr(), "页面一")
        let idx2 = tb.addItem(p2.getPtr(), "页面二")
        @Expect(idx1, 0)
        @Expect(idx2, 1)
        @Expect(tb.count(), 2)
        @Expect(tb.currentIndex(), 0)
        @Expect(tb.itemText(0), "页面一")
        p1.close()
        p2.close()
        tb.delete()
    }

    @TestCase
    func testSetCurrentIndex() {
        let tb = QToolBox()
        let p1 = QLabel()
        let p2 = QLabel()
        tb.addItem(p1.getPtr(), "一")
        tb.addItem(p2.getPtr(), "二")
        tb.setCurrentIndex(1)
        @Expect(tb.currentIndex(), 1)
        @Expect(tb.indexOf(p2.getPtr()), 1)
        tb.setCurrentWidget(p1.getPtr())
        @Expect(tb.currentIndex(), 0)
        p1.close()
        p2.close()
        tb.delete()
    }

    @TestCase
    func testItemEnabled() {
        let tb = QToolBox()
        let p = QLabel()
        tb.addItem(p.getPtr(), "页面")
        tb.setItemEnabled(0, false)
        @Expect(tb.isItemEnabled(0), false)
        tb.setItemEnabled(0, true)
        @Expect(tb.isItemEnabled(0), true)
        tb.setItemToolTip(0, "提示")
        tb.setItemIcon(0, "")
        p.close()
        tb.delete()
    }

    @TestCase
    func testCurrentChangedCallback() {
        let tb = QToolBox()
        tb.setOnCurrentChanged(gToolBoxIndexCb)
        let p1 = QLabel()
        let p2 = QLabel()
        tb.addItem(p1.getPtr(), "一")
        tb.addItem(p2.getPtr(), "二")
        tb.setCurrentIndex(1)
        @Expect(gToolBoxIndex, 1)
        p1.close()
        p2.close()
        tb.delete()
    }

    @TestCase
    func testInsertRemove() {
        let tb = QToolBox()
        let p1 = QLabel()
        let p2 = QLabel()
        tb.addItem(p1.getPtr(), "一")
        let idx = tb.insertItem(0, p2.getPtr(), "插入")
        @Expect(idx, 0)
        @Expect(tb.count(), 2)
        tb.removeItem(0)
        @Expect(tb.count(), 1)
        p1.close()
        p2.close()
        tb.delete()
    }
}

// =====================================================================
// QGroupBox 测试（containers）
// =====================================================================
@Test
class QGroupBoxTests {
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
        let box = QGroupBox()
        @Expect(box.getPtr() != 0, true)
        box.close()
    }

    @TestCase
    func testTitle() {
        let box = QGroupBox()
        box.setTitle("分组标题")
        @Expect(box.title(), "分组标题")
        box.close()
    }

    @TestCase
    func testCheckable() {
        let box = QGroupBox()
        @Expect(box.isCheckable(), false)
        box.setCheckable(true)
        @Expect(box.isCheckable(), true)
        box.setChecked(true)
        @Expect(box.isChecked(), true)
        box.setChecked(false)
        @Expect(box.isChecked(), false)
        box.close()
    }

    @TestCase
    func testFlat() {
        let box = QGroupBox()
        box.setFlat(true)
        @Expect(box.isFlat(), true)
        box.setFlat(false)
        @Expect(box.isFlat(), false)
        box.close()
    }
}

// =====================================================================
// QTabWidget 测试（containers）
// =====================================================================
@Test
class QTabWidgetTests {
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
        let tab = QTabWidget()
        @Expect(tab.getPtr() != 0, true)
        tab.close()
    }

    @TestCase
    func testAddTab() {
        let tab = QTabWidget()
        let p1 = QLabel()
        let p2 = QLabel()
        tab.addTab(p1.getPtr(), "标签一")
        tab.addTab(p2.getPtr(), "标签二")
        @Expect(tab.count(), 2)
        @Expect(tab.currentIndex(), 0)
        @Expect(tab.tabText(0), "标签一")
        p1.close()
        p2.close()
        tab.close()
    }

    @TestCase
    func testSetCurrentIndex() {
        let tab = QTabWidget()
        let p1 = QLabel()
        let p2 = QLabel()
        tab.addTab(p1.getPtr(), "一")
        tab.addTab(p2.getPtr(), "二")
        tab.setCurrentIndex(1)
        @Expect(tab.currentIndex(), 1)
        tab.setTabText(1, "修改")
        @Expect(tab.tabText(1), "修改")
        p1.close()
        p2.close()
        tab.close()
    }

    @TestCase
    func testInsertTab() {
        let tab = QTabWidget()
        let p1 = QLabel()
        let p2 = QLabel()
        tab.addTab(p1.getPtr(), "一")
        let idx = tab.insertTab(0, p2.getPtr(), "插入")
        @Expect(idx, 0)
        @Expect(tab.count(), 2)
        p1.close()
        p2.close()
        tab.close()
    }

    @TestCase
    func testTabsClosable() {
        let tab = QTabWidget()
        let p = QLabel()
        tab.addTab(p.getPtr(), "一")
        tab.setTabsClosable(true)
        tab.setMovable(true)
        @Assert(tab.getPtr() != 0)
        p.close()
        tab.close()
    }

    @TestCase
    func testCurrentChangedCallback() {
        let tab = QTabWidget()
        tab.setOnCurrentChanged(gTabIndexCb)
        let p1 = QLabel()
        let p2 = QLabel()
        tab.addTab(p1.getPtr(), "一")
        tab.addTab(p2.getPtr(), "二")
        tab.setCurrentIndex(1)
        @Expect(gTabIndex, 1)
        p1.close()
        p2.close()
        tab.close()
    }

    // 任务 3：图标/定位/文档模式方法测试
    @TestCase
    func testSetTabIcon() {
        let tab = QTabWidget()
        let p = QLabel()
        tab.addTab(p.getPtr(), "一")
        let icon = QIcon()  // 空图标，验证不崩溃
        tab.setTabIcon(0, icon.getPtr())
        @Assert(tab.getPtr() != 0)
        icon.close()
        p.close()
        tab.close()
    }

    @TestCase
    func testSetIconSize() {
        let tab = QTabWidget()
        tab.setIconSize(16, 16)
        @Assert(tab.getPtr() != 0)
        tab.close()
    }

    @TestCase
    func testSetTabPosition() {
        let tab = QTabWidget()
        tab.setTabPosition(1)  // South
        @Assert(tab.getPtr() != 0)
        tab.setTabPosition(2)  // West
        tab.close()
    }

    @TestCase
    func testSetDocumentMode() {
        let tab = QTabWidget()
        tab.setDocumentMode(true)
        @Assert(tab.getPtr() != 0)
        tab.close()
    }

    @TestCase
    func testSetElideMode() {
        let tab = QTabWidget()
        tab.setElideMode(2)  // ElideMiddle
        @Assert(tab.getPtr() != 0)
        tab.close()
    }

    @TestCase
    func testSetTabShape() {
        let tab = QTabWidget()
        tab.setTabShape(1)  // Triangular
        @Assert(tab.getPtr() != 0)
        tab.close()
    }

    @TestCase
    func testSetUsesScrollButtons() {
        let tab = QTabWidget()
        tab.setUsesScrollButtons(false)
        @Assert(tab.getPtr() != 0)
        tab.close()
    }
}

// =====================================================================
// QDate / QTime / QDateTime 测试
// =====================================================================
@Test
class QDateTimeTests {
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
    func testDateCreate() {
        let d = QDate(2024, 5, 20)
        @Expect(d.year(), 2024)
        @Expect(d.month(), 5)
        @Expect(d.day(), 20)
        @Expect(d.isValid(), true)
        d.delete()
    }

    @TestCase
    func testDateDefault() {
        let d = QDate()
        @Expect(d.year(), 1970)
        @Expect(d.month(), 1)
        @Expect(d.day(), 1)
        d.delete()
    }

    @TestCase
    func testDateToString() {
        let d = QDate(2024, 5, 20)
        @Expect(d.toString(), "2024-05-20")
        d.delete()
    }

    @TestCase
    func testDateSetDate() {
        let d = QDate()
        d.setDate(2023, 12, 25)
        @Expect(d.year(), 2023)
        @Expect(d.month(), 12)
        @Expect(d.day(), 25)
        d.delete()
    }

    @TestCase
    func testTimeCreate() {
        let t = QTime(13, 30, 45)
        @Expect(t.hour(), 13)
        @Expect(t.minute(), 30)
        @Expect(t.second(), 45)
        @Expect(t.isValid(), true)
        t.delete()
    }

    @TestCase
    func testTimeSetHMS() {
        let t = QTime()
        t.setHMS(8, 15, 30)
        @Expect(t.hour(), 8)
        @Expect(t.minute(), 15)
        @Expect(t.second(), 30)
        t.delete()
    }

    @TestCase
    func testTimeToString() {
        let t = QTime(9, 5, 7)
        @Expect(t.toString(), "09:05:07")
        t.delete()
    }

    @TestCase
    func testDateTimeCreate() {
        let d = QDate(2024, 1, 1)
        let t = QTime(10, 0, 0)
        let dt = QDateTime(d, t)
        @Expect(dt.getPtr() != 0, true)
        dt.delete()
    }

@TestCase
    func testDateTimeToString() {
        let d = QDate(2024, 1, 2)
        let t = QTime(3, 4, 5)
        let dt = QDateTime(d, t)
        @Expect(dt.toString(), "2024-01-02 03:04:05")
        dt.delete()
    }
}

// =====================================================================
// QCalendarWidget 测试
// =====================================================================

// 信号回调全局状态（CFunc 无法捕获局部变量）
var gCalClicked: String = ""
let gCalClickedCb: CStringCallback = { v: CString =>
    gCalClicked = v.toString()
}

var gCalActivated: String = ""
let gCalActivatedCb: CStringCallback = { v: CString =>
    gCalActivated = v.toString()
}

var gCalSelectionChanged: Bool = false
let gCalSelectionChangedCb: VoidCallback = { =>
    gCalSelectionChanged = true
}

@Test
class QCalendarWidgetTests {
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
    func testCalendarCreate() {
        let cal = QCalendarWidget()
        @Expect(cal.getPtr() != 0, true)
        cal.delete()
    }

    @TestCase
    func testCalendarSignals() {
        let cal = QCalendarWidget()
        cal.setOnClicked(gCalClickedCb)
        cal.setOnActivated(gCalActivatedCb)
        cal.setOnSelectionChanged(gCalSelectionChangedCb)
        @Expect(cal.getPtr() != 0, true)

        // 程序化改变选中日期，触发 selectionChanged 信号
        gCalSelectionChanged = false
        let d = QDate(2024, 5, 20)
        cal.setSelectedDate(d)
        @Expect(gCalSelectionChanged, true)

        d.delete()
        cal.delete()
    }
}

// =====================================================================
// QTextEdit 测试
// =====================================================================
// QTextEdit 信号回调全局状态（CFunc 无法捕获局部变量）
var gTeCursorPosChanged: Bool = false
let gTeCursorPosCb: VoidCallback = { =>
    gTeCursorPosChanged = true
}

var gTeSelectionChanged: Bool = false
let gTeSelectionCb: VoidCallback = { =>
    gTeSelectionChanged = true
}

// QTextEdit 测试
// =====================================================================
@Test
class QTextEditTests {
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
        let edit = QTextEdit()
        @Expect(edit.getPtr() != 0, true)
        edit.close()
    }

    @TestCase
    func testSetText() {
        let edit = QTextEdit()
        edit.setText("多行文本")
        @Expect(edit.text(), "多行文本")
        edit.close()
    }

    @TestCase
    func testPlainText() {
        let edit = QTextEdit()
        edit.setPlainText("纯文本")
        @Expect(edit.toPlainText(), "纯文本")
        edit.close()
    }

    @TestCase
    func testHtml() {
        let edit = QTextEdit()
        edit.setHtml("<b>粗体</b>")
        let html = edit.toHtml()
        @Expect(html.contains("粗体"), true)
        edit.close()
    }

    @TestCase
    func testAppend() {
        let edit = QTextEdit()
        edit.setText("第一行")
        edit.append("第二行")
        let text = edit.toPlainText()
        @Expect(text.contains("第二行"), true)
        edit.close()
    }

    @TestCase
    func testReadOnly() {
        let edit = QTextEdit()
        edit.setReadOnly(true)
        @Assert(edit.getPtr() != 0)
        edit.setReadOnly(false)
        @Assert(edit.getPtr() != 0)
        edit.close()
    }

    @TestCase
    func testLineWrap() {
        let edit = QTextEdit()
        edit.setLineWrapMode(1)
        @Expect(edit.lineWrapMode(), 1)
        edit.setLineWrapMode(0)
        @Expect(edit.lineWrapMode(), 0)
        edit.close()
    }

    @TestCase
    func testFindReplace() {
        let edit = QTextEdit()
        edit.setText("apple banana apple")
        @Expect(edit.find("banana", false), true)
        let count = edit.replaceAll("apple", "orange", false)
        @Expect(count >= 2, true)
        edit.close()
    }

    @TestCase
    func testFont() {
        let edit = QTextEdit()
        edit.setFontFamily("Arial")
        edit.setFontSize(14)
        edit.setFontBold(true)
        edit.setFontItalic(true)
        @Assert(edit.getPtr() != 0)
        edit.close()
    }

    @TestCase
    func testUndoRedo() {
        let edit = QTextEdit()
        edit.setPlainText("初始")
        // append 走撤销框架，setPlainText 会重置 undo 栈
        edit.append("追加")
        @Expect(edit.canUndo(), true)
        edit.undo()
        edit.redo()
        @Assert(edit.getPtr() != 0)
        edit.close()
    }

    @TestCase
    func testClear() {
        let edit = QTextEdit()
        edit.setText("待清空")
        edit.clear()
        @Expect(edit.toPlainText(), "")
        edit.close()
    }

    @TestCase
    func testCursor() {
        let edit = QTextEdit()
        edit.setText("第一行\n第二行")
        edit.goToLine(1)
        @Expect(edit.currentLine(), 1)
        @Expect(edit.lineCount() >= 2, true)
        @Expect(edit.characterCount() > 0, true)
        edit.close()
    }

    // 任务 5：setTabStopDistance/setAcceptRichText/setPlaceholderText
    @TestCase
    func testSetTabStopDistance() {
        let edit = QTextEdit()
        edit.setTabStopDistance(40.0)
        @Assert(edit.isValid())
        edit.close()
    }

    @TestCase
    func testSetAcceptRichText() {
        let edit = QTextEdit()
        edit.setAcceptRichText(false)
        @Assert(edit.isValid())
        edit.setAcceptRichText(true)
        edit.close()
    }

    @TestCase
    func testSetPlaceholderText() {
        let edit = QTextEdit()
        edit.setPlaceholderText("请输入内容...")
        @Assert(edit.isValid())
        edit.close()
    }

    @TestCase
    func testSetOnCursorPositionChanged() {
        let edit = QTextEdit()
        edit.setOnCursorPositionChanged(gTeCursorPosCb)
        @Assert(edit.isValid())
        // 程序化改变光标位置触发信号
        gTeCursorPosChanged = false
        edit.setText("hello")
        edit.close()
    }

    @TestCase
    func testSetOnSelectionChanged() {
        let edit = QTextEdit()
        edit.setOnSelectionChanged(gTeSelectionCb)
        @Assert(edit.isValid())
        // 程序化选中文本触发信号
        gTeSelectionChanged = false
        edit.setText("hello world")
        edit.close()
    }
}

// =====================================================================
// QFrame 测试（containers）
// =====================================================================
@Test
class QFrameTests {
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
        let frame = QFrame()
        @Expect(frame.getPtr() != 0, true)
        frame.close()
    }

    @TestCase
    func testFrameShape() {
        let frame = QFrame()
        frame.setFrameShape(1)  // FrameShape.Box
        @Expect(frame.frameShape(), 1)
        frame.setFrameShadow(48)  // FrameShadow.Sunken
        @Expect(frame.frameShadow(), 48)
        @Expect(frame.frameStyle() != 0, true)
        frame.close()
    }

    @TestCase
    func testLineWidth() {
        let frame = QFrame()
        frame.setFrameShape(1)  // FrameShape.Box：frameWidth = lineWidth + midLineWidth
        frame.setLineWidth(3)
        @Expect(frame.lineWidth(), 3)
        frame.setMidLineWidth(2)
        @Expect(frame.midLineWidth(), 2)
        @Expect(frame.frameWidth() > 0, true)
        frame.close()
    }
}

// =====================================================================
// QScrollArea 测试（containers）
// =====================================================================
@Test
class QScrollAreaTests {
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
        let sa = QScrollArea()
        @Expect(sa.getPtr() != 0, true)
        sa.close()
    }

    @TestCase
    func testSetWidget() {
        let sa = QScrollArea()
        let inner = QLabel()
        sa.setWidget(inner.getPtr())
        @Expect(sa.widget(), inner.getPtr())
        inner.close()
        sa.close()
    }

    @TestCase
    func testWidgetResizable() {
        let sa = QScrollArea()
        sa.setWidgetResizable(true)
        @Expect(sa.widgetResizable(), true)
        sa.setWidgetResizable(false)
        @Expect(sa.widgetResizable(), false)
        sa.close()
    }

    @TestCase
    func testTakeWidget() {
        let sa = QScrollArea()
        let inner = QLabel()
        sa.setWidget(inner.getPtr())
        let taken = sa.takeWidget()
        @Expect(taken, inner.getPtr())
        @Expect(sa.widget(), 0)
        inner.close()
        sa.close()
    }

    @TestCase
    func testScrollBarPolicy() {
        let sa = QScrollArea()
        sa.setHorizontalScrollBarPolicy(ScrollBarPolicy.ScrollBarAlwaysOff)
        sa.setVerticalScrollBarPolicy(ScrollBarPolicy.ScrollBarAlwaysOn)
        sa.ensureVisible(10, 10, 5, 5)
        @Assert(sa.getPtr() != 0)
        sa.close()
    }
}
