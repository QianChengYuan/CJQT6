# macOS Intel (x86_64)

**当前版本暂不提供预编译桥接库。**

原因：仓颉 **1.1.0 版本暂未提供 macOS x64（x86_64）SDK**，无法在 Intel Mac 上编译仓颉侧代码，故本目录无 `libcjqt6_bridge.dylib`，`cjpm.toml` 中 `[target.x86_64-apple-darwin]` 段也已注释。

待仓颉官方后续版本提供 macOS x64 SDK 后，可通过 `scripts/build-macos-x64.sh` 构建并部署 `libcjqt6_bridge.dylib` 到本目录。

> macOS Apple Silicon（arm64）已提供预编译 `libcjqt6_bridge.dylib`，见 `../macos-arm64/`。
