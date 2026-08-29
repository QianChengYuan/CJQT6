# AGENTS.md — CJQT6

CJQT6（版本 1.9.0）是仓颉(Cangjie)语言的 Qt6 封装库：仓颉源码（`src/`）通过 FFI 调用 C++ 桥接动态库（`cjqt6_bridge`，`native/`）包装 Qt6 API。远端仓库在 **GitCode**（`https://gitcode.com/yuan_1992/CJQT6.git`）；GitHub 镜像仓（`QianChengYuan/CJQT6`）挂载 `.github/workflows/ci.yml` 跑三端无人值守 CI（Linux 主仓、Windows 镜像仓）。

> **最重要参考**：本仓库自带 `.agents/skills/cjqt6/SKILL.md`（随 git 版本化），包含模块地图、API 约定、信号槽写法、内存管理陷阱与常见错误速查。写任何 cjqt6 代码前先读它，再以同模块已有 `.cj` 文件为范式。

## 构建（两步，顺序不可颠倒）

任何改动后验证，都必须先重编 C++ 桥接库，再 `cjpm build`。桥接库产物必须部署到 `releases/<platform>/`，`cjpm.toml` 的 `link-option` 引用它。

**Windows（推荐一键脚本）**：
```powershell
.\scripts\update-bridge.ps1          # 自动探测 QTDIR → cmake configure+build → 同步 dll/lib 到 releases/windows-x64/
cjpm build                            # 链接 releases/windows-x64/cjqt6_bridge.lib
```

**Linux**：
```bash
bash scripts/build-linux-x64.sh      # 产物部署到 releases/linux-x64/
cjpm build
```

手动方式（Windows）：`cmake ..\.. -G "Visual Studio 17 2022" -A x64 -DCMAKE_PREFIX_PATH="$env:QTDIR"` + `cmake --build . --config Release`，再把 `native\build_windows_x64\bin\cjqt6_bridge.dll` 和 `lib\cjqt6_bridge.lib` 拷到 `releases\windows-x64\`。

**运行示例/程序**：Qt 运行时 DLL 必须可找到，先 `.\scripts\setup-qt-env.ps1`（或把 `C:\Qt\6.10.3\msvc2022_64\bin` 加入 PATH），然后 `cd examples/<name> && cjpm run`。发布部署用 `windeployqt.exe` 或示例目录内的 `deploy_qt.ps1`。

## 已知坑（踩过才会知道）

- **增量构建陷阱**：`native\build_windows_x64` 有 CMake 缓存时，`cmake --build` 可能判定"已最新"跳过链接，导致改了 C++ 代码但行为不变。强制重编：`cmake --build . --config Release --clean-first`，或删掉 `native\build_windows_x64` 重来。
- **`cjpm.toml` 用 `${CJQT6_ROOT}` 环境变量替换链接路径**（Windows 目标段 `[target.x86_64-w64-mingw32]`：`link-option = "${CJQT6_ROOT}/releases/windows-x64/cjqt6_bridge.dll"`）。构建前必须设置 `CJQT6_ROOT` 指向仓库根目录（`scripts/update-bridge.ps1`、`scripts/verify_all.ps1`、`scripts/setup-qt-env.ps1/.sh` 已自动注入，CI 用 `github.workspace`）；**不设置会拼成 `/releases/...` 直接链接失败**。cjc 实际目标三元组是 `x86_64-w64-mingw32`（`cjc -v` 实测），顶层 `link-option` 已置空。
- **`tests/` 目录只保留部署脚本，测试源码已迁入根包 `src/test/`**（`package cjqt6.test`，23 个 `*_test.cj`），根目录 `cjpm test` 直接发现并运行；`docs/internal/`、`PUBLISHING.md`、`.agents/skills/`（除 `cjqt6/SKILL.md`）不入库。
- 示例（`examples/`）是独立 cjpm 工程，通过 `cjqt6 = { path = "../../" }` 依赖根包；其 `link-option` 也含本机绝对路径。
- `src/main.cj` 只是打印占位，不是入口；库本身是 `output-type = "dynamic"`，真正的运行入口在各示例。

## 目录地图（只列会影响行为的）

| 路径 | 说明 |
|------|------|
| `src/<module>/` | 仓颉封装源码（13 子包：core/widgets/gui/dialogs/menu/paint/qml/multimedia/network/sql/views/print/resource；`process` 仅在桥接层 `native/src/process/`，仓颉封装未单独建包） |
| `src/test/` | 测试源码（`package cjqt6.test`，23 个 `*_test.cj`，根目录 `cjpm test` 发现） |
| `native/src/<module>/bridge_*.cpp` | C++ FFI 桥接实现（53 个 .cpp，模块含 core/gui/widgets/views/multimedia/network/paint/print/process/qml/sql/tools），`extern "C"` 导出 `qXxx*` 函数；改它必须重编 bridge |
| `native/includes/*.h` | 桥接头文件（含 MOC 类 gui.h/widgets.h/signalemitter.h） |
| `releases/<platform>/` | 预编译桥接库（入库），cjpm 链接目标；现有 `windows-x64/`、`linux-x64/` 含实际产物，`macos-arm64/`、`macos-x64/` 仅占位 README |
| `examples/` | 19 个独立示例工程（notepad/calculator/dormitory_manager/qq_chat_lan…） |
| `tests/` | 只保留部署脚本 `deploy_qt_test.ps1` / `deploy_qt.ps1`（构建产物不入库） |
| `scripts/` | `update-bridge.ps1`、`rebuild_all.ps1`、`setup-qt-env.ps1/.sh`、`build-linux-x64.sh` 等 |
| `docs/` | `guides/`（构建/架构/交叉编译/性能/版本矩阵/封装模板）、`api/01~20`、`internal/`（评估/覆盖度/控件分析）、`resource/`、`testing/`、`tutorial/` |
| `.agents/skills/cjqt6/SKILL.md` | 项目自带 skill，权威速查（必读） |

## 写仓颉代码的硬约束（仓颉 1.1.0）

- 每个 Qt 对象封装为 class，实现 `QtResource` 接口：持有 `ptr: Int64`，`checkValid()` 守卫，`close()` 释放，`getPtr(): Int64` 取指针。
- **终结器（`~init`）被刻意禁用**：GC 时机不确定，依赖它会在 Qt 对象仍被使用时提前删除导致崩溃。用完必须显式 `close()`/`delete()`，不要依赖 GC。
- 所有 `foreign func` 调用必须包在 `unsafe { }` 内。
- 字符串过 FFI：`LibC.mallocCString(s)` 分配、用完 `LibC.free(c)`；返回的 `CString` 立即 `.toString()`，不要长期持有。
- 无三元运算符（用 if/else 表达式）；默认参数**仅支持命名参数**（`p!: T = 默认值`），非命名参数无默认值——库中可选参数用重载实现（如 `addWidget(ptr)` 与 `addWidget(ptr, stretch)`）；`match` 分支体允许 1~N 行 exprs（每行一个表达式，分支值取最后一行），**不能**用 `{}` 包裹（`case x =>` 后直接多行平铺）。
- `CFunc` 回调**不能捕获局部变量**——回调定义为顶层 `let` 绑定 + 全局 `?T` 变量共享状态，再传给 `setOnXxx(...)`。
- 布局 `addWidget`/`addLayout`/`setLayout` 收的是 **`Int64` 原生指针**（`xxx.getPtr()`），不是对象；`setAlignment` 收 `Int32`（`Alignment.Center.value`）。
- `Int64` 作 Map 键需 `& 0x3FFFFFFF` 位掩码；`ArrayList` 用 `.add()`/`.size`。

## 测试

- 测试源码已迁入根包 `src/test/`（`package cjqt6.test`，23 个 `*_test.cj`，约 1684 个 `@Expect` 断言），**根目录 `cjpm test` 直接发现并运行**，随仓库版本化。
- Windows 一键跑测试：`powershell -File tests\deploy_qt_test.ps1 -RunTest`（部署 Qt 运行时 + offscreen 平台 + 跑全量）；Linux 无显示环境用 `xvfb-run cjpm test`。
- GUI 测试类用 `GUITestEnvironment`（`src/core/gui_test_env.cj`）在 `@BeforeAll` 里建 `QApplication`。规范见 `docs/testing/test-guide.md` 与 `test-specification.md`（`@TestCase`/`@Expect`/`@ExpectThrows`）。
- 崩溃退出码 3221227010 通常是缺 QApplication 实例。

## 新增控件/类的流程（CONTRIBUTING 有简版）

1. `native/src/<module>/bridge_*.cpp` 加 `extern "C"` 函数（含 `qXxxDelete`）+ `native/includes/*.h` 声明；
2. 把 .cpp 加进根 `CMakeLists.txt` 对应模块 SOURCES 列表；
3. 重编 bridge 并同步 `releases/`；
4. `src/<module>/xxx.cj` 写封装 class（foreign 声明 + QtResource + checkValid + close）；
5. `cjpm build` 验证，补 `src/test/` 测试与 `docs/api/` 文档。

## 语言/风格

- 全仓库文档、注释、commit message 均为**中文**，写代码注释与文档请跟随。
- 命名：类大驼峰 `QPushButton`、函数小驼峰 `setText()`；C++ 桥接函数 `qXxxCreate`/`qXxxSetXxx`。
- 格式化用 `cjfmt`、静态检查用 `cjlint`（本项目无强制 CI 门槛，但保持与同模块文件一致）。
