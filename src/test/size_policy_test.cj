package cjqt6.test

import cjqt6.core.*
import std.unittest.*

@Test
class SizePolicyTests {
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

    // 枚举值对齐 Qt 头文件 qsizepolicy.h（QSizePolicy::Policy）
    @TestCase
    func testPolicyValuesAlignQt() {
        @Expect(SizePolicy.Fixed, 0)
        @Expect(SizePolicy.Minimum, 1)
        @Expect(SizePolicy.MinimumExpanding, 3)
        @Expect(SizePolicy.Maximum, 4)
        @Expect(SizePolicy.Preferred, 5)
        @Expect(SizePolicy.Expanding, 7)
        @Expect(SizePolicy.Ignored, 13)
    }

    // 设置水平/垂直不同策略后能读回，验证 FFI 桥接正确
    @TestCase
    func testSetSizePolicy() {
        let w = QWidget()
        w.setSizePolicy(SizePolicy.Expanding, SizePolicy.Fixed)
        @Expect(w.sizePolicyHorizontal(), SizePolicy.Expanding)
        @Expect(w.sizePolicyVertical(), SizePolicy.Fixed)
        w.close()
    }

    // 单参重载：水平/垂直同策略
    @TestCase
    func testSetSizePolicySameBoth() {
        let w = QWidget()
        w.setSizePolicy(SizePolicy.Minimum)
        @Expect(w.sizePolicyHorizontal(), SizePolicy.Minimum)
        @Expect(w.sizePolicyVertical(), SizePolicy.Minimum)
        w.close()
    }

    // close 后调用抛 ResourceDisposedException
    @TestCase
    func testSizePolicyAfterClose() {
        let w = QWidget()
        w.close()
        @ExpectThrows[ResourceDisposedException](w.setSizePolicy(SizePolicy.Fixed, SizePolicy.Fixed))
        @ExpectThrows[ResourceDisposedException](w.sizePolicyHorizontal())
    }
}
