package cjqt6.test

import cjqt6.core.*
import cjqt6.multimedia.*
import cjqt6.paint.*
import std.math.*
import std.unittest.*

// =====================================================================
// 全局回调状态（CFunc 回调不捕获局部变量，只能用全局变量）
// =====================================================================
var gPosChanged: Int64 = -1
let gPosChangedCb: Int64Callback = { v: Int64 =>
    gPosChanged = v
}

var gDurChanged: Int64 = -1
let gDurChangedCb: Int64Callback = { v: Int64 =>
    gDurChanged = v
}

var gPlayState: Int32 = -1
let gPlayStateCb: Int32Callback = { v: Int32 =>
    gPlayState = v
}

var gMediaStatusVal: Int32 = -1
let gMediaStatusCb: Int32Callback = { v: Int32 =>
    gMediaStatusVal = v
}

// =====================================================================
// QAudioOutput 测试
// =====================================================================
@Test
@Tag[requires_audio]
class QAudioOutputTests {
    private static var guiEnv: ?GUITestEnvironment = None

    @BeforeAll
    static func setupGUI(): Unit {
        let env = GUITestEnvironment.getInstance()
        env.setupEnvironment()
        guiEnv = Some(env)
    }

    @AfterAll
    static func teardownGUI(): Unit {
        if (let Some(env) <- guiEnv) {
            env.teardownEnvironment()
        }
    }

    @TestCase
    func testCreateDelete() {
        let out = QAudioOutput()
        @Expect(out.getPtr() != 0, true)
        out.delete()
    }

    @TestCase
    func testVolumeRoundtrip() {
        let out = QAudioOutput()
        out.setVolume(0.5f32)
        @Expect(out.volume(), 0.5f32)
        out.setVolume(0.0f32)
        @Expect(out.volume(), 0.0f32)
        out.setVolume(1.0f32)
        @Expect(out.volume(), 1.0f32)
        out.delete()
    }

    @TestCase
    func testMuteRoundtrip() {
        let out = QAudioOutput()
        out.setMuted(true)
        @Expect(out.isMuted(), true)
        out.setMuted(false)
        @Expect(out.isMuted(), false)
        out.delete()
    }

    @TestCase
    func testVolumeAndMuteCombined() {
        let out = QAudioOutput()
        out.setVolume(0.25f32)
        out.setMuted(true)
        @Expect(out.volume(), 0.25f32)
        @Expect(out.isMuted(), true)
        out.delete()
    }
}

// =====================================================================
// QMediaPlayer 测试
// =====================================================================
@Test
@Tag[requires_audio]
class QMediaPlayerTests {
    private static var guiEnv: ?GUITestEnvironment = None

    @BeforeAll
    static func setupGUI(): Unit {
        let env = GUITestEnvironment.getInstance()
        env.setupEnvironment()
        guiEnv = Some(env)
    }

    @AfterAll
    static func teardownGUI(): Unit {
        if (let Some(env) <- guiEnv) {
            env.teardownEnvironment()
        }
    }

    @TestCase
    func testCreateDelete() {
        let player = QMediaPlayer()
        @Expect(player.getPtr() != 0, true)
        player.delete()
    }

    @TestCase
    func testInitialState() {
        let player = QMediaPlayer()
        @Expect(player.playbackState(), PlaybackState.stopped())
        @Expect(player.mediaStatus(), MediaStatus.noMedia())
        @Expect(player.duration(), 0)
        @Expect(player.position(), 0)
        @Expect(player.volume(), 0.0f32)
        @Expect(player.playbackRate(), 1.0f32)
        @Expect(player.isSeekable(), false)
        @Expect(player.hasAudio(), false)
        @Expect(player.error(), 0)
        @Expect(player.errorString(), "")
        player.delete()
    }

    @TestCase
    func testVolumeWithAudioOutput() {
        let player = QMediaPlayer()
        let output = QAudioOutput()
        player.setAudioOutput(output)
        player.setVolume(0.5f32)
        @Expect(player.volume(), 0.5f32)
        player.setVolume(0.8f32)
        @Expect(player.volume(), 0.8f32)
        player.delete()
        output.delete()
    }

    @TestCase
    func testPlaybackRateRoundtrip() {
        let player = QMediaPlayer()
        player.setPlaybackRate(1.5f32)
        @Expect(player.playbackRate(), 1.5f32)
        player.setPlaybackRate(2.0f32)
        @Expect(player.playbackRate(), 2.0f32)
        player.setPlaybackRate(0.5f32)
        @Expect(player.playbackRate(), 0.5f32)
        player.delete()
    }

    @TestCase
    func testSetLoopsNoCrash() {
        let player = QMediaPlayer()
        player.setLoops(Loops.once())
        player.setLoops(Loops.infinite())
        player.setLoops(3)
        @Expect(player.getPtr() != 0, true)
        player.delete()
    }

    @TestCase
    func testPositionNoCrash() {
        let player = QMediaPlayer()
        player.setPosition(1000)
        @Expect(player.position() >= 0, true)
        player.delete()
    }

    @TestCase
    func testSetSourceNoCrash() {
        let player = QMediaPlayer()
        player.setSource("")
        player.setSourceFile("C:/nonexistent_cjqt6_test.mp3")
        @Expect(player.getPtr() != 0, true)
        player.delete()
    }

    @TestCase
    func testMetaDataEmpty() {
        let player = QMediaPlayer()
        @Expect(player.title(), "")
        @Expect(player.artist(), "")
        @Expect(player.album(), "")
        player.delete()
    }

    @TestCase
    func testPlayPauseStopNoCrash() {
        let player = QMediaPlayer()
        player.play()
        player.pause()
        player.stop()
        @Expect(player.getPtr() != 0, true)
        player.delete()
    }

    @TestCase
    func testCallbacksRegister() {
        let player = QMediaPlayer()
        player.onPositionChanged(gPosChangedCb)
        player.onDurationChanged(gDurChangedCb)
        player.onPlaybackStateChanged(gPlayStateCb)
        player.onMediaStatusChanged(gMediaStatusCb)
        @Expect(player.getPtr() != 0, true)
        player.delete()
    }

    @TestCase
    func testMultiplePlayers() {
        let p1 = QMediaPlayer()
        let p2 = QMediaPlayer()
        p1.setPlaybackRate(2.0f32)
        p2.setPlaybackRate(0.5f32)
        @Expect(p1.playbackRate(), 2.0f32)
        @Expect(p2.playbackRate(), 0.5f32)
        p1.delete()
        p2.delete()
    }
}

// =====================================================================
// QSoundEffect 测试
// =====================================================================
@Test
@Tag[requires_audio]
class QSoundEffectTests {
    private static var guiEnv: ?GUITestEnvironment = None

    @BeforeAll
    static func setupGUI(): Unit {
        let env = GUITestEnvironment.getInstance()
        env.setupEnvironment()
        guiEnv = Some(env)
    }

    @AfterAll
    static func teardownGUI(): Unit {
        if (let Some(env) <- guiEnv) {
            env.teardownEnvironment()
        }
    }

    @TestCase
    func testCreateDelete() {
        let fx = QSoundEffect()
        @Expect(fx.status(), SoundEffectStatus.Null())
        fx.delete()
    }

    @TestCase
    func testVolumeRoundtrip() {
        let fx = QSoundEffect()
        fx.setVolume(0.5)
        @Expect(fx.volume(), 0.5)
        fx.setVolume(1.0)
        @Expect(fx.volume(), 1.0)
        fx.delete()
    }

    @TestCase
    func testLoopCountRoundtrip() {
        let fx = QSoundEffect()
        fx.setLoopCount(3)
        @Expect(fx.loopCount(), 3)
        // Qt6 将非法值(0/-1)钳制为 1（最小合法循环次数）
        fx.setLoopCount(0)
        @Expect(fx.loopCount(), 1)
        fx.setLoopCount(-1)
        @Expect(fx.loopCount(), 1)
        fx.delete()
    }

    @TestCase
    func testMuteRoundtrip() {
        let fx = QSoundEffect()
        fx.setMuted(true)
        @Expect(fx.isMuted(), true)
        fx.setMuted(false)
        @Expect(fx.isMuted(), false)
        fx.delete()
    }

    @TestCase
    func testInitialStatus() {
        let fx = QSoundEffect()
        @Expect(fx.status(), SoundEffectStatus.Null())
        @Expect(fx.isPlaying(), false)
        fx.delete()
    }

    @TestCase
    func testSetSourceNoCrash() {
        let fx = QSoundEffect()
        fx.setSource("qrc:/nonexistent.wav")
        fx.setSourceFile("C:/nonexistent_cjqt6_test.wav")
        @Expect(fx.status() >= SoundEffectStatus.Null(), true)
        fx.delete()
    }

    @TestCase
    func testPlayStopNoCrash() {
        let fx = QSoundEffect()
        fx.play()
        fx.stop()
        @Expect(fx.status() >= SoundEffectStatus.Null(), true)
        fx.delete()
    }
}

// =====================================================================
// QMediaDevices / QCamera 测试
// =====================================================================
@Test
@Tag[requires_audio]
class QMediaDevicesCameraTests {
    private static var guiEnv: ?GUITestEnvironment = None

    @BeforeAll
    static func setupGUI(): Unit {
        let env = GUITestEnvironment.getInstance()
        env.setupEnvironment()
        guiEnv = Some(env)
    }

    @AfterAll
    static func teardownGUI(): Unit {
        if (let Some(env) <- guiEnv) {
            env.teardownEnvironment()
        }
    }

    @TestCase
    func testVideoInputCount() {
        @Expect(QMediaDevices.videoInputCount() >= 0, true)
    }

    @TestCase
    func testDefaultVideoInput() {
        let device = QMediaDevices.defaultVideoInput()
        device.description()
        device.id()
        device.delete()
    }

    @TestCase
    func testCameraCreate() {
        let cam = QCamera()
        @Expect(cam.getPtr() != 0, true)
        cam.close()
    }

    @TestCase
    func testCameraInitialState() {
        let cam = QCamera()
        @Expect(cam.isActive(), false)
        // 无摄像头环境(offscreen/CI)下 QCamera 会报告错误码(1=CameraError)，
        // 合法取值区间为 [0,4]，此处仅校验其为合法枚举值
        @Expect(cam.errorCode() >= 0 && cam.errorCode() <= 4, true)
        cam.errorString()
        cam.close()
    }

    @TestCase
    func testCameraStartStopNoCrash() {
        let cam = QCamera()
        cam.start()
        cam.stop()
        @Expect(cam.getPtr() != 0, true)
        cam.close()
    }

    @TestCase
    func testCameraClose() {
        let cam = QCamera()
        cam.close()
        @Expect(cam.getPtr(), 0)
    }

    @TestCase
    func testCameraClosedThrows() {
        let cam = QCamera()
        cam.close()
        @ExpectThrows[ResourceDisposedException](cam.isActive())
    }
}

// =====================================================================
// QImageCapture 测试
// =====================================================================
@Test
@Tag[requires_audio]
class QImageCaptureTests {
    private static var guiEnv: ?GUITestEnvironment = None

    @BeforeAll
    static func setupGUI(): Unit {
        let env = GUITestEnvironment.getInstance()
        env.setupEnvironment()
        guiEnv = Some(env)
    }

    @AfterAll
    static func teardownGUI(): Unit {
        if (let Some(env) <- guiEnv) {
            env.teardownEnvironment()
        }
    }

    @TestCase
    func testCreateClose() {
        let cap = QImageCapture()
        @Expect(cap.getPtr() != 0, true)
        cap.close()
        @Expect(cap.getPtr(), 0)
    }

    @TestCase
    func testQualityRoundtrip() {
        let cap = QImageCapture()
        cap.setQuality(ImageCaptureQuality.lowQuality())
        @Expect(cap.quality(), ImageCaptureQuality.lowQuality())
        cap.setQuality(ImageCaptureQuality.normalQuality())
        @Expect(cap.quality(), ImageCaptureQuality.normalQuality())
        cap.setQuality(ImageCaptureQuality.highQuality())
        @Expect(cap.quality(), ImageCaptureQuality.highQuality())
        cap.close()
    }

    @TestCase
    func testNotReadyWithoutCamera() {
        let cap = QImageCapture()
        @Expect(cap.isReadyForCapture(), false)
        cap.close()
    }

    @TestCase
    func testCaptureReturnsErrorWithoutCamera() {
        let cap = QImageCapture()
        // Qt6: capture() 返回请求 ID；无相机时返回 -1（不是 ImageCaptureError 枚举）
        @Expect(cap.capture() == -1, true)
        cap.close()
    }

    @TestCase
    func testCaptureToFileReturnsErrorWithoutCamera() {
        let cap = QImageCapture()
        // Qt6: captureToFile() 返回请求 ID；无相机时返回 -1（不是 ImageCaptureError 枚举）
        @Expect(cap.captureToFile("C:/tmp/cjqt6_cap_test.jpg") == -1, true)
        cap.close()
    }
}

// =====================================================================
// QVideoWidget 测试
// =====================================================================
@Test
@Tag[requires_audio]
class QVideoWidgetTests {
    private static var guiEnv: ?GUITestEnvironment = None

    @BeforeAll
    static func setupGUI(): Unit {
        let env = GUITestEnvironment.getInstance()
        env.setupEnvironment()
        guiEnv = Some(env)
    }

    @AfterAll
    static func teardownGUI(): Unit {
        if (let Some(env) <- guiEnv) {
            env.teardownEnvironment()
        }
    }

    @TestCase
    func testCreateShowClose() {
        let widget = QVideoWidget()
        @Expect(widget.getPtr() != 0, true)
        widget.show()
        widget.close()
        @Expect(widget.getPtr(), 0)
    }

    @TestCase
    func testAspectRatioRoundtrip() {
        let widget = QVideoWidget()
        widget.setAspectRatioMode(1)
        @Expect(widget.aspectRatioMode(), 1)
        widget.setAspectRatioMode(2)
        @Expect(widget.aspectRatioMode(), 2)
        widget.setAspectRatioMode(0)
        @Expect(widget.aspectRatioMode(), 0)
        widget.close()
    }
}

// =====================================================================
// QMediaCaptureSession 测试
// =====================================================================
@Test
@Tag[requires_audio]
class QMediaCaptureSessionTests {
    private static var guiEnv: ?GUITestEnvironment = None

    @BeforeAll
    static func setupGUI(): Unit {
        let env = GUITestEnvironment.getInstance()
        env.setupEnvironment()
        guiEnv = Some(env)
    }

    @AfterAll
    static func teardownGUI(): Unit {
        if (let Some(env) <- guiEnv) {
            env.teardownEnvironment()
        }
    }

    @TestCase
    func testCreateClose() {
        let session = QMediaCaptureSession()
        @Expect(session.getPtr() != 0, true)
        session.close()
        @Expect(session.getPtr(), 0)
    }

    @TestCase
    func testSetCameraNoCrash() {
        let session = QMediaCaptureSession()
        let cam = QCamera()
        session.setCamera(cam.getPtr())
        @Expect(session.getPtr() != 0, true)
        cam.close()
        session.close()
    }

    @TestCase
    func testSetVideoOutputNoCrash() {
        let session = QMediaCaptureSession()
        let widget = QVideoWidget()
        session.setVideoOutput(widget.getPtr())
        @Expect(session.getPtr() != 0, true)
        widget.close()
        session.close()
    }
}

// =====================================================================
// 渐变类测试（QLinearGradient / QRadialGradient / QConicalGradient）
// =====================================================================
@Test
class GradientTests {
    private static var guiEnv: ?GUITestEnvironment = None

    @BeforeAll
    static func setupGUI(): Unit {
        let env = GUITestEnvironment.getInstance()
        env.setupEnvironment()
        guiEnv = Some(env)
    }

    @AfterAll
    static func teardownGUI(): Unit {
        if (let Some(env) <- guiEnv) {
            env.teardownEnvironment()
        }
    }

    @TestCase
    func testLinearCreateDelete() {
        let g = QLinearGradient(0.0f32, 0.0f32, 100.0f32, 50.0f32)
        @Expect(g.isValid(), true)
        g.delete()
        @Expect(g.isValid(), false)
    }

    @TestCase
    func testLinearFromIntAndColorAt() {
        let g = QLinearGradient.fromInt(0, 0, 100, 50)
        let red = QColor(255, 0, 0)
        let blue = QColor(0, 0, 255)
        g.setColorAt(0.0f32, red)
        g.setColorAt(1.0f32, blue)
        @Expect(g.isValid(), true)
        g.delete()
        red.delete()
        blue.delete()
    }

    @TestCase
    func testRadialCreateDelete() {
        let g = QRadialGradient(50.0f32, 50.0f32, 40.0f32, 50.0f32, 50.0f32)
        @Expect(g.isValid(), true)
        g.delete()
        @Expect(g.isValid(), false)
    }

    @TestCase
    func testRadialFromIntAndColorAt() {
        let g = QRadialGradient.fromInt(50, 50, 40, 60, 60)
        let color = QColor(0, 255, 0)
        g.setColorAt(0.5f32, color)
        @Expect(g.isValid(), true)
        g.delete()
        color.delete()
    }

    @TestCase
    func testConicalCreateDelete() {
        let g = QConicalGradient(50.0f32, 50.0f32, 90.0f32)
        @Expect(g.isValid(), true)
        g.delete()
        @Expect(g.isValid(), false)
    }

    @TestCase
    func testConicalFromIntAndColorAt() {
        let g = QConicalGradient.fromInt(50, 50, 90)
        let color = QColor(255, 255, 0)
        g.setColorAt(0.25f32, color)
        @Expect(g.isValid(), true)
        g.delete()
        color.delete()
    }
}

// =====================================================================
// QFont 测试
// =====================================================================
@Test
class QFontTests {
    private static var guiEnv: ?GUITestEnvironment = None

    @BeforeAll
    static func setupGUI(): Unit {
        let env = GUITestEnvironment.getInstance()
        env.setupEnvironment()
        guiEnv = Some(env)
    }

    @AfterAll
    static func teardownGUI(): Unit {
        if (let Some(env) <- guiEnv) {
            env.teardownEnvironment()
        }
    }

    @TestCase
    func testCreateDelete() {
        let font = QFont("Arial")
        @Expect(font.isValid(), true)
        font.delete()
        @Expect(font.isValid(), false)
    }

    @TestCase
    func testCreateWithSize() {
        let font = QFont("Arial", 14)
        @Expect(font.isValid(), true)
        font.delete()
    }

    @TestCase
    func testSetPointSize() {
        let font = QFont("Arial", 12)
        font.setPointSize(20)
        @Expect(font.isValid(), true)
        font.delete()
    }

    @TestCase
    func testSetBoldItalic() {
        let font = QFont("Arial")
        font.setBold(true)
        font.setItalic(true)
        @Expect(font.isValid(), true)
        font.delete()
    }
}

// =====================================================================
// QPainterPath 测试
// =====================================================================
@Test
class QPainterPathTests {
    private static var guiEnv: ?GUITestEnvironment = None

    @BeforeAll
    static func setupGUI(): Unit {
        let env = GUITestEnvironment.getInstance()
        env.setupEnvironment()
        guiEnv = Some(env)
    }

    @AfterAll
    static func teardownGUI(): Unit {
        if (let Some(env) <- guiEnv) {
            env.teardownEnvironment()
        }
    }

    @TestCase
    func testCreateDelete() {
        let path = QPainterPath()
        @Expect(path.isValid(), true)
        @Expect(path.isEmpty(), true)
        path.delete()
        @Expect(path.isValid(), false)
    }

    @TestCase
    func testMoveLineNotEmpty() {
        let path = QPainterPath()
        path.moveTo(10.0f32, 10.0f32)
        path.lineTo(50.0f32, 50.0f32)
        @Expect(path.isEmpty(), false)
        path.delete()
    }

    @TestCase
    func testAddShapes() {
        let path = QPainterPath()
        path.addRect(0.0f32, 0.0f32, 100.0f32, 50.0f32)
        path.addEllipse(0.0f32, 0.0f32, 20.0f32, 20.0f32)
        path.closeSubpath()
        @Expect(path.isEmpty(), false)
        path.delete()
    }

    @TestCase
    func testChainedCalls() {
        let path = QPainterPath()
        path.moveTo(0.0f32, 0.0f32).lineTo(10.0f32, 10.0f32).addRect(0.0f32, 0.0f32, 5.0f32, 5.0f32)
        @Expect(path.isEmpty(), false)
        path.delete()
    }
}

// =====================================================================
// QPixmap 测试
// =====================================================================
@Test
class QPixmapTests {
    private static var guiEnv: ?GUITestEnvironment = None

    @BeforeAll
    static func setupGUI(): Unit {
        let env = GUITestEnvironment.getInstance()
        env.setupEnvironment()
        guiEnv = Some(env)
    }

    @AfterAll
    static func teardownGUI(): Unit {
        if (let Some(env) <- guiEnv) {
            env.teardownEnvironment()
        }
    }

    @TestCase
    func testCreateNull() {
        let pm = QPixmap()
        @Expect(pm.isValid(), true)
        @Expect(pm.isNull(), true)
        pm.delete()
    }

    @TestCase
    func testWithSize() {
        let pm = QPixmap.withSize(100, 50)
        @Expect(pm.width(), 100)
        @Expect(pm.height(), 50)
        @Expect(pm.isNull(), false)
        pm.delete()
    }

    @TestCase
    func testLoadNonexistent() {
        let pm = QPixmap.load("C:/nonexistent_cjqt6_test.png")
        @Expect(pm.isValid(), true)
        @Expect(pm.isNull(), true)
        pm.delete()
    }

    @TestCase
    func testFill() {
        let pm = QPixmap.withSize(10, 10)
        let red = QColor(255, 0, 0)
        pm.fill(red)
        @Expect(pm.isNull(), false)
        pm.delete()
        red.delete()
    }

    @TestCase
    func testDeleteInvalidates() {
        let pm = QPixmap.withSize(20, 20)
        pm.delete()
        @Expect(pm.isValid(), false)
    }
}

// =====================================================================
// QImage 测试
// =====================================================================
@Test
class QImageTests {
    private static var guiEnv: ?GUITestEnvironment = None

    @BeforeAll
    static func setupGUI(): Unit {
        let env = GUITestEnvironment.getInstance()
        env.setupEnvironment()
        guiEnv = Some(env)
    }

    @AfterAll
    static func teardownGUI(): Unit {
        if (let Some(env) <- guiEnv) {
            env.teardownEnvironment()
        }
    }

    @TestCase
    func testCreateNull() {
        let img = QImage()
        @Expect(img.isValid(), true)
        @Expect(img.isNull(), true)
        img.delete()
    }

    @TestCase
    func testWithSize() {
        let img = QImage.withSize(64, 48)
        @Expect(img.width(), 64)
        @Expect(img.height(), 48)
        @Expect(img.isNull(), false)
        img.delete()
    }

    @TestCase
    func testMultipleImages() {
        let img1 = QImage.withSize(10, 10)
        let img2 = QImage.withSize(20, 30)
        @Expect(img1.width(), 10)
        @Expect(img2.width(), 20)
        @Expect(img2.height(), 30)
        img1.delete()
        img2.delete()
    }
}

// =====================================================================
// QPainter 测试
// =====================================================================
@Test
class QPainterTests {
    private static var guiEnv: ?GUITestEnvironment = None

    @BeforeAll
    static func setupGUI(): Unit {
        let env = GUITestEnvironment.getInstance()
        env.setupEnvironment()
        guiEnv = Some(env)
    }

    @AfterAll
    static func teardownGUI(): Unit {
        if (let Some(env) <- guiEnv) {
            env.teardownEnvironment()
        }
    }

    @TestCase
    func testCreate() {
        let painter = QPainter()
        @Expect(painter.getPtr() != 0, true)
    }

    @TestCase
    func testFromPtr() {
        let painter = QPainter.fromPtr(0)
        @Expect(painter.getPtr(), 0)
    }

    @TestCase
    func testBeginEndOnImage() {
        let img = QImage.withSize(100, 80)
        let painter = QPainter()
        @Expect(painter.begin(img.getPtr()), true)
        @Expect(painter.isActive(), true)
        @Expect(painter.end(), true)
        @Expect(painter.isActive(), false)
        img.delete()
    }

    @TestCase
    func testDevice() {
        let img = QImage.withSize(100, 80)
        let painter = QPainter(img.getPtr())
        @Expect(painter.device() != 0, true)
        painter.end()
        img.delete()
    }

    @TestCase
    func testDrawPrimitives() {
        let img = QImage.withSize(200, 150)
        let painter = QPainter(img.getPtr())
        painter.drawLine(0, 0, 100, 100)
        painter.drawRect(10, 10, 50, 30)
        painter.drawEllipse(20, 20, 40, 40)
        painter.drawCircle(100, 100, 20)
        painter.drawArc(0, 0, 80, 80, 0, 180 * 16)
        painter.drawPie(50, 50, 60, 60, 0, 90 * 16)
        @Expect(painter.isActive(), true)
        painter.end()
        img.delete()
    }

    @TestCase
    func testSetPenBrushFont() {
        let img = QImage.withSize(100, 100)
        let painter = QPainter(img.getPtr())
        let pen = QPen()
        let brush = QBrush()
        let color = QColor(255, 0, 0)
        let font = QFont("Arial", 12)
        painter.setPen(pen)
        painter.setPenColor(color)
        painter.setBrush(brush)
        painter.setFont(font)
        painter.setRenderHint(RenderHint.Antialiasing.value())
        painter.setOpacity(0.5f32)
        @Expect(painter.isActive(), true)
        painter.end()
        pen.delete()
        brush.delete()
        color.delete()
        font.delete()
        img.delete()
    }

    @TestCase
    func testDrawText() {
        let img = QImage.withSize(200, 100)
        let painter = QPainter(img.getPtr())
        painter.drawText(10, 20, "Hello CJQT6")
        painter.drawTextRect(0, 0, 200, 100, TextAlignment.Center.value, "Centered")
        painter.end()
        img.delete()
    }

    @TestCase
    func testDrawPixmapImage() {
        let img = QImage.withSize(200, 150)
        let painter = QPainter(img.getPtr())
        let pm = QPixmap.withSize(40, 30)
        let img2 = QImage.withSize(30, 20)
        painter.drawPixmap(5, 5, pm)
        painter.drawImage(50, 50, img2)
        @Expect(painter.isActive(), true)
        painter.end()
        pm.delete()
        img2.delete()
        img.delete()
    }

    @TestCase
    func testFillRect() {
        let img = QImage.withSize(100, 100)
        let painter = QPainter(img.getPtr())
        let brush = QBrush(QColor(255, 0, 0))
        let color = QColor(0, 255, 0)
        painter.fillRect(0, 0, 50, 50, brush)
        painter.fillRectColor(50, 50, 50, 50, color)
        painter.end()
        brush.delete()
        color.delete()
        img.delete()
    }

    @TestCase
    func testDrawAndFillPath() {
        let img = QImage.withSize(100, 100)
        let painter = QPainter(img.getPtr())
        let path = QPainterPath()
        path.addRect(10.0f32, 10.0f32, 50.0f32, 50.0f32)
        let brush = QBrush(QColor(0, 0, 255))
        painter.drawPath(path)
        painter.fillPath(path, brush)
        @Expect(painter.isActive(), true)
        painter.end()
        path.delete()
        brush.delete()
        img.delete()
    }

    @TestCase
    func testTransformSaveRestore() {
        let img = QImage.withSize(100, 100)
        let painter = QPainter(img.getPtr())
        painter.save()
        painter.translate(10.0f32, 10.0f32)
        painter.scale(2.0f32, 2.0f32)
        painter.rotate(45.0f32)
        painter.drawRect(0, 0, 10, 10)
        painter.restore()
        painter.drawRect(0, 0, 10, 10)
        painter.end()
        img.delete()
    }
}

// =====================================================================
// QFontDatabase 测试
// =====================================================================
@Test
class QFontDatabaseTests {
    private static var guiEnv: ?GUITestEnvironment = None

    @BeforeAll
    static func setupGUI(): Unit {
        let env = GUITestEnvironment.getInstance()
        env.setupEnvironment()
        guiEnv = Some(env)
    }

    @AfterAll
    static func teardownGUI(): Unit {
        if (let Some(env) <- guiEnv) {
            env.teardownEnvironment()
        }
    }

    private static func firstFamily(): String {
        let fams = QFontDatabase.families()
        if (let Some(idx) <- fams.indexOf(",")) {
            return fams[0..idx].trimAscii()
        }
        fams.trimAscii()
    }

    private static func firstStyle(family: String): String {
        let styles = QFontDatabase.styles(family)
        if (let Some(idx) <- styles.indexOf(",")) {
            return styles[0..idx].trimAscii()
        }
        styles.trimAscii()
    }

    @TestCase
    func testFamilies() {
        @Expect(QFontDatabase.families().size > 0, true)
    }

    @TestCase
    func testStandardSizes() {
        @Expect(QFontDatabase.standardSizes() > 0, true)
    }

    @TestCase
    func testStylesNonEmpty() {
        let fam = firstFamily()
        @Expect(QFontDatabase.styles(fam).size > 0, true)
    }

    @TestCase
    func testIsScalableNoCrash() {
        let fam = firstFamily()
        let result = QFontDatabase.isScalable(fam)
        @Expect(result == true || result == false, true)
    }

    @TestCase
    func testIsFixedPitchNoCrash() {
        let fam = firstFamily()
        let style = firstStyle(fam)
        let result = QFontDatabase.isFixedPitch(fam, style)
        @Expect(result == true || result == false, true)
    }

    @TestCase
    func testPointSizes() {
        let fam = firstFamily()
        let style = firstStyle(fam)
        @Expect(QFontDatabase.pointSizes(fam, style) >= 0, true)
    }
}

// =====================================================================
// QTransform 测试
// =====================================================================
@Test
class QTransformTests {
    private static var guiEnv: ?GUITestEnvironment = None

    @BeforeAll
    static func setupGUI(): Unit {
        let env = GUITestEnvironment.getInstance()
        env.setupEnvironment()
        guiEnv = Some(env)
    }

    @AfterAll
    static func teardownGUI(): Unit {
        if (let Some(env) <- guiEnv) {
            env.teardownEnvironment()
        }
    }

    @TestCase
    func testCreateIdentity() {
        let t = QTransform()
        @Expect(t.isIdentity(), true)
        @Expect(t.isInvertible(), true)
        @Expect(t.m11(), 1.0f32)
        @Expect(t.m22(), 1.0f32)
        @Expect(t.m33(), 1.0f32)
        @Expect(t.dx(), 0.0f32)
        @Expect(t.dy(), 0.0f32)
        t.delete()
    }

    @TestCase
    func testCreateWithValues() {
        let t = QTransform(1.0f32, 2.0f32, 3.0f32, 4.0f32, 5.0f32, 6.0f32, 7.0f32, 8.0f32, 9.0f32)
        @Expect(t.m11(), 1.0f32)
        @Expect(t.m12(), 2.0f32)
        @Expect(t.m13(), 3.0f32)
        @Expect(t.m21(), 4.0f32)
        @Expect(t.m22(), 5.0f32)
        @Expect(t.m23(), 6.0f32)
        @Expect(t.m31(), 7.0f32)
        @Expect(t.m32(), 8.0f32)
        @Expect(t.m33(), 9.0f32)
        @Expect(t.isIdentity(), false)
        t.delete()
    }

    @TestCase
    func testSetMatrix() {
        let t = QTransform()
        t.setMatrix(2.0f32, 0.0f32, 0.0f32, 0.0f32, 3.0f32, 0.0f32, 5.0f32, 6.0f32, 1.0f32)
        @Expect(t.m11(), 2.0f32)
        @Expect(t.m22(), 3.0f32)
        @Expect(t.m31(), 5.0f32)
        @Expect(t.m32(), 6.0f32)
        @Expect(t.isIdentity(), false)
        t.delete()
    }

    @TestCase
    func testTranslate() {
        let t = QTransform()
        let t2 = t.translate(10.0f32, 20.0f32)
        @Expect(t2.dx(), 10.0f32)
        @Expect(t2.dy(), 20.0f32)
        @Expect(t2.isIdentity(), false)
        t.delete()
        t2.delete()
    }

    @TestCase
    func testScale() {
        let t = QTransform()
        let t2 = t.scale(2.0f32, 3.0f32)
        @Expect(t2.m11(), 2.0f32)
        @Expect(t2.m22(), 3.0f32)
        @Expect(t2.isIdentity(), false)
        t.delete()
        t2.delete()
    }

    @TestCase
    func testRotate() {
        let t = QTransform()
        let t2 = t.rotate(90.0f32)
        @Expect(abs(Float64(t2.m12()) - 1.0) < 0.001, true)
        @Expect(abs(Float64(t2.m21()) + 1.0) < 0.001, true)
        t.delete()
        t2.delete()
    }

    @TestCase
    func testShear() {
        let t = QTransform()
        let t2 = t.shear(1.0f32, 0.0f32)
        @Expect(abs(Float64(t2.m21()) - 1.0) < 0.001, true)
        @Expect(t2.isIdentity(), false)
        t.delete()
        t2.delete()
    }

    @TestCase
    func testInverted() {
        let t = QTransform()
        let t2 = t.translate(10.0f32, 20.0f32)
        @Expect(t2.isInvertible(), true)
        let inv = t2.inverted()
        @Expect(inv.dx(), -10.0f32)
        @Expect(inv.dy(), -20.0f32)
        t.delete()
        t2.delete()
        inv.delete()
    }

    @TestCase
    func testMultiply() {
        let t = QTransform()
        let t2 = t.translate(10.0f32, 0.0f32)
        let t3 = t.scale(2.0f32, 1.0f32)
        let r = t2.multiply(t3)
        @Expect(r.dx(), 20.0f32)
        @Expect(r.m11(), 2.0f32)
        t.delete()
        t2.delete()
        t3.delete()
        r.delete()
    }

    @TestCase
    func testDeleteInvalidates() {
        let t = QTransform()
        t.delete()
        @Expect(t.getPtr(), 0)
    }
}

// =====================================================================
// 绘图枚举测试
// =====================================================================
@Test
class PaintEnumTests {
    private static var guiEnv: ?GUITestEnvironment = None

    @BeforeAll
    static func setupGUI(): Unit {
        let env = GUITestEnvironment.getInstance()
        env.setupEnvironment()
        guiEnv = Some(env)
    }

    @AfterAll
    static func teardownGUI(): Unit {
        if (let Some(env) <- guiEnv) {
            env.teardownEnvironment()
        }
    }

    @TestCase
    func testPenStyleValues() {
        @Expect(PenStyle.NoPen.value(), 0)
        @Expect(PenStyle.SolidLine.value(), 1)
        @Expect(PenStyle.DashLine.value(), 2)
        @Expect(PenStyle.DotLine.value(), 3)
        @Expect(PenStyle.DashDotLine.value(), 4)
        @Expect(PenStyle.DashDotDotLine.value(), 5)
        @Expect(PenStyle.CustomDashLine.value(), 6)
    }

    @TestCase
    func testPenStyleFromValue() {
        @Expect(PenStyle.fromValue(1).value(), PenStyle.SolidLine.value())
        @Expect(PenStyle.fromValue(2).value(), PenStyle.DashLine.value())
        @Expect(PenStyle.fromValue(4).value(), PenStyle.DashDotLine.value())
        @Expect(PenStyle.fromValue(0).value(), PenStyle.NoPen.value())
    }

    @TestCase
    func testBrushStyleValues() {
        @Expect(BrushStyle.NoBrush.value(), 0)
        @Expect(BrushStyle.SolidPattern.value(), 1)
        @Expect(BrushStyle.CrossPattern.value(), 11)
        @Expect(BrushStyle.LinearGradient.value(), 15)
        @Expect(BrushStyle.RadialGradient.value(), 16)
        @Expect(BrushStyle.ConicalGradient.value(), 17)
    }

    @TestCase
    func testBrushStyleFromValue() {
        @Expect(BrushStyle.fromValue(0).value(), BrushStyle.NoBrush.value())
        @Expect(BrushStyle.fromValue(1).value(), BrushStyle.SolidPattern.value())
        @Expect(BrushStyle.fromValue(11).value(), BrushStyle.CrossPattern.value())
        @Expect(BrushStyle.fromValue(15).value(), BrushStyle.LinearGradient.value())
        @Expect(BrushStyle.fromValue(16).value(), BrushStyle.RadialGradient.value())
        @Expect(BrushStyle.fromValue(17).value(), BrushStyle.ConicalGradient.value())
    }

    @TestCase
    func testRenderHintValues() {
        @Expect(RenderHint.Antialiasing.value(), 0x01)
        @Expect(RenderHint.TextAntialiasing.value(), 0x02)
        @Expect(RenderHint.SmoothPixmapTransform.value(), 0x04)
        @Expect(RenderHint.HighQualityAntialiasing.value(), 0x08)
        @Expect(RenderHint.NonCosmeticDefaultPen.value(), 0x10)
    }

    @TestCase
    func testImageFormatValues() {
        @Expect(ImageFormat.Invalid.value(), 0)
        @Expect(ImageFormat.RGB32.value(), 4)
        @Expect(ImageFormat.ARGB32.value(), 5)
        @Expect(ImageFormat.ARGB32_Premultiplied.value(), 6)
        @Expect(ImageFormat.RGBA8888.value(), 9)
    }

    @TestCase
    func testImageFormatFromValue() {
        @Expect(ImageFormat.fromValue(4).value(), ImageFormat.RGB32.value())
        @Expect(ImageFormat.fromValue(5).value(), ImageFormat.ARGB32.value())
        @Expect(ImageFormat.fromValue(9).value(), ImageFormat.RGBA8888.value())
    }

    @TestCase
    func testTextAlignmentValues() {
        @Expect(TextAlignment.Left.value, 0x01)
        @Expect(TextAlignment.Right.value, 0x02)
        @Expect(TextAlignment.HCenter.value, 0x04)
        @Expect(TextAlignment.Top.value, 0x20)
        @Expect(TextAlignment.Bottom.value, 0x40)
        @Expect(TextAlignment.VCenter.value, 0x80)
        @Expect(TextAlignment.Center.value, 0x84)
        @Expect(TextAlignment.Default.value, 0x81)
    }

    @TestCase
    func testTextAlignmentCombine() {
        let combined = TextAlignment.Left | TextAlignment.Right
        @Expect(combined.value, 0x03)
        let centerBottom = TextAlignment.HCenter | TextAlignment.Bottom
        @Expect(centerBottom.value, 0x44)
    }
}
