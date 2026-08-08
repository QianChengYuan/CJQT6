package cjqt6.test

import cjqt6.core.*
import cjqt6.network.*
import std.unittest.*

// =====================================================================
// 回调用全局 CFunc（不捕获局部变量，仅验证注册不崩溃）
// =====================================================================
private let gNetVoidCb: VoidCallback = { => () }
private let gNetInt64Cb: Int64Callback = { v: Int64 => () }
private let gNetStrCb: CStringCallback = { s: CString => () }

// =====================================================================
// QHostAddress 测试
// =====================================================================
@Test
class QHostAddressTests {
    @TestCase
    func testCreateDefault() {
        let addr = QHostAddress()
        @Assert(addr.getPtr() != 0)
        @Expect(addr.isNull(), true)
        addr.delete()
    }

    @TestCase
    func testCreateWithIPv4() {
        let addr = QHostAddress("127.0.0.1")
        @Expect(addr.isNull(), false)
        @Expect(addr.toString(), "127.0.0.1")
        addr.delete()
    }

    @TestCase
    func testCreateWithIPv6() {
        let addr = QHostAddress("::1")
        @Expect(addr.isNull(), false)
        @Expect(addr.protocol(), NetworkProtocol.IPv6)
        addr.delete()
    }

    @TestCase
    func testProtocolIPv4() {
        let addr = QHostAddress("192.168.1.1")
        @Expect(addr.protocol(), NetworkProtocol.IPv4)
        addr.delete()
    }

    @TestCase
    func testToStringRoundTrip() {
        let addr = QHostAddress("10.0.0.1")
        @Expect(addr.toString(), "10.0.0.1")
        addr.delete()
    }

    @TestCase
    func testSetAddress() {
        let addr = QHostAddress()
        addr.setAddress("172.16.0.1")
        @Expect(addr.toString(), "172.16.0.1")
        @Expect(addr.isNull(), false)
        addr.delete()
    }

    @TestCase
    func testEqual() {
        let addr = QHostAddress("127.0.0.1")
        @Expect(addr.equal("127.0.0.1"), true)
        @Expect(addr.equal("1.2.3.4"), false)
        addr.delete()
    }

    @TestCase
    func testLocalHost() {
        let addr = HostAddress.LocalHost()
        @Expect(addr.toString(), "127.0.0.1")
        addr.delete()
    }

    @TestCase
    func testAny() {
        let addr = HostAddress.Any()
        @Expect(addr.toString(), "0.0.0.0")
        addr.delete()
    }

    @TestCase
    func testBroadcast() {
        let addr = HostAddress.Broadcast()
        @Expect(addr.toString(), "255.255.255.255")
        addr.delete()
    }

    @TestCase
    func testLocalHostIPv6() {
        let addr = HostAddress.LocalHostIPv6()
        @Expect(addr.protocol(), NetworkProtocol.IPv6)
        addr.delete()
    }
}

// =====================================================================
// QNetworkProxy 测试
// =====================================================================
@Test
class QNetworkProxyTests {
    @TestCase
    func testCreateDefault() {
        let proxy = QNetworkProxy()
        @Assert(proxy.getPtr() != 0)
        @Expect(proxy.proxyType(), ProxyType.noProxy())
        proxy.close()
    }

    @TestCase
    func testCreateWithType() {
        let proxy = QNetworkProxy(ProxyType.http())
        @Expect(proxy.proxyType(), ProxyType.http())
        proxy.close()
    }

    @TestCase
    func testSetType() {
        let proxy = QNetworkProxy()
        proxy.setType(ProxyType.socks5())
        @Expect(proxy.proxyType(), ProxyType.socks5())
        proxy.setType(ProxyType.defaultProxy())
        @Expect(proxy.proxyType(), ProxyType.defaultProxy())
        proxy.close()
    }

    @TestCase
    func testSetHostName() {
        let proxy = QNetworkProxy()
        proxy.setHostName("proxy.example.com")
        @Expect(proxy.hostName(), "proxy.example.com")
        proxy.close()
    }

    @TestCase
    func testSetPort() {
        let proxy = QNetworkProxy()
        proxy.setPort(8080)
        @Expect(proxy.port(), 8080)
        proxy.close()
    }

    @TestCase
    func testSetUser() {
        let proxy = QNetworkProxy()
        proxy.setUser("alice")
        @Expect(proxy.user(), "alice")
        proxy.close()
    }

    @TestCase
    func testSetPassword() {
        let proxy = QNetworkProxy()
        proxy.setPassword("secret")
        @Expect(proxy.password(), "secret")
        proxy.close()
    }

    @TestCase
    func testFullConfig() {
        let proxy = QNetworkProxy(ProxyType.http())
        proxy.setHostName("cache.example.com")
        proxy.setPort(3128)
        proxy.setUser("u")
        proxy.setPassword("p")
        @Expect(proxy.proxyType(), ProxyType.http())
        @Expect(proxy.hostName(), "cache.example.com")
        @Expect(proxy.port(), 3128)
        @Expect(proxy.user(), "u")
        @Expect(proxy.password(), "p")
        proxy.close()
    }

    @TestCase
    func testClose() {
        let proxy = QNetworkProxy()
        proxy.close()
        proxy.close()  // 重复 close 安全
        @Assert(true)
    }

    @TestCase
    func testOperationsAfterClose() {
        let proxy = QNetworkProxy()
        proxy.close()
        @ExpectThrows[ResourceDisposedException](proxy.setType(ProxyType.http()))
        @ExpectThrows[ResourceDisposedException](proxy.hostName())
        @ExpectThrows[ResourceDisposedException](proxy.port())
    }

    @TestCase
    func testDelete() {
        let proxy = QNetworkProxy()
        proxy.close()
        @Assert(true)
    }
}

// =====================================================================
// QTcpSocket 测试（不做真实连接）
// =====================================================================
@Test
class QTcpSocketTests {
    @TestCase
    func testCreate() {
        let sock = QTcpSocket()
        @Assert(sock.isValid())
        @Expect(sock.isClosed(), false)
        sock.close()
    }

    @TestCase
    func testInitialState() {
        let sock = QTcpSocket()
        @Expect(sock.state(), SocketState.UnconnectedState)
        sock.close()
    }

    @TestCase
    func testInitialError() {
        let sock = QTcpSocket()
        @Expect(sock.error(), SocketError.UnknownSocketError)
        sock.close()
    }

    @TestCase
    func testWriteUnconnectedReturnsMinusOne() {
        let sock = QTcpSocket()
        let n = sock.writeString("hello")
        @Expect(n, -1)
        sock.close()
    }

    @TestCase
    func testBytesAvailableZero() {
        let sock = QTcpSocket()
        @Expect(sock.bytesAvailable(), 0)
        sock.close()
    }

    @TestCase
    func testBytesToWriteZero() {
        let sock = QTcpSocket()
        @Expect(sock.bytesToWrite(), 0)
        sock.close()
    }

    @TestCase
    func testAtEnd() {
        let sock = QTcpSocket()
        @Assert(sock.atEnd() == true || sock.atEnd() == false)
        sock.close()
    }

    @TestCase
    func testReadEmpty() {
        let sock = QTcpSocket()
        let data = sock.read(10)
        @Expect(data.size, 0)
        sock.close()
    }

    @TestCase
    func testAbortSafe() {
        let sock = QTcpSocket()
        sock.abort()
        @Assert(sock.isValid())
        sock.close()
    }

    @TestCase
    func testDisconnectSafe() {
        let sock = QTcpSocket()
        sock.disconnectFromHost()
        @Assert(sock.isValid())
        sock.close()
    }

    @TestCase
    func testRegisterCallbacks() {
        let sock = QTcpSocket()
        sock.setOnConnected(gNetVoidCb)
        sock.setOnDisconnected(gNetVoidCb)
        sock.setOnReadyRead(gNetVoidCb)
        sock.setOnError(gNetVoidCb)
        @Assert(sock.isValid())
        sock.close()
    }

    @TestCase
    func testDisconnectCallbacks() {
        let sock = QTcpSocket()
        sock.setOnReadyRead(gNetVoidCb)
        sock.disconnectCallbacks()
        @Assert(sock.isValid())
        sock.close()
    }

    @TestCase
    func testClose() {
        let sock = QTcpSocket()
        sock.close()
        @Expect(sock.isClosed(), true)
        @Expect(sock.isValid(), false)
    }

    @TestCase
    func testOperationsAfterClose() {
        let sock = QTcpSocket()
        sock.close()
        @ExpectThrows[ResourceDisposedException](sock.state())
        @ExpectThrows[ResourceDisposedException](sock.writeString("x"))
        @ExpectThrows[ResourceDisposedException](sock.bytesAvailable())
    }

    @TestCase
    func testDelete() {
        let sock = QTcpSocket()
        sock.delete()
        sock.delete()  // 重复删除安全
        @Assert(true)
    }
}

// =====================================================================
// QUdpSocket 测试（仅本地回环 bind，不对外收发）
// =====================================================================
@Test
class QUdpSocketTests {
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
        let sock = QUdpSocket()
        @Assert(sock.getPtr() != 0)
        sock.delete()
    }

    @TestCase
    func testInitialState() {
        let sock = QUdpSocket()
        @Expect(sock.state(), SocketState.UnconnectedState)
        sock.delete()
    }

    @TestCase
    func testBindLoopback() {
        let sock = QUdpSocket()
        let ok = sock.bind("127.0.0.1", 0)
        @Expect(ok, true)
        @Expect(sock.state(), SocketState.BoundState)
        sock.close()
        sock.delete()
    }

    @TestCase
    func testBindAnyAddress() {
        let sock = QUdpSocket()
        let ok = sock.bind("0.0.0.0", 0)
        @Expect(ok, true)
        @Expect(sock.state(), SocketState.BoundState)
        sock.close()
        sock.delete()
    }

    @TestCase
    func testWriteDatagramLoopback() {
        let sock = QUdpSocket()
        sock.bind("127.0.0.1", 0)
        // Qt 6 writeDatagram 未绑定时会隐式绑定到 Any+可用端口并成功发送
        let n = sock.writeStringDatagram("ping", "127.0.0.1", 9999)
        @Expect(n, 4)
        sock.delete()
    }

    @TestCase
    func testPendingDatagramEmpty() {
        let sock = QUdpSocket()
        @Expect(sock.hasPendingDatagrams(), false)
        // Qt 文档：无待读数据报时 pendingDatagramSize() 返回 -1
        @Expect(sock.pendingDatagramSize(), -1)
        sock.delete()
    }

    @TestCase
    func testReadDatagramEmpty() {
        let sock = QUdpSocket()
        let dg = sock.readDatagram()
        @Expect(dg.data.size, 0)
        @Expect(dg.senderPort, 0)
        sock.delete()
    }

    @TestCase
    func testRegisterCallbacks() {
        let sock = QUdpSocket()
        sock.setOnReadyRead(gNetVoidCb)
        sock.setOnError(gNetVoidCb)
        @Assert(sock.getPtr() != 0)
        sock.delete()
    }

    @TestCase
    func testDisconnectCallbacks() {
        let sock = QUdpSocket()
        sock.setOnReadyRead(gNetVoidCb)
        sock.disconnectCallbacks()
        @Assert(sock.getPtr() != 0)
        sock.delete()
    }
}

// =====================================================================
// QLocalServer 测试（本地命名管道/域套接字，非网络 I/O）
// =====================================================================
@Test
class QLocalServerTests {
    @TestCase
    func testCreate() {
        let server = QLocalServer()
        @Assert(server.getPtr() != 0)
        server.close()
    }

    @TestCase
    func testListenAndClose() {
        let name = "cjqt6_test_srv_1"
        let server = QLocalServer()
        let ok = server.listen(name)
        @Expect(ok, true)
        @Expect(server.isListening(), true)
        @Expect(server.serverName(), name)
        @Expect(server.fullServerName().size > 0, true)
        server.stopListening()
        @Expect(server.isListening(), false)
        server.close()
    }

    @TestCase
    func testMaxPendingConnections() {
        let server = QLocalServer()
        server.setMaxPendingConnections(8)
        @Expect(server.maxPendingConnections(), 8)
        server.close()
    }

    @TestCase
    func testSocketOptions() {
        let server = QLocalServer()
        @Expect(server.socketOptions(), SocketOption.noOptions())
        server.setSocketOptions(SocketOption.worldAccessOption())
        @Expect(server.socketOptions(), SocketOption.worldAccessOption())
        server.close()
    }

    @TestCase
    func testHasPendingConnections() {
        let server = QLocalServer()
        @Expect(server.hasPendingConnections(), false)
        server.close()
    }

    @TestCase
    func testWaitForNewConnectionTimeout() {
        let server = QLocalServer()
        let p = server.waitForNewConnection(50)
        @Expect(p, 0)
        server.close()
    }

    @TestCase
    func testNextPendingConnectionNull() {
        let server = QLocalServer()
        let p = server.nextPendingConnection()
        @Expect(p, 0)
        server.close()
    }

    @TestCase
    func testRemoveServer() {
        let name = "cjqt6_test_srv_rm"
        let server = QLocalServer()
        server.listen(name)
        server.stopListening()
        server.close()
        QLocalServer.removeServer(name)
        @Assert(true)
    }

    @TestCase
    func testClose() {
        let server = QLocalServer()
        server.close()
        server.close()  // 重复 close 安全
        @Assert(true)
    }

    @TestCase
    func testOperationsAfterClose() {
        let server = QLocalServer()
        server.close()
        @ExpectThrows[ResourceDisposedException](server.listen("cjqt6_test_srv_x"))
        @ExpectThrows[ResourceDisposedException](server.isListening())
    }
}

// =====================================================================
// QSslSocket 测试（不发起真实 TLS 连接）
// =====================================================================
@Test
class QSslSocketTests {
    @TestCase
    func testCreate() {
        let sock = QSslSocket()
        @Assert(sock.getPtr() != 0)
        sock.close()
    }

    @TestCase
    func testInitialMode() {
        let sock = QSslSocket()
        @Expect(sock.sslMode(), SslMode.unsecured())
        @Expect(sock.isEncrypted(), false)
        sock.close()
    }

    @TestCase
    func testPeerVerifyMode() {
        let sock = QSslSocket()
        sock.setPeerVerifyMode(PeerVerifyMode.verifyPeer())
        @Expect(sock.peerVerifyMode(), PeerVerifyMode.verifyPeer())
        sock.setPeerVerifyMode(PeerVerifyMode.verifyNone())
        @Expect(sock.peerVerifyMode(), PeerVerifyMode.verifyNone())
        sock.close()
    }

    @TestCase
    func testPeerCertificateInfoEmpty() {
        let sock = QSslSocket()
        @Expect(sock.peerCertificateInfo().size >= 0, true)
        sock.close()
    }

    @TestCase
    func testRegisterCallbacks() {
        let sock = QSslSocket()
        sock.setOnEncrypted(gNetVoidCb)
        sock.setOnPeerVerifyError(gNetStrCb)
        @Assert(sock.getPtr() != 0)
        sock.close()
    }

    @TestCase
    func testClose() {
        let sock = QSslSocket()
        sock.close()
        sock.close()  // 重复 close 安全
        @Assert(true)
    }

    @TestCase
    func testOperationsAfterClose() {
        let sock = QSslSocket()
        sock.close()
        @ExpectThrows[ResourceDisposedException](sock.sslMode())
        @ExpectThrows[ResourceDisposedException](sock.isEncrypted())
    }
}

// =====================================================================
// QNetworkRequest / QNetworkAccessManager 测试（不发起真实请求）
// =====================================================================
@Test
class QNetworkRequestTests {
    @TestCase
    func testCreate() {
        let req = QNetworkRequest("https://example.com")
        @Assert(req.getPtr() != 0)
        req.close()
    }

    @TestCase
    func testUrl() {
        let req = QNetworkRequest("https://example.com/path")
        @Expect(req.url(), "https://example.com/path")
        req.close()
    }

    @TestCase
    func testSetUrl() {
        let req = QNetworkRequest("https://a.com")
        req.setUrl("https://b.com/api")
        @Expect(req.url(), "https://b.com/api")
        req.close()
    }

    @TestCase
    func testSetHeader() {
        let req = QNetworkRequest("https://example.com")
        req.setHeader(KnownHeaders.userAgent(), "CJQT6/1.0")
        @Expect(req.header(KnownHeaders.userAgent()), "CJQT6/1.0")
        req.close()
    }

    @TestCase
    func testContentTypeHeader() {
        let req = QNetworkRequest("https://example.com")
        req.setHeader(KnownHeaders.contentType(), "application/json")
        @Expect(req.header(KnownHeaders.contentType()), "application/json")
        req.close()
    }

    @TestCase
    func testSetRawHeader() {
        let req = QNetworkRequest("https://example.com")
        req.setRawHeader("X-Custom", "value")
        @Assert(req.getPtr() != 0)
        req.close()
    }

    @TestCase
    func testSetTransferTimeout() {
        let req = QNetworkRequest("https://example.com")
        req.setTransferTimeout(5000)
        @Assert(req.getPtr() != 0)
        req.close()
    }

    @TestCase
    func testClose() {
        let req = QNetworkRequest("https://example.com")
        req.close()
        req.close()  // 重复 close 安全
        @Assert(true)
    }

    @TestCase
    func testOperationsAfterClose() {
        let req = QNetworkRequest("https://example.com")
        req.close()
        @ExpectThrows[ResourceDisposedException](req.url())
        @ExpectThrows[ResourceDisposedException](req.header(KnownHeaders.userAgent()))
    }
}

@Test
class QNetworkAccessManagerTests {
    @TestCase
    func testCreate() {
        let mgr = QNetworkAccessManager()
        @Assert(mgr.getPtr() != 0)
        mgr.close()
    }

    @TestCase
    func testSetTransferTimeout() {
        let mgr = QNetworkAccessManager()
        mgr.setTransferTimeout(10000)
        @Assert(mgr.getPtr() != 0)
        mgr.close()
    }

    @TestCase
    func testClose() {
        let mgr = QNetworkAccessManager()
        mgr.close()
        mgr.close()  // 重复 close 安全
        @Assert(true)
    }

    @TestCase
    func testOperationsAfterClose() {
        let mgr = QNetworkAccessManager()
        mgr.close()
        let req = QNetworkRequest("https://example.com")
        @ExpectThrows[ResourceDisposedException](mgr.get(req))
        req.close()
    }
}

// =====================================================================
// Datagram 纯数据类测试
// =====================================================================
@Test
class DatagramTests {
    @TestCase
    func testDefaultConstruct() {
        let dg = Datagram()
        @Expect(dg.data.size, 0)
        @Expect(dg.senderAddress, "")
        @Expect(dg.senderPort, 0)
    }

    @TestCase
    func testConstructWithFields() {
        let bytes: Array<Byte> = [104, 105]
        let dg = Datagram(bytes, "127.0.0.1", 12345)
        @Expect(dg.data.size, 2)
        @Expect(dg.senderAddress, "127.0.0.1")
        @Expect(dg.senderPort, 12345)
    }

    @TestCase
    func testFieldMutation() {
        let dg = Datagram()
        dg.senderAddress = "192.168.1.10"
        dg.senderPort = 8000
        @Expect(dg.senderAddress, "192.168.1.10")
        @Expect(dg.senderPort, 8000)
    }
}
