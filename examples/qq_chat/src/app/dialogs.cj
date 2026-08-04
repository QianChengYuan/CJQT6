// ============================================================
// QQ聊天 - 对话框模块
// 注册 / 修改密码 / 添加好友 三个对话框
// ============================================================
package qq_chat.app

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import cjqt6.dialogs.*
import cjqt6.views.*
import std.collection.*
import qq_chat.core.*
import qq_chat.state.*

// ============================================================
// 注册对话框
// ============================================================

/// 注册确认按钮回调
let onRegisterConfirm: VoidCallback = {
    => doRegister()
}

/// 注册取消按钮回调
let onRegisterCancel: VoidCallback = {
    => closeRegisterDialog()
}

/// 关闭注册对话框并释放资源。
public func closeRegisterDialog(): Unit {
    if (let Some(d) <- gRegisterDialog) {
        d.hide();
        d.delete();
        gRegisterDialog = None
    }
}

/// 显示注册对话框：创建窗口 → 设置布局 → 显示。
/// 防止重复创建：若已存在则直接 show。
public func showRegisterDialog(): Unit {
    if (let Some(d) <- gRegisterDialog) {
        d.show();
        return
    }

    let dialog = QWidget()
    dialog.setTitle("注册新账号")
    dialog.resizeDp(380, 280)
    dialog.setMinimumSizeDp(300, 220)
    gRegisterDialog = dialog

    let layout = QVBoxLayout()
    layout.setMargin(20)
    layout.setSpacing(12)

    let title = createLabel("注册新账号")
    title.setStyleSheet("font-size: 18px; font-weight: bold;")
    title.setAlignment(Alignment.Center.value)
    layout.addWidget(title.getPtr())

    // 提示：账号自动分配
    let hint = createLabel("账号将自动分配（10000 起，新注册 +1）")
    hint.setStyleSheet("color: #95a5a6; font-size: 11px;")
    hint.setAlignment(Alignment.Center.value)
    layout.addWidget(hint.getPtr())

    // 密码
    let pwdEdit = createLineEdit("密码")
    pwdEdit.setEchoMode(LineEditEchoMode.Password)
    gRegPassword = pwdEdit
    layout.addLayout(createLabeledRow("密码:", pwdEdit.getPtr()))

    // 昵称
    let nameEdit = createLineEdit("昵称（显示名）")
    gRegDisplayName = nameEdit
    layout.addLayout(createLabeledRow("昵称:", nameEdit.getPtr()))

    // 按钮
    let btnRow = QHBoxLayout()
    let confirmBtn = createButton("确认注册", onRegisterConfirm)
    confirmBtn.setStyleSheet("background-color: #3498db; color: white; padding: 8px 18px; border-radius: 3px;")
    let cancelBtn = createButton("取消", onRegisterCancel)
    btnRow.addWidget(confirmBtn.getPtr())
    btnRow.addWidget(cancelBtn.getPtr())
    layout.addLayout(btnRow.getPtr())

    layout.addStretch()
    dialog.setLayout(layout.getPtr())
    dialog.show()
}

/// 执行注册：校验必填字段 → 调用数据库 addUser → 成功则提示新账号并关闭对话框。
public func doRegister(): Unit {
    let password = if (let Some(e) <- gRegPassword) {
        e.text()
    } else {
        ""
    }
    let displayName = if (let Some(e) <- gRegDisplayName) {
        e.text()
    } else {
        ""
    }

    // 校验：密码和昵称为必填
    if (password.isEmpty() || displayName.isEmpty()) {
        QMessageBox.warning(0, "提示", "请填写必填字段（密码、昵称）")
        return
    }

    if (let Some(db) <- gDb) {
        let newAccount = db.addUser(password, displayName)
        if (newAccount > 0) {
            QMessageBox.information(0, "成功", "注册成功！您的账号是 ${newAccount}，请使用该账号登录。")
            closeRegisterDialog()
        } else {
            QMessageBox.warning(0, "错误", "注册失败，请重试。")
        }
    }
}

// ============================================================
// 修改密码对话框
// ============================================================

/// 修改密码确认按钮回调
let onChangePwdConfirm: VoidCallback = {
    => doChangePassword()
}

/// 修改密码取消按钮回调
let onChangePwdCancel: VoidCallback = {
    => closeChangePwdDialog()
}

/// 关闭修改密码对话框并释放资源。
public func closeChangePwdDialog(): Unit {
    if (let Some(d) <- gChangePwdDialog) {
        d.hide();
        d.delete();
        gChangePwdDialog = None
    }
}

/// 显示修改密码对话框。
public func showChangePwdDialog(): Unit {
    if (let Some(d) <- gChangePwdDialog) {
        d.show();
        return
    }

    let dialog = QWidget()
    dialog.setTitle("修改密码")
    dialog.resizeDp(380, 260)
    dialog.setMinimumSizeDp(300, 220)
    gChangePwdDialog = dialog

    let layout = QVBoxLayout()
    layout.setMargin(20)
    layout.setSpacing(12)

    let title = createLabel("修改密码")
    title.setStyleSheet("font-size: 18px; font-weight: bold;")
    title.setAlignment(Alignment.Center.value)
    layout.addWidget(title.getPtr())

    // 旧密码
    let oldEdit = createLineEdit("请输入旧密码")
    oldEdit.setEchoMode(LineEditEchoMode.Password)
    gOldPwdEdit = oldEdit
    layout.addLayout(createLabeledRow("旧密码:", oldEdit.getPtr()))

    // 新密码
    let newEdit = createLineEdit("请输入新密码")
    newEdit.setEchoMode(LineEditEchoMode.Password)
    gNewPwdEdit = newEdit
    layout.addLayout(createLabeledRow("新密码:", newEdit.getPtr()))

    // 确认新密码
    let confirmEdit = createLineEdit("再次输入新密码")
    confirmEdit.setEchoMode(LineEditEchoMode.Password)
    confirmEdit.setOnReturnPressed(onChangePwdConfirm) // 回车确认
    gConfirmPwdEdit = confirmEdit
    layout.addLayout(createLabeledRow("确  认:", confirmEdit.getPtr()))

    // 按钮
    let btnRow = QHBoxLayout()
    let confirmBtn = createButton("确认修改", onChangePwdConfirm)
    confirmBtn.setStyleSheet("background-color: #3498db; color: white; padding: 8px 18px; border-radius: 3px;")
    let cancelBtn = createButton("取消", onChangePwdCancel)
    btnRow.addWidget(confirmBtn.getPtr())
    btnRow.addWidget(cancelBtn.getPtr())
    layout.addLayout(btnRow.getPtr())

    layout.addStretch()
    dialog.setLayout(layout.getPtr())
    dialog.show()
}

/// 执行修改密码：校验旧密码/新密码/确认一致性 → 调用数据库 changePassword。
public func doChangePassword(): Unit {
    let oldPwd = if (let Some(e) <- gOldPwdEdit) {
        e.text()
    } else {
        ""
    }
    let newPwd = if (let Some(e) <- gNewPwdEdit) {
        e.text()
    } else {
        ""
    }
    let confirmPwd = if (let Some(e) <- gConfirmPwdEdit) {
        e.text()
    } else {
        ""
    }

    // 校验：旧密码和新密码不能为空
    if (oldPwd.isEmpty() || newPwd.isEmpty()) {
        QMessageBox.warning(0, "提示", "请填写旧密码和新密码")
        return
    }
    // 校验：两次新密码一致
    if (newPwd != confirmPwd) {
        QMessageBox.warning(0, "提示", "两次输入的新密码不一致")
        return
    }
    // 校验：新密码不能与旧密码相同
    if (newPwd == oldPwd) {
        QMessageBox.warning(0, "提示", "新密码不能与旧密码相同")
        return
    }
    // 执行修改
    if (let Some(u) <- gCurrentUser) {
        if (let Some(db) <- gDb) {
            if (db.changePassword(u.id, oldPwd, newPwd)) {
                u.password = newPwd // 同步更新内存中的用户信息
                QMessageBox.information(0, "成功", "密码修改成功！下次请使用新密码登录。")
                closeChangePwdDialog()
            } else {
                QMessageBox.warning(0, "错误", "旧密码不正确，修改失败")
            }
        }
    }
}

// ============================================================
// 添加好友对话框
// ============================================================

/// 搜索按钮回调
let onSearchClick: VoidCallback = {
    => doSearchUsers()
}

/// 添加好友确认按钮回调
let onAddFriendConfirm: VoidCallback = {
    => doAddFriend()
}

/// 添加好友取消按钮回调
let onAddFriendCancel: VoidCallback = {
    => closeAddFriendDialog()
}

/// 关闭添加好友对话框并释放资源。
public func closeAddFriendDialog(): Unit {
    if (let Some(d) <- gAddFriendDialog) {
        d.hide();
        d.delete();
        gAddFriendDialog = None
    }
}

/// 执行搜索用户：按关键字查询 → 结果显示在列表中。
public func doSearchUsers(): Unit {
    if (let Some(list) <- gSearchResultList) {
        list.clear()
        gSearchCache.clear()
        let keyword = if (let Some(e) <- gSearchEdit) {
            e.text()
        } else {
            ""
        }
        if (keyword.isEmpty()) {
            return
        }
        if (let Some(db) <- gDb) {
            let users = db.searchUsersByKeyword(keyword)
            for (u in users) {
                list.addItem("${u.displayName} (${u.account})")
                gSearchCache.add(u)
            }
        }
    }
}

/// 执行添加好友：选中搜索结果 → 调用数据库 addFriend → 刷新好友列表。
public func doAddFriend(): Unit {
    if (let Some(list) <- gSearchResultList) {
        let row = list.currentRow()
        if (row < 0 || Int64(row) >= gSearchCache.size) {
            QMessageBox.warning(0, "提示", "请先搜索并选择要添加的用户")
            return
        }
        let target = gSearchCache[Int64(row)]
        if (let Some(db) <- gDb) {
            if (let Some(u) <- gCurrentUser) {
                if (db.addFriend(u.id, target.id, target.displayName)) {
                    QMessageBox.information(0, "成功", "已添加 ${target.displayName} 为好友")
                    refreshFriendList()
                    closeAddFriendDialog()
                } else {
                    QMessageBox.warning(0, "提示", "该用户已是好友或添加失败")
                }
            }
        }
    }
}

/// 显示添加好友对话框：搜索框 + 结果列表 + 添加/关闭按钮。
public func showAddFriendDialog(): Unit {
    if (let Some(d) <- gAddFriendDialog) {
        d.show();
        return
    }

    let dialog = QWidget()
    dialog.setTitle("添加好友")
    dialog.resizeDp(360, 420)
    dialog.setMinimumSizeDp(280, 300)
    gAddFriendDialog = dialog

    let layout = QVBoxLayout()
    layout.setMargin(20)
    layout.setSpacing(12)

    let title = createLabel("添加好友")
    title.setStyleSheet("font-size: 18px; font-weight: bold;")
    title.setAlignment(Alignment.Center.value)
    layout.addWidget(title.getPtr())

    // 搜索行
    let searchRow = QHBoxLayout()
    let searchEdit = createLineEdit("输入账号或昵称")
    gSearchEdit = searchEdit
    searchRow.addWidget(searchEdit.getPtr())
    let searchBtn = createButton("搜索", onSearchClick)
    searchRow.addWidget(searchBtn.getPtr())
    layout.addLayout(searchRow.getPtr())

    // 结果列表
    let resultList = QListWidget()
    gSearchResultList = resultList
    layout.addWidget(resultList.getPtr())

    // 按钮
    let btnRow = QHBoxLayout()
    let confirmBtn = createButton("添加选中", onAddFriendConfirm)
    confirmBtn.setStyleSheet("background-color: #3498db; color: white; padding: 8px 18px; border-radius: 3px;")
    let cancelBtn = createButton("关闭", onAddFriendCancel)
    btnRow.addWidget(confirmBtn.getPtr())
    btnRow.addWidget(cancelBtn.getPtr())
    layout.addLayout(btnRow.getPtr())

    layout.addStretch()
    dialog.setLayout(layout.getPtr())
    dialog.show()
}
