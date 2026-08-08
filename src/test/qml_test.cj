package cjqt6.test

import cjqt6.core.*
import cjqt6.qml.*
import std.unittest.*

// =====================================================================
// 全局回调状态（CFunc 回调不捕获局部变量，只能用全局变量）
// =====================================================================
var gItemXChanged: Int32 = 0
var gItemWidthChanged: Int32 = 0
var gItemOpacityChanged: Int32 = 0
var gItemVisibleChanged: Int32 = 0
var gItemFocusValue: Int32 = -1
var gItemParentPtr: Int64 = 0
var gWindowWidth: Int32 = -1
var gCompStatus: Int32 = -1

let gItemXChangedCb: VoidCallback = { => gItemXChanged += 1 }
let gItemWidthChangedCb: VoidCallback = { => gItemWidthChanged += 1 }
let gItemOpacityChangedCb: VoidCallback = { => gItemOpacityChanged += 1 }
let gItemVisibleChangedCb: VoidCallback = { => gItemVisibleChanged += 1 }
let gItemFocusChangedCb: Int32Callback = { v: Int32 => gItemFocusValue = v }
let gItemParentChangedCb: Int64Callback = { p: Int64 => gItemParentPtr = p }
let gWindowWidthCb: Int32Callback = { w: Int32 => gWindowWidth = w }
let gCompStatusCb: Int32Callback = { s: Int32 => gCompStatus = s }

// =====================================================================
// QQuickItem 测试
// =====================================================================
@Test
class QQuickItemTests {
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
    func testCreateOwned() {
        let item = QQuickItem.create()
        @Expect(item.getPtr() != 0, true)
        @Expect(item.isValid(), true)
        item.close()
        @Expect(item.isClosed(), true)
        @Expect(item.getPtr(), 0)
    }

    @TestCase
    func testFromPtrBorrowed() {
        let item = QQuickItem.create()
        let borrowed = QQuickItem.fromPtr(item.getPtr())
        @Expect(borrowed.isValid(), true)
        borrowed.close()  // 借用项 close 只标记，不删除
        @Expect(borrowed.isClosed(), true)
        @Expect(item.isValid(), true)  // 原对象仍有效
        item.close()
    }

    @TestCase
    func testPositionAndSize() {
        let item = QQuickItem.create()
        item.setX(10.5f32)
        item.setY(20.5f32)
        item.setWidth(120.0f32)
        item.setHeight(80.0f32)
        @Expect(item.x(), 10.5f32)
        @Expect(item.y(), 20.5f32)
        @Expect(item.width(), 120.0f32)
        @Expect(item.height(), 80.0f32)
        item.close()
    }

    @TestCase
    func testVisualProperties() {
        let item = QQuickItem.create()
        item.setOpacity(0.5f32)
        @Expect(item.opacity(), 0.5f32)
        item.setRotation(45.0f32)
        @Expect(item.rotation(), 45.0f32)
        item.setScale(2.0f32)
        @Expect(item.scale(), 2.0f32)
        item.setZ(3.0f32)
        @Expect(item.z(), 3.0f32)
        item.setVisible(true)
        @Expect(item.isVisible(), true)
        item.setEnabled(false)
        @Expect(item.isEnabled(), false)
        item.close()
    }

    @TestCase
    func testObjectName() {
        let item = QQuickItem.create()
        item.setObjectName("myItem")
        @Expect(item.objectName(), "myItem")
        item.close()
    }

    @TestCase
    func testFocus() {
        let item = QQuickItem.create()
        item.setFocus(true)
        @Expect(item.hasFocus(), true)
        item.setFocus(false)
        @Expect(item.hasFocus(), false)
        item.close()
    }

    @TestCase
    func testParentItem() {
        let parent = QQuickItem.create()
        let child = QQuickItem.create()
        child.setParentItem(parent)
        @Expect(child.parentItem(), parent.getPtr())
        child.close()
        parent.close()
    }

    @TestCase
    func testDynamicProperties() {
        let item = QQuickItem.create()
        item.setProperty("name", "hello")
        @Expect(item.getPropertyString("name"), "hello")
        item.setPropertyInt("count", 42)
        @Expect(item.getPropertyInt("count"), 42)
        item.setPropertyDouble("ratio", 3.14)
        @Expect(item.getPropertyDouble("ratio"), 3.14)
        item.setPropertyBool("flag", true)
        @Expect(item.getPropertyBool("flag"), true)
        item.close()
    }

    @TestCase
    func testVoidSignals() {
        let item = QQuickItem.create()
        gItemXChanged = 0
        gItemWidthChanged = 0
        gItemOpacityChanged = 0
        gItemVisibleChanged = 0
        item.setOnXChanged(gItemXChangedCb)
        item.setOnWidthChanged(gItemWidthChangedCb)
        item.setOnOpacityChanged(gItemOpacityChangedCb)
        item.setOnVisibleChanged(gItemVisibleChangedCb)
        item.setX(50.0f32)
        item.setWidth(200.0f32)
        item.setOpacity(0.9f32)
        item.setVisible(false)  // 默认可见 → 变为不可见，触发 visibleChanged
        item.setVisible(true)   // 再次触发
        @Expect(gItemXChanged > 0, true)
        @Expect(gItemWidthChanged > 0, true)
        @Expect(gItemOpacityChanged > 0, true)
        @Expect(gItemVisibleChanged > 0, true)
        item.disconnect()
        item.close()
    }

    @TestCase
    func testFocusSignal() {
        let item = QQuickItem.create()
        gItemFocusValue = -1
        item.setOnFocusChanged(gItemFocusChangedCb)
        item.setFocus(true)
        @Expect(gItemFocusValue != -1, true)
        item.disconnectFocusChanged()
        item.close()
    }

    @TestCase
    func testDisconnectStopsCallback() {
        let item = QQuickItem.create()
        gItemXChanged = 0
        item.setOnXChanged(gItemXChangedCb)
        item.disconnectXChanged()
        item.setX(70.0f32)
        @Expect(gItemXChanged, 0)
        item.close()
    }

    @TestCase
    func testDoubleClose() {
        let item = QQuickItem.create()
        item.close()
        item.close()  // 安全
        @Expect(item.getPtr(), 0)
    }

    @TestCase
    func testOperationsAfterClose() {
        let item = QQuickItem.create()
        item.close()
        @ExpectThrows[ResourceDisposedException](item.setX(1.0f32))
        @ExpectThrows[ResourceDisposedException](item.x())
        @ExpectThrows[ResourceDisposedException](item.setProperty("a", "b"))
        @ExpectThrows[ResourceDisposedException](item.isVisible())
    }
}

// =====================================================================
// QQmlContext 测试
// =====================================================================
@Test
class QQmlContextTests {
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
    func testCreateOwned() {
        let ctx = QQmlContext.create(0)
        @Expect(ctx.getPtr() != 0, true)
        ctx.close()
        @Expect(ctx.isClosed(), true)
    }

    @TestCase
    func testFromPtr() {
        let ctx = QQmlContext.create(0)
        let borrowed = QQmlContext.fromPtr(ctx.getPtr())
        @Expect(borrowed.getPtr(), ctx.getPtr())
        borrowed.close()
        @Expect(ctx.isValid(), true)
        ctx.close()
    }

    @TestCase
    func testSetContextProperties() {
        let ctx = QQmlContext.create(0)
        ctx.setContextPropertyString("name", "CJQT6")
        ctx.setContextPropertyInt("count", 7)
        ctx.setContextPropertyDouble("ratio", 2.5)
        ctx.setContextPropertyBool("flag", true)
        @Assert(true)
        ctx.close()
    }

    @TestCase
    func testParentContext() {
        let parent = QQmlContext.create(0)
        let child = QQmlContext.create(parent.getPtr())
        @Expect(child.parentContext(), parent.getPtr())
        child.close()
        parent.close()
    }

    @TestCase
    func testDoubleClose() {
        let ctx = QQmlContext.create(0)
        ctx.close()
        ctx.close()
        @Expect(ctx.getPtr(), 0)
    }

    @TestCase
    func testOperationsAfterClose() {
        let ctx = QQmlContext.create(0)
        ctx.close()
        @ExpectThrows[ResourceDisposedException](ctx.setContextPropertyInt("x", 1))
        @ExpectThrows[ResourceDisposedException](ctx.parentContext())
    }
}

// =====================================================================
// QQmlApplicationEngine 测试
// =====================================================================
@Test
class QQmlEngineTests {
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
    func testCreateAndDelete() {
        let engine = QQmlApplicationEngine()
        @Expect(engine.getPtr() != 0, true)
        engine.delete()
        @Expect(engine.isClosed(), true)
    }

    @TestCase
    func testRootContext() {
        let engine = QQmlApplicationEngine()
        let ctx = engine.rootContext()
        @Expect(ctx.isValid(), true)
        ctx.close()  // 借用项，仅标记
        engine.delete()
    }

    @TestCase
    func testSetContextProperties() {
        let engine = QQmlApplicationEngine()
        engine.setContextPropertyString("appName", "Test")
        engine.setContextPropertyInt("version", 1)
        engine.setContextPropertyDouble("scale", 1.5)
        engine.setContextPropertyBool("debug", true)
        engine.clearComponentCache()
        @Assert(true)
        engine.delete()
    }

    @TestCase
    func testStatusConstants() {
        @Expect(Status.Null, 0)
        @Expect(Status.Ready, 1)
        @Expect(Status.Loading, 2)
        @Expect(Status.Error, 3)
    }

    @TestCase
    func testResizeModeConstants() {
        @Expect(ResizeMode.SizeViewToRootObject, 0)
        @Expect(ResizeMode.SizeRootObjectToView, 1)
    }

    @TestCase
    func testOperationsAfterClose() {
        let engine = QQmlApplicationEngine()
        engine.delete()
        @ExpectThrows[ResourceDisposedException](engine.rootObjectsCount())
        @ExpectThrows[ResourceDisposedException](engine.clearComponentCache())
    }
}

// =====================================================================
// QQmlComponent 测试
// =====================================================================
@Test
class QQmlComponentTests {
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
        let engine = QQmlApplicationEngine()
        let comp = QQmlComponent(engine.getPtr())
        @Expect(comp.getPtr() != 0, true)
        @Expect(comp.status(), Status.Null)
        comp.close()
        engine.delete()
    }

    @TestCase
    func testSetDataAndReady() {
        let engine = QQmlApplicationEngine()
        let comp = QQmlComponent(engine.getPtr())
        comp.setData("import QtQuick\nRectangle { width: 50; height: 50 }")
        @Expect(comp.isError(), false)
        @Expect(comp.status() != Status.Null, true)
        // setData 为异步编译，Ready 需事件循环；此处仅验证无错误
        comp.close()
        engine.delete()
    }

    @TestCase
    func testStatusSignalConnect() {
        let engine = QQmlApplicationEngine()
        let comp = QQmlComponent(engine.getPtr())
        gCompStatus = -1
        comp.setOnStatusChanged(gCompStatusCb)
        comp.disconnectStatusChanged()
        @Assert(true)
        comp.close()
        engine.delete()
    }

    @TestCase
    func testDoubleClose() {
        let engine = QQmlApplicationEngine()
        let comp = QQmlComponent(engine.getPtr())
        comp.close()
        comp.close()
        @Expect(comp.getPtr(), 0)
        engine.delete()
    }

    @TestCase
    func testOperationsAfterClose() {
        let engine = QQmlApplicationEngine()
        let comp = QQmlComponent(engine.getPtr())
        comp.close()
        @ExpectThrows[ResourceDisposedException](comp.status())
        @ExpectThrows[ResourceDisposedException](comp.setData("import QtQuick\nItem {}"))
        engine.delete()
    }
}

// =====================================================================
// QQuickWindow 测试
// =====================================================================
@Test
class QQuickWindowTests {
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
    func testCreateAndProperties() {
        let win = QQuickWindow()
        @Expect(win.getPtr() != 0, true)
        win.setTitle("Test Window")
        win.resize(400, 300)
        @Expect(win.width() > 0, true)
        @Expect(win.height() > 0, true)
        win.setColor(255, 0, 0, 255)
        @Expect(win.isVisible(), false)
        win.close()
        @Expect(win.isClosed(), true)
    }

    @TestCase
    func testContentItem() {
        let win = QQuickWindow()
        let item = win.contentItem()
        @Expect(item.isValid(), true)
        item.close()  // 借用项
        win.close()
    }

    @TestCase
    func testSignals() {
        let win = QQuickWindow()
        gWindowWidth = -1
        win.setOnWidthChanged(gWindowWidthCb)
        win.resize(500, 300)
        @Expect(gWindowWidth > 0, true)
        win.disconnect()
        win.close()
    }

    @TestCase
    func testOperationsAfterClose() {
        let win = QQuickWindow()
        win.close()
        @ExpectThrows[ResourceDisposedException](win.setTitle("x"))
        @ExpectThrows[ResourceDisposedException](win.resize(1, 1))
        @ExpectThrows[ResourceDisposedException](win.isVisible())
    }
}
