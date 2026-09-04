package cjqt6.test

import cjqt6.core.*
import cjqt6.richwidgets.*
import std.unittest.*

// ============================================================
// Skeleton / Empty / Statistic / Countdown 测试
// ============================================================

@Test
class SkeletonTests {
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
        let s = Skeleton(3)
        @Expect(s.rowCount(), Int64(3))
        @Expect(s.isValid(), true)
        s.close()
    }

    @TestCase
    func testDefault() {
        let s = Skeleton()
        @Expect(s.rowCount(), Int64(1))
        s.close()
    }
}

@Test
class EmptyTests {
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
        let e = Empty("暂无数据")
        @Expect(e.isValid(), true)
        e.close()
    }

    @TestCase
    func testWithDescription() {
        let e = Empty("暂无数据", "请先添加数据后再查看")
        @Expect(e.isValid(), true)
        e.close()
    }

    @TestCase
    func testSetText() {
        let e = Empty("空")
        e.setText("无内容")
        @Expect(e.isValid(), true)
        e.close()
    }
}

@Test
class StatisticTests {
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
        let s = Statistic("访问量", "1024", "次")
        @Expect(s.isValid(), true)
        s.close()
    }

    @TestCase
    func testCreateInt() {
        let s = Statistic("用户数", Int64(500))
        @Expect(s.isValid(), true)
        s.close()
    }

    @TestCase
    func testSetValue() {
        let s = Statistic("销售额", "0", "元")
        s.setValue("9999")
        s.setValue(Int64(10000))
        @Expect(s.isValid(), true)
        s.close()
    }
}

@Test
class CountdownTests {
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
        let c = Countdown(60)
        @Expect(c.getRemaining(), 60)
        @Expect(c.isValid(), true)
        c.close()
    }

    @TestCase
    func testNegativeClamp() {
        let c = Countdown(-5)
        @Expect(c.getRemaining(), 0)
        c.close()
    }
}