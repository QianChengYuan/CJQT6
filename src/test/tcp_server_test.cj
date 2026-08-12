package cjqt6.test

// =====================================================================
// TCP 服务端模块测试（src/network/tcp_server.cj）
// 覆盖：QTcpServer
//      构造/监听/停止/状态/端口/地址/错误/最大连接数/回调
// =====================================================================

import cjqt6.core.*
import cjqt6.network.*
import std.unittest.*

// CFunc 回调（顶层 let，不捕获局部变量）
private let gNewConnCb: VoidCallback = { => () }
var gNewConnCaptureCount: Int32 = 0

// ---------------------------------------------------------------------
// QTcpServer 测试
// ---------------------------------------------------------------------
@Test
class QTcpServerTests {
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
        let s = QTcpServer()
        @Assert(s.isValid())
        @Expect(s.isClosed(), false)
        @Expect(s.getPtr() != 0, true)
        @Expect(s.isListening(), false)
        s.close()
        @Expect(s.isClosed(), true)
    }

    @TestCase
    func testListenOnAutoPort() {
        let s = QTcpServer()
        let ok = s.listen(0u16)
        @Expect(ok, true)
        @Expect(s.isListening(), true)
        @Expect(s.serverPort() > 0, true)
        s.close()
    }

    @TestCase
    func testListenOnSpecificPort() {
        let s = QTcpServer()
        // 使用 0 让系统分配，避免端口冲突
        let ok = s.listenOn("127.0.0.1", 0u16)
        @Expect(ok, true)
        @Expect(s.isListening(), true)
        @Expect(s.serverPort() > 0, true)
        s.close()
    }

    @TestCase
    func testListenOnAllInterfaces() {
        let s = QTcpServer()
        let ok = s.listenOn("0.0.0.0", 0u16)
        @Expect(ok, true)
        @Expect(s.isListening(), true)
        s.close()
    }

    @TestCase
    func testCloseServer() {
        let s = QTcpServer()
        s.listen(0u16)
        @Expect(s.isListening(), true)
        s.closeServer()
        @Expect(s.isListening(), false)
        s.close()
    }

    @TestCase
    func testServerAddress() {
        let s = QTcpServer()
        s.listenOn("127.0.0.1", 0u16)
        let addr = s.serverAddress()
        @Expect(addr, "127.0.0.1")
        s.close()
    }

    @TestCase
    func testErrorStringEmptyWhenNoError() {
        let s = QTcpServer()
        let err = s.errorString()
        @Expect(err.size, 0)
        s.close()
    }

    @TestCase
    func testMaxPendingConnectionsRoundtrip() {
        let s = QTcpServer()
        let initial = s.maxPendingConnections()
        @Expect(initial > 0, true)
        s.setMaxPendingConnections(50)
        @Expect(s.maxPendingConnections(), 50)
        s.setMaxPendingConnections(10)
        @Expect(s.maxPendingConnections(), 10)
        s.close()
    }

    @TestCase
    func testHasPendingConnectionsFalse() {
        let s = QTcpServer()
        @Expect(s.hasPendingConnections(), false)
        s.listen(0u16)
        @Expect(s.hasPendingConnections(), false)
        s.close()
    }

    @TestCase
    func testNextPendingConnectionNone() {
        let s = QTcpServer()
        let conn = s.nextPendingConnection()
        match (conn) {
            case Some(_) => @Fail("应返回 None")
            case None => @Assert(true)
        }
        s.close()
    }

    @TestCase
    func testSetOnNewConnection() {
        let s = QTcpServer()
        s.setOnNewConnection(gNewConnCb)
        @Assert(s.isValid())
        s.close()
    }

    @TestCase
    func testSetOnNewConnectionCapture() {
        gNewConnCaptureCount = 0
        let s = QTcpServer()
        let id = s.setOnNewConnectionCapture({ =>
            gNewConnCaptureCount += 1
        })
        @Expect(id > 0, true)
        s.close()
    }

    @TestCase
    func testDisconnectCallbacks() {
        let s = QTcpServer()
        s.setOnNewConnection(gNewConnCb)
        s.disconnectCallbacks()
        @Assert(s.isValid())
        s.close()
    }

    @TestCase
    func testCloseAndCheckValid() {
        let s = QTcpServer()
        s.close()
        @Expect(s.isValid(), false)
        @Expect(s.isClosed(), true)
        @ExpectThrows[ResourceDisposedException](s.checkValid())
    }

    @TestCase
    func testOperationsAfterClose() {
        let s = QTcpServer()
        s.close()
        @ExpectThrows[ResourceDisposedException](s.listen(0u16))
        @ExpectThrows[ResourceDisposedException](s.isListening())
        @ExpectThrows[ResourceDisposedException](s.serverPort())
        @ExpectThrows[ResourceDisposedException](s.closeServer())
        @ExpectThrows[ResourceDisposedException](s.setOnNewConnection(gNewConnCb))
    }

    @TestCase
    func testDeleteCompatibility() {
        let s = QTcpServer()
        s.delete()
        @Expect(s.isClosed(), true)
    }

    @TestCase
    func testDoubleClose() {
        let s = QTcpServer()
        s.close()
        s.close()
        @Expect(s.isClosed(), true)
    }
}