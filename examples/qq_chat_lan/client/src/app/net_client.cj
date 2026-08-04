// ============================================================
// QQ局域网聊天 - 客户端网络层
// 负责：连接服务器、注册事件回调、按行分帧、发送请求帧、
//       连接超时控制。解析后的帧交给 handlers.cj 分发。
// ============================================================
package qq_lan_client.app

import cjqt6.core.*
import cjqt6.network.*
import qq_lan_client.core.*
import std.convert.*

/// 全局唯一套接字
public var gSocket: ?QTcpSocket = None

/// TCP 连接是否建立
public var gConnected: Bool = false

/// 是否已登录（login_ok 之后为 true）
public var gLoggedIn: Bool = false

/// 接收缓冲
public var gBuffer: Array<Byte> = []

/// 连接探测定时器（等待 connected / 超时判定）
public var gConnectTimer: ?QTimer = None
public var gConnectTicks: Int64 = 0

/// 连接成功后待发送的登录请求
public var gPendingAccount: Int64 = 0
public var gPendingPassword: String = ""

/// 连接成功后待发送的注册请求（与登录二选一）
public var gPendingRegister: Bool = false
public var gPendingRegNickname: String = ""
public var gPendingRegPassword: String = ""

/// 顶层定时器回调（CFunc 不能捕获变量）
let onConnectTick: VoidCallback = { => connectTick() }

/// 解析 "host:port" 或 "host"（默认端口 9600）
public func parseServerAddress(addr: String): (String, UInt16) {
    var host = addr
    var port: UInt16 = 9600
    var colonPos: Int64 = -1
    var i: Int64 = 0
    while (i < addr.size) {
        if (addr[i] == 58) { colonPos = i }
        i++
    }
    if (colonPos >= 0 && colonPos + 1 < addr.size) {
        host = addr[0..colonPos]
        let portStr = addr[(colonPos + 1)..addr.size]
        if (let Some(p) <- Int64.tryParse(portStr)) {
            if (p > 0 && p < 65536) {
                port = UInt16(p)
            }
        }
    }
    if (host.isEmpty()) { host = "127.0.0.1" }
    (host, port)
}

/// 发起连接并排队登录请求；连接结果由 connectTick 与事件回调驱动
public func startLogin(host: String, port: UInt16, account: Int64, password: String): Unit {
    // 已连接则直接发登录帧
    if (gConnected) {
        if (let Some(s) <- gSocket) {
            if (s.isValid()) {
                gPendingRegister = false
                sendLoginFrame(account, password)
                setLoginStatus("正在登录...")
                return
            }
        }
    }
    gPendingRegister = false
    gPendingAccount = account
    gPendingPassword = password
    beginConnect(host, port, "正在连接服务器 ${host}:${port} ...")
}

/// 发起连接并排队注册请求（注册对话框在登录页使用）
public func startRegister(host: String, port: UInt16, nickname: String, password: String): Unit {
    if (gConnected) {
        if (let Some(s) <- gSocket) {
            if (s.isValid()) {
                sendRegisterFrame(nickname, password)
                setRegisterStatus("正在注册...")
                return
            }
        }
    }
    gPendingRegister = true
    gPendingRegNickname = nickname
    gPendingRegPassword = password
    beginConnect(host, port, "正在连接服务器 ${host}:${port} ...")
}

/// 共享的连接建立流程：建套接字、注册回调、启动探测定时器
public func beginConnect(host: String, port: UInt16, statusText: String): Unit {
    closeSocketQuiet()
    gBuffer = []
    gConnectTicks = 0

    let sock = QTcpSocket()
    gSocket = sock
    let _ = sock.setOnConnectedCapture({ => onSocketConnected() })
    let _ = sock.setOnReadyReadCapture({ => onNetData() })
    let _ = sock.setOnDisconnectedCapture({ => onNetDisconnected() })
    let _ = sock.setOnErrorCapture({ => onNetError() })
    sock.connectToHost(host, port)
    setLoginStatus(statusText)

    // 定时器：每 200ms 检查一次，最多等待 4 秒
    let timer = QTimer()
    timer.setInterval(200)
    timer.setOnTimeout(onConnectTick)
    timer.start()
    gConnectTimer = timer
}

/// 连接探测：成功则发登录帧；超时则提示失败
public func connectTick(): Unit {
    if (gConnected) {
        stopConnectTimer()
        return
    }
    gConnectTicks++
    if (gConnectTicks >= 20) {
        stopConnectTimer()
        setLoginStatus("连接超时，请检查服务器地址与端口")
        closeSocketQuiet()
    }
}

public func stopConnectTimer(): Unit {
    if (let Some(t) <- gConnectTimer) {
        t.stop()
        t.close()
        gConnectTimer = None
    }
}

/// TCP 连接建立
public func onSocketConnected(): Unit {
    gConnected = true
    stopConnectTimer()
    if (gPendingRegister) {
        sendRegisterFrame(gPendingRegNickname, gPendingRegPassword)
        setRegisterStatus("已连接，正在注册...")
    } else {
        sendLoginFrame(gPendingAccount, gPendingPassword)
        setLoginStatus("已连接，正在登录...")
    }
}

/// 发送登录帧
public func sendLoginFrame(account: Int64, password: String): Unit {
    sendRaw("{\"type\":\"login\",\"account\":${account},\"password\":\"${escapeJson(password)}\"}")
}

/// 发送注册帧
public func sendRegisterFrame(nickname: String, password: String): Unit {
    sendRaw("{\"type\":\"register\",\"nickname\":\"${escapeJson(nickname)}\",\"password\":\"${escapeJson(password)}\"}")
}

/// 数据到达：追加缓冲，按 \n 切帧交给 handleFrame
public func onNetData(): Unit {
    if (let Some(sock) <- gSocket) {
        let chunk = sock.readAll()
        if (chunk.size > 0) {
            gBuffer = gBuffer.concat(chunk)
        }
        if (gBuffer.size > 1024 * 1024) {
            gBuffer = []
            return
        }
        var start: Int64 = 0
        var i: Int64 = 0
        while (i < gBuffer.size) {
            if (gBuffer[i] == 10u8) {
                let lineBytes = gBuffer[start..i]
                let line = String.fromUtf8(lineBytes)
                start = i + 1
                if (!line.isEmpty()) {
                    handleFrame(line)
                }
            }
            i++
        }
        if (start > 0) {
            if (start < gBuffer.size) {
                gBuffer = gBuffer[start..gBuffer.size]
            } else {
                gBuffer = []
            }
        }
    }
}

/// 连接错误（连接阶段的失败提示；已登录时交给断开逻辑）
public func onNetError(): Unit {
    if (!gConnected && !gLoggedIn) {
        stopConnectTimer()
        setLoginStatus("无法连接服务器，请检查地址/端口或防火墙")
    }
}

/// 连接断开
public func onNetDisconnected(): Unit {
    let wasLoggedIn = gLoggedIn
    gConnected = false
    gLoggedIn = false
    stopConnectTimer()
    if (wasLoggedIn) {
        handleLoggedOut("与服务器失去连接")
    }
}

/// 发送一帧 JSON（自动追加换行符）
public func sendRaw(json: String): Unit {
    if (let Some(sock) <- gSocket) {
        if (sock.isValid() && gConnected) {
            let _ = sock.writeString(json + "\n")
            let _ = sock.flush()
        }
    }
}

/// 静默关闭套接字（登录失败/重试连接时使用）
public func closeSocketQuiet(): Unit {
    stopConnectTimer()
    if (let Some(sock) <- gSocket) {
        gSocket = None
        sock.disconnectCallbacks()
        sock.close()
    }
    gConnected = false
}

/// 退出登录：通知服务端并关闭连接
public func logoutAndClose(): Unit {
    gLoggedIn = false
    gConnected = false
    if (let Some(sock) <- gSocket) {
        gSocket = None
        sock.disconnectCallbacks()
        sock.close()
    }
}
