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
