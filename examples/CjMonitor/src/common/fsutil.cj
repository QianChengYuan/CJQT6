package CjMonitor.common

import std.fs.*

// ============================================================
// 文件写入工具
//
// 用途：把自测/巡检结果落盘。控制台输出在部分启动方式下不可见
// （例如 cjpm run 会分离启动子进程，stdout 不回流），因此关键结果必须落盘。
// CJQT6 未封装 QFile，统一用 std.fs。
// ============================================================

/// 写入文本文件（UTF-8，覆盖）。成功返回 true。
public func writeTextFile(path: String, content: String): Bool {
    try {
        File.writeTo(Path(path), content.toArray())
        true
    } catch (_: Exception) {
        false
    }
}

/// 追加写文本文件（UTF-8，不存在则创建）。成功返回 true。
///
/// 用途：启动期跟踪。GUI 进程的 stdout 通常不可见（且崩溃时无输出），
/// 逐点追加写文件是定位启动期崩溃最可靠的手段。
public func appendTextFile(path: String, content: String): Bool {
    try {
        let f = File(Path(path), Append)
        f.write(content.toArray())
        f.close()
        true
    } catch (_: Exception) {
        false
    }
}

/// 读取文本文件（UTF-8）。失败返回 None。
public func readTextFileOrNone(path: String): Option<String> {
    try {
        Some(String.fromUtf8(File.readFrom(Path(path))))
    } catch (_: Exception) {
        None
    }
}
