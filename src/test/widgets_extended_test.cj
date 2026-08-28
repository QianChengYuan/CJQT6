package cjqt6.test

import cjqt6.widgets.*
import cjqt6.core.*
import std.unittest.*

// =====================================================================
// QCheckBox 测试
// =====================================================================
@Test
class QCheckBoxTests {
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
        let cb = QCheckBox()
        @Assert(cb.isValid())
        @Expect(cb.getPtr() != 0, true)
        @Expect(cb.isClosed(), false)
        cb.close()
    }

    @TestCase
    func testSetText() {
        let cb = QCheckBox()
        cb.setText("Agree")
        @Assert(cb.isValid())
        cb.close()
    }

    @TestCase
    func testText() {
        let cb = QCheckBox()
        cb.setText("Accept Terms")
        let t = cb.text()
        @Expect(t, "Accept Terms")
        cb.close()
    }

    @TestCase
    func testSetChecked() {
        let cb = QCheckBox()
        cb.setChecked(true)
        @Expect(cb.isChecked(), true)
        cb.setChecked(false)
        @Expect(cb.isChecked(), false)
        cb.close()
    }

    @TestCase
    func testDefaultUnchecked() {
        let cb = QCheckBox()
        @Expect(cb.isChecked(), false)
        cb.close()
    }

    @TestCase
    func testTristate() {
        let cb = QCheckBox()
        cb.setTristate(true)
        @Expect(cb.isTristate(), true)
        cb.setTristate(false)
        @Expect(cb.isTristate(), false)
        cb.close()
    }

    @TestCase
    func testCheckState() {
        let cb = QCheckBox()
        cb.setTristate(true)
        cb.setCheckState(CheckState.Checked)
        @Expect(cb.checkState(), CheckState.Checked)
        cb.setCheckState(CheckState.Unchecked)
        @Expect(cb.checkState(), CheckState.Unchecked)
        cb.setCheckState(CheckState.PartiallyChecked)
        @Expect(cb.checkState(), CheckState.PartiallyChecked)
        cb.close()
    }

    @TestCase
    func testClose() {
        let cb = QCheckBox()
        @Expect(cb.isClosed(), false)
        cb.close()
        @Expect(cb.isClosed(), true)
        @Expect(cb.isValid(), false)
    }

    @TestCase
    func testOperationsAfterClose() {
        let cb = QCheckBox()
        cb.close()
        @ExpectThrows[ResourceDisposedException](cb.setText("test"))
        @ExpectThrows[ResourceDisposedException](cb.setChecked(true))
        @ExpectThrows[ResourceDisposedException](cb.isChecked())
    }
}

// =====================================================================
// QRadioButton 测试
// =====================================================================
@Test
class QRadioButtonTests {
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
        let rb = QRadioButton()
        @Expect(rb.getPtr() != 0, true)
        rb.delete()
    }

    @TestCase
    func testSetText() {
        let rb = QRadioButton()
        rb.setText("Option A")
        @Expect(rb.text(), "Option A")
        rb.delete()
    }

    @TestCase
    func testSetChecked() {
        let rb = QRadioButton()
        rb.setChecked(true)
        @Expect(rb.isChecked(), true)
        rb.delete()
    }

    @TestCase
    func testAutoExclusive() {
        let rb = QRadioButton()
        rb.setAutoExclusive(true)
        @Expect(rb.isAutoExclusive(), true)
        rb.setAutoExclusive(false)
        @Expect(rb.isAutoExclusive(), false)
        rb.delete()
    }

    @TestCase
    func testDelete() {
        let rb = QRadioButton()
        rb.delete()
        @Assert(true)
        rb.delete()  // 安全
        @Assert(true)
    }

    @TestCase
    func testSetEnabled() {
        let rb = QRadioButton()
        rb.setEnabled(false)
        @Expect(rb.isEnabled(), false)
        rb.delete()
    }
    
    // ===== QtResource 测试 =====
    
    @TestCase
    func testClose() {
        let rb = QRadioButton()
        @Expect(rb.isClosed(), false)
        @Expect(rb.isValid(), true)
        rb.close()
        @Expect(rb.isClosed(), true)
        @Expect(rb.isValid(), false)
    }
    
    @TestCase
    func testDoubleClose() {
        let rb = QRadioButton()
        rb.close()
        rb.close()  // 安全
        @Assert(true)
    }
    
    @TestCase
    func testOperationsAfterClose() {
        let rb = QRadioButton()
        rb.close()
        @ExpectThrows[ResourceDisposedException](rb.show())
        @ExpectThrows[ResourceDisposedException](rb.hide())
        @ExpectThrows[ResourceDisposedException](rb.setText("test"))
        @ExpectThrows[ResourceDisposedException](rb.setChecked(true))
    }
    
    @TestCase
    func testDeleteAfterClose() {
        let rb = QRadioButton()
        rb.close()
        rb.delete()  // delete 应安全处理已关闭状态
        @Assert(true)
    }
}

// =====================================================================
// QComboBox 测试
// =====================================================================
@Test
class QComboBoxTests {
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
        let cb = QComboBox()
        @Assert(cb.isValid())
        @Expect(cb.getPtr() != 0, true)
        @Expect(cb.isClosed(), false)
        cb.close()
    }

    @TestCase
    func testAddItem() {
        let cb = QComboBox()
        cb.addItem("Apple")
        @Expect(cb.count(), 1)
        @Expect(cb.itemText(0), "Apple")
        cb.close()
    }

    @TestCase
    func testAddItems() {
        let cb = QComboBox()
        cb.addItem("Apple")
        cb.addItem("Banana")
        cb.addItem("Cherry")
        @Expect(cb.count(), 3)
        @Expect(cb.itemText(0), "Apple")
        @Expect(cb.itemText(2), "Cherry")
        cb.close()
    }

    @TestCase
    func testInsertItem() {
        let cb = QComboBox()
        cb.addItem("A")
        cb.addItem("C")
        cb.insertItem(1, "B")
        @Expect(cb.count(), 3)
        @Expect(cb.itemText(1), "B")
        cb.close()
    }

    @TestCase
    func testRemoveItem() {
        let cb = QComboBox()
        cb.addItem("A")
        cb.addItem("B")
        cb.addItem("C")
        cb.removeItem(1)
        @Expect(cb.count(), 2)
        @Expect(cb.itemText(0), "A")
        @Expect(cb.itemText(1), "C")
        cb.close()
    }

    @TestCase
    func testClear() {
        let cb = QComboBox()
        cb.addItem("A")
        cb.addItem("B")
        cb.addItem("C")
        @Expect(cb.count(), 3)
        cb.clear()
        @Expect(cb.count(), 0)
        cb.close()
    }

    @TestCase
    func testCurrentIndex() {
        let cb = QComboBox()
        cb.addItem("A")
        cb.addItem("B")
        cb.addItem("C")
        cb.setCurrentIndex(1)
        @Expect(cb.currentIndex(), 1)
        @Expect(cb.currentText(), "B")
        cb.close()
    }

    @TestCase
    func testSetCurrentText() {
        let cb = QComboBox()
        cb.addItem("Red")
        cb.addItem("Green")
        cb.addItem("Blue")
        cb.setCurrentText("Green")
        @Expect(cb.currentText(), "Green")
        cb.close()
    }

    @TestCase
    func testSetItemText() {
        let cb = QComboBox()
        cb.addItem("A")
        cb.addItem("B")
        cb.addItem("C")
        cb.setItemText(0, "Alpha")
        @Expect(cb.itemText(0), "Alpha")
        cb.close()
    }

    @TestCase
    func testFindText() {
        let cb = QComboBox()
        cb.addItem("Red")
        cb.addItem("Green")
        cb.addItem("Blue")
        let idx = cb.findText("Green")
        @Expect(idx, 1)
        let notFound = cb.findText("Purple")
        @Expect(notFound, -1)
        cb.close()
    }

    @TestCase
    func testSetEditable() {
        let cb = QComboBox()
        cb.setEditable(true)
        @Expect(cb.isEditable(), true)
        cb.setEditable(false)
        @Expect(cb.isEditable(), false)
        cb.close()
    }

    @TestCase
    func testPlaceholderText() {
        let cb = QComboBox()
        cb.setEditable(true)
        cb.setPlaceholderText("Choose...")
        @Assert(cb.isValid())
        cb.close()
    }

    @TestCase
    func testSetIconSize() {
        let cb = QComboBox()
        cb.setIconSize(24, 24)
        @Assert(cb.isValid())
        cb.close()
    }

    @TestCase
    func testClose() {
        let cb = QComboBox()
        @Expect(cb.isClosed(), false)
        cb.close()
        @Expect(cb.isClosed(), true)
        @Expect(cb.isValid(), false)
    }
}

// =====================================================================
// QSlider 测试
// =====================================================================
@Test
class QSliderTests {
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
        let slider = QSlider()
        @Assert(slider.isValid())
        @Expect(slider.getPtr() != 0, true)
        @Expect(slider.isClosed(), false)
        slider.close()
    }

    @TestCase
    func testSetValue() {
        let slider = QSlider()
        slider.setRange(0, 100)
        slider.setValue(50)
        @Expect(slider.value(), 50)
        slider.close()
    }

    @TestCase
    func testValueBounds() {
        let slider = QSlider()
        slider.setRange(0, 100)
        slider.setValue(0)
        @Expect(slider.value(), 0)
        slider.setValue(100)
        @Expect(slider.value(), 100)
        slider.close()
    }

    @TestCase
    func testSetOrientation() {
        let slider = QSlider()
        slider.setOrientation(1) // horizontal
        @Assert(slider.isValid())
        slider.setOrientation(2) // vertical
        @Assert(slider.isValid())
        slider.close()
    }

    @TestCase
    func testSingleStep() {
        let slider = QSlider()
        slider.setSingleStep(5)
        @Expect(slider.singleStep(), 5)
        slider.close()
    }

    @TestCase
    func testPageStep() {
        let slider = QSlider()
        slider.setPageStep(20)
        @Expect(slider.pageStep(), 20)
        slider.close()
    }

    @TestCase
    func testTickPosition() {
        let slider = QSlider()
        slider.setTickPosition(0) // NoTicks
        @Expect(slider.tickPosition(), 0)
        slider.setTickPosition(1) // TicksAbove
        @Expect(slider.tickPosition(), 1)
        slider.close()
    }

    @TestCase
    func testTickInterval() {
        let slider = QSlider()
        slider.setTickInterval(10)
        @Expect(slider.tickInterval(), 10)
        slider.close()
    }

    @TestCase
    func testInvertedControls() {
        let slider = QSlider()
        slider.setInvertedControls(true)
        @Expect(slider.invertedControls(), true)
        slider.setInvertedControls(false)
        @Expect(slider.invertedControls(), false)
        slider.close()
    }

    @TestCase
    func testTracking() {
        let slider = QSlider()
        slider.setTracking(true)
        @Assert(slider.isValid())
        slider.setTracking(false)
        @Assert(slider.isValid())
        slider.close()
    }

    @TestCase
    func testClose() {
        let slider = QSlider()
        @Expect(slider.isClosed(), false)
        slider.close()
        @Expect(slider.isClosed(), true)
        @Expect(slider.isValid(), false)
    }

    @TestCase
    func testOperationsAfterClose() {
        let slider = QSlider()
        slider.close()
        @ExpectThrows[ResourceDisposedException](slider.setValue(10))
        @ExpectThrows[ResourceDisposedException](slider.value())
        @ExpectThrows[ResourceDisposedException](slider.setRange(0, 100))
    }
}

// =====================================================================
// QProgressBar 测试
// =====================================================================
@Test
class QProgressBarTests {
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
        let bar = QProgressBar()
        @Assert(bar.isValid())
        @Expect(bar.getPtr() != 0, true)
        @Expect(bar.isClosed(), false)
        bar.close()
    }

    @TestCase
    func testSetValue() {
        let bar = QProgressBar()
        bar.setRange(0, 100)
        bar.setValue(50)
        @Expect(bar.value(), 50)
        bar.close()
    }

    @TestCase
    func testValueBounds() {
        let bar = QProgressBar()
        bar.setRange(0, 100)
        bar.setValue(0)
        @Expect(bar.value(), 0)
        bar.setValue(100)
        @Expect(bar.value(), 100)
        bar.close()
    }

    @TestCase
    func testSetTextVisible() {
        let bar = QProgressBar()
        bar.setTextVisible(true)
        @Expect(bar.isTextVisible(), true)
        bar.setTextVisible(false)
        @Expect(bar.isTextVisible(), false)
        bar.close()
    }

    @TestCase
    func testSetFormat() {
        let bar = QProgressBar()
        bar.setFormat("%p%")
        let f = bar.format()
        @Expect(f, "%p%")
        bar.close()
    }

    @TestCase
    func testSetInvertedAppearance() {
        let bar = QProgressBar()
        bar.setInvertedAppearance(true)
        @Expect(bar.invertedAppearance(), true)
        bar.setInvertedAppearance(false)
        @Expect(bar.invertedAppearance(), false)
        bar.close()
    }

    @TestCase
    func testSetOrientation() {
        let bar = QProgressBar()
        bar.setOrientation(1)
        @Assert(bar.isValid())
        bar.setOrientation(2)
        @Assert(bar.isValid())
        bar.close()
    }

    @TestCase
    func testRangeMinMax() {
        let bar = QProgressBar()
        bar.setMinimum(10)
        @Expect(bar.minimum(), 10)
        bar.setMaximum(90)
        @Expect(bar.maximum(), 90)
        bar.close()
    }

    @TestCase
    func testReset() {
        let bar = QProgressBar()
        bar.setRange(0, 100)
        bar.setValue(80)
        bar.reset()
        @Assert(bar.isValid())
        bar.close()
    }

    @TestCase
    func testClose() {
        let bar = QProgressBar()
        @Expect(bar.isClosed(), false)
        bar.close()
        @Expect(bar.isClosed(), true)
        @Expect(bar.isValid(), false)
    }

    @TestCase
    func testOperationsAfterClose() {
        let bar = QProgressBar()
        bar.close()
        @ExpectThrows[ResourceDisposedException](bar.setValue(10))
        @ExpectThrows[ResourceDisposedException](bar.value())
        @ExpectThrows[ResourceDisposedException](bar.setRange(0, 100))
    }
}

// =====================================================================
// QDial 测试
// =====================================================================
@Test
class QDialTests {
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
        let dial = QDial()
        @Expect(dial.getPtr() != 0, true)
        dial.delete()
    }

    @TestCase
    func testSetValue() {
        let dial = QDial()
        dial.setRange(0, 100)
        dial.setValue(50)
        @Expect(dial.value(), 50)
        dial.delete()
    }

    @TestCase
    func testWrapping() {
        let dial = QDial()
        dial.setWrapping(true)
        @Expect(dial.wrapping(), true)
        dial.setWrapping(false)
        @Expect(dial.wrapping(), false)
        dial.delete()
    }

    @TestCase
    func testNotchesVisible() {
        let dial = QDial()
        dial.setNotchesVisible(true)
        @Expect(dial.notchesVisible(), true)
        dial.setNotchesVisible(false)
        @Expect(dial.notchesVisible(), false)
        dial.delete()
    }

    @TestCase
    func testSingleStep() {
        let dial = QDial()
        dial.setSingleStep(5)
        @Assert(true)
        dial.delete()
    }

    @TestCase
    func testPageStep() {
        let dial = QDial()
        dial.setPageStep(20)
        @Expect(dial.pageStep(), 20)
        dial.delete()
    }

    @TestCase
    func testNotchTarget() {
        let dial = QDial()
        dial.setNotchTarget(10.5)
        @Expect(dial.notchTarget(), 10.5)
        dial.delete()
    }

    @TestCase
    func testDoubleDelete() {
        let dial = QDial()
        dial.delete()
        dial.delete()  // 安全
        @Assert(true)
    }
    
    // ===== QtResource 测试 =====
    
    @TestCase
    func testClose() {
        let dial = QDial()
        @Expect(dial.isClosed(), false)
        @Expect(dial.isValid(), true)
        dial.close()
        @Expect(dial.isClosed(), true)
        @Expect(dial.isValid(), false)
    }
    
    @TestCase
    func testDoubleClose() {
        let dial = QDial()
        dial.close()
        dial.close()  // 安全
        @Assert(true)
    }
    
    @TestCase
    func testOperationsAfterClose() {
        let dial = QDial()
        dial.close()
        @ExpectThrows[ResourceDisposedException](dial.show())
        @ExpectThrows[ResourceDisposedException](dial.hide())
        @ExpectThrows[ResourceDisposedException](dial.setValue(50))
        @ExpectThrows[ResourceDisposedException](dial.value())
    }
    
    @TestCase
    func testDeleteAfterClose() {
        let dial = QDial()
        dial.close()
        dial.delete()  // 安全
        @Assert(true)
    }
}

// =====================================================================
// QDoubleSpinBox 测试
// =====================================================================
@Test
class QDoubleSpinBoxTests {
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
        let spin = QDoubleSpinBox()
        @Expect(spin.getPtr() != 0, true)
        spin.delete()
    }

    @TestCase
    func testSetValue() {
        let spin = QDoubleSpinBox()
        spin.setRange(0.0, 100.0)
        spin.setValue(50.5)
        @Expect(spin.value(), 50.5)
        spin.delete()
    }

    @TestCase
    func testSetDecimals() {
        let spin = QDoubleSpinBox()
        spin.setDecimals(3)
        @Expect(spin.decimals(), 3)
        spin.delete()
    }

    @TestCase
    func testPrefixSuffix() {
        let spin = QDoubleSpinBox()
        spin.setPrefix("$")
        @Expect(spin.prefix(), "$")
        spin.setSuffix(" kg")
        @Expect(spin.suffix(), " kg")
        spin.delete()
    }

    @TestCase
    func testMinMax() {
        let spin = QDoubleSpinBox()
        spin.setMinimum(10.0)
        @Expect(spin.minimum(), 10.0)
        spin.setMaximum(200.0)
        @Expect(spin.maximum(), 200.0)
        spin.delete()
    }

    @TestCase
    func testDoubleDelete() {
        let spin = QDoubleSpinBox()
        spin.delete()
        spin.delete()
        @Assert(true)
    }
}

// =====================================================================
// QValidator 测试
// =====================================================================
@Test
class QValidatorTests {
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
    func testIntValidatorCreate() {
        let v = QIntValidator(0, 100)
        @Expect(v.getPtr() != 0, true)
        v.delete()
    }

    @TestCase
    func testIntValidatorRange() {
        let v = QIntValidator(10, 90)
        @Expect(v.bottom(), 10)
        @Expect(v.top(), 90)
        v.delete()
    }

    @TestCase
    func testIntValidatorSetRange() {
        let v = QIntValidator(0, 100)
        v.setRange(20, 80)
        @Expect(v.bottom(), 20)
        @Expect(v.top(), 80)
        v.delete()
    }

    @TestCase
    func testDoubleValidatorCreate() {
        let v = QDoubleValidator(0.0, 100.0, 2)
        @Expect(v.getPtr() != 0, true)
        v.delete()
    }

    @TestCase
    func testDoubleValidatorRange() {
        let v = QDoubleValidator(10.0, 90.0, 3)
        @Expect(v.bottom(), 10.0)
        @Expect(v.top(), 90.0)
        @Expect(v.decimals(), 3)
        v.delete()
    }

    @TestCase
    func testRegExpValidatorCreate() {
        let v = QRegExpValidator("[0-9]+")
        @Expect(v.getPtr() != 0, true)
        v.delete()
    }

    @TestCase
    func testRegExpValidatorSetPattern() {
        let v = QRegExpValidator("[a-z]+")
        v.setPattern("[A-Z]+")
        @Expect(v.getPtr() != 0, true)
        v.delete()
    }

    @TestCase
    func testSetValidatorOnLineEdit() {
        let edit = QLineEdit()
        let v = QIntValidator(0, 100)
        setLineEditValidator(edit, v)
        @Assert(edit.isValid())
        edit.close()
        v.delete()
    }
}

// =====================================================================
// QSplashScreen 测试
// =====================================================================
@Test
class QSplashScreenTests {
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
        let splash = QSplashScreen()
        @Expect(splash.getPtr() != 0, true)
        splash.delete()
    }

    @TestCase
    func testShowMessage() {
        let splash = QSplashScreen()
        splash.showMessage("Loading...")
        let msg = splash.message()
        @Expect(msg, "Loading...")
        splash.delete()
    }

    @TestCase
    func testClearMessage() {
        let splash = QSplashScreen()
        splash.showMessage("Loading...")
        splash.clearMessage()
        let msg = splash.message()
        @Expect(msg, "")
        splash.delete()
    }

    @TestCase
    func testShowMessageWithAlignment() {
        let splash = QSplashScreen()
        splash.showMessage("Starting...", 0x0084)
        let msg = splash.message()
        @Expect(msg, "Starting...")
        splash.delete()
    }

    @TestCase
    func testDoubleDelete() {
        let splash = QSplashScreen()
        splash.delete()
        splash.delete()
        @Assert(true)
    }
}

// =====================================================================
// QLCDNumber 测试
// =====================================================================
@Test
class QLCDNumberTests {
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
        let lcd = QLCDNumber()
        @Expect(lcd.getPtr() != 0, true)
        lcd.close()
    }

    @TestCase
    func testCreateWithDigits() {
        let lcd = QLCDNumber(6)
        @Expect(lcd.getPtr() != 0, true)
        @Expect(lcd.digitCount(), 6)
        lcd.close()
    }

    @TestCase
    func testDisplayInt() {
        let lcd = QLCDNumber()
        lcd.displayInt(42)
        @Expect(lcd.value(), 42.0)
        lcd.close()
    }

    @TestCase
    func testSetMode() {
        let lcd = QLCDNumber()
        lcd.setMode(LCDMode.hex())
        @Expect(lcd.mode(), LCDMode.hex())
        lcd.close()
    }

    @TestCase
    func testSetSegmentStyle() {
        let lcd = QLCDNumber()
        lcd.setSegmentStyle(LCDSegmentStyle.filled())
        @Expect(lcd.segmentStyle(), LCDSegmentStyle.filled())
        lcd.close()
    }

    // ===== QtResource 测试 =====

    @TestCase
    func testClose() {
        let lcd = QLCDNumber()
        @Expect(lcd.isClosed(), false)
        @Expect(lcd.isValid(), true)
        lcd.close()
        @Expect(lcd.isClosed(), true)
        @Expect(lcd.isValid(), false)
    }

    @TestCase
    func testDoubleClose() {
        let lcd = QLCDNumber()
        lcd.close()
        lcd.close()  // 安全
        @Assert(true)
    }

    @TestCase
    func testOperationsAfterClose() {
        let lcd = QLCDNumber()
        lcd.close()
        @ExpectThrows[ResourceDisposedException](lcd.show())
        @ExpectThrows[ResourceDisposedException](lcd.hide())
        @ExpectThrows[ResourceDisposedException](lcd.displayInt(42))
        @ExpectThrows[ResourceDisposedException](lcd.value())
    }

    @TestCase
    func testDeleteAfterClose() {
        let lcd = QLCDNumber()
        lcd.close()
        lcd.delete()  // 安全
        @Assert(true)
    }
}

// =====================================================================
// QToolButton 测试
// =====================================================================
@Test
class QToolButtonTests {
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
        let btn = QToolButton()
        @Expect(btn.getPtr() != 0, true)
        btn.close()
    }

    @TestCase
    func testSetText() {
        let btn = QToolButton()
        btn.setText("Action")
        @Assert(btn.isValid())
        btn.close()
    }

    @TestCase
    func testSetIconFromPath() {
        let btn = QToolButton()
        btn.setIconFromPath("")
        @Assert(btn.isValid())
        btn.close()
    }

    @TestCase
    func testSetToolButtonStyle() {
        let btn = QToolButton()
        btn.setToolButtonStyle(ToolButtonTextBesideIcon)
        @Expect(btn.toolButtonStyle(), ToolButtonTextBesideIcon)
        btn.close()
    }

    @TestCase
    func testSetAutoRaise() {
        let btn = QToolButton()
        btn.setAutoRaise(true)
        @Expect(btn.autoRaise(), true)
        btn.setAutoRaise(false)
        @Expect(btn.isAutoRaise(), false)
        btn.close()
    }

    // ===== QtResource 测试 =====

    @TestCase
    func testClose() {
        let btn = QToolButton()
        @Expect(btn.isClosed(), false)
        @Expect(btn.isValid(), true)
        btn.close()
        @Expect(btn.isClosed(), true)
        @Expect(btn.isValid(), false)
    }

    @TestCase
    func testDoubleClose() {
        let btn = QToolButton()
        btn.close()
        btn.close()  // 安全
        @Assert(true)
    }

    @TestCase
    func testOperationsAfterClose() {
        let btn = QToolButton()
        btn.close()
        @ExpectThrows[ResourceDisposedException](btn.show())
        @ExpectThrows[ResourceDisposedException](btn.hide())
        @ExpectThrows[ResourceDisposedException](btn.setText("test"))
        @ExpectThrows[ResourceDisposedException](btn.setIconFromPath(""))
    }

    @TestCase
    func testDeleteAfterClose() {
        let btn = QToolButton()
        btn.close()
        btn.delete()  // 安全
        @Assert(true)
    }
}

// =====================================================================
// QSplitter 测试
// =====================================================================
@Test
class QSplitterTests {
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
        let splitter = QSplitter(0)
        @Expect(splitter.getPtr() != 0, true)
        splitter.close()
    }

    @TestCase
    func testCreateHorizontal() {
        let splitter = QSplitter.createHorizontal(0)
        @Expect(splitter.getPtr() != 0, true)
        splitter.close()
    }

    @TestCase
    func testCreateVertical() {
        let splitter = QSplitter.createVertical(0)
        @Expect(splitter.getPtr() != 0, true)
        splitter.close()
    }

    @TestCase
    func testSetEnabled() {
        let splitter = QSplitter(0)
        splitter.setEnabled(false)
        @Expect(splitter.isEnabled(), false)
        splitter.setEnabled(true)
        @Expect(splitter.isEnabled(), true)
        splitter.close()
    }

    @TestCase
    func testSetStyleSheet() {
        let splitter = QSplitter(0)
        splitter.setStyleSheet("QSplitter::handle { background: red }")
        @Assert(splitter.isValid())
        splitter.close()
    }

    @TestCase
    func testSetMinimumSize() {
        let splitter = QSplitter(0)
        splitter.setMinimumSize(200, 100)
        @Assert(splitter.isValid())
        splitter.close()
    }

    @TestCase
    func testSetMaximumSize() {
        let splitter = QSplitter(0)
        splitter.setMaximumSize(800, 600)
        @Assert(splitter.isValid())
        splitter.close()
    }

    @TestCase
    func testSetOrientation() {
        let splitter = QSplitter(0)
        splitter.setOrientation(SplitterOrientation.Vertical)
        @Expect(splitter.orientation(), SplitterOrientation.Vertical)
        splitter.setOrientation(SplitterOrientation.Horizontal)
        @Expect(splitter.orientation(), SplitterOrientation.Horizontal)
        splitter.close()
    }

    @TestCase
    func testSetHandleWidth() {
        let splitter = QSplitter(0)
        splitter.setHandleWidth(5)
        @Expect(splitter.handleWidth(), 5)
        splitter.close()
    }

    @TestCase
    func testClose() {
        let splitter = QSplitter(0)
        @Expect(splitter.isClosed(), false)
        @Expect(splitter.isValid(), true)
        splitter.close()
        @Expect(splitter.isClosed(), true)
        @Expect(splitter.isValid(), false)
    }

    @TestCase
    func testDoubleClose() {
        let splitter = QSplitter(0)
        splitter.close()
        splitter.close()  // 安全
        @Assert(true)
    }

    @TestCase
    func testOperationsAfterClose() {
        let splitter = QSplitter(0)
        splitter.close()
        @ExpectThrows[ResourceDisposedException](splitter.show())
        @ExpectThrows[ResourceDisposedException](splitter.hide())
        @ExpectThrows[ResourceDisposedException](splitter.addWidget(0))
        @ExpectThrows[ResourceDisposedException](splitter.count())
        @ExpectThrows[ResourceDisposedException](splitter.setOrientation(1))
        @ExpectThrows[ResourceDisposedException](splitter.setEnabled(false))
        @ExpectThrows[ResourceDisposedException](splitter.setStyleSheet(""))
        @ExpectThrows[ResourceDisposedException](splitter.setMinimumSize(100, 50))
    }

    // 任务 4：insertWidget/replaceWidget/setOpaqueResize/setSizes/sizes/saveState/restoreState
    @TestCase
    func testInsertWidget() {
        let splitter = QSplitter.createHorizontal(0)
        let p1 = QLabel()
        let p2 = QLabel()
        splitter.addWidget(p1.getPtr())
        splitter.insertWidget(0, p2.getPtr())  // 在头部插入
        @Expect(splitter.count(), 2)
        p1.close()
        p2.close()
        splitter.close()
    }

    @TestCase
    func testReplaceWidget() {
        let splitter = QSplitter.createHorizontal(0)
        let p1 = QLabel()
        let p2 = QLabel()
        splitter.addWidget(p1.getPtr())
        let oldPtr = splitter.replaceWidget(0, p2.getPtr())
        @Expect(oldPtr != 0, true)  // 返回被替换的 p1 指针
        @Expect(splitter.count(), 1)
        p1.close()
        p2.close()
        splitter.close()
    }

    @TestCase
    func testSetOpaqueResize() {
        let splitter = QSplitter(0)
        splitter.setOpaqueResize(false)
        @Assert(splitter.isValid())
        splitter.setOpaqueResize(true)
        splitter.close()
    }

    @TestCase
    func testSetSizes() {
        let splitter = QSplitter.createHorizontal(0)
        let p1 = QLabel()
        let p2 = QLabel()
        splitter.addWidget(p1.getPtr())
        splitter.addWidget(p2.getPtr())
        splitter.setSizes([100, 200])
        let s = splitter.sizes()
        @Expect(s.size, 2)
        // 比例应近似 100:200（实际值由 Qt 分配，验证总数非 0）
        @Expect(s[0] + s[1] > 0, true)
        p1.close()
        p2.close()
        splitter.close()
    }

    @TestCase
    func testSizes() {
        let splitter = QSplitter.createHorizontal(0)
        let p1 = QLabel()
        let p2 = QLabel()
        splitter.addWidget(p1.getPtr())
        splitter.addWidget(p2.getPtr())
        let s = splitter.sizes()
        @Expect(s.size, 2)
        p1.close()
        p2.close()
        splitter.close()
    }

    @TestCase
    func testSaveState() {
        let splitter = QSplitter.createHorizontal(0)
        let p1 = QLabel()
        let p2 = QLabel()
        splitter.addWidget(p1.getPtr())
        splitter.addWidget(p2.getPtr())
        let state = splitter.saveState()
        @Expect(state.size > 0, true)  // 非空状态字节
        p1.close()
        p2.close()
        splitter.close()
    }

    @TestCase
    func testSaveAndRestoreState() {
        let splitter = QSplitter.createHorizontal(0)
        let p1 = QLabel()
        let p2 = QLabel()
        splitter.addWidget(p1.getPtr())
        splitter.addWidget(p2.getPtr())
        splitter.setSizes([100, 300])
        let state = splitter.saveState()
        // 恢复到新 splitter
        let splitter2 = QSplitter.createHorizontal(0)
        let q1 = QLabel()
        let q2 = QLabel()
        splitter2.addWidget(q1.getPtr())
        splitter2.addWidget(q2.getPtr())
        let ok = splitter2.restoreState(state)
        @Expect(ok, true)
        q1.close()
        q2.close()
        splitter2.close()
        p1.close()
        p2.close()
        splitter.close()
    }
}
