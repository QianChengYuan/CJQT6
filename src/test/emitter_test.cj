package cjqt6.test

// =====================================================================
// 信号发射器模块测试（src/core/emitter.cj）
// 覆盖：ConnectionType 常量 + SignalEmitter
//      void/int/double/string 四种信号 + 连接/发射/断开
// =====================================================================

import cjqt6.core.*
import std.unittest.*

// 全局回调状态（CFunc 不能捕获局部变量）
var gVoidCount: Int32 = 0
var gIntValue: Int32 = 0
var gDoubleValue: Float64 = 0.0
var gStringValue: String = ""
var gVoidCaptureCount: Int32 = 0

private let gVoidCb: VoidCallback = { =>
    gVoidCount += 1
}

private let gIntCb: Int32Callback = { v: Int32 =>
    gIntValue = v
}

private let gDoubleCb: Float64Callback = { v: Float64 =>
    gDoubleValue = v
}

private let gStringCb: CStringCallback = { s: CString =>
    gStringValue = s.toString()
}

// ---------------------------------------------------------------------
// ConnectionType 常量测试（无需 GUI）
// ---------------------------------------------------------------------
@Test
class ConnectionTypeTests {
    @TestCase

    func testConstants() {
        @Expect(ConnectionType.Auto, 0)
        @Expect(ConnectionType.Direct, 1)
        @Expect(ConnectionType.Queued, 2)
        @Expect(ConnectionType.BlockingQueued, 3)
    }
}

// ---------------------------------------------------------------------
// SignalEmitter 测试
// ---------------------------------------------------------------------
@Test
class SignalEmitterTests {
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
        let e = SignalEmitter()
        @Assert(e.isValid())
        @Expect(e.isClosed(), false)
        @Expect(e.getPtr() != 0, true)
        e.close()
        @Expect(e.isClosed(), true)
    }

    @TestCase
    func testVoidSignal() {
        gVoidCount = 0
        let e = SignalEmitter()
        e.setOnVoid(gVoidCb)
        @Expect(gVoidCount, 0)
        e.emitVoid()
        @Expect(gVoidCount, 1)
        e.emitVoid()
        e.emitVoid()
        @Expect(gVoidCount, 3)
        e.close()
    }

    @TestCase
    func testVoidSignalWithConnectionType() {
        gVoidCount = 0
        let e = SignalEmitter()
        e.setOnVoid(gVoidCb, ConnectionType.Direct)
        e.emitVoid()
        @Expect(gVoidCount, 1)
        e.close()
    }

    @TestCase
    func testVoidSignalCapture() {
        gVoidCaptureCount = 0
        let e = SignalEmitter()
        let conn = e.setOnVoidCapture({ =>
            gVoidCaptureCount += 1
        })
        @Expect(conn.isConnected(), true)
        e.emitVoid()
        @Expect(gVoidCaptureCount, 1)
        conn.disconnect()
        @Expect(conn.isConnected(), false)
        e.emitVoid()
        @Expect(gVoidCaptureCount, 1)
        e.close()
    }

    @TestCase
    func testIntSignal() {
        gIntValue = 0
        let e = SignalEmitter()
        e.setOnInt(gIntCb)
        e.emitInt(42)
        @Expect(gIntValue, 42)
        e.emitInt(-100)
        @Expect(gIntValue, -100)
        e.close()
    }

    @TestCase
    func testIntSignalWithConnectionType() {
        gIntValue = 0
        let e = SignalEmitter()
        e.setOnInt(gIntCb, ConnectionType.Direct)
        e.emitInt(7)
        @Expect(gIntValue, 7)
        e.close()
    }

    @TestCase
    func testDoubleSignal() {
        gDoubleValue = 0.0
        let e = SignalEmitter()
        e.setOnDouble(gDoubleCb)
        e.emitDouble(3.14)
        @Expect(gDoubleValue, 3.14)
        e.emitDouble(-2.5)
        @Expect(gDoubleValue, -2.5)
        e.close()
    }

    @TestCase
    func testDoubleSignalWithConnectionType() {
        gDoubleValue = 0.0
        let e = SignalEmitter()
        e.setOnDouble(gDoubleCb, ConnectionType.Direct)
        e.emitDouble(1.0)
        @Expect(gDoubleValue, 1.0)
        e.close()
    }

    @TestCase
    func testStringSignal() {
        gStringValue = ""
        let e = SignalEmitter()
        e.setOnString(gStringCb)
        e.emitString("hello")
        @Expect(gStringValue, "hello")
        e.emitString("world")
        @Expect(gStringValue, "world")
        e.close()
    }

    @TestCase
    func testStringSignalWithConnectionType() {
        gStringValue = ""
        let e = SignalEmitter()
        e.setOnString(gStringCb, ConnectionType.Direct)
        e.emitString("direct")
        @Expect(gStringValue, "direct")
        e.close()
    }

    @TestCase
    func testDisconnectIndividual() {
        gVoidCount = 0
        gIntValue = 0
        let e = SignalEmitter()
        e.setOnVoid(gVoidCb)
        e.setOnInt(gIntCb)
        e.emitVoid()
        e.emitInt(5)
        @Expect(gVoidCount, 1)
        @Expect(gIntValue, 5)
        e.disconnectVoid()
        e.emitVoid()
        @Expect(gVoidCount, 1)
        e.emitInt(99)
        @Expect(gIntValue, 99)
        e.disconnectInt()
        e.emitInt(0)
        @Expect(gIntValue, 99)
        e.close()
    }

    @TestCase
    func testDisconnectAll() {
        gVoidCount = 0
        gIntValue = 0
        gDoubleValue = 0.0
        gStringValue = ""
        let e = SignalEmitter()
        e.setOnVoid(gVoidCb)
        e.setOnInt(gIntCb)
        e.setOnDouble(gDoubleCb)
        e.setOnString(gStringCb)
        e.disconnect()
        e.emitVoid()
        e.emitInt(1)
        e.emitDouble(1.0)
        e.emitString("x")
        @Expect(gVoidCount, 0)
        @Expect(gIntValue, 0)
        @Expect(gDoubleValue, 0.0)
        @Expect(gStringValue, "")
        e.close()
    }

    @TestCase
    func testCloseAndCheckValid() {
        let e = SignalEmitter()
        e.close()
        @Expect(e.isValid(), false)
        @ExpectThrows[ResourceDisposedException](e.checkValid())
    }

    @TestCase
    func testOperationsAfterClose() {
        let e = SignalEmitter()
        e.close()
        @ExpectThrows[ResourceDisposedException](e.emitVoid())
        @ExpectThrows[ResourceDisposedException](e.emitInt(1))
        @ExpectThrows[ResourceDisposedException](e.emitDouble(1.0))
        @ExpectThrows[ResourceDisposedException](e.emitString("x"))
        @ExpectThrows[ResourceDisposedException](e.setOnVoid(gVoidCb))
    }

    @TestCase
    func testDeleteCompatibility() {
        let e = SignalEmitter()
        e.delete()
        @Expect(e.isClosed(), true)
    }
}