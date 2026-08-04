# ============================================================
# QQ局域网聊天 - 协议端到端测试
# 模拟两个客户端：注册 -> 登录 -> 加好友 -> 互发消息 -> 离线消息 -> 心跳
# 用法：先启动服务端，再运行
#   powershell -ExecutionPolicy Bypass -File e2e_test.ps1
# 注意：本文件需保存为 UTF-8 with BOM，否则 Windows PowerShell 5.1 中文乱码
# ============================================================
$ErrorActionPreference = "Stop"
$serverHost = "127.0.0.1"
$port = 9600
$script:pass = 0
$script:fail = 0

function Assert($cond, $name) {
    if ($cond) { $script:pass++; Write-Host ("  [PASS] " + $name) -ForegroundColor Green }
    else { $script:fail++; Write-Host ("  [FAIL] " + $name) -ForegroundColor Red }
}

function New-ChatClient {
    $c = New-Object System.Net.Sockets.TcpClient
    $c.Connect($serverHost, $port)
    return @{ Client = $c; Buffer = "" }
}

function Send-Frame($sess, $json) {
    $bytes = [Text.Encoding]::UTF8.GetBytes($json + [char]10)
    $sess.Client.GetStream().Write($bytes, 0, $bytes.Length)
    $sess.Client.GetStream().Flush()
}

function Read-Frame($sess) {
    $stream = $sess.Client.GetStream()
    $buf = New-Object byte[] 65536
    $deadline = (Get-Date).AddSeconds(8)
    while ($true) {
        $idx = $sess.Buffer.IndexOf([string][char]10)
        if ($idx -ge 0) {
            $line = $sess.Buffer.Substring(0, $idx)
            $sess.Buffer = $sess.Buffer.Substring($idx + 1)
            return $line
        }
        if ((Get-Date) -gt $deadline) { throw ("read timeout, buffer=" + $sess.Buffer) }
        if ($stream.DataAvailable) {
            $n = $stream.Read($buf, 0, $buf.Length)
            $sess.Buffer += [Text.Encoding]::UTF8.GetString($buf, 0, $n)
        } else {
            Start-Sleep -Milliseconds 30
        }
    }
}

$msgHello = "你好 Bob，局域网聊天测试！"
$msgReply = "收到！我是 Bob。"
$msgOffline = "这是离线消息"

Write-Host "== 1. 注册两个账号 =="
$alice = New-ChatClient
Send-Frame $alice '{"type":"register","nickname":"Alice","password":"pass1234"}'
$r = Read-Frame $alice | ConvertFrom-Json
Assert ($r.type -eq "reg_ok") "Alice 注册返回 reg_ok"
$accA = $r.account
Write-Host ("  Alice 账号: " + $accA)

$bob = New-ChatClient
Send-Frame $bob '{"type":"register","nickname":"Bob","password":"pass1234"}'
$r = Read-Frame $bob | ConvertFrom-Json
Assert ($r.type -eq "reg_ok") "Bob 注册返回 reg_ok"
$accB = $r.account
Write-Host ("  Bob 账号: " + $accB)

Write-Host "== 2. 登录 =="
Send-Frame $alice ('{"type":"login","account":' + $accA + ',"password":"pass1234"}')
$r = Read-Frame $alice | ConvertFrom-Json
Assert ($r.type -eq "login_ok") "Alice 登录成功"
Assert ($r.nickname -eq "Alice") "Alice 昵称正确"
$idA = $r.id

Send-Frame $bob ('{"type":"login","account":' + $accB + ',"password":"wrong"}')
$r = Read-Frame $bob | ConvertFrom-Json
Assert ($r.type -eq "error" -and $r.op -eq "login") "错误密码被拒绝"

Send-Frame $bob ('{"type":"login","account":' + $accB + ',"password":"pass1234"}')
$r = Read-Frame $bob | ConvertFrom-Json
Assert ($r.type -eq "login_ok") "Bob 登录成功"
$idB = $r.id

$r = Read-Frame $alice | ConvertFrom-Json
Assert ($r.type -eq "presence" -and $r.userId -eq $idB -and $r.online -eq $true) "Alice 收到 Bob 上线通知"

Write-Host "== 3. 添加好友 =="
Send-Frame $alice ('{"type":"add_friend","account":' + $accB + '}')
$r = Read-Frame $alice | ConvertFrom-Json
Assert ($r.type -eq "ok" -and $r.op -eq "add_friend") "Alice 收到加好友成功"
Assert ($r.friend.nickname -eq "Bob") "好友信息为 Bob"

$r = Read-Frame $bob | ConvertFrom-Json
Assert ($r.type -eq "friend_added" -and $r.friend.nickname -eq "Alice") "Bob 收到被添加通知"

Write-Host "== 4. 在线互发消息 =="
$frame = '{"type":"chat","to":' + $idB + ',"text":"' + $msgHello + '"}'
Send-Frame $alice $frame
$r = Read-Frame $bob | ConvertFrom-Json
Assert ($r.type -eq "chat" -and $r.fromName -eq "Alice") "Bob 收到 Alice 的消息"
Assert ($r.text -eq $msgHello) "消息内容完整（含中文与标点）"

$frame = '{"type":"chat","to":' + $idA + ',"text":"' + $msgReply + '"}'
Send-Frame $bob $frame
$r = Read-Frame $alice | ConvertFrom-Json
Assert ($r.type -eq "chat" -and $r.text -eq $msgReply) "Alice 收到 Bob 的回复"

Write-Host "== 5. 离线消息 =="
$bob.Client.Close()
Start-Sleep -Milliseconds 800
Send-Frame $alice ('{"type":"chat","to":' + $idB + ',"text":"' + $msgOffline + '"}')
Start-Sleep -Milliseconds 500

$bob2 = New-ChatClient
Send-Frame $bob2 ('{"type":"login","account":' + $accB + ',"password":"pass1234"}')
$r = Read-Frame $bob2 | ConvertFrom-Json
Assert ($r.type -eq "login_ok") "Bob 重新登录成功"
Assert ($r.friends.Count -eq 1 -and $r.friends[0].nickname -eq "Alice") "好友列表含 Alice"
$offlineMsgs = @($r.messages | Where-Object { $_.text -eq $msgOffline })
Assert ($offlineMsgs.Count -eq 1) "离线消息随登录下发"

$r = Read-Frame $alice | ConvertFrom-Json
Assert ($r.type -eq "presence" -and $r.online -eq $false) "Alice 收到 Bob 离线通知"
$r = Read-Frame $alice | ConvertFrom-Json
Assert ($r.type -eq "presence" -and $r.online -eq $true) "Alice 收到 Bob 重新上线通知"

Write-Host "== 6. 心跳 =="
Send-Frame $alice '{"type":"ping"}'
$r = Read-Frame $alice | ConvertFrom-Json
Assert ($r.type -eq "pong") "ping/pong 正常"

$alice.Client.Close()
$bob2.Client.Close()

Write-Host ""
Write-Host ("结果: " + $script:pass + " 通过 / " + $script:fail + " 失败")
if ($script:fail -gt 0) { exit 1 } else { exit 0 }
