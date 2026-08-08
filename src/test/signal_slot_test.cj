package cjqt6.test

import cjqt6.core.*
import cjqt6.widgets.*
import std.unittest.*

var gTimer: ?QTimer = None
var gReplaceA: Int32 = 0
var gReplaceB: Int32 = 0
var gHandleOld: Int32 = 0
var gHandleNew: Int32 = 0
var gPhase: Int32 = 0
var gConnOld: ?SignalConnection = None
var gConn2: ?SignalConnection = None
var gWatchdog: ?QTimer = None
var gApp: ?QApplication = None

@Test
class SignalSlotTests {

    @BeforeEach
    static func setUp(): Unit {
        gApp = Some(QApplication())
    }

    @AfterEach
    static func tearDown(): Unit {
        if (let Some(w) <- gWatchdog) {
            w.stop()
            w.close()
        }
        gWatchdog = None
        if (let Some(a) <- gApp) {
            a.delete()
        }
        gApp = None
        gTimer = None
        gConnOld = None
        gConn2 = None
    }

    static func armWatchdog(ms: Int32): Unit {
        let w = QTimer()
        gWatchdog = Some(w)
        w.setInterval(ms)
        w.setOnTimeout({ => QApp.quit() })
        w.start()
    }

    static func disarmWatchdog(): Unit {
        if (let Some(w) <- gWatchdog) {
            w.stop()
            w.close()
        }
        gWatchdog = None
    }

    @TestCase
    func testReplaceSemantics() {
        gReplaceA = 0
        gReplaceB = 0
        let timer = QTimer()
        gTimer = Some(timer)
        timer.setInterval(10)

        timer.setOnTimeout({ => gReplaceA += 1 })
        timer.setOnTimeout({ =>
            gReplaceB += 1
            if (gReplaceB >= 3) {
                if (let Some(t) <- gTimer) { t.stop() }
                QApp.quit()
            }
        })

        armWatchdog(3000)
        timer.start()
        if (let Some(a) <- gApp) { a.exec() }
        disarmWatchdog()

        @Expect(gReplaceA, 0)
        @Expect(gReplaceB, 3)
        timer.close()
    }

    @TestCase
    func testHandleDisconnect() {
        gHandleOld = 0
        gHandleNew = 0
        gPhase = 0
        gConn2 = None

        let timer = QTimer()
        gTimer = Some(timer)
        timer.setInterval(10)

        let conn = timer.setOnTimeout({ =>
            if (gPhase == 0) {
                gHandleOld += 1
                if (gHandleOld >= 2) {
                    if (let Some(c) <- gConnOld) { c.disconnect() }
                    if (let Some(t) <- gTimer) {
                        gConn2 = t.setOnTimeout({ =>
                            gHandleNew += 1
                            if (gHandleNew >= 3) {
                                if (let Some(gt) <- gTimer) { gt.stop() }
                                QApp.quit()
                            }
                        })
                    }
                    gPhase = 1
                }
            }
        })
        gConnOld = Some(conn)
        @Expect(conn.isConnected(), true)

        armWatchdog(3000)
        timer.start()
        if (let Some(a) <- gApp) { a.exec() }
        disarmWatchdog()

        @Expect(gHandleOld, 2)
        @Expect(gHandleNew, 3)
        @Expect(conn.isConnected(), false)
        if (let Some(c2) <- gConn2) {
            @Expect(c2.isConnected(), true)
        } else {
            @Fail("new connection was not created")
        }
        timer.close()
    }

    @TestCase
    func testButtonPressedHandle() {
        let btn = QPushButton()
        let conn = btn.setOnPressed({ => /* offscreen */ })
        @Expect(conn.isConnected(), true)

        conn.disconnect()
        @Expect(conn.isConnected(), false)

        let conn2 = btn.setOnPressed({ => /* offscreen */ })
        @Expect(conn2.isConnected(), true)
        conn2.disconnect()
        btn.close()
    }
}
