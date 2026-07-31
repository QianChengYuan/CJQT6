package cjqt6.multimedia

// ============================================================
// QSoundEffect - 音效播放
// ============================================================

foreign func qSoundEffectCreate(): Int64
foreign func qSoundEffectSetSource(ptr: Int64, url: CString): Unit
foreign func qSoundEffectSetSourceFile(ptr: Int64, filePath: CString): Unit
foreign func qSoundEffectSetVolume(ptr: Int64, volume: Float64): Unit
foreign func qSoundEffectVolume(ptr: Int64): Float64
foreign func qSoundEffectSetLoopCount(ptr: Int64, count: Int32): Unit
foreign func qSoundEffectLoopCount(ptr: Int64): Int32
foreign func qSoundEffectSetMuted(ptr: Int64, muted: Bool): Unit
foreign func qSoundEffectIsMuted(ptr: Int64): Bool
foreign func qSoundEffectIsPlaying(ptr: Int64): Bool
foreign func qSoundEffectPlay(ptr: Int64): Unit
foreign func qSoundEffectStop(ptr: Int64): Unit
foreign func qSoundEffectStatus(ptr: Int64): Int32
foreign func qSoundEffectDelete(ptr: Int64): Unit

/// 音效状态常量：无效/初始状态
public class SoundEffectStatus {
    /// 无效状态
    public static func Null(): Int32 { 0 }
    /// 正在加载音源
    public static func Loading(): Int32 { 1 }
    /// 加载完成，可播放
    public static func Ready(): Int32 { 2 }
    /// 加载出错
    public static func Error(): Int32 { 3 }
}

/// 音效播放器，适合播放短促的音效文件（低延迟，支持音量/循环/静音控制）
public class QSoundEffect {
    private var ptr: Int64 = 0

    /// 创建音效播放器
    public init() {
        unsafe { ptr = qSoundEffectCreate() }
    }

    /// 设置音源（URL 形式，如 qrc:/sounds/click.wav）
    public func setSource(url: String): Unit {
        unsafe {
            var cstr = LibC.mallocCString(url)
            qSoundEffectSetSource(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 设置音源（本地文件路径）
    public func setSourceFile(filePath: String): Unit {
        unsafe {
            var cstr = LibC.mallocCString(filePath)
            qSoundEffectSetSourceFile(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 设置音量（0.0 - 1.0）
    public func setVolume(volume: Float64): Unit {
        unsafe { qSoundEffectSetVolume(ptr, volume) }
    }

    /// 获取当前音量（0.0 - 1.0）
    public func volume(): Float64 {
        unsafe { qSoundEffectVolume(ptr) }
    }

    /// 设置循环次数（0 为无限循环）
    public func setLoopCount(count: Int32): Unit {
        unsafe { qSoundEffectSetLoopCount(ptr, count) }
    }

    /// 获取循环次数
    public func loopCount(): Int32 {
        unsafe { qSoundEffectLoopCount(ptr) }
    }

    /// 设置是否静音
    public func setMuted(muted: Bool): Unit {
        unsafe { qSoundEffectSetMuted(ptr, muted) }
    }

    /// 是否处于静音状态
    public func isMuted(): Bool {
        unsafe { qSoundEffectIsMuted(ptr) }
    }

    /// 是否正在播放
    public func isPlaying(): Bool {
        unsafe { qSoundEffectIsPlaying(ptr) }
    }

    /// 开始播放（按设定的循环次数）
    public func play(): Unit {
        unsafe { qSoundEffectPlay(ptr) }
    }

    /// 停止播放
    public func stop(): Unit {
        unsafe { qSoundEffectStop(ptr) }
    }

    /// 获取当前状态（SoundEffectStatus 常量）
    public func status(): Int32 {
        unsafe { qSoundEffectStatus(ptr) }
    }

    /// 释放底层资源
    public func delete(): Unit {
        if (ptr != 0) {
            unsafe { qSoundEffectDelete(ptr) }
            ptr = 0
        }
    }
}
