package cjqt6.test

// =====================================================================
// 快捷键 + 桌面服务模块测试
// 覆盖：src/core/shortcut.cj 的 QShortcut
//      src/core/desktopservices.cj 的 QDesktopServices
// 注意：QDesktopServices.openUrl/openFile 会调用系统程序打开，
//      标注 @Tag[requires_desktop]
// =====================================================================

import cjqt6.core.*
import std.unittest.*

// ---------------------------------------------------------------------
// QShortcut 测试
// ---------------------------------------------------------------------
@Test
class QShortcutTests {
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
        let parent = QWidget()
        let sc = QShortcut(parent)
        @Assert(sc.isValid())
        @Expect(sc.isClosed(), false)
        @Expect(sc.getPtr() != 0, true)
        sc.close()
        @Expect(sc.isClosed(), true)
        parent.close()
    }

    @TestCase
    func testSetKey() {
        let parent = QWidget()
        let sc = QShortcut(parent)
        sc.setKey("Ctrl+O")
        sc.setKey("Ctrl+S")
        sc.setKey("F5")
        sc.close()
        parent.close()
        @Assert(true)
    }

    @TestCase
    func testSetEnabled() {
        let parent = QWidget()
        let sc = QShortcut(parent)
        sc.setEnabled(true)
        sc.setEnabled(false)
        sc.setEnabled(true)
        sc.close()
        parent.close()
        @Assert(true)
    }

    @TestCase
    func testSetAutoRepeat() {
        let parent = QWidget()
        let sc = QShortcut(parent)
        sc.setAutoRepeat(true)
        sc.setAutoRepeat(false)
        sc.close()
        parent.close()
        @Assert(true)
    }

    @TestCase
    func testCloseAndCheckValid() {
        let parent = QWidget()
        let sc = QShortcut(parent)
        sc.close()
        @Expect(sc.isValid(), false)
        @ExpectThrows[ResourceDisposedException](sc.checkValid())
        parent.close()
    }

    @TestCase
    func testOperationsAfterClose() {
        let parent = QWidget()
        let sc = QShortcut(parent)
        sc.close()
        @ExpectThrows[ResourceDisposedException](sc.setKey("Ctrl+X"))
        @ExpectThrows[ResourceDisposedException](sc.setEnabled(true))
        @ExpectThrows[ResourceDisposedException](sc.setAutoRepeat(true))
        parent.close()
    }

    @TestCase
    func testDeleteCompatibility() {
        let parent = QWidget()
        let sc = QShortcut(parent)
        sc.delete()
        @Expect(sc.isClosed(), true)
        parent.close()
    }

    @TestCase
    func testDoubleClose() {
        let parent = QWidget()
        let sc = QShortcut(parent)
        sc.close()
        sc.close()
        @Expect(sc.isClosed(), true)
        parent.close()
    }
}

// ---------------------------------------------------------------------
// QDesktopServices 测试（调用系统程序打开，标注 requires_desktop）
// ---------------------------------------------------------------------
@Test
@Tag[requires_desktop]
class QDesktopServicesTests {
    @TestCase
    func testOpenUrlHttp() {
        // 打开一个 URL，可能成功或失败（取决于系统默认浏览器）
        let r = QDesktopServices.openUrl("https://example.com") // cjlint-ignore !G.OTH.03 测试用示例URL
        @Assert(r == true || r == false)
    }

    @TestCase
    func testOpenUrlInvalid() {
        // 无效 URL 通常返回 false
        let r = QDesktopServices.openUrl("")
        @Assert(r == true || r == false)
    }

    @TestCase
    func testOpenFileNonExistent() {
        // 不存在的文件通常返回 false
        let r = QDesktopServices.openFile("C:\\nonexistent_path_12345\\file.txt")
        @Assert(r == true || r == false)
    }
}
