# CJQT6 修复报告 · 第三轮（FIX-REPORT-ROUND3）

> 范围：① capture 闭包 close 级注销扩展到 network 模块；② QSplitter.saveState
> 截断时未初始化内存读取修复；③ 移除 views model 包装上误暴露的 QWidget-only
> 方法（消除跨类 UB）。

---

## 1. 本轮实施

### 1.1 network Capture 接入对象级注销（承接第二轮机制）
- `src/core/callback.cj` 的对象级注册表 API 不变（第二轮的
  `registerObjectVoidCallback / unregisterObjectVoidCallbacks`）。
- `src/network/tcp_socket.cj`（QTcpSocket）：
  - `setOnConnectedCapture/setOnDisconnectedCapture/setOnReadyReadCapture/setOnErrorCapture`
    改为对象登记（4 处）；
  - `close()` 与 `disconnectCallbacks()` 均统一注销对象名下闭包（幂等）。
- `src/network/tcp_server.cj`（QTcpServer）：`setOnNewConnectionCapture` 对象登记；
  `close()`/`disconnectCallbacks()` 统一注销。
- 意义：高频短连接（如聊天/轮询服务）反复创建 socket 时，不再向
  `gVoidRegistry` 永久写入闭包条目。

### 1.2 QSplitter.saveState 截断安全修复
- `native/src/widgets/bridge_containers.cpp`：原实现当状态长度 ≥ 4096 缓冲时不写入、
  不更新 `*bufferSize`（保持初值 4096），仓颉侧按 4096 读取**未初始化堆内存**。
  现约定：放得下 → 写入并置实际长度；放不下 → 不改写缓冲并把 `*bufferSize` 置 0，
  仓颉 `saveState()` 据此返回空数组（`restoreState` 对空数组返回 false），不再读取垃圾字节。
- 成功路径语义不变（长度 < 4096 时结果与原来一致）。

### 1.3 移除 model 包装上的 QWidget-only 方法（跨类 UB 源）
- 全仓 grep 确认 **零调用方** 后，删除：
  - `src/views/filesystemmodel.cj`（QFileSystemModel）：`show/hide/resize/setEnabled/setStyleSheet`
  - `src/views/standarditemmodel.cj`（QStandardItemModel）：`show/hide/resize/setEnabled/setStyleSheet`
- 理由：这些类底层是 QAbstractItemModel（非 QWidget），把 model 指针当 QWidget* 调
  `qWidgetShow` 等为跨类 UB（原审查标记）；删除为 API 收敛，不影响模型数据用法。

---

## 2. 验证

- 桥接库：`scripts/update-bridge.ps1`（Qt 6.10.3 MSVC 2022）重编通过并部署
  `releases/windows-x64/cjqt6_bridge.dll/.lib`（bridge_containers.cpp 变更已编入）。
- `cjpm build`：通过。
- 全量 `cjpm test`（offscreen）：**1154 PASS / ~4 FAIL（81% 处）**；失败仍为环境偶发族
  （QProcessSpawn 控制台 GBK “Invalid utf8 byte sequence” 等，与既往各轮一致、
  与本次改动文件零重叠）；network/views/splitter 相关用例均通过。

> 本轮结果：见上。

---

## 3. 剩余项（继续留待后续）

charts 所有权矩阵（P0）、回调表加锁与注册替换（P0）、约 40 类 QtResource 化（P0，
建议按模块分批）、emitter 等其余 Capture 接入、takeItem/裸句柄泄漏（P1）、
QLegend 非拥有包装说明、文档同步（docs/api 05_views 移除 model 上的 QWidget 方法描述等）。
