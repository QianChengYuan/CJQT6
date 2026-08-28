package cjqt6.test

import cjqt6.widgets.*
import cjqt6.core.*
import cjqt6.menu.*
import std.unittest.*

@Test
class QPushButtonTests {
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
        let btn = QPushButton()
        @Assert(btn.isValid())
        @Expect(btn.isClosed(), false)
        @Expect(btn.getPtr() != 0, true)
        btn.close()
    }
    
    @TestCase
    func testClose() {
        let btn = QPushButton()
        @Expect(btn.isClosed(), false)
        btn.close()
        @Expect(btn.isClosed(), true)
        @Expect(btn.isValid(), false)
    }
    
    @TestCase
    func testSetText() {
        let btn = QPushButton()
        btn.setText("Click Me")
        @Assert(btn.isValid())
        btn.close()
    }
    
    @TestCase
    func testOperationsAfterClose() {
        let btn = QPushButton()
        btn.close()
        
        @ExpectThrows[ResourceDisposedException](btn.show())
        @ExpectThrows[ResourceDisposedException](btn.hide())
        @ExpectThrows[ResourceDisposedException](btn.setText("test"))
        @ExpectThrows[ResourceDisposedException](btn.resize(100, 50))
    }
    
    @TestCase
    func testSetMinimumSize() {
        let btn = QPushButton()
        btn.setMinimumSize(100, 50)
        @Assert(btn.isValid())
        btn.close()
    }
    
    @TestCase
    func testSetMaximumSize() {
        let btn = QPushButton()
        btn.setMaximumSize(400, 300)
        @Assert(btn.isValid())
        btn.close()
    }
    
    @TestCase
    func testSetMenu() {
        let btn = QPushButton()
        let menu = QMenu("测试菜单")
        btn.setMenu(menu.getPtr())
        @Assert(btn.isValid())
        btn.close()
        menu.close()
    }
}

@Test
class QLabelTests {
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
        let label = QLabel()
        @Assert(label.isValid())
        @Expect(label.isClosed(), false)
        label.close()
    }
    
    @TestCase
    func testSetText() {
        let label = QLabel()
        label.setText("Hello World")
        @Assert(label.isValid())
        label.close()
    }
    
    @TestCase
    func testSetAlignment() {
        let label = QLabel()
        label.setAlignment(0x0004)
        @Assert(label.isValid())
        label.close()
    }
    
    @TestCase
    func testOperationsAfterClose() {
        let label = QLabel()
        label.close()
        
        @ExpectThrows[ResourceDisposedException](label.show())
        @ExpectThrows[ResourceDisposedException](label.setText("test"))
    }
}

@Test
class QLineEditTests {
    
    @TestCase
    func testCreate() {
        let edit = QLineEdit()
        @Assert(edit.isValid())
        @Expect(edit.isClosed(), false)
        edit.close()
    }
    
    @TestCase
    func testSetText() {
        let edit = QLineEdit()
        edit.setText("Initial Text")
        @Assert(edit.isValid())
        edit.close()
    }
    
    @TestCase
    func testText() {
        let edit = QLineEdit()
        edit.setText("Test Content")
        let text = edit.text()
        @Expect(text, "Test Content")
        edit.close()
    }
    
    @TestCase
    func testClear() {
        let edit = QLineEdit()
        edit.setText("Some Text")
        edit.clear()
        let text = edit.text()
        @Expect(text, "")
        edit.close()
    }
    
    @TestCase
    func testSetPlaceholder() {
        let edit = QLineEdit()
        edit.setPlaceholder("Enter name...")
        @Assert(edit.isValid())
        edit.close()
    }
    
    @TestCase
    func testOperationsAfterClose() {
        let edit = QLineEdit()
        edit.close()
        
        @ExpectThrows[ResourceDisposedException](edit.setText("test"))
        @ExpectThrows[ResourceDisposedException](edit.text())
        @ExpectThrows[ResourceDisposedException](edit.clear())
    }
}

@Test
class QSpinBoxTests {
    
    @TestCase
    func testCreate() {
        let spin = QSpinBox()
        @Assert(spin.isValid())
        @Expect(spin.isClosed(), false)
        spin.close()
    }
    
    @TestCase
    func testSetValue() {
        let spin = QSpinBox()
        spin.setValue(50)
        @Assert(spin.isValid())
        spin.close()
    }
    
    @TestCase
    func testValue() {
        let spin = QSpinBox()
        spin.setValue(42)
        let v = spin.value()
        @Expect(v, 42)
        spin.close()
    }
    
    @TestCase
    func testSetRange() {
        let spin = QSpinBox()
        spin.setRange(0, 100)
        spin.setValue(50)
        @Expect(spin.value(), 50)
        spin.close()
    }
    
    @TestCase
    func testOperationsAfterClose() {
        let spin = QSpinBox()
        spin.close()
        
        @ExpectThrows[ResourceDisposedException](spin.setValue(10))
        @ExpectThrows[ResourceDisposedException](spin.value())
    }
}
