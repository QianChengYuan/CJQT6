# macOS Apple Silicon (arm64)

此目录存放预编译的 libcjqt6_bridge.dylib（macOS arm64）。
由 scripts/build-macos-arm64.sh 构建并部署，或从 GitHub Actions CI artifact 回填。

## 产物来源

- `libcjqt6_bridge.dylib`：由 GitHub Actions CI macOS job（run 43，commit `7132b7a`）构建
  - 构建环境：macOS 14 runner，Qt 6.4.2 (clang_64 universal2)，仓颉 SDK 1.1.0
  - 架构：arm64（从 universal2 中提取）
  - CI 配置：`.github/workflows/ci.yml` macOS job，artifact 名 `cjqt6-bridge-macos-arm64`

