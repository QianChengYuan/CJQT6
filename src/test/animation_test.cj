package cjqt6.test

// =====================================================================
// 动画模块测试（src/core/animation.cj + src/core/propertyanimation.cj）
// 覆盖：AnimationState/AnimationDirection/EasingCurve 常量
//      QAbstractAnimation / QParallelAnimationGroup
//      QPropertyAnimation
// =====================================================================

import cjqt6.core.*
import std.unittest.*

// ---------------------------------------------------------------------
// 动画常量类测试（无需 GUI）
// ---------------------------------------------------------------------
@Test
class AnimationConstantsTests {
    @TestCase
    func testAnimationState() {
        @Expect(AnimationState.stopped(), 0)
        @Expect(AnimationState.paused(), 1)
        @Expect(AnimationState.running(), 2)
    }

    @TestCase
    func testAnimationDirection() {
        @Expect(AnimationDirection.forward(), 0)
        @Expect(AnimationDirection.backward(), 1)
    }

    @TestCase
    func testEasingCurveConstants() {
        @Expect(EasingCurve.Linear, 0)
        @Expect(EasingCurve.InQuad, 1)
        @Expect(EasingCurve.OutQuad, 2)
        @Expect(EasingCurve.InOutQuad, 3)
        @Expect(EasingCurve.InCubic, 4)
        @Expect(EasingCurve.OutCubic, 5)
        @Expect(EasingCurve.InOutCubic, 6)
        @Expect(EasingCurve.InSine, 7)
        @Expect(EasingCurve.OutSine, 8)
        @Expect(EasingCurve.InOutSine, 9)
        @Expect(EasingCurve.InElastic, 14)
        @Expect(EasingCurve.OutElastic, 15)
        @Expect(EasingCurve.InOutElastic, 16)
        @Expect(EasingCurve.InBounce, 17)
        @Expect(EasingCurve.OutBounce, 18)
        @Expect(EasingCurve.InOutBounce, 19)
    }
}

// ---------------------------------------------------------------------
// QParallelAnimationGroup 测试
// ---------------------------------------------------------------------
@Test
class QParallelAnimationGroupTests {
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
        let g = QParallelAnimationGroup()
        @Expect(g.getPtr() != 0, true)
        @Expect(g.animationCount(), 0)
        g.close()
    }

    @TestCase
    func testAddRemoveAnimation() {
        let g = QParallelAnimationGroup()
        // 用 QPropertyAnimation 作为子动画（需要一个目标对象指针，这里用 0）
        // QPropertyAnimation 创建时 target=0 仍可创建（Qt 允许）
        let anim = QPropertyAnimation(0, "pos")
        @Expect(g.animationCount(), 0)
        g.addAnimation(anim.getPtr())
        @Expect(g.animationCount(), 1)
        g.removeAnimation(anim.getPtr())
        @Expect(g.animationCount(), 0)
        anim.close()
        g.close()
    }

    @TestCase
    func testStateInitial() {
        let g = QParallelAnimationGroup()
        @Expect(g.state(), AnimationState.stopped())
        g.close()
    }

    @TestCase
    func testLoopCountRoundtrip() {
        let g = QParallelAnimationGroup()
        g.setLoopCount(3)
        @Expect(g.loopCount(), 3)
        g.setLoopCount(-1)
        @Expect(g.loopCount(), -1)
        g.close()
    }

    @TestCase
    func testDirectionRoundtrip() {
        let g = QParallelAnimationGroup()
        g.setDirection(AnimationDirection.backward())
        @Expect(g.direction(), AnimationDirection.backward())
        g.setDirection(AnimationDirection.forward())
        @Expect(g.direction(), AnimationDirection.forward())
        g.close()
    }

    @TestCase
    func testStartStopPauseResume() {
        let g = QParallelAnimationGroup()
        let anim = QPropertyAnimation(0, "pos")
        anim.setDuration(10000)
        g.addAnimation(anim.getPtr())
        g.setLoopCount(1)
        g.start()
        @Expect(g.state(), AnimationState.running())
        g.pause()
        @Expect(g.state(), AnimationState.paused())
        g.resume()
        @Expect(g.state(), AnimationState.running())
        g.stop()
        @Expect(g.state(), AnimationState.stopped())
        anim.close()
        g.close()
    }

    @TestCase
    func testDoubleClose() {
        let g = QParallelAnimationGroup()
        g.close()
        g.close()  // 安全
        @Assert(true)
    }
}

// ---------------------------------------------------------------------
// QPropertyAnimation 测试
// ---------------------------------------------------------------------
@Test
class QPropertyAnimationTests {
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
        let anim = QPropertyAnimation(0, "pos")
        @Assert(anim.isValid())
        @Expect(anim.isClosed(), false)
        @Expect(anim.getPtr() != 0, true)
        anim.close()
        @Expect(anim.isClosed(), true)
    }

    @TestCase
    func testDurationRoundtrip() {
        let anim = QPropertyAnimation(0, "x")
        anim.setDuration(1000)
        @Expect(anim.duration(), 1000)
        anim.setDuration(250)
        @Expect(anim.duration(), 250)
        anim.close()
    }

    @TestCase
    func testStartEndValues() {
        let anim = QPropertyAnimation(0, "value")
        anim.setStartValue(0.0)
        anim.setEndValue(100.0)
        anim.close()
        @Assert(true)
    }

    @TestCase
    func testLoopCountRoundtrip() {
        let anim = QPropertyAnimation(0, "x")
        anim.setLoopCount(5)
        @Expect(anim.loopCount(), 5)
        anim.setLoopCount(-1)
        @Expect(anim.loopCount(), -1)
        anim.close()
    }

    @TestCase
    func testSetEasingCurve() {
        let anim = QPropertyAnimation(0, "x")
        anim.setEasingCurve(EasingCurve.InOutQuad)
        anim.setEasingCurve(EasingCurve.OutBounce)
        anim.close()
        @Assert(true)
    }

    @TestCase
    func testStartStop() {
        let anim = QPropertyAnimation(0, "x")
        anim.setDuration(100)
        anim.setLoopCount(1)
        anim.start()
        anim.stop()
        anim.close()
        @Assert(true)
    }

    @TestCase
    func testCloseAndCheckValid() {
        let anim = QPropertyAnimation(0, "x")
        anim.close()
        @Expect(anim.isValid(), false)
        @ExpectThrows[ResourceDisposedException](anim.checkValid())
    }

    @TestCase
    func testOperationsAfterClose() {
        let anim = QPropertyAnimation(0, "x")
        anim.close()
        @ExpectThrows[ResourceDisposedException](anim.setDuration(100))
        @ExpectThrows[ResourceDisposedException](anim.duration())
        @ExpectThrows[ResourceDisposedException](anim.start())
        @ExpectThrows[ResourceDisposedException](anim.setLoopCount(1))
    }

    @TestCase
    func testDeleteCompatibility() {
        let anim = QPropertyAnimation(0, "x")
        anim.delete()
        @Expect(anim.isClosed(), true)
    }
}