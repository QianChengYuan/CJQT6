package cjqt6.test

import cjqt6.core.*
import std.unittest.*

@Test
class DpiTests {
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

    // DPI 查询返回合理正值（offscreen 平台下也不应为 0）
    @TestCase
    func testDpiQueryValid() {
        @Expect(QScreen.primaryDpiX() > 0.0, true)
        @Expect(QScreen.primaryDpiY() > 0.0, true)
        @Expect(QScreen.scaleFactor() > 0.0, true)
        @Expect(QScreen.primaryDevicePixelRatio() > 0.0, true)
    }

    // 逻辑像素转物理像素后应 >= 原值（High-DPI scale 因子 >= 1）
    @TestCase
    func testLogicalToPhysicalNonShrink() {
        let physical = QScreen.logicalToPhysical(100)
        @Expect(physical >= 100, true)
    }

    // 逻辑↔物理往返转换应回到原值附近（允许取整误差 ±1）
    @TestCase
    func testLogicalPhysicalRoundtrip() {
        let physical = QScreen.logicalToPhysical(100)
        let logical = QScreen.physicalToLogical(physical)
        @Expect(logical >= 99 && logical <= 101, true)
    }
}
