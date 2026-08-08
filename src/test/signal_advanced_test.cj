package cjqt6.test

import cjqt6.core.*
import cjqt6.widgets.*
import std.unittest.*

// 全局状态：CFunc 回调函数内无法捕获局部变量，必须使用包级全局变量
var gAlarmApp: ?QApplication = None
var gAlarmCount: Int32 = 0
var gAlarmTimer: ?QTimer = None
var gAlarmWatchdog: ?QTimer = None
var gAlarmConn: ?SignalConnection = None

@Test
class SignalAdvancedTests {

    @BeforeEach
    static func setUp(): Unit {
        gAlarmCount = 0
        gAlarmTimer = None
        gAlarmWatchdog = None
        gAlarmConn = None
    }

    @AfterEach
    static func tearDown(): Unit {
        if (let Some(t) <- gAlarmTimer) { t.close() }
        if (let Some(w) <- gAlarmWatchdog) { w.close() }
        if (let Some(a) <- gAlarmApp) { a.delete() }
        gAlarmTimer = None
        gAlarmWatchdog = None
        gAlarmApp = None
        gAlarmConn = None
    }

    /// 安全看门狗：超时后强制退出事件循环
    static func armWatchdog(ms: Int32): Unit {
        let w = QTimer()
        gAlarmWatchdog = Some(w)
        w.setInterval(ms)
        w.setOnTimeout({ => QApp.quit() })
        w.start()
    }

    /// 多个 onTimeout 替换：最后一个绑定生效
    @TestCase
    func testMultipleSignalReplacements() {
        gAlarmCount = 0

        let app = QApplication()
        gAlarmApp = Some(app)
        armWatchdog(3000)

        let timer = QTimer()
        gAlarmTimer = Some(timer)
        timer.setInterval(10)

        // 设置 -> 替换 -> 替换：只有最后一个应该触发
        timer.setOnTimeout({ => gAlarmCount += 1 })
        timer.setOnTimeout({ => gAlarmCount += 10 })
        timer.setOnTimeout({ =>
            gAlarmCount += 1
            if (gAlarmCount >= 3) {
                if (let Some(t) <- gAlarmTimer) { t.stop() }
                QApp.quit()
            }
        })

        timer.start()
        app.exec()

        @Expect(gAlarmCount, 3)  // 只有最后一个绑定触发了 3 次
        timer.close()
    }

    /// SignalConnection 使用句柄方式断开
    @TestCase
    func testConnectionHandleReturned() {
        gAlarmCount = 0

        let app = QApplication()
        gAlarmApp = Some(app)
        armWatchdog(3000)

        let timer = QTimer()
        gAlarmTimer = Some(timer)
        timer.setInterval(10)

        let conn = timer.setOnTimeout({ =>
            gAlarmCount += 1
            if (gAlarmCount >= 2) {
                if (let Some(t) <- gAlarmTimer) { t.stop() }
                QApp.quit()
            }
        })

        @Expect(conn.isConnected(), true)
        timer.start()
        app.exec()

        @Expect(gAlarmCount, 2)
        conn.disconnect()
        @Expect(conn.isConnected(), false)
        timer.close()
    }

    /// 验证信号 API 层面的连接/断开（不触发事件循环）
    @TestCase
    func testCallbackConnectionApi() {
        let btn = QPushButton()
        let conn = btn.setOnPressed({ => /* noop */ })
        @Expect(conn.isConnected(), true)
        conn.disconnect()
        @Expect(conn.isConnected(), false)
        btn.close()
    }

    /// 事件循环内多次 disconnect/reconnect
    @TestCase
    func testDisconnectReconnectCycle() {
        gAlarmCount = 0

        let app = QApplication()
        gAlarmApp = Some(app)
        armWatchdog(3000)

        let timer = QTimer()
        gAlarmTimer = Some(timer)
        timer.setInterval(10)

        // 第一次连接
        let conn1 = timer.setOnTimeout({ =>
            gAlarmCount += 1
        })

        // 断开并重新连接
        conn1.disconnect()
        @Expect(conn1.isConnected(), false)

        let conn2 = timer.setOnTimeout({ =>
            gAlarmCount += 100
            if (gAlarmCount >= 300) {
                if (let Some(t) <- gAlarmTimer) { t.stop() }
                QApp.quit()
            }
        })
        @Expect(conn2.isConnected(), true)

        timer.start()
        app.exec()

        @Expect(gAlarmCount, 300)  // 只有 conn2 触发（conn1 已断开）
        timer.close()
    }
}

// =====================================================================
// 信号生命周期测试
// =====================================================================
@Test
class QSignalLifecycleTests {

    @TestCase
    func testDisconnectAfterResourceClosed() {
        let timer = QTimer()
        let conn = timer.setOnTimeout({ => /* noop */ })
        timer.close()

        // 控件关闭后 SignalConnection 应该仍可安全调用 disconnect
        conn.disconnect()
        @Assert(true)
    }

    @TestCase
    func testMultipleComponentsSignals() {
        let btn = QPushButton()
        let btn2 = QPushButton()

        let conn1 = btn.setOnPressed({ => /* noop */ })
        let conn2 = btn2.setOnPressed({ => /* noop */ })

        @Expect(conn1.isConnected(), true)
        @Expect(conn2.isConnected(), true)

        conn1.disconnect()
        @Expect(conn1.isConnected(), false)
        @Expect(conn2.isConnected(), true)  // 另一个不受影响

        conn2.disconnect()
        @Expect(conn2.isConnected(), false)

        btn2.close()
        btn.close()
    }

    @TestCase
    func testButtonSignalsIndependence() {
        let btn1 = QPushButton()
        let btn2 = QPushButton()

        let conn1 = btn1.setOnPressed({ => /* noop */ })
        let conn2 = btn2.setOnPressed({ => /* noop */ })

        @Expect(conn1.isConnected(), true)
        @Expect(conn2.isConnected(), true)

        // 通过 SignalConnection handle 断开：不影响其他
        conn1.disconnect()
        @Expect(conn1.isConnected(), false)
        @Expect(conn2.isConnected(), true)

        conn2.disconnect()
        @Expect(conn2.isConnected(), false)

        btn2.close()
        btn1.close()
    }

    @TestCase
    func testCheckboxStateChangedApi() {
        let cb = QCheckBox()
        cb.setOnStateChanged({ x: Int32 => /* noop */ })
        @Assert(cb.isValid())
        cb.disconnectStateChanged()
        @Assert(cb.isValid())
        cb.close()
    }

    @TestCase
    func testButtonToggledApi() {
        let btn = QPushButton()
        let conn = btn.setOnToggled({ x: Int32 => /* noop */ })
        @Expect(conn.isConnected(), true)
        conn.disconnect()
        @Expect(conn.isConnected(), false)
        btn.close()
    }
}
