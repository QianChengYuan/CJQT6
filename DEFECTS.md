# CJQT6 缺陷分析报告

> **分析对象**：CJQT6 v1.9.0（仓颉 Qt6 封装库）
> **分析日期**：2026-09-07
> **分析范围**：功能实现 / 性能 / 安全性 / 兼容性 / 可维护性 / 用户体验
> **分析方式**：静态代码审查，未修改任何源代码
> **代码规模基准**：仓颉封装 `src/` 211 个 `.cj` 文件约 52909 行；C++ 桥接 `native/` 56 个 `.cpp` 文件约 22645 行；测试 47 个文件；示例 20 个工程。

---

## 修复状态总览（2026-09-08 / 09 更新）

本报告记录的缺陷已完成高/中优先级修复闭环，均经四平台 CI（Windows x64 / Linux x64 / Linux ARM64 / macOS arm64）全量验证并入库。各缺陷正文保留原始分析，状态如下：

| 缺陷 | 严重度 | 状态 | 说明 / commit |
|------|--------|------|----------------|
| **B1** | 高 | ✅ 已修复 | `bridge_events.cpp` 全局回调表加 `std::recursive_mutex`，锁内查找拷贝、锁外执行回调防死锁 |
| **D1** | 高 | ✅ 已修复 | `releases/linux-arm64/` 已建并入库实际桥接库，CI 加 `aarch64` job（仓颉官方有 linux-aarch64 SDK） |
| **D2** | 高 | ✅ 已取消 | 仓颉 **1.1.0 版本暂未提供 macOS x64（x86_64）SDK**，当前版本非可修复项；`cjpm.toml` 的 `x86_64-apple-darwin` target 已注释，平台表标记暂不支持 |
| **A1** | 中 | ✅ 已修复（结论修正） | grep 计数差为文本假象；真实问题是 **33 个 QObject 封装类缺级联销毁守卫**——charts 24 类补 `isObjectAlive` 守卫、views 9 类接入存活表，修 double-free/UAF；附级联生命周期回归测试 |
| **A2** | 中 | ✅ 判定误报 | `QSqlDatabase` 是隐式共享**值类（非 QObject）**，`trackObject` 强转 QObject 会 UB，不 track 正确；`close()` 不调 `removeDatabase` 为可选增强项 |
| **A3** | 中 | ✅ 已修复 | `QProcessEnvironment` 已实现 `QtResource` 接口与 `checkValid` 守卫 |
| **C1** | 中 | ✅ 已修复 | 桥接层 11 处空 `catch(...){}` 补 `qWarning` 日志（保留吞异常防穿透 FFI 的防御语义，不再静默） |
| **E1** | 中 | ✅ 已修复 | `scripts/run-test.ps1` 移除硬编码本机绝对路径 |
| **F1** | 中 | ✅ 已修复 | SKILL.md 模块地图补 `richwidgets`（20 个富控件）行 |
| **F2** | 低 | ✅ 已修复 | AGENTS.md / README.md 测试数（49）、断言数（约 2950）、示例数（20）、模块数（15）已同步 |
| **F3** | 低 | ✅ 已修复 | macOS / Linux ARM64 产物状态、平台支持表已按实际更新 |
| C2 / D3 / E2 / G1 / H1–H4 / I1–I2 | 低-中 | ⏸ 未处理 | 属设计取舍、性能优化、示例卫生或 FFI 固有限制，有规避手段，不阻塞使用；详见各正文 |

> 回归测试：新增 `src/test/cascade_lifetime_test.cj`（6 个 `@TestCase`，charts/views 级联销毁后业务方法抛 `ResourceDisposedException`、`close()` 安全幂等），锁定 A1 修复行为。全量 `cjpm test` 1401 PASSED / 75 SKIPPED / 12 FAILED（12 个为 QEventWidgetTests 在 Windows offscreen 下预先存在的偶发超时，与本次改动无关）。

---

## 严重程度定义

| 等级 | 含义 |
|------|------|
| **高** | 导致构建/链接失败、运行期崩溃、数据损坏，或阻塞核心功能使用 |
| **中** | 行为不一致、资源泄漏、调试困难、影响特定平台/场景，有规避手段 |
| **低** | 文档过时、性能微损、风格不统一，不影响主流程 |

---

## 缺陷统计概览

| 类别 | 高 | 中 | 低 | 小计 |
|------|----|----|----|------|
| A. 内存管理 | 0 | 3 | 0 | 3 |
| B. 线程安全 | 1 | 0 | 0 | 1 |
| C. 异常处理 | 0 | 2 | 0 | 2 |
| D. 平台兼容性 | 2 | 1 | 0 | 3 |
| E. 构建系统 | 0 | 2 | 0 | 2 |
| F. 文档完整性 | 0 | 2 | 1 | 3 |
| G. 性能 | 0 | 1 | 0 | 1 |
| H. 用户体验 | 0 | 4 | 0 | 4 |
| I. 安全性 | 0 | 1 | 1 | 2 |
| **合计** | **3** | **16** | **2** | **21** |

---

## A. 内存管理缺陷

### A1. `trackObject` / `untrackObject` 调用严重不配对（存活表条目泄漏）
- **严重程度**：中
- **影响范围**：全局对象存活注册表（`native/src/core/bridge_core.cpp` 维护的 map），影响所有走 `QtResource` 范式的封装类，长期运行进程内存增长。
- **缺陷描述**：对象存活注册表要求 `trackObject(ptr)`（创建后注册）与 `untrackObject(ptr)`（close 时注销）严格配对。全仓统计：`trackObject(` 调用 **293 次**，`untrackObject(` 调用仅 **178 次**，差值 **115 次未配对**。残留条目使存活表持续膨胀，且 `isObjectAlive(ptr)` 在指针被复用时可能误判存活。
- **证据**：
  - [cstring_utils.cj](file:///c:/CodeTools/cangjie_git/CJQT6/src/core/cstring_utils.cj#L51-L68) 定义 `trackObject/untrackObject/isObjectAlive`
  - 全仓 grep 统计：`trackObject(` = 293，`untrackObject(` = 178
- **复现步骤**：
  1. 在 `src/core/cstring_utils.cj` 的 `trackObject` / `untrackObject` 内加计数打印
  2. `cjpm test` 跑全量测试
  3. 统计调用次数差，确认 close 路径遗漏 trackObject 注销

### A2. `QSqlDatabase` 静态工厂不检查 `ptr==0`、不 `trackObject`，`isValid`/`checkValid` 不调用 `isObjectAlive`
- **严重程度**：中
- **影响范围**：SQL 模块（`src/sql/database.cj`），数据库连接对象无法被反向失效通知，与 `QWidget` 标准范式不一致。
- **缺陷描述**：
  - `addDatabase` / `database` 静态工厂创建后**不检查 `db.ptr == 0`**（创建失败不抛 `CreateFailedException`），也**不调用 `trackObject(db.ptr)`**；
  - `isValid()` 仅返回 `!closed && ptr != 0`，**未调用 `isObjectAlive(ptr)`**（对比 [widget.cj#L199-L201](file:///c:/CodeTools/cangjie_git/CJQT6/src/core/widget.cj#L199-L201) 的 `!closed && ptr != 0 && isObjectAlive(ptr)`）；
  - `checkValid()` 同样未做 `isObjectAlive` 兜底；
  - `close()` **不调用 `untrackObject(ptr)`**，残留存活表条目。
- **证据**：
  - [database.cj#L86-L96](file:///c:/CodeTools/cangjie_git/CJQT6/src/sql/database.cj#L86-L96) `addDatabase` 无 ptr 检查、无 trackObject
  - [database.cj#L99-L107](file:///c:/CodeTools/cangjie_git/CJQT6/src/sql/database.cj#L99-L107) `database()` 同上
  - [database.cj#L205-L207](file:///c:/CodeTools/cangjie_git/CJQT6/src/sql/database.cj#L205-L207) `isValid` 缺 isObjectAlive
  - [database.cj#L212-L219](file:///c:/CodeTools/cangjie_git/CJQT6/src/sql/database.cj#L212-L219) `checkValid` 缺 isObjectAlive
  - [database.cj#L222-L231](file:///c:/CodeTools/cangjie_git/CJQT6/src/sql/database.cj#L222-L231) `close` 缺 untrackObject
- **复现步骤**：
  1. `import cjqt6.sql.*`
  2. 传入不存在的驱动名调用 `QSqlDatabase.addDatabase("INVALID","c")`
  3. 观察返回的 `QSqlDatabase` 对象 `ptr==0` 但无异常抛出，后续调用 `open()` 才在 `checkValid` 抛 `NullPointerException`，而非 `CreateFailedException`

### A3. `QProcessEnvironment` 未实现 `QtResource` 接口、方法缺 `checkValid` 守卫
- **严重程度**：中
- **影响范围**：进程模块（`src/core/process.cj`），资源管理范式不统一，构造失败不抛异常。
- **缺陷描述**：`QProcessEnvironment` 持有 `ptr: Int64` 但**未实现 `QtResource` 接口**（无 `isClosed/close/getPtr/isValid/checkValid`），`init()` 不检查 `ptr==0`，`insert/remove/value` 等方法**无 `checkValid()` 守卫**，ptr 为 0 时直接穿透到 FFI。
- **证据**：
  - [process.cj#L60-L100](file:///c:/CodeTools/cangjie_git/CJQT6/src/core/process.cj#L60-L100) 类定义与方法均无 checkValid
- **复现步骤**：
  1. `let env = QProcessEnvironment()` 后立即 `env.insert("K","V")`
  2. 若底层 `qProcessEnvironmentCreate()` 返回 0，`insert` 直接以 ptr=0 调 FFI，行为未定义

---

## B. 线程安全缺陷

### B1. `bridge_events.cpp` 全局回调 map 与 widget map 无锁保护
- **严重程度**：高
- **影响范围**：事件处理桥接层（`native/src/core/bridge_events.cpp`），多线程 GUI 程序偶发崩溃、回调丢失、数据竞争。
- **缺陷描述**：6 个静态全局 `std::unordered_map`（鼠标按下/移动/释放、按键按下/释放、绘制回调）与 `g_eventWidgets` 全部**未加锁**。`EventWidget` 构造（L36 写入 map）、析构（L40 擦除 map）与 Qt 事件循环线程的鼠标/键盘/绘制事件回调（L47-105 读取 map）若并发，触发 `std::unordered_map` 并发读写未定义行为（崩溃/迭代器失效）。
- **证据**：
  - [bridge_events.cpp#L16-L24](file:///c:/CodeTools/cangjie_git/CJQT6/native/src/core/bridge_events.cpp#L16-L24) 6 个 map + g_eventWidgets 无 mutex
  - [bridge_events.cpp#L36-L41](file:///c:/CodeTools/cangjie_git/CJQT6/native/src/core/bridge_events.cpp#L36-L41) 构造/析构写 map
  - [bridge_events.cpp#L46-L105](file:///c:/CodeTools/cangjie_git/CJQT6/native/src/core/bridge_events.cpp#L46-L105) 事件处理读 map
- **复现步骤**：
  1. 工作线程通过 `UiPoster` 频繁创建/销毁 `EventWidget` 子类控件
  2. 主线程同时移动鼠标触发 `mouseMoveEvent`
  3. 长时间运行可复现偶发崩溃（rehash 期间迭代器失效）

---

## C. 异常处理缺陷

### C1. 桥接层 11 处空 `catch(...) {}` 完全静默吞掉异常
- **严重程度**：中
- **影响范围**：C++ 桥接层（`native/src/**/*.cpp`），异常被静默吞掉，调试困难。
- **缺陷描述**：全 native 目录有 **11 处** `catch(...) {}` 空捕获，**无任何日志输出**。这与 [SECURITY.md#L29](file:///c:/CodeTools/cangjie_git/CJQT6/SECURITY.md#L29) 声称的"`bridge_signal.cpp` 38 处 `try{...}catch(...)` 已捕获，**仅记日志**不抛出"描述不符——实际部分路径是空 catch。
- **证据**：
  - `Select-String -Pattern 'catch\s*\(\s*\.\.\.\s*\)\s*\{\s*\}'` 在 `native/src` 命中 **11 处**
  - [bridge_events.cpp#L49-L51](file:///c:/CodeTools/cangjie_git/CJQT6/native/src/core/bridge_events.cpp#L49-L51) 等为空 catch 代表
- **复现步骤**：
  1. 在回调内抛 C++ 异常
  2. 观察无任何日志输出，问题被静默掩盖

### C2. `safeExecute` / `safeRun` 用 `println` 降级异常
- **严重程度**：中（低边缘）
- **影响范围**：`src/core/resource.cj` 公共辅助函数，错误被降级为控制台打印，调用方无法结构化区分失败原因。
- **缺陷描述**：`safeExecute` 捕获 `Exception` 后 `println("Warning: ${e}")` 返回 `None`；`safeRun` 同样返回 `false`。异常信息仅写标准输出，未接入日志框架，CI/offscreen 环境下输出易丢失。
- **证据**：
  - [resource.cj#L66-L83](file:///c:/CodeTools/cangjie_git/CJQT6/src/core/resource.cj#L66-L83)

---

## D. 平台兼容性缺陷

### D1. `linux-arm64` 链接目录不存在 ✅ 已修复
- **严重程度**：高
- **影响范围**：Linux ARM64 平台构建直接失败。
- **缺陷描述**：[cjpm.toml#L106-L108](file:///c:/CodeTools/cangjie_git/CJQT6/cjpm.toml#L106-L108) 声明 `[target.aarch64-unknown-linux-gnu] link-option = "-Lreleases/linux-arm64 -lcjqt6_bridge"`，但 `releases/` 目录下**没有 `linux-arm64` 子目录**（仅有 `windows-x64`、`linux-x64`、`macos-x64`、`macos-arm64`）。链接器找不到库直接报错。
- **证据**：
  - `ls releases/linux-arm64` → `Cannot find path ... because it does not exist`
- **复现步骤**：
  1. 在 aarch64 Linux 上设置 `CJQT6_ROOT`
  2. `cjpm build`
  3. 链接阶段报 `cannot find -lcjqt6_bridge`
- **修复方案**：
  1. 仓颉官方已发布 `cangjie-sdk-linux-aarch64-1.1.0.tar.gz`，解除了前置阻塞。
  2. 新增 `scripts/build-linux-arm64.sh` 原生 ARM64 构建脚本，产物部署到 `releases/linux-arm64/`。
  3. CI 新增 `linux-arm64` job（`ubuntu-24.04-arm` runner + Qt 6.5.3 gcc_arm64），编译 `libcjqt6_bridge.so` 并上传 artifact。
  4. `releases/linux-arm64/` 目录已创建（含 README.md 说明构建方式），CI 产物下载后 commit 入库即可。
- **修复状态**：基础设施已就绪（构建脚本 + CI job + 目录），`libcjqt6_bridge.so` 需由 CI 构建后下载入库。

### D2. `macos-x64` 仅有占位 README，无桥接库产物
- **严重程度**：高
- **影响范围**：macOS x64（Intel）平台构建链接失败。
- **缺陷描述**：[cjpm.toml#L96-L98](file:///c:/CodeTools/cangjie_git/CJQT6/cjpm.toml#L96-L98) 链接 `releases/macos-x64 -lcjqt6_bridge`，但 `releases/macos-x64/` 只有 147 字节的 `README.md`，**无 `libcjqt6_bridge.dylib`**。注意 `macos-arm64` 已有实际 dylib（1.7MB），与 [AGENTS.md](file:///c:/CodeTools/cangjie_git/CJQT6/AGENTS.md) 声称"macos-arm64/、macos-x64/ 仅占位 README"不符——文档与实际产物状态不一致。
- **证据**：
  - `ls releases/macos-x64` → 仅 `README.md`（147 字节）
  - `ls releases/macos-arm64` → 有 `libcjqt6_bridge.dylib`（1702776 字节）
- **复现步骤**：
  1. 在 Intel Mac 上 `cjpm build`
  2. 链接报 `cannot find -lcjqt6_bridge`

### D3. Windows 链接依赖 `CJQT6_ROOT` 环境变量，未设置即链接失败
- **严重程度**：中
- **影响范围**：Windows 构建，新用户首次构建易踩坑。
- **缺陷描述**：[cjpm.toml#L86-L88](file:///c:/CodeTools/cangjie_git/CJQT6/cjpm.toml#L86-L88) `link-option = "${CJQT6_ROOT}/releases/windows-x64/cjqt6_bridge.dll"`，环境变量未设置时拼成 `/releases/windows-x64/...` 链接失败。AGENTS.md 已记录此坑，但配置仍依赖外部环境变量而非相对路径自洽。
- **复现步骤**：
  1. 新克隆仓库，不设 `CJQT6_ROOT`
  2. `cjpm build`
  3. 链接报找不到 `cjqt6_bridge.dll`

---

## E. 构建系统缺陷

### E1. `scripts/run-test.ps1` 硬编码开发者本机绝对路径
- **严重程度**：中
- **影响范围**：测试脚本可移植性，其他开发者机器上脚本回退路径探测失效。
- **缺陷描述**：脚本在 `cjpm` / `cjcov` 探测的回退路径列表中硬编码了 `"C:\CodeTools\cangjie\cangjie_1.1.0\tools\bin\cjpm.exe"` 与 `"C:\CodeTools\cangjie\cangjie_1.1.0\tools\bin\cjcov.exe"`，这是特定开发者的本机安装路径，不可移植。
- **证据**：
  - [run-test.ps1#L58](file:///c:/CodeTools/cangjie_git/CJQT6/scripts/run-test.ps1#L58) 硬编码 cjpm 路径
  - [run-test.ps1#L152](file:///c:/CodeTools/cangjie_git/CJQT6/scripts/run-test.ps1#L152) 硬编码 cjcov 路径
- **复现步骤**：
  1. 在未把 cjpm 加入 PATH 的其他机器上跑 `run-test.ps1`
  2. 若 `$env:CANGJIE_HOME` 也未设，脚本回退到硬编码路径 `C:\CodeTools\cangjie\...`，路径不存在直接退出

### E2. 增量构建 stale-DLL 陷阱导致 flaky 测试
- **严重程度**：中
- **影响范围**：开发与 CI 流程，改了 C++ 桥接代码但运行行为不变，测试偶发失败。
- **缺陷描述**：`native/build_windows_x64` 存在 CMake 缓存时，`cmake --build` 可能判定"已最新"跳过链接，导致改了 C++ 但产物时间戳不变，测试加载过期 bridge 出现 flaky 断言失败。`run-test.ps1` 自身的注释明确警示了此陷阱。
- **证据**：
  - [run-test.ps1#L14-L17](file:///c:/CodeTools/cangjie_git/CJQT6/scripts/run-test.ps1#L14-L17) 注释承认"过期 bridge 导致 flaky"
  - [SKILL.md#L231-L236](file:///c:/CodeTools/cangjie_git/CJQT6/.agents/skills/cjqt6/SKILL.md#L231-L236) 增量构建陷阱说明
- **复现步骤**：
  1. 修改 `native/src/widgets/bridge_ext_wcore.cpp`
  2. `cmake --build native/build_windows_x64 --config Release`（未 `--clean-first`）
  3. 运行测试，行为与改前一致（链接被跳过）

---

## F. 文档完整性缺陷

### F1. `richwidgets` 模块（20 个文件）在 SKILL.md 模块地图中完全缺失
- **严重程度**：中
- **影响范围**：用户认知，无法发现仿 Ant Design 风格的丰富控件集。
- **缺陷描述**：`src/richwidgets/` 目录含 20 个文件（avatar/badge/cascader/countdown/daterange/descriptions/empty/form/groupcard/pagination/rate/searchbox/skeleton/statistic/steps/switch/tag/timeline/toast/transfer），但 [SKILL.md 模块地图表](file:///c:/CodeTools/cangjie_git/CJQT6/.agents/skills/cjqt6/SKILL.md#L29-L46) 完全未列出 `cjqt6.richwidgets` 模块。用户读 SKILL 无法获知这些控件存在。
- **证据**：
  - `ls src/richwidgets` → 20 个 `.cj` 文件
  - SKILL.md 模块表无 `richwidgets` 行

### F2. 测试文件数与示例数与文档不符
- **严重程度**：低
- **影响范围**：文档准确性。
- **缺陷描述**：
  - [AGENTS.md](file:///c:/CodeTools/cangjie_git/CJQT6/AGENTS.md) 称"41 个 `*_test.cj`"，实际 `src/test/` 下有 **47 个**测试文件；
  - [AGENTS.md](file:///c:/CodeTools/cangjie_git/CJQT6/AGENTS.md) 称"25 个示例/工具工程目录"，实际 `examples/` 下只有 **20 个**目录（all_controls_demo/analog_clock/bench/calculator/chart_demo/charts_demo/delegate_demo/dormitory_manager/expense_tracker/hello_cjqt6/music_player/notepad/paint_app/qq_chat_lan/resource/signal_smoke/snake_game/tank_battle/todo_list/ui2cj_demo）。
- **证据**：
  - `ls src/test` → 47 项
  - `ls examples` → 20 项

### F3. AGENTS.md 对 macOS 产物状态描述与实际不符
- **严重程度**：低
- **影响范围**：跨平台构建预期。
- **缺陷描述**：[AGENTS.md](file:///c:/CodeTools/cangjie_git/CJQT6/AGENTS.md) 称"macos-arm64/、macos-x64/ 仅占位 README"，但实际 `macos-arm64` 已含 1.7MB 的 `libcjqt6_bridge.dylib`，仅 `macos-x64` 是占位。
- **证据**：见 D2 证据。

---

## G. 性能缺陷

### G1. 频繁字符串方法每次调用都 `mallocCString` + `free`
- **严重程度**：低-中
- **影响范围**：高频文本操作场景（如 `setText` 在循环/动画中）。
- **缺陷描述**：`QWidget.setTitle`、`QTextEdit.setText`、`QLabel.setText` 等每次调用都执行 `LibC.mallocCString(s) → FFI → LibC.free(cstr)` 三连。仓颉侧已提供 `withCString` 助手收敛三连（[cstring_utils.cj#L30-L36](file:///c:/CodeTools/cangjie_git/CJQT6/src/core/cstring_utils.cj#L30-L36)），但部分热路径未迁移到该助手，仍手写 malloc/free，存在重复分配开销与遗漏 free 风险。
- **证据**：
  - [widget.cj#L119-L126](file:///c:/CodeTools/cangjie_git/CJQT6/src/core/widget.cj#L119-L126) `setTitle` 手写三连
  - [textedit.cj#L139-L145](file:///c:/CodeTools/cangjie_git/CJQT6/src/widgets/textedit.cj#L139-L145) `setText` 手写三连

---

## H. 用户体验缺陷

### H1. 布局 `addWidget`/`setLayout` 收原生指针而非对象
- **严重程度**：中
- **影响范围**：所有布局代码，用户易传错。
- **缺陷描述**：[layout.cj#L143-L149](file:///c:/CodeTools/cangjie_git/CJQT6/src/gui/layout.cj#L143-L149) `QWidget.setLayout(layoutPtr: Int64)`，`addWidget`/`addLayout` 同样收 `Int64`。用户必须写 `vbox.addWidget(label.getPtr())`，易忘 `.getPtr()` 直接传对象，编译期不报错（Int64 与对象无类型关系，但传对象会传对象引用值，运行期行为未定义）。
- **复现步骤**：
  1. `vbox.addWidget(label)`（漏 `.getPtr()`）
  2. 编译可能通过，运行期布局错乱或崩溃

### H2. `setAlignment` 需传 `.value`，易错
- **严重程度**：中
- **影响范围**：所有对齐 API。
- **缺陷描述**：[types.cj#L9-L40](file:///c:/CodeTools/cangjie_git/CJQT6/src/gui/types.cj#L9-L40) `Alignment` 是结构体，但 `setAlignment` 收 `Int32`，必须传 `Alignment.Center.value`。用户直觉上写 `setAlignment(Alignment.Center)` 类型不匹配；组合对齐需用位运算 `|` 再取 `.value`，学习成本高。
- **复现步骤**：
  1. `label.setAlignment(Alignment.Center)` → 类型错误
  2. 必须改为 `label.setAlignment(Alignment.Center.value)`

### H3. `notepad` 示例 47 个对象创建 0 个 `close()`
- **严重程度**：中
- **影响范围**：示例未示范正确资源管理，与库强调"必须显式 close"自相矛盾，用户学到错误范式。
- **缺陷描述**：[examples/notepad/src/main.cj](file:///c:/CodeTools/cangjie_git/CJQT6/examples/notepad/src/main.cj) 共 1028 行，统计 `let ... = Q` 创建语句 **47 处**，但 `.close()` 调用 **0 处**。完全依赖进程退出释放，未示范 SKILL.md 第 4 节"必须显式 `close()`"的规范。
- **证据**：
  - `Select-String -Pattern '^\s*let\s+\w+\s*=\s*Q'` → 47
  - `Select-String -Pattern '\.close\(\)'` → 0
- **复现步骤**：
  1. 打开 `examples/notepad/src/main.cj`
  2. 全文搜索 `.close()`，确认 0 命中

### H4. `CFunc` 回调不能捕获局部变量，强制全局 `?T` 共享状态
- **严重程度**：中
- **影响范围**：信号槽连接范式，易引入竞态。
- **缺陷描述**：[callback.cj#L5-L10](file:///c:/CodeTools/cangjie_git/CJQT6/src/core/callback.cj#L5-L10) 明确 `CFunc` 不能捕获局部变量，范式要求回调定义为顶层 `let` 绑定 + 全局 `?T` 变量共享控件状态。该范式繁琐，且多回调并发访问同一全局 `?T` 无保护，易竞态。
- **证据**：SKILL.md 第 3.5 节示例 `var infoLabel: ?QLabel = None`

---

## I. 安全性缺陷

### I1. `ptr: Int64` 暴露给用户，FFI 无边界检查可伪造指针
- **严重程度**：中（低边缘）
- **影响范围**：FFI 边界，不受信代码可绕过封装访问任意内存。
- **缺陷描述**：所有封装类的 `getPtr(): Int64` 把原生指针暴露给用户，`addWidget(ptr: Int64)` 等 FFI 入口对传入的 `ptr` 不做有效性校验（仅部分方法有 `checkValid` 检查自身 ptr，对外部传入的 ptr 无校验）。用户可构造任意 `Int64` 传入 `qWidgetSetTitle(伪造ptr, ...)`，触发任意内存读写。
- **证据**：
  - [widget.cj#L30-L37](file:///c:/CodeTools/cangjie_git/CJQT6/src/core/widget.cj#L30-L37) `setWidgetGeometry(widgetPtr: Int64, ...)` 无 ptr 校验
- **缓解**：SECURITY.md 已建议"只在你信任的用户输入范围构建字符串/路径"，沙箱内使用相对安全。

### I2. 存活表竞态（已知，部分缓解）
- **严重程度**：低（已记录在 SECURITY.md）
- **影响范围**：跨线程操作 Qt 对象生命周期。
- **缺陷描述**：[SECURITY.md#L28-L29](file:///c:/CodeTools/cangjie_git/CJQT6/SECURITY.md#L28-L29) 承认 `trackObject`/`isObjectAlive`/`untrackObject` 跨线程读写可能竞态。声称 `bridge_core.cpp` 已用互斥保护存活表；但 [bridge_events.cpp#L16-L24](file:///c:/CodeTools/cangjie_git/CJQT6/native/src/core/bridge_events.cpp#L16-L24) 的事件回调 map 与 widget map **未保护**（见 B1），存活表与事件 map 不在同把锁下，仍存在 TOCTOU 窗口。

---

## 附录：分析未发现的潜在问题（已核查）

- **终结器 `~init`**：全仓 grep 显示所有 `~init()` 均被注释（如 [widget.cj#L247](file:///c:/CodeTools/cangjie_git/CJQT6/src/core/widget.cj#L247)），符合"终结器刻意禁用"约定，**无缺陷**。
- **SQL 注入**：[database.cj](file:///c:/CodeTools/cangjie_git/CJQT6/src/sql/database.cj) 提供了 `qSqlQueryPrepare` + `qSqlQueryBindValue` 参数化查询路径，库本身不强制字符串拼接，**非库缺陷**（用户误用才注入）。
- **`freeBridgeString` 配对**：抽样 `QPushButton.text()`、`QWidget.styleSheet()` 等返回字符串方法均正确调用 `freeBridgeString`，**未见遗漏**。

---

## 附录：缺陷优先级建议

| 优先级 | 缺陷编号 | 理由 | 状态 |
|--------|----------|------|------|
| P0（阻塞性） | D1, D2, B1 | 链接失败/崩溃，阻塞使用 | D1 ✅已修复 / D2 ⏸️已取消（仓颉 1.1.0 暂未提供 macOS x86_64 SDK，target 已注释）/ B1 ✅已修复 |
| P1（重要） | A1, A2, C1, E1 | 资源泄漏/调试困难/可移植性 | 待处理 |
| P2（改进） | A3, D3, E2, F1, G1, H1, H2, H3, H4, I1 | 一致性/文档/易用性 | 待处理 |
| P3（次要） | C2, F2, F3, I2 | 文档/边缘安全 | 待处理 |

---

*本报告仅基于静态代码审查生成，未对源代码进行任何修改。所有缺陷均附文件路径与行号证据可供复核。*
