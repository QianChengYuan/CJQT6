# CJQT6测试编写规范

## 一、测试文件组织

### 1.1 文件命名

- 测试文件名：`<module>_test.cj`
- 示例：`color_test.cj`、`widgets_test.cj`
- 位置：与源文件同目录

### 1.2 包声明

```cangjie
package cjqt6.widgets

// 测试模式下 unittest 和 unittest.testmacro 自动导入
```

---

## 二、测试类结构

### 2.1 基本结构

```cangjie
@Test
class MyTests {
    @TestCase
    func testSomething() {
        // 测试代码
    }
}
```

### 2.2 带GUI环境的测试类

```cangjie
@Test
class MyWidgetTests {
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
    
    @BeforeEach
    func setup() {
        // 每个测试前执行
    }
    
    @AfterEach
    func teardown() {
        // 每个测试后执行
    }
    
    @TestCase
    func testCreate() {
        // 测试代码
    }
}
```

---

## 三、断言使用

### 3.1 相等性断言

```cangjie
// 软失败（继续执行）
@Expect(actual, expected)

// 快速失败（立即停止）
@Assert(actual, expected)
```

### 3.2 布尔断言

```cangjie
@Expect(widget.isValid())
@Assert(value > 0)
```

### 3.3 异常断言

```cangjie
@ExpectThrows[ResourceDisposedException](widget.show())
@AssertThrows[NullPointerException](nullPtr.access())
```

### 3.4 浮点数近似相等

```cangjie
@Expect(3.14159, 3.14, delta: 0.01)
```

---

## 四、测试用例分类

### 4.1 构造函数测试

```cangjie
@TestCase
func testCreate() {
    let obj = MyWidget()
    @Assert(obj.isValid())
    @Expect(obj.getPtr() != 0, true)
    obj.close()
}
```

### 4.2 属性测试

```cangjie
@TestCase
func testSetText() {
    let widget = QLabel()
    widget.setText("Hello")
    @Assert(widget.isValid())
    widget.close()
}

@TestCase
func testSetEnabled() {
    let widget = QPushButton()
    widget.setEnabled(false)
    @Expect(widget.isEnabled(), false)
    widget.close()
}
```

### 4.3 方法测试

```cangjie
@TestCase
func testResize() {
    let widget = QWidget()
    widget.resize(200, 100)
    @Expect(widget.width(), 200)
    @Expect(widget.height(), 100)
    widget.close()
}
```

### 4.4 边界值测试

```cangjie
@TestCase
func testBoundaryValues() {
    let spinBox = QSpinBox()
    spinBox.setRange(0, 100)
    
    // 边界值
    spinBox.setValue(0)
    @Expect(spinBox.value(), 0)
    
    spinBox.setValue(100)
    @Expect(spinBox.value(), 100)
    
    // 越界值
    spinBox.setValue(-1)
    @Expect(spinBox.value(), 0)  // 自动调整到最小值
    
    spinBox.close()
}
```

### 4.5 异常情况测试

```cangjie
@TestCase
func testOperationsAfterClose() {
    let widget = QWidget()
    widget.close()
    
    @ExpectThrows[ResourceDisposedException](widget.show())
    @ExpectThrows[ResourceDisposedException](widget.resize(100, 100))
}
```

### 4.6 生命周期测试

```cangjie
@TestCase
func testDoubleClose() {
    let widget = QWidget()
    widget.close()
    widget.close()  // 应该安全
    @Expect(widget.isClosed(), true)
}

@TestCase
func testDeleteCompatibility() {
    let widget = QWidget()
    widget.delete()
    @Expect(widget.isClosed(), true)
}
```

---

## 五、资源管理

### 5.1 显式清理

```cangjie
@TestCase
func testSomething() {
    let widget = QWidget()
    // ... 使用widget ...
    widget.close()  // 或 widget.delete()
}
```

### 5.2 多对象清理

```cangjie
@TestCase
func testMultipleObjects() {
    let w1 = QWidget()
    let w2 = QLabel()
    let w3 = QPushButton()
    
    // ... 测试代码 ...
    
    w3.close()
    w2.close()
    w1.close()
}
```

---

## 六、参数化测试

### 6.1 值驱动

```cangjie
@Test[value in [0, 50, 100]]
func testSpinBoxValues(value: Int32) {
    let spinBox = QSpinBox()
    spinBox.setRange(0, 100)
    spinBox.setValue(value)
    @Expect(spinBox.value(), value)
    spinBox.close()
}
```

### 6.2 范围驱动

```cangjie
@Test[x in 0..10]
func testRange(x: Int64) {
    // x 从 0 到 9
}
```

---

## 七、测试模板

### 7.1 简单测试模板

```cangjie
package cjqt6.module

@Test
class MyTests {
    @TestCase
    func testFeature() {
        // Arrange
        let obj = MyObject()
        
        // Act
        obj.doSomething()
        
        // Assert
        @Expect(obj.isValid())
        
        // Cleanup
        obj.close()
    }
}
```

### 7.2 GUI测试模板

```cangjie
package cjqt6.widgets

@Test
class MyWidgetTests {
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
        let widget = MyWidget()
        @Assert(widget.isValid())
        widget.close()
    }
    
    @TestCase
    func testMethod() {
        let widget = MyWidget()
        // ... 测试代码 ...
        widget.close()
    }
}
```

---

## 八、最佳实践

### 8.1 单一职责

每个测试方法只测试一个功能点。

### 8.2 命名清晰

```cangjie
// 好的命名
func testSetText()
func testResizeBoundary()
func testOperationsAfterClose()

// 不好的命名
func test1()
func testWidget()
```

### 8.3 避免依赖

测试之间不应有依赖关系，每个测试应独立运行。

### 8.4 快速执行

单个测试应在30秒内完成。

---

**文档版本**：1.0  
**更新日期**：2026-05-09
