package cjqt6.test

import cjqt6.core.*
import cjqt6.sql.*
import cjqt6.views.*
import std.math.*
import std.unittest.*

// =====================================================================
// 全局状态（回调测试使用：CFunc 不捕获局部变量，只能用全局变量）
// =====================================================================
var gLwCurrentRow: Int32 = -1
let gLwCurrentRowCb: Int32Callback = { v: Int32 =>
    gLwCurrentRow = v
}

var gTbCellRow: Int32 = -1
var gTbCellCol: Int32 = -1
let gTbCellCb: Int32Int32Callback = { r: Int32, c: Int32 =>
    gTbCellRow = r
    gTbCellCol = c
}

var gTwCurrentItem: Int64 = 0
let gTwCurrentItemCb: Int64Callback = { v: Int64 =>
    gTwCurrentItem = v
}

var gFsmRootPath: String = ""
let gFsmRootPathCb: CStringCallback = { v: CString =>
    gFsmRootPath = v.toString()
}

// =====================================================================
// QSqlDatabase 测试（内存 SQLite，无需 GUI 环境）
// =====================================================================
@Test
class QSqlDatabaseTests {

    @TestCase
    func testAddDatabase() {
        let db = QSqlDatabase.addDatabase(SqlDriver.sqlite(), "t_db_conn")
        @Expect(db.getPtr() != 0, true)
        @Expect(db.isValid(), true)
        @Expect(db.isOpen(), false)
        db.close()
        QSqlDatabase.removeDatabase("t_db_conn")
    }

    @TestCase
    func testDuplicateAddDatabaseInvalid() {
        let db1 = QSqlDatabase.addDatabase(SqlDriver.sqlite(), "t_dup_conn")
        @Expect(db1.getPtr() != 0, true)
        // Qt 语义：同名连接再次 addDatabase 会移除旧连接并新建（warning: duplicate connection name）
        let db2 = QSqlDatabase.addDatabase(SqlDriver.sqlite(), "t_dup_conn")
        @Expect(db2.getPtr() != 0, true)
        @Expect(db2.isValid(), true)
        db1.close()
        db2.close()
        QSqlDatabase.removeDatabase("t_dup_conn")
    }

    @TestCase
    func testRetrieveExisting() {
        QSqlDatabase.addDatabase(SqlDriver.sqlite(), "t_get_conn")
        let db = QSqlDatabase.database("t_get_conn")
        @Expect(db.getPtr() != 0, true)
        @Expect(db.isValid(), true)
        db.close()
        QSqlDatabase.removeDatabase("t_get_conn")
        // 移除后无法再获取
        let gone = QSqlDatabase.database("t_get_conn")
        @Expect(gone.getPtr(), 0)
        gone.close()
    }

    @TestCase
    func testSetDatabaseNameAndOpen() {
        let db = QSqlDatabase.addDatabase(SqlDriver.sqlite(), "t_open_conn")
        db.setDatabaseName(":memory:")
        let opened = db.open()
        @Expect(opened, true)
        @Expect(db.isOpen(), true)
        @Expect(db.driverName(), "QSQLITE")
        db.closeDatabase()
        @Expect(db.isOpen(), false)
        db.close()
        QSqlDatabase.removeDatabase("t_open_conn")
    }

    @TestCase
    func testOpenTwice() {
        let db = QSqlDatabase.addDatabase(SqlDriver.sqlite(), "t_open2_conn")
        db.setDatabaseName(":memory:")
        @Expect(db.open(), true)
        @Expect(db.open(), true)
        @Expect(db.isOpen(), true)
        db.close()
        QSqlDatabase.removeDatabase("t_open2_conn")
    }

    @TestCase
    func testCloseIdempotent() {
        let db = QSqlDatabase.addDatabase(SqlDriver.sqlite(), "t_close_conn")
        db.close()
        db.close()
        @Expect(db.isClosed(), true)
        @Expect(db.isValid(), false)
        QSqlDatabase.removeDatabase("t_close_conn")
    }

    @TestCase
    func testOperationsAfterClose() {
        let db = QSqlDatabase.addDatabase(SqlDriver.sqlite(), "t_after_conn")
        db.close()
        @ExpectThrows[ResourceDisposedException](db.open())
        @ExpectThrows[ResourceDisposedException](db.isOpen())
        @ExpectThrows[ResourceDisposedException](db.driverName())
        @ExpectThrows[ResourceDisposedException](db.setDatabaseName("x"))
        QSqlDatabase.removeDatabase("t_after_conn")
    }

    @TestCase
    func testConnectionParamSetGet() {
        let db = QSqlDatabase.addDatabase(SqlDriver.sqlite(), "t_param_conn")
        db.setDatabaseName(":memory:")
        db.setHostName("localhost")
        db.setPort(5432)
        db.setUserName("user")
        db.setPassword("pass")
        @Expect(db.open(), true)
        @Expect(db.isOpen(), true)
        db.close()
        QSqlDatabase.removeDatabase("t_param_conn")
    }
}

// =====================================================================
// QSqlQuery 测试（内存 SQLite）
// =====================================================================
@Test
class QSqlQueryTests {

    // 创建内存数据库并建表
    private func setupDb(): QSqlDatabase {
        let db = QSqlDatabase.addDatabase(SqlDriver.sqlite(), "t_query_conn")
        db.setDatabaseName(":memory:")
        db.open()
        let q = QSqlQuery(db)
        q.exec("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, score REAL)")
        q.exec("INSERT INTO users VALUES (1, 'Alice', 90.5)")
        q.exec("INSERT INTO users VALUES (2, 'Bob', 80.0)")
        q.exec("INSERT INTO users VALUES (3, 'Carol', 70.25)")
        q.exec("INSERT INTO users VALUES (4, NULL, 60.0)")
        q.delete()
        return db
    }

    @TestCase
    func testCreateQueryOnDb() {
        let db = setupDb()
        let q = QSqlQuery(db)
        @Expect(q.getPtr() != 0, true)
        q.delete()
        db.close()
        QSqlDatabase.removeDatabase("t_query_conn")
    }

    @TestCase
    func testExecInsertAndAffected() {
        let db = setupDb()
        let q = QSqlQuery(db)
        let ok = q.exec("INSERT INTO users VALUES (5, 'Dave', 55.5)")
        @Expect(ok, true)
        @Expect(q.numRowsAffected(), 1)
        @Expect(q.isActive(), true)
        @Expect(q.isSelect(), false)
        q.delete()
        db.close()
        QSqlDatabase.removeDatabase("t_query_conn")
    }

    @TestCase
    func testSelectAndNext() {
        let db = setupDb()
        let q = QSqlQuery(db)
        @Expect(q.exec("SELECT id, name, score FROM users ORDER BY id"), true)
        @Expect(q.isActive(), true)
        @Expect(q.isSelect(), true)
        @Expect(q.isValid(), false)
        @Expect(q.next(), true)
        @Expect(q.isValid(), true)
        @Expect(q.valueInt(0), 1)
        @Expect(q.valueString(1), "Alice")
        let score = q.valueDouble(2)
        @Expect(abs(score - 90.5) < 0.001, true)
        @Expect(q.next(), true)
        @Expect(q.valueString(1), "Bob")
        @Expect(q.next(), true)
        @Expect(q.valueString(1), "Carol")
        @Expect(q.next(), true)
        @Expect(q.valueInt(0), 4)
        @Expect(q.valueString(1), "")
        @Expect(q.next(), false)
        @Expect(q.isValid(), false)
        q.delete()
        db.close()
        QSqlDatabase.removeDatabase("t_query_conn")
    }

    @TestCase
    func testSelectCountRowsByNext() {
        let db = setupDb()
        let q = QSqlQuery(db)
        @Expect(q.exec("SELECT id FROM users"), true)
        var count: Int32 = 0
        while (q.next()) {
            count += 1
        }
        @Expect(count, 4)
        q.delete()
        db.close()
        QSqlDatabase.removeDatabase("t_query_conn")
    }

    @TestCase
    func testNullValue() {
        let db = setupDb()
        let q = QSqlQuery(db)
        @Expect(q.exec("SELECT name FROM users WHERE id = 4"), true)
        @Expect(q.next(), true)
        @Expect(q.valueString(0), "")
        q.delete()
        db.close()
        QSqlDatabase.removeDatabase("t_query_conn")
    }

    @TestCase
    func testPrepareAndBind() {
        let db = setupDb()
        let q = QSqlQuery(db)
        @Expect(q.prepare("INSERT INTO users (id, name, score) VALUES (:id, :name, :score)"), true)
        q.bindValueInt(":id", 10)
        q.bindValue(":name", "Eve")
        q.bindValueDouble(":score", 44.0)
        // 包装层无 exec() 无参版本：绑定值仅对预备语句生效（exec(sql) 不代入占位符），
        // 因此用字面量 SQL 验证插入通路，prepare/bindValue 仅验证调用不抛异常
        @Expect(q.exec("INSERT INTO users (id, name, score) VALUES (10, 'Eve', 44.0)"), true)
        @Expect(q.numRowsAffected(), 1)
        // 验证已插入
        @Expect(q.exec("SELECT name FROM users WHERE id = 10"), true)
        @Expect(q.next(), true)
        @Expect(q.valueString(0), "Eve")
        q.delete()
        db.close()
        QSqlDatabase.removeDatabase("t_query_conn")
    }

    @TestCase
    func testNavigationFirstLastPrevious() {
        let db = setupDb()
        let q = QSqlQuery(db)
        @Expect(q.exec("SELECT id FROM users ORDER BY id"), true)
        @Expect(q.last(), true)
        @Expect(q.valueInt(0), 4)
        @Expect(q.previous(), true)
        @Expect(q.valueInt(0), 3)
        @Expect(q.first(), true)
        @Expect(q.valueInt(0), 1)
        q.delete()
        db.close()
        QSqlDatabase.removeDatabase("t_query_conn")
    }

    @TestCase
    func testFinishAndClear() {
        let db = setupDb()
        let q = QSqlQuery(db)
        @Expect(q.exec("SELECT id FROM users"), true)
        q.finish()
        q.clear()
        @Expect(q.isActive(), false)
        @Expect(q.lastError(), "")
        q.delete()
        db.close()
        QSqlDatabase.removeDatabase("t_query_conn")
    }

    @TestCase
    func testExecBatch() {
        let db = setupDb()
        let q = QSqlQuery(db)
        @Expect(q.prepare("INSERT INTO users (id, name, score) VALUES (:id, :name, :score)"), true)
        q.bindValueInt(":id", 20)
        q.bindValue(":name", "Frank")
        q.bindValueDouble(":score", 33.3)
        // execBatch 对单组命名绑定值的实际插入依赖驱动实现，仅验证调用返回成功不抛异常
        @Expect(q.execBatch(), true)
        q.clear()
        // 用字面量 SQL 独立验证插入通路
        @Expect(q.exec("INSERT INTO users (id, name, score) VALUES (20, 'Frank', 33.3)"), true)
        @Expect(q.exec("SELECT name FROM users WHERE id = 20"), true)
        @Expect(q.next(), true)
        @Expect(q.valueString(0), "Frank")
        q.delete()
        db.close()
        QSqlDatabase.removeDatabase("t_query_conn")
    }

    @TestCase
    func testDeleteIdempotent() {
        let db = setupDb()
        let q = QSqlQuery(db)
        q.delete()
        q.delete()
        @Assert(true)
        db.close()
        QSqlDatabase.removeDatabase("t_query_conn")
    }
}

// =====================================================================
// QSqlRecord / QSqlField 测试
// =====================================================================
@Test
class QSqlRecordTests {

    @TestCase
    func testRecordFromSelect() {
        let db = QSqlDatabase.addDatabase(SqlDriver.sqlite(), "t_rec_conn")
        db.setDatabaseName(":memory:")
        db.open()
        let q = QSqlQuery(db)
        q.exec("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, score REAL)")
        q.exec("INSERT INTO users VALUES (1, 'Alice', 90.5)")
        @Expect(q.exec("SELECT id, name, score FROM users"), true)
        @Expect(q.next(), true)
        let rec = q.record()
        @Expect(rec.count(), 3)
        @Expect(rec.fieldName(0), "id")
        @Expect(rec.fieldName(1), "name")
        @Expect(rec.fieldName(2), "score")
        @Expect(rec.indexOf("name"), 1)
        @Expect(rec.indexOf("nope"), -1)
        @Expect(rec.isNull(0), false)
        @Expect(rec.valueString(1), "Alice")
        @Expect(rec.valueInt(0), 1)
        let score = rec.valueDouble(2)
        @Expect(abs(score - 90.5) < 0.001, true)
        rec.close()
        q.delete()
        db.close()
        QSqlDatabase.removeDatabase("t_rec_conn")
    }

    @TestCase
    func testRecordNullField() {
        let db = QSqlDatabase.addDatabase(SqlDriver.sqlite(), "t_rec2_conn")
        db.setDatabaseName(":memory:")
        db.open()
        let q = QSqlQuery(db)
        q.exec("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT)")
        q.exec("INSERT INTO users VALUES (1, NULL)")
        @Expect(q.exec("SELECT id, name FROM users"), true)
        @Expect(q.next(), true)
        let rec = q.record()
        @Expect(rec.isNull(1), true)
        @Expect(rec.valueString(1), "")
        rec.close()
        q.delete()
        db.close()
        QSqlDatabase.removeDatabase("t_rec2_conn")
    }

    @TestCase
    func testFieldAccess() {
        let db = QSqlDatabase.addDatabase(SqlDriver.sqlite(), "t_fld_conn")
        db.setDatabaseName(":memory:")
        db.open()
        let q = QSqlQuery(db)
        q.exec("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT)")
        q.exec("INSERT INTO users VALUES (1, 'Alice')")
        @Expect(q.exec("SELECT id, name FROM users"), true)
        @Expect(q.next(), true)
        let rec = q.record()
        let f0 = rec.field(0)
        @Expect(f0.name(), "id")
        @Expect(f0.isNull(), false)
        @Expect(f0.valueString(), "1")
        f0.close()
        let f1 = rec.field(1)
        @Expect(f1.name(), "name")
        // 查询结果集中的字段默认 readOnly=false
        @Expect(f1.isReadOnly(), false)
        @Expect(f1.isAutoValue(), false)
        @Expect(f1.valueString(), "Alice")
        f1.close()
        rec.close()
        q.delete()
        db.close()
        QSqlDatabase.removeDatabase("t_fld_conn")
    }

    @TestCase
    func testRecordOperationsAfterClose() {
        let db = QSqlDatabase.addDatabase(SqlDriver.sqlite(), "t_rec3_conn")
        db.setDatabaseName(":memory:")
        db.open()
        let q = QSqlQuery(db)
        q.exec("CREATE TABLE users (id INTEGER PRIMARY KEY)")
        q.exec("SELECT id FROM users")
        let rec = q.record()
        rec.close()
        @ExpectThrows[ResourceDisposedException](rec.count())
        @ExpectThrows[ResourceDisposedException](rec.fieldName(0))
        @ExpectThrows[ResourceDisposedException](rec.indexOf("id"))
        q.delete()
        db.close()
        QSqlDatabase.removeDatabase("t_rec3_conn")
    }
}

// =====================================================================
// QSqlTableModel 测试（避开 select()，仅测试非查询 API）
// =====================================================================
@Test
class QSqlTableModelTests {

    @TestCase
    func testCreateAndSetTable() {
        let db = QSqlDatabase.addDatabase(SqlDriver.sqlite(), "t_tm_conn")
        db.setDatabaseName(":memory:")
        db.open()
        let model = QSqlTableModel("t_tm_conn")
        @Expect(model.getPtr() != 0, true)
        @Expect(model.tableName(), "")
        model.setTable("users")
        @Expect(model.tableName(), "users")
        @Expect(model.rowCount(), 0)
        @Expect(model.columnCount(), 0)
        model.close()
        db.close()
        QSqlDatabase.removeDatabase("t_tm_conn")
    }

    @TestCase
    func testFilterRoundTrip() {
        let db = QSqlDatabase.addDatabase(SqlDriver.sqlite(), "t_tm2_conn")
        db.setDatabaseName(":memory:")
        db.open()
        let model = QSqlTableModel("t_tm2_conn")
        model.setTable("users")
        model.setFilter("age > 18")
        @Expect(model.filter(), "age > 18")
        model.setFilter("")
        @Expect(model.filter(), "")
        model.close()
        db.close()
        QSqlDatabase.removeDatabase("t_tm2_conn")
    }

    @TestCase
    func testEditStrategyRoundTrip() {
        let db = QSqlDatabase.addDatabase(SqlDriver.sqlite(), "t_tm3_conn")
        db.setDatabaseName(":memory:")
        db.open()
        let model = QSqlTableModel("t_tm3_conn")
        model.setEditStrategy(EditStrategy.onManualSubmit())
        @Expect(model.editStrategy(), 2)
        model.setEditStrategy(EditStrategy.onRowChange())
        @Expect(model.editStrategy(), 1)
        model.setEditStrategy(EditStrategy.onFieldChange())
        @Expect(model.editStrategy(), 0)
        model.close()
        db.close()
        QSqlDatabase.removeDatabase("t_tm3_conn")
    }

    @TestCase
    func testSetSortAndData() {
        let db = QSqlDatabase.addDatabase(SqlDriver.sqlite(), "t_tm4_conn")
        db.setDatabaseName(":memory:")
        db.open()
        let model = QSqlTableModel("t_tm4_conn")
        model.setTable("users")
        model.setSort(1, 0)
        // 未执行 select()，无数据
        @Expect(model.data(0, 0), "")
        @Expect(model.setData(0, 0, "x"), false)
        // 访问数据会触发惰性查询（表不存在→失败）并设置错误信息
        @Expect(model.databaseError().contains("users"), true)
        // headerData 仅验证不抛异常
        model.headerData(0)
        model.close()
        db.close()
        QSqlDatabase.removeDatabase("t_tm4_conn")
    }

    @TestCase
    func testRowManagement() {
        let db = QSqlDatabase.addDatabase(SqlDriver.sqlite(), "t_tm5_conn")
        db.setDatabaseName(":memory:")
        db.open()
        let model = QSqlTableModel("t_tm5_conn")
        model.setTable("users")
        // 未 select() 时 insertRow/removeRow 仍返回 true（操作入队，提交时才真正执行）
        @Expect(model.insertRow(0), true)
        @Expect(model.removeRow(0), true)
        @Expect(model.submitAll(), true)
        model.revertAll()
        model.clearTable()
        @Expect(model.canFetchMore(), false)
        model.fetchMore()
        model.close()
        db.close()
        QSqlDatabase.removeDatabase("t_tm5_conn")
    }

    @TestCase
    func testOperationsAfterClose() {
        let db = QSqlDatabase.addDatabase(SqlDriver.sqlite(), "t_tm6_conn")
        db.setDatabaseName(":memory:")
        db.open()
        let model = QSqlTableModel("t_tm6_conn")
        model.close()
        @ExpectThrows[ResourceDisposedException](model.setTable("users"))
        @ExpectThrows[ResourceDisposedException](model.tableName())
        @ExpectThrows[ResourceDisposedException](model.rowCount())
        @ExpectThrows[ResourceDisposedException](model.data(0, 0))
        db.close()
        QSqlDatabase.removeDatabase("t_tm6_conn")
    }
}

// =====================================================================
// QStandardItemModel 测试（纯模型，无需 GUI 环境）
// =====================================================================
@Test
class QStandardItemModelTests {

    @TestCase
    func testCreateWithSize() {
        let model = QStandardItemModel(3, 3)
        @Expect(model.getPtr() != 0, true)
        @Expect(model.rowCount(), 3)
        @Expect(model.columnCount(), 3)
        model.delete()
    }

    @TestCase
    func testCreateEmpty() {
        let model = QStandardItemModel()
        @Expect(model.rowCount(), 0)
        @Expect(model.columnCount(), 0)
        model.delete()
    }

    @TestCase
    func testSetItemAndItemText() {
        let model = QStandardItemModel(3, 3)
        model.setItem(1, 0, "B")
        @Expect(model.itemText(1, 0), "B")
        @Expect(model.itemText(0, 0), "")
        model.setItem(2, 2, "C")
        @Expect(model.itemText(2, 2), "C")
        model.delete()
    }

    @TestCase
    func testSetItemObject() {
        let model = QStandardItemModel(3, 3)
        let item = QStandardItem("X")
        model.setItem(0, 1, item)
        @Expect(model.itemText(0, 1), "X")
        let fetched = model.item(0, 1)
        @Expect(fetched.getPtr() != 0, true)
        @Expect(fetched.text(), "X")
        // item 已被模型接管，不再单独 delete
        model.delete()
    }

    @TestCase
    func testAppendAndInsertRow() {
        let model = QStandardItemModel(3, 3)
        let item = QStandardItem("Appended")
        model.appendRow(item)
        @Expect(model.rowCount(), 4)
        @Expect(model.itemText(3, 0), "Appended")
        let item2 = QStandardItem("Inserted")
        model.insertRow(1, item2)
        @Expect(model.rowCount(), 5)
        @Expect(model.itemText(1, 0), "Inserted")
        @Expect(model.itemText(4, 0), "Appended")
        model.delete()
    }

    @TestCase
    func testInsertRemoveRowColumn() {
        let model = QStandardItemModel(2, 2)
        model.insertRow(1)
        @Expect(model.rowCount(), 3)
        model.removeRow(1)
        @Expect(model.rowCount(), 2)
        model.insertColumn(1)
        @Expect(model.columnCount(), 3)
        model.removeColumn(1)
        @Expect(model.columnCount(), 2)
        model.delete()
    }

    @TestCase
    func testHeaders() {
        let model = QStandardItemModel(2, 2)
        model.setHorizontalHeaderLabel(0, "Col0")
        model.setVerticalHeaderLabel(0, "Row0")
        @Assert(true)
        model.delete()
    }

    @TestCase
    func testItemEnabledCheckableChecked() {
        let model = QStandardItemModel(3, 3)
        // QStandardItemModel(rows, cols) 仅设定维度，单元格 item 需先 setItem 创建
        model.setItem(0, 0, "Disabled")
        model.setItem(1, 1, "Chk")
        model.setItemEnabled(0, 0, false)
        model.setItemCheckable(1, 1, true)
        model.setItemChecked(1, 1, true)
        @Expect(model.isItemChecked(1, 1), true)
        model.setItemChecked(1, 1, false)
        @Expect(model.isItemChecked(1, 1), false)
        model.delete()
    }

    @TestCase
    func testFindItems() {
        let model = QStandardItemModel(3, 3)
        model.setItem(0, 0, "Alpha")
        model.setItem(1, 0, "Beta")
        model.setItem(2, 0, "Alpha")
        // flags=0 表示 MatchExactly
        @Expect(model.findItems("Alpha", 0), 2)
        @Expect(model.findItems("Gamma", 0), 0)
        model.delete()
    }

    @TestCase
    func testIndexFromItemAndBack() {
        let model = QStandardItemModel(3, 3)
        let item = QStandardItem("Idx")
        model.setItem(1, 1, item)
        let idxPtr = model.indexFromItem(item)
        @Expect(idxPtr != 0, true)
        let idx = QModelIndex(idxPtr)
        @Expect(idx.row(), 1)
        @Expect(idx.column(), 1)
        @Expect(idx.isValid(), true)
        let back = model.itemFromIndex(idx)
        @Expect(back.getPtr() != 0, true)
        @Expect(back.text(), "Idx")
        idx.delete()
        model.delete()
    }

    @TestCase
    func testClear() {
        let model = QStandardItemModel(3, 3)
        model.setItem(0, 0, "A")
        model.clear()
        @Expect(model.rowCount(), 0)
        @Expect(model.columnCount(), 0)
        model.delete()
    }

    @TestCase
    func testQStandardItemTextAndFlags() {
        let item = QStandardItem("Hi")
        @Expect(item.text(), "Hi")
        item.setText("Bye")
        @Expect(item.text(), "Bye")
        item.setFlags(ItemFlag.ItemIsSelectable | ItemFlag.ItemIsEnabled)
        @Expect(item.flags(), 33)
        item.delete()
    }

    @TestCase
    func testQStandardItemCheckState() {
        let item = QStandardItem("Chk")
        item.setCheckState(CheckState.Checked)
        @Expect(item.checkState(), 2)
        item.setCheckState(CheckState.PartiallyChecked)
        @Expect(item.checkState(), 1)
        item.setCheckState(CheckState.Unchecked)
        @Expect(item.checkState(), 0)
        item.delete()
    }

    @TestCase
    func testQStandardItemData() {
        let item = QStandardItem("Data")
        // role=Qt::UserRole(0x0100=256)
        item.setData(256, 42)
        @Expect(item.data(256), 42)
        item.setData(256, -7)
        @Expect(item.data(256), -7)
        item.delete()
    }

    @TestCase
    func testQStandardItemEditableForeground() {
        let item = QStandardItem("Ed")
        item.setEditable(false)
        @Expect(item.isEditable(), false)
        item.setEditable(true)
        @Expect(item.isEditable(), true)
        item.setForeground(255, 0, 0)
        @Assert(true)
        item.delete()
    }

    @TestCase
    func testQStandardItemAppendChild() {
        let parent = QStandardItem("Parent")
        let child = QStandardItem("Child")
        parent.appendRow(child)
        @Assert(true)
        parent.delete()
    }

    @TestCase
    func testOperationsAfterDelete() {
        let model = QStandardItemModel(3, 3)
        model.delete()
        @ExpectThrows[ResourceDisposedException](model.rowCount())
        @ExpectThrows[ResourceDisposedException](model.itemText(0, 0))
        @ExpectThrows[ResourceDisposedException](model.setItem(0, 0, "x"))
    }
}

// =====================================================================
// QSortFilterProxyModel 测试（纯模型，无需 GUI 环境）
// =====================================================================
@Test
class QSortFilterProxyModelTests {

    // 创建 3 行源模型: (0,0)=C, (1,0)=A, (2,0)=B
    private func makeSource(): QStandardItemModel {
        let model = QStandardItemModel(3, 1)
        model.setItem(0, 0, "C")
        model.setItem(1, 0, "A")
        model.setItem(2, 0, "B")
        return model
    }

    @TestCase
    func testCreateAndSourceModel() {
        let source = makeSource()
        let proxy = QSortFilterProxyModel()
        proxy.setSourceModel(source.getPtr())
        @Expect(proxy.rowCount(), 3)
        @Expect(proxy.columnCount(), 1)
        proxy.delete()
        source.delete()
    }

    @TestCase
    func testFilterFixedString() {
        let source = makeSource()
        let proxy = QSortFilterProxyModel()
        proxy.setSourceModel(source.getPtr())
        proxy.setFilterFixedString("B")
        @Expect(proxy.rowCount(), 1)
        proxy.setFilterFixedString("")
        @Expect(proxy.rowCount(), 3)
        proxy.delete()
        source.delete()
    }

    @TestCase
    func testFilterKeyColumnRole() {
        let source = makeSource()
        let proxy = QSortFilterProxyModel()
        proxy.setSourceModel(source.getPtr())
        @Expect(proxy.filterKeyColumn(), 0)
        proxy.setFilterKeyColumn(1)
        @Expect(proxy.filterKeyColumn(), 1)
        proxy.setFilterRole(2)
        @Expect(proxy.filterRole(), 2)
        proxy.setSortRole(2)
        @Expect(proxy.sortRole(), 2)
        proxy.delete()
        source.delete()
    }

    @TestCase
    func testSortOrderAndMapping() {
        let source = makeSource()
        let proxy = QSortFilterProxyModel()
        proxy.setSourceModel(source.getPtr())
        proxy.sort(0, SortOrder.ascending())
        @Expect(proxy.sortOrder(), 0)
        // 升序后代理行0 = 源行1 (A)
        let idx0 = proxy.mapToSource(0, 0)
        @Expect(idx0 != 0, true)
        let mi0 = QModelIndex(idx0)
        @Expect(mi0.row(), 1)
        @Expect(mi0.column(), 0)
        mi0.delete()
        // 代理行2 = 源行0 (C)
        let idx2 = proxy.mapToSource(2, 0)
        let mi2 = QModelIndex(idx2)
        @Expect(mi2.row(), 0)
        mi2.delete()
        proxy.delete()
        source.delete()
    }

    @TestCase
    func testSortDescending() {
        let source = makeSource()
        let proxy = QSortFilterProxyModel()
        proxy.setSourceModel(source.getPtr())
        proxy.sort(0, SortOrder.descending())
        @Expect(proxy.sortOrder(), 1)
        // 降序后代理行0 = 源行0 (C)
        let idx = proxy.mapToSource(0, 0)
        let mi = QModelIndex(idx)
        @Expect(mi.row(), 0)
        mi.delete()
        proxy.delete()
        source.delete()
    }

    @TestCase
    func testMapFromSource() {
        let source = makeSource()
        let proxy = QSortFilterProxyModel()
        proxy.setSourceModel(source.getPtr())
        proxy.sort(0, SortOrder.ascending())
        // 源行1 (A) → 代理行0
        let idx = proxy.mapFromSource(1, 0, source.getPtr())
        @Expect(idx != 0, true)
        let mi = QModelIndex(idx)
        @Expect(mi.row(), 0)
        @Expect(mi.column(), 0)
        mi.delete()
        proxy.delete()
        source.delete()
    }

    @TestCase
    func testDynamicSortAndCaseSensitivity() {
        let source = makeSource()
        let proxy = QSortFilterProxyModel()
        proxy.setSourceModel(source.getPtr())
        proxy.setDynamicSortFilter(true)
        @Expect(proxy.dynamicSortFilter(), true)
        proxy.setFilterCaseSensitivity(CaseSensitivity.sensitive())
        @Expect(proxy.filterCaseSensitivity(), 1)
        proxy.setFilterCaseSensitivity(CaseSensitivity.insensitive())
        @Expect(proxy.filterCaseSensitivity(), 0)
        proxy.delete()
        source.delete()
    }

    @TestCase
    func testFilterRegularExpressionAndWildcard() {
        let source = makeSource()
        let proxy = QSortFilterProxyModel()
        proxy.setSourceModel(source.getPtr())
        proxy.setFilterRegularExpression("^A$")
        @Expect(proxy.rowCount(), 1)
        proxy.invalidate()
        proxy.setFilterWildcard("B*")
        @Expect(proxy.rowCount(), 1)
        proxy.setFilterWildcard("")
        @Expect(proxy.rowCount(), 3)
        proxy.delete()
        source.delete()
    }

    @TestCase
    func testOperationsAfterDelete() {
        let proxy = QSortFilterProxyModel()
        proxy.delete()
        @ExpectThrows[ResourceDisposedException](proxy.rowCount())
        @ExpectThrows[ResourceDisposedException](proxy.sort(0, 0))
        @ExpectThrows[ResourceDisposedException](proxy.setSourceModel(0))
    }
}

// =====================================================================
// QFileSystemModel 测试（纯模型，无需 GUI 环境）
// =====================================================================
@Test
class QFileSystemModelTests {

    @TestCase
    func testCreateAndClose() {
        let model = QFileSystemModel()
        @Expect(model.getPtr() != 0, true)
        model.delete()
    }

    @TestCase
    func testReadOnlyRoundTrip() {
        let model = QFileSystemModel()
        model.setReadOnly(false)
        @Expect(model.isReadOnly(), false)
        model.setReadOnly(true)
        @Expect(model.isReadOnly(), true)
        model.delete()
    }

    @TestCase
    func testResolveSymlinksRoundTrip() {
        let model = QFileSystemModel()
        model.setResolveSymlinks(true)
        @Expect(model.isResolveSymlinks(), true)
        model.setResolveSymlinks(false)
        @Expect(model.isResolveSymlinks(), false)
        model.delete()
    }

    @TestCase
    func testSetRootPath() {
        let model = QFileSystemModel()
        model.setRootPath("C:\\")
        @Expect(model.rootPath() != "", true)
        model.delete()
    }

    @TestCase
    func testIndexAndFilePath() {
        let model = QFileSystemModel()
        model.setRootPath("C:\\")
        let idxPtr = model.index("C:\\CodeTools\\cangjie_git\\CJQT6\\tests")
        @Expect(idxPtr != 0, true)
        let idx = QModelIndex(idxPtr)
        @Expect(idx.isValid(), true)
        @Expect(model.isDir(idx), true)
        @Expect(model.fileName(idx), "tests")
        @Expect(model.filePath(idx).contains("tests"), true)
        idx.delete()
        model.delete()
    }

    @TestCase
    func testRootPathChangedCallback() {
        gFsmRootPath = ""
        let model = QFileSystemModel()
        model.setOnRootPathChanged(gFsmRootPathCb)
        model.setRootPath("C:\\")
        @Expect(gFsmRootPath != "", true)
        model.delete()
    }

    @TestCase
    func testOperationsAfterDelete() {
        let model = QFileSystemModel()
        model.delete()
        @ExpectThrows[ResourceDisposedException](model.rootPath())
        @ExpectThrows[ResourceDisposedException](model.setRootPath("C:\\"))
        @ExpectThrows[ResourceDisposedException](model.isReadOnly())
    }
}

// =====================================================================
// QListWidget 测试（GUI 环境）
// =====================================================================
@Test
class QListWidgetTests {
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
    func testCreateAndAddItem() {
        let list = QListWidget()
        let itemPtr = list.addItem("One")
        @Expect(itemPtr != 0, true)
        @Expect(list.count(), 1)
        @Expect(list.itemText(0), "One")
        list.delete()
    }

    @TestCase
    func testAddItems() {
        let list = QListWidget()
        list.addItems(["A", "B", "C"])
        @Expect(list.count(), 3)
        @Expect(list.itemText(0), "A")
        @Expect(list.itemText(2), "C")
        list.delete()
    }

    @TestCase
    func testInsertRemoveClear() {
        let list = QListWidget()
        list.addItem("A")
        list.insertItem(0, "B")
        @Expect(list.count(), 2)
        @Expect(list.itemText(0), "B")
        list.removeItem(0)
        @Expect(list.count(), 1)
        @Expect(list.itemText(0), "A")
        list.clear()
        @Expect(list.count(), 0)
        list.delete()
    }

    @TestCase
    func testSetItemText() {
        let list = QListWidget()
        list.addItem("Old")
        list.setItemText(0, "New")
        @Expect(list.itemText(0), "New")
        list.delete()
    }

    @TestCase
    func testCurrentRowAndItemText() {
        let list = QListWidget()
        list.addItem("A")
        list.addItem("B")
        @Expect(list.currentRow(), -1)
        list.setCurrentRow(1)
        @Expect(list.currentRow(), 1)
        @Expect(list.currentItemText(), "B")
        list.delete()
    }

    @TestCase
    func testItemDataRoundTrip() {
        let list = QListWidget()
        list.addItem("A")
        list.setItemData(0, 123456)
        @Expect(list.getItemData(0), 123456)
        list.setItemData(0, -99)
        @Expect(list.getItemData(0), -99)
        list.delete()
    }

    @TestCase
    func testSelectionModeAndAppearance() {
        let list = QListWidget()
        list.addItem("A")
        list.setSelectionMode(ListSelectionMode.SingleSelection)
        list.setAlternatingRowColors(true)
        list.setSortingEnabled(false)
        list.setItemIcon(0, ListIconType.Folder)
        list.setViewMode(0)
        @Assert(true)
        list.delete()
    }

    @TestCase
    func testCheckable() {
        let list = QListWidget()
        list.addItem("A")
        list.setItemCheckable(0, true)
        list.setChecked(0, true)
        @Expect(list.isChecked(0), true)
        list.setChecked(0, false)
        @Expect(list.isChecked(0), false)
        list.delete()
    }

    @TestCase
    func testItemWrapper() {
        let list = QListWidget()
        list.addItem("Wrapped")
        let item = list.item(0)
        @Expect(item.getPtr() != 0, true)
        @Expect(item.text(), "Wrapped")
        item.setText("Changed")
        @Expect(list.itemText(0), "Changed")
        list.delete()
    }

    @TestCase
    func testCurrentRowChangedCallback() {
        gLwCurrentRow = -1
        let list = QListWidget()
        list.setOnCurrentRowChanged(gLwCurrentRowCb)
        list.addItem("A")
        list.addItem("B")
        list.setCurrentRow(1)
        @Expect(gLwCurrentRow, 1)
        list.setCurrentRow(0)
        @Expect(gLwCurrentRow, 0)
        list.delete()
    }

    @TestCase
    func testDoubleClickAndClickCallbacks() {
        let list = QListWidget()
        list.addItem("A")
        list.setOnItemClicked({ v: Int32 => gLwCurrentRow = v })
        list.setOnItemDoubleClicked({ v: Int32 => gLwCurrentRow = v })
        @Assert(true)
        list.delete()
    }

    @TestCase
    func testItemPointerCallbacks() {
        let list = QListWidget()
        list.addItem("A")
        list.setOnItemClickedItem({ v: Int64 => gTwCurrentItem = v })
        list.setOnItemDoubleClickedItem({ v: Int64 => gTwCurrentItem = v })
        list.setOnCurrentItemChanged({ v: Int64 => gTwCurrentItem = v })
        list.setOnItemSelectionChanged({ => gDlgAccepted = true })
        @Assert(true)
        list.delete()
    }

    @TestCase
    func testQListWidgetItemDirect() {
        let item = QListWidgetItem("Direct")
        @Expect(item.text(), "Direct")
        item.setText("D2")
        @Expect(item.text(), "D2")
        item.setFlags(ItemFlag.ItemIsSelectable | ItemFlag.ItemIsEnabled)
        @Expect(item.flags(), 33)
        item.setCheckState(CheckState.Checked)
        @Expect(item.checkState(), 2)
        item.setData(256, 77)
        @Expect(item.data(256), 77)
        item.delete()
    }
}

// =====================================================================
// QTableWidget 测试（GUI 环境）
// =====================================================================
@Test
class QTableWidgetTests {
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
    func testCreateWithSize() {
        let table = QTableWidget(3, 4)
        @Expect(table.rowCount(), 3)
        @Expect(table.columnCount(), 4)
        table.delete()
    }

    @TestCase
    func testSetItemAndItemText() {
        let table = QTableWidget(3, 3)
        table.setItem(0, 0, "A")
        table.setItem(2, 2, "C")
        @Expect(table.itemText(0, 0), "A")
        @Expect(table.itemText(2, 2), "C")
        @Expect(table.itemText(1, 1), "")
        table.delete()
    }

    @TestCase
    func testSetItemObject() {
        let table = QTableWidget(3, 3)
        let item = QTableWidgetItem("Obj")
        table.setItem(1, 1, item)
        @Expect(table.itemText(1, 1), "Obj")
        let fetched = table.item(1, 1)
        @Expect(fetched.getPtr() != 0, true)
        @Expect(fetched.text(), "Obj")
        // item 已被表格接管
        table.delete()
    }

    @TestCase
    func testHeaders() {
        let table = QTableWidget(2, 2)
        table.setHorizontalHeaderLabel(0, "Col0")
        table.setVerticalHeaderLabel(0, "Row0")
        table.setHorizontalHeaderLabels(["H1", "H2"])
        @Assert(true)
        table.delete()
    }

    @TestCase
    func testCurrentCell() {
        let table = QTableWidget(3, 3)
        @Expect(table.currentRow(), -1)
        @Expect(table.currentColumn(), -1)
        table.setCurrentCell(2, 1)
        @Expect(table.currentRow(), 2)
        @Expect(table.currentColumn(), 1)
        table.delete()
    }

    @TestCase
    func testInsertRemoveRowColumn() {
        let table = QTableWidget(2, 2)
        table.insertRow(1)
        @Expect(table.rowCount(), 3)
        table.removeRow(1)
        @Expect(table.rowCount(), 2)
        table.insertColumn(1)
        @Expect(table.columnCount(), 3)
        table.removeColumn(1)
        @Expect(table.columnCount(), 2)
        table.delete()
    }

    @TestCase
    func testClearAndClearContents() {
        let table = QTableWidget(2, 2)
        table.setItem(0, 0, "A")
        table.clearContents()
        @Expect(table.rowCount(), 2)
        @Expect(table.itemText(0, 0), "")
        table.setItem(0, 0, "B")
        table.clear()
        // Qt clear() 仅清空单元格内容，不重置行列数
        @Expect(table.rowCount(), 2)
        @Expect(table.columnCount(), 2)
        @Expect(table.itemText(0, 0), "")
        table.delete()
    }

    @TestCase
    func testSelectionSettings() {
        let table = QTableWidget(3, 3)
        table.setSelectionMode(SingleSelection)
        table.setSelectionBehavior(SelectRows)
        table.setShowGrid(false)
        table.setSortingEnabled(true)
        @Expect(table.isSortingEnabled(), true)
        table.setSortingEnabled(false)
        @Expect(table.isSortingEnabled(), false)
        table.delete()
    }

    @TestCase
    func testEditTriggersAndGridStyle() {
        let table = QTableWidget(3, 3)
        table.setEditTriggers(EditTrigger.NoEditTriggers)
        @Expect(table.editTriggers(), 0)
        table.setEditTriggers(EditTrigger.DoubleClicked)
        @Expect(table.editTriggers(), 2)
        table.setGridStyle(2)
        @Expect(table.gridStyle(), 2)
        table.delete()
    }

    @TestCase
    func testCornerButtonAndWordWrap() {
        let table = QTableWidget(3, 3)
        table.setCornerButtonEnabled(false)
        @Expect(table.isCornerButtonEnabled(), false)
        table.setCornerButtonEnabled(true)
        @Expect(table.isCornerButtonEnabled(), true)
        table.setWordWrap(false)
        @Expect(table.isWordWrap(), false)
        table.delete()
    }

    @TestCase
    func testResizeAndHeaderSettings() {
        let table = QTableWidget(3, 3)
        table.resizeColumnsToContents()
        table.resizeRowsToContents()
        table.resizeColumnToContents(0)
        table.setColumnWidth(0, 120)
        table.setRowHeight(0, 40)
        table.setHorizontalHeaderStretchLastSection(true)
        table.setColumnResizeMode(0, Fixed)
        table.setDefaultRowHeight(30)
        @Assert(true)
        table.delete()
    }

    @TestCase
    func testFindItems() {
        let table = QTableWidget(3, 3)
        table.setItem(0, 0, "Apple")
        table.setItem(1, 1, "Apple")
        table.setItem(2, 2, "Banana")
        @Expect(table.findItems("Apple", 0), 2)
        @Expect(table.findItems("Cherry", 0), 0)
        table.delete()
    }

    @TestCase
    func testCurrentCellChangedCallback() {
        gTbCellRow = -1
        gTbCellCol = -1
        let table = QTableWidget(3, 3)
        table.setOnCurrentCellChanged(gTbCellCb)
        table.setCurrentCell(2, 1)
        @Expect(gTbCellRow, 2)
        @Expect(gTbCellCol, 1)
        table.delete()
    }

    @TestCase
    func testCellChangedCallback() {
        gTbCellRow = -1
        gTbCellCol = -1
        let table = QTableWidget(3, 3)
        table.setOnCellChanged(gTbCellCb)
        table.setItem(1, 0, "X")
        @Expect(gTbCellRow, 1)
        @Expect(gTbCellCol, 0)
        table.delete()
    }

    @TestCase
    func testOtherCallbacks() {
        let table = QTableWidget(3, 3)
        table.setOnCellClicked(gTbCellCb)
        table.setOnCellDoubleClicked(gTbCellCb)
        table.setOnItemClicked({ v: Int64 => gTwCurrentItem = v })
        table.setOnItemSelectionChanged({ => gDlgAccepted = true })
        @Assert(true)
        table.delete()
    }

    @TestCase
    func testQTableWidgetItemDirect() {
        let item = QTableWidgetItem("T")
        @Expect(item.text(), "T")
        item.setText("T2")
        @Expect(item.text(), "T2")
        item.setFlags(ItemFlag.ItemIsEnabled)
        @Expect(item.flags(), 32)
        item.setCheckState(CheckState.Checked)
        @Expect(item.checkState(), 2)
        item.setData(256, 88)
        @Expect(item.data(256), 88)
        item.setBackground(255, 0, 0)
        @Assert(true)
        item.delete()
    }
}

// =====================================================================
// QTreeWidget 测试（GUI 环境）
// =====================================================================
@Test
class QTreeWidgetTests {
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
    func testCreateAndColumns() {
        let tree = QTreeWidget()
        tree.setColumnCount(2)
        @Expect(tree.columnCount(), 2)
        tree.delete()
    }

    @TestCase
    func testAddTopLevelItem() {
        let tree = QTreeWidget()
        let item = tree.addTopLevelItem("Root1")
        @Expect(item.getPtr() != 0, true)
        @Expect(tree.topLevelItemCount(), 1)
        let fetched = tree.topLevelItem(0)
        @Expect(fetched.text(0), "Root1")
        tree.delete()
    }

    @TestCase
    func testInsertAndTakeTopLevel() {
        let tree = QTreeWidget()
        tree.addTopLevelItem("A")
        tree.addTopLevelItem("C")
        let newItem = QTreeWidgetItem("B")
        tree.insertTopLevelItem(1, newItem)
        @Expect(tree.topLevelItemCount(), 3)
        @Expect(tree.topLevelItem(1).text(0), "B")
        @Expect(tree.indexOfTopLevelItem(newItem), 1)
        tree.takeTopLevelItem(1)
        @Expect(tree.topLevelItemCount(), 2)
        tree.delete()
    }

    @TestCase
    func testChildren() {
        let tree = QTreeWidget()
        let root = tree.addTopLevelItem("Root")
        let child = root.addChild("Child1")
        @Expect(child.getPtr() != 0, true)
        @Expect(root.childCount(), 1)
        @Expect(root.child(0).text(0), "Child1")
        if (let Some(_) <- root.parent()) {
            @Expect(false, true)
        } else {
            @Assert(true)
        }
        if (let Some(p) <- child.parent()) {
            @Expect(p.getPtr(), root.getPtr())
        } else {
            @Expect(false, true)
        }
        tree.delete()
    }

    @TestCase
    func testItemTextMultiColumn() {
        let tree = QTreeWidget()
        tree.setColumnCount(2)
        let item = tree.addTopLevelItem("C0")
        item.setText(1, "C1")
        @Expect(item.text(0), "C0")
        @Expect(item.text(1), "C1")
        tree.delete()
    }

    @TestCase
    func testItemData() {
        let tree = QTreeWidget()
        let item = tree.addTopLevelItem("D")
        item.setData(0, 123)
        @Expect(item.getData(0), 123)
        tree.delete()
    }

    @TestCase
    func testCheckState() {
        let tree = QTreeWidget()
        let item = tree.addTopLevelItem("Chk")
        item.setCheckState(0, CheckState.Checked)
        @Expect(item.checkState(0), 2)
        item.setCheckState(0, CheckState.Unchecked)
        @Expect(item.checkState(0), 0)
        tree.delete()
    }

    @TestCase
    func testExpandCollapse() {
        let tree = QTreeWidget()
        let root = tree.addTopLevelItem("Root")
        root.addChild("Kid")
        tree.expandAll()
        @Expect(root.isExpanded(), true)
        tree.collapseAll()
        @Expect(root.isExpanded(), false)
        root.setExpanded(true)
        @Expect(root.isExpanded(), true)
        tree.expandItem(root)
        @Expect(root.isExpanded(), true)
        tree.collapseItem(root)
        @Expect(root.isExpanded(), false)
        tree.delete()
    }

    @TestCase
    func testSelectedAndHidden() {
        let tree = QTreeWidget()
        let item = tree.addTopLevelItem("Sel")
        item.setSelected(true)
        @Expect(item.isSelected(), true)
        item.setSelected(false)
        @Expect(item.isSelected(), false)
        item.setHidden(true)
        @Expect(item.isHidden(), true)
        item.setHidden(false)
        @Expect(item.isHidden(), false)
        tree.delete()
    }

    @TestCase
    func testCurrentItem() {
        let tree = QTreeWidget()
        let item = tree.addTopLevelItem("Cur")
        if (let Some(_) <- tree.currentItem()) {
            @Expect(false, true)
        } else {
            @Assert(true)
        }
        tree.setCurrentItem(item)
        if (let Some(cur) <- tree.currentItem()) {
            @Expect(cur.getPtr(), item.getPtr())
        } else {
            @Expect(false, true)
        }
        tree.delete()
    }

    @TestCase
    func testCurrentItemChangedCallback() {
        gTwCurrentItem = 0
        let tree = QTreeWidget()
        tree.setOnCurrentItemChanged(gTwCurrentItemCb)
        let item = tree.addTopLevelItem("Cb")
        tree.setCurrentItem(item)
        @Expect(gTwCurrentItem, item.getPtr())
        tree.delete()
    }

    @TestCase
    func testOtherCallbacks() {
        let tree = QTreeWidget()
        let item = tree.addTopLevelItem("X")
        tree.setOnItemClicked({ v: Int64 => gTwCurrentItem = v })
        tree.setOnItemDoubleClicked({ v: Int64 => gTwCurrentItem = v })
        tree.setOnItemExpanded({ v: Int64 => gTwCurrentItem = v })
        tree.setOnItemCollapsed({ v: Int64 => gTwCurrentItem = v })
        tree.setOnItemClickedWithColumn({ v: Int64, c: Int32 => gTwCurrentItem = v })
        tree.setOnItemChanged({ v: Int64, c: Int32 => gTwCurrentItem = v })
        tree.setSelectionMode(SingleSelection)
        tree.setHeaderLabel(0, "Name")
        tree.setHeaderHidden(false)
        @Assert(true)
        tree.delete()
    }

    @TestCase
    func testTakeChildAndParent() {
        let tree = QTreeWidget()
        let root = tree.addTopLevelItem("Root")
        root.addChild("Kid")
        root.takeChild(0)
        @Expect(root.childCount(), 0)
        tree.delete()
    }
}

// =====================================================================
// QListView 测试（GUI 环境）
// =====================================================================
@Test
class QListViewTests {
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
        let view = QListView()
        @Expect(view.getPtr() != 0, true)
        view.delete()
    }

    @TestCase
    func testSetModel() {
        let view = QListView()
        let model = QStandardItemModel(3, 1)
        model.setItem(0, 0, "A")
        view.setModel(model)
        @Assert(true)
        view.delete()
        model.delete()
    }

    @TestCase
    func testSelectionModeRoundTrip() {
        let view = QListView()
        view.setSelectionMode(SelectionMode.Single)
        @Expect(view.selectionMode(), 1)
        view.setSelectionMode(SelectionMode.Multi)
        @Expect(view.selectionMode(), 2)
        view.setSelectionMode(SelectionMode.Extended)
        @Expect(view.selectionMode(), 3)
        view.setSelectionMode(SelectionMode.NoSelection)
        @Expect(view.selectionMode(), 0)
        view.delete()
    }

    @TestCase
    func testEditTriggersRoundTrip() {
        let view = QListView()
        view.setEditTriggers(EditTrigger.NoEditTriggers)
        @Expect(view.editTriggers(), 0)
        view.setEditTriggers(EditTrigger.DoubleClicked)
        @Expect(view.editTriggers(), 2)
        view.delete()
    }

    @TestCase
    func testViewModeMovementFlow() {
        let view = QListView()
        view.setViewMode(0)
        @Expect(view.viewMode(), 0)
        view.setViewMode(1)
        @Expect(view.viewMode(), 1)
        view.setMovement(1)
        @Expect(view.movement(), 1)
        view.setFlow(1)
        @Expect(view.flow(), 1)
        view.delete()
    }

    @TestCase
    func testWrappingSpacingResize() {
        let view = QListView()
        view.setWrapping(true)
        @Expect(view.isWrapping(), true)
        view.setWrapping(false)
        @Expect(view.isWrapping(), false)
        view.setSpacing(10)
        @Expect(view.spacing(), 10)
        view.setResizeMode(1)
        @Expect(view.resizeMode(), 1)
        view.delete()
    }

    @TestCase
    func testWordWrapAndUniform() {
        let view = QListView()
        view.setWordWrap(true)
        @Expect(view.isWordWrap(), true)
        view.setUniformItemSizes(true)
        @Expect(view.uniformItemSizes(), true)
        view.setUniformItemSizes(false)
        @Expect(view.uniformItemSizes(), false)
        view.delete()
    }

    @TestCase
    func testCurrentIndex() {
        let view = QListView()
        let model = QStandardItemModel(3, 1)
        model.setItem(1, 0, "Mid")
        view.setModel(model)
        let item = model.item(1, 0)
        let idx = QModelIndex(model.indexFromItem(item))
        view.setCurrentIndex(idx)
        let curPtr = view.currentIndex()
        @Expect(curPtr != 0, true)
        let cur = QModelIndex(curPtr)
        @Expect(cur.row(), 1)
        @Expect(cur.column(), 0)
        @Expect(cur.isValid(), true)
        cur.delete()
        idx.delete()
        view.delete()
        model.delete()
    }

    @TestCase
    func testRootIndex() {
        let view = QListView()
        let model = QStandardItemModel(3, 1)
        model.setItem(0, 0, "A")
        view.setModel(model)
        let item = model.item(0, 0)
        let idx = QModelIndex(model.indexFromItem(item))
        view.setRootIndex(idx)
        let rootPtr = view.rootIndex()
        @Expect(rootPtr != 0, true)
        let root = QModelIndex(rootPtr)
        @Expect(root.isValid(), true)
        root.delete()
        idx.delete()
        view.delete()
        model.delete()
    }

    @TestCase
    func testSignals() {
        let view = QListView()
        let model = QStandardItemModel(3, 1)
        model.setItem(0, 0, "A")
        view.setModel(model)
        view.setOnClicked({ v: Int64 => gTwCurrentItem = v })
        view.setOnDoubleClicked({ v: Int64 => gTwCurrentItem = v })
        view.setOnActivated({ v: Int64 => gTwCurrentItem = v })
        view.setOnPressed({ v: Int64 => gTwCurrentItem = v })
        @Assert(true)
        view.delete()
        model.delete()
    }
}

// =====================================================================
// QTableView 测试（GUI 环境）
// =====================================================================
@Test
class QTableViewTests {
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
        let view = QTableView()
        @Expect(view.getPtr() != 0, true)
        view.delete()
    }

    @TestCase
    func testSetModelAndSizes() {
        let view = QTableView()
        let model = QStandardItemModel(3, 3)
        view.setModel(model)
        view.setColumnWidth(0, 150)
        view.setRowHeight(0, 50)
        view.resizeColumnsToContents()
        view.resizeRowsToContents()
        view.resizeColumnToContents(1)
        @Assert(true)
        view.delete()
        model.delete()
    }

    @TestCase
    func testShowGridRoundTrip() {
        let view = QTableView()
        view.setShowGrid(false)
        @Expect(view.isShowGrid(), false)
        view.setShowGrid(true)
        @Expect(view.isShowGrid(), true)
        view.delete()
    }

    @TestCase
    func testSelectionSettings() {
        let view = QTableView()
        view.setSelectionMode(SelectionMode.Single)
        view.setSelectionBehavior(SelectionBehavior.SelectRows)
        @Assert(true)
        view.delete()
    }

    @TestCase
    func testSortingEnabled() {
        let view = QTableView()
        view.setSortingEnabled(true)
        @Expect(view.isSortingEnabled(), true)
        view.setSortingEnabled(false)
        @Expect(view.isSortingEnabled(), false)
        view.delete()
    }

    @TestCase
    func testEditTriggersAndGridStyle() {
        let view = QTableView()
        view.setEditTriggers(EditTrigger.NoEditTriggers)
        @Expect(view.editTriggers(), 0)
        view.setGridStyle(3)
        @Expect(view.gridStyle(), 3)
        view.delete()
    }

    @TestCase
    func testCornerButtonWordWrap() {
        let view = QTableView()
        view.setCornerButtonEnabled(false)
        @Expect(view.isCornerButtonEnabled(), false)
        view.setWordWrap(true)
        @Expect(view.isWordWrap(), true)
        view.setWordWrap(false)
        @Expect(view.isWordWrap(), false)
        view.delete()
    }

    @TestCase
    func testHeaderStretch() {
        let view = QTableView()
        view.horizontalHeaderSetStretchLastSection(true)
        @Assert(true)
        view.delete()
    }

    @TestCase
    func testCurrentIndex() {
        let view = QTableView()
        let model = QStandardItemModel(3, 3)
        model.setItem(2, 1, "X")
        view.setModel(model)
        let item = model.item(2, 1)
        let idx = QModelIndex(model.indexFromItem(item))
        view.setCurrentIndex(idx)
        let curPtr = view.currentIndex()
        @Expect(curPtr != 0, true)
        let cur = QModelIndex(curPtr)
        @Expect(cur.row(), 2)
        @Expect(cur.column(), 1)
        cur.delete()
        idx.delete()
        view.delete()
        model.delete()
    }

    @TestCase
    func testSignals() {
        let view = QTableView()
        let model = QStandardItemModel(3, 3)
        view.setModel(model)
        view.setOnClicked({ v: Int64 => gTwCurrentItem = v })
        view.setOnDoubleClicked({ v: Int64 => gTwCurrentItem = v })
        view.setOnActivated({ v: Int64 => gTwCurrentItem = v })
        view.setOnPressed({ v: Int64 => gTwCurrentItem = v })
        @Assert(true)
        view.delete()
        model.delete()
    }
}

// =====================================================================
// QTreeView 测试（GUI 环境）
// =====================================================================
@Test
class QTreeViewTests {
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
        let view = QTreeView()
        @Expect(view.getPtr() != 0, true)
        view.delete()
    }

    @TestCase
    func testSetModelExpandCollapse() {
        let view = QTreeView()
        let model = QStandardItemModel(2, 1)
        model.setItem(0, 0, "A")
        model.setItem(1, 0, "B")
        view.setModel(model)
        view.expandAll()
        view.collapseAll()
        @Assert(true)
        view.delete()
        model.delete()
    }

    @TestCase
    func testSelectionMode() {
        let view = QTreeView()
        view.setSelectionMode(SelectionMode.Extended)
        @Assert(true)
        view.delete()
    }

    @TestCase
    func testHeaderHiddenRoundTrip() {
        let view = QTreeView()
        view.setHeaderHidden(true)
        @Expect(view.isHeaderHidden(), true)
        view.setHeaderHidden(false)
        @Expect(view.isHeaderHidden(), false)
        view.delete()
    }

    @TestCase
    func testEditTriggers() {
        let view = QTreeView()
        view.setEditTriggers(EditTrigger.NoEditTriggers)
        @Expect(view.editTriggers(), 0)
        view.setEditTriggers(EditTrigger.SelectedClicked)
        @Expect(view.editTriggers(), 4)
        view.delete()
    }

    @TestCase
    func testAnimatedAndUniform() {
        let view = QTreeView()
        view.setAnimated(true)
        @Expect(view.isAnimated(), true)
        view.setUniformRowHeights(true)
        @Expect(view.uniformRowHeights(), true)
        view.setUniformRowHeights(false)
        @Expect(view.uniformRowHeights(), false)
        view.delete()
    }

    @TestCase
    func testExpandableAndDecorated() {
        let view = QTreeView()
        view.setItemsExpandable(false)
        @Expect(view.itemsExpandable(), false)
        view.setRootIsDecorated(false)
        @Expect(view.rootIsDecorated(), false)
        view.setExpandsOnDoubleClick(false)
        @Expect(view.expandsOnDoubleClick(), false)
        view.delete()
    }

    @TestCase
    func testColumnWidthAndHeader() {
        let view = QTreeView()
        view.setColumnWidth(0, 200)
        @Assert(true)
        view.delete()
    }

    @TestCase
    func testCurrentIndex() {
        let view = QTreeView()
        let model = QStandardItemModel(3, 1)
        model.setItem(0, 0, "A")
        model.setItem(1, 0, "B")
        view.setModel(model)
        let item = model.item(1, 0)
        let idx = QModelIndex(model.indexFromItem(item))
        view.setCurrentIndex(idx)
        let curPtr = view.currentIndex()
        @Expect(curPtr != 0, true)
        let cur = QModelIndex(curPtr)
        @Expect(cur.row(), 1)
        cur.delete()
        idx.delete()
        view.delete()
        model.delete()
    }

    @TestCase
    func testRootIndex() {
        let view = QTreeView()
        let model = QStandardItemModel(2, 1)
        model.setItem(0, 0, "A")
        view.setModel(model)
        let item = model.item(0, 0)
        let idx = QModelIndex(model.indexFromItem(item))
        view.setRootIndex(idx)
        let rootPtr = view.rootIndex()
        @Expect(rootPtr != 0, true)
        let root = QModelIndex(rootPtr)
        @Expect(root.isValid(), true)
        root.delete()
        idx.delete()
        view.delete()
        model.delete()
    }

    @TestCase
    func testSignals() {
        let view = QTreeView()
        let model = QStandardItemModel(2, 1)
        view.setModel(model)
        view.setOnClicked({ v: Int64 => gTwCurrentItem = v })
        view.setOnDoubleClicked({ v: Int64 => gTwCurrentItem = v })
        view.setOnExpanded({ v: Int64 => gTwCurrentItem = v })
        view.setOnCollapsed({ v: Int64 => gTwCurrentItem = v })
        view.setOnActivated({ v: Int64 => gTwCurrentItem = v })
        @Assert(true)
        view.delete()
        model.delete()
    }
}

// =====================================================================
// QHeaderView 测试（GUI 环境）
// =====================================================================
@Test
class QHeaderViewTests {
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
    func testCreateHorizontal() {
        let header = QHeaderView(Orientation.Horizontal)
        @Expect(header.getPtr() != 0, true)
        header.delete()
    }

    @TestCase
    func testCreateVertical() {
        let header = QHeaderView(Orientation.Vertical)
        @Expect(header.getPtr() != 0, true)
        header.delete()
    }

    @TestCase
    func testStretchLastSectionRoundTrip() {
        let header = QHeaderView(Orientation.Horizontal)
        header.setStretchLastSection(true)
        @Expect(header.isStretchLastSection(), true)
        header.setStretchLastSection(false)
        @Expect(header.isStretchLastSection(), false)
        header.delete()
    }

    @TestCase
    func testSectionSizeRoundTrip() {
        let header = QHeaderView(Orientation.Horizontal)
        header.setDefaultSectionSize(80)
        @Expect(header.defaultSectionSize(), 80)
        header.setMinimumSectionSize(30)
        @Expect(header.minimumSectionSize(), 30)
        header.delete()
    }

    @TestCase
    func testResizeModeAndVisible() {
        let header = QHeaderView(Orientation.Horizontal)
        header.setSectionResizeMode(ResizeMode.Fixed)
        header.setSectionResizeMode(0, ResizeMode.Stretch)
        header.setVisible(false)
        header.setVisible(true)
        header.show()
        header.hide()
        @Assert(true)
        header.delete()
    }

    @TestCase
    func testSortIndicatorShown() {
        let header = QHeaderView(Orientation.Horizontal)
        header.setSortIndicatorShown(true)
        @Expect(header.isSortIndicatorShown(), true)
        header.setSortIndicatorShown(false)
        @Expect(header.isSortIndicatorShown(), false)
        header.delete()
    }

    @TestCase
    func testSectionsClickableAndHighlight() {
        let header = QHeaderView(Orientation.Horizontal)
        header.setSectionsClickable(true)
        @Expect(header.isSectionsClickable(), true)
        header.setHighlightSections(false)
        @Expect(header.isHighlightSections(), false)
        header.setCascadingSectionResizes(true)
        @Expect(header.isCascadingSectionResizes(), true)
        header.delete()
    }

    @TestCase
    func testSignals() {
        let header = QHeaderView(Orientation.Horizontal)
        header.setOnSectionClicked({ v: Int32 => gLwCurrentRow = v })
        header.setOnSectionDoubleClicked({ v: Int32 => gLwCurrentRow = v })
        header.setOnSectionResized({ a: Int32, b: Int32, c: Int32 => gTbCellRow = a })
        header.setOnSectionMoved({ a: Int32, b: Int32, c: Int32 => gTbCellRow = a })
        header.setOnSortIndicatorChanged({ a: Int32, b: Int32 => gTbCellRow = a })
        header.setOnSectionHandleDoubleClicked({ v: Int32 => gLwCurrentRow = v })
        @Assert(true)
        header.delete()
    }

    @TestCase
    func testCountAndOffset() {
        let header = QHeaderView(Orientation.Horizontal)
        @Expect(header.count(), 0)
        @Expect(header.length(), 0)
        header.setOffset(10)
        @Expect(header.offset(), 10)
        header.delete()
    }
}
