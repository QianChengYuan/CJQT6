package cjqt6.multimedia

import cjqt6.core.*

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
public class QSoundEffect <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    /// 创建音效播放器
    /// throws: CreateFailedException 底层 Qt 对象创建失败时抛出
    public init() {
        unsafe {
            ptr = qSoundEffectCreate()
            if (ptr == 0) {
                throw CreateFailedException("QSoundEffect 创建失败")
            }
        }
        trackObject(ptr)
    }

    /// 设置音源（URL 形式，如 qrc:/sounds/click.wav）
    public func setSource(url: String): Unit {
        checkValid()
        unsafe {
            var cstr = LibC.mallocCString(url)
            qSoundEffectSetSource(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 设置音源（本地文件路径）
    public func setSourceFile(filePath: String): Unit {
        checkValid()
        unsafe {
            var cstr = LibC.mallocCString(filePath)
            qSoundEffectSetSourceFile(ptr, cstr)
            LibC.free(cstr)
        }
    }

    /// 设置音量（0.0 - 1.0）
    public func setVolume(volume: Float64): Unit {
        checkValid()
        unsafe { qSoundEffectSetVolume(ptr, volume) }
    }

    /// 获取当前音量（0.0 - 1.0）
    public func volume(): Float64 {
        checkValid()
        unsafe { qSoundEffectVolume(ptr) }
    }

    /// 设置循环次数（0 为无限循环）
    public func setLoopCount(count: Int32): Unit {
        checkValid()
        unsafe { qSoundEffectSetLoopCount(ptr, count) }
    }

    /// 获取循环次数
    public func loopCount(): Int32 {
        checkValid()
        unsafe { qSoundEffectLoopCount(ptr) }
    }

    /// 设置是否静音
    public func setMuted(muted: Bool): Unit {
        checkValid()
        unsafe { qSoundEffectSetMuted(ptr, muted) }
    }

    /// 是否处于静音状态
    public func isMuted(): Bool {
        checkValid()
        unsafe { qSoundEffectIsMuted(ptr) }
    }

    /// 是否正在播放
    public func isPlaying(): Bool {
        checkValid()
        unsafe { qSoundEffectIsPlaying(ptr) }
    }

    /// 开始播放（按设定的循环次数）
    public func play(): Unit {
        checkValid()
        unsafe { qSoundEffectPlay(ptr) }
    }

    /// 停止播放
    public func stop(): Unit {
        checkValid()
        unsafe { qSoundEffectStop(ptr) }
    }

    /// 获取当前状态（SoundEffectStatus 常量）
    public func status(): Int32 {
        checkValid()
        unsafe { qSoundEffectStatus(ptr) }
    }

    /// 获取原生指针
    public func getPtr(): Int64 { ptr }

    /// 是否已关闭（资源已释放）
    public func isClosed(): Bool { closed }

    /// 检查对象有效性（未关闭且指针有效）
    public func isValid(): Bool {
        return !closed && ptr != 0 && isObjectAlive(ptr)
    }

    /// 检查有效性，无效时抛出异常
    /// throws: ResourceDisposedException 对象已释放或底层 Qt 对象失效时抛出
    /// throws: NullPointerException 空指针访问时抛出
    public func checkValid(): Unit {
        if (closed) {
            throw ResourceDisposedException("QSoundEffect 已经被释放")
        }
        if (ptr == 0) {
            throw NullPointerException("QSoundEffect 指针为空")
        }
        if (!isObjectAlive(ptr)) {
            throw ResourceDisposedException("QSoundEffect 底层 Qt 对象已失效")
        }
    }

    /// 关闭资源，释放Qt对象（幂等）
    public func close(): Unit {
        if (!closed && ptr != 0) {
            if (!isObjectAlive(ptr)) {
                untrackObject(ptr)
                ptr = 0
                closed = true
                return
            }
            untrackObject(ptr)
            unsafe { qSoundEffectDelete(ptr) }
            closed = true
            ptr = 0
        }
    }

    /// 删除音效播放器（兼容旧 API，等同 close()）
    public func delete(): Unit {
        close()
    }
}
