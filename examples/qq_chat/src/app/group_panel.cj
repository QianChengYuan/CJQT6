package qq_chat.app

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import std.collection.*
import qq_chat.core.*
import qq_chat.state.*

public func initFriendGroups(friends: ArrayList<Friend>): Unit {
    gFriendGroups.clear()
    let myFriends = FriendGroup()
    myFriends.groupId = 1
    myFriends.name = "我的好友"
    for (f in friends) {
        myFriends.friends.add(f)
    }
    gFriendGroups.add(myFriends)
    let groupChat = FriendGroup()
    groupChat.groupId = 2
    groupChat.name = "群/校友录"
    gFriendGroups.add(groupChat)
    let recent = FriendGroup()
    recent.groupId = 3
    recent.name = "最近联系人"
    gFriendGroups.add(recent)
}

public func buildGroupHeader(name: String, onlineCount: Int32, totalCount: Int32, expanded: Bool): QWidget {
    let header = QWidget()
    header.setStyleSheet(buildGroupHeaderStyleSheet())
    let layout = QHBoxLayout()
    layout.setMargin(4)
    layout.setSpacing(4)
    let arrow = QLabel()
    if (expanded) {
        arrow.setText("▼")
    } else {
        arrow.setText("▶")
    }
    arrow.setStyleSheet("color: white; font-size: 12px;")
    layout.addWidget(arrow.getPtr())
    let nameLbl = QLabel()
    nameLbl.setText("${name}(${onlineCount}/${totalCount})")
    nameLbl.setStyleSheet("color: white; font-size: 13px;")
    layout.addWidget(nameLbl.getPtr())
    layout.addStretch()
    header.setLayout(layout.getPtr())
    header
}

public func toggleGroup(groupId: Int64): Unit {
    for (i in 0..gFriendGroups.size) {
        let group = gFriendGroups[i]
        if (group.groupId == groupId) {
            group.expanded = !group.expanded
        }
    }
}