package CJQT6.core

// 测试模式下 unittest 和 unittest.testmacro 自动导入

// ============================================================
// 异常类测试（不需要显示环境）
// ============================================================

@Test
class ExceptionTests {
    
    @TestCase
    func testQtException() {
        let ex = QtException("test error")
        @Expect(ex.message, "test error")
    }
    
    @TestCase
    func testResourceDisposedException() {
        let ex = ResourceDisposedException("widget disposed")
        @Expect(ex.message, "widget disposed")
    }
    
    @TestCase
    func testNullPointerException() {
        let ex = NullPointerException("null ptr")
        @Expect(ex.message, "null ptr")
    }
    
    @TestCase
    func testCreateFailedException() {
        let ex = CreateFailedException("create failed")
        @Expect(ex.message, "create failed")
    }
    
    @TestCase
    func testExceptionInheritance() {
        let ex1 = ResourceDisposedException("test")
        @Assert(ex1 is QtException)
        
        let ex2 = NullPointerException("test")
        @Assert(ex2 is QtException)
        
        let ex3 = CreateFailedException("test")
        @Assert(ex3 is QtException)
    }
}

// ============================================================
// 辅助函数测试（不需要显示环境）
// ============================================================

@Test
class HelperFunctionTests {
    
    @TestCase
    func testSafeExecuteSuccess() {
        let result = safeExecute({ => 42})
        match (result) {
            case Some(v) => @Expect(v, 42)
            case None => @Fail("should return Some")
        }
    }
    
    @TestCase
    func testSafeExecuteException() {
        let result = safeExecute({ =>
            throw IllegalArgumentException("test error")
            0
        })
        match (result) {
            case Some(_) => @Fail("should return None")
            case None => @Assert(true)
        }
    }
    
    @TestCase
    func testSafeRunSuccess() {
        // safeRun 成功时返回 true
        let result = safeRun({ => })
        @Expect(result, true)
    }
    
    @TestCase
    func testSafeRunException() {
        let result = safeRun({ =>
            throw IllegalArgumentException("test error")
        })
        @Expect(result, false)
    }
}

// ============================================================
// QWidget 测试（需要显示环境）
// 注意：在 CI 环境中使用 xvfb-run 运行测试
// ============================================================

@Test
class QWidgetTests {
    
    @TestCase
    func testCreate() {
        let widget = QWidget()
        @Assert(widget.isValid())
        @Expect(widget.isClosed(), false)
        @Expect(widget.getPtr() != 0, true)
        widget.close()
    }
    
    @TestCase
    func testClose() {
        let widget = QWidget()
        @Expect(widget.isClosed(), false)
        widget.close()
        @Expect(widget.isClosed(), true)
        @Expect(widget.isValid(), false)
        @Expect(widget.getPtr(), 0)
    }
    
    @TestCase
    func testDeleteCompatibility() {
        let widget = QWidget()
        @Expect(widget.isValid(), true)
        widget.delete()
        @Expect(widget.isClosed(), true)
    }
    
    @TestCase
    func testDoubleClose() {
        let widget = QWidget()
        widget.close()
        widget.close()
        @Expect(widget.isClosed(), true)
    }
    
    @TestCase
    func testCheckValid() {
        let widget = QWidget()
        widget.checkValid()
        
        widget.close()
        @ExpectThrows[ResourceDisposedException](widget.checkValid())
    }
    
    @TestCase
    func testOperationsAfterClose() {
        let widget = QWidget()
        widget.close()
        
        @ExpectThrows[ResourceDisposedException](widget.show())
        @ExpectThrows[ResourceDisposedException](widget.hide())
        @ExpectThrows[ResourceDisposedException](widget.setTitle("test"))
        @ExpectThrows[ResourceDisposedException](widget.resize(100, 100))
    }
}

@Test
class QTimerTests {
    
    @TestCase
    func testCreate() {
        let timer = QTimer()
        @Assert(timer.isValid())
        @Expect(timer.isClosed(), false)
        timer.close()
        @Expect(timer.isClosed(), true)
    }
    
    @TestCase
    func testClose() {
        let timer = QTimer()
        @Expect(timer.isClosed(), false)
        timer.close()
        @Expect(timer.isClosed(), true)
        @Expect(timer.isValid(), false)
    }
    
    @TestCase
    func testOperationsAfterClose() {
        let timer = QTimer()
        timer.close()
        
        @ExpectThrows[ResourceDisposedException](timer.setInterval(1000))
        @ExpectThrows[ResourceDisposedException](timer.start())
        @ExpectThrows[ResourceDisposedException](timer.stop())
    }
}