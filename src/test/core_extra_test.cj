package cjqt6.test

import cjqt6.core.*
import cjqt6.views.*
import std.math.*
import std.unittest.*

// =====================================================================
// 全局状态（回调测试使用：CFunc 不捕获局部变量，只能用全局变量）
// =====================================================================
var gThreadFinished: Bool = false
var gRunnableRan: Bool = false

// =====================================================================
// QItemSelectionModel 测试（使用 QStandardItemModel 提供数据模型）
// =====================================================================
@Test
class QItemSelectionModelTests {

    @TestCase
    func testCreateAndClose() {
        let model = QStandardItemModel(3, 3)
        let sel = QItemSelectionModel(model.getPtr())
        @Expect(sel.getPtr() != 0, true)
        @Expect(sel.hasSelection(), false)
        @Expect(sel.currentIndexRow(), -1)
        @Expect(sel.currentIndexCol(), -1)
        sel.close()
        model.delete()
    }

    @TestCase
    func testSetCurrentIndex() {
        let model = QStandardItemModel(3, 3)
        model.setItem(1, 0, "B")
        let sel = QItemSelectionModel(model.getPtr())
        sel.setCurrentIndex(1, 0, SelectionFlag.clearAndSelect())
        @Expect(sel.currentIndexRow(), 1)
        @Expect(sel.currentIndexCol(), 0)
        @Expect(sel.isSelected(1, 0), true)
        @Expect(sel.hasSelection(), true)
        sel.close()
        model.delete()
    }

    @TestCase
    func testSelectRow() {
        let model = QStandardItemModel(3, 3)
        let sel = QItemSelectionModel(model.getPtr())
        sel.select(0, 0, SelectionFlag.select() | SelectionFlag.rows())
        @Expect(sel.isRowSelected(0), true)
        @Expect(sel.isSelected(0, 0), true)
        @Expect(sel.isSelected(0, 1), true)
        @Expect(sel.isSelected(0, 2), true)
        @Expect(sel.selectedRowsCount(), 1)
        @Expect(sel.selectedRowAt(0), 0)
        sel.close()
        model.delete()
    }

    @TestCase
    func testSelectMultipleCells() {
        let model = QStandardItemModel(3, 3)
        let sel = QItemSelectionModel(model.getPtr())
        sel.select(0, 0, SelectionFlag.select())
        sel.select(1, 1, SelectionFlag.select())
        @Expect(sel.isSelected(0, 0), true)
        @Expect(sel.isSelected(1, 1), true)
        @Expect(sel.isSelected(2, 2), false)
        @Expect(sel.hasSelection(), true)
        sel.close()
        model.delete()
    }

    @TestCase
    func testDeselect() {
        let model = QStandardItemModel(3, 3)
        let sel = QItemSelectionModel(model.getPtr())
        sel.select(1, 0, SelectionFlag.select())
        @Expect(sel.isSelected(1, 0), true)
        sel.select(1, 0, SelectionFlag.deselect())
        @Expect(sel.isSelected(1, 0), false)
        @Expect(sel.hasSelection(), false)
        sel.close()
        model.delete()
    }

    @TestCase
    func testClearSelectionPreservesCurrent() {
        let model = QStandardItemModel(3, 3)
        let sel = QItemSelectionModel(model.getPtr())
        sel.setCurrentIndex(1, 0, SelectionFlag.clearAndSelect())
        @Expect(sel.hasSelection(), true)
        sel.clearSelection()
        @Expect(sel.hasSelection(), false)
        @Expect(sel.isSelected(1, 0), false)
        @Expect(sel.currentIndexRow(), 1)
        sel.close()
        model.delete()
    }

    @TestCase
    func testClear() {
        let model = QStandardItemModel(3, 3)
        let sel = QItemSelectionModel(model.getPtr())
        sel.setCurrentIndex(1, 0, SelectionFlag.clearAndSelect())
        sel.clear()
        @Expect(sel.hasSelection(), false)
        @Expect(sel.currentIndexRow(), -1)
        @Expect(sel.currentIndexCol(), -1)
        sel.close()
        model.delete()
    }

    @TestCase
    func testModelPointer() {
        let model = QStandardItemModel(3, 3)
        let sel = QItemSelectionModel(model.getPtr())
        @Expect(sel.model(), model.getPtr())
        sel.close()
        model.delete()
    }

    @TestCase
    func testOperationsAfterClose() {
        let model = QStandardItemModel(3, 3)
        let sel = QItemSelectionModel(model.getPtr())
        sel.close()
        @ExpectThrows[ResourceDisposedException](sel.currentIndexRow())
        @ExpectThrows[ResourceDisposedException](sel.isSelected(0, 0))
        @ExpectThrows[ResourceDisposedException](sel.hasSelection())
        @ExpectThrows[ResourceDisposedException](sel.setCurrentIndex(0, 0, SelectionFlag.select()))
        model.delete()
    }
}

// =====================================================================
// QJsonDocument 测试
// =====================================================================
@Test
class QJsonDocumentTests {

    @TestCase
    func testParseObject() {
        let doc = QJsonDocument("{\"name\":\"cjqt6\"}")
        @Expect(doc.isNull(), false)
        @Expect(doc.isObject(), true)
        @Expect(doc.isArray(), false)
        doc.close()
    }

    @TestCase
    func testParseArray() {
        let doc = QJsonDocument("[1,2,3]")
        @Expect(doc.isArray(), true)
        @Expect(doc.isObject(), false)
        doc.close()
    }

    @TestCase
    func testToJsonRoundTrip() {
        let doc = QJsonDocument("{\"name\":\"cjqt6\"}")
        @Expect(doc.toJson(0), "{\"name\":\"cjqt6\"}")
        doc.close()
    }

    @TestCase
    func testParseErrorThrows() {
        // 解析失败时底层返回 0，访问任何方法都会抛 ResourceDisposedException
        let doc = QJsonDocument("{invalid json")
        @ExpectThrows[ResourceDisposedException](doc.isNull())
        doc.close()
    }

    @TestCase
    func testObjectAccess() {
        let doc = QJsonDocument("{\"name\":\"cjqt6\",\"count\":2}")
        let obj = doc.object()
        @Expect(obj.contains("name"), true)
        @Expect(obj.contains("nope"), false)
        @Expect(obj.size(), 2)
        @Expect(obj.isEmpty(), false)
        // QJsonObject 的键按字典序排列（Qt 语义），"count" < "name"
        @Expect(obj.keyAt(0), "count")
        @Expect(obj.keyAt(1), "name")
        obj.close()
        doc.close()
    }

    @TestCase
    func testArrayAccess() {
        let doc = QJsonDocument("[1,2,3]")
        let arr = doc.array()
        @Expect(arr.size(), 3)
        @Expect(arr.isEmpty(), false)
        arr.close()
        doc.close()
    }

    @TestCase
    func testOperationsAfterClose() {
        let doc = QJsonDocument("{\"a\":1}")
        doc.close()
        @ExpectThrows[ResourceDisposedException](doc.toJson(0))
        @ExpectThrows[ResourceDisposedException](doc.isNull())
        @ExpectThrows[ResourceDisposedException](doc.isObject())
    }
}

// =====================================================================
// QJsonObject 测试
// =====================================================================
@Test
class QJsonObjectTests {

    @TestCase
    func testCreateEmpty() {
        let obj = QJsonObject()
        @Expect(obj.isEmpty(), true)
        @Expect(obj.size(), 0)
        obj.close()
    }

    @TestCase
    func testInsertAndContains() {
        let obj = QJsonObject()
        obj.insert("name", QJsonValue.createString("cjqt6"))
        @Expect(obj.contains("name"), true)
        @Expect(obj.contains("nope"), false)
        @Expect(obj.size(), 1)
        @Expect(obj.isEmpty(), false)
        obj.close()
    }

    @TestCase
    func testValueRoundTrip() {
        let obj = QJsonObject()
        obj.insert("name", QJsonValue.createString("cjqt6"))
        let v = obj.value("name")
        @Expect(v.isString(), true)
        @Expect(v.toString(), "cjqt6")
        v.close()
        obj.close()
    }

    @TestCase
    func testRemove() {
        let obj = QJsonObject()
        obj.insert("a", QJsonValue.createInt(1))
        obj.insert("b", QJsonValue.createInt(2))
        @Expect(obj.size(), 2)
        obj.remove("a")
        @Expect(obj.contains("a"), false)
        @Expect(obj.size(), 1)
        obj.close()
    }

    @TestCase
    func testKeyAt() {
        let obj = QJsonObject()
        obj.insert("first", QJsonValue.createInt(1))
        obj.insert("second", QJsonValue.createInt(2))
        @Expect(obj.keyAt(0), "first")
        @Expect(obj.keyAt(1), "second")
        obj.close()
    }

    @TestCase
    func testOperationsAfterClose() {
        let obj = QJsonObject()
        obj.close()
        @ExpectThrows[ResourceDisposedException](obj.contains("k"))
        @ExpectThrows[ResourceDisposedException](obj.size())
        @ExpectThrows[ResourceDisposedException](obj.isEmpty())
    }
}

// =====================================================================
// QJsonArray 测试
// =====================================================================
@Test
class QJsonArrayTests {

    @TestCase
    func testCreateEmpty() {
        let arr = QJsonArray()
        @Expect(arr.isEmpty(), true)
        @Expect(arr.size(), 0)
        arr.close()
    }

    @TestCase
    func testAppendAndAt() {
        let arr = QJsonArray()
        arr.append(QJsonValue.createString("a"))
        arr.append(QJsonValue.createInt(7))
        @Expect(arr.size(), 2)
        let v0 = arr.at(0)
        @Expect(v0.isString(), true)
        @Expect(v0.toString(), "a")
        v0.close()
        let v1 = arr.at(1)
        @Expect(v1.toInt(0), 7)
        v1.close()
        arr.close()
    }

    @TestCase
    func testRemoveAt() {
        let arr = QJsonArray()
        arr.append(QJsonValue.createString("a"))
        arr.append(QJsonValue.createString("b"))
        arr.removeAt(0)
        @Expect(arr.size(), 1)
        let v = arr.at(0)
        @Expect(v.toString(), "b")
        v.close()
        arr.close()
    }
}

// =====================================================================
// QJsonValue 测试
// =====================================================================
@Test
class QJsonValueTests {

    @TestCase
    func testCreateNull() {
        let v = QJsonValue.createNull()
        @Expect(v.isNull(), true)
        @Expect(v.valueType(), JsonType.nullType())
        v.close()
    }

    @TestCase
    func testCreateString() {
        let v = QJsonValue.createString("hello")
        @Expect(v.isString(), true)
        @Expect(v.toString(), "hello")
        @Expect(v.valueType(), JsonType.stringType())
        v.close()
    }

    @TestCase
    func testCreateInt() {
        let v = QJsonValue.createInt(42)
        // 整数值在 Qt 的 QJsonValue 中类型为 Double
        @Expect(v.isDouble(), true)
        @Expect(v.toInt(0), 42)
        @Expect(v.valueType(), JsonType.doubleType())
        v.close()
    }

    @TestCase
    func testCreateDouble() {
        let v = QJsonValue.createDouble(3.14)
        @Expect(v.isDouble(), true)
        let d = v.toDouble(0.0)
        @Expect(abs(d - 3.14) < 0.0001, true)
        v.close()
    }

    @TestCase
    func testCreateBool() {
        let v = QJsonValue.createBool(true)
        @Expect(v.isBool(), true)
        @Expect(v.toBool(false), true)
        @Expect(v.valueType(), JsonType.boolType())
        v.close()
    }

    @TestCase
    func testToIntDefault() {
        // 非数值类型返回默认值
        let v = QJsonValue.createString("not a number")
        @Expect(v.toInt(99), 99)
        v.close()
    }

    @TestCase
    func testOperationsAfterClose() {
        let v = QJsonValue.createString("x")
        v.close()
        @ExpectThrows[ResourceDisposedException](v.isString())
        @ExpectThrows[ResourceDisposedException](v.toString())
    }
}

// =====================================================================
// QThread 测试
// =====================================================================
@Test
class QThreadTests {

    @TestCase
    func testCreateAndClose() {
        let thread = QThread()
        @Expect(thread.getPtr() != 0, true)
        @Expect(thread.isFinished(), false)
        thread.close()
        @Expect(thread.getPtr(), 0)
    }

    @TestCase
    func testDoubleClose() {
        let thread = QThread()
        thread.close()
        thread.close()  // 安全
        @Assert(true)
    }

    @TestCase
    func testStackSize() {
        let thread = QThread()
        thread.setStackSize(1048576)
        @Expect(thread.stackSize() >= 1048576, true)
        thread.close()
    }

    @TestCase
    func testStartQuitWait() {
        let thread = QThread()
        thread.start()
        QThread.msleep(50)
        @Expect(thread.isRunning(), true)
        thread.quit()
        let done = thread.waitTimeout(2000)
        @Expect(done, true)
        @Expect(thread.isFinished(), true)
        @Expect(thread.isRunning(), false)
        thread.close()
    }

    @TestCase
    func testRequestInterruption() {
        // Qt 语义：requestInterruption() 仅在线程运行中才生效
        let thread = QThread()
        thread.start()
        QThread.msleep(50)
        @Expect(thread.isRunning(), true)
        @Expect(thread.isInterruptionRequested(), false)
        thread.requestInterruption()
        @Expect(thread.isInterruptionRequested(), true)
        thread.quit()
        let done = thread.waitTimeout(2000)
        @Expect(done, true)
        thread.close()
    }

    @TestCase
    func testStaticMethods() {
        @Expect(QThread.idealThreadCount() > 0, true)
        @Expect(QThread.currentThreadPtr() != 0, true)
        QThread.msleep(5)
        @Assert(true)
    }

    @TestCase
    func testFinishedCallback() {
        gThreadFinished = false
        let thread = QThread()
        thread.setOnFinished({ => gThreadFinished = true })
        thread.start()
        QThread.msleep(20)
        thread.quit()
        let done = thread.waitTimeout(2000)
        @Expect(done, true)
        @Expect(gThreadFinished, true)
        thread.close()
    }

    @TestCase
    func testOperationsAfterClose() {
        let thread = QThread()
        thread.close()
        @ExpectThrows[ResourceDisposedException](thread.start())
        @ExpectThrows[ResourceDisposedException](thread.isRunning())
        @ExpectThrows[ResourceDisposedException](thread.isFinished())
    }
}

// =====================================================================
// QThreadPool / QRunnable 测试
// =====================================================================
@Test
class QThreadPoolTests {

    @TestCase
    func testGlobalInstance() {
        let pool = QThreadPool.globalInstance()
        @Expect(pool.getPtr() != 0, true)
        @Expect(pool.maxThreadCount() >= 1, true)
        @Expect(pool.activeThreadCount() >= 0, true)
    }

    @TestCase
    func testMaxThreadCountRoundTrip() {
        let pool = QThreadPool.globalInstance()
        pool.setMaxThreadCount(4)
        @Expect(pool.maxThreadCount(), 4)
        pool.setMaxThreadCount(2)
        @Expect(pool.maxThreadCount(), 2)
    }

    @TestCase
    func testExpiryTimeoutRoundTrip() {
        let pool = QThreadPool.globalInstance()
        pool.setExpiryTimeout(1000)
        @Expect(pool.expiryTimeout(), 1000)
        pool.setExpiryTimeout(30000)
    }

    @TestCase
    func testRunRunnable() {
        gRunnableRan = false
        let runnable = QRunnable({ => gRunnableRan = true })
        let pool = QThreadPool.globalInstance()
        pool.start(runnable)
        let done = pool.waitForDone()
        @Expect(done, true)
        @Expect(gRunnableRan, true)
        // 注意：CjRunnable 设置了 autoDelete=true，任务执行后由线程池自动释放，
        // 此处不能再调用 runnable.close()
    }

    @TestCase
    func testWaitForDoneTimeout() {
        let pool = QThreadPool.globalInstance()
        let done = pool.waitForDoneTimeout(100)
        @Expect(done, true)
    }
}
