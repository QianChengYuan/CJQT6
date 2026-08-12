package cjqt6.test

// =====================================================================
// 事件模块测试（src/core/events.cj）
// 覆盖：MouseButton / Key / Modifier 常量类 + QEventWidget
// =====================================================================

import cjqt6.core.*
import std.unittest.*

// CFunc 回调（顶层 let）
private let gMouseCb: CFunc<(Int32, Int32, Int32) -> Unit> = { b: Int32, x: Int32, y: Int32 => () }
private let gKeyCb: CFunc<(Int32, Int32, Int32) -> Unit> = { k: Int32, m: Int32, u: Int32 => () }
private let gPaintCb: CFunc<(Int64) -> Unit> = { p: Int64 => () }

// ---------------------------------------------------------------------
// MouseButton 常量测试（无需 GUI，但底层调用 Qt，需 QApplication）
// ---------------------------------------------------------------------
@Test
class MouseButtonTests {
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
    func testLeftRightMiddle() {
        let l = MouseButton.left()
        let r = MouseButton.right()
        let m = MouseButton.middle()
        // Qt::LeftButton=1, RightButton=2, MiddleButton=4
        @Expect(l, 1)
        @Expect(r, 2)
        @Expect(m, 4)
    }

    @TestCase
    func testDistinctValues() {
        @Expect(MouseButton.left() != MouseButton.right(), true)
        @Expect(MouseButton.right() != MouseButton.middle(), true)
        @Expect(MouseButton.left() != MouseButton.middle(), true)
    }
}

// ---------------------------------------------------------------------
// Key 常量测试
// ---------------------------------------------------------------------
@Test
class KeyConstantsTests {
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
    func testLetterKeys() {
        @Expect(Key.a(), 65)
        @Expect(Key.b(), 66)
        @Expect(Key.z(), 90)
    }

    @TestCase
    func testDigitKeys() {
        @Expect(Key.num0(), 48)
        @Expect(Key.num1(), 49)
        @Expect(Key.num9(), 57)
    }

    @TestCase
    func testFunctionKeysNonZero() {
        @Expect(Key.f1() > 0, true)
        @Expect(Key.f2() > 0, true)
        @Expect(Key.f12() > 0, true)
        @Expect(Key.f1() != Key.f2(), true)
    }

    @TestCase
    func testNavigationKeysNonZero() {
        @Expect(Key.left() > 0, true)
        @Expect(Key.right() > 0, true)
        @Expect(Key.up() > 0, true)
        @Expect(Key.down() > 0, true)
        @Expect(Key.home() > 0, true)
        @Expect(Key.end() > 0, true)
        @Expect(Key.pageUp() > 0, true)
        @Expect(Key.pageDown() > 0, true)
    }

    @TestCase
    func testEditKeysNonZero() {
        @Expect(Key.escape() > 0, true)
        @Expect(Key.tab() > 0, true)
        @Expect(Key.backspace() > 0, true)
        @Expect(Key.enter() > 0, true)
        @Expect(Key.returnKey() > 0, true)
        @Expect(Key.insert() > 0, true)
        @Expect(Key.delete() > 0, true)
        @Expect(Key.space() > 0, true)
    }

    @TestCase
    func testModifierKeysNonZero() {
        @Expect(Key.shift() > 0, true)
        @Expect(Key.control() > 0, true)
        @Expect(Key.alt() > 0, true)
        @Expect(Key.meta() > 0, true)
    }

    @TestCase
    func testLockKeysNonZero() {
        @Expect(Key.capsLock() > 0, true)
        @Expect(Key.numLock() > 0, true)
        @Expect(Key.scrollLock() > 0, true)
    }

    @TestCase
    func testMiscKeysNonZero() {
        @Expect(Key.pause() > 0, true)
        @Expect(Key.print() > 0, true)
    }
}

// ---------------------------------------------------------------------
// Modifier 常量与位检测测试
// ---------------------------------------------------------------------
@Test
class ModifierTests {
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
    func testModifierValuesNonZero() {
        @Expect(Modifier.shift() > 0, true)
        @Expect(Modifier.control() > 0, true)
        @Expect(Modifier.alt() > 0, true)
        @Expect(Modifier.meta() > 0, true)
    }

    @TestCase
    func testHasShift() {
        let m = Modifier.shift()
        @Expect(Modifier.hasShift(m), true)
        @Expect(Modifier.hasShift(0), false)
    }

    @TestCase
    func testHasControl() {
        let m = Modifier.control()
        @Expect(Modifier.hasControl(m), true)
        @Expect(Modifier.hasControl(0), false)
    }

    @TestCase
    func testHasAlt() {
        let m = Modifier.alt()
        @Expect(Modifier.hasAlt(m), true)
        @Expect(Modifier.hasAlt(0), false)
    }

    @TestCase
    func testHasMeta() {
        let m = Modifier.meta()
        @Expect(Modifier.hasMeta(m), true)
        @Expect(Modifier.hasMeta(0), false)
    }

    @TestCase
    func testCombinedModifiers() {
        let combined = Modifier.shift() | Modifier.control()
        @Expect(Modifier.hasShift(combined), true)
        @Expect(Modifier.hasControl(combined), true)
        @Expect(Modifier.hasAlt(combined), false)
        @Expect(Modifier.hasMeta(combined), false)
    }
}

// ---------------------------------------------------------------------
// QEventWidget 测试
// ---------------------------------------------------------------------
@Test
class QEventWidgetTests {
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
        let w = QEventWidget()
        @Expect(w.getPtr() != 0, true)
        @Expect(w.getId() != 0, true)
        w.delete()
    }

    @TestCase
    func testSetTitle() {
        let w = QEventWidget()
        w.setTitle("事件窗口")
        w.delete()
        @Assert(true)
    }

    @TestCase
    func testResize() {
        let w = QEventWidget()
        w.resize(400, 300)
        w.delete()
        @Assert(true)
    }

    @TestCase
    func testSetGeometry() {
        let w = QEventWidget()
        w.setGeometry(10, 20, 400, 300)
        w.delete()
        @Assert(true)
    }

    @TestCase
    func testShowHide() {
        let w = QEventWidget()
        w.show()
        w.hide()
        w.delete()
        @Assert(true)
    }

    @TestCase
    func testSetLayout() {
        let w = QEventWidget()
        w.setLayout(0)
        w.delete()
        @Assert(true)
    }

    @TestCase
    func testMouseCallbacks() {
        let w = QEventWidget()
        w.setOnMousePress(gMouseCb)
        w.setOnMouseMove(gMouseCb)
        w.setOnMouseRelease(gMouseCb)
        w.clearMousePressCallback()
        w.clearMouseMoveCallback()
        w.clearMouseReleaseCallback()
        w.delete()
        @Assert(true)
    }

    @TestCase
    func testKeyCallbacks() {
        let w = QEventWidget()
        w.setOnKeyPress(gKeyCb)
        w.setOnKeyRelease(gKeyCb)
        w.clearKeyPressCallback()
        w.clearKeyReleaseCallback()
        w.delete()
        @Assert(true)
    }

    @TestCase
    func testPaintCallback() {
        let w = QEventWidget()
        w.setOnPaint(gPaintCb)
        w.clearPaintCallback()
        w.delete()
        @Assert(true)
    }

    @TestCase
    func testClearAllCallbacks() {
        let w = QEventWidget()
        w.setOnMousePress(gMouseCb)
        w.setOnKeyPress(gKeyCb)
        w.setOnPaint(gPaintCb)
        w.clearAllCallbacks()
        w.delete()
        @Assert(true)
    }

    @TestCase
    func testUpdate() {
        let w = QEventWidget()
        w.update()
        w.delete()
        @Assert(true)
    }

    @TestCase
    func testDoubleDelete() {
        let w = QEventWidget()
        w.delete()
        w.delete()  // 安全
        @Assert(true)
    }
}