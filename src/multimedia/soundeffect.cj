package cjqt6.multimedia

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

public class SoundEffectStatus {
    public static func Null(): Int32 { 0 }
    public static func Loading(): Int32 { 1 }
    public static func Ready(): Int32 { 2 }
    public static func Error(): Int32 { 3 }
}

public class QSoundEffect {
    private var ptr: Int64 = 0

    public init() {
        unsafe { ptr = qSoundEffectCreate() }
    }

    public func setSource(url: String): Unit {
        unsafe {
            var cstr = LibC.mallocCString(url)
            qSoundEffectSetSource(ptr, cstr)
            LibC.free(cstr)
        }
    }

    public func setSourceFile(filePath: String): Unit {
        unsafe {
            var cstr = LibC.mallocCString(filePath)
            qSoundEffectSetSourceFile(ptr, cstr)
            LibC.free(cstr)
        }
    }

    public func setVolume(volume: Float64): Unit {
        unsafe { qSoundEffectSetVolume(ptr, volume) }
    }

    public func volume(): Float64 {
        unsafe { qSoundEffectVolume(ptr) }
    }

    public func setLoopCount(count: Int32): Unit {
        unsafe { qSoundEffectSetLoopCount(ptr, count) }
    }

    public func loopCount(): Int32 {
        unsafe { qSoundEffectLoopCount(ptr) }
    }

    public func setMuted(muted: Bool): Unit {
        unsafe { qSoundEffectSetMuted(ptr, muted) }
    }

    public func isMuted(): Bool {
        unsafe { qSoundEffectIsMuted(ptr) }
    }

    public func isPlaying(): Bool {
        unsafe { qSoundEffectIsPlaying(ptr) }
    }

    public func play(): Unit {
        unsafe { qSoundEffectPlay(ptr) }
    }

    public func stop(): Unit {
        unsafe { qSoundEffectStop(ptr) }
    }

    public func status(): Int32 {
        unsafe { qSoundEffectStatus(ptr) }
    }

    public func delete(): Unit {
        if (ptr != 0) {
            unsafe { qSoundEffectDelete(ptr) }
            ptr = 0
        }
    }
}
