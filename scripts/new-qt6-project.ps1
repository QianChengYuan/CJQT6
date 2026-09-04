#!/usr/bin/env pwsh
# CJQT6 项目脚手架 —— 快速创建 CJQT6 应用骨架
# 用法: .\scripts\new-qt6-project.ps1 -Name myapp
#       .\scripts\new-qt6-project.ps1 -Name myapp -Path ./projects
# 对应 roadmap 9.5：cjqt6-cli 脚手架（cjpm init --template qt6 等价物）

param(
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [string]$Path = "."
)

$projectDir = Join-Path $Path $Name

if (Test-Path $projectDir) {
    Write-Host "❌ 目录已存在: $projectDir" -ForegroundColor Red
    exit 1
}

# 创建目录结构
New-Item -ItemType Directory -Force -Path "$projectDir/src" | Out-Null

# 生成 cjpm.toml
$cjpmContent = @"
[package]
  cjc-version = "1.1.0"
  name = "$Name"
  description = "CJQT6 应用 - $Name"
  version = "1.0.0"
  target-dir = ""
  output-type = "executable"
  compile-option = ""
  override-compile-option = ""
  # link-option 需指向 CJQT6 桥接库；设置 CJQT6_ROOT 环境变量指向 CJQT6 仓库根目录
  link-option = "-L`${CJQT6_ROOT}/releases/windows-x64 -lcjqt6_bridge"
  package-configuration = {}

[dependencies]
  # 方式一：git 依赖（推荐，发布时用）
  cjqt6 = { git = "https://gitcode.com/yuan_1992/CJQT6.git", tag = "v1.9.0" }
  # 方式二：本地路径依赖（开发调试时用，取消注释并调整路径）
  # cjqt6 = { path = "../CJQT6" }
"@
$cjpmContent | Out-File -FilePath "$projectDir/cjpm.toml" -Encoding utf8 -NoNewline

# 生成 src/main.cj 骨架
$mainContent = @"
package $Name

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*

// ============================================================
// $Name - CJQT6 应用入口
// ============================================================

main(): Int32 {
    let app = QApplication()

    let window = QWidget()
    window.setTitle("$Name")
    window.resize(400, 300)

    // 在此添加控件...
    let layout = QVBoxLayout()
    layout.setMargin(20)

    let label = QLabel()
    label.setText("Hello CJQT6!")
    label.setAlignment(Alignment.Center.value)
    layout.addWidget(label.getPtr())

    window.setLayout(layout.getPtr())
    window.show()

    let result = app.exec()
    return result
}
"@
$mainContent | Out-File -FilePath "$projectDir/src/main.cj" -Encoding utf8 -NoNewline

# 生成 README
$readmeContent = @"
# $Name

基于 [CJQT6](https://gitcode.com/yuan_1992/CJQT6) 的仓颉 Qt6 应用。

## 构建

```bash
# 设置 CJQT6_ROOT 环境变量指向 CJQT6 仓库根目录
# 设置 QTDIR 指向 Qt6 安装路径（如 C:\Qt\6.10.3\msvc2022_64）
cjpm build
```

## 运行

```bash
cjpm run
```
"@
$readmeContent | Out-File -FilePath "$projectDir/README.md" -Encoding utf8 -NoNewline

Write-Host "✅ 已创建 CJQT6 项目: $projectDir" -ForegroundColor Green
Write-Host ""
Write-Host "目录结构:" -ForegroundColor Cyan
Write-Host "  $projectDir/"
Write-Host "    ├── cjpm.toml"
Write-Host "    ├── README.md"
Write-Host "    └── src/"
Write-Host "        └── main.cj"
Write-Host ""
Write-Host "后续步骤:" -ForegroundColor Yellow
Write-Host "  cd $projectDir"
Write-Host "  cjpm build"
Write-Host "  cjpm run"