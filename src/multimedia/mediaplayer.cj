package CJQT6.multimedia

// QMediaPlayer - 媒体播放器
foreign func qMediaPlayerCreate(): Int64
foreign func qMediaPlayerSetSource(ptr: Int64, url: CString): Unit
foreign func qMediaPlayerSetSourceFile(ptr: Int64, filePath: CString): Unit
foreign func qMediaPlayerSetAudioOutput(ptr: Int64, outputPtr: Int64): Unit
foreign func qMediaPlayerPlay(ptr: Int64): Unit
foreign func qMediaPlayerPause(ptr: Int64): Unit
foreign func qMediaPlayerStop(ptr: Int64): Unit
foreign func qMediaPlayerSetPosition(ptr: Int64, position: Int64): Unit
foreign func qMediaPlayerPosition(ptr: Int64): Int64
foreign func qMediaPlayerDuration(ptr: Int64): Int64
foreign func qMediaPlayerSetVolume(ptr: Int64, volume: Float32): Unit
foreign func qMediaPlayerVolume(ptr: Int64): Float32
foreign func qMediaPlayerPlaybackState(ptr: Int64): Int32
foreign func qMediaPlayerSetLoops(ptr: Int64, loops: Int32): Unit
foreign func qMediaPlayerSetPlaybackRate(ptr: Int64, rate: Float32): Unit
foreign func qMediaPlayerPlaybackRate(ptr: Int64): Float32
foreign func qMediaPlayerMetaData(ptr: Int64, key: CString): CString
foreign func qMediaPlayerIsSeekable(ptr: Int64): Bool
foreign func qMediaPlayerHasAudio(ptr: Int64): Bool
foreign func qMediaPlayerMediaStatus(ptr: Int64): Int32
foreign func qMediaPlayerError(ptr: Int64): Int32
foreign func qMediaPlayerErrorString(ptr: Int64): CString
foreign func qMediaPlayerDelete(ptr: Int64): Unit

// QAudioOutput - 音频输出
foreign func qAudioOutputCreate(): Int64
foreign func qAudioOutputSetVolume(ptr: Int64, volume: Float32): Unit
foreign func qAudioOutputVolume(ptr: Int64): Float32
foreign func qAudioOutputSetMuted(ptr: Int64, muted: Bool): Unit
foreign func qAudioOutputIsMuted(ptr: Int64): Bool
foreign func qAudioOutputDelete(ptr: Int64): Unit

// 播放状态常量
public class PlaybackState {
    public static func stopped(): Int32 { 0 }
    public static func playing(): Int32 { 1 }
    public static func paused(): Int32 { 2 }
}

// 媒体状态常量
public class MediaStatus {
    public static func noMedia(): Int32 { 0 }
    public static func loading(): Int32 { 1 }
    public static func loaded(): Int32 { 2 }
    public static func buffering(): Int32 { 3 }
    public static func stalled(): Int32 { 4 }
    public static func buffered(): Int32 { 5 }
    public static func endOfMedia(): Int32 { 6 }
    public static func invalidMedia(): Int32 { 7 }
}

// 循环模式
public class Loops {
    public static func once(): Int32 { 1 }
    public static func infinite(): Int32 { -1 }
}

/// 音频输出设备
public class QAudioOutput {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe { ptr = qAudioOutputCreate() }
    }
    
    public func setVolume(volume: Float32): Unit {
        unsafe { qAudioOutputSetVolume(ptr, volume) }
    }
    
    public func volume(): Float32 {
        unsafe { qAudioOutputVolume(ptr) }
    }
    
    public func setMuted(muted: Bool): Unit {
        unsafe { qAudioOutputSetMuted(ptr, muted) }
    }
    
    public func isMuted(): Bool {
        unsafe { qAudioOutputIsMuted(ptr) }
    }
    
    public func getPtr(): Int64 { ptr }
    
    public func delete() {
        if (ptr != 0) {
            unsafe { qAudioOutputDelete(ptr) }
            ptr = 0
        }
    }
}

/// 媒体播放器
public class QMediaPlayer {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe { ptr = qMediaPlayerCreate() }
    }
    
    // 设置媒体源（URL）
    public func setSource(url: String): Unit {
        unsafe {
            var cstr = LibC.mallocCString(url)
            qMediaPlayerSetSource(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    // 设置本地文件作为媒体源
    public func setSourceFile(filePath: String): Unit {
        unsafe {
            var cstr = LibC.mallocCString(filePath)
            qMediaPlayerSetSourceFile(ptr, cstr)
            LibC.free(cstr)
        }
    }
    
    public func setAudioOutput(output: QAudioOutput): Unit {
        unsafe { qMediaPlayerSetAudioOutput(ptr, output.getPtr()) }
    }
    
    public func play(): Unit {
        unsafe { qMediaPlayerPlay(ptr) }
    }
    
    public func pause(): Unit {
        unsafe { qMediaPlayerPause(ptr) }
    }
    
    public func stop(): Unit {
        unsafe { qMediaPlayerStop(ptr) }
    }
    
    public func setPosition(position: Int64): Unit {
        unsafe { qMediaPlayerSetPosition(ptr, position) }
    }
    
    public func position(): Int64 {
        unsafe { qMediaPlayerPosition(ptr) }
    }
    
    public func duration(): Int64 {
        unsafe { qMediaPlayerDuration(ptr) }
    }
    
    public func setVolume(volume: Float32): Unit {
        unsafe { qMediaPlayerSetVolume(ptr, volume) }
    }
    
    public func volume(): Float32 {
        unsafe { qMediaPlayerVolume(ptr) }
    }
    
    public func playbackState(): Int32 {
        unsafe { qMediaPlayerPlaybackState(ptr) }
    }
    
    public func setLoops(loops: Int32): Unit {
        unsafe { qMediaPlayerSetLoops(ptr, loops) }
    }
    
    // 播放速度 (0.5 - 4.0)
    public func setPlaybackRate(rate: Float32): Unit {
        unsafe { qMediaPlayerSetPlaybackRate(ptr, rate) }
    }
    
    public func playbackRate(): Float32 {
        unsafe { qMediaPlayerPlaybackRate(ptr) }
    }
    
    // 媒体元数据
    public func metaData(key: String): String {
        unsafe {
            var cstr = LibC.mallocCString(key)
            let result = qMediaPlayerMetaData(ptr, cstr)
            LibC.free(cstr)
            return result.toString()
        }
    }
    
    public func title(): String { metaData("title") }
    public func artist(): String { metaData("artist") }
    public func album(): String { metaData("album") }
    
    public func isSeekable(): Bool {
        unsafe { qMediaPlayerIsSeekable(ptr) }
    }
    
    public func hasAudio(): Bool {
        unsafe { qMediaPlayerHasAudio(ptr) }
    }
    
    public func mediaStatus(): Int32 {
        unsafe { qMediaPlayerMediaStatus(ptr) }
    }
    
    public func error(): Int32 {
        unsafe { qMediaPlayerError(ptr) }
    }
    
    public func errorString(): String {
        unsafe { qMediaPlayerErrorString(ptr).toString() }
    }
    
    public func getPtr(): Int64 { ptr }
    
    public func delete() {
        if (ptr != 0) {
            unsafe { qMediaPlayerDelete(ptr) }
            ptr = 0
        }
    }
}
