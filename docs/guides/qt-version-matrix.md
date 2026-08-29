# CJQT6 Qt 版本 × 平台兼容矩阵

> **目的**：明确 CJQT6 对 Qt6 小版本的支持边界，记录已验证组合与踩坑结论（P1-2）。
> **结论先行**：CJQT6 通过 FFI 动态链接 Qt6，**对 Qt 小版本敏感**（详见下文 ABI 说明），
> 各平台以「锁定版本」为准，换版本需重编 bridge 并跑全量测试。

## 1. 兼容矩阵

| 平台 | 桥接库产物 | 锁定 Qt 版本 | 验证方式 | 状态 |
|------|-----------|-------------|----------|------|
| Windows x64 (MSVC 2022) | `releases/windows-x64/` | **6.10.3** (msvc2022_64) | CI（windows-2022）+ 本机 | ✅ 全量用例通过 |
| Windows x64 (MinGW) | `releases/windows-x64/` | 6.10.3 (mingw_64) | 本机交叉验证 | ⚠️ 见 ABI 说明 |
| Linux x86_64 (GCC) | `releases/linux-x64/` | **6.4.2** (gcc_64) | CI（ubuntu-24.04）+ WSL | ✅ 全量用例通过（requires_audio 组按需跳过） |
| macOS x86_64 | `releases/macos-x64/` | 待定 | 无（P1-3 待做） | ⏳ 占位 |
| macOS arm64 | `releases/macos-arm64/` | 待定 | 无（P1-3 待做） | ⏳ 占位 |

## 2. 为什么要锁定 Qt 小版本（ABI 说明）

CJQT6 的 `cjqt6_bridge` 动态库直接链接 Qt6 的 `Qt6Core/Gui/Widgets/...` DLL/SO。
Qt **小版本之间存在 ABI 差异**，换版本后旧 bridge 可能**静默缺符号**或**加载失败**：

| 已踩坑 | 影响版本 | 表现 | 解决方案 |
|--------|----------|------|----------|
| `qt_qFindChild_helper` 符号移除 | ≥ 6.5（6.10.3 实测） | bridge DLL 加载时报「无法定位程序输入点 qt_qFindChild_helper」，整个 DLL 无法加载 | 已改用手动递归遍历 `QObject::children()` + `qobject_cast`（`native/src/qml/bridge_qml.cpp`） |
| `QSpinBox/QDoubleSpinBox::valueChanged(QString)` 重载移除 | Qt 6 全系 | 编译期报错 | 文本变化走既有 `setOnTextChanged`（`textChanged(const QString&)`），与数值 `setOnValueChanged` 并存 |
| `QRegExpValidator` 移除 | Qt 6 全系 | 编译期报错 | 改用 `QRegularExpressionValidator` |
| MinGW bridge 与 MSVC 运行时 ABI 不兼容 | MinGW 构建产物 | 仓颉 MSVC 运行时下 DLL 加载异常 | 一律用 MSVC 2022 构建 Windows 桥接库 |

**红线**：`releases/<platform>/` 中的预编译产物**必须**与使用的 Qt 小版本匹配，
否则 `cjpm build` 链接的是旧产物、行为与预期不符（见 `docs/guides/build-guide.md`「增量构建陷阱」）。

## 3. 版本更换指南

### 3.1 换 Qt 小版本必须做的三件事

1. **重编 bridge**（必须 `--clean-first` 或删除 `native/build_*` 缓存，防止 CMake 误判"已最新"跳过链接）：
   - Windows：`.\scripts\update-bridge.ps1 -QtDir "C:\Qt\<新版本>\msvc2022_64"`
   - Linux：`QTDIR=<新版本> bash scripts/build-linux-x64.sh`
2. **同步 `releases/<platform>/`**：把新编译的 `cjqt6_bridge.dll`/`libcjqt6_bridge.so` 拷入（脚本已自动完成）。
3. **跑全量测试**：`cjpm test`（无显示环境用 `xvfb-run` / offscreen），确认目标版本通过后再定版。

### 3.2 动态链接换版本（快速尝试）

在 `cjpm.toml` 或示例中调整 Qt 运行时 DLL 的搜索路径即可切换运行时 Qt，
但**仓颉侧只需重编 bridge**（bridge 是唯一静态绑定 Qt ABI 的层）。不重编 bridge 直接换运行时 =
加载旧符号集，行为不可预期。

## 4. 当前锁定版本的实测记录

| 版本 | 平台/工具链 | 实测结论 |
|------|------------|----------|
| Qt 6.10.3 (msvc2022_64) | Windows 10/11 + MSVC 2022 | 全量用例通过；`valueChanged(QString)` 编译期报错；`qt_qFindChild_helper` 已不导出 |
| Qt 6.10.2 (msvc2022_64) | 本机历史版本 | 曾用于开发期验证 |
| Qt 6.7.0 (msvc2019_64) | 本机历史版本 | 曾用于开发期验证 |
| Qt 6.4.2 (gcc_64) | Ubuntu 24.04 + GCC 13.3 | 全量用例通过（requires_audio 组跳过）；gstreamer 1.24 下多媒体测试正常退出 |

## 5. 维护约定

- 每引入一个新 Qt 小版本支持，必须在**该版本上跑一次全量测试**并回填本矩阵第 4 节。
- 不承诺"全 Qt6 系列通吃"；`docs/internal/api-completeness.md` 的 API 覆盖基于锁定版本验证。
- 若某版本出现 ABI 断裂且无法通过源码规避，升级方案应写入 `docs/CHANGELOG.md` 的 Unreleased 段。
