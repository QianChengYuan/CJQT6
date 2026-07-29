// ============================================================
// 宿舍管理系统 - 数据模型定义
// ============================================================
package dormitory_manager

import std.time.*

// ============================================================
// 角色常量
// ============================================================
public const ROLE_ADMIN: String = "admin" // 系统管理员
public const ROLE_MANAGER: String = "manager" // 宿管
public const ROLE_STUDENT: String = "student" // 学生

// ============================================================
// 考勤状态常量
// ============================================================
public const ATTENDANCE_NORMAL: String = "normal" // 正常
public const ATTENDANCE_LATE: String = "late" // 迟到
public const ATTENDANCE_EARLY: String = "early" // 早退
public const ATTENDANCE_ABSENT: String = "absent" // 缺勤
public const ATTENDANCE_LEAVE: String = "leave" // 请假

// ============================================================
// 报修状态常量
// ============================================================
public const REPAIR_PENDING: String = "pending" // 待处理
public const REPAIR_PROCESSING: String = "processing" // 处理中
public const REPAIR_RESOLVED: String = "resolved" // 已解决
public const REPAIR_REJECTED: String = "rejected" // 已拒绝

// ============================================================
// 报修分类常量
// ============================================================
public const REPAIR_ELECTRIC: String = "electric" // 电力
public const REPAIR_PLUMBING: String = "plumbing" // 水管
public const REPAIR_FURNITURE: String = "furniture" // 家具
public const REPAIR_OTHER: String = "other" // 其他

// ============================================================
// 公告目标角色常量
// ============================================================
public const ANNOUNCE_ALL: String = "all" // 全部
public const ANNOUNCE_ADMIN: String = "admin" // 管理员
public const ANNOUNCE_MANAGER: String = "manager" // 宿管
public const ANNOUNCE_STUDENT: String = "student" // 学生

// ============================================================
// 用户模型
// ============================================================
public class User {
    public var id: Int64 = 0
    public var username: String = ""
    public var password: String = ""
    public var role: String = ""
    public var displayName: String = ""
    public var phone: String = ""
    public var createTime: String = ""

    public init() {}
}

// ============================================================
// 宿舍楼模型
// ============================================================
public class DormBuilding {
    public var id: Int64 = 0
    public var name: String = ""
    public var floors: Int32 = 0
    public var roomsPerFloor: Int32 = 0
    public var address: String = ""
    public var managerId: Int64 = 0
    public var managerName: String = ""

    public init() {}
}

// ============================================================
// 房间模型
// ============================================================
public class DormRoom {
    public var id: Int64 = 0
    public var buildingId: Int64 = 0
    public var buildingName: String = ""
    public var roomNo: String = ""
    public var floor: Int32 = 0
    public var capacity: Int32 = 0
    public var occupied: Int32 = 0

    public init() {}
}

// ============================================================
// 学生模型
// ============================================================
public class Student {
    public var id: Int64 = 0
    public var userId: Int64 = 0
    public var username: String = ""
    public var studentNo: String = ""
    public var displayName: String = ""
    public var gender: String = ""
    public var phone: String = ""
    public var className: String = ""
    public var enrollYear: Int32 = 0
    public var buildingId: Int64 = 0
    public var buildingName: String = ""
    public var roomId: Int64 = 0
    public var roomNo: String = ""
    public var bedNo: Int32 = 0

    public init() {}
}

// ============================================================
// 考勤记录模型
// ============================================================
public class Attendance {
    public var id: Int64 = 0
    public var studentId: Int64 = 0
    public var studentNo: String = ""
    public var studentName: String = ""
    public var date: String = ""
    public var status: String = ""
    public var checkInTime: String = ""
    public var checkOutTime: String = ""
    public var note: String = ""

    public init() {}
}

// ============================================================
// 报修记录模型
// ============================================================
public class Repair {
    public var id: Int64 = 0
    public var studentId: Int64 = 0
    public var studentName: String = ""
    public var studentNo: String = ""
    public var roomId: Int64 = 0
    public var roomNo: String = ""
    public var buildingName: String = ""
    public var title: String = ""
    public var description: String = ""
    public var category: String = ""
    public var status: String = ""
    public var createTime: String = ""
    public var resolveTime: String = ""
    public var managerId: Int64 = 0
    public var managerName: String = ""
    public var note: String = ""

    public init() {}
}

// ============================================================
// 公告模型
// ============================================================
public class Announcement {
    public var id: Int64 = 0
    public var title: String = ""
    public var content: String = ""
    public var createTime: String = ""
    public var authorId: Int64 = 0
    public var authorName: String = ""
    public var targetRole: String = ""

    public init() {}
}

// ============================================================
// 仪表板统计信息
// ============================================================
public class DashboardStats {
    public var totalBuildings: Int32 = 0
    public var totalRooms: Int32 = 0
    public var totalStudents: Int32 = 0
    public var totalManagers: Int32 = 0
    public var pendingRepairs: Int32 = 0
    public var todayAbsent: Int32 = 0
    public var availableBeds: Int32 = 0

    public init() {}
}

// ============================================================
// 辅助函数
// ============================================================

/// 获取状态的中文显示名
public func getStatusDisplayName(status: String): String {
    if (status == ATTENDANCE_NORMAL) {
        return "正常"
    }
    if (status == ATTENDANCE_LATE) {
        return "迟到"
    }
    if (status == ATTENDANCE_EARLY) {
        return "早退"
    }
    if (status == ATTENDANCE_ABSENT) {
        return "缺勤"
    }
    if (status == ATTENDANCE_LEAVE) {
        return "请假"
    }
    if (status == REPAIR_PENDING) {
        return "待处理"
    }
    if (status == REPAIR_PROCESSING) {
        return "处理中"
    }
    if (status == REPAIR_RESOLVED) {
        return "已解决"
    }
    if (status == REPAIR_REJECTED) {
        return "已拒绝"
    }
    return status
}

/// 获取报修分类的中文名
public func getRepairCategoryDisplay(category: String): String {
    if (category == REPAIR_ELECTRIC) {
        return "电力维修"
    }
    if (category == REPAIR_PLUMBING) {
        return "水管维修"
    }
    if (category == REPAIR_FURNITURE) {
        return "家具维修"
    }
    if (category == REPAIR_OTHER) {
        return "其他"
    }

    return category
}

/// 获取角色中文名
public func getRoleDisplay(role: String): String {
    if (role == ROLE_ADMIN) {
        return "管理员"
    }
    if (role == ROLE_MANAGER) {
        return "宿管"
    }
    if (role == ROLE_STUDENT) {
        return "学生"
    }
    return role
}

/// 获取今天的日期字符串 (yyyy-MM-dd)
public func getTodayString(): String {
    let now = DateTime.now()
    let dateStr = now.toString()
    return if (dateStr.size >= 10) {
        dateStr[0..10]
    } else {
        dateStr
    }
}

/// 获取当前时间字符串 (yyyy-MM-dd HH:mm:ss)
public func getNowString(): String {
    let now = DateTime.now()
    let str = now.toString()
    return if (str.size >= 19) {
        str[0..19]
    } else {
        str
    }
}

/// 字符串转Float64
public func stringToFloat(s: String): Float64 {
    var result: Float64 = 0.0
    var negative = false
    var decimal = false
    var decimalPlace: Float64 = 0.1
    var start = 0
    if (s.size > 0 && s[0] == 45) {
        negative = true
        start = 1
    }
    for (i in start..s.size) {
        let c = s[i]
        if (c >= 48 && c <= 57) {
            if (decimal) {
                result = result + Float64(c - 48) * decimalPlace
                decimalPlace = decimalPlace * 0.1
            } else {
                result = result * 10.0 + Float64(c - 48)
            }
        } else if (c == 46) {
            decimal = true
        }
    }
    return if (negative) {
        -result
    } else {
        result
    }
}

/// Float64转字符串保留两位小数
public func formatFloat64(amount: Float64): String {
    let intPart = Int64(amount)
    let decimalPart = Int64((amount - Float64(intPart)) * 100.0 + 0.5)
    return "${intPart}.${if (decimalPart < 10) { "0" } else { "" }}${decimalPart}"
}
