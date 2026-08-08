package cjqt6.test

import cjqt6.gui.*
import cjqt6.widgets.*
import cjqt6.core.*
import std.unittest.*

// =====================================================================
// QVBoxLayout 测试
// =====================================================================
@Test
class QVBoxLayoutTests {
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
        let layout = QVBoxLayout()
        @Assert(layout.isValid())
        @Expect(layout.getPtr() != 0, true)
        @Expect(layout.isClosed(), false)
        layout.close()
    }

    @TestCase
    func testAddWidget() {
        let layout = QVBoxLayout()
        let widget = QWidget()
        layout.addWidget(widget.getPtr())
        @Assert(layout.isValid())
        widget.close()
        layout.close()
    }

    @TestCase
    func testAddWidgetWithStretch() {
        let layout = QVBoxLayout()
        let widget = QWidget()
        layout.addWidget(widget.getPtr(), 1)
        @Assert(layout.isValid())
        widget.close()
        layout.close()
    }

    @TestCase
    func testAddLayout() {
        let layout = QVBoxLayout()
        let childLayout = QHBoxLayout()
        layout.addLayout(childLayout.getPtr())
        @Assert(layout.isValid())
        childLayout.close()
        layout.close()
    }

    @TestCase
    func testAddStretch() {
        let layout = QVBoxLayout()
        layout.addStretch()
        @Assert(layout.isValid())
        layout.close()
    }

    @TestCase
    func testSetSpacing() {
        let layout = QVBoxLayout()
        layout.setSpacing(10)
        @Assert(layout.isValid())
        layout.close()
    }

    @TestCase
    func testSetMargin() {
        let layout = QVBoxLayout()
        layout.setMargin(5)
        @Assert(layout.isValid())
        layout.close()
    }

    @TestCase
    func testClose() {
        let layout = QVBoxLayout()
        @Expect(layout.isClosed(), false)
        layout.close()
        @Expect(layout.isClosed(), true)
        @Expect(layout.isValid(), false)
    }

    @TestCase
    func testOperationsAfterClose() {
        let layout = QVBoxLayout()
        layout.close()
        let widget = QWidget()
        @ExpectThrows[Exception](layout.addWidget(widget.getPtr()))
        widget.close()
    }
}

// =====================================================================
// QHBoxLayout 测试
// =====================================================================
@Test
class QHBoxLayoutTests {
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
        let layout = QHBoxLayout()
        @Assert(layout.isValid())
        @Expect(layout.getPtr() != 0, true)
        @Expect(layout.isClosed(), false)
        layout.close()
    }

    @TestCase
    func testAddWidget() {
        let layout = QHBoxLayout()
        let widget = QWidget()
        layout.addWidget(widget.getPtr())
        @Assert(layout.isValid())
        widget.close()
        layout.close()
    }

    @TestCase
    func testAddWidgetWithStretch() {
        let layout = QHBoxLayout()
        let widget = QWidget()
        layout.addWidget(widget.getPtr(), 2)
        @Assert(layout.isValid())
        widget.close()
        layout.close()
    }

    @TestCase
    func testAddLayout() {
        let layout = QHBoxLayout()
        let childLayout = QVBoxLayout()
        layout.addLayout(childLayout.getPtr())
        @Assert(layout.isValid())
        childLayout.close()
        layout.close()
    }

    @TestCase
    func testAddStretch() {
        let layout = QHBoxLayout()
        layout.addStretch()
        @Assert(layout.isValid())
        layout.close()
    }

    @TestCase
    func testSetSpacing() {
        let layout = QHBoxLayout()
        layout.setSpacing(15)
        @Assert(layout.isValid())
        layout.close()
    }

    @TestCase
    func testSetMargin() {
        let layout = QHBoxLayout()
        layout.setMargin(8)
        @Assert(layout.isValid())
        layout.close()
    }

    @TestCase
    func testClose() {
        let layout = QHBoxLayout()
        @Expect(layout.isClosed(), false)
        layout.close()
        @Expect(layout.isClosed(), true)
        @Expect(layout.isValid(), false)
    }

    @TestCase
    func testOperationsAfterClose() {
        let layout = QHBoxLayout()
        layout.close()
        let widget = QWidget()
        @ExpectThrows[Exception](layout.addWidget(widget.getPtr()))
        widget.close()
    }
}

// =====================================================================
// QGridLayout 测试
// =====================================================================
@Test
class QGridLayoutTests {
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
        let layout = QGridLayout()
        @Assert(layout.isValid())
        @Expect(layout.getPtr() != 0, true)
        @Expect(layout.isClosed(), false)
        layout.close()
    }

    @TestCase
    func testAddWidget() {
        let layout = QGridLayout()
        let w1 = QWidget()
        let w2 = QWidget()
        layout.addWidget(w1.getPtr(), 0, 0)
        layout.addWidget(w2.getPtr(), 1, 0)
        @Assert(layout.isValid())
        w2.close()
        w1.close()
        layout.close()
    }

    @TestCase
    func testAddWidgetWithSpan() {
        let layout = QGridLayout()
        let widget = QWidget()
        layout.addWidgetSpan(widget.getPtr(), 0, 0, 1, 2)
        @Assert(layout.isValid())
        widget.close()
        layout.close()
    }

    @TestCase
    func testSetSpacing() {
        let layout = QGridLayout()
        layout.setSpacing(12)
        @Assert(layout.isValid())
        layout.close()
    }

    @TestCase
    func testSetMargin() {
        let layout = QGridLayout()
        layout.setMargin(10)
        @Assert(layout.isValid())
        layout.close()
    }

    @TestCase
    func testClose() {
        let layout = QGridLayout()
        @Expect(layout.isClosed(), false)
        layout.close()
        @Expect(layout.isClosed(), true)
        @Expect(layout.isValid(), false)
    }

    @TestCase
    func testOperationsAfterClose() {
        let layout = QGridLayout()
        layout.close()
        let widget = QWidget()
        @ExpectThrows[Exception](layout.addWidget(widget.getPtr(), 0, 0))
        widget.close()
    }
}

// =====================================================================
// QFormLayout 测试
// =====================================================================
@Test
class QFormLayoutTests {
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
        let layout = QFormLayout()
        @Assert(layout.isValid())
        @Expect(layout.getPtr() != 0, true)
        layout.close()
    }

    @TestCase
    func testAddRow() {
        let layout = QFormLayout()
        let widget = QLineEdit()
        layout.addRow("Name:", widget.getPtr())
        @Expect(layout.rowCount(), 1)
        widget.close()
        layout.close()
    }

    @TestCase
    func testAddMultipleRows() {
        let layout = QFormLayout()
        let w1 = QLineEdit()
        let w2 = QLineEdit()
        layout.addRow("First:", w1.getPtr())
        layout.addRow("Second:", w2.getPtr())
        @Expect(layout.rowCount(), 2)
        w2.close()
        w1.close()
        layout.close()
    }

    @TestCase
    func testClose() {
        let layout = QFormLayout()
        @Expect(layout.isClosed(), false)
        layout.close()
        @Expect(layout.isClosed(), true)
    }
}

// =====================================================================
// Widget + Layout 集成测试
// =====================================================================
@Test
class WidgetLayoutIntegrationTests {
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
    func testSetLayoutOnWidget() {
        let widget = QWidget()
        let layout = QVBoxLayout()
        widget.setLayout(layout.getPtr())
        @Assert(widget.isValid())
        @Assert(layout.isValid())
        layout.close()
        widget.close()
    }

    @TestCase
    func testComplexLayout() {
        let widget = QWidget()
        let mainLayout = QVBoxLayout()
        let btnLayout = QHBoxLayout()
        let btn1 = QPushButton()
        let btn2 = QPushButton()

        btn1.setText("OK")
        btn2.setText("Cancel")
        btnLayout.addWidget(btn1.getPtr())
        btnLayout.addWidget(btn2.getPtr())
        mainLayout.addLayout(btnLayout.getPtr())
        widget.setLayout(mainLayout.getPtr())

        @Assert(widget.isValid())

        btn2.close()
        btn1.close()
        btnLayout.close()
        mainLayout.close()
        widget.close()
    }

    @TestCase
    func testNestedLayoutManagement() {
        let widget = QWidget()
        let outer = QVBoxLayout()
        let row1 = QHBoxLayout()
        let row2 = QHBoxLayout()

        let label = QLabel()
        label.setText("Row 1")
        row1.addWidget(label.getPtr())

        let edit = QLineEdit()
        edit.setText("Row 2")
        row2.addWidget(edit.getPtr())

        outer.addLayout(row1.getPtr())
        outer.addLayout(row2.getPtr())
        widget.setLayout(outer.getPtr())

        @Assert(widget.isValid())

        edit.close()
        label.close()
        row2.close()
        row1.close()
        outer.close()
        widget.close()
    }
}
