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

$gotUp = $false
for ($i = 0; $i -lt 6; $i++) {
    $r = Read-Frame $alice | ConvertFrom-Json
    $c1 = ($r.type -eq "presence")
    $c2 = ($r.userId -eq $idB)
    $c3 = ($r.online -eq $true)
    Write-Host ("DBG3 c1=$c1 c2=$c2 c3=$c3 and=" + ($c1 -and $c2 -and $c3))
    if ($c1 -and $c2 -and $c3) { $gotUp = $true; break }
}
Write-Host ("DBG4 gotUp=" + $gotUp)
Assert $gotUp "Alice 收到 Bob 上线通知"

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
$ackA = Read-Frame $alice | ConvertFrom-Json
Assert ($ackA.type -eq "chat_ack") "Alice 收到自己消息的 chat_ack"
$r = Read-Frame $bob | ConvertFrom-Json
Assert ($r.type -eq "chat" -and $r.fromName -eq "Alice") "Bob 收到 Alice 的消息"
Assert ($r.text -eq $msgHello) "消息内容完整（含中文与标点）"

$frame = '{"type":"chat","to":' + $idA + ',"text":"' + $msgReply + '"}'
Send-Frame $bob $frame
$ackB = Read-Frame $bob | ConvertFrom-Json
Assert ($ackB.type -eq "chat_ack") "Bob 收到自己消息的 chat_ack"
$r = Read-Frame $alice | ConvertFrom-Json
Assert ($r.type -eq "chat" -and $r.text -eq $msgReply) "Alice 收到 Bob 的回复"

Write-Host "== 5. 离线消息 =="
$bob.Client.Close()
Start-Sleep -Milliseconds 800
# Bob 断开后，服务端清理定时器（200ms 周期）会向在线好友广播 offline 通知，
# 该帧先于随后 chat_ack 到达 Alice，必须先读取，否则会被 chat_ack 循环吞掉。
$gotOffline = $false
for ($i = 0; $i -lt 3; $i++) {
    $f = Read-Frame $alice | ConvertFrom-Json
    if ($f.type -eq "presence" -and $f.online -eq $false) { $gotOffline = $true; break }
}
Assert $gotOffline "Alice 收到 Bob 离线通知"

Send-Frame $alice ('{"type":"chat","to":' + $idB + ',"text":"' + $msgOffline + '"}')
$gotAck = $false
for ($i = 0; $i -lt 6; $i++) {
    $f = Read-Frame $alice | ConvertFrom-Json
    if ($f.type -eq "chat_ack") { $gotAck = $true; break }
}
Assert $gotAck "Alice 收到离线消息的 chat_ack"
Start-Sleep -Milliseconds 500

$bob2 = New-ChatClient
Send-Frame $bob2 ('{"type":"login","account":' + $accB + ',"password":"pass1234"}')
$r = Read-Frame $bob2 | ConvertFrom-Json
Assert ($r.type -eq "login_ok") "Bob 重新登录成功"
Assert ($r.friends.Count -eq 1 -and $r.friends[0].nickname -eq "Alice") "好友列表含 Alice"
$offlineMsgs = @($r.messages | Where-Object { $_.text -eq $msgOffline })
Assert ($offlineMsgs.Count -eq 1) "离线消息随登录下发"

$gotOnline = $false
for ($i = 0; $i -lt 6; $i++) {
    $f = Read-Frame $alice | ConvertFrom-Json
    if ($f.type -eq "presence" -and $f.online -eq $true) { $gotOnline = $true; break }
}
Assert $gotOnline "Alice 收到 Bob 重新上线通知"

Write-Host "== 6. 心跳 =="
Send-Frame $alice '{"type":"ping"}'
$r = Read-Frame $alice | ConvertFrom-Json
Assert ($r.type -eq "pong") "ping/pong 正常"

Write-Host "== 7. 历史记录同步 =="
Send-Frame $alice ("{`"type`":`"history`",`"friend`":$idB,`"limit`":50}")
$r = Read-Frame $alice | ConvertFrom-Json
Assert ($r.type -eq "history" -and $r.friend -eq $idB) "Alice 收到 history 帧"
$histTexts = @($r.messages | ForEach-Object { $_.text })
Assert ($histTexts -contains $msgHello) "history 含之前的中文消息"

Write-Host "== 8. 消息撤回 =="
Send-Frame $alice ("{`"type`":`"chat`",`"to`":$idB,`"text`":`"这条稍后撤回`"}")
$chatToBob = Read-Frame $bob2 | ConvertFrom-Json
Assert ($chatToBob.type -eq "chat") "Bob 收到待撤回消息"
$ack = Read-Frame $alice | ConvertFrom-Json
Assert ($ack.type -eq "chat_ack") "Alice 收到 chat_ack"
$mid = $ack.id
Send-Frame $alice ("{`"type`":`"recall`",`"msgId`":$mid}")
$okRecall = Read-Frame $alice | ConvertFrom-Json
Assert ($okRecall.type -eq "ok" -and $okRecall.op -eq "recall") "Alice 撤回成功"
$recToBob = Read-Frame $bob2 | ConvertFrom-Json
Assert ($recToBob.type -eq "recall" -and $recToBob.msgId -eq $mid) "Bob 收到撤回通知"

Write-Host "== 9. 文件分块传输 =="
Send-Frame $alice ("{`"type`":`"file_begin`",`"to`":$idB,`"tid`":`"t1`",`"name`":`"hi.txt`",`"size`":5,`"kind`":`"file`"}")
$fb = Read-Frame $bob2 | ConvertFrom-Json
Assert ($fb.type -eq "file_begin" -and $fb.name -eq "hi.txt") "Bob 收到 file_begin"
Send-Frame $alice ("{`"type`":`"file_chunk`",`"to`":$idB,`"tid`":`"t1`",`"seq`":0,`"data`":`"aGVsbG8=`"}")
$fc = Read-Frame $bob2 | ConvertFrom-Json
Assert ($fc.type -eq "file_chunk" -and $fc.data -eq "aGVsbG8=") "Bob 收到 file_chunk"
Send-Frame $alice ("{`"type`":`"file_end`",`"to`":$idB,`"tid`":`"t1`"}")
$fe = Read-Frame $bob2 | ConvertFrom-Json
Assert ($fe.type -eq "file_end") "Bob 收到 file_end"

Write-Host "== 10. 改昵称（广播） =="
Send-Frame $alice '{"type":"change_nick","nickname":"AliceNew"}'
$okNick = Read-Frame $alice | ConvertFrom-Json
Assert ($okNick.type -eq "ok" -and $okNick.op -eq "change_nick") "Alice 改昵称成功"
$nc = Read-Frame $bob2 | ConvertFrom-Json
Assert ($nc.type -eq "nick_changed" -and $nc.nickname -eq "AliceNew") "Bob 收到昵称变更广播"

Write-Host "== 11. 设置备注 =="
Send-Frame $alice ("{`"type`":`"set_remark`",`"friend`":$idB,`"remark`":`"老铁`"}")
$okRm = Read-Frame $alice | ConvertFrom-Json
Assert ($okRm.type -eq "ok" -and $okRm.op -eq "set_remark") "Alice 设置备注成功"

Write-Host "== 12. 删除好友 =="
Send-Frame $alice ("{`"type`":`"del_friend`",`"friend`":$idB}")
$okDel = Read-Frame $alice | ConvertFrom-Json
Assert ($okDel.type -eq "ok" -and $okDel.op -eq "del_friend") "Alice 删除好友成功"
$fd = Read-Frame $bob2 | ConvertFrom-Json
Assert ($fd.type -eq "friend_deleted" -and $fd.userId -eq $idA) "Bob 收到被删通知"

$alice.Client.Close()
$bob2.Client.Close()

Write-Host ""
Write-Host ("结果: " + $script:pass + " 通过 / " + $script:fail + " 失败")
if ($script:fail -gt 0) { exit 1 } else { exit 0 }
