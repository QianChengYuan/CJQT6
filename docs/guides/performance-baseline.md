# CJQT6 性能基线（P2-3）

> **目的**：量化四条高频路径的单次开销，作为后续性能优化（尤其 P3 `@FastNative` 标注）
> 的对照基线。**任何性能相关 commit 必须带前后对照数据**（见文末「提交要求」）。
> 测时工程：`examples/bench`（`std.time.MonoTime` 单调纳秒钟，先 warmup 再计时，取 ns/op）。

## 1. 基线速查表（2026-08-12 实测，Qt 6.10.3 / MSVC 2022 / Release）

| 路径 | 场景 | ns/op | 说明 |
|------|------|------:|------|
| 基线 | 空 lambda + Int64 累加 | **9** | 纯仓颉闭包调用成本，其余用例可扣除此底噪 |
| 纯 FFI 往返 | `QSpinBox.value()`（Int32 getter） | **166** | 含 `checkValid`→`isObjectAlive` FFI + 存活表查找 + 目标 FFI |
| 纯 FFI 往返 | `QSpinBox.isEnabled()`（Bool getter） | **160** | 同上 |
| 纯 FFI 往返 | `QSpinBox.setValue(7)`（Int32 setter） | **691** | setter 比 getter 贵（Qt 内部 state 变更 + 可能发信号） |
| 字符串过 FFI | `QPushButton.setText`（String→CString→Qt） | **408** | UTF-16↔UTF-8 转换 + malloc/free |
| 字符串过 FFI | `QPushButton.text()`（Qt→CString→String） | **462** | 同上反向 |
| 信号回调吞吐 | `SignalEmitter.emitVoid()`（void 回调） | **317** | DirectConnection，同线程同步触发 |
| 信号回调吞吐 | `SignalEmitter.emitInt(1)`（int 回调） | **315** | 同上 |
| 信号回调吞吐 | `SignalEmitter.emitString("x")`（string 回调） | **676** | 带字符串转换 |
| 异步路径 | `runOnUiThread`（post+drain，n=50000） | **2701** | 含注册表增删 + 事件队列投递 + 派发 |
| 异步路径 | `QTimer(interval=0)` 事件循环派发（n=50000） | **12993** | 完整事件循环信号派发 |

> 注：不同机器/优化开关数值会有波动（±20% 属正常），对照时应**同机同配置**再比较。
> Linux 端可复用同一 `examples/bench`（`cjpm run`，offscreen），数据回填到第 4 节。

## 2. 解读结论（决定优化方向）

1. **纯 getter/setter 已在数百 ns 量级**，`@FastNative` 只减 FFI thunk（数 ns 级），
   **对高频 getter 标注收益有限**——除非该 getter 在热循环中以百万次/秒调用。
2. **真正热点**按成本排序：
   - 事件循环信号派发（~13µs/op）——QTimer/跨线程投递是数量级最高的单次成本；
   - `runOnUiThread`（~2.7µs/op）——跨线程场景按此预算评估；
   - 字符串转换（~400-700ns/op）——每次过 FFI 都要 UTF-16↔UTF-8 转换；
   - 信号回调派发（~300-700ns/op）。
3. 优化优先级建议：**减少往返与批量桥接**（如字符串批量读写、信号合并），
   而非盲目标注 getter。

## 3. 如何复跑基线

```powershell
# Windows（配好 Qt 运行时后）
cd examples/bench
.\scripts\setup-qt-env.ps1        # 或手动把 Qt bin 加 PATH
cjpm run                          # offscreen 平台，无显示依赖

# Linux
cd examples/bench
cjpm run                          # 无需显示，默认 offscreen
```

跑完把表格中关键指标与本文件对比，波动超 ±30% 需排查（进程调度、Qt 版本、编译优化）。

## 4. 跨平台记录

| 平台/工具链 | Qt 版本 | 跑测日期 | 关键指标（getter / setText / emitVoid / runOnUiThread / QTimer） |
|------------|---------|----------|------|
| Windows MSVC 2022 | 6.10.3 | 2026-08-12 | 166 / 408 / 317 / 2701 / 12993 ns/op |
| Linux GCC（待回填） | 6.4.2 | - | - |

## 5. 提交要求（门禁化）

- 性能优化 commit 的 message **必须附前后对照**，例如：
  `perf: setText 批量桥接 408→210 ns/op（见 docs/performance-baseline.md 基线）`。
- 引入新热点 API 前先跑本基线，避免劣化超 30% 未被发现。
- P3 `@FastNative` 标注前，必须按第 2 节结论判断是否为真热点并附 bench 数据。

## 6. DPI 高清渲染（P0-b，2026-08-31 验证）

- **Qt6 默认启用 High-DPI scaling**：Qt 6 已移除 Qt5 遗留的 `AA_EnableHighDpiScaling`/`AA_UseHighDpiPixmaps` 属性，默认开启，`QApplication` **无需**再显式 `setAttribute`。
- 库已封装 DPI 基础设施（`cjqt6.core.QScreen`）：
  - `primaryDpiX/Y`、`primaryPhysicalDpiX/Y`、`primaryDevicePixelRatio`、`scaleFactor()`；
  - `logicalToPhysical` / `physicalToLogical` 逻辑↔物理像素换算（内部走 `devicePixelRatio`）；
  - `QWidget.resizeDp` / `setMinimumSizeDp` / `setMaximumSizeDp` 用逻辑像素做 DPI 感知布局，内部调用 `QScreen.logicalToPhysical`。
- **清晰度最佳实践**：图标优先 SVG / @2x 位图资源，避免在 125%/150%/200% 缩放下放大发糊；文本由 Qt raster 引擎按 `devicePixelRatio` 处理，默认清晰，无需干预。
- 验证：`src/test/dpi_test.cj` 覆盖 DPI 查询有效性、逻辑→物理不缩小、逻辑↔物理往返一致性。
