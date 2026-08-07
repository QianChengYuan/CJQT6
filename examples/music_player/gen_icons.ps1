# ============================================================
# gen_icons.ps1 — 生成 music_player 现代风格图标（白色单色，透明背景）
# 用法: pwsh gen_icons.ps1
# 输出: <示例目录>/icons/*.png
# ============================================================
Add-Type -AssemblyName System.Drawing

$iconsDir = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "icons"
New-Item -ItemType Directory -Force -Path $iconsDir | Out-Null

# 白色（主题色，适配深色 UI）
$White = [System.Drawing.Color]::FromArgb(255, 255, 255, 255)
# 辅助灰（用于次要元素，如喇叭的声波）
$Gray  = [System.Drawing.Color]::FromArgb(220, 200, 205, 215)

function New-Canvas($size) {
    $bmp = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)
    return @($bmp, $g)
}

function Save-And-Dispose($ctx, $name, $size) {
    $bmp = $ctx[0]; $g = $ctx[1]
    $bmp.Save((Join-Path $iconsDir "$name.png"), [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose(); $bmp.Dispose()
    Write-Host "[+] $name.png"
}

# 通用：填充多边形
function Add-Poly($g, $points, $color, $fill) {
    $pts = @($points | ForEach-Object { New-Object System.Drawing.PointF($_[0], $_[1]) })
    $brush = New-Object System.Drawing.SolidBrush($color)
    if ($fill) { $g.FillPolygon($brush, $pts) } else {
        $pen = New-Object System.Drawing.Pen($color, 3.5); $pen.LineJoin = 'Round'
        $g.DrawPolygon($pen, $pts); $pen.Dispose()
    }
    $brush.Dispose()
}
function Add-Rect($g, $x, $y, $w, $h, $color, $fill, $radius) {
    $brush = New-Object System.Drawing.SolidBrush($color)
    if ($radius -le 0) {
        if ($fill) { $g.FillRectangle($brush, $x, $y, $w, $h) }
        else { $pen = New-Object System.Drawing.Pen($color, 3.5); $g.DrawRectangle($pen, $x, $y, $w, $h); $pen.Dispose() }
    } else {
        $path = New-Object System.Drawing.Drawing2D.GraphicsPath
        $d = $radius * 2
        $path.AddArc($x, $y, $d, $d, 180, 90)
        $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
        $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
        $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
        $path.CloseFigure()
        if ($fill) { $g.FillPath($brush, $path) }
        else { $pen = New-Object System.Drawing.Pen($color, 3.5); $g.DrawPath($pen, $path); $pen.Dispose() }
        $path.Dispose()
    }
    $brush.Dispose()
}
function Add-Line($g, $x1, $y1, $x2, $y2, $color, $width) {
    $pen = New-Object System.Drawing.Pen($color, $width)
    $pen.StartCap = 'Round'; $pen.EndCap = 'Round'
    $g.DrawLine($pen, $x1, $y1, $x2, $y2)
    $pen.Dispose()
}
function Add-Fan($g, $cx, $cy, $r, $a1, $a2, $color, $width) {
    $pen = New-Object System.Drawing.Pen($color, $width)
    $pen.StartCap = 'Round'; $pen.EndCap = 'Round'
    $g.DrawArc($pen, $cx - $r, $cy - $r, $r * 2, $r * 2, $a1, $a2)
    $pen.Dispose()
}

$S = 96   # 画布 96px（显示时缩小到 24-28px，保证清晰）

# ---- play: 右三角 ----
$ctx = New-Canvas $S
$g = $ctx[1]
Add-Poly $g @((38,24),(38,72),(80,48)) $White $true
Save-And-Dispose $ctx "play" $S

# ---- pause: 双竖条 ----
$ctx = New-Canvas $S
$g = $ctx[1]
Add-Rect $g 30 22 14 52 $White $true 4
Add-Rect $g 52 22 14 52 $White $true 4
Save-And-Dispose $ctx "pause" $S

# ---- stop: 圆角方块 ----
$ctx = New-Canvas $S
$g = $ctx[1]
Add-Rect $g 26 26 44 44 $White $true 8
Save-And-Dispose $ctx "stop" $S

# ---- prev: 左条 + 左三角（跳过上一曲） ----
$ctx = New-Canvas $S
$g = $ctx[1]
Add-Rect $g 24 26 8 44 $White $true 3
Add-Poly $g @((76,26),(76,70),(38,48)) $White $true
Save-And-Dispose $ctx "prev" $S

# ---- next: 右条 + 右三角（跳过下一曲） ----
$ctx = New-Canvas $S
$g = $ctx[1]
Add-Rect $g 64 26 8 44 $White $true 3
Add-Poly $g @((20,26),(20,70),(58,48)) $White $true
Save-And-Dispose $ctx "next" $S

# ---- mute: 喇叭 + 叉 ----
$ctx = New-Canvas $S
$g = $ctx[1]
Add-Poly $g @((24,38),(24,58),(40,58),(56,72),(56,24),(40,38)) $White $true
Add-Line $g 64 36 84 60 $White 6
Add-Line $g 84 36 64 60 $White 6
Save-And-Dispose $ctx "mute" $S

# ---- volume: 喇叭 + 声波 ----
$ctx = New-Canvas $S
$g = $ctx[1]
Add-Poly $g @((24,38),(24,58),(40,58),(56,72),(56,24),(40,38)) $White $true
Add-Fan $g 64 48 16 -55 55 $Gray 5
Add-Fan $g 68 48 26 -50 50 $Gray 5
Save-And-Dispose $ctx "volume" $S

# ---- add: 加号 ----
$ctx = New-Canvas $S
$g = $ctx[1]
Add-Line $g 48 24 48 72 $White 10
Add-Line $g 24 48 72 48 $White 10
Save-And-Dispose $ctx "add" $S

# ---- remove: 减号 ----
$ctx = New-Canvas $S
$g = $ctx[1]
Add-Line $g 24 48 72 48 $White 10
Save-And-Dispose $ctx "remove" $S

# ---- clear: 垃圾桶 ----
$ctx = New-Canvas $S
$g = $ctx[1]
Add-Rect $g 34 20 28 6 $White $true 2   # 盖子
Add-Rect $g 30 30 36 44 $White $true 6  # 桶身
Add-Rect $g 30 26 6 50 $White $true 3   # 左提手
Add-Rect $g 60 26 6 50 $White $true 3   # 右提手
Add-Rect $g 42 38 12 6 $White $true 2
Add-Rect $g 42 50 12 6 $White $true 2
Add-Rect $g 26 52 44 6 $White $true 3
Save-And-Dispose $ctx "clear" $S

# ---- folder: 文件夹 ----
$ctx = New-Canvas $S
$g = $ctx[1]
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$path.AddArc(22, 36, 12, 12, 180, 90)
$path.AddLine(28, 36, 44, 36)
$path.AddArc(44, 36, 12, 12, 180, 90)
$path.AddLine(50, 36, 74, 36)
$path.AddLine(74, 66, 22, 66)
$path.CloseFigure()
$brush = New-Object System.Drawing.SolidBrush($White)
$g.FillPath($brush, $path)
$brush.Dispose(); $path.Dispose()
Add-Rect $g 26 28 24 12 $White $true 6
Save-And-Dispose $ctx "folder" $S

# ---- speed: 速度计 ----
$ctx = New-Canvas $S
$g = $ctx[1]
Add-Fan $g 48 54 30 130 230 $White 7
Add-Fan $g 48 54 18 130 230 $Gray 5
Add-Line $g 48 54 48 32 $White 6
Add-Line $g 48 54 62 44 $White 6
Add-Rect $g 43 22 10 10 $White $true 5
Save-And-Dispose $ctx "speed" $S

# ---- loop: 循环（重复） ----
$ctx = New-Canvas $S
$g = $ctx[1]
$pen = New-Object System.Drawing.Pen($White, 7)
$pen.StartCap = 'Round'; $pen.EndCap = 'Round'
$g.DrawArc($pen, 22, 28, 52, 40, 210, 300)
$pen.Dispose()
Add-Poly $g @((70,20),(78,40),(58,38)) $White $true
Save-And-Dispose $ctx "loop" $S

# ---- shuffle: 随机 ----
$ctx = New-Canvas $S
$g = $ctx[1]
Add-Line $g 22 28 40 40 $White 6
Add-Line $g 40 40 58 52 $Gray 5
Add-Line $g 62 24 74 24 $Gray 5
Add-Line $g 22 68 40 56 $White 6
Add-Line $g 40 56 58 44 $Gray 5
Add-Line $g 62 72 74 72 $Gray 5
Add-Line $g 62 24 74 24 $Gray 5
Add-Rect $g 74 19 10 10 $White $true 5
Add-Rect $g 74 67 10 10 $White $true 5
Add-Rect $g 16 23 10 10 $White $true 5
Add-Rect $g 16 63 10 10 $White $true 5
Save-And-Dispose $ctx "shuffle" $S

Write-Host "`n[OK] 图标生成完成: $(Get-ChildItem $iconsDir -Filter '*.png').Count 个"
