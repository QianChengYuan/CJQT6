// ============================================================
// 宿舍管理系统 - 主入口 & UI
// 功能：登录管理（宿管/学生/管理员）、权限控制、宿舍管理
// ============================================================
package dormitory_manager

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import cjqt6.dialogs.*
import cjqt6.menu.*
import cjqt6.views.*
import cjqt6.sql.*
import std.collection.*

// ============================================================
// 全局状态
// ============================================================
var gApp: ?QApplication = None
var gDb: ?DatabaseManager = None
var gCurrentUser: ?User = None
var gLoginWindow: ?QWidget = None
var gMainWindow: ?QMainWindow = None
var gStackedWidget: ?QStackedWidget = None  // 登录页(0) / 主界面(1)
var gStatusLabel: ?QLabel = None            // 登录页状态
var gUsernameEdit: ?QLineEdit = None        // 登录用户名
var gPasswordEdit: ?QLineEdit = None        // 登录密码
var gTabWidget: ?QTabWidget = None          // 主界面Tab

// ============================================================
// 辅助工厂函数
// ============================================================

func createLabel(text: String): QLabel {
    let l = QLabel()
    l.setText(text)
    l
}

func createButton(text: String, onClick: VoidCallback): QPushButton {
    let btn = QPushButton()
    btn.setText(text)
    btn.setOnClick(onClick)
    btn
}

func createLineEdit(placeholder: String): QLineEdit {
    let e = QLineEdit()
    e.setPlaceholder(placeholder)
    e
}

/// 创建带左侧标签的水平行，返回布局指针
func createLabeledRow(labelText: String, widgetPtr: Int64): Int64 {
    let row = QHBoxLayout()
    let lb = createLabel(labelText)
    row.addWidget(lb.getPtr())
    row.addWidget(widgetPtr)
    row.getPtr()
}

/// 创建卡片样式的统计标签
func createStatCard(title: String, value: String, color: String): QWidget {
    let card = QWidget()
    let layout = QVBoxLayout()
    layout.setMargin(15)
    layout.setSpacing(5)

    let titleLabel = createLabel(title)
    titleLabel.setAlignment(Alignment.Center.value)
    layout.addWidget(titleLabel.getPtr())

    let valueLabel = createLabel(value)
    valueLabel.setAlignment(Alignment.Center.value)
    valueLabel.setStyleSheet("font-size: 28px; font-weight: bold; color: ${color};")
    layout.addWidget(valueLabel.getPtr())

    card.setLayout(layout.getPtr())
    card.setStyleSheet("background-color: white; border: 1px solid #ddd; border-radius: 8px;")
    card.setMinimumSize(150, 90)
    card
}

/// 从ID字符串中解析出数字（如 "ID: 123" -> 123）
func parseIdFromString(s: String): Int64 {
    var id: Int64 = 0
    for (c in s) {
        if (c >= 48 && c <= 57) {
            id = id * 10 + Int64(c - 48)
        }
    }
    return id
}

/// 清除表格所有行
func clearTable(table: QTableWidget): Unit {
    table.setRowCount(0)
}

/// 向表格添加一行文本
func addTableRow(table: QTableWidget, cols: Array<String>): Unit {
    let row = table.rowCount()
    table.insertRow(row)
    for (i in 0..cols.size) {
        table.setItem(row, Int32(i), cols[i])
    }
}

// ============================================================
// 回调函数声明（顶层 let，给按钮等使用）
// ============================================================

let onLoginClick: VoidCallback = { =>
    doLogin()
}

let onLogoutClick: VoidCallback = { =>
    doLogout()
}

let onRegisterClick: VoidCallback = { =>
    showRegisterDialog()
}

let onLoginReturnPressed: VoidCallback = { =>
    doLogin()
}

// ============================================================
// 核心业务函数
// ============================================================

func doLogin(): Unit {
    if (let Some(edit) <- gUsernameEdit) {
        if (let Some(pwd) <- gPasswordEdit) {
            let username = edit.text()
            let password = pwd.text()
            if (username.isEmpty() || password.isEmpty()) {
                if (let Some(label) <- gStatusLabel) { label.setText("⚠ 请输入用户名和密码") }
                return
            }
            if (let Some(db) <- gDb) {
                let userOpt = db.login(username, password)
                if (let Some(user) <- userOpt) {
                    gCurrentUser = Some(user)
                    if (let Some(label) <- gStatusLabel) { label.setText("✓ 登录成功！") }
                    showMainDashboard()
                } else {
                    if (let Some(label) <- gStatusLabel) { label.setText("✗ 用户名或密码错误") }
                }
            }
        }
    }
}

func doLogout(): Unit {
    gCurrentUser = None
    // 清理主界面
    if (let Some(mw) <- gMainWindow) { mw.delete(); gMainWindow = None }
    if (let Some(stack) <- gStackedWidget) { stack.setCurrentIndex(0) }
    // 重置登录
    if (let Some(edit) <- gUsernameEdit) { edit.setText("") }
    if (let Some(pwd) <- gPasswordEdit) { pwd.setText("") }
    if (let Some(label) <- gStatusLabel) { label.setText("") }
    // 显示登录窗口
    if (let Some(lw) <- gLoginWindow) { lw.show() }
}

func showMainDashboard(): Unit {
    if (let Some(loginW) <- gLoginWindow) { loginW.hide() }
    if (let Some(user) <- gCurrentUser) {
        if (user.role == ROLE_ADMIN) { buildAdminDashboard() }
        else if (user.role == ROLE_MANAGER) { buildManagerDashboard() }
        else if (user.role == ROLE_STUDENT) { buildStudentDashboard() }
    }
    if (let Some(stack) <- gStackedWidget) { stack.setCurrentIndex(1) }
}

// ============================================================
// 注册对话框
// ============================================================
var gRegisterDialog: ?QWidget = None

let onRegisterConfirm: VoidCallback = { =>
    doRegister()
}
let onRegisterCancel: VoidCallback = { =>
    closeRegisterDialog()
}

func closeRegisterDialog(): Unit {
    if (let Some(d) <- gRegisterDialog) { d.hide(); d.delete(); gRegisterDialog = None }
}

var gRegUsername: ?QLineEdit = None
var gRegPassword: ?QLineEdit = None
var gRegName: ?QLineEdit = None
var gRegPhone: ?QLineEdit = None
var gRegStudentNo: ?QLineEdit = None
var gRegClass: ?QLineEdit = None
var gRegRole: ?QComboBox = None
var gRegGender: ?QComboBox = None

func showRegisterDialog(): Unit {
    if (let Some(d) <- gRegisterDialog) { d.show(); return }

    let dialog = QWidget()
    dialog.setTitle("注册新账号")
    dialog.resize(380, 400)
    gRegisterDialog = dialog

    let layout = QVBoxLayout()
    layout.setMargin(20)
    layout.setSpacing(10)

    let title = createLabel("注册新账号")
    title.setStyleSheet("font-size: 18px; font-weight: bold;")
    title.setAlignment(Alignment.Center.value)
    layout.addWidget(title.getPtr())

    // 用户名
    let usernameEdit = createLineEdit("用户名（登录用）")
    gRegUsername = usernameEdit
    let row1 = createLabeledRow("用户名:", usernameEdit.getPtr())
    layout.addLayout(row1)

    // 密码
    let pwdEdit = createLineEdit("密码")
    pwdEdit.setEchoMode(LineEditEchoMode.Password)
    gRegPassword = pwdEdit
    let row2 = createLabeledRow("密码:", pwdEdit.getPtr())
    layout.addLayout(row2)

    // 姓名
    let nameEdit = createLineEdit("真实姓名")
    gRegName = nameEdit
    let row3 = createLabeledRow("姓名:", nameEdit.getPtr())
    layout.addLayout(row3)

    // 电话
    let phoneEdit = createLineEdit("手机号")
    gRegPhone = phoneEdit
    let row4 = createLabeledRow("电话:", phoneEdit.getPtr())
    layout.addLayout(row4)

    // 角色
    let roleCombo = QComboBox()
    roleCombo.addItem("学生")
    roleCombo.addItem("宿管")
    gRegRole = roleCombo
    let row5 = createLabeledRow("角色:", roleCombo.getPtr())
    layout.addLayout(row5)

    // 学号（学生用）
    let studentNoEdit = createLineEdit("学号（学生必填）")
    gRegStudentNo = studentNoEdit
    let row6 = createLabeledRow("学号:", studentNoEdit.getPtr())
    layout.addLayout(row6)

    // 班级
    let classEdit = createLineEdit("班级（学生必填）")
    gRegClass = classEdit
    let row7 = createLabeledRow("班级:", classEdit.getPtr())
    layout.addLayout(row7)

    // 性别
    let genderCombo = QComboBox()
    genderCombo.addItem("male")
    genderCombo.addItem("female")
    gRegGender = genderCombo
    let row8 = createLabeledRow("性别:", genderCombo.getPtr())
    layout.addLayout(row8)

    // 按钮
    let btnRow = QHBoxLayout()
    let confirmBtn = createButton("确认注册", onRegisterConfirm)
    confirmBtn.setStyleSheet("background-color: #3498db; color: white; padding: 8px;")
    let cancelBtn = createButton("取消", onRegisterCancel)
    btnRow.addWidget(confirmBtn.getPtr())
    btnRow.addWidget(cancelBtn.getPtr())
    layout.addLayout(btnRow.getPtr())

    layout.addStretch()
    dialog.setLayout(layout.getPtr())
    dialog.show()
}

func doRegister(): Unit {
    let username = if (let Some(e) <- gRegUsername) { e.text() } else { "" }
    let password = if (let Some(e) <- gRegPassword) { e.text() } else { "" }
    let name = if (let Some(e) <- gRegName) { e.text() } else { "" }
    let phone = if (let Some(e) <- gRegPhone) { e.text() } else { "" }
    let roleIdx = if (let Some(c) <- gRegRole) { c.currentIndex() } else { 0i32 }
    let studentNo = if (let Some(e) <- gRegStudentNo) { e.text() } else { "" }
    let className = if (let Some(e) <- gRegClass) { e.text() } else { "" }
    let genderIdx = if (let Some(c) <- gRegGender) { c.currentIndex() } else { 0i32 }

    if (username.isEmpty() || password.isEmpty() || name.isEmpty()) {
        QMessageBox.warning(0, "提示", "请填写必填字段（用户名、密码、姓名）")
        return
    }

    let role = if (roleIdx == 0) { ROLE_STUDENT } else { ROLE_MANAGER }
    let gender = if (genderIdx == 0) { "male" } else { "female" }

    if (let Some(db) <- gDb) {
        let userId = db.addUser(username, password, role, name, phone)
        if (userId > 0) {
            if (role == ROLE_STUDENT && !studentNo.isEmpty() && !className.isEmpty()) {
                db.addStudent(userId, studentNo, name, gender, phone, className, 2024, 0, 0, 0)
            }
            QMessageBox.information(0, "成功", "注册成功！请等待管理员分配宿舍。")
            closeRegisterDialog()
        } else {
            QMessageBox.warning(0, "错误", "注册失败，用户名可能已存在。")
        }
    }
}

// ============================================================
// 通用 - 创建表格
// ============================================================
func createTable(headers: Array<String>): QTableWidget {
    let table = QTableWidget()
    table.setColumnCount(Int32(headers.size))
    for (i in 0..headers.size) {
        table.setHorizontalHeaderLabel(Int32(i), headers[Int64(i)])
    }
    table.setSelectionBehavior(SelectRows)
    table.setSelectionMode(SingleSelection)
    table.setAutoFillWidth()
    table.setDefaultRowHeight(28)
    table.setAlternatingRowColors(true)
    table
}

// ============================================================
// 构建登录界面
// ============================================================
func buildLoginUI(): QWidget {
    let window = QWidget()
    window.setTitle("宿舍管理系统 - 登录")
    window.resize(400, 350)

    let layout = QVBoxLayout()
    layout.setMargin(30)
    layout.setSpacing(12)

    // 标题
    let title = createLabel("🏠 宿舍管理系统")
    title.setStyleSheet("font-size: 22px; font-weight: bold; color: #2c3e50;")
    title.setAlignment(Alignment.Center.value)
    layout.addWidget(title.getPtr())

    layout.addStretch()

    // 用户名
    let usernameEdit = createLineEdit("请输入用户名")
    gUsernameEdit = usernameEdit
    let row1 = createLabeledRow("用户名:", usernameEdit.getPtr())
    layout.addLayout(row1)

    // 密码
    let pwdEdit = createLineEdit("请输入密码")
    pwdEdit.setEchoMode(LineEditEchoMode.Password)
    pwdEdit.setOnReturnPressed(onLoginReturnPressed)  // 回车登录
    gPasswordEdit = pwdEdit
    let row2 = createLabeledRow("密  码:", pwdEdit.getPtr())
    layout.addLayout(row2)

    layout.addStretch()

    // 登录按钮
    let loginBtn = createButton("登  录", onLoginClick)
    loginBtn.setStyleSheet("background-color: #3498db; color: white; font-size: 14px; padding: 8px;")
    layout.addWidget(loginBtn.getPtr())

    // 注册按钮
    let regBtn = createButton("注册账号", onRegisterClick)
    layout.addWidget(regBtn.getPtr())

    // 状态标签
    let status = createLabel("")
    status.setAlignment(Alignment.Center.value)
    status.setStyleSheet("color: #e74c3c;")
    gStatusLabel = status
    layout.addWidget(status.getPtr())

    // 提示
    let tip = createLabel("默认账号: admin/admin123   学生: student1/stu123   宿管: manager1/manager123")
    tip.setStyleSheet("color: #95a5a6; font-size: 11px;")
    tip.setAlignment(Alignment.Center.value)
    layout.addWidget(tip.getPtr())

    layout.addStretch()
    window.setLayout(layout.getPtr())
    return window
}

// ============================================================
// 构建 - 管理员仪表板
// ============================================================
func buildAdminDashboard(): Unit {
    if (let Some(mw) <- gMainWindow) { mw.show(); return }

    let window = QMainWindow()
    window.setTitle("宿舍管理系统 - 管理员面板")
    window.resize(1100, 700)
    gMainWindow = window

    // 菜单栏
    let menuBar = QMenuBar()
    let userMenu = menuBar.addMenu("系统(&S)")
    let logoutAction = userMenu.addAction("退出登录(&L)")
    logoutAction.setOnTriggered(onLogoutClick)
    let exitAction = userMenu.addAction("退出系统(&X)")
    exitAction.setOnTriggered({ => if (let Some(a) <- gApp) { a.quit() } })
    window.setMenuBar(menuBar.getPtr())

    // 状态栏
    let statusBar = QStatusBar()
    if (let Some(u) <- gCurrentUser) {
        statusBar.showMessage("当前用户: ${u.displayName} (${getRoleDisplay(u.role)})")
    }
    window.setStatusBar(statusBar.getPtr())

    // TabWidget
    let tab = QTabWidget()
    gTabWidget = tab

    // ---- 首页 ----
    tab.addTab(buildAdminHomePage().getPtr(), "📊 首页")

    // ---- 宿舍楼管理 ----
    tab.addTab(buildBuildingPage().getPtr(), "🏢 宿舍楼")

    // ---- 房间管理 ----
    tab.addTab(buildAdminRoomPage().getPtr(), "🚪 房间")

    // ---- 学生管理 ----
    tab.addTab(buildAdminStudentPage().getPtr(), "👤 学生")

    // ---- 宿管管理 ----
    tab.addTab(buildManagerManagePage().getPtr(), "👥 宿管")

    // ---- 考勤管理 ----
    tab.addTab(buildAdminAttendancePage().getPtr(), "📋 考勤")

    // ---- 报修管理 ----
    tab.addTab(buildAdminRepairPage().getPtr(), "🔧 报修")

    // ---- 公告管理 ----
    tab.addTab(buildAdminAnnouncementPage().getPtr(), "📢 公告")

    window.setCentralWidget(tab.getPtr())
    window.show()
}

// ============================================================
// 首页 - 统计卡片
// ============================================================
var gStatsRefreshCallback: VoidCallback = { => }
let onRefreshStats: VoidCallback = { => unsafe { gStatsRefreshCallback() } }

func buildStatPage(stats: DashboardStats): QWidget {
    let page = QWidget()
    let layout = QVBoxLayout()
    layout.setMargin(20)
    layout.setSpacing(15)

    let title = createLabel("系统概览")
    title.setStyleSheet("font-size: 20px; font-weight: bold;")
    layout.addWidget(title.getPtr())

    // 刷新按钮
    let refreshBtn = createButton("🔄 刷新数据", onRefreshStats)
    refreshBtn.setStyleSheet("background-color: #2ecc71; color: white; padding: 6px 16px;")
    layout.addWidget(refreshBtn.getPtr())

    // 统计卡片行
    let cardRow = QHBoxLayout()
    cardRow.setSpacing(15)

    let card1 = createStatCard("宿舍楼", "${stats.totalBuildings}", "#3498db")
    cardRow.addWidget(card1.getPtr())
    let card2 = createStatCard("房间数", "${stats.totalRooms}", "#2ecc71")
    cardRow.addWidget(card2.getPtr())
    let card3 = createStatCard("学生数", "${stats.totalStudents}", "#e67e22")
    cardRow.addWidget(card3.getPtr())
    let card4 = createStatCard("宿管数", "${stats.totalManagers}", "#9b59b6")
    cardRow.addWidget(card4.getPtr())
    let card5 = createStatCard("待处理报修", "${stats.pendingRepairs}", "#e74c3c")
    cardRow.addWidget(card5.getPtr())
    let card6 = createStatCard("可用床位", "${stats.availableBeds}", "#1abc9c")
    cardRow.addWidget(card6.getPtr())

    layout.addLayout(cardRow.getPtr())

    layout.addStretch()
    page.setLayout(layout.getPtr())
    return page
}

func buildAdminHomePage(): QWidget {
    let stats = if (let Some(db) <- gDb) { db.getDashboardStats() } else { DashboardStats() }
    let page = buildStatPage(stats)
    gStatsRefreshCallback = { =>
        if (let Some(tab) <- gTabWidget) {
            let newStats = if (let Some(db) <- gDb) { db.getDashboardStats() } else { DashboardStats() }
            tab.removeTab(0)
            tab.insertTab(0, buildStatPage(newStats).getPtr(), "📊 首页")
            tab.setCurrentIndex(0)
        }
    }
    return page
}

// ============================================================
// 宿舍楼管理
// ============================================================
var gBuildingTable: ?QTableWidget = None
let onAddBuilding: VoidCallback = { => showBuildingDialog(0) }
let onEditBuilding: VoidCallback = { => showBuildingDialog(1) }
let onDeleteBuilding: VoidCallback = { => doDeleteBuilding() }
let onRefreshBuilding: VoidCallback = { => refreshBuildingTable() }

func refreshBuildingTable(): Unit {
    if (let Some(db) <- gDb) {
        if (let Some(table) <- gBuildingTable) {
            clearTable(table)
            let buildings = db.getAllBuildings()
            for (b in buildings) {
                addTableRow(table, [
                    "${b.id}", b.name, "${b.floors}", "${b.roomsPerFloor}",
                    b.address, b.managerName
                ])
            }
        }
    }
}

func showBuildingDialog(mode: Int32): Unit {
    let title = if (mode == 0) { "添加宿舍楼" } else { "编辑宿舍楼" }
    let dialog = QWidget()
    dialog.setTitle(title)
    dialog.resize(400, 300)

    let layout = QVBoxLayout()
    layout.setMargin(20)
    layout.setSpacing(10)

    let nameEdit = createLineEdit("楼名（如: 静苑1号楼）")
    let floorsEdit = createLineEdit("楼层数")
    let roomsEdit = createLineEdit("每层房间数")
    let addressEdit = createLineEdit("地址")

    // 宿管选择
    let managerCombo = QComboBox()
    let managers = if (let Some(db) <- gDb) { db.getUsersByRole(ROLE_MANAGER) } else { ArrayList<User>() }
    managerCombo.addItem("无")
    var selectedManagerId: Int64 = 0
    for (m in managers) {
        managerCombo.addItem("${m.displayName} (${m.username})")
    }

    if (mode == 1) {
        if (let Some(table) <- gBuildingTable) {
            let row = table.currentRow()
            if (row >= 0) {
                nameEdit.setText(table.itemText(row, 1))
                floorsEdit.setText(table.itemText(row, 2))
                roomsEdit.setText(table.itemText(row, 3))
                addressEdit.setText(table.itemText(row, 4))
                let managerName = table.itemText(row, 5)
                for (i in 0..managers.size) {
                    if (managers[Int64(i)].displayName == managerName) {
                        managerCombo.setCurrentIndex(Int32(i + 1))
                        selectedManagerId = managers[Int64(i)].id
                        break
                    }
                }
            }
        }
    }

    layout.addLayout(createLabeledRow("楼名:", nameEdit.getPtr()))
    layout.addLayout(createLabeledRow("楼层:", floorsEdit.getPtr()))
    layout.addLayout(createLabeledRow("房间数:", roomsEdit.getPtr()))
    layout.addLayout(createLabeledRow("地址:", addressEdit.getPtr()))
    layout.addLayout(createLabeledRow("宿管:", managerCombo.getPtr()))

    // 用 capture API 避免 CFunc 不能捕获局部变量的问题
    let saveBtn = QPushButton()
    saveBtn.setText("保存")
    saveBtn.setStyleSheet("background-color: #3498db; color: white;")
    let _bldgConn = saveBtn.setOnClickCapture({ =>
        let name = nameEdit.text()
        let floorsStr = floorsEdit.text()
        let roomsStr = roomsEdit.text()
        let address = addressEdit.text()
        let mgrIdx = managerCombo.currentIndex()
        if (name.isEmpty() || floorsStr.isEmpty() || roomsStr.isEmpty()) {
            QMessageBox.warning(0, "提示", "请填写完整信息")
            return
        }
        var floors: Int32 = 0
        for (c in floorsStr) { if (c >= 48 && c <= 57) { floors = floors * 10 + Int32(c - 48) } }
        var roomsPerF: Int32 = 0
        for (c in roomsStr) { if (c >= 48 && c <= 57) { roomsPerF = roomsPerF * 10 + Int32(c - 48) } }
        let mgrId = if (mgrIdx > 0 && Int64(mgrIdx - 1) < managers.size) { managers[Int64(mgrIdx - 1)].id } else { 0 }

        if (let Some(db) <- gDb) {
            if (mode == 0) {
                let bid = db.addBuilding(name, floors, roomsPerF, address, mgrId)
                if (bid > 0) {
                    for (f in 0..floors) {
                        for (r in 0..roomsPerF) {
                            let roomNo = "${f + 1}${if (r < 9) { "0" } else { "" }}${r + 1}"
                            db.addRoom(bid, roomNo, f + 1, 4)
                        }
                    }
                    QMessageBox.information(0, "成功", "宿舍楼创建成功！已自动生成 ${floors * roomsPerF} 个房间。")
                }
            } else {
                if (let Some(table) <- gBuildingTable) {
                    let row = table.currentRow()
                    let idStr = table.itemText(row, 0)
                    var bid: Int64 = 0
                    for (c in idStr) { if (c >= 48 && c <= 57) { bid = bid * 10 + Int64(c - 48) } }
                    db.updateBuilding(bid, name, floors, roomsPerF, address, mgrId)
                    QMessageBox.information(0, "成功", "宿舍楼信息已更新。")
                }
            }
            refreshBuildingTable()
            dialog.hide(); dialog.delete()
        }
    })
    layout.addWidget(saveBtn.getPtr())
    layout.addStretch()
    dialog.setLayout(layout.getPtr())
    dialog.show()
}

func doDeleteBuilding(): Unit {
    if (let Some(table) <- gBuildingTable) {
        let row = table.currentRow()
        if (row < 0) { QMessageBox.warning(0, "提示", "请先选择要删除的宿舍楼"); return }
        if (QMessageBox.question(0, "确认", "确定要删除该宿舍楼及其所有房间吗？")) {
            let idStr = table.itemText(row, 0)
            var bid: Int64 = 0
            for (c in idStr) { if (c >= 48 && c <= 57) { bid = bid * 10 + Int64(c - 48) } }
            if (let Some(db) <- gDb) { db.deleteBuilding(bid) }
            refreshBuildingTable()
        }
    }
}

func buildBuildingPage(): QWidget {
    let page = QWidget()
    let layout = QVBoxLayout()
    layout.setMargin(15)
    layout.setSpacing(10)

    // 工具栏
    let toolRow = QHBoxLayout()
    let addBtn = createButton("➕ 添加", onAddBuilding)
    addBtn.setStyleSheet("background-color: #3498db; color: white;")
    let editBtn = createButton("✏ 编辑", onEditBuilding)
    editBtn.setStyleSheet("background-color: #f39c12; color: white;")
    let delBtn = createButton("🗑 删除", onDeleteBuilding)
    delBtn.setStyleSheet("background-color: #e74c3c; color: white;")
    let refreshBtn = createButton("🔄 刷新", onRefreshBuilding)
    toolRow.addWidget(addBtn.getPtr())
    toolRow.addWidget(editBtn.getPtr())
    toolRow.addWidget(delBtn.getPtr())
    toolRow.addWidget(refreshBtn.getPtr())
    toolRow.addStretch()
    layout.addLayout(toolRow.getPtr())

    let table = createTable(["ID", "楼名", "楼层数", "每层房间", "地址", "负责宿管"])
    gBuildingTable = table
    layout.addWidget(table.getPtr())

    page.setLayout(layout.getPtr())
    refreshBuildingTable()
    return page
}

// ============================================================
// 房间管理 (Admin)
// ============================================================
var gAdminRoomTable: ?QTableWidget = None
let onAddRoom: VoidCallback = { => showRoomDialog(0) }
let onEditRoom: VoidCallback = { => showRoomDialog(1) }
let onDeleteRoom: VoidCallback = { => doDeleteRoom() }
let onRefreshRoom: VoidCallback = { => refreshAdminRoomTable() }

func refreshAdminRoomTable(): Unit {
    if (let Some(db) <- gDb) {
        if (let Some(table) <- gAdminRoomTable) {
            clearTable(table)
            let rooms = db.getAllRooms()
            for (r in rooms) {
                let available = r.capacity - r.occupied
                addTableRow(table, [
                    "${r.id}", r.buildingName, r.roomNo, "${r.floor}",
                    "${r.capacity}", "${r.occupied}", "${available}"
                ])
            }
        }
    }
}

func showRoomDialog(mode: Int32): Unit {
    let title = if (mode == 0) { "添加房间" } else { "编辑房间" }
    let dialog = QWidget()
    dialog.setTitle(title)
    dialog.resize(400, 300)

    let layout = QVBoxLayout()
    layout.setMargin(20)
    layout.setSpacing(10)

    // 楼选择
    let buildingCombo = QComboBox()
    let buildings = if (let Some(db) <- gDb) { db.getAllBuildings() } else { ArrayList<DormBuilding>() }
    for (b in buildings) { buildingCombo.addItem(b.name) }

    let roomNoEdit = createLineEdit("房间号（如 101）")
    let floorEdit = createLineEdit("楼层")
    let capacityEdit = createLineEdit("容量")

    if (mode == 1) {
        if (let Some(table) <- gAdminRoomTable) {
            let row = table.currentRow()
            if (row >= 0) {
                let bName = table.itemText(row, 1)
                for (i in 0..buildings.size) {
                    if (buildings[Int64(i)].name == bName) {
                        buildingCombo.setCurrentIndex(Int32(i))
                        break
                    }
                }
                roomNoEdit.setText(table.itemText(row, 2))
                floorEdit.setText(table.itemText(row, 3))
                capacityEdit.setText(table.itemText(row, 4))
            }
        }
    }

    layout.addLayout(createLabeledRow("楼:", buildingCombo.getPtr()))
    layout.addLayout(createLabeledRow("房间号:", roomNoEdit.getPtr()))
    layout.addLayout(createLabeledRow("楼层:", floorEdit.getPtr()))
    layout.addLayout(createLabeledRow("容量:", capacityEdit.getPtr()))

    let saveBtn = QPushButton()
    saveBtn.setText("保存")
    saveBtn.setStyleSheet("background-color: #3498db; color: white;")
    let _roomConn = saveBtn.setOnClickCapture({ =>
        let bIdx = buildingCombo.currentIndex()
        let roomNo = roomNoEdit.text()
        let floorStr = floorEdit.text()
        let capStr = capacityEdit.text()
        if (roomNo.isEmpty() || floorStr.isEmpty() || capStr.isEmpty()) {
            QMessageBox.warning(0, "提示", "请填写完整信息")
            return
        }
        var floor: Int32 = 0
        for (c in floorStr) { if (c >= 48 && c <= 57) { floor = floor * 10 + Int32(c - 48) } }
        var cap: Int32 = 0
        for (c in capStr) { if (c >= 48 && c <= 57) { cap = cap * 10 + Int32(c - 48) } }
        let bid = if (bIdx >= 0 && Int64(bIdx) < buildings.size) { buildings[Int64(bIdx)].id } else { 0 }

        if (let Some(db) <- gDb) {
            if (mode == 0) { db.addRoom(bid, roomNo, floor, cap) }
            else {
                if (let Some(table) <- gAdminRoomTable) {
                    let row = table.currentRow()
                    let idStr = table.itemText(row, 0)
                    var rid: Int64 = 0
                    for (c in idStr) { if (c >= 48 && c <= 57) { rid = rid * 10 + Int64(c - 48) } }
                    db.updateRoom(rid, bid, roomNo, floor, cap)
                }
            }
            refreshAdminRoomTable()
            dialog.hide(); dialog.delete()
        }
    })
    layout.addWidget(saveBtn.getPtr())
    layout.addStretch()
    dialog.setLayout(layout.getPtr())
    dialog.show()
}

func doDeleteRoom(): Unit {
    if (let Some(table) <- gAdminRoomTable) {
        let row = table.currentRow()
        if (row < 0) { QMessageBox.warning(0, "提示", "请先选择房间"); return }
        if (QMessageBox.question(0, "确认", "确定要删除该房间吗？")) {
            let idStr = table.itemText(row, 0)
            var rid: Int64 = 0
            for (c in idStr) { if (c >= 48 && c <= 57) { rid = rid * 10 + Int64(c - 48) } }
            if (let Some(db) <- gDb) { db.deleteRoom(rid) }
            refreshAdminRoomTable()
        }
    }
}

func buildAdminRoomPage(): QWidget {
    let page = QWidget()
    let layout = QVBoxLayout()
    layout.setMargin(15)
    layout.setSpacing(10)

    let toolRow = QHBoxLayout()
    let addBtn = createButton("➕ 添加", onAddRoom)
    addBtn.setStyleSheet("background-color: #3498db; color: white;")
    let editBtn = createButton("✏ 编辑", onEditRoom)
    editBtn.setStyleSheet("background-color: #f39c12; color: white;")
    let delBtn = createButton("🗑 删除", onDeleteRoom)
    delBtn.setStyleSheet("background-color: #e74c3c; color: white;")
    let refreshBtn = createButton("🔄 刷新", onRefreshRoom)
    toolRow.addWidget(addBtn.getPtr())
    toolRow.addWidget(editBtn.getPtr())
    toolRow.addWidget(delBtn.getPtr())
    toolRow.addWidget(refreshBtn.getPtr())
    toolRow.addStretch()
    layout.addLayout(toolRow.getPtr())

    let table = createTable(["ID", "楼名", "房间号", "楼层", "容量", "已住", "空余"])
    gAdminRoomTable = table
    layout.addWidget(table.getPtr())

    page.setLayout(layout.getPtr())
    refreshAdminRoomTable()
    return page
}

// ============================================================
// 学生管理 (Admin)
// ============================================================
var gAdminStudentTable: ?QTableWidget = None
let onAddStudent: VoidCallback = { => showStudentDialog(0) }
let onEditStudent: VoidCallback = { => showStudentDialog(1) }
let onDeleteStudent: VoidCallback = { => doDeleteStudent() }
let onRefreshStudent: VoidCallback = { => refreshAdminStudent() }

func refreshAdminStudent(): Unit {
    if (let Some(db) <- gDb) {
        if (let Some(table) <- gAdminStudentTable) {
            clearTable(table)
            let students = db.getAllStudents()
            for (s in students) {
                let gender = if (s.gender == "male") { "男" } else { "女" }
                addTableRow(table, [
                    "${s.id}", s.studentNo, s.displayName, gender, s.phone,
                    s.className, "${s.enrollYear}", s.buildingName, s.roomNo, "${s.bedNo}"
                ])
            }
        }
    }
}

func showStudentDialog(mode: Int32): Unit {
    let title = if (mode == 0) { "添加学生" } else { "编辑学生" }
    let dialog = QWidget()
    dialog.setTitle(title)
    dialog.resize(500, 450)

    let layout = QVBoxLayout()
    layout.setMargin(20)
    layout.setSpacing(8)

    let studentNoEdit = createLineEdit("学号")
    let nameEdit = createLineEdit("姓名")
    let genderCombo = QComboBox()
    genderCombo.addItem("男")
    genderCombo.addItem("女")
    let phoneEdit = createLineEdit("电话")
    let classEdit = createLineEdit("班级")
    let yearEdit = createLineEdit("入学年份")

    // 宿舍楼选择
    let buildingCombo = QComboBox()
    let buildings = if (let Some(db) <- gDb) { db.getAllBuildings() } else { ArrayList<DormBuilding>() }
    buildingCombo.addItem("未分配")
    for (b in buildings) { buildingCombo.addItem(b.name) }

    // 房间选择（显示所有有空位的房间）
    let roomCombo = QComboBox()
    let rooms = if (let Some(db) <- gDb) { db.getAvailableRooms() } else { ArrayList<DormRoom>() }
    roomCombo.addItem("未分配")
    for (r in rooms) {
        roomCombo.addItem("${r.buildingName} - ${r.roomNo} (空${r.capacity - r.occupied}床)")
    }

    // 床位号
    let bedEdit = createLineEdit("床位号 (1-8)")

    if (mode == 1) {
        if (let Some(table) <- gAdminStudentTable) {
            let row = table.currentRow()
            if (row >= 0) {
                studentNoEdit.setText(table.itemText(row, 1))
                nameEdit.setText(table.itemText(row, 2))
                let genderStr = table.itemText(row, 3)
                genderCombo.setCurrentIndex(if (genderStr == "男") { 0 } else { 1 })
                phoneEdit.setText(table.itemText(row, 4))
                classEdit.setText(table.itemText(row, 5))
                yearEdit.setText(table.itemText(row, 6))
                // 回显房间和床位信息
                let buildingName = table.itemText(row, 7)
                let roomNo = table.itemText(row, 8)
                let bedStr = table.itemText(row, 9)
                if (!buildingName.isEmpty() && !roomNo.isEmpty()) {
                    // 选中对应的楼名
                    for (i in 0..buildingCombo.count()) {
                        if (buildingCombo.itemText(i) == buildingName) { buildingCombo.setCurrentIndex(i); break }
                    }
                    // 选中对应的房间
                    for (i in 0..roomCombo.count()) {
                        if (roomCombo.itemText(i).contains(roomNo) && roomCombo.itemText(i).contains(buildingName)) {
                            roomCombo.setCurrentIndex(i); break
                        }
                    }
                    bedEdit.setText(bedStr)
                }
            }
        }
    }

    layout.addLayout(createLabeledRow("学号:", studentNoEdit.getPtr()))
    layout.addLayout(createLabeledRow("姓名:", nameEdit.getPtr()))
    layout.addLayout(createLabeledRow("性别:", genderCombo.getPtr()))
    layout.addLayout(createLabeledRow("电话:", phoneEdit.getPtr()))
    layout.addLayout(createLabeledRow("班级:", classEdit.getPtr()))
    layout.addLayout(createLabeledRow("年份:", yearEdit.getPtr()))
    layout.addLayout(createLabeledRow("宿舍楼:", buildingCombo.getPtr()))
    layout.addLayout(createLabeledRow("房间:", roomCombo.getPtr()))
    layout.addLayout(createLabeledRow("床位:", bedEdit.getPtr()))

    let saveBtn = QPushButton()
    saveBtn.setText("保存")
    saveBtn.setStyleSheet("background-color: #3498db; color: white;")
    let _stuConn = saveBtn.setOnClickCapture({ =>
        let studentNo = studentNoEdit.text()
        let name = nameEdit.text()
        let gender = if (genderCombo.currentIndex() == 0) { "male" } else { "female" }
        let phone = phoneEdit.text()
        let className = classEdit.text()
        let yearStr = yearEdit.text()
        if (studentNo.isEmpty() || name.isEmpty() || className.isEmpty()) {
            QMessageBox.warning(0, "提示", "请填写完整信息")
            return
        }
        var year: Int32 = 0
        for (c in yearStr) { if (c >= 48 && c <= 57) { year = year * 10 + Int32(c - 48) } }
        if (year == 0) { year = 2024 }

        // 解析房间选择
        var buildingId: Int64 = 0
        var roomId: Int64 = 0
        var bedNo: Int32 = 0
        let roomIdx = Int64(roomCombo.currentIndex())
        if (roomIdx > 0 && roomIdx - 1 < rooms.size) {
            let selectedRoom = rooms[roomIdx - 1]
            buildingId = selectedRoom.buildingId
            roomId = selectedRoom.id
            // 解析床位号
            let bedStr = bedEdit.text()
            for (c in bedStr) { if (c >= 48 && c <= 57) { bedNo = bedNo * 10 + Int32(c - 48) } }
            if (bedNo <= 0) { bedNo = selectedRoom.occupied + 1 } // 默认分配到空床
        }

        if (let Some(db) <- gDb) {
            if (mode == 0) {
                let userId = db.addUser(studentNo, "stu123", ROLE_STUDENT, name, phone)
                if (userId > 0) {
                    db.addStudent(userId, studentNo, name, gender, phone, className, year,
                        buildingId, roomId, bedNo)
                }
            } else {
                if (let Some(table) <- gAdminStudentTable) {
                    let row = table.currentRow()
                    if (row >= 0) {
                        let idStr = table.itemText(row, 0)
                        var sid: Int64 = 0
                        for (c in idStr) { if (c >= 48 && c <= 57) { sid = sid * 10 + Int64(c - 48) } }
                        if (sid > 0) {
                            let students = db.getAllStudents()
                            for (s in students) {
                                if (s.id == sid) {
                                    db.updateUser(s.userId, name, phone, "")
                                    let newBid = if (buildingId > 0) { buildingId } else { s.buildingId }
                                    let newRid = if (roomId > 0) { roomId } else { s.roomId }
                                    let newBed = if (bedNo > 0) { bedNo } else { s.bedNo }
                                    db.updateStudent(sid, studentNo, name, gender, phone,
                                        className, year, newBid, newRid, newBed)
                                    break
                                }
                            }
                        }
                    }
                }
            }
            refreshAdminStudent()
            dialog.hide(); dialog.delete()
        }
    })
    layout.addWidget(saveBtn.getPtr())
    layout.addStretch()
    dialog.setLayout(layout.getPtr())
    dialog.show()
}

func doDeleteStudent(): Unit {
    if (let Some(table) <- gAdminStudentTable) {
        let row = table.currentRow()
        if (row < 0) { QMessageBox.warning(0, "提示", "请先选择学生"); return }
        if (QMessageBox.question(0, "确认", "确定要删除该学生记录吗？")) {
            let idStr = table.itemText(row, 0)
            var sid: Int64 = 0
            for (c in idStr) { if (c >= 48 && c <= 57) { sid = sid * 10 + Int64(c - 48) } }
            if (let Some(db) <- gDb) { db.deleteStudent(sid) }
            refreshAdminStudent()
        }
    }
}

func buildAdminStudentPage(): QWidget {
    let page = QWidget()
    let layout = QVBoxLayout()
    layout.setMargin(15)
    layout.setSpacing(10)

    let toolRow = QHBoxLayout()
    let addBtn = createButton("➕ 添加", onAddStudent)
    addBtn.setStyleSheet("background-color: #3498db; color: white;")
    let editBtn = createButton("✏ 编辑", onEditStudent)
    editBtn.setStyleSheet("background-color: #f39c12; color: white;")
    let delBtn = createButton("🗑 删除", onDeleteStudent)
    delBtn.setStyleSheet("background-color: #e74c3c; color: white;")
    let refreshBtn = createButton("🔄 刷新", onRefreshStudent)
    toolRow.addWidget(addBtn.getPtr())
    toolRow.addWidget(editBtn.getPtr())
    toolRow.addWidget(delBtn.getPtr())
    toolRow.addWidget(refreshBtn.getPtr())
    toolRow.addStretch()
    layout.addLayout(toolRow.getPtr())

    let table = createTable(["ID", "学号", "姓名", "性别", "电话", "班级", "入学年份", "宿舍楼", "房间", "床位"])
    gAdminStudentTable = table
    layout.addWidget(table.getPtr())

    page.setLayout(layout.getPtr())
    refreshAdminStudent()
    return page
}

// ============================================================
// 宿管管理 (Admin)
// ============================================================
var gManagerTable: ?QTableWidget = None
let onAddManager: VoidCallback = { => showManagerDialog(0) }
let onEditManager: VoidCallback = { => showManagerDialog(1) }
let onDeleteManager: VoidCallback = { => doDeleteManager() }
let onRefreshManager: VoidCallback = { => refreshManagerTable() }

func refreshManagerTable(): Unit {
    if (let Some(db) <- gDb) {
        if (let Some(table) <- gManagerTable) {
            clearTable(table)
            let managers = db.getUsersByRole(ROLE_MANAGER)
            for (m in managers) {
                addTableRow(table, ["${m.id}", m.username, m.displayName, m.phone])
            }
        }
    }
}

func showManagerDialog(mode: Int32): Unit {
    let title = if (mode == 0) { "添加宿管" } else { "编辑宿管" }
    let dialog = QWidget()
    dialog.setTitle(title)
    dialog.resize(380, 280)

    let layout = QVBoxLayout()
    layout.setMargin(20)
    layout.setSpacing(10)

    let usernameEdit = createLineEdit("用户名")
    let pwdEdit = createLineEdit("密码")
    pwdEdit.setEchoMode(LineEditEchoMode.Password)
    let nameEdit = createLineEdit("姓名")
    let phoneEdit = createLineEdit("电话")

    if (mode == 0) { pwdEdit.setText("manager123") }

    if (mode == 1) {
        if (let Some(table) <- gManagerTable) {
            let row = table.currentRow()
            if (row >= 0) {
                usernameEdit.setText(table.itemText(row, 1))
                nameEdit.setText(table.itemText(row, 2))
                phoneEdit.setText(table.itemText(row, 3))
            }
        }
    }

    layout.addLayout(createLabeledRow("用户名:", usernameEdit.getPtr()))
    layout.addLayout(createLabeledRow("密码:", pwdEdit.getPtr()))
    layout.addLayout(createLabeledRow("姓名:", nameEdit.getPtr()))
    layout.addLayout(createLabeledRow("电话:", phoneEdit.getPtr()))

    let saveBtn = QPushButton()
    saveBtn.setText("保存")
    saveBtn.setStyleSheet("background-color: #3498db; color: white;")
    let _mgrConn = saveBtn.setOnClickCapture({ =>
        let username = usernameEdit.text()
        let pwd = pwdEdit.text()
        let name = nameEdit.text()
        let phone = phoneEdit.text()
        if (username.isEmpty() || pwd.isEmpty() || name.isEmpty()) {
            QMessageBox.warning(0, "提示", "请填写完整信息")
            return
        }
        if (let Some(db) <- gDb) {
            if (mode == 0) { db.addUser(username, pwd, ROLE_MANAGER, name, phone) }
            else {
                if (let Some(table) <- gManagerTable) {
                    let row = table.currentRow()
                    let idStr = table.itemText(row, 0)
                    var mid: Int64 = 0
                    for (c in idStr) { if (c >= 48 && c <= 57) { mid = mid * 10 + Int64(c - 48) } }
                    db.updateUser(mid, name, phone, "")
                }
            }
            refreshManagerTable()
            dialog.hide(); dialog.delete()
        }
    })
    layout.addWidget(saveBtn.getPtr())
    layout.addStretch()
    dialog.setLayout(layout.getPtr())
    dialog.show()
}

func doDeleteManager(): Unit {
    if (let Some(table) <- gManagerTable) {
        let row = table.currentRow()
        if (row < 0) { QMessageBox.warning(0, "提示", "请先选择宿管"); return }
        if (QMessageBox.question(0, "确认", "确定要删除该宿管吗？")) {
            let idStr = table.itemText(row, 0)
            var mid: Int64 = 0
            for (c in idStr) { if (c >= 48 && c <= 57) { mid = mid * 10 + Int64(c - 48) } }
            if (let Some(db) <- gDb) { db.deleteUser(mid) }
            refreshManagerTable()
        }
    }
}

func buildManagerManagePage(): QWidget {
    let page = QWidget()
    let layout = QVBoxLayout()
    layout.setMargin(15)
    layout.setSpacing(10)

    let toolRow = QHBoxLayout()
    let addBtn = createButton("➕ 添加", onAddManager)
    addBtn.setStyleSheet("background-color: #3498db; color: white;")
    let editBtn = createButton("✏ 编辑", onEditManager)
    editBtn.setStyleSheet("background-color: #f39c12; color: white;")
    let delBtn = createButton("🗑 删除", onDeleteManager)
    delBtn.setStyleSheet("background-color: #e74c3c; color: white;")
    let refreshBtn = createButton("🔄 刷新", onRefreshManager)
    toolRow.addWidget(addBtn.getPtr())
    toolRow.addWidget(editBtn.getPtr())
    toolRow.addWidget(delBtn.getPtr())
    toolRow.addWidget(refreshBtn.getPtr())
    toolRow.addStretch()
    layout.addLayout(toolRow.getPtr())

    let table = createTable(["ID", "用户名", "姓名", "电话"])
    gManagerTable = table
    layout.addWidget(table.getPtr())

    page.setLayout(layout.getPtr())
    refreshManagerTable()
    return page
}

// ============================================================
// 管理员 - 考勤管理
// ============================================================
var gAdminAttTable: ?QTableWidget = None
var gAdminAttDate: ?QLineEdit = None
let onRefreshAdminAtt: VoidCallback = { => refreshAdminAttendance() }

func refreshAdminAttendance(): Unit {
    let date = if (let Some(e) <- gAdminAttDate) { e.text() } else { getTodayString() }
    if (date.isEmpty()) { return }
    if (let Some(db) <- gDb) {
        if (let Some(table) <- gAdminAttTable) {
            clearTable(table)
            let records = db.getAttendanceByDate(date)
            for (a in records) {
                addTableRow(table, [
                    "${a.id}", a.studentNo, a.studentName,
                    getStatusDisplayName(a.status), a.checkInTime, a.checkOutTime, a.note
                ])
            }
        }
    }
}

func buildAdminAttendancePage(): QWidget {
    let page = QWidget()
    let layout = QVBoxLayout()
    layout.setMargin(15)
    layout.setSpacing(10)

    let toolRow = QHBoxLayout()
    let dateEdit = createLineEdit(getTodayString())
    dateEdit.setPlaceholder("yyyy-MM-dd")
    gAdminAttDate = dateEdit
    toolRow.addWidget(createLabel("日期:").getPtr())
    toolRow.addWidget(dateEdit.getPtr())
    let refreshBtn = createButton("🔍 查询", onRefreshAdminAtt)
    refreshBtn.setStyleSheet("background-color: #3498db; color: white;")
    toolRow.addWidget(refreshBtn.getPtr())
    toolRow.addStretch()
    layout.addLayout(toolRow.getPtr())

    let table = createTable(["ID", "学号", "姓名", "状态", "签到时间", "签退时间", "备注"])
    gAdminAttTable = table
    layout.addWidget(table.getPtr())

    page.setLayout(layout.getPtr())
    refreshAdminAttendance()
    return page
}

// ============================================================
// 管理员 - 报修管理
// ============================================================
var gAdminRepairTable: ?QTableWidget = None
let onRefreshAdminRepair: VoidCallback = { => refreshAdminRepair() }
let onProcessRepair: VoidCallback = { => showProcessRepairDialog() }

func refreshAdminRepair(): Unit {
    if (let Some(db) <- gDb) {
        if (let Some(table) <- gAdminRepairTable) {
            clearTable(table)
            let repairs = db.getAllRepairs()
            for (r in repairs) {
                addTableRow(table, [
                    "${r.id}", r.studentNo, r.studentName, r.buildingName, r.roomNo,
                    r.title, getRepairCategoryDisplay(r.category),
                    getStatusDisplayName(r.status), r.createTime, r.managerName
                ])
            }
        }
    }
}

func showProcessRepairDialog(): Unit {
    if (let Some(table) <- gAdminRepairTable) {
        let row = table.currentRow()
        if (row < 0) { QMessageBox.warning(0, "提示", "请先选择报修记录"); return }
        let idStr = table.itemText(row, 0)
        // 把 rid 的计算移入回调内，避免捕获 mutable var
        let dialog = QWidget()
        dialog.setTitle("处理报修")
        dialog.resize(380, 250)

        let layout = QVBoxLayout()
        layout.setMargin(20)
        layout.setSpacing(10)

        let statusCombo = QComboBox()
        statusCombo.addItem("待处理")
        statusCombo.addItem("处理中")
        statusCombo.addItem("已解决")
        statusCombo.addItem("已拒绝")

        let noteEdit = createLineEdit("处理备注")

        layout.addLayout(createLabeledRow("状态:", statusCombo.getPtr()))
        layout.addLayout(createLabeledRow("备注:", noteEdit.getPtr()))

        let saveBtn = QPushButton()
        saveBtn.setText("确认")
        saveBtn.setStyleSheet("background-color: #3498db; color: white;")
        let _repConn = saveBtn.setOnClickCapture({ =>
            // 在回调内重新解析 rid
            let ridStrLocal = idStr
            var ridLocal: Int64 = 0
            for (c in ridStrLocal) { if (c >= 48 && c <= 57) { ridLocal = ridLocal * 10 + Int64(c - 48) } }
            let status = if (statusCombo.currentIndex() == 0) { REPAIR_PENDING }
                else if (statusCombo.currentIndex() == 1) { REPAIR_PROCESSING }
                else if (statusCombo.currentIndex() == 2) { REPAIR_RESOLVED }
                else { REPAIR_REJECTED }
            let note = noteEdit.text()
            let adminId = if (let Some(u) <- gCurrentUser) { u.id } else { 0 }
            if (let Some(db) <- gDb) {
                db.updateRepairStatus(ridLocal, status, adminId, note)
                refreshAdminRepair()
                dialog.hide(); dialog.delete()
            }
        })
        layout.addWidget(saveBtn.getPtr())
        layout.addStretch()
        dialog.setLayout(layout.getPtr())
        dialog.show()
    }
}

func buildAdminRepairPage(): QWidget {
    let page = QWidget()
    let layout = QVBoxLayout()
    layout.setMargin(15)
    layout.setSpacing(10)

    let toolRow = QHBoxLayout()
    let processBtn = createButton("🔧 处理选中", onProcessRepair)
    processBtn.setStyleSheet("background-color: #e67e22; color: white;")
    let refreshBtn = createButton("🔄 刷新", onRefreshAdminRepair)
    toolRow.addWidget(processBtn.getPtr())
    toolRow.addWidget(refreshBtn.getPtr())
    toolRow.addStretch()
    layout.addLayout(toolRow.getPtr())

    let table = createTable(["ID", "学号", "姓名", "楼", "房间", "标题", "分类", "状态", "时间", "处理人"])
    gAdminRepairTable = table
    layout.addWidget(table.getPtr())

    page.setLayout(layout.getPtr())
    refreshAdminRepair()
    return page
}

// ============================================================
// 管理员 - 公告管理
// ============================================================
var gAdminAnnounceTable: ?QTableWidget = None
let onAddAnnounce: VoidCallback = { => showAnnounceDialog() }
let onDeleteAnnounce: VoidCallback = { => doDeleteAnnounce() }
let onRefreshAnnounce: VoidCallback = { => refreshAdminAnnounce() }

func refreshAdminAnnounce(): Unit {
    if (let Some(db) <- gDb) {
        if (let Some(table) <- gAdminAnnounceTable) {
            clearTable(table)
            let announces = db.getAllAnnouncements()
            for (a in announces) {
                let target = if (a.targetRole == ANNOUNCE_ALL) { "全部" }
                    else if (a.targetRole == ANNOUNCE_STUDENT) { "学生" }
                    else if (a.targetRole == ANNOUNCE_MANAGER) { "宿管" }
                    else { a.targetRole }
                addTableRow(table, [
                    "${a.id}", a.title, a.content, a.authorName, target, a.createTime
                ])
            }
        }
    }
}

func showAnnounceDialog(): Unit {
    let dialog = QWidget()
    dialog.setTitle("发布公告")
    dialog.resize(450, 350)

    let layout = QVBoxLayout()
    layout.setMargin(20)
    layout.setSpacing(10)

    let titleEdit = createLineEdit("公告标题")
    let contentEdit = QTextEdit()
    contentEdit.setMinimumSize(0, 120)
    let targetCombo = QComboBox()
    targetCombo.addItem("全部")
    targetCombo.addItem("学生")
    targetCombo.addItem("宿管")

    layout.addLayout(createLabeledRow("标题:", titleEdit.getPtr()))
    layout.addWidget(contentEdit.getPtr())
    layout.addLayout(createLabeledRow("目标:", targetCombo.getPtr()))

    let publishBtn = QPushButton()
    publishBtn.setText("📢 发布")
    publishBtn.setStyleSheet("background-color: #3498db; color: white;")
    let _annConn = publishBtn.setOnClickCapture({ =>
        let title = titleEdit.text()
        let content = contentEdit.text()
        if (title.isEmpty() || content.isEmpty()) {
            QMessageBox.warning(0, "提示", "请填写完整信息")
            return
        }
        let target = if (targetCombo.currentIndex() == 0) { ANNOUNCE_ALL }
            else if (targetCombo.currentIndex() == 1) { ANNOUNCE_STUDENT }
            else { ANNOUNCE_MANAGER }
        let authorId = if (let Some(u) <- gCurrentUser) { u.id } else { 0 }
        if (let Some(db) <- gDb) {
            db.addAnnouncement(title, content, authorId, target)
            refreshAdminAnnounce()
            dialog.hide(); dialog.delete()
        }
    })
    layout.addWidget(publishBtn.getPtr())
    dialog.setLayout(layout.getPtr())
    dialog.show()
}

func doDeleteAnnounce(): Unit {
    if (let Some(table) <- gAdminAnnounceTable) {
        let row = table.currentRow()
        if (row < 0) { QMessageBox.warning(0, "提示", "请先选择公告"); return }
        if (QMessageBox.question(0, "确认", "确定要删除该公告吗？")) {
            let idStr = table.itemText(row, 0)
            var aid: Int64 = 0
            for (c in idStr) { if (c >= 48 && c <= 57) { aid = aid * 10 + Int64(c - 48) } }
            if (let Some(db) <- gDb) { db.deleteAnnouncement(aid) }
            refreshAdminAnnounce()
        }
    }
}

func buildAdminAnnouncementPage(): QWidget {
    let page = QWidget()
    let layout = QVBoxLayout()
    layout.setMargin(15)
    layout.setSpacing(10)

    let toolRow = QHBoxLayout()
    let addBtn = createButton("📝 发布公告", onAddAnnounce)
    addBtn.setStyleSheet("background-color: #3498db; color: white;")
    let delBtn = createButton("🗑 删除", onDeleteAnnounce)
    delBtn.setStyleSheet("background-color: #e74c3c; color: white;")
    let refreshBtn = createButton("🔄 刷新", onRefreshAnnounce)
    toolRow.addWidget(addBtn.getPtr())
    toolRow.addWidget(delBtn.getPtr())
    toolRow.addWidget(refreshBtn.getPtr())
    toolRow.addStretch()
    layout.addLayout(toolRow.getPtr())

    let table = createTable(["ID", "标题", "内容", "作者", "目标", "时间"])
    gAdminAnnounceTable = table
    layout.addWidget(table.getPtr())

    page.setLayout(layout.getPtr())
    refreshAdminAnnounce()
    return page
}

// ============================================================
// 宿管仪表板
// ============================================================
func buildManagerDashboard(): Unit {
    if (let Some(mw) <- gMainWindow) { mw.show(); return }

    let window = QMainWindow()
    let managerId = if (let Some(u) <- gCurrentUser) { u.id } else { 0 }
    window.setTitle("宿舍管理系统 - 宿管面板")
    window.resize(1000, 650)
    gMainWindow = window

    let menuBar = QMenuBar()
    let userMenu = menuBar.addMenu("系统(&S)")
    let logoutAction = userMenu.addAction("退出登录(&L)")
    logoutAction.setOnTriggered(onLogoutClick)
    window.setMenuBar(menuBar.getPtr())

    let statusBar = QStatusBar()
    if (let Some(u) <- gCurrentUser) {
        statusBar.showMessage("当前用户: ${u.displayName} (宿管)")
    }
    window.setStatusBar(statusBar.getPtr())

    let tab = QTabWidget()
    gTabWidget = tab

    // 首页
    let stats = if (let Some(db) <- gDb) { db.getManagerDashboardStats(managerId) } else { DashboardStats() }
    tab.addTab(buildStatPage(stats).getPtr(), "📊 首页")

    // 学生查看
    tab.addTab(buildManagerStudentPage(managerId).getPtr(), "👤 学生")

    // 房间查看
    tab.addTab(buildManagerRoomPage(managerId).getPtr(), "🚪 房间")

    // 考勤管理
    tab.addTab(buildManagerAttendancePage(managerId).getPtr(), "📋 考勤")

    // 报修处理
    tab.addTab(buildManagerRepairPage(managerId).getPtr(), "🔧 报修")

    // 公告
    tab.addTab(buildManagerAnnouncePage().getPtr(), "📢 公告")

    window.setCentralWidget(tab.getPtr())
    window.show()
}

// ============================================================
// 宿管 - 学生查看
// ============================================================
var gManagerStudentTable: ?QTableWidget = None

func refreshManagerStudent(managerId: Int64): Unit {
    if (let Some(db) <- gDb) {
        if (let Some(table) <- gManagerStudentTable) {
            clearTable(table)
            // 获取该宿管管理的楼
            let buildings = db.getAllBuildings()
            for (b in buildings) {
                if (b.managerId == managerId || managerId == 0) {
                    let students = db.getStudentsByBuilding(b.id)
                    for (s in students) {
                        let gender = if (s.gender == "male") { "男" } else { "女" }
                        addTableRow(table, [
                            s.studentNo, s.displayName, gender, s.phone, s.className,
                            "${s.enrollYear}", b.name, s.roomNo, "${s.bedNo}"
                        ])
                    }
                }
            }
        }
    }
}

func buildManagerStudentPage(managerId: Int64): QWidget {
    let page = QWidget()
    let layout = QVBoxLayout()
    layout.setMargin(15)
    layout.setSpacing(10)

    let title = createLabel("👤 本楼学生列表")
    title.setStyleSheet("font-size: 16px; font-weight: bold;")
    layout.addWidget(title.getPtr())

    let table = createTable(["学号", "姓名", "性别", "电话", "班级", "入学年份", "宿舍楼", "房间", "床位"])
    gManagerStudentTable = table

    // 刷新按钮
    let refBtn = QPushButton()
    refBtn.setText("🔄 刷新")
    let _mgrStuConn = refBtn.setOnClickCapture({ => refreshManagerStudent(managerId) })
    layout.addWidget(refBtn.getPtr())
    layout.addWidget(table.getPtr())

    page.setLayout(layout.getPtr())
    refreshManagerStudent(managerId)
    return page
}

// ============================================================
// 宿管 - 房间查看
// ============================================================
var gManagerRoomTable: ?QTableWidget = None

func refreshManagerRoom(managerId: Int64): Unit {
    if (let Some(db) <- gDb) {
        if (let Some(table) <- gManagerRoomTable) {
            clearTable(table)
            let buildings = db.getAllBuildings()
            for (b in buildings) {
                if (b.managerId == managerId || managerId == 0) {
                    let rooms = db.getRoomsByBuilding(b.id)
                    for (r in rooms) {
                        let available = r.capacity - r.occupied
                        addTableRow(table, [
                            b.name, r.roomNo, "${r.floor}",
                            "${r.capacity}", "${r.occupied}", "${available}"
                        ])
                    }
                }
            }
        }
    }
}

func buildManagerRoomPage(managerId: Int64): QWidget {
    let page = QWidget()
    let layout = QVBoxLayout()
    layout.setMargin(15)
    layout.setSpacing(10)

    let title = createLabel("🚪 本楼房间状态")
    title.setStyleSheet("font-size: 16px; font-weight: bold;")
    layout.addWidget(title.getPtr())

    let table = createTable(["楼名", "房间号", "楼层", "容量", "已住", "空余"])
    gManagerRoomTable = table

    let refBtn = QPushButton()
    refBtn.setText("🔄 刷新")
    let _mgrRoomConn = refBtn.setOnClickCapture({ => refreshManagerRoom(managerId) })
    layout.addWidget(refBtn.getPtr())
    layout.addWidget(table.getPtr())

    page.setLayout(layout.getPtr())
    refreshManagerRoom(managerId)
    return page
}

// ============================================================
// 宿管 - 考勤管理
// ============================================================
var gManagerAttTable: ?QTableWidget = None
var gManagerAttDate: ?QLineEdit = None

func refreshManagerAttendance(managerId: Int64): Unit {
    let date = if (let Some(e) <- gManagerAttDate) { e.text() } else { getTodayString() }
    if (date.isEmpty()) { return }
    if (let Some(db) <- gDb) {
        if (let Some(table) <- gManagerAttTable) {
            clearTable(table)
            // 取该楼所有学生的考勤
            let records = db.getAttendanceByDate(date)
            for (a in records) {
                addTableRow(table, [
                    a.studentNo, a.studentName,
                    getStatusDisplayName(a.status), a.checkInTime, a.checkOutTime, a.note
                ])
            }
        }
    }
}

func buildManagerAttendancePage(managerId: Int64): QWidget {
    let page = QWidget()
    let layout = QVBoxLayout()
    layout.setMargin(15)
    layout.setSpacing(10)

    let title = createLabel("📋 本楼考勤管理")
    title.setStyleSheet("font-size: 16px; font-weight: bold;")
    layout.addWidget(title.getPtr())

    let toolRow = QHBoxLayout()
    let dateEdit = createLineEdit(getTodayString())
    dateEdit.setPlaceholder("yyyy-MM-dd")
    gManagerAttDate = dateEdit
    toolRow.addWidget(createLabel("日期:").getPtr())
    toolRow.addWidget(dateEdit.getPtr())
    let queryBtn = QPushButton()
    queryBtn.setText("🔍 查询")
    queryBtn.setStyleSheet("background-color: #3498db; color: white;")
    let _mgrAttConn = queryBtn.setOnClickCapture({ => refreshManagerAttendance(managerId) })
    toolRow.addWidget(queryBtn.getPtr())
    toolRow.addStretch()
    layout.addLayout(toolRow.getPtr())

    let table = createTable(["学号", "姓名", "状态", "签到", "签退", "备注"])
    gManagerAttTable = table
    layout.addWidget(table.getPtr())

    page.setLayout(layout.getPtr())
    refreshManagerAttendance(managerId)
    return page
}

// ============================================================
// 宿管 - 报修处理
// ============================================================
var gManagerRepairTable: ?QTableWidget = None

func refreshManagerRepair(managerId: Int64): Unit {
    if (let Some(db) <- gDb) {
        if (let Some(table) <- gManagerRepairTable) {
            clearTable(table)
            let repairs = db.getPendingRepairs()
            for (r in repairs) {
                addTableRow(table, [
                    "${r.id}", r.studentNo, r.studentName, r.buildingName, r.roomNo,
                    r.title, getRepairCategoryDisplay(r.category),
                    getStatusDisplayName(r.status), r.createTime
                ])
            }
        }
    }
}

func buildManagerRepairPage(managerId: Int64): QWidget {
    let page = QWidget()
    let layout = QVBoxLayout()
    layout.setMargin(15)
    layout.setSpacing(10)

    let title = createLabel("🔧 待处理报修")
    title.setStyleSheet("font-size: 16px; font-weight: bold;")
    layout.addWidget(title.getPtr())

    let toolRow = QHBoxLayout()
    let processBtn = createButton("🔧 处理", onProcessRepair)
    processBtn.setStyleSheet("background-color: #e67e22; color: white;")
    let refreshBtn = QPushButton()
    refreshBtn.setText("🔄 刷新")
    let _mgrRepConn = refreshBtn.setOnClickCapture({ => refreshManagerRepair(managerId) })
    toolRow.addWidget(processBtn.getPtr())
    toolRow.addWidget(refreshBtn.getPtr())
    toolRow.addStretch()
    layout.addLayout(toolRow.getPtr())

    let table = createTable(["ID", "学号", "姓名", "楼", "房间", "标题", "分类", "状态", "时间"])
    gManagerRepairTable = table
    layout.addWidget(table.getPtr())

    page.setLayout(layout.getPtr())
    refreshManagerRepair(managerId)
    return page
}

// ============================================================
// 宿管 - 公告查看
// ============================================================
var gManagerAnnounceTable: ?QTableWidget = None

func refreshManagerAnnounce(): Unit {
    if (let Some(db) <- gDb) {
        if (let Some(table) <- gManagerAnnounceTable) {
            clearTable(table)
            let announces = db.getAnnouncementsByRole(ROLE_MANAGER)
            for (a in announces) {
                addTableRow(table, [a.title, a.content, a.authorName, a.createTime])
            }
        }
    }
}

func buildManagerAnnouncePage(): QWidget {
    let page = QWidget()
    let layout = QVBoxLayout()
    layout.setMargin(15)
    layout.setSpacing(10)

    let title = createLabel("📢 公告通知")
    title.setStyleSheet("font-size: 16px; font-weight: bold;")
    layout.addWidget(title.getPtr())

    let table = createTable(["标题", "内容", "发布人", "时间"])
    gManagerAnnounceTable = table
    layout.addWidget(table.getPtr())

    let refBtn = createButton("🔄 刷新", { => refreshManagerAnnounce() })
    layout.addWidget(refBtn.getPtr())

    page.setLayout(layout.getPtr())
    refreshManagerAnnounce()
    return page
}

// ============================================================
// 学生仪表板
// ============================================================
func buildStudentDashboard(): Unit {
    let window = QMainWindow()
    let userId = if (let Some(u) <- gCurrentUser) { u.id } else { 0 }
    let student = if (let Some(db) <- gDb) { db.getStudentByUserId(userId) } else { None<Student> }
    let studentInfo = if (let Some(s) <- student) { s } else { Student() }

    window.setTitle("宿舍管理系统 - 学生面板")
    window.resize(900, 600)
    gMainWindow = window

    let menuBar = QMenuBar()
    let userMenu = menuBar.addMenu("系统(&S)")
    let logoutAction = userMenu.addAction("退出登录(&L)")
    logoutAction.setOnTriggered(onLogoutClick)
    window.setMenuBar(menuBar.getPtr())

    let statusBar = QStatusBar()
    if (let Some(u) <- gCurrentUser) {
        statusBar.showMessage("当前用户: ${u.displayName} (学生)")
    }
    window.setStatusBar(statusBar.getPtr())

    let tab = QTabWidget()
    gTabWidget = tab

    // 个人信息
    tab.addTab(buildStudentInfoPage(studentInfo).getPtr(), "👤 个人信息")

    // 我的考勤
    tab.addTab(buildStudentAttendancePage(studentInfo).getPtr(), "📋 我的考勤")

    // 提交报修
    tab.addTab(buildStudentRepairPage(studentInfo).getPtr(), "🔧 提交报修")

    // 公告查看
    tab.addTab(buildStudentAnnouncePage().getPtr(), "📢 公告")

    window.setCentralWidget(tab.getPtr())
    window.show()
}

// ============================================================
// 学生 - 个人信息
// ============================================================
func buildStudentInfoPage(student: Student): QWidget {
    let page = QWidget()
    let layout = QVBoxLayout()
    layout.setMargin(25)
    layout.setSpacing(15)

    let title = createLabel("👤 我的信息")
    title.setStyleSheet("font-size: 20px; font-weight: bold;")
    layout.addWidget(title.getPtr())

    // 信息卡片
    let infoGroup = QWidget()
    infoGroup.setStyleSheet("background-color: #f8f9fa; border: 1px solid #dee2e6; border-radius: 8px; padding: 20px;")
    let infoLayout = QGridLayout()
    infoLayout.setSpacing(12)

    let fields = ArrayList<(String, String)>()
    fields.add(("姓名", student.displayName))
    fields.add(("学号", student.studentNo))
    fields.add(("性别", if (student.gender == "male") { "男" } else { "女" }))
    fields.add(("电话", student.phone))
    fields.add(("班级", student.className))
    fields.add(("入学年份", "${student.enrollYear}"))
    fields.add(("宿舍楼", student.buildingName))
    fields.add(("房间号", student.roomNo))
    fields.add(("床位", "${student.bedNo}"))

    var idx: Int32 = 0
    for (pair in fields) {
        let lb = createLabel("${pair[0]}: ")
        lb.setStyleSheet("font-weight: bold;")
        let val = createLabel(pair[1])
        infoLayout.addWidget(lb.getPtr(), idx / 3, (idx % 3) * 2)
        infoLayout.addWidget(val.getPtr(), idx / 3, (idx % 3) * 2 + 1)
        idx = idx + 1
    }

    infoGroup.setLayout(infoLayout.getPtr())
    layout.addWidget(infoGroup.getPtr())
    layout.addStretch()
    page.setLayout(layout.getPtr())
    return page
}

// ============================================================
// 学生 - 考勤查看
// ============================================================
var gStudentAttTable: ?QTableWidget = None

func refreshStudentAttendance(studentId: Int64): Unit {
    if (let Some(db) <- gDb) {
        if (let Some(table) <- gStudentAttTable) {
            clearTable(table)
            let records = db.getAttendanceByStudent(studentId)
            for (a in records) {
                addTableRow(table, [
                    a.date, getStatusDisplayName(a.status), a.checkInTime, a.checkOutTime, a.note
                ])
            }
        }
    }
}

func buildStudentAttendancePage(student: Student): QWidget {
    let page = QWidget()
    let layout = QVBoxLayout()
    layout.setMargin(15)
    layout.setSpacing(10)

    let title = createLabel("📋 我的考勤记录")
    title.setStyleSheet("font-size: 16px; font-weight: bold;")
    layout.addWidget(title.getPtr())

    let table = createTable(["日期", "状态", "签到", "签退", "备注"])
    gStudentAttTable = table

    let refBtn = QPushButton()
    refBtn.setText("🔄 刷新")
    let _stuAttConn = refBtn.setOnClickCapture({ => refreshStudentAttendance(student.id) })
    layout.addWidget(refBtn.getPtr())
    layout.addWidget(table.getPtr())

    page.setLayout(layout.getPtr())
    if (student.id > 0) { refreshStudentAttendance(student.id) }
    return page
}

// ============================================================
// 学生 - 提交报修
// ============================================================
var gStudentRepairTable: ?QTableWidget = None
var gRepairTitle: ?QLineEdit = None
var gRepairDesc: ?QTextEdit = None
var gRepairCategory: ?QComboBox = None

let onSubmitRepair: VoidCallback = { =>
    if (let Some(db) <- gDb) {
        let userId = if (let Some(u) <- gCurrentUser) { u.id } else { 0 }
        let student = db.getStudentByUserId(userId)
        if (let Some(s) <- student) {
            let title = if (let Some(e) <- gRepairTitle) { e.text() } else { "" }
            let desc = if (let Some(e) <- gRepairDesc) { e.text() } else { "" }
            let catIdx = if (let Some(c) <- gRepairCategory) { c.currentIndex() } else { 0i32 }
            let category = if (catIdx == 0) { REPAIR_ELECTRIC }
                else if (catIdx == 1) { REPAIR_PLUMBING }
                else if (catIdx == 2) { REPAIR_FURNITURE }
                else { REPAIR_OTHER }
            if (title.isEmpty()) {
                QMessageBox.warning(0, "提示", "请填写报修标题")
                return
            }
            let rid = db.addRepair(s.id, s.roomId, title, desc, category)
            if (rid > 0) {
                QMessageBox.information(0, "成功", "报修提交成功！等待处理。")
                if (let Some(e) <- gRepairTitle) { e.setText("") }
                if (let Some(e) <- gRepairDesc) { e.setText("") }
                refreshStudentRepairs(s.id)
            }
        } else {
            QMessageBox.warning(0, "提示", "您还没有分配宿舍，请联系管理员。")
        }
    }
}

func refreshStudentRepairs(studentId: Int64): Unit {
    if (let Some(db) <- gDb) {
        if (let Some(table) <- gStudentRepairTable) {
            clearTable(table)
            let repairs = db.getRepairsByStudent(studentId)
            for (r in repairs) {
                addTableRow(table, [
                    r.title, getRepairCategoryDisplay(r.category),
                    getStatusDisplayName(r.status), r.createTime, r.note
                ])
            }
        }
    }
}

func buildStudentRepairPage(student: Student): QWidget {
    let page = QWidget()
    let layout = QVBoxLayout()
    layout.setMargin(15)
    layout.setSpacing(10)

    let title = createLabel("🔧 提交报修申请")
    title.setStyleSheet("font-size: 16px; font-weight: bold;")
    layout.addWidget(title.getPtr())

    // 输入区
    let inputGroup = QWidget()
    inputGroup.setStyleSheet("background-color: #f8f9fa; border: 1px solid #dee2e6; border-radius: 8px; padding: 15px;")
    let inputLayout = QVBoxLayout()
    inputLayout.setSpacing(8)

    let titleEdit = createLineEdit("报修标题（如：灯泡坏了）")
    gRepairTitle = titleEdit
    inputLayout.addWidget(titleEdit.getPtr())

    let descEdit = QTextEdit()
    descEdit.setMinimumSize(0, 100)
    gRepairDesc = descEdit
    inputLayout.addWidget(descEdit.getPtr())

    let catCombo = QComboBox()
    catCombo.addItem("电力维修")
    catCombo.addItem("水管维修")
    catCombo.addItem("家具维修")
    catCombo.addItem("其他")
    gRepairCategory = catCombo
    let catRow = createLabeledRow("分类:", catCombo.getPtr())
    inputLayout.addLayout(catRow)

    let submitBtn = createButton("📤 提交报修", onSubmitRepair)
    submitBtn.setStyleSheet("background-color: #e67e22; color: white; padding: 8px;")
    inputLayout.addWidget(submitBtn.getPtr())

    inputGroup.setLayout(inputLayout.getPtr())
    layout.addWidget(inputGroup.getPtr())

    // 报修历史
    let histTitle = createLabel("我的报修记录")
    histTitle.setStyleSheet("font-size: 14px; font-weight: bold; margin-top: 10px;")
    layout.addWidget(histTitle.getPtr())

    let table = createTable(["标题", "分类", "状态", "时间", "备注"])
    gStudentRepairTable = table
    layout.addWidget(table.getPtr())

    page.setLayout(layout.getPtr())
    if (student.id > 0) { refreshStudentRepairs(student.id) }
    return page
}

// ============================================================
// 学生 - 公告查看
// ============================================================
var gStudentAnnounceTable: ?QTableWidget = None

func refreshStudentAnnounce(): Unit {
    if (let Some(db) <- gDb) {
        if (let Some(table) <- gStudentAnnounceTable) {
            clearTable(table)
            let announces = db.getAnnouncementsByRole(ROLE_STUDENT)
            for (a in announces) {
                addTableRow(table, [a.title, a.content, a.authorName, a.createTime])
            }
        }
    }
}

func buildStudentAnnouncePage(): QWidget {
    let page = QWidget()
    let layout = QVBoxLayout()
    layout.setMargin(15)
    layout.setSpacing(10)

    let title = createLabel("📢 公告通知")
    title.setStyleSheet("font-size: 16px; font-weight: bold;")
    layout.addWidget(title.getPtr())

    let table = createTable(["标题", "内容", "发布人", "时间"])
    gStudentAnnounceTable = table
    layout.addWidget(table.getPtr())

    let refBtn = createButton("🔄 刷新", { => refreshStudentAnnounce() })
    layout.addWidget(refBtn.getPtr())

    page.setLayout(layout.getPtr())
    refreshStudentAnnounce()
    return page
}

// ============================================================
// 主入口
// ============================================================
main(): Int32 {
    let app = QApplication()
    gApp = app

    // 打开数据库
    let db = QSqlDatabase.addDatabase(SqlDriver.sqlite(), "dormitory_manager")
    db.setDatabaseName("dormitory.db")
    if (!db.open()) {
        println("数据库打开失败: ${db.lastError()}")
        QMessageBox.critical(0, "错误", "数据库打开失败: ${db.lastError()}")
        return 1
    }
    gDb = DatabaseManager(db)

    // 创建登录窗口（直接用 QWidget，不经过 QStackedWidget）
    let loginPage = buildLoginUI()
    loginPage.setTitle("宿舍管理系统 - 登录")
    loginPage.resize(400, 350)
    gLoginWindow = loginPage
    loginPage.show()

    // 堆叠窗口用于登录后切换（保留 gStackedWidget 兼容性）
    let stack = QStackedWidget()
    gStackedWidget = stack

    let result = app.exec()

    // 清理
    if (let Some(d) <- gDb) { d.close() }
    db.close()
    db.delete()
    return result
}
