package cjqt6.test

import cjqt6.core.*
import cjqt6.gui.*
import cjqt6.widgets.*
import std.unittest.*

// ============================================================
// 反向失效通知专项测试
// 验证：父 Qt 对象被销毁时，被级联销毁的子对象指针能被 isValid()/checkValid() 识别为失效
// ============================================================

@Test
class ReverseInvalidationTests {
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
    func testChildWidgetInvalidAfterParentClose() {
        let parent = QWidget()
        let child = QWidget()
        unsafe {
            setWidgetParent(child.getPtr(), parent.getPtr())
        }
        @Assert(parent.isValid())
        @Assert(child.isValid())

        parent.close()
        // 父对象销毁时 Qt 会级联销毁子对象
        @Expect(child.isValid(), false)
        // 子对象指针未置零，但底层对象已失效
        @Assert(child.getPtr() != 0)
    }

    @TestCase
    func testChildWidgetCheckValidThrowsAfterParentClose() {
        let parent = QWidget()
        let child = QPushButton()
        unsafe {
            setWidgetParent(child.getPtr(), parent.getPtr())
        }
        parent.close()

        var thrown = false
        try {
            child.setText("hello")
        } catch (e: ResourceDisposedException) {
            thrown = true
        }
        @Expect(thrown, true)
    }

    @TestCase
    func testChildWidgetCheckValidThrowsAliveMessage() {
        let parent = QWidget()
        let child = QWidget()
        unsafe {
            setWidgetParent(child.getPtr(), parent.getPtr())
        }
        parent.close()

        var message = ""
        try {
            child.checkValid()
        } catch (e: ResourceDisposedException) {
            message = e.message
        }
        @Expect(message.contains("底层 Qt 对象已失效"), true)
    }

    @TestCase
    func testChildAfterParentCloseThenChildCloseSafe() {
        let parent = QWidget()
        let child = QPushButton()
        unsafe {
            setWidgetParent(child.getPtr(), parent.getPtr())
        }
        parent.close()
        // 底层对象已被级联销毁，再次 close 不应崩溃
        child.close()
        @Expect(child.isClosed(), true)
    }

    @TestCase
    func testUntrackedWidgetStillValid() {
        let w = QWidget()
        @Assert(w.isValid())
        w.close()
        @Expect(w.isValid(), false)
    }
}
