package cjqt6.test

import cjqt6.core.*
import cjqt6.widgets.*
import std.unittest.*
import std.fs.*

// =====================================================================
// QUiLoader - Qt Designer .ui 文件加载测试
// =====================================================================
@Test
class QUiLoaderTests {
    private static var guiEnv: ?GUITestEnvironment = None
    private static let uiFilePath = "./ui_test_form.ui"

    /// 生成一个简单的 .ui 表单文件（含一个 QPushButton，objectName = btnOk）
    static func createUiFile(): Unit {
        let uiXml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
            "<ui version=\"4.0\">\n" +
            " <class>Form</class>\n" +
            " <widget class=\"QWidget\" name=\"Form\">\n" +
            "  <layout class=\"QVBoxLayout\" name=\"verticalLayout\">\n" +
            "   <item>\n" +
            "    <widget class=\"QPushButton\" name=\"btnOk\">\n" +
            "     <property name=\"text\">\n" +
            "      <string>OK</string>\n" +
            "     </property>\n" +
            "    </widget>\n" +
            "   </item>\n" +
            "  </layout>\n" +
            " </widget>\n" +
            " <resources/>\n" +
            " <connections/>\n" +
            "</ui>\n"
        removeIfExists(Path(uiFilePath), recursive: true)
        let file = File(uiFilePath, OpenMode.ReadWrite)
        file.write(uiXml.toArray())
        file.close()
    }

    @BeforeAll
    static func setup(): Unit {
        let env = GUITestEnvironment.getInstance()
        env.setupEnvironment()
        guiEnv = Some(env)
        createUiFile()
    }

    @AfterAll
    static func teardown(): Unit {
        if (let Some(env) <- guiEnv) {
            env.teardownEnvironment()
        }
        removeIfExists(Path(uiFilePath), recursive: true)
    }

    /// 加载 .ui 文件，返回根控件
    @TestCase
    func testLoadUiFile() {
        let loader = QUiLoader()
        @Expect(loader.isValid(), true)
        let form = loader.load(uiFilePath, 0)
        @Expect(form.getPtr() != 0, true)
        @Expect(form.isValid(), true)
        form.close()  // fromPtr 包装，只标记关闭
        loader.close()
        @Expect(loader.isClosed(), true)
    }

    /// 加载后按 objectName 查找子控件
    @TestCase
    func testFindChildByName() {
        let loader = QUiLoader()
        let form = loader.load(uiFilePath, 0)
        let btn = form.findChild("btnOk")
        @Expect(btn.getPtr() != 0, true)
        @Expect(btn.isValid(), true)
        // 不存在的控件返回无效对象
        let missing = form.findChild("noSuchControl")
        @Expect(missing.getPtr(), 0)
        @Expect(missing.isValid(), false)
        form.close()
        loader.close()
    }

    /// 加载不存在的文件应抛出异常
    @TestCase
    func testLoadMissingFile() {
        let loader = QUiLoader()
        @ExpectThrows[CreateFailedException](loader.load("./no_such_file.ui", 0))
        loader.close()    }

    /// 设置工作目录后加载相对资源路径
    @TestCase
    func testSetWorkingDirectory() {
        let loader = QUiLoader()
        loader.setWorkingDirectory("./")
        // 工作目录设置不抛异常即为成功
        @Expect(loader.isValid(), true)
        let form = loader.load(uiFilePath, 0)
        @Expect(form.getPtr() != 0, true)
        form.close()
        loader.close()
    }
}
