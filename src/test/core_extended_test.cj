package cjqt6.test

import cjqt6.core.*
import std.unittest.*

// =====================================================================
// QApplication 基本 API 测试
// =====================================================================
@Test
class QApplicationBasicTests {

    @TestCase
    func testCreateAndDelete() {
        let app = QApplication()
        app.delete()
        @Assert(true)
    }

    @TestCase
    func testDoubleDelete() {
        let app = QApplication()
        app.delete()
        app.delete()  // 安全
        @Assert(true)
    }

    @TestCase
    func testQuit() {
        let app = QApplication()
        app.quit()
        app.delete()
        @Assert(true)
    }

    @TestCase
    func testLoadQtTranslation() {
        let app = QApplication()
        let r = app.loadQtTranslation("zh_CN")
        // 可能返回 true/false，取决于 qt 翻译文件是否存在
        @Assert(true)
        app.delete()
    }

    @TestCase
    func testLocale() {
        let app = QApplication()
        let loc = app.locale()
        @Assert(loc.size > 0)
        app.delete()
    }

    @TestCase
    func testSystemLocale() {
        let app = QApplication()
        let loc = app.systemLocale()
        @Assert(loc.size > 0)
        app.delete()
    }

    @TestCase
    func testSetLocale() {
        let app = QApplication()
        app.setLocale("en_US")
        @Assert(true)
        app.delete()
    }

    @TestCase
    func testSwitchLanguage() {
        let app = QApplication()
        app.switchLanguage("zh_CN")
        @Assert(true)
        app.delete()
    }

    @TestCase
    func testQAppStaticQuit() {
        let app = QApplication()
        QApp.quit()
        app.delete()
        @Assert(true)
    }
}

// =====================================================================
// QClipboard 测试（静态方法 API）
// =====================================================================
@Test
class QClipboardTests {
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
    func testSetText() {
        QClipboard.setText("clipboard test content")
        @Assert(true)
    }

    @TestCase
    func testText() {
        QClipboard.setText("hello clipboard")
        let t = QClipboard.text()
        @Expect(t, "hello clipboard")
    }

    @TestCase
    func testHasText() {
        QClipboard.setText("has text")
        @Expect(QClipboard.hasText(), true)
        QClipboard.clear()
        @Expect(QClipboard.hasText(), false)
    }

    @TestCase
    func testClear() {
        QClipboard.setText("test")
        QClipboard.clear()
        @Expect(QClipboard.hasText(), false)
    }
}

// =====================================================================
// QScreen 测试（静态方法 API）
// =====================================================================
@Test
class QScreenTests {
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
    func testPrimaryWidth() {
        let w = QScreen.primaryWidth()
        @Expect(w > 0, true)
    }

    @TestCase
    func testPrimaryHeight() {
        let h = QScreen.primaryHeight()
        @Expect(h > 0, true)
    }

    @TestCase
    func testDevicePixelRatio() {
        let ratio = QScreen.primaryDevicePixelRatio()
        @Expect(ratio > 0.0, true)
    }

    @TestCase
    func testDpi() {
        let dpiX = QScreen.primaryDpiX()
        @Expect(dpiX > 0.0, true)
    }

    @TestCase
    func testRefreshRate() {
        let rate = QScreen.primaryRefreshRate()
        @Expect(rate > 0.0, true)
    }

    @TestCase
    func testScaleFactor() {
        let sf = QScreen.scaleFactor()
        @Expect(sf > 0.0, true)
    }
}

// =====================================================================
// QSettings 测试
// =====================================================================
@Test
class QSettingsTests {
    @TestCase
    func testCreate() {
        let settings = QSettings("CJQT6Test")
        @Assert(settings.isValid())
        @Expect(settings.isClosed(), false)
        settings.close()
    }

    @TestCase
    func testSetValue() {
        let settings = QSettings("CJQT6Test")
        settings.setValue("testKey", "testValue")
        @Assert(settings.isValid())
        settings.close()
    }

    @TestCase
    func testValue() {
        let settings = QSettings("CJQT6Test")
        settings.setValue("myKey", "myValue")
        let v = settings.value("myKey", "")
        @Expect(v, "myValue")
        settings.close()
    }

    @TestCase
    func testValueDefault() {
        let settings = QSettings("CJQT6Test")
        let v = settings.value("noSuchKey", "defaultVal")
        @Expect(v, "defaultVal")
        settings.close()
    }

    @TestCase
    func testContains() {
        let settings = QSettings("CJQT6Test")
        settings.setValue("existsKey", "123")
        @Expect(settings.contains("existsKey"), true)
        @Expect(settings.contains("nonexistent"), false)
        settings.close()
    }

    @TestCase
    func testRemove() {
        let settings = QSettings("CJQT6Test")
        settings.setValue("removeMe", "val")
        @Expect(settings.contains("removeMe"), true)
        settings.remove("removeMe")
        @Expect(settings.contains("removeMe"), false)
        settings.close()
    }

    @TestCase
    func testValueInt() {
        let settings = QSettings("CJQT6Test")
        let v = settings.valueInt("intKey", 42)
        @Expect(v, 42)
        settings.close()
    }

    @TestCase
    func testClose() {
        let settings = QSettings("CJQT6Test")
        @Expect(settings.isClosed(), false)
        settings.close()
        @Expect(settings.isClosed(), true)
    }

    @TestCase
    func testOperationsAfterClose() {
        let settings = QSettings("CJQT6Test")
        settings.close()
        @ExpectThrows[ResourceDisposedException](settings.setValue("k", "v"))
        @ExpectThrows[ResourceDisposedException](settings.value("k", ""))
    }
}

// =====================================================================
// QFileWatcher 测试
// =====================================================================
@Test
class QFileWatcherTests {
    @TestCase
    func testCreate() {
        let watcher = QFileSystemWatcher()
        @Assert(watcher.isValid())
        @Expect(watcher.isClosed(), false)
        watcher.close()
    }

    @TestCase
    func testClose() {
        let watcher = QFileSystemWatcher()
        @Expect(watcher.isClosed(), false)
        watcher.close()
        @Expect(watcher.isClosed(), true)
        @Expect(watcher.isValid(), false)
    }

    @TestCase
    func testOperationsAfterClose() {
        let watcher = QFileSystemWatcher()
        watcher.close()
        @ExpectThrows[ResourceDisposedException](watcher.addPath("C:\\"))
        @ExpectThrows[ResourceDisposedException](watcher.removePath("C:\\"))
    }

    @TestCase
    func testDoubleClose() {
        let watcher = QFileSystemWatcher()
        watcher.close()
        watcher.close()  // 安全
        @Expect(watcher.isClosed(), true)
    }
}

// =====================================================================
// QStandardPaths 测试（静态常量 API）
// =====================================================================
@Test
class QStandardPathsTests {
    @TestCase
    func testHomeLocation() {
        let path = QStandardPaths.writableLocation(StandardLocationHome)
        @Assert(path.size > 0)
    }

    @TestCase
    func testTempLocation() {
        let path = QStandardPaths.writableLocation(StandardLocationTemp)
        @Assert(path.size > 0)
    }

    @TestCase
    func testTempDir() {
        let path = QStandardPaths.tempDir()
        @Assert(path.size > 0)
    }

    @TestCase
    func testDesktopLocation() {
        let path = QStandardPaths.writableLocation(StandardLocationDesktop)
        @Assert(path.size > 0)
    }

    @TestCase
    func testDisplayName() {
        let name = QStandardPaths.displayName(StandardLocationDocuments)
        @Assert(name.size > 0)
    }
}

// =====================================================================
// QTranslator 测试
// =====================================================================
@Test
class QTranslatorTests {
    @TestCase
    func testCreate() {
        let app = QApplication()
        // loadQtTranslation 是最简单的翻译加载路径
        let ok = app.loadQtTranslation("")
        // 可能成功也可能失败，不 crash 即可
        @Assert(true)
        app.delete()
    }
}
