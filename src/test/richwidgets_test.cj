package cjqt6.test

import cjqt6.core.*
import cjqt6.richwidgets.*
import cjqt6.widgets.*
import std.unittest.*

@Test
class SwitchTests {
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
    func testCreateAndToggle() {
        let sw = Switch()
        @Expect(sw.isChecked(), false)
        sw.setChecked(true)
        @Expect(sw.isChecked(), true)
        sw.toggle()
        @Expect(sw.isChecked(), false)
        @Expect(sw.isValid(), true)
        sw.close()
    }

    @TestCase
    func testSetText() {
        let sw = Switch()
        sw.setText("开启")
        @Expect(sw.isValid(), true)
        sw.close()
    }

    @TestCase
    func testClose() {
        let sw = Switch()
        sw.close()
        @Expect(sw.isClosed(), true)
        @Expect(sw.isValid(), false)
    }
}

@Test
class ToastTests {
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
    func testCreateAndClose() {
        let toast = Toast("加载中...", 3000)
        @Expect(toast.isClosed(), false)
        toast.close()
        @Expect(toast.isClosed(), true)
    }

    @TestCase
    func testCloseIdempotent() {
        let toast = Toast("加载中...", 3000)
        toast.close()
        toast.close()
        @Expect(toast.isClosed(), true)
    }
}

// ---------------------------------------------------------------------
// P1-5：Toast 自动化用例为何只覆盖「创建/关闭」两条最简路径
// 实测结论（对照实验见 docs/internal/cjmonitor-findings.md P1-5）：任何涉及
// 「静态入口替换/释放」或「用例内 exec + quit」的 Toast 用例，在本仓库测试进程里
// 都**时序敏感**——同一份代码会随前后用例顺序、乃至插入一行 println 而时通时挂。
// 为避免给 CI 引入 flaky 用例，本文件只保留不需要事件循环、且实测稳定的两条；
// Toast 的自动关闭与静态入口行为改由 docs 记录结论，不作运行期断言。
// ---------------------------------------------------------------------

@Test
class SearchBoxTests {
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
    func testTextAndClear() {
        let box = SearchBox()
        @Expect(box.text(), "")
        box.setText("hello")
        @Expect(box.text(), "hello")
        box.clear()
        @Expect(box.text(), "")
        box.close()
    }

    @TestCase
    func testSetPlaceholder() {
        let box = SearchBox()
        box.setPlaceholder("请输入关键词")
        @Expect(box.isValid(), true)
        box.close()
    }
}

@Test
class FormTests {
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
    func testAddRow() {
        let form = Form("用户信息")
        form.addRow("姓名", QLineEdit())
        form.addRow("邮箱", QLineEdit())
        @Expect(form.isValid(), true)
        form.close()
    }

    @TestCase
    func testSetTitle() {
        let form = Form()
        form.setTitle("测试表单")
        @Expect(form.isValid(), true)
        form.close()
    }
}

@Test
class DateRangePickerTests {
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
    func testSetAndGet() {
        let picker = DateRangePicker()
        picker.setStartDate(2024, 1, 1)
        picker.setEndDate(2024, 12, 31)
        @Expect(picker.getStartDate().year(), 2024)
        @Expect(picker.getEndDate().month(), 12)
        @Expect(picker.getEndDate().day(), 31)
        picker.close()
    }

    @TestCase
    func testDisplayFormat() {
        let picker = DateRangePicker()
        picker.setDisplayFormat("yyyy/MM/dd")
        @Expect(picker.isValid(), true)
        picker.close()
    }
}

@Test
class PaginationTests {
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
    func testCreateAndSetTotal() {
        let pg = Pagination()
        pg.setTotalPages(5)
        @Expect(pg.getTotalPages(), 5)
        @Expect(pg.getCurrentPage(), 1)
        pg.close()
    }

    @TestCase
    func testSetCurrentPage() {
        let pg = Pagination()
        pg.setTotalPages(10)
        pg.setCurrentPage(3)
        @Expect(pg.getCurrentPage(), 3)
        pg.close()
    }

    @TestCase
    func testOutOfBounds() {
        let pg = Pagination()
        pg.setTotalPages(3)
        pg.setCurrentPage(3)
        pg.setCurrentPage(5)
        @Expect(pg.getCurrentPage(), 3)
        pg.setCurrentPage(0)
        @Expect(pg.getCurrentPage(), 3)
        pg.close()
    }
}

@Test
class GroupCardTests {
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
    func testCreateAndAddWidget() {
        let card = GroupCard("设置")
        card.addWidget(QLabel())
        card.addWidget(QPushButton())
        @Expect(card.isValid(), true)
        card.close()
    }

    @TestCase
    func testTitle() {
        let card = GroupCard()
        card.setTitle("卡片标题")
        @Expect(card.title(), "卡片标题")
        card.close()
    }
}
