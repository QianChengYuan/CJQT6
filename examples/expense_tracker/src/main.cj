// ============================================================
// 个人记账本 - CJQT6 示例
// 功能：收支记录管理、分类统计、数据持久化（SQLite）
// ============================================================

package expense_tracker

import CJQT6.core.*
import CJQT6.widgets.*
import CJQT6.gui.*
import CJQT6.dialogs.*
import CJQT6.sql.*
import CJQT6.views.*
import std.collection.*

// ============================================================
// 全局状态
// ============================================================
var gApp: ?QApplication = None
var gMainWindow: ?MainWindow = None

// 收支类型
let TYPE_EXPENSE: Int32 = 0  // 支出
let TYPE_INCOME: Int32 = 1   // 收入

// 支出分类
let EXPENSE_CATEGORIES: Array<String> = [
    "餐饮", "交通", "购物", "娱乐", "居住", "医疗", "教育", "其他"
]

// 收入分类
let INCOME_CATEGORIES: Array<String> = [
    "工资", "奖金", "投资", "兼职", "其他"
]

// ============================================================
// 记录数据类
// ============================================================
public class Record {
    public var id: Int64 = 0
    public var recordType: Int32 = TYPE_EXPENSE
    public var category: String = ""
    public var amount: Float64 = 0.0
    public var date: String = ""
    public var note: String = ""
    
    public init() {}
}

// ============================================================
// 数据库管理类
// ============================================================
public class DatabaseManager {
    private var db: QSqlDatabase
    private var query: QSqlQuery
    private var nextId: Int64 = 1
    
    public init(db: QSqlDatabase) {
        this.db = db
        this.query = QSqlQuery(db)
        createTables()
        loadMaxId()
    }
    
    private func createTables(): Unit {
        let sql = "CREATE TABLE IF NOT EXISTS records (id INTEGER PRIMARY KEY, type INTEGER, category TEXT, amount REAL, date TEXT, note TEXT)"
        query.exec(sql)
    }
    
    private func loadMaxId(): Unit {
        query.exec("SELECT MAX(id) FROM records")
        if (query.next()) {
            nextId = Int64(query.valueInt(0)) + 1
        }
    }
    
    public func addRecord(recordType: Int32, category: String, amount: Float64, date: String, note: String): Int64 {
        let id = nextId
        nextId = nextId + 1
        let sql = "INSERT INTO records (id, type, category, amount, date, note) VALUES (${id}, ${recordType}, '${category}', ${amount}, '${date}', '${note}')"
        if (query.exec(sql)) { return id }
        return 0
    }
    
    public func deleteRecord(id: Int64): Bool {
        return query.exec("DELETE FROM records WHERE id = ${id}")
    }
    
    public func getRecordsByMonth(yearMonth: String): ArrayList<Record> {
        let records = ArrayList<Record>()
        query.exec("SELECT id, type, category, amount, date, note FROM records WHERE date LIKE '${yearMonth}%' ORDER BY date DESC")
        while (query.next()) {
            let record = Record()
            record.id = Int64(query.valueInt(0))
            record.recordType = query.valueInt(1)
            record.category = query.valueString(2)
            record.amount = stringToFloat(query.valueString(3))
            record.date = query.valueString(4)
            record.note = query.valueString(5)
            records.add(record)
        }
        return records
    }
    
    public func getStatistics(yearMonth: String): (Float64, Float64) {
        var totalExpense: Float64 = 0.0
        var totalIncome: Float64 = 0.0
        query.exec("SELECT type, SUM(amount) FROM records WHERE date LIKE '${yearMonth}%' GROUP BY type")
        while (query.next()) {
            let recordType = query.valueInt(0)
            let amount = stringToFloat(query.valueString(1))
            if (recordType == TYPE_EXPENSE) { totalExpense = totalExpense + amount }
            else { totalIncome = totalIncome + amount }
        }
        return (totalExpense, totalIncome)
    }
    
    private func stringToFloat(s: String): Float64 {
        var result: Float64 = 0.0
        var negative = false
        var decimal = false
        var decimalPlace: Float64 = 0.1
        var start = 0
        if (s.size > 0 && s[0] == 45) { negative = true; start = 1 }
        for (i in start..s.size) {
            let c = s[i]
            if (c >= 48 && c <= 57) {
                if (decimal) { result = result + Float64(c - 48) * decimalPlace; decimalPlace = decimalPlace * 0.1 }
                else { result = result * 10.0 + Float64(c - 48) }
            } else if (c == 46) { decimal = true }
        }
        return if (negative) { -result } else { result }
    }
    
    public func close(): Unit { query.finish(); query.delete() }
}

// ============================================================
// 顶层回调函数
// ============================================================
func onTypeChanged(index: Int32): Unit {
    if (let Some(w) <- gMainWindow) { w.doTypeChanged(index) }
}

func onAddRecord(): Unit {
    if (let Some(w) <- gMainWindow) { w.doAddRecord() }
}

func onDeleteRecord(): Unit {
    if (let Some(w) <- gMainWindow) { w.doDeleteRecord() }
}

// ============================================================
// 主窗口类
// ============================================================
public class MainWindow {
    private var window: QWidget
    private var dbManager: ?DatabaseManager = None
    private var records: ArrayList<Record> = ArrayList<Record>()
    
    private var typeCombo: QComboBox
    private var categoryCombo: QComboBox
    private var amountEdit: QLineEdit
    private var noteEdit: QLineEdit
    private var dateEdit: QDateEdit
    private var tableWidget: QTableWidget
    private var totalExpenseLabel: QLabel
    private var totalIncomeLabel: QLabel
    private var balanceLabel: QLabel
    private var currentYearMonth: String = ""
    
    public init(db: QSqlDatabase) {
        window = QWidget()
        dbManager = DatabaseManager(db)
        typeCombo = QComboBox()
        categoryCombo = QComboBox()
        amountEdit = QLineEdit()
        noteEdit = QLineEdit()
        dateEdit = QDateEdit()
        tableWidget = QTableWidget()
        totalExpenseLabel = QLabel()
        totalIncomeLabel = QLabel()
        balanceLabel = QLabel()
        
        let today = QDateTime.currentDateTime()
        let dateStr = today.date().toString()
        // 日期格式: "yyyy-MM-dd"，截取 "yyyy-MM"
        currentYearMonth = if (dateStr.size >= 7) { dateStr[0..7] } else { "" }
        
        setupUI()
        loadData()
    }
    
    private func setupUI(): Unit {
        window.setTitle("个人记账本 - CJQT6")
        window.resize(900, 600)

        let mainLayout = QVBoxLayout()
        let inputLayout = QGridLayout()

        // 类型选择
        let typeLabel = QLabel()
        typeLabel.setText("类型:")
        typeCombo.addItem("支出")
        typeCombo.addItem("收入")
        typeCombo.setOnCurrentIndexChanged({ index => onTypeChanged(index) })

        // 日期选择
        let dateLabel = QLabel()
        dateLabel.setText("日期:")
        dateEdit.setCalendarPopup(true)
        dateEdit.setDisplayFormat("yyyy-MM-dd")
        let today = QDate.currentDate()
        dateEdit.setDate(today)

        // 分类选择
        let categoryLabel = QLabel()
        categoryLabel.setText("分类:")
        doTypeChanged(TYPE_EXPENSE)

        // 金额输入
        let amountLabel = QLabel()
        amountLabel.setText("金额:")

        // 备注输入
        let noteLabel = QLabel()
        noteLabel.setText("备注:")

        // 按钮
        let addButton = QPushButton()
        addButton.setText("添加记录")
        addButton.setOnClick({ => onAddRecord() })

        let deleteButton = QPushButton()
        deleteButton.setText("删除选中")
        deleteButton.setOnClick({ => onDeleteRecord() })

        // 布局：第一行 - 类型、日期
        inputLayout.addWidget(typeLabel.getPtr(), 0, 0)
        inputLayout.addWidget(typeCombo.getPtr(), 0, 1)
        inputLayout.addWidget(dateLabel.getPtr(), 0, 2)
        inputLayout.addWidget(dateEdit.getPtr(), 0, 3)
        // 布局：第二行 - 分类、金额、备注
        inputLayout.addWidget(categoryLabel.getPtr(), 1, 0)
        inputLayout.addWidget(categoryCombo.getPtr(), 1, 1)
        inputLayout.addWidget(amountLabel.getPtr(), 1, 2)
        inputLayout.addWidget(amountEdit.getPtr(), 1, 3)
        inputLayout.addWidget(noteLabel.getPtr(), 1, 4)
        inputLayout.addWidget(noteEdit.getPtr(), 1, 5)
        // 布局：第三行 - 按钮
        inputLayout.addWidget(addButton.getPtr(), 2, 1)
        inputLayout.addWidget(deleteButton.getPtr(), 2, 3)

        let statsLayout = QHBoxLayout()
        totalExpenseLabel.setText("支出: ¥0.00")
        totalIncomeLabel.setText("收入: ¥0.00")
        balanceLabel.setText("结余: ¥0.00")
        statsLayout.addWidget(totalExpenseLabel.getPtr())
        statsLayout.addWidget(totalIncomeLabel.getPtr())
        statsLayout.addWidget(balanceLabel.getPtr())
        statsLayout.addStretch()
        
        tableWidget.setColumnCount(5)
        tableWidget.setHorizontalHeaderLabel(0, "日期")
        tableWidget.setHorizontalHeaderLabel(1, "类型")
        tableWidget.setHorizontalHeaderLabel(2, "分类")
        tableWidget.setHorizontalHeaderLabel(3, "金额")
        tableWidget.setHorizontalHeaderLabel(4, "备注")
        tableWidget.setSelectionBehavior(SelectRows)
        tableWidget.setSelectionMode(SingleSelection)
        tableWidget.setAutoFillWidth()
        tableWidget.setDefaultRowHeight(30)
        
        mainLayout.addLayout(inputLayout.getPtr())
        mainLayout.addLayout(statsLayout.getPtr())
        mainLayout.addWidget(tableWidget.getPtr())
        window.setLayout(mainLayout.getPtr())
    }
    
    public func doTypeChanged(index: Int32): Unit {
        categoryCombo.clear()
        let categories = if (index == TYPE_EXPENSE) { EXPENSE_CATEGORIES } else { INCOME_CATEGORIES }
        for (cat in categories) { categoryCombo.addItem(cat) }
    }
    
    public func doAddRecord(): Unit {
        let recordType = typeCombo.currentIndex()
        let category = categoryCombo.currentText()
        let amountStr = amountEdit.text()
        let note = noteEdit.text()
        let selectedDate = dateEdit.date()
        let date = selectedDate.toString()

        if (amountStr.isEmpty()) { QMessageBox.warning(0, "提示", "请输入金额"); return }
        let amount = stringToFloat(amountStr)
        if (amount <= 0.0) { QMessageBox.warning(0, "提示", "金额必须大于0"); return }

        if (let Some(db) <- dbManager) {
            if (db.addRecord(recordType, category, amount, date, note) > 0) {
                amountEdit.setText("")
                noteEdit.setText("")
                // 更新当前月份为选择日期的月份
                currentYearMonth = if (date.size >= 7) { date[0..7] } else { "" }
                loadData()
            } else { QMessageBox.warning(0, "错误", "添加记录失败") }
        }
    }
    
    public func doDeleteRecord(): Unit {
        let row = Int64(tableWidget.currentRow())
        if (row < 0 || row >= records.size) { QMessageBox.warning(0, "提示", "请先选择一条记录"); return }
        if (QMessageBox.question(0, "确认", "确定要删除这条记录吗？")) {
            let record = records[row]
            if (let Some(db) <- dbManager) { if (db.deleteRecord(record.id)) { loadData() } }
        }
    }
    
    private func loadData(): Unit {
        if (let Some(db) <- dbManager) {
            records = db.getRecordsByMonth(currentYearMonth)
            tableWidget.setRowCount(0)
            for (record in records) {
                let row = tableWidget.rowCount()
                tableWidget.insertRow(row)
                tableWidget.setItem(row, 0, record.date)
                tableWidget.setItem(row, 1, if (record.recordType == TYPE_EXPENSE) { "支出" } else { "收入" })
                tableWidget.setItem(row, 2, record.category)
                tableWidget.setItem(row, 3, "¥${formatAmount(record.amount)}")
                tableWidget.setItem(row, 4, record.note)
            }
            updateStatistics()
        }
    }
    
    private func updateStatistics(): Unit {
        if (let Some(db) <- dbManager) {
            let (totalExpense, totalIncome) = db.getStatistics(currentYearMonth)
            let balance = totalIncome - totalExpense
            totalExpenseLabel.setText("支出: ¥${formatAmount(totalExpense)}")
            totalIncomeLabel.setText("收入: ¥${formatAmount(totalIncome)}")
            balanceLabel.setText("结余: ¥${formatAmount(balance)}")
        }
    }
    
    private func formatAmount(amount: Float64): String {
        let intPart = Int64(amount)
        let decimalPart = Int64((amount - Float64(intPart)) * 100.0 + 0.5)
        return "${intPart}.${if (decimalPart < 10) { "0" } else { "" }}${decimalPart}"
    }
    
    private func stringToFloat(s: String): Float64 {
        var result: Float64 = 0.0
        var negative = false
        var decimal = false
        var decimalPlace: Float64 = 0.1
        var start = 0
        if (s.size > 0 && s[0] == 45) { negative = true; start = 1 }
        for (i in start..s.size) {
            let c = s[i]
            if (c >= 48 && c <= 57) {
                if (decimal) { result = result + Float64(c - 48) * decimalPlace; decimalPlace = decimalPlace * 0.1 }
                else { result = result * 10.0 + Float64(c - 48) }
            } else if (c == 46) { decimal = true }
        }
        return if (negative) { -result } else { result }
    }
    
    public func show(): Unit { window.show() }
    
    public func delete(): Unit {
        if (let Some(db) <- dbManager) { db.close() }
        typeCombo.delete()
        categoryCombo.delete()
        amountEdit.delete()
        noteEdit.delete()
        dateEdit.delete()
        tableWidget.delete()
        totalExpenseLabel.delete()
        totalIncomeLabel.delete()
        balanceLabel.delete()
        window.delete()
    }
}

// ============================================================
// 主函数
// ============================================================
main() {
    gApp = QApplication()
    let db = QSqlDatabase.addDatabase(SqlDriver.sqlite(), "expense_tracker")
    db.setDatabaseName("expense.db")
    if (!db.open()) { println("数据库打开失败: ${db.lastError()}"); return }
    
    gMainWindow = MainWindow(db)
    if (let Some(w) <- gMainWindow) { w.show() }
    if (let Some(a) <- gApp) { a.exec() }
    
    if (let Some(w) <- gMainWindow) { w.delete() }
    db.close()
    db.delete()
}
