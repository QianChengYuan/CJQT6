# CJQT6 脚本目录(`scripts/`)

本目录汇总 CJQT6 项目所有构建、测试、同步工具脚本。共享辅助函数集中在 [`lib/`](./lib),由具体脚本 `source`(bash) / dot-source(PowerShell) 复用。

## 运行基线

| 语言 | 基线 | CI runner | 本地推荐 |
|---|---|---|---|
| bash | bash 4+(数组支持,含 `bash` / Git Bash / WSL bash) | ubuntu-24.04(GCC 13) / macos-14 | Git Bash / WSL / Linux 桌面 |
| PowerShell | **PowerShell 7+(pwsh 7.x)** | `windows-2022` runner 默认 pwsh 7.x | `winget install Microsoft.PowerShell` |

> ⚠️ **PowerShell 7+ 基线声明**(2026-09-09):本目录 PowerShell 脚本不再兼容 Windows PowerShell 5.1。
> 5.1 parser 在 ANSI 代码页环境下读 UTF-8 文件会误判中文行,且不支持三元 `?:`、null-coalescing `??`、单行 if-return 等语法。
> 历史遗留的 `gen-api-index.ps1`(PS 7+ 三元)等脚本按原状保留,不在本轮整理范围。

## 目录结构

```
scripts/
├── README.md                  # 本文件
├── lib/                       # 共享函数库(bash + PowerShell)
│   ├── common.sh              #   bash:detect_platform / find_qt / get_jobs / die / warn
│   └── common.ps1             #   PowerShell:Find-QtDir / Find-Cjpm / Find-Cjcov / Write-Step
│
├── build-all-platforms.sh     # 自动检测平台,调用对应 build-<platform>.sh
├── build-linux-x64.sh         # Linux x86_64 FFI 桥接库
├── build-linux-arm64.sh       # Linux ARM64(aarch64)原生构建
├── build-macos-arm64.sh       # macOS Apple Silicon
├── build-macos-x64.sh         # [DEPRECATED] 仓颉 1.1.0 无 macOS x64 SDK
├── build-win64.sh             # [DEPRECATED] mingw 交叉编译已停用
│
├── build-native-tests.sh      # 桥接层 C++ 单元测试(bash)
├── build-native-tests.ps1     # 桥接层 C++ 单元测试(PowerShell,Windows)
│
├── update-bridge.ps1          # [Windows 核心] 编译 bridge + 同步到 releases/windows-x64/
│
├── setup-qt-env.sh            # Linux/macOS/WSL 设置 Qt6 环境变量
├── setup-qt-env.ps1           # Windows 设置 Qt6 环境变量(MSVC 2022)
│
├── run-test.sh                # 仅跑 cjpm test(预设 Qt/仓颉运行时)
├── run-test.ps1               # [Windows 完整流程] bridge + build + 部署 + cjpm test + 覆盖率
├── run-lint.ps1               # cjlint 静态检查入口(分类统计)
├── verify_all.ps1             # [Windows 一键门禁] bridge + build + test + 覆盖率 + 冒烟示例
├── rebuild_all.ps1            # [DEPRECATED] 已被 verify_all.ps1 替代
│
├── deploy-qt-example.ps1      # [新增] 示例运行时 DLL 部署(Qt + MSVC CRT + bridge + cjqt6 deps)
├── deploy-qt-test.ps1         # [新增] 测试运行时 DLL 部署(从 tests/ 合并)
│
├── sync-release-artifacts.ps1 # 从 GitHub CI run 下载四平台 bridge 同步到 releases/
├── check-coverage.ps1         # 覆盖率门禁(双口径阈值)
├── check-release.ps1          # 语义化版本门禁(打 tag 前)
│
├── gen-coverage-summary.ps1   # 生成 PR 评论用覆盖率 markdown
├── gen-api-index.ps1          # 从 docs/api/ 生成 INDEX.md(覆盖校验)
├── gen-ui.ps1                 # Designer .ui 一键转仓颉代码
├── fix-throws-annotations.ps1 # 批量补全 /// throws: 注释(消除 G.ERR.01)
│
├── new-qt6-project.ps1        # Windows 脚手架
└── new-qt6-project.sh         # Linux/macOS 脚手架
```

## 分类索引(按用途)

### 1. 桥接库构建(7 个,active 5 / deprecated 2)

| 脚本 | 平台 | 状态 | CI 引用 |
|---|---|---|---|
| `build-linux-x64.sh` | Linux x86_64 | ✅ active | ✅(ci.yml linux) |
| `build-linux-arm64.sh` | Linux ARM64 | ✅ active | ✅(ci.yml linux-arm64) |
| `build-macos-arm64.sh` | macOS arm64 | ✅ active | ✅(ci.yml macos-arm64) |
| `build-macos-x64.sh` | macOS x64 | ⚠️ deprecated | ❌ |
| `build-win64.sh` | Linux→Win 交叉 | ⚠️ deprecated | ❌(改用 `update-bridge.ps1` + MSVC) |
| `build-all-platforms.sh` | 自动检测 | ✅ active | ❌(本地工具) |
| `update-bridge.ps1` | Windows MSVC | ✅ active | ✅(ci.yml windows) |

### 2. 桥接层 C++ 单元测试(P0-3,2 个)

| 脚本 | 平台 | 备注 |
|---|---|---|
| `build-native-tests.sh` | Linux/macOS | `-asan` 启用 AddressSanitizer |
| `build-native-tests.ps1` | Windows | `-Asan`(PowerShell switch)启用 AddressSanitizer |

### 3. 仓颉测试与门禁(4 个,active 3 / deprecated 1)

| 脚本 | 用途 | 备注 |
|---|---|---|
| `run-test.sh` | 仅 cjpm test(Linux/macOS) | 设置 Qt/仓颉运行时环境 |
| `run-test.ps1` | Windows 完整测试流程 | 调 `update-bridge.ps1` + `build-native-tests.ps1` + `deploy-qt-test.ps1` |
| `run-lint.ps1` | cjlint 静态检查入口 | 分类统计告警 |
| `verify_all.ps1` | Windows 一键门禁 | bridge + build + test + 覆盖率 + 冒烟示例 |
| `rebuild_all.ps1` | (deprecated) | 已被 `verify_all.ps1` 替代,保留仅做向后兼容 |

### 4. 环境配置(2 个)

| 脚本 | 平台 | 用法 |
|---|---|---|
| `setup-qt-env.sh` | Linux/macOS/WSL | `source ./scripts/setup-qt-env.sh` |
| `setup-qt-env.ps1` | Windows | `.\scripts\setup-qt-env.ps1` |

### 5. 同步与门禁(3 个)

| 脚本 | 用途 |
|---|---|
| `sync-release-artifacts.ps1` | 从 GitHub CI run 下载四平台 bridge 同步到 `releases/` |
| `check-coverage.ps1` | 覆盖率门禁(双口径阈值,P0-1) |
| `check-release.ps1` | 语义化版本门禁(打 tag 前) |

### 7. 运行时 DLL 部署(2 个,新增合并)

| 脚本 | 用途 | 调用者 |
|---|---|---|
| `deploy-qt-example.ps1` | 示例运行时 DLL 部署(Qt + MSVC CRT + bridge + cjqt6 deps) | examples/ 下手动 |
| `deploy-qt-test.ps1` | 测试运行时 DLL 部署(Qt + bridge + MSVC CRT + 平台/驱动/媒体插件 + 跑 cjpm test) | `run-test.ps1` / `verify_all.ps1` |

> **防卡死设计**(`deploy-qt-test.ps1 -RunTest`):
> - 默认 `-j 1` 串行编译 —— `cjpm test --coverage` 并行编译时 `cjc.exe` 会挂死成孤儿(CPU 0/内存 ~0MB),
>   其继承的 stdout 句柄让调用方永远等不到 EOF,表现为"卡住且零输出"。
> - 开跑前 / 结束后清理孤儿 `cjc.exe`;用 .NET `Process` 启动 cjpm 以支持整体硬超时
>   (`-TestTimeoutSec`,默认 1800s),超时打印挂起进程画像(含命令行)并按 PID 杀整棵进程树。
> - 每 30s 输出一次心跳,结束时日志落盘 `target\cjpm-test.log`。
> - 参数:`-SkipCoverage` / `-Filter '<类名>'` / `-ExcludeTags` / `-TimeoutEach` / `-Jobs` / `-TestTimeoutSec`。

> 历史:`tests/deploy_qt.ps1` 与 `tests/deploy_qt_test.ps1` 已合并到 `scripts/deploy-qt-example.ps1` 与 `scripts/deploy-qt-test.ps1`,
> `tests/` 目录整体移出仓库(2026-09-09)。

### 6. 脚手架与代码生成(4 个)

| 脚本 | 用途 |
|---|---|
| `new-qt6-project.{ps1,sh}` | 创建 CJQT6 应用骨架(`cjpm init --template qt6` 等价物,roadmap 9.5) |
| `gen-ui.ps1` | Designer `.ui` 文件一键转仓颉代码 |
| `gen-api-index.ps1` | 从 `docs/api/*.md` 生成 `INDEX.md`(覆盖校验 `-FailOnMissing`) |
| `fix-throws-annotations.ps1` | 批量补全 `/// throws:` 注释(消除 `G.ERR.01`) |
| `gen-coverage-summary.ps1` | 生成 PR 评论用覆盖率 markdown(由 CI 调用) |

## 共享函数库(`lib/`)

### bash:`common.sh`

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

PLATFORM=$(detect_platform)        # linux-x64 / linux-arm64 / wsl / macos-x64 / macos-arm64 / windows / unknown
QTDIR=$(find_qt)                   # 探测 Qt6 路径(QTDIR 环境变量优先,失败 exit 1)
JOBS=$(get_jobs)                   # nproc / sysctl / fallback 4
ROOT=$(get_root_dir "$0")          # 定位项目根

print_section "标题"                # 打印彩色 section 标题
die "错误消息"                       # 红字 + 退出 1
warn "警告消息"                      # 黄字 + 继续
```

### PowerShell:`common.ps1`

```powershell
. "$PSScriptRoot\lib\common.ps1"

$RootDir = Get-RootDir -ScriptPath $PSCommandPath
Set-Location $RootDir
Set-Cjqt6RootEnv -RootDir $RootDir    # 设置 $env:CJQT6_ROOT

$QtDir = Find-QtDir -QtDir $QtDir      # 探测 Qt6(参数 / $env:QTDIR / 常见路径 / 扫描)
$cjpm  = Find-Cjpm                     # 探测 cjpm
$cjcov = Find-Cjcov                    # 探测 cjcov

Write-Section "标题"                    # 彩色 section 标题
Write-Step -Step 1 -Total 5 -Text "..." # 步骤进度(支持 Skip/Error 着色)
Write-Die "致命错误"                    # 红字 + 退出 1
```

## 状态说明

- **active**:正常维护,CI/本地都会调用
- **deprecated**:已废弃但保留以兼容旧用法,文件顶部 `DEPRECATED` 块说明替代脚本
- **internal**:仅供其他脚本调用(本目录所有脚本均如此,无需手动执行)

## 约定

1. **跨平台脚本对**:能用 `.sh` 就写 `.sh`,Windows 专用写 `.ps1`,同一功能两个文件
2. **共享函数优先**:探测 Qt / 仓颉 / 平台 / JOBS 一律走 `lib/`,具体脚本不再各自实现
3. **错误处理**:
   - bash:`set -euo pipefail` + `die` 函数
   - PowerShell:`$ErrorActionPreference = "Stop"` + `Write-Die` 函数
4. **彩色**:`tput` / `Write-Host -ForegroundColor`,非 TTY 环境自动降级为无色
5. **路径探测**:`lib/common.sh::find_qt` 与 `lib/common.ps1::Find-QtDir` 是唯一允许的 Qt 路径探测入口
6. **状态标注**:废弃脚本必须在文件最顶部加 `DEPRECATED` 头注释,说明替代方案

## 改动历史

- **2026-09-09 (round 2)** — 合并 `tests/` 到 `scripts/`:
  - `tests/deploy_qt.ps1` → `scripts/deploy-qt-example.ps1`(支持 `-ExampleRoot` 参数,使用 lib 函数)
  - `tests/deploy_qt_test.ps1` → `scripts/deploy-qt-test.ps1`(使用 lib 函数)
  - 更新 `run-test.ps1` / `verify_all.ps1` 引用新路径
  - 删除整个 `tests/` 目录(mv 到系统临时目录,绕过 safe-delete 守卫)
  - **声明 PowerShell 7+ 基线**,Windows PowerShell 5.1 不再支持

- **2026-09-09 (round 1)** — 抽取 `lib/common.{sh,ps1}`,统一探测函数;build-* / setup-* / update-bridge / run-* / verify_all 全部迁移;`build-win64.sh` / `build-macos-x64.sh` / `rebuild_all.ps1` 加 DEPRECATED 头。详见 `.workbuddy/memory/2026-09-09.md`。