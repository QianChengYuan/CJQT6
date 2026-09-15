// ============================================================
// 歌词匹配 L1~L5 分级匹配 + 打分 + 目录缓存
// 设计文档 2.3 节
// ============================================================
package CjMusic

import std.collection.*
import std.fs.*

// ============================================================
// 目录 .lrc 列表缓存（文档 2.3.3 节）
// ============================================================
var gLyricDirCache: HashMap<String, Array<String>> = HashMap<String, Array<String>>()

/// 列出指定目录下的 .lrc 文件名（带缓存）
public func listLrcFiles(dirPath: String): Array<String> {
    match (gLyricDirCache.get(dirPath)) {
        case Some(list) => list
        case None =>
            let list = ArrayList<String>()
            try {
                let entries = Directory.readFrom(Path(dirPath))
                for (entry in entries) {
                    if (entry.name.toAsciiLower().endsWith(".lrc")) {
                        list.add(entry.name)
                    }
                }
            } catch (e: Exception) {
                // 目录读取失败
            }
            let arr = Array<String>(list.size, {i => list[i]})
            gLyricDirCache[dirPath] = arr
            arr
    }
}


// ============================================================
// 质量标签清洗（文档 2.3.1 节，lrc4cj 不处理这些）
// ============================================================

/// 剥离质量标签前缀/后缀：[HQ] / [SQ] / [320K] / [FLAC] 等
public func stripQualityTags(name: String): String {
    var result = name
    // 循环剥离开头的 [xxx] 标签
    while (result.startsWith("[")) {
        match (result.indexOf("]")) {
            case Some(closeIdx) =>
                let tag = result[1..closeIdx].toAsciiUpper()
                if (isQualityTag(tag)) {
                    result = result[(closeIdx + 1)..result.size].trimAscii()
                } else {
                    break  // 非质量标签，停止
                }
            case None => break
        }
    }
    // 循环剥离结尾的 [xxx] 标签
    while (result.endsWith("]")) {
        match (result.lastIndexOf("[")) {
            case Some(openIdx) =>
                let tag = result[(openIdx + 1)..(result.size - 1)].toAsciiUpper()
                if (isQualityTag(tag)) {
                    result = result[0..openIdx].trimAscii()
                } else {
                    break
                }
            case None => break
        }
    }
    result
}

/// 判断标签是否为质量标签
func isQualityTag(tag: String): Bool {
    let qualityTags = ["HQ", "SQ", "HD", "LOSSLESS", "FLAC", "320K", "320KBPS",
        "192K", "128K", "CD", "母带", "无损"]
    for (qt in qualityTags) {
        if (tag == qt) {
            return true
        }
    }
    // 以 K 结尾的码率标签
    if (tag.endsWith("K") && tag.size > 1) {
        let prefix = tag[0..(tag.size - 1)]
        var allDigit = true
        for (r in prefix.runes()) {
            if (r < r'0' || r > r'9') {
                allDigit = false
                break
            }
        }
        if (allDigit) {
            return true
        }
    }
    false
}

// ============================================================
// 归一化（文档 2.3.2 节 L2：大小写/空格/全角半角）
// ============================================================

/// 归一化文件名用于匹配：小写 + 去多余空格 + 全角转半角
public func normalizeName(name: String): String {
    var result = name.toAsciiLower()
    // 全角空格 → 半角空格
    result = result.replace("\u{3000}", " ")
    // 去多余空格
    while (result.contains("  ")) {
        result = result.replace("  ", " ")
    }
    result = result.trimAscii()
    result
}

/// 剥离歌手前缀（文档 2.3.2 节 L4）
/// "凤凰传奇 - 海底" → "海底"
public func stripArtistPrefix(name: String): String {
    let separators = [" - ", "–", "—", "－", "-"]
    for (sep in separators) {
        if (name.contains(sep)) {
            match (name.indexOf(sep)) {
                case Some(idx) =>
                    let right = name[(idx + sep.size)..name.size].trimAscii()
                    if (!right.isEmpty()) {
                        return right
                    }
                case None => ()
            }
        }
    }
    name
}

// ============================================================
// 路径辅助
// ============================================================

/// 获取文件所在目录
public func getDirectory(path: String): String {
    let p = Path(path)
    p.parent.toString()
}

/// 替换扩展名
public func replaceExtension(path: String, newExt: String): String {
    let p = Path(path)
    let dir = p.parent.toString()
    let stem = p.fileNameWithoutExtension
    if (dir.isEmpty() || dir == ".") {
        "${stem}.${newExt}"
    } else {
        joinPath(dir, "${stem}.${newExt}")
    }
}

/// 获取文件名（不含扩展名）
public func getFileNameStem(path: String): String {
    let p = Path(path)
    p.fileNameWithoutExtension
}

// ============================================================
// L1~L4 匹配（O(1)，不扫描目录）
// ============================================================

/// L1：同名替换扩展名
/// 返回匹配的 .lrc 路径，不存在返回 None
public func matchL1(audioPath: String): ?String {
    let lrcPath = replaceExtension(audioPath, "lrc")
    if (exists(Path(lrcPath))) {
        return Some(lrcPath)
    }
    None
}

/// L2：归一化匹配（同目录下，归一化后同名）
public func matchL2(audioPath: String): ?String {
    let dir = getDirectory(audioPath)
    if (dir.isEmpty()) {
        return None
    }
    let audioStem = normalizeName(getFileNameStem(audioPath))
    let lrcFiles = listLrcFiles(dir)
    for (lrcName in lrcFiles) {
        let lrcStem = normalizeName(lrcName.removeSuffix(".lrc"))
        if (audioStem == lrcStem) {
            return Some(joinPath(dir, lrcName))
        }
    }
    None
}

/// L3：剥离质量标签后匹配
public func matchL3(audioPath: String): ?String {
    let dir = getDirectory(audioPath)
    if (dir.isEmpty()) {
        return None
    }
    let audioStem = normalizeName(stripQualityTags(getFileNameStem(audioPath)))
    if (audioStem.isEmpty()) {
        return None
    }
    let lrcFiles = listLrcFiles(dir)
    for (lrcName in lrcFiles) {
        let lrcStem = normalizeName(stripQualityTags(lrcName.removeSuffix(".lrc")))
        if (audioStem == lrcStem) {
            return Some(joinPath(dir, lrcName))
        }
    }
    None
}

/// L4：剥离歌手前缀后匹配
public func matchL4(audioPath: String): ?String {
    let dir = getDirectory(audioPath)
    if (dir.isEmpty()) {
        return None
    }
    let audioStem = normalizeName(stripArtistPrefix(stripQualityTags(getFileNameStem(audioPath))))
    if (audioStem.isEmpty()) {
        return None
    }
    let lrcFiles = listLrcFiles(dir)
    for (lrcName in lrcFiles) {
        let lrcStem = normalizeName(stripArtistPrefix(stripQualityTags(lrcName.removeSuffix(".lrc"))))
        if (audioStem == lrcStem) {
            return Some(joinPath(dir, lrcName))
        }
    }
    None
}

// ============================================================
// L5 打分（文档 2.3.4 节）
// ============================================================

/// 计算两个归一化名字的匹配分数
/// 返回 0~100 的分数
public func scoreMatch(audioStem: String, lrcStem: String): Int32 {
    if (audioStem == lrcStem) {
        return 100   // 精确同名
    }
    let normAudio = normalizeName(audioStem)
    let normLrc = normalizeName(lrcStem)
    if (normAudio == normLrc) {
        return 90    // 归一化后相同
    }
    let strippedAudio = normalizeName(stripQualityTags(stripArtistPrefix(audioStem)))
    let strippedLrc = normalizeName(stripQualityTags(stripArtistPrefix(lrcStem)))
    if (!strippedAudio.isEmpty() && strippedAudio == strippedLrc) {
        return 80    // 剥离装饰后相同
    }
    // 包含关系
    if (!normAudio.isEmpty() && !normLrc.isEmpty()) {
        if (normAudio.contains(normLrc) || normLrc.contains(normAudio)) {
            return 60
        }
    }
    // 简化：不实现编辑距离，返回 0
    0
}

/// L5：目录内模糊打分
/// 返回 (最佳匹配路径, 分数)，无匹配返回 None
public func matchL5(audioPath: String): ?(String, Int32) {
    let dir = getDirectory(audioPath)
    if (dir.isEmpty()) {
        return None
    }
    let audioStem = getFileNameStem(audioPath)
    let lrcFiles = listLrcFiles(dir)
    if (lrcFiles.size == 0) {
        return None
    }
    var bestPath = ""
    var bestScore: Int32 = 0
    for (lrcName in lrcFiles) {
        let lrcStem = lrcName.removeSuffix(".lrc")
        let score = scoreMatch(audioStem, lrcStem)
        if (score > bestScore) {
            bestScore = score
            bestPath = joinPath(dir, lrcName)
        } else if (score == bestScore && score > 0 && !bestPath.isEmpty()) {
            // 同分取更短的（文档 2.3.4 节）
            let currentLen = lrcName.size
            let bestLen = Path(bestPath).fileName.size
            if (currentLen < bestLen) {
                bestPath = joinPath(dir, lrcName)
            }
        }
    }
    if (bestScore > 0) {
        return Some((bestPath, bestScore))
    }
    None
}

// ============================================================
// 分级匹配入口（L1 → L2 → L3 → L4 → L5）
// ============================================================

/// 匹配结果
public struct LyricMatchResult {
    public let path: String
    public let level: Int32      // 命中级别 1~5
    public let score: Int32      // 分数（L5 有意义）

    public init(path: String, level: Int32, score: Int32) {
        this.path = path
        this.level = level
        this.score = score
    }
}

/// 分级匹配：L1 → L2 → L3 → L4 → L5
/// 返回匹配结果，无匹配返回 None
public func matchLyrics(audioPath: String): ?LyricMatchResult {
    // L1：同名替换
    match (matchL1(audioPath)) {
        case Some(p) => return Some(LyricMatchResult(p, 1, 100))
        case None => ()
    }
    // L2：归一化
    match (matchL2(audioPath)) {
        case Some(p) => return Some(LyricMatchResult(p, 2, 90))
        case None => ()
    }
    // L3：剥离质量标签
    match (matchL3(audioPath)) {
        case Some(p) => return Some(LyricMatchResult(p, 3, 80))
        case None => ()
    }
    // L4：剥离歌手前缀
    match (matchL4(audioPath)) {
        case Some(p) => return Some(LyricMatchResult(p, 4, 80))
        case None => ()
    }
    // L5：目录模糊打分
    match (matchL5(audioPath)) {
        case Some((p, score)) => return Some(LyricMatchResult(p, 5, score))
        case None => ()
    }
    None
}

// ============================================================
// 用户手动指定歌词缓存（文档 2.3.5 节第 3 点）
// ============================================================
var gManualLyricMap: HashMap<String, String> = HashMap<String, String>()


/// 查询用户手动指定的歌词
public func getManualLyric(audioPath: String): ?String {
    gManualLyricMap.get(audioPath)
}