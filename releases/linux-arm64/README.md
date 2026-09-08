# Linux ARM64 (aarch64) 桥接库

本目录存放 Linux ARM64 平台的 C++ FFI 桥接库 `libcjqt6_bridge.so`。

## 平台信息

- **目标三元组**: `aarch64-unknown-linux-gnu`
- **产物**: `libcjqt6_bridge.so`（由 CMake 编译 C++ 桥接源码生成）
- **链接配置**: [cjpm.toml](../../cjpm.toml) 中 `[target.aarch64-unknown-linux-gnu]` 段

## 获取方式

### 方式一：CI 自动构建（推荐）

GitHub Actions 的 `linux-arm64` job 会在原生 ARM64 runner（`ubuntu-24.04-arm`）上编译桥接库，
并将 `libcjqt6_bridge.so` 作为 artifact 上传。

1. 触发 CI（push / PR / workflow_dispatch）
2. 在 workflow 运行结果的 Artifacts 中下载 `cjqt6-bridge-linux-arm64`
3. 将其中的 `libcjqt6_bridge.so` 放入本目录

### 方式二：本地原生构建

在 ARM64 Linux 主机上执行（Qt6 通过 apt 安装）：

```bash
# 安装 Qt6 开发包（Ubuntu/Debian）
sudo apt-get install qt6-base-dev qt6-declarative-dev qt6-tools-dev \
  qt6-multimedia-dev qt6-charts-dev qt6-svg-dev

# 构建（QTDIR 指向 multiarch 系统库目录，含 cmake/Qt6）
QTDIR=/usr/lib/aarch64-linux-gnu bash scripts/build-linux-arm64.sh
```

脚本会自动将产物部署到 `releases/linux-arm64/`。

> **注意**：Qt 官方公共镜像（aqtinstall）不提供 ARM64 Linux 预编译包，
> 因此 ARM64 上需通过系统包管理器（apt）安装 Qt6。

### 方式三：交叉编译（从 x64 主机）

参考 [docs/guides/cross-compile.md](../../docs/guides/cross-compile.md) 中的 ARM64 交叉编译章节，
需要安装 `gcc-aarch64-linux-gnu`、`g++-aarch64-linux-gnu` 及 ARM64 版 Qt6。

## 依赖

- Qt6 >= 6.2（Core, Gui, Widgets, Qml, Quick, Sql, Multimedia, Charts）
- 运行时需 `libstdc++.so.6` 及 Qt6 各组件共享库

> **注意**：本目录初始不含 `libcjqt6_bridge.so`，需通过上述方式构建后放入。
> 若该文件缺失，在 ARM64 Linux 上执行 `cjpm build` 会因链接失败（`cannot find -lcjqt6_bridge`）而报错。
