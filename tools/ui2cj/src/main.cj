// ============================================================
// main.cj — ui2cj 命令行入口
//
// 用法：
//   cjpm run -- form.ui                 # 生成到工程 src/main.cj 或 <base>_ui.cj
//   cjpm run -- form.ui out.cj          # 指定输出文件
//   cjpm run -- form.ui --package demo  # 首行生成 package 声明
//
// 自动行为（与 Python 脚手架 uic2cj.py 一致）：
//   - 从 .ui 所在目录向上查找最近的 cjpm.toml，读取 [package] name 作包名；
//   - 工程根有 src/ 目录时默认输出 src/main.cj，否则输出 <base>_ui.cj。
// ============================================================

package Ui2Cj

import std.collection.*
import std.fs.*

main(args: Array<String>) {
    if (args.size < 1) {
        println("用法: ui2cj <form.ui> [output.cj] [--package <name>]")
        println("      [--project-dir <dir>] [--output <file>]")
        println("将 Qt Designer 的 .ui 文件转换为 CJQT6 仓颉源码")
        println("默认行为：向上查找 cjpm.toml 自动填 package；有 src/ 目录则输出 src/main.cj")
        return
    }

    let uiPath = args[0]
    if (!exists(Path(uiPath))) {
        println("错误：文件不存在 - ${uiPath}")
        return
    }

    // 解析 --xxx 选项
    var outputPath = ""
    var pkgName = ""
    var projectDir = ""
    var positional = ArrayList<String>()
    var i: Int64 = 1
    while (i < args.size) {
        let a = args[i]
        if (a == "--package" && i + 1 < args.size) {
            pkgName = args[i + 1]
            i += 2
        } else if (a == "--project-dir" && i + 1 < args.size) {
            projectDir = args[i + 1]
            i += 2
        } else if (a == "--output" && i + 1 < args.size) {
            outputPath = args[i + 1]
            i += 2
        } else {
            positional.add(a)
            i += 1
        }
    }
    if (!positional.isEmpty() && outputPath.isEmpty()) {
        outputPath = positional[0]
    }

    // 自动探测 cjpm 工程：包名 + 默认输出
    // 同时向上寻找 CJQT6 库根（包名 cjqt6，用于无工程时生成可运行工程）
    let baseDir = if (projectDir.isEmpty()) { dirOf(uiPath) } else { projectDir }
    let (projDir, repoDir) = findProjectAndRepo(baseDir)
    let cjpmDir = projDir
    if (pkgName.isEmpty() && !cjpmDir.isEmpty()) {
        pkgName = readPackageName(cjpmDir)
        if (!pkgName.isEmpty()) {
            println("[探测] 从 cjpm.toml 读取包名: ${pkgName}")
        }
    }
    if (outputPath.isEmpty() && !cjpmDir.isEmpty()) {
        outputPath = defaultOutput(uiPath, cjpmDir)
    }

    // 无 cjpm 工程：自动生成最小可运行工程（cjpm.toml + src/main.cj）
    if (cjpmDir.isEmpty()) {
        if (pkgName.isEmpty()) {
            pkgName = sanitizePkg(fileStem(uiPath))
        }
        if (!repoDir.isEmpty()) {
            writeScaffoldProject(baseDir, repoDir, pkgName)
            outputPath = Path(baseDir).join("src").join("main.cj").toString()
            println("[引导] 未找到 cjpm.toml，已在 ${baseDir} 生成最小可运行工程：")
            println("       - cjpm.toml（依赖 ${repoDir}）")
            println("       - src/main.cj（${outputPath}）")
            println("       可执行: cd ${baseDir} && cjpm build && cjpm run")
        } else {
            if (outputPath.isEmpty()) {
                outputPath = defaultOutput(uiPath, baseDir)
            }
            println("[提示] 未找到 cjpm.toml，且无法定位 CJQT6 仓库，已输出独立文件：${outputPath}")
            println("       如需生成可运行工程，请用 --project-dir 指定工程目录，")
            println("       或将 .ui 放在 CJQT6 仓库内 examples/ 等目录再运行。")
        }
    }

    try {
        let code = generate(uiPath, outputPath, pkgName)
        println("[OK] 转换成功：${outputPath}")
        println("     共 ${lineCount(code)} 行仓颉代码")
        if (outputPath.endsWith("main.cj")) {
            println("提示: 输出到 src/main.cj，可执行 cjpm build 验证")
        }
    } catch (e: Exception) {
        println("[FAIL] 转换失败：${e.message}")
        return
    }
}

// ------------------------------------------------------------
// 路径 / cjpm 工程探测
// ------------------------------------------------------------
func dirOf(path: String): String {
    let p = Path(path).parent
    p.toString()
}

// 从 startDir 向上查找：
//   返回 (用户 cjpm 工程根, CJQT6 库根)。
//   遇到包名 cjqt6 的 cjpm.toml 视为"库自身工程"（不是用户工程），
//   记为库根并继续向上；遇到其他包名即视为用户工程并停止。
func findProjectAndRepo(startDir: String): (String, String) {
    var d = Path(startDir)
    var repo = ""
    while (true) {
        if (exists(d.join("cjpm.toml"))) {
            let name = readPackageName(d.toString())
            if (name == "cjqt6") {
                if (repo.isEmpty()) {
                    repo = d.toString()
                }
            } else {
                return (d.toString(), repo)
            }
        }
        let parent = d.parent
        if (parent.toString() == d.toString() || parent.toString().isEmpty()) {
            return ("", repo)
        }
        d = parent
    }
    return ("", repo)
}

// 取文件名去掉扩展名（不带目录）
func fileStem(path: String): String {
    let base = basename(path)
    let idx = base.lastIndexOf(".")
    if (let Some(i) <- idx) {
        return base[0..i]
    }
    base
}

// 把名字转成合法仓颉包名（仅字母/数字/下划线，且不以数字开头）
func sanitizePkg(name: String): String {
    var sb = StringBuilder()
    for (r in name.runes()) {
        if ((r >= r'a' && r <= r'z') || (r >= r'A' && r <= r'Z') ||
            (r >= r'0' && r <= r'9') || r == r'_') {
            sb.append(r)
        } else {
            sb.append(r'_')
        }
    }
    var out = sb.toString()
    if (out.isEmpty()) {
        return "myapp"
    }
    let first = Rune(out[0])
    if (first >= r'0' && first <= r'9') {
        out = "_" + out
    }
    out
}

// 从 cjpm.toml 的 [package] 段读取 name（简易行扫描）
// 需正确跳过行内注释：`name = "cjqt6"  # 模块名...`
func readPackageName(cjpmDir: String): String {
    try {
        let bytes = File.readFrom(Path(cjpmDir).join("cjpm.toml"))
        let text = String.fromUtf8(bytes)
        for (line in text.split("\n")) {
            let t = line.trimAscii()
            if (t.startsWith("#")) {
                continue
            }
            if (!t.contains("=")) {
                continue
            }
            let parts = t.split("=", 2)
            if (parts.size < 2) {
                continue
            }
            let key = parts[0].trimAscii()
            if (key != "name") {
                continue
            }
            var value = parts[1].trimAscii()
            // 去掉行内 # 注释
            let hIdx = value.indexOf("#")
            if (let Some(hi) <- hIdx) {
                value = value[0..hi].trimAscii()
            }
            return stripQuotes(value)
        }
    } catch (_) {
        return ""
    }
    return ""
}

// 去掉首尾的单双引号（简易 stripQuotes）
func stripQuotes(s: String): String {
    var out = s
    if (out.startsWith("\"") && out.endsWith("\"") && out.size >= 2) {
        out = out[1..out.size - 1]
    } else if (out.startsWith("\'") && out.endsWith("\'") && out.size >= 2) {
        out = out[1..out.size - 1]
    }
    out
}

// 默认输出：工程根有 src/ 目录则输出 src/main.cj，否则 <base>_ui.cj
func defaultOutput(uiPath: String, cjpmDir: String): String {
    if (isDir(Path(cjpmDir).join("src"))) {
        return Path(cjpmDir).join("src").join("main.cj").toString()
    }
    let p = Path(uiPath)
    let base = p.fileNameWithoutExtension
    if (!p.parent.toString().isEmpty()) {
        return p.parent.join("${base}_ui.cj").toString()
    }
    return "${base}_ui.cj"
}

func isDir(p: Path): Bool {
    try {
        let items = Directory.readFrom(p)
        _ = items.size
        return true
    } catch (_) {
        return false
    }
}

func lineCount(s: String): Int64 {
    if (s.isEmpty()) {
        return 0
    }
    var n: Int64 = 1
    for (c in s.runes()) {
        if (c == r'\n') {
            n++
        }
    }
    n
}

// ------------------------------------------------------------
// 无 cjpm 工程时的"最小可运行工程"引导
// ------------------------------------------------------------
// 在 projectDir 生成最小 cjpm.toml（依赖 CJQT6 库根）、src/ 目录、
// 以及 deploy_qt.ps1（部署 Qt 运行时/插件/MSVC 运行库，cjpm run 前置）。
func writeScaffoldProject(projectDir: String, repoDir: String, pkgName: String): Unit {
    // 创建 src/ 目录（生成 main.cj 需要）
    let srcDir = Path(projectDir).join("src")
    if (!exists(srcDir)) {
        Directory.create(srcDir, recursive: true)
    }

    // 计算 projectDir → repoDir 的相对路径（统一用 / 分隔，便于跨平台）
    let rel = relativePath(projectDir, repoDir)
    if (rel.isEmpty()) {
        println("[警告] 无法计算 ${projectDir} 到 ${repoDir} 的相对路径，cjpm.toml 依赖可能不正确")
    }

    let content = StringBuilder()
    content.append("[package]\n")
    content.append("  cjc-version = \"1.1.0\"\n")
    content.append("  name = \"${pkgName}\"\n")
    content.append("  version = \"0.1.0\"\n")
    content.append("  output-type = \"executable\"\n")
    content.append("  compile-option = \"\"\n")
    content.append("  link-option = \"-L${rel}/releases/windows-x64 -lcjqt6_bridge\"\n")
    content.append("\n")
    content.append("[dependencies]\n")
    content.append("  cjqt6 = { path = \"${rel}\" }\n")
    content.append("  cjqt6.print = { path = \"${rel}\" }\n")

    let cfg = Path(projectDir).join("cjpm.toml")
    File.writeTo(cfg, content.toString().toArray())

    // 生成 deploy_qt.ps1：部署 Qt 运行时 + 平台插件 + cjqt6 依赖 + bridge
    let deploy = StringBuilder()
    deploy.append("# ============================================================\n")
    deploy.append("# deploy_qt.ps1 —— CJQT6 运行时 DLL 部署脚本（由 ui2cj 生成）\n")
    deploy.append("# cjpm build/run 不会部署 Qt6 运行时/平台插件/MSVC 运行库，\n")
    deploy.append("# 缺这些会导致启动时报 DLL 找不到或 Qt 平台插件错误（无窗口）。\n")
    deploy.append("# 用法：在本目录执行  powershell -ExecutionPolicy Bypass -File deploy_qt.ps1\n")
    deploy.append("# 然后  cjpm run  即可正常显示窗口。\n")
    deploy.append("# ============================================================\n")
    deploy.append("\n")
    deploy.append("$ErrorActionPreference = \"Stop\"\n")
    deploy.append("\n")
    deploy.append("$ExampleRoot = Split-Path -Parent $MyInvocation.MyCommand.Path\n")
    deploy.append("$BinDir = Join-Path $ExampleRoot \"target/release/bin\"\n")
    deploy.append("if (-not (Test-Path $BinDir)) {\n")
    deploy.append("    Write-Host \"[!] 找不到 $BinDir — 请先 cjpm build\" -ForegroundColor Yellow\n")
    deploy.append("    exit 1\n")
    deploy.append("}\n")
    deploy.append("\n")
    deploy.append("$QtCandidates = @(\n")
    deploy.append("    \"C:\\Qt\\6.10.3\\msvc2022_64\",\n")
    deploy.append("    \"C:\\Qt\\6.10.2\\msvc2022_64\",\n")
    deploy.append("    \"C:\\Qt\\6.7.0\\msvc2022_64\"\n")
    deploy.append(")\n")
    deploy.append("$QtBin = $null\n")
    deploy.append("foreach ($q in $QtCandidates) {\n")
    deploy.append("    if (Test-Path (Join-Path $q \"bin\\Qt6Core.dll\")) { $QtBin = $q; break }\n")
    deploy.append("}\n")
    deploy.append("if (-not $QtBin) {\n")
    deploy.append("    Write-Host \"[!] 未找到 Qt6 msvc2022_64 安装，请修改脚本中的 $QtCandidates\" -ForegroundColor Yellow\n")
    deploy.append("    exit 1\n")
    deploy.append("}\n")
    deploy.append("Write-Host \"[*] 使用 Qt: $QtBin\"\n")
    deploy.append("\n")
    deploy.append("$QtDlls = Get-ChildItem (Join-Path $QtBin \"bin\") -Filter \"Qt6*.dll\"\n")
    deploy.append("foreach ($f in $QtDlls) { Copy-Item $f.FullName $BinDir -Force }\n")
    deploy.append("Write-Host (\"[+] 已拷贝 Qt6 运行时 DLL: \" + $QtDlls.Count)\n")
    deploy.append("\n")
    deploy.append("function Copy-Plugin($sub) {\n")
    deploy.append("    $src = Join-Path $QtBin \"plugins/$sub\"\n")
    deploy.append("    if (Test-Path $src) {\n")
    deploy.append("        $dst = Join-Path $BinDir $sub\n")
    deploy.append("        New-Item -ItemType Directory -Force -Path $dst | Out-Null\n")
    deploy.append("        foreach ($f in (Get-ChildItem $src -Filter \"*.dll\")) { Copy-Item $f.FullName $dst -Force }\n")
    deploy.append("        Write-Host (\"[+] 已拷贝插件 $sub : \" + (Get-ChildItem $dst -Filter '*.dll').Count)\n")
    deploy.append("    }\n")
    deploy.append("}\n")
    deploy.append("Copy-Plugin \"platforms\"\n")
    deploy.append("Copy-Plugin \"styles\"\n")
    deploy.append("Copy-Plugin \"imageformats\"\n")
    deploy.append("\n")
    deploy.append("$CrtDir = $null\n")
    deploy.append("$vsRoots = @(\n")
    deploy.append("    \"C:\\Program Files (x86)\\Microsoft Visual Studio\\2022\\BuildTools\",\n")
    deploy.append("    \"C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\",\n")
    deploy.append("    \"C:\\Program Files\\Microsoft Visual Studio\\2022\\Professional\",\n")
    deploy.append("    \"C:\\Program Files\\Microsoft Visual Studio\\2022\\Enterprise\"\n")
    deploy.append(")\n")
    deploy.append("foreach ($r in $vsRoots) {\n")
    deploy.append("    $d = Get-ChildItem -Path $r -Recurse -Filter \"msvcp140.dll\" -ErrorAction SilentlyContinue |\n")
    deploy.append("         Where-Object { $_.FullName -like \"*Microsoft.VC143.CRT*\" } |\n")
    deploy.append("         Select-Object -First 1\n")
    deploy.append("    if ($d) { $CrtDir = $d.DirectoryName; break }\n")
    deploy.append("}\n")
    deploy.append("if (-not $CrtDir) { Write-Host \"[!] 未找到 MSVC 运行库，将依赖系统 PATH\" -ForegroundColor Yellow }\n")
    deploy.append("if ($CrtDir) {\n")
    deploy.append("    $crtFiles = Get-ChildItem $CrtDir -Filter \"msvcp140*.dll\" -ErrorAction SilentlyContinue\n")
    deploy.append("    $crtFiles += Get-ChildItem $CrtDir -Filter \"vcruntime140*.dll\" -ErrorAction SilentlyContinue\n")
    deploy.append("    foreach ($f in $crtFiles) { Copy-Item $f.FullName $BinDir -Force }\n")
    deploy.append("    Write-Host (\"[+] 已拷贝 MSVC 运行库: \" + $crtFiles.Count)\n")
    deploy.append("}\n")
    deploy.append("\n")
    deploy.append("$Cjqt6DepDir = Join-Path $ExampleRoot \"target/release/cjqt6\"\n")
    deploy.append("if (Test-Path $Cjqt6DepDir) {\n")
    deploy.append("    $depFiles = Get-ChildItem $Cjqt6DepDir -Filter \"*.dll\" -ErrorAction SilentlyContinue\n")
    deploy.append("    foreach ($f in $depFiles) { Copy-Item $f.FullName $BinDir -Force }\n")
    deploy.append("    Write-Host (\"[+] 已拷贝 cjqt6 依赖 DLL: \" + $depFiles.Count)\n")
    deploy.append("}\n")
    deploy.append("\n")
    deploy.append("$BridgeSrc = Join-Path $ExampleRoot \"${rel}/releases/windows-x64/cjqt6_bridge.dll\"\n")
    deploy.append("if (Test-Path $BridgeSrc) {\n")
    deploy.append("    Copy-Item $BridgeSrc $BinDir -Force\n")
    deploy.append("    Write-Host \"[+] 已拷贝 cjqt6_bridge.dll\"\n")
    deploy.append("} else {\n")
    deploy.append("    Write-Host \"[!] 未找到 $BridgeSrc（请先重建 bridge）\" -ForegroundColor Yellow\n")
    deploy.append("}\n")
    deploy.append("\n")
    deploy.append("Write-Host (\"`n[OK] 部署完成，bin 目录 DLL 总数: \" + (Get-ChildItem $BinDir -Filter '*.dll').Count)\n")
    deploy.append("Write-Host \"[*] 现在可以运行: cjpm run\"\n")

    let deployPath = Path(projectDir).join("deploy_qt.ps1")
    // 前置 UTF-8 BOM（U+FEFF 编码为 EF BB BF）：Windows PowerShell 5.1 对
    // 无 BOM 的 UTF-8 按 ANSI 解析，中文多字节会错位吞掉行尾引号导致语法错误。
    let bomStr = "\u{FEFF}"
    File.writeTo(deployPath, (bomStr + deploy.toString()).toArray())
}

// 计算 from 目录到 to 目录的相对路径（绝对路径、/ 分隔、无尾部斜杠）
// 无法计算（不同盘符）时返回空串
func relativePath(from: String, to: String): String {
    let fa = normalizeSlashes(Path(from).toString())
    let ta = normalizeSlashes(Path(to).toString())
    let fParts = fa.split("/")
    let tParts = ta.split("/")
    // 找出公共前缀长度
    var common: Int64 = 0
    while (common < fParts.size && common < tParts.size && fParts[common] == tParts[common]) {
        common++
    }
    // 公共前缀为空（不同盘符）则无法相对
    if (common == 0) {
        return ""
    }
    var ups = ArrayList<String>()
    for (_ in common..fParts.size) {
        ups.add("..")
    }
    let upsStr = String.join(ups.toArray(), delimiter: "/")
    let downs = ArrayList<String>()
    for (i in common..tParts.size) {
        downs.add(tParts[i])
    }
    let downsStr = String.join(downs.toArray(), delimiter: "/")
    if (upsStr.isEmpty()) {
        if (downsStr.isEmpty()) {
            return "."
        }
        return downsStr
    }
    if (downsStr.isEmpty()) {
        return upsStr
    }
    return "${upsStr}/${downsStr}"
}

// 统一路径分隔符为 /，去掉末尾斜杠
func normalizeSlashes(p: String): String {
    var out = p.replace("\\", "/")
    while (out.endsWith("/") && out.size > 1) {
        out = out[0..out.size - 1]
    }
    out
}
