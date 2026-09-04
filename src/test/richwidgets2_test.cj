package cjqt6.test

import cjqt6.core.*
import cjqt6.richwidgets.*
import std.unittest.*

// ============================================================
// Avatar / Badge / Steps / Timeline / Transfer 测试
// ============================================================

@Test
class AvatarTests {
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
        let av = Avatar("张", 40)
        @Expect(av.isValid(), true)
        av.close()
    }

    @TestCase
    func testSetText() {
        let av = Avatar("张")
        av.setText("李")
        @Expect(av.isValid(), true)
        av.close()
    }

    @TestCase
    func testSetSize() {
        let av = Avatar("王", 40)
        av.setSize(60)
        @Expect(av.isValid(), true)
        av.close()
    }

    @TestCase
    func testSetColor() {
        let av = Avatar("赵", 40)
        av.setBackgroundColor("#ff0000")
        av.setForegroundColor("#000000")
        @Expect(av.isValid(), true)
        av.close()
    }
}

@Test
class BadgeTests {
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
        let b = Badge()
        @Expect(b.getCount(), 0)
        @Expect(b.isValid(), true)
        b.close()
    }

    @TestCase
    func testSetCount() {
        let b = Badge()
        b.setCount(5)
        @Expect(b.getCount(), 5)
        b.close()
    }

    @TestCase
    func testMaxCount() {
        let b = Badge()
        b.setMaxCount(99)
        b.setCount(150)
        @Expect(b.getCount(), 150) // 原始值保留，显示层为 "99+"
        b.close()
    }

    @TestCase
    func testNegativeClamp() {
        let b = Badge()
        b.setCount(-10)
        @Expect(b.getCount(), 0)
        b.close()
    }
}

@Test
class StepsTests {
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
        let s = Steps(["第一步", "第二步", "第三步"])
        @Expect(s.stepCount(), 3)
        @Expect(s.getCurrentStep(), 0)
        s.close()
    }

    @TestCase
    func testSetCurrentStep() {
        let s = Steps(["A", "B", "C"])
        s.setCurrentStep(1)
        @Expect(s.getCurrentStep(), 1)
        s.close()
    }

    @TestCase
    func testClampHigh() {
        let s = Steps(["A", "B", "C"])
        s.setCurrentStep(10)
        @Expect(s.getCurrentStep(), 2)
        s.close()
    }

    @TestCase
    func testClampLow() {
        let s = Steps(["A", "B", "C"])
        s.setCurrentStep(-1)
        @Expect(s.getCurrentStep(), 0)
        s.close()
    }
}

@Test
class TimelineTests {
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
    func testAddItem() {
        let tl = Timeline()
        tl.addItem("2024-01-01", "事件A")
        tl.addItem("2024-01-02", "事件B")
        @Expect(tl.itemCount(), Int64(2))
        tl.close()
    }

    @TestCase
    func testClear() {
        let tl = Timeline()
        tl.addItem("2024-01-01", "事件A")
        tl.clear()
        @Expect(tl.itemCount(), Int64(0))
        tl.close()
    }
}

@Test
class TransferTests {
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
    func testAddCandidate() {
        let tf = Transfer()
        tf.addCandidate("选项A")
        tf.addCandidate("选项B")
        let items = tf.getCandidateItems()
        @Expect(items.size, Int64(2))
        tf.close()
    }

    @TestCase
    func testAddSelected() {
        let tf = Transfer()
        tf.addSelected("已选1")
        let items = tf.getSelectedItems()
        @Expect(items.size, Int64(1))
        tf.close()
    }

    @TestCase
    func testClear() {
        let tf = Transfer()
        tf.addCandidate("A")
        tf.addSelected("B")
        tf.clear()
        @Expect(tf.getCandidateItems().size, Int64(0))
        @Expect(tf.getSelectedItems().size, Int64(0))
        tf.close()
    }
}