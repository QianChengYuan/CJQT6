# install.ps1 — 仓颉 SDK 安装脚本(Windows)
# 由 .github/actions/setup-cangjie composite action 调用
# 通过环境变量 INPUT_OS / INPUT_VERSION / INPUT_URL_OVERRIDE / INPUT_SHA_OVERRIDE 传参

$ErrorActionPreference = "Stop"

$InputOS        = if ($env:INPUT_OS)        { $env:INPUT_OS }        else { "windows" }
$InputVersion   = if ($env:INPUT_VERSION)   { $env:INPUT_VERSION }   else { "1.1.0" }
$InputURL       = if ($env:INPUT_URL_OVERRIDE) { $env:INPUT_URL_OVERRIDE } else { "" }
$InputSHA       = if ($env:INPUT_SHA_OVERRIDE) { $env:INPUT_SHA_OVERRIDE } else { "" }

# 默认 objectKey(随 1.1.0 版本固定,官方重传可用 url-override 覆盖)
$defaultURLs = @{
  "windows" = "https://cangjie-lang.cn/v1/files/auth/downLoad?nsId=142267&fileName=cangjie-sdk-windows-x64-$InputVersion.zip&objectKey=69e9d12b21f5a8178d6fd213"
}
$defaultSHAs = @{
  "windows" = "3E2746B1C556441F1E0D8128CA23FE80A34583AFE2FA58A32F8ABB3B3C08B7E6"
}

$url = if ($InputURL) { $InputURL } else { $defaultURLs[$InputOS] }
$sha = if ($InputSHA) { $InputSHA } else { $defaultSHAs[$InputOS] }

if (-not $url) {
  Write-Host "::error::未找到平台 $InputOS 的 SDK URL,请通过 url-override input 覆盖"
  exit 1
}

New-Item -ItemType Directory -Force -Path "$env:RUNNER_TEMP\cangjie-sdk" | Out-Null
Write-Host "==> 下载仓颉 SDK: $url"
curl.exe -fL --retry 3 -o "$env:RUNNER_TEMP\cangjie-sdk.zip" $url

if ($sha) {
  Write-Host "==> 校验 SHA-256: $sha"
  $actual = (Get-FileHash "$env:RUNNER_TEMP\cangjie-sdk.zip" -Algorithm SHA256).Hash
  if ($actual -ne $sha) {
    Write-Host "::error::SDK SHA-256 校验失败: $actual (期望 $sha)"
    exit 1
  }
} else {
  Write-Host "::warning::平台 $InputOS 未配置 SHA-256,跳过校验"
}

Write-Host "==> 解压到: $env:RUNNER_TEMP\cangjie-sdk"
Expand-Archive -Path "$env:RUNNER_TEMP\cangjie-sdk.zip" -DestinationPath "$env:RUNNER_TEMP\cangjie-sdk" -Force

$envFile = Get-ChildItem "$env:RUNNER_TEMP\cangjie-sdk" -Recurse -Filter envsetup.ps1 | Select-Object -First 1
if (-not $envFile) {
  Write-Host "::error::解压后未找到 envsetup.ps1"
  exit 1
}
$CANGJIE_HOME = $envFile.DirectoryName

"CANGJIE_HOME=$CANGJIE_HOME"                                    | Out-File -FilePath $env:GITHUB_ENV  -Append
"$CANGJIE_HOME\bin"                                              | Out-File -FilePath $env:GITHUB_PATH -Append
"$CANGJIE_HOME\tools\bin"                                        | Out-File -FilePath $env:GITHUB_PATH -Append
# cjlint 依赖 libcjlint.dll(tools\lib),cjpm/cjc 依赖 libcangjie-runtime.dll(runtime\lib)
"$CANGJIE_HOME\tools\lib"                                        | Out-File -FilePath $env:GITHUB_PATH -Append
"$CANGJIE_HOME\runtime\lib\windows_x86_64_cjnative"              | Out-File -FilePath $env:GITHUB_PATH -Append

# step output(供 composite 顶层 outputs 引用)
"cangjie-home=$CANGJIE_HOME" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
Write-Host "==> 已安装到: $CANGJIE_HOME"