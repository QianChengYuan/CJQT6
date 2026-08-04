# QQ 局域网聊天（qq_chat_lan）

基于 [CJQT6](../../)（仓颉语言 Qt6 封装库）实现的**客户端 / 服务端**局域网即时通讯示例。
由单机版 `examples/qq_chat` 演进而来：把"SQLite + 定时器轮询"的本地模拟，替换为
**QTcpServer 监听 + QTcpSocket 长连接 + JSON-line 协议**的真实网络收发。

第一版为**最小闭环**：注册 / 登录 / 在线状态 / 好友管理 / 一对一文本聊天 / 离线消息补发。

```
┌──────────┐   TCP 9600 (JSON-line)   ┌──────────┐
│ 客户端 A  │ ◄──────────────────────► │          │
└──────────                          │  服务端   │  SQLite: 用户/好友/消息
┌──────────┐                          │          │
│ 客户端 B  │ ◄──────────────────────► │          │
└──────────                          └──────────┘
```

## 目录结构

```
qq_chat_lan/
├── server/                  # 服务端（QTcpServer + SQLite）
│   ├── cjpm.toml
│   └── src/
│       ├── main.cj          # 入口：建库 -> 建窗 -> 监听 -> 事件循环
│       ├── db.cj            # ServerDb：users / friends / messages CRUD
│       └── net.cj           # 会话管理、协议分发、消息路由、在线广播
├── client/                  # 客户端（登录/好友列表/聊天窗口）
│   ├── cjpm.toml
│   └── src/
│       ├── main.cj          # 入口：登录窗
│       ├── core/            # 数据模型 + JSON 协议工具
│       ├── state/           # 全局状态
│       └── app/             # 网络层 + 登录/好友/聊天/对话框 UI
└── e2e_test.ps1             # 协议端到端测试（模拟双客户端，19 项断言）
```

## 构建

前置：仓颉编译器 `cjc`/`cjpm`、Qt6（≥6.2）、CMake、MSVC 2022（Windows）。

1. **构建 C++ 桥接库**（本次为 cjqt6 新增了 QTcpServer 封装，必须重编桥接库）：

   ```powershell
   cd <仓库根>
   .\scripts\update-bridge.ps1        # 自动 cmake 配置 + MSVC 编译 + 同步到 releases/
   ```

2. **构建服务端 / 客户端**：

   ```powershell
   cd examples\qq_chat_lan\server ; cjpm build
   cd ..\client               ; cjpm build
   ```

## 运行

1. **先启动服务端**（会在当前目录生成 `qq_lan_server.db`，监听 `0.0.0.0:9600`）：

   ```powershell
   # 需把 Qt6 bin 与桥接库目录加入 PATH（或用 scripts\setup-qt-env.ps1）
   .\target\release\bin\main.exe
   ```

2. **再启动客户端**，在登录页填写：
   - **服务器地址**：服务端机器的局域网 IP + 端口，如 `192.168.1.100:9600`（本机可填 `127.0.0.1:9600`）；
   - 首次使用点 **注册账号**，系统自动分配 QQ 号（10000 起）。

3. 两台机器各开一个客户端，互相 **添加好友**（按 QQ 号）后即可聊天；对方不在线时消息由服务端暂存，上线自动补发。

> 防火墙需放行 9600 端口；服务端窗口实时打印连接 / 登录 / 消息日志。

## 协议（JSON-line，UTF-8，`\n` 分帧）

客户端 → 服务端：

| type | 字段 | 说明 |
|------|------|------|
| `register` | `nickname`,`password` | 注册，返回 `reg_ok{account}` |
| `login` | `account`,`password` | 登录，返回 `login_ok{self,friends,messages}` |
| `add_friend` | `account` | 按 QQ 号加好友（双向建立） |
| `chat` | `to`,`text` | 发文本消息 |
| `ping` | — | 心跳，回 `pong` |

服务端 → 客户端：`reg_ok` / `login_ok` / `chat{from,fromName,text,time}` /
`presence{userId,online}` / `friend_added` / `ok{op}` / `pong` / `error{op,message}`。

## 本次对 CJQT6 库的增强（随仓库提交）

- **新增 `cjqt6.network.QTcpServer`**（`src/network/tcp_server.cj` + 桥接层）：
  `listen/listenOn/nextPendingConnection/setOnNewConnection(Capture)` 等，补上原先缺失的 TCP 服务端能力。
- **`QTcpSocket` 扩展**：`peerAddress/peerPort/localAddress/localPort`、
  包装服务端连接的 `init(nativePtr)`、四类信号的 **Capture（闭包捕获）回调**——
  多连接场景下每个套接字可注册各自闭包以区分来源。
- **修复信号回调互相覆盖**：QTcpSocket 的 connected/disconnected/readyRead/error
  改为各自独立回调表，可同时注册。
- **修复 `std::mutex` 死锁**（重要）：桥接层原用 `std::mutex` 保护回调表，
  在 Cangjie 运行时加载的 DLL 中**首次加锁即死锁**（连栈上新锁的 `try_lock` 都卡死）。
  统一改为 `atomic_flag` 自旋锁（与 `bridge_signal.cpp` 既有方案一致），
  涉及 `bridge_network.cpp` / `bridge_network_access.cpp` / `bridge_thread.cpp`。

## 测试

```powershell
# 先启动服务端，然后：
powershell -ExecutionPolicy Bypass -File e2e_test.ps1
```

覆盖：注册、登录、错误密码拒绝、在线状态广播、加好友双向通知、中文消息互发、
离线消息补发、上下线感知、心跳，共 19 项断言。

## 已知限制（v1）

- 仅文本消息；图片 / 文件 / 表情 / 群聊 / 消息撤回等单机版特性尚未移植。
- 密码明文存储（演示用），无 TLS；生产使用请自行加 `QSslSocket` / 哈希。
- 聊天记录在客户端为会话内缓存，重连后仅补发未读消息。
