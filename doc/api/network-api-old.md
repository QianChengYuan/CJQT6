# QtNetwork 模块 API 文档

CJQT6 的 QtNetwork 模块封装了 Qt6 的网络功能，提供 TCP/UDP 通信能力。

## 模块概览

```
cjqt6.network
├── QHostAddress    - IP地址封装
├── QTcpSocket      - TCP客户端套接字
├── QUdpSocket      - UDP数据报套接字
├── SocketState     - 套接字状态枚举
└── SocketError     - 套接字错误枚举
```

---

## QHostAddress - IP地址

IP地址的封装类，支持IPv4和IPv6。

### 构造函数

```cangjie
public init()                           // 创建空地址
public init(address: String)            // 从字符串创建地址
```

### 主要方法

| 方法 | 返回类型 | 说明 |
|------|----------|------|
| `setAddress(address: String)` | Unit | 设置地址 |
| `toString()` | String | 转换为字符串 |
| `protocol()` | Int32 | 获取协议类型（IPv4/IPv6） |
| `isNull()` | Bool | 是否为空地址 |
| `equal(address: String)` | Bool | 判断是否相等 |
| `delete()` | Unit | 释放资源 |

### 示例

```cangjie
let addr = QHostAddress("127.0.0.1")
println("地址: ${addr.toString()}")
println("协议: ${addr.protocol()}")
addr.delete()
```

---

## QTcpSocket - TCP套接字

提供TCP客户端功能，支持连接、读写、断开等操作。

### 构造函数

```cangjie
public init()
```

### 连接管理

| 方法 | 说明 |
|------|------|
| `connectToHost(host: String, port: UInt16)` | 连接到主机 |
| `disconnectFromHost()` | 断开连接 |
| `close()` | 关闭套接字 |
| `state()` | 获取套接字状态 |
| `isValid()` | 是否有效 |

### 数据读写

| 方法 | 返回类型 | 说明 |
|------|----------|------|
| `write(data: Array<Byte>)` | Int64 | 写入字节数组 |
| `writeString(text: String)` | Int64 | 写入字符串 |
| `read(maxSize: Int64)` | Array<Byte> | 读取数据 |
| `readAll()` | Array<Byte> | 读取所有可用数据 |
| `readString(maxSize: Int64)` | String | 读取为字符串 |
| `bytesAvailable()` | Int64 | 可读取字节数 |
| `bytesToWrite()` | Int64 | 待写入字节数 |
| `flush()` | Bool | 刷新缓冲区 |

### 错误处理

| 方法 | 返回类型 | 说明 |
|------|----------|------|
| `error()` | Int32 | 获取错误码 |
| `errorString()` | String | 获取错误描述 |

### 回调设置

| 方法 | 说明 |
|------|------|
| `setOnConnected(callback)` | 设置连接成功回调 |
| `setOnDisconnected(callback)` | 设置断开连接回调 |
| `setOnReadyRead(callback)` | 设置数据就绪回调 |
| `setOnError(callback)` | 设置错误回调 |
| `disconnectCallbacks()` | 断开所有信号连接 |

### 示例

```cangjie
let socket = QTcpSocket()

socket.setOnConnected({
    println("已连接")
    socket.writeString("Hello Server")
})

socket.setOnReadyRead({
    let data = socket.readString(1024)
    println("收到: ${data}")
})

socket.setOnError({
    println("错误: ${socket.errorString()}")
})

socket.connectToHost("127.0.0.1", 8080)
```

---

## QUdpSocket - UDP套接字

提供UDP通信功能，支持数据报收发。

### 构造函数

```cangjie
public init()
```

### 绑定与关闭

| 方法 | 返回类型 | 说明 |
|------|----------|------|
| `bind(address: String, port: UInt16)` | Bool | 绑定到地址和端口 |
| `bind(port: UInt16)` | Bool | 绑定到端口（任意地址） |
| `close()` | Unit | 关闭套接字 |
| `state()` | Int32 | 获取套接字状态 |
| `isValid()` | Bool | 是否有效 |

### 数据报收发

| 方法 | 返回类型 | 说明 |
|------|----------|------|
| `writeDatagram(data: Array<Byte>, host: String, port: UInt16)` | Int64 | 发送数据报 |
| `writeStringDatagram(text: String, host: String, port: UInt16)` | Int64 | 发送字符串数据报 |
| `readDatagram()` | Datagram | 读取数据报 |
| `hasPendingDatagrams()` | Bool | 是否有待读数据报 |
| `pendingDatagramSize()` | Int64 | 待读数据报大小 |

### Datagram 类

UDP数据报结构：

```cangjie
public class Datagram {
    public var data: Array<Byte>       // 数据内容
    public var senderAddress: String   // 发送者地址
    public var senderPort: UInt16      // 发送者端口
}
```

### 错误处理

| 方法 | 返回类型 | 说明 |
|------|----------|------|
| `error()` | Int32 | 获取错误码 |
| `errorString()` | String | 获取错误描述 |

### 回调设置

| 方法 | 说明 |
|------|------|
| `setOnReadyRead(callback)` | 设置数据就绪回调 |
| `setOnError(callback)` | 设置错误回调 |
| `disconnectCallbacks()` | 断开所有信号连接 |

### 示例：UDP服务端

```cangjie
let socket = QUdpSocket()
socket.bind(8080)

socket.setOnReadyRead({
    while (socket.hasPendingDatagrams()) {
        let datagram = socket.readDatagram()
        let message = String.fromUtf8(datagram.data)
        println("来自 ${datagram.senderAddress}:${datagram.senderPort}")
        println("消息: ${message}")
        
        // 回复
        socket.writeStringDatagram("OK", datagram.senderAddress, datagram.senderPort)
    }
})
```

### 示例：UDP客户端

```cangjie
let socket = QUdpSocket()

socket.setOnReadyRead({
    let datagram = socket.readDatagram()
    println("收到回复: ${String.fromUtf8(datagram.data)}")
})

// 发送消息
socket.writeStringDatagram("Hello", "127.0.0.1", 8080)
```

---

## SocketState - 套接字状态

套接字连接状态枚举：

| 常量 | 值 | 说明 |
|------|-----|------|
| `UnconnectedState` | 0 | 未连接 |
| `HostLookupState` | 1 | 正在查找主机 |
| `ConnectingState` | 2 | 正在连接 |
| `ConnectedState` | 3 | 已连接 |
| `BoundState` | 4 | 已绑定 |
| `ListeningState` | 5 | 正在监听 |
| `ClosingState` | 6 | 正在关闭 |

---

## SocketError - 套接字错误

套接字错误类型枚举：

| 常量 | 值 | 说明 |
|------|-----|------|
| `ConnectionRefusedError` | 0 | 连接被拒绝 |
| `RemoteHostClosedError` | 1 | 远程主机关闭连接 |
| `HostNotFoundError` | 2 | 主机未找到 |
| `SocketAccessError` | 3 | 套接字访问错误 |
| `SocketResourceError` | 4 | 套接字资源错误 |
| `SocketTimeoutError` | 5 | 套接字超时 |
| `DatagramTooLargeError` | 6 | 数据报过大 |
| `NetworkError` | 7 | 网络错误 |
| `AddressInUseError` | 8 | 地址已使用 |
| `SocketAddressNotAvailableError` | 9 | 地址不可用 |
| `UnsupportedSocketOperationError` | 10 | 不支持的套接字操作 |
| `UnknownSocketError` | 11 | 未知错误 |

---

## 资源管理

**重要**：使用完套接字后必须调用 `delete()` 释放资源：

```cangjie
let socket = QTcpSocket()
// ... 使用套接字 ...
socket.disconnectCallbacks()
socket.delete()
```

---

## 完整示例

参见 `examples/network_example/` 目录：
- `server.cj` - UDP服务端示例
- `client.cj` - UDP客户端示例
