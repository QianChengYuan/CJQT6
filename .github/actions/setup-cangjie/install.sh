#!/bin/bash
# install.sh — 仓颉 SDK 安装脚本(Linux / macOS)
# 由 .github/actions/setup-cangjie/composite action 调用
# 通过环境变量 INPUT_OS / INPUT_VERSION / INPUT_URL_OVERRIDE / INPUT_SHA_OVERRIDE 传参

set -euo pipefail

INPUT_OS="${INPUT_OS:-linux}"
INPUT_VERSION="${INPUT_VERSION:-1.1.0}"
INPUT_URL_OVERRIDE="${INPUT_URL_OVERRIDE:-}"
INPUT_SHA_OVERRIDE="${INPUT_SHA_OVERRIDE:-}"

# 默认 objectKey(随 1.1.0 版本固定,官方重传可用 url-override 覆盖)
# SHA-256 默认值硬编码;macOS 暂未固定默认 SHA,需 vars.CANGJIE_SDK_SHA_MACOS 覆盖
# 注:不用关联数组(macOS bash 3.2 不支持 declare -A)
case "$INPUT_OS" in
  linux)
    DEFAULT_URL="https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-sdk-linux-x64-${INPUT_VERSION}.tar.gz&objectKey=69e9d50c21f5a8178d6fd219"
    DEFAULT_SHA="5ce7e8c8523aad9cf5965f818249e1a39f10788963aef7c5852697a3ac964060"
    ;;
  macos)
    DEFAULT_URL="https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-sdk-mac-aarch64-${INPUT_VERSION}.tar.gz&objectKey=69eac73121f5a8178d6fd21b"
    DEFAULT_SHA=""
    ;;
  linux-arm64)
    DEFAULT_URL="https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-sdk-linux-aarch64-${INPUT_VERSION}.tar.gz&objectKey=69e9d37021f5a8178d6fd216"
    DEFAULT_SHA="fe961bd2972632fb86cbb8bb2d536a9fcaa8308d348c6a4f9148276ee62f495a"
    ;;
  *)
    DEFAULT_URL=""
    DEFAULT_SHA=""
    ;;
esac

url="${INPUT_URL_OVERRIDE:-$DEFAULT_URL}"
sha="${INPUT_SHA_OVERRIDE:-$DEFAULT_SHA}"

if [ -z "$url" ]; then
  echo "::error::未找到平台 ${INPUT_OS} 的 SDK URL,请通过 url-override input 覆盖"
  exit 1
fi

mkdir -p "$RUNNER_TEMP/cangjie-sdk"
echo "==> 下载仓颉 SDK: $url"
curl -fL --retry 3 -o "$RUNNER_TEMP/cangjie-sdk.tar.gz" "$url"

if [ -n "$sha" ]; then
  echo "==> 校验 SHA-256: $sha"
  echo "$sha  $RUNNER_TEMP/cangjie-sdk.tar.gz" | sha256sum -c -
else
  echo "::warning::平台 ${INPUT_OS} 未配置 SHA-256,跳过校验(建议配 vars.CANGJIE_SDK_SHA_${INPUT_OS^^})"
fi

echo "==> 解压到: $RUNNER_TEMP/cangjie-sdk"
tar -xzf "$RUNNER_TEMP/cangjie-sdk.tar.gz" -C "$RUNNER_TEMP/cangjie-sdk"

# 探测 envsetup.sh(GNU find 与 BSD find 都支持 -maxdepth,仅 -printf 不通用)
CANGJIE_HOME="$(dirname "$(find "$RUNNER_TEMP/cangjie-sdk" -maxdepth 2 -name envsetup.sh | head -n1)")"
if [ -z "$CANGJIE_HOME" ]; then
  echo "::error::解压后未找到 envsetup.sh"
  exit 1
fi

echo "CANGJIE_HOME=$CANGJIE_HOME"            >> "$GITHUB_ENV"
echo "$CANGJIE_HOME/bin"                      >> "$GITHUB_PATH"
echo "$CANGJIE_HOME/tools/bin"                >> "$GITHUB_PATH"

# 运行时库路径(Linux / macOS 注入方式不同)
case "$INPUT_OS" in
  linux)
    echo "LD_LIBRARY_PATH=$CANGJIE_HOME/runtime/lib/linux_x86_64_cjnative:$CANGJIE_HOME/tools/lib:${LD_LIBRARY_PATH:-}" >> "$GITHUB_ENV"
    ;;
  linux-arm64)
    echo "LD_LIBRARY_PATH=$CANGJIE_HOME/runtime/lib/linux_aarch64_cjnative:$CANGJIE_HOME/tools/lib:${LD_LIBRARY_PATH:-}" >> "$GITHUB_ENV"
    ;;
  macos)
    # 动态探测 cjnative 子目录(macOS 实测为 darwin_aarch64_cjnative)
    CJ_RUNTIME_LIB="$(find "$CANGJIE_HOME/runtime/lib" -maxdepth 1 -type d -name '*cjnative' | head -n1)"
    if [ -z "$CJ_RUNTIME_LIB" ]; then
      echo "::error::未找到仓颉 runtime lib cjnative 目录($CANGJIE_HOME/runtime/lib 下)"
      ls -la "$CANGJIE_HOME/runtime/lib" || true
      exit 1
    fi
    echo "CJ_RUNTIME_LIB=$CJ_RUNTIME_LIB" >> "$GITHUB_ENV"
    echo "DYLD_LIBRARY_PATH=$CJ_RUNTIME_LIB:$CANGJIE_HOME/tools/lib:${DYLD_LIBRARY_PATH:-}" >> "$GITHUB_ENV"
    ;;
esac

# step output(供 composite 顶层 outputs 引用)
echo "cangjie-home=$CANGJIE_HOME" >> "$GITHUB_OUTPUT"
echo "==> 已安装到: $CANGJIE_HOME"