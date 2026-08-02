# CJQT6 网络模块

本模块提供 TCP/UDP 网络通信功能和 IP 地址封装。

## 模块导入

```cangjie
import cjqt6.network.*
```

## IP 地址

### QHostAddress - IP 地址封装

支持 IPv4 和 IPv6 地址。

```cangjie
// 创建空地址
let addr = QHostAddress()

// 从字符串创建
let addr2 = QHostAddress("127.0.0.1")
let addr3 = QHostAddress("::1")

// 设置地址
addr.setAddress("192.168.1.1")

// 地址转字符串
let str = addr.toString()

// 协议类型
let proto = addr.protocol()  // 0=IPv4, 1=IPv6, 2=AnyIP

// 判断是否为空
if (addr.isNull()) {
    println("地址为空")
}

// 地址比较
if (addr.equal("192.168.1.1")) {
    println("地址匹配")
}

// 常用地址常量
let localhost = HostAddress.LocalHost()      // 127.0.0.1
let localhost6 = HostAddress.LocalHostIPv6()  // ::1
let any = HostAddress.Any()                   // 0.0.0.0
let any6 = HostAddress.AnyIPv6()              // ::
let broadcast = HostAddress.Broadcast()       // 255.255.255.255
```

**QHostAddress 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建空地址 |
| `init(address: String)` | 从字符串创建地址 |
| `setAddress(address: String)` | 设置地址 |
| `toString(): String` | 转为字符串 |
| `protocol(): Int32` | 获取协议类型（0=IPv4, 1=IPv6, 2=AnyIP） |
| `isNull(): Bool` | 是否为空 |
| `equal(address: String): Bool` | 判断是否等于指定地址 |
| `getPtr(): Int64` | 获取指针 |
| `delete()` | 释放资源 |

**协议常量** (`NetworkProtocol`):
| 常量 | 值 | 说明 |
|------|-----|------|
| `NetworkProtocol.IPv4` | 0 | IPv4 |
| `NetworkProtocol.IPv6` | 1 | IPv6 |
| `NetworkProtocol.AnyIP` | 2 | 任意协议 |

**地址常量** (`HostAddress`):
| 常量 | 说明 |
|------|------|
| `HostAddress.LocalHost()` | 本地回环地址 (127.0.0.1) |
| `HostAddress.LocalHostIPv6()` | IPv6 本地回环地址 (::1) |
| `HostAddress.Any()` | 任意地址 (0.0.0.0) |
| `HostAddress.AnyIPv6()` | IPv6 任意地址 (::) |
| `HostAddress.Broadcast()` | 广播地址 (255.255.255.255) |

---

## QTcpSocket - TCP 套接字

提供 TCP 客户端功能，支持连接、读写、断开等操作。

```cangjie
let socket = QTcpSocket()

// 连接到服务器
socket.connectToHost("127.0.0.1", 8080)

// 发送数据
let data: Array<Byte> = [72, 101, 108, 108, 111]  // "Hello"
socket.write(data)
socket.writeString("Hello Server!")

// 读取数据
let response = socket.read(1024)        // 读取最多1024字节
let allData = socket.readAll()          // 读取所有可用数据
let text = socket.readString(1024)      // 读取为字符串

// 检查状态
let state = socket.state()              // 查看连接状态
let available = socket.bytesAvailable() // 可读取字节数
let pending = socket.bytesToWrite()     // 待写入字节数
socket.flush()                          // 刷新缓冲区

// 信号回调
socket.setOnConnected({ =>
    println("连接成功！")
})

socket.setOnDisconnected({ =>
    println("连接断开")
})

socket.setOnReadyRead({ =>
    println("收到数据！")
    let data = socket.readAll()
})

socket.setOnError({ =>
    println("连接错误: ${socket.errorString()}")
})

// 断开连接
socket.disconnectFromHost()
socket.close()
socket.delete()
```

**QTcpSocket 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建 TCP 套接字 |
| `connectToHost(host: String, port: UInt16)` | 连接到主机 |
| `disconnectFromHost()` | 断开连接 |
| `write(data: Array<Byte>): Int64` | 写入数据（返回写入字节数） |
| `writeString(text: String): Int64` | 写入字符串 |
| `read(maxSize: Int64): Array<Byte>` | 读取数据 |
| `readAll(): Array<Byte>` | 读取所有可用数据 |
| `readString(maxSize: Int64): String` | 读取为字符串 |
| `bytesAvailable(): Int64` | 可读取字节数 |
| `bytesToWrite(): Int64` | 待写入字节数 |
| `flush(): Bool` | 刷新缓冲区 |
| `atEnd(): Bool` | 是否到达末尾 |
| `state(): Int32` | 获取套接字状态 |
| `error(): Int32` | 获取错误码 |
| `errorString(): String` | 获取错误描述 |
| `isValid(): Bool` | 是否有效 |
| `close()` | 关闭套接字 |
| `setOnConnected(callback: VoidCallback)` | 连接成功回调 |
| `setOnDisconnected(callback: VoidCallback)` | 断开连接回调 |
| `setOnReadyRead(callback: VoidCallback)` | 数据就绪回调 |
| `setOnError(callback: VoidCallback)` | 错误回调 |
| `disconnectCallbacks()` | 断开所有信号连接 |
| `getPtr(): Int64` | 获取指针 |
| `delete()` | 释放资源 |

**Socket 状态常量** (`SocketState`):
| 常量 | 值 | 说明 |
|------|-----|------|
| `SocketState.UnconnectedState` | 0 | 未连接 |
| `SocketState.HostLookupState` | 1 | 正在查找主机 |
| `SocketState.ConnectingState` | 2 | 正在连接 |
| `SocketState.ConnectedState` | 3 | 已连接 |
| `SocketState.BoundState` | 4 | 已绑定 |
| `SocketState.ListeningState` | 5 | 正在监听 |
| `SocketState.ClosingState` | 6 | 正在关闭 |

**Socket 错误常量** (`SocketError`):
| 常量 | 说明 |
|------|------|
| `SocketError.ConnectionRefusedError` | 连接被拒绝 |
| `SocketError.RemoteHostClosedError` | 远程主机关闭连接 |
| `SocketError.HostNotFoundError` | 主机未找到 |
| `SocketError.SocketAccessError` | 套接字访问错误 |
| `SocketError.SocketResourceError` | 套接字资源错误 |
| `SocketError.SocketTimeoutError` | 套接字超时 |
| `SocketError.NetworkError` | 网络错误 |
| `SocketError.AddressInUseError` | 地址已被使用 |

---

## QUdpSocket - UDP 套接字

提供 UDP 通信功能，支持数据报的收发。

```cangjie
let udpSocket = QUdpSocket()

// 绑定到指定端口
udpSocket.bind(8888)
// 或绑定到指定地址和端口
// udpSocket.bind("192.168.1.1", 8888)

// 发送数据报
let data: Array<Byte> = [72, 101, 108, 108, 111]
udpSocket.writeDatagram(data, "127.0.0.1", 8888)
udpSocket.writeStringDatagram("Hello UDP!", "127.0.0.1", 8888)

// 接收数据报
if (udpSocket.hasPendingDatagrams()) {
    let datagram = udpSocket.readDatagram()
    println("收到来自 ${datagram.senderAddress}:${datagram.senderPort} 的数据: ${datagram.data}")
}

// 信号回调
udpSocket.setOnReadyRead({ =>
    while (udpSocket.hasPendingDatagrams()) {
        let dgram = udpSocket.readDatagram()
        // 处理数据报
    }
})

udpSocket.close()
udpSocket.delete()
```

**QUdpSocket 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建 UDP 套接字 |
| `bind(address: String, port: UInt16): Bool` | 绑定到指定地址和端口 |
| `bind(port: UInt16): Bool` | 绑定到任意地址的指定端口 |
| `close()` | 关闭套接字 |
| `writeDatagram(data, host, port): Int64` | 发送数据报 |
| `writeStringDatagram(text, host, port): Int64` | 发送字符串数据报 |
| `readDatagram(): Datagram` | 读取数据报 |
| `hasPendingDatagrams(): Bool` | 是否有待读取的数据报 |
| `pendingDatagramSize(): Int64` | 待读取数据报的大小 |
| `state(): Int32` | 获取套接字状态 |
| `error(): Int32` | 获取错误码 |
| `errorString(): String` | 获取错误描述 |
| `isValid(): Bool` | 是否有效 |
| `setOnReadyRead(callback: VoidCallback)` | 数据就绪回调 |
| `setOnError(callback: VoidCallback)` | 错误回调 |
| `disconnectCallbacks()` | 断开所有信号连接 |
| `getPtr(): Int64` | 获取指针 |
| `delete()` | 释放资源 |

**Datagram 属性**:
| 属性 | 类型 | 说明 |
|------|------|------|
| `data` | `Array<Byte>` | 数据内容 |
| `senderAddress` | `String` | 发送者地址 |
| `senderPort` | `UInt16` | 发送者端口 |

---

## QLocalServer - 本地服务器

通过 Unix 域套接字（Unix）或 Windows 命名管道（Windows）提供进程间通信（IPC）。

```cangjie
let server = QLocalServer()
if (server.listen("my_app_server")) {
    println("监听中: ${server.serverName()}")
    println("完整名称: ${server.fullServerName()}")
}

server.setMaxPendingConnections(10)
server.setSocketOptions(SocketOption.userAccessOption())

// 阻塞等待新连接（返回已连接的 QLocalSocket 指针，无连接返回 0）
let sockPtr = server.waitForNewConnection(3000)

// 或非阻塞检查挂起连接
if (server.hasPendingConnections()) {
    let sockPtr = server.nextPendingConnection()
}

server.stopListening()  // 停止监听
server.close()          // 释放资源
QLocalServer.removeServer("my_app_server")  // 移除服务器（静态方法）
```

**QLocalServer 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建本地服务器 |
| `listen(name: String): Bool` | 开始监听指定名称，返回是否成功 |
| `stopListening()` | 停止监听（对应 Qt 的 close） |
| `isListening(): Bool` | 是否正在监听 |
| `serverName(): String` | 获取服务器名称 |
| `fullServerName(): String` | 获取完整服务器名称（含平台前缀，如 Windows 管道路径） |
| `maxPendingConnections(): Int32` / `setMaxPendingConnections(count)` | 获取/设置最大挂起连接数 |
| `waitForNewConnection(msec: Int32): Int64` | 阻塞等待新连接，返回 QLocalSocket 指针（无连接返回 0） |
| `hasPendingConnections(): Bool` | 是否有挂起的连接 |
| `nextPendingConnection(): Int64` | 获取下一个挂起连接的 QLocalSocket 指针 |
| `setSocketOptions(options)` / `socketOptions(): Int32` | 设置/获取套接字访问权限（SocketOption 组合） |
| `removeServer(name: String): Bool` | 移除指定名称的服务器（静态方法） |
| `getPtr(): Int64` | 获取指针 |
| `close()` | 释放资源 |

**SocketOption 访问权限常量**（可按位组合）:
| 常量 | 值 | 说明 |
|------|-----|------|
| `SocketOption.noOptions()` | 0 | 无特殊权限 |
| `SocketOption.userAccessOption()` | 1 | 仅用户可访问 |
| `SocketOption.groupAccessOption()` | 2 | 同组用户可访问 |
| `SocketOption.otherAccessOption()` | 4 | 其他用户可访问 |
| `SocketOption.worldAccessOption()` | 7 | 所有用户可访问（1\|2\|4） |

---

## QNetworkAccessManager - 网络访问管理器

发送 HTTP 请求（GET/POST/PUT/DELETE），异步返回 `QNetworkReply` 对象。

```cangjie
let manager = QNetworkAccessManager()
manager.setTransferTimeout(5000)  // 5秒超时

let request = QNetworkRequest("https://example.com/api")
request.setHeader(KnownHeaders.userAgent(), "CJQT6/1.0")

let reply = manager.get(request)
reply.setOnFinished({ replyPtr: Int64 =>
    // 在回调中通过指针读取结果（注意：回调内勿直接 delete reply）
    println("状态码: ${reply.statusCode()}")
    println("响应体: ${reply.readAll()}")
})

// POST 请求
let req2 = QNetworkRequest("https://example.com/login")
req2.setHeader(KnownHeaders.contentType(), "application/json")
let reply2 = manager.post(req2, "{\"user\":\"alice\"}")

manager.close()  // 释放资源
```

**QNetworkAccessManager 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建网络访问管理器 |
| `get(request: QNetworkRequest): QNetworkReply` | 发送 GET 请求 |
| `post(request, data: String): QNetworkReply` | 发送 POST 请求 |
| `put(request, data: String): QNetworkReply` | 发送 PUT 请求 |
| `deleteResource(request): QNetworkReply` | 发送 DELETE 请求 |
| `setTransferTimeout(timeoutMs: Int32)` | 设置传输超时（毫秒） |
| `getPtr(): Int64` | 获取指针 |
| `close()` | 释放资源 |

---

## QNetworkRequest - 网络请求

描述一个 HTTP 请求的 URL、请求头等信息。

```cangjie
let request = QNetworkRequest("https://example.com/api")
request.setUrl("https://example.com/v2/api")   // 修改 URL
request.setHeader(KnownHeaders.userAgent(), "Mozilla/5.0")
request.setRawHeader("X-Api-Key", "secret123") // 自定义原始头
request.setTransferTimeout(10000)              // 10秒超时

let url = request.url()      // 获取 URL
let ua = request.header(KnownHeaders.userAgent())  // 获取请求头
request.close()
```

**QNetworkRequest 方法**:
| 方法 | 说明 |
|------|------|
| `init(url: String)` | 从 URL 创建网络请求 |
| `setUrl(url)` / `url(): String` | 设置/获取 URL |
| `setHeader(header: Int32, value: String)` | 设置已知 HTTP 头 |
| `header(header: Int32): String` | 获取已知 HTTP 头 |
| `setRawHeader(name: String, value: String)` | 设置原始 HTTP 头 |
| `setTransferTimeout(timeoutMs: Int32)` | 设置传输超时（毫秒） |
| `getPtr(): Int64` | 获取指针 |
| `close()` | 释放资源 |

**KnownHeaders 已知 HTTP 头常量**:
| 常量 | 值 | 说明 |
|------|-----|------|
| `KnownHeaders.contentType()` | 0 | Content-Type |
| `KnownHeaders.contentLength()` | 1 | Content-Length |
| `KnownHeaders.location()` | 2 | Location |
| `KnownHeaders.lastModified()` | 3 | Last-Modified |
| `KnownHeaders.cookie()` | 4 | Cookie |
| `KnownHeaders.setCookie()` | 5 | Set-Cookie |
| `KnownHeaders.userAgent()` | 6 | User-Agent |
| `KnownHeaders.referer()` | 7 | Referer |
| `KnownHeaders.server()` | 8 | Server |

---

## QNetworkReply - 网络响应

网络请求的响应对象，由 `QNetworkAccessManager` 的请求方法返回。**不可直接构造**。

```cangjie
let reply = manager.get(request)
println("状态码: ${reply.statusCode()}")
println("错误码: ${reply.error()} / ${reply.errorString()}")
println("响应头: ${reply.header(KnownHeaders.contentType())}")

reply.setOnFinished({ replyPtr: Int64 =>
    if (reply.isFinished()) {
        let body = reply.readAll()
        println("响应体: ${body}")
    }
})

if (reply.isRunning()) {
    reply.abort()  // 中止请求
}
reply.close()  // 释放资源（内部使用 deleteLater 保证线程安全）
```

**QNetworkReply 方法**:
| 方法 | 说明 |
|------|------|
| `readAll(): String` | 读取所有响应数据 |
| `bytesAvailable(): Int64` | 获取可用字节数 |
| `error(): Int32` | 获取错误码 |
| `errorString(): String` | 获取错误描述 |
| `statusCode(): Int32` | 获取 HTTP 状态码 |
| `header(header: Int32): String` | 获取响应头 |
| `isFinished(): Bool` | 请求是否完成 |
| `isRunning(): Bool` | 请求是否进行中 |
| `abort()` | 中止请求 |
| `url(): String` | 获取请求 URL |
| `setOnFinished(callback: Int64Callback)` | 请求完成回调（参数为 reply 指针） |
| `getPtr(): Int64` | 获取指针 |
| `close()` | 释放资源 |

> 注意：`setOnFinished` 回调参数为底层 reply 指针（Int64），若需访问封装对象请在闭包外捕获 reply 引用；回调内请勿直接 `close()` 该对象。

---

## QNetworkProxy - 网络代理

描述代理服务器的类型、主机、端口及认证信息，可设置为应用级代理。

```cangjie
let proxy = QNetworkProxy(ProxyType.http())
proxy.setHostName("proxy.example.com")
proxy.setPort(8080)
proxy.setUser("alice")
proxy.setPassword("secret")

// 设为应用级代理（静态方法，影响所有网络请求）
QNetworkProxy.setApplicationProxy("proxy.example.com", 8080)

proxy.close()
```

**QNetworkProxy 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建默认代理配置（NoProxy） |
| `init(proxyType: Int32)` | 创建指定类型的代理配置 |
| `setType(proxyType)` / `proxyType(): Int32` | 设置/获取代理类型 |
| `setHostName(host)` / `hostName(): String` | 设置/获取代理主机名 |
| `setPort(port: UInt16)` / `port(): UInt16` | 设置/获取代理端口 |
| `setUser(user)` / `user(): String` | 设置/获取认证用户名 |
| `setPassword(pass)` / `password(): String` | 设置/获取认证密码 |
| `setApplicationProxy(host, port)` | 设为应用级代理（静态方法） |
| `getPtr(): Int64` | 获取指针 |
| `close()` | 释放资源 |

**ProxyType 代理类型常量**:
| 常量 | 值 | 说明 |
|------|-----|------|
| `ProxyType.noProxy()` | 0 | 不使用代理 |
| `ProxyType.defaultProxy()` | 1 | 使用系统默认代理 |
| `ProxyType.socks5()` | 2 | SOCKS5 代理 |
| `ProxyType.http()` | 3 | HTTP 代理 |
| `ProxyType.httpCaching()` | 4 | HTTP 缓存代理 |
| `ProxyType.ftpCaching()` | 5 | FTP 缓存代理 |

---

## QSslSocket - SSL/TLS 加密套接字

提供加密的网络通信（如 HTTPS），支持客户端/服务端加密模式与对端证书验证。

```cangjie
let sslSocket = QSslSocket()
sslSocket.setPeerVerifyMode(PeerVerifyMode.verifyNone())  // 跳过证书验证（仅测试用）

sslSocket.setOnEncrypted({ =>
    println("加密完成！")
})

sslSocket.setOnPeerVerifyError({ err: String =>
    println("证书验证错误: ${err}")
})

sslSocket.connectToHostEncrypted("example.com", 443)

// 已建立 TCP 连接后升级为加密
// sslSocket.startClientEncryption()

if (sslSocket.isEncrypted()) {
    println("模式: ${sslSocket.sslMode()}")
    println("对端证书: ${sslSocket.peerCertificateInfo()}")
}

sslSocket.close()
```

**QSslSocket 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建 SSL 套接字 |
| `connectToHostEncrypted(host: String, port: UInt16)` | 连接到加密主机 |
| `startClientEncryption()` | 启动客户端加密（用于已建立连接的加密升级） |
| `startServerEncryption()` | 启动服务端加密 |
| `isEncrypted(): Bool` | 是否已加密 |
| `sslMode(): Int32` | 获取 SSL 模式（SslMode 常量） |
| `setPeerVerifyMode(mode)` / `peerVerifyMode(): Int32` | 设置/获取对端验证模式 |
| `peerCertificateInfo(): String` | 获取对端证书信息 |
| `setOnEncrypted(callback: VoidCallback)` | 加密完成回调 |
| `setOnPeerVerifyError(callback: CStringCallback)` | 对端证书验证错误回调 |
| `getPtr(): Int64` | 获取指针 |
| `close()` | 释放资源 |

**SslMode SSL 模式常量**:
| 常量 | 值 | 说明 |
|------|-----|------|
| `SslMode.unsecured()` | 0 | 未加密模式 |
| `SslMode.sslClient()` | 1 | SSL 客户端模式 |
| `SslMode.sslServer()` | 2 | SSL 服务端模式 |

**PeerVerifyMode 对端验证模式常量**:
| 常量 | 值 | 说明 |
|------|-----|------|
| `PeerVerifyMode.verifyNone()` | 0 | 不验证对端证书 |
| `PeerVerifyMode.queryPeer()` | 1 | 请求对端证书但不验证 |
| `PeerVerifyMode.verifyPeer()` | 2 | 请求并验证对端证书 |
| `PeerVerifyMode.autoVerify()` | 3 | 自动验证（客户端模式自动开启验证） |
