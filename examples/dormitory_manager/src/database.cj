// ============================================================
// 宿舍管理系统 - 数据库管理
// ============================================================
package dormitory_manager

import cjqt6.sql.*
import std.collection.*

// ============================================================
// DatabaseManager - 所有数据库操作
// ============================================================
public class DatabaseManager {
    private var db: QSqlDatabase
    private var query: QSqlQuery

    public init(db: QSqlDatabase) {
        this.db = db
        this.query = QSqlQuery(db)
        createTables()
        initDefaultData()
    }

    // ============================================================
    // 建表
    // ============================================================
    private func createTables(): Unit {
        // 用户表
        query.exec("CREATE TABLE IF NOT EXISTS users (" +
            "id INTEGER PRIMARY KEY, " +
            "username TEXT UNIQUE NOT NULL, " +
            "password TEXT NOT NULL, " +
            "role TEXT NOT NULL, " +
            "display_name TEXT NOT NULL, " +
            "phone TEXT, " +
            "create_time TEXT NOT NULL)")

        // 宿舍楼表
        query.exec("CREATE TABLE IF NOT EXISTS dorm_buildings (" +
            "id INTEGER PRIMARY KEY, " +
            "name TEXT NOT NULL UNIQUE, " +
            "floors INTEGER NOT NULL, " +
            "rooms_per_floor INTEGER NOT NULL, " +
            "address TEXT, " +
            "manager_id INTEGER)")

        // 房间表
        query.exec("CREATE TABLE IF NOT EXISTS dorm_rooms (" +
            "id INTEGER PRIMARY KEY, " +
            "building_id INTEGER NOT NULL, " +
            "room_no TEXT NOT NULL, " +
            "floor INTEGER NOT NULL, " +
            "capacity INTEGER NOT NULL DEFAULT 4, " +
            "occupied INTEGER NOT NULL DEFAULT 0)")

        // 学生表
        query.exec("CREATE TABLE IF NOT EXISTS students (" +
            "id INTEGER PRIMARY KEY, " +
            "user_id INTEGER NOT NULL UNIQUE, " +
            "student_no TEXT UNIQUE NOT NULL, " +
            "gender TEXT NOT NULL, " +
            "class_name TEXT NOT NULL, " +
            "enroll_year INTEGER NOT NULL, " +
            "building_id INTEGER, " +
            "room_id INTEGER, " +
            "bed_no INTEGER)")

        // 考勤表
        query.exec("CREATE TABLE IF NOT EXISTS attendance (" +
            "id INTEGER PRIMARY KEY, " +
            "student_id INTEGER NOT NULL, " +
            "date TEXT NOT NULL, " +
            "status TEXT NOT NULL, " +
            "check_in_time TEXT, " +
            "check_out_time TEXT, " +
            "note TEXT)")

        // 报修表
        query.exec("CREATE TABLE IF NOT EXISTS repairs (" +
            "id INTEGER PRIMARY KEY, " +
            "student_id INTEGER NOT NULL, " +
            "room_id INTEGER NOT NULL, " +
            "title TEXT NOT NULL, " +
            "description TEXT, " +
            "category TEXT NOT NULL, " +
            "status TEXT NOT NULL DEFAULT 'pending', " +
            "create_time TEXT NOT NULL, " +
            "resolve_time TEXT, " +
            "manager_id INTEGER, " +
            "note TEXT)")

        // 公告表
        query.exec("CREATE TABLE IF NOT EXISTS announcements (" +
            "id INTEGER PRIMARY KEY, " +
            "title TEXT NOT NULL, " +
            "content TEXT NOT NULL, " +
            "create_time TEXT NOT NULL, " +
            "author_id INTEGER NOT NULL, " +
            "target_role TEXT NOT NULL DEFAULT 'all')")
    }

    // ============================================================
    // 初始化默认数据
    // ============================================================
    private func initDefaultData(): Unit {
        // 检查是否存在管理员账号
        query.exec("SELECT COUNT(*) FROM users WHERE role = 'admin'")
        if (query.next()) {
            let count = query.valueInt(0)
            if (count > 0) { return }
        }

        // 创建默认管理员: admin/admin123
        let now = getNowString()
        query.exec("INSERT INTO users (id, username, password, role, display_name, phone, create_time) " +
            "VALUES (1, 'admin', 'admin123', 'admin', '系统管理员', '13800000000', '${now}')")

        // 创建默认宿管
        query.exec("INSERT INTO users (id, username, password, role, display_name, phone, create_time) " +
            "VALUES (2, 'manager1', 'manager123', 'manager', '张宿管', '13800000001', '${now}')")
        query.exec("INSERT INTO users (id, username, password, role, display_name, phone, create_time) " +
            "VALUES (3, 'manager2', 'manager123', 'manager', '李宿管', '13800000002', '${now}')")

        // 创建默认学生
        query.exec("INSERT INTO users (id, username, password, role, display_name, phone, create_time) " +
            "VALUES (4, 'student1', 'stu123', 'student', '王小明', '13800000003', '${now}')")
        query.exec("INSERT INTO users (id, username, password, role, display_name, phone, create_time) " +
            "VALUES (5, 'student2', 'stu123', 'student', '赵小红', '13800000004', '${now}')")
        query.exec("INSERT INTO users (id, username, password, role, display_name, phone, create_time) " +
            "VALUES (6, 'student3', 'stu123', 'student', '刘小刚', '13800000005', '${now}')")

        // 创建默认宿舍楼
        query.exec("INSERT INTO dorm_buildings (id, name, floors, rooms_per_floor, address, manager_id) " +
            "VALUES (1, '静苑1号楼', 6, 20, '校园南区', 2)")
        query.exec("INSERT INTO dorm_buildings (id, name, floors, rooms_per_floor, address, manager_id) " +
            "VALUES (2, '静苑2号楼', 6, 20, '校园南区', 3)")

        // 创建默认房间 (1号楼)
        query.exec("INSERT INTO dorm_rooms (id, building_id, room_no, floor, capacity, occupied) " +
            "VALUES (1, 1, '101', 1, 4, 2)")
        query.exec("INSERT INTO dorm_rooms (id, building_id, room_no, floor, capacity, occupied) " +
            "VALUES (2, 1, '102', 1, 4, 1)")
        query.exec("INSERT INTO dorm_rooms (id, building_id, room_no, floor, capacity, occupied) " +
            "VALUES (3, 1, '201', 2, 4, 0)")
        query.exec("INSERT INTO dorm_rooms (id, building_id, room_no, floor, capacity, occupied) " +
            "VALUES (4, 2, '101', 1, 4, 0)")

        // 创建默认学生信息
        query.exec("INSERT INTO students (id, user_id, student_no, gender, class_name, enroll_year, building_id, room_id, bed_no) " +
            "VALUES (1, 4, '2024001', 'male', '计算机2401', 2024, 1, 1, 1)")
        query.exec("INSERT INTO students (id, user_id, student_no, gender, class_name, enroll_year, building_id, room_id, bed_no) " +
            "VALUES (2, 5, '2024002', 'female', '软件2401', 2024, 1, 1, 2)")
        query.exec("INSERT INTO students (id, user_id, student_no, gender, class_name, enroll_year, building_id, room_id, bed_no) " +
            "VALUES (3, 6, '2024003', 'male', '计算机2401', 2024, 1, 2, 1)")

        // 创建默认考勤记录
        let today = getTodayString()
        query.exec("INSERT INTO attendance (id, student_id, date, status, check_in_time, check_out_time, note) " +
            "VALUES (1, 1, '${today}', 'normal', '07:30', '22:00', '')")
        query.exec("INSERT INTO attendance (id, student_id, date, status, check_in_time, check_out_time, note) " +
            "VALUES (2, 2, '${today}', 'normal', '07:45', '21:30', '')")
        query.exec("INSERT INTO attendance (id, student_id, date, status, check_in_time, check_out_time, note) " +
            "VALUES (3, 3, '${today}', 'late', '08:30', '22:15', '睡过头了')")

        // 创建默认报修
        query.exec("INSERT INTO repairs (id, student_id, room_id, title, description, category, status, create_time, note) " +
            "VALUES (1, 1, 1, '灯泡坏了', '宿舍灯管不亮，需要更换', 'electric', 'pending', '${now}', '')")

        // 创建默认公告
        query.exec("INSERT INTO announcements (id, title, content, create_time, author_id, target_role) " +
            "VALUES (1, '欢迎使用宿舍管理系统', '欢迎各位同学使用宿舍管理系统！本系统提供在线报修、考勤查询等功能。', '${now}', 1, 'all')")
    }

    // ============================================================
    // 用户认证
    // ============================================================
    public func login(username: String, password: String): ?User {
        query.exec("SELECT id, username, password, role, display_name, phone, create_time " +
            "FROM users WHERE username = '${username}' AND password = '${password}'")
        if (query.next()) {
            let user = User()
            user.id = Int64(query.valueInt(0))
            user.username = query.valueString(1)
            user.password = query.valueString(2)
            user.role = query.valueString(3)
            user.displayName = query.valueString(4)
            user.phone = query.valueString(5)
            user.createTime = query.valueString(6)
            return Some(user)
        }
        return None
    }

    // ============================================================
    // 用户管理 (Admin)
    // ============================================================
    public func addUser(username: String, password: String, role: String, displayName: String, phone: String): Int64 {
        let now = getNowString()
        let sql = "INSERT INTO users (id, username, password, role, display_name, phone, create_time) " +
            "VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM users), '${username}', '${password}', " +
            "'${role}', '${displayName}', '${phone}', '${now}')"
        if (query.exec(sql)) {
            query.exec("SELECT MAX(id) FROM users")
            if (query.next()) { return Int64(query.valueInt(0)) }
        }
        return 0
    }

    public func updateUser(id: Int64, displayName: String, phone: String, password: String): Bool {
        var sql = "UPDATE users SET display_name = '${displayName}', phone = '${phone}'"
        if (!password.isEmpty()) { sql = sql + ", password = '${password}'" }
        sql = sql + " WHERE id = ${id}"
        return query.exec(sql)
    }

    public func deleteUser(id: Int64): Bool {
        return query.exec("DELETE FROM users WHERE id = ${id}")
    }

    public func getAllUsers(): ArrayList<User> {
        let list = ArrayList<User>()
        query.exec("SELECT id, username, password, role, display_name, phone, create_time FROM users ORDER BY id")
        while (query.next()) {
            let u = User()
            u.id = Int64(query.valueInt(0))
            u.username = query.valueString(1)
            u.password = query.valueString(2)
            u.role = query.valueString(3)
            u.displayName = query.valueString(4)
            u.phone = query.valueString(5)
            u.createTime = query.valueString(6)
            list.add(u)
        }
        return list
    }

    public func getUsersByRole(role: String): ArrayList<User> {
        let list = ArrayList<User>()
        query.exec("SELECT id, username, password, role, display_name, phone, create_time " +
            "FROM users WHERE role = '${role}' ORDER BY id")
        while (query.next()) {
            let u = User()
            u.id = Int64(query.valueInt(0))
            u.username = query.valueString(1)
            u.password = query.valueString(2)
            u.role = query.valueString(3)
            u.displayName = query.valueString(4)
            u.phone = query.valueString(5)
            u.createTime = query.valueString(6)
            list.add(u)
        }
        return list
    }

    // ============================================================
    // 宿舍楼管理
    // ============================================================
    public func addBuilding(name: String, floors: Int32, roomsPerFloor: Int32, address: String, managerId: Int64): Int64 {
        let sql = "INSERT INTO dorm_buildings (id, name, floors, rooms_per_floor, address, manager_id) " +
            "VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM dorm_buildings), " +
            "'${name}', ${floors}, ${roomsPerFloor}, '${address}', ${managerId})"
        if (query.exec(sql)) {
            query.exec("SELECT MAX(id) FROM dorm_buildings")
            if (query.next()) { return Int64(query.valueInt(0)) }
        }
        return 0
    }

    public func updateBuilding(id: Int64, name: String, floors: Int32, roomsPerFloor: Int32, address: String, managerId: Int64): Bool {
        return query.exec("UPDATE dorm_buildings SET name = '${name}', floors = ${floors}, " +
            "rooms_per_floor = ${roomsPerFloor}, address = '${address}', manager_id = ${managerId} WHERE id = ${id}")
    }

    public func deleteBuilding(id: Int64): Bool {
        // 先删除该楼的所有房间
        query.exec("DELETE FROM dorm_rooms WHERE building_id = ${id}")
        return query.exec("DELETE FROM dorm_buildings WHERE id = ${id}")
    }

    public func getAllBuildings(): ArrayList<DormBuilding> {
        let list = ArrayList<DormBuilding>()
        query.exec("SELECT b.id, b.name, b.floors, b.rooms_per_floor, b.address, b.manager_id, " +
            "COALESCE(u.display_name, '') FROM dorm_buildings b " +
            "LEFT JOIN users u ON b.manager_id = u.id ORDER BY b.id")
        while (query.next()) {
            let b = DormBuilding()
            b.id = Int64(query.valueInt(0))
            b.name = query.valueString(1)
            b.floors = query.valueInt(2)
            b.roomsPerFloor = query.valueInt(3)
            b.address = query.valueString(4)
            b.managerId = Int64(query.valueInt(5))
            b.managerName = query.valueString(6)
            list.add(b)
        }
        return list
    }

    // ============================================================
    // 房间管理
    // ============================================================
    public func addRoom(buildingId: Int64, roomNo: String, floor: Int32, capacity: Int32): Int64 {
        let sql = "INSERT INTO dorm_rooms (id, building_id, room_no, floor, capacity, occupied) " +
            "VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM dorm_rooms), " +
            "${buildingId}, '${roomNo}', ${floor}, ${capacity}, 0)"
        if (query.exec(sql)) {
            query.exec("SELECT MAX(id) FROM dorm_rooms")
            if (query.next()) { return Int64(query.valueInt(0)) }
        }
        return 0
    }

    public func updateRoom(id: Int64, buildingId: Int64, roomNo: String, floor: Int32, capacity: Int32): Bool {
        return query.exec("UPDATE dorm_rooms SET building_id = ${buildingId}, room_no = '${roomNo}', " +
            "floor = ${floor}, capacity = ${capacity} WHERE id = ${id}")
    }

    public func deleteRoom(id: Int64): Bool {
        return query.exec("DELETE FROM dorm_rooms WHERE id = ${id}")
    }

    public func getRoomsByBuilding(buildingId: Int64): ArrayList<DormRoom> {
        let list = ArrayList<DormRoom>()
        query.exec("SELECT r.id, r.building_id, COALESCE(b.name, ''), r.room_no, r.floor, " +
            "r.capacity, r.occupied FROM dorm_rooms r " +
            "LEFT JOIN dorm_buildings b ON r.building_id = b.id " +
            "WHERE r.building_id = ${buildingId} ORDER BY r.room_no")
        while (query.next()) {
            let r = DormRoom()
            r.id = Int64(query.valueInt(0))
            r.buildingId = Int64(query.valueInt(1))
            r.buildingName = query.valueString(2)
            r.roomNo = query.valueString(3)
            r.floor = query.valueInt(4)
            r.capacity = query.valueInt(5)
            r.occupied = query.valueInt(6)
            list.add(r)
        }
        return list
    }

    public func getAllRooms(): ArrayList<DormRoom> {
        let list = ArrayList<DormRoom>()
        query.exec("SELECT r.id, r.building_id, COALESCE(b.name, ''), r.room_no, r.floor, " +
            "r.capacity, r.occupied FROM dorm_rooms r " +
            "LEFT JOIN dorm_buildings b ON r.building_id = b.id ORDER BY b.name, r.room_no")
        while (query.next()) {
            let r = DormRoom()
            r.id = Int64(query.valueInt(0))
            r.buildingId = Int64(query.valueInt(1))
            r.buildingName = query.valueString(2)
            r.roomNo = query.valueString(3)
            r.floor = query.valueInt(4)
            r.capacity = query.valueInt(5)
            r.occupied = query.valueInt(6)
            list.add(r)
        }
        return list
    }

    public func getAvailableRooms(): ArrayList<DormRoom> {
        let list = ArrayList<DormRoom>()
        query.exec("SELECT r.id, r.building_id, COALESCE(b.name, ''), r.room_no, r.floor, " +
            "r.capacity, r.occupied FROM dorm_rooms r " +
            "LEFT JOIN dorm_buildings b ON r.building_id = b.id " +
            "WHERE r.occupied < r.capacity ORDER BY b.name, r.room_no")
        while (query.next()) {
            let r = DormRoom()
            r.id = Int64(query.valueInt(0))
            r.buildingId = Int64(query.valueInt(1))
            r.buildingName = query.valueString(2)
            r.roomNo = query.valueString(3)
            r.floor = query.valueInt(4)
            r.capacity = query.valueInt(5)
            r.occupied = query.valueInt(6)
            list.add(r)
        }
        return list
    }

    // ============================================================
    // 学生管理
    // ============================================================
    public func addStudent(userId: Int64, studentNo: String, displayName: String, gender: String,
            phone: String, className: String, enrollYear: Int32,
            buildingId: Int64, roomId: Int64, bedNo: Int32): Int64 {
        // 更新用户显示名
        query.exec("UPDATE users SET display_name = '${displayName}', phone = '${phone}' WHERE id = ${userId}")
        // 添加学生记录
        let sql = "INSERT INTO students (id, user_id, student_no, gender, class_name, enroll_year, " +
            "building_id, room_id, bed_no) VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM students), " +
            "${userId}, '${studentNo}', '${gender}', '${className}', ${enrollYear}, " +
            "${buildingId}, ${roomId}, ${bedNo})"
        if (query.exec(sql)) {
            // 更新房间已住人数
            query.exec("UPDATE dorm_rooms SET occupied = occupied + 1 WHERE id = ${roomId}")
            query.exec("SELECT MAX(id) FROM students")
            if (query.next()) { return Int64(query.valueInt(0)) }
        }
        return 0
    }

    public func updateStudent(id: Int64, studentNo: String, displayName: String, gender: String,
            phone: String, className: String, enrollYear: Int32,
            buildingId: Int64, roomId: Int64, bedNo: Int32): Bool {
        // 获取旧房间信息
        query.exec("SELECT room_id, building_id FROM students WHERE id = ${id}")
        var oldRoomId: Int64 = 0
        var oldBuildingId: Int64 = 0
        if (query.next()) {
            oldRoomId = Int64(query.valueInt(0))
            oldBuildingId = Int64(query.valueInt(1))
        }
        // 更新用户信息
        query.exec("UPDATE users SET display_name = '${displayName}', phone = '${phone}' " +
            "WHERE id = (SELECT user_id FROM students WHERE id = ${id})")
        // 更新学生记录
        let sql = "UPDATE students SET student_no = '${studentNo}', gender = '${gender}', " +
            "class_name = '${className}', enroll_year = ${enrollYear}, " +
            "building_id = ${buildingId}, room_id = ${roomId}, bed_no = ${bedNo} WHERE id = ${id}"
        let result = query.exec(sql)
        // 如果房间变了，更新房间人数
        if (result && oldRoomId != roomId) {
            query.exec("UPDATE dorm_rooms SET occupied = occupied - 1 WHERE id = ${oldRoomId}")
            query.exec("UPDATE dorm_rooms SET occupied = occupied + 1 WHERE id = ${roomId}")
        }
        return result
    }

    public func deleteStudent(id: Int64): Bool {
        // 获取房间ID
        query.exec("SELECT room_id FROM students WHERE id = ${id}")
        if (query.next()) {
            let roomId = Int64(query.valueInt(0))
            query.exec("UPDATE dorm_rooms SET occupied = occupied - 1 WHERE id = ${roomId}")
        }
        // 删除学生记录
        query.exec("DELETE FROM students WHERE id = ${id}")
        return true
    }

    public func getAllStudents(): ArrayList<Student> {
        let list = ArrayList<Student>()
        query.exec("SELECT s.id, s.user_id, u.username, s.student_no, u.display_name, " +
            "s.gender, u.phone, s.class_name, s.enroll_year, " +
            "s.building_id, COALESCE(b.name, '未分配'), s.room_id, COALESCE(r.room_no, '未分配'), " +
            "s.bed_no FROM students s " +
            "JOIN users u ON s.user_id = u.id " +
            "LEFT JOIN dorm_buildings b ON s.building_id = b.id " +
            "LEFT JOIN dorm_rooms r ON s.room_id = r.id ORDER BY s.student_no")
        while (query.next()) {
            let s = Student()
            s.id = Int64(query.valueInt(0))
            s.userId = Int64(query.valueInt(1))
            s.username = query.valueString(2)
            s.studentNo = query.valueString(3)
            s.displayName = query.valueString(4)
            s.gender = query.valueString(5)
            s.phone = query.valueString(6)
            s.className = query.valueString(7)
            s.enrollYear = query.valueInt(8)
            s.buildingId = Int64(query.valueInt(9))
            s.buildingName = query.valueString(10)
            s.roomId = Int64(query.valueInt(11))
            s.roomNo = query.valueString(12)
            s.bedNo = query.valueInt(13)
            list.add(s)
        }
        return list
    }

    public func getStudentsByBuilding(buildingId: Int64): ArrayList<Student> {
        let list = ArrayList<Student>()
        query.exec("SELECT s.id, s.user_id, u.username, s.student_no, u.display_name, " +
            "s.gender, u.phone, s.class_name, s.enroll_year, " +
            "s.building_id, COALESCE(b.name, '未分配'), s.room_id, COALESCE(r.room_no, '未分配'), " +
            "s.bed_no FROM students s " +
            "JOIN users u ON s.user_id = u.id " +
            "LEFT JOIN dorm_buildings b ON s.building_id = b.id " +
            "LEFT JOIN dorm_rooms r ON s.room_id = r.id " +
            "WHERE s.building_id = ${buildingId} ORDER BY s.student_no")
        while (query.next()) {
            let s = Student()
            s.id = Int64(query.valueInt(0))
            s.userId = Int64(query.valueInt(1))
            s.username = query.valueString(2)
            s.studentNo = query.valueString(3)
            s.displayName = query.valueString(4)
            s.gender = query.valueString(5)
            s.phone = query.valueString(6)
            s.className = query.valueString(7)
            s.enrollYear = query.valueInt(8)
            s.buildingId = Int64(query.valueInt(9))
            s.buildingName = query.valueString(10)
            s.roomId = Int64(query.valueInt(11))
            s.roomNo = query.valueString(12)
            s.bedNo = query.valueInt(13)
            list.add(s)
        }
        return list
    }

    public func getStudentByUserId(userId: Int64): ?Student {
        query.exec("SELECT s.id, s.user_id, u.username, s.student_no, u.display_name, " +
            "s.gender, u.phone, s.class_name, s.enroll_year, " +
            "s.building_id, COALESCE(b.name, '未分配'), s.room_id, COALESCE(r.room_no, '未分配'), " +
            "s.bed_no FROM students s " +
            "JOIN users u ON s.user_id = u.id " +
            "LEFT JOIN dorm_buildings b ON s.building_id = b.id " +
            "LEFT JOIN dorm_rooms r ON s.room_id = r.id " +
            "WHERE s.user_id = ${userId}")
        if (query.next()) {
            let s = Student()
            s.id = Int64(query.valueInt(0))
            s.userId = Int64(query.valueInt(1))
            s.username = query.valueString(2)
            s.studentNo = query.valueString(3)
            s.displayName = query.valueString(4)
            s.gender = query.valueString(5)
            s.phone = query.valueString(6)
            s.className = query.valueString(7)
            s.enrollYear = query.valueInt(8)
            s.buildingId = Int64(query.valueInt(9))
            s.buildingName = query.valueString(10)
            s.roomId = Int64(query.valueInt(11))
            s.roomNo = query.valueString(12)
            s.bedNo = query.valueInt(13)
            return Some(s)
        }
        return None
    }

    // ============================================================
    // 考勤管理
    // ============================================================
    public func addAttendance(studentId: Int64, date: String, status: String, checkIn: String, checkOut: String, note: String): Int64 {
        let sql = "INSERT INTO attendance (id, student_id, date, status, check_in_time, check_out_time, note) " +
            "VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM attendance), " +
            "${studentId}, '${date}', '${status}', '${checkIn}', '${checkOut}', '${note}')"
        if (query.exec(sql)) {
            query.exec("SELECT MAX(id) FROM attendance")
            if (query.next()) { return Int64(query.valueInt(0)) }
        }
        return 0
    }

    public func updateAttendance(id: Int64, status: String, checkIn: String, checkOut: String, note: String): Bool {
        return query.exec("UPDATE attendance SET status = '${status}', " +
            "check_in_time = '${checkIn}', check_out_time = '${checkOut}', note = '${note}' WHERE id = ${id}")
    }

    public func deleteAttendance(id: Int64): Bool {
        return query.exec("DELETE FROM attendance WHERE id = ${id}")
    }

    public func getAttendanceByDate(date: String): ArrayList<Attendance> {
        let list = ArrayList<Attendance>()
        query.exec("SELECT a.id, a.student_id, s.student_no, u.display_name, " +
            "a.date, a.status, a.check_in_time, a.check_out_time, a.note " +
            "FROM attendance a " +
            "JOIN students s ON a.student_id = s.id " +
            "JOIN users u ON s.user_id = u.id " +
            "WHERE a.date = '${date}' ORDER BY s.student_no")
        while (query.next()) {
            let a = Attendance()
            a.id = Int64(query.valueInt(0))
            a.studentId = Int64(query.valueInt(1))
            a.studentNo = query.valueString(2)
            a.studentName = query.valueString(3)
            a.date = query.valueString(4)
            a.status = query.valueString(5)
            a.checkInTime = query.valueString(6)
            a.checkOutTime = query.valueString(7)
            a.note = query.valueString(8)
            list.add(a)
        }
        return list
    }

    public func getAttendanceByStudent(studentId: Int64): ArrayList<Attendance> {
        let list = ArrayList<Attendance>()
        query.exec("SELECT a.id, a.student_id, s.student_no, u.display_name, " +
            "a.date, a.status, a.check_in_time, a.check_out_time, a.note " +
            "FROM attendance a " +
            "JOIN students s ON a.student_id = s.id " +
            "JOIN users u ON s.user_id = u.id " +
            "WHERE a.student_id = ${studentId} ORDER BY a.date DESC")
        while (query.next()) {
            let a = Attendance()
            a.id = Int64(query.valueInt(0))
            a.studentId = Int64(query.valueInt(1))
            a.studentNo = query.valueString(2)
            a.studentName = query.valueString(3)
            a.date = query.valueString(4)
            a.status = query.valueString(5)
            a.checkInTime = query.valueString(6)
            a.checkOutTime = query.valueString(7)
            a.note = query.valueString(8)
            list.add(a)
        }
        return list
    }

    public func getAttendanceByBuildingAndDate(buildingId: Int64, date: String): ArrayList<Attendance> {
        let list = ArrayList<Attendance>()
        query.exec("SELECT a.id, a.student_id, s.student_no, u.display_name, " +
            "a.date, a.status, a.check_in_time, a.check_out_time, a.note " +
            "FROM attendance a " +
            "JOIN students s ON a.student_id = s.id " +
            "JOIN users u ON s.user_id = u.id " +
            "WHERE s.building_id = ${buildingId} AND a.date = '${date}' ORDER BY s.room_id, s.bed_no")
        while (query.next()) {
            let a = Attendance()
            a.id = Int64(query.valueInt(0))
            a.studentId = Int64(query.valueInt(1))
            a.studentNo = query.valueString(2)
            a.studentName = query.valueString(3)
            a.date = query.valueString(4)
            a.status = query.valueString(5)
            a.checkInTime = query.valueString(6)
            a.checkOutTime = query.valueString(7)
            a.note = query.valueString(8)
            list.add(a)
        }
        return list
    }

    public func getAttendanceExists(studentId: Int64, date: String): ?Attendance {
        query.exec("SELECT a.id, a.student_id, s.student_no, u.display_name, " +
            "a.date, a.status, a.check_in_time, a.check_out_time, a.note " +
            "FROM attendance a " +
            "JOIN students s ON a.student_id = s.id " +
            "JOIN users u ON s.user_id = u.id " +
            "WHERE a.student_id = ${studentId} AND a.date = '${date}'")
        if (query.next()) {
            let a = Attendance()
            a.id = Int64(query.valueInt(0))
            a.studentId = Int64(query.valueInt(1))
            a.studentNo = query.valueString(2)
            a.studentName = query.valueString(3)
            a.date = query.valueString(4)
            a.status = query.valueString(5)
            a.checkInTime = query.valueString(6)
            a.checkOutTime = query.valueString(7)
            a.note = query.valueString(8)
            return Some(a)
        }
        return None
    }

    // ============================================================
    // 报修管理
    // ============================================================
    public func addRepair(studentId: Int64, roomId: Int64, title: String, description: String, category: String): Int64 {
        let now = getNowString()
        let sql = "INSERT INTO repairs (id, student_id, room_id, title, description, category, status, create_time) " +
            "VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM repairs), " +
            "${studentId}, ${roomId}, '${title}', '${description}', '${category}', 'pending', '${now}')"
        if (query.exec(sql)) {
            query.exec("SELECT MAX(id) FROM repairs")
            if (query.next()) { return Int64(query.valueInt(0)) }
        }
        return 0
    }

    public func updateRepairStatus(id: Int64, status: String, managerId: Int64, note: String): Bool {
        let now = getNowString()
        var sql = "UPDATE repairs SET status = '${status}', manager_id = ${managerId}, note = '${note}'"
        if (status == REPAIR_RESOLVED || status == REPAIR_REJECTED) {
            sql = sql + ", resolve_time = '${now}'"
        }
        sql = sql + " WHERE id = ${id}"
        return query.exec(sql)
    }

    public func deleteRepair(id: Int64): Bool {
        return query.exec("DELETE FROM repairs WHERE id = ${id}")
    }

    public func getAllRepairs(): ArrayList<Repair> {
        let list = ArrayList<Repair>()
        query.exec("SELECT r.id, r.student_id, u.display_name, s.student_no, " +
            "r.room_id, COALESCE(dr.room_no, ''), COALESCE(b.name, ''), " +
            "r.title, r.description, r.category, r.status, r.create_time, " +
            "COALESCE(r.resolve_time, ''), COALESCE(r.manager_id, 0), COALESCE(m.display_name, ''), " +
            "COALESCE(r.note, '') FROM repairs r " +
            "JOIN students s ON r.student_id = s.id " +
            "JOIN users u ON s.user_id = u.id " +
            "LEFT JOIN dorm_rooms dr ON r.room_id = dr.id " +
            "LEFT JOIN dorm_buildings b ON dr.building_id = b.id " +
            "LEFT JOIN users m ON r.manager_id = m.id ORDER BY r.create_time DESC")
        while (query.next()) {
            let r = Repair()
            r.id = Int64(query.valueInt(0))
            r.studentId = Int64(query.valueInt(1))
            r.studentName = query.valueString(2)
            r.studentNo = query.valueString(3)
            r.roomId = Int64(query.valueInt(4))
            r.roomNo = query.valueString(5)
            r.buildingName = query.valueString(6)
            r.title = query.valueString(7)
            r.description = query.valueString(8)
            r.category = query.valueString(9)
            r.status = query.valueString(10)
            r.createTime = query.valueString(11)
            r.resolveTime = query.valueString(12)
            r.managerId = Int64(query.valueInt(13))
            r.managerName = query.valueString(14)
            r.note = query.valueString(15)
            list.add(r)
        }
        return list
    }

    public func getRepairsByStudent(studentId: Int64): ArrayList<Repair> {
        let list = ArrayList<Repair>()
        query.exec("SELECT r.id, r.student_id, u.display_name, s.student_no, " +
            "r.room_id, COALESCE(dr.room_no, ''), COALESCE(b.name, ''), " +
            "r.title, r.description, r.category, r.status, r.create_time, " +
            "COALESCE(r.resolve_time, ''), COALESCE(r.manager_id, 0), COALESCE(m.display_name, ''), " +
            "COALESCE(r.note, '') FROM repairs r " +
            "JOIN students s ON r.student_id = s.id " +
            "JOIN users u ON s.user_id = u.id " +
            "LEFT JOIN dorm_rooms dr ON r.room_id = dr.id " +
            "LEFT JOIN dorm_buildings b ON dr.building_id = b.id " +
            "LEFT JOIN users m ON r.manager_id = m.id " +
            "WHERE r.student_id = ${studentId} ORDER BY r.create_time DESC")
        while (query.next()) {
            let r = Repair()
            r.id = Int64(query.valueInt(0))
            r.studentId = Int64(query.valueInt(1))
            r.studentName = query.valueString(2)
            r.studentNo = query.valueString(3)
            r.roomId = Int64(query.valueInt(4))
            r.roomNo = query.valueString(5)
            r.buildingName = query.valueString(6)
            r.title = query.valueString(7)
            r.description = query.valueString(8)
            r.category = query.valueString(9)
            r.status = query.valueString(10)
            r.createTime = query.valueString(11)
            r.resolveTime = query.valueString(12)
            r.managerId = Int64(query.valueInt(13))
            r.managerName = query.valueString(14)
            r.note = query.valueString(15)
            list.add(r)
        }
        return list
    }

    public func getPendingRepairs(): ArrayList<Repair> {
        let list = ArrayList<Repair>()
        query.exec("SELECT r.id, r.student_id, u.display_name, s.student_no, " +
            "r.room_id, COALESCE(dr.room_no, ''), COALESCE(b.name, ''), " +
            "r.title, r.description, r.category, r.status, r.create_time, " +
            "COALESCE(r.resolve_time, ''), COALESCE(r.manager_id, 0), COALESCE(m.display_name, ''), " +
            "COALESCE(r.note, '') FROM repairs r " +
            "JOIN students s ON r.student_id = s.id " +
            "JOIN users u ON s.user_id = u.id " +
            "LEFT JOIN dorm_rooms dr ON r.room_id = dr.id " +
            "LEFT JOIN dorm_buildings b ON dr.building_id = b.id " +
            "LEFT JOIN users m ON r.manager_id = m.id " +
            "WHERE r.status = 'pending' OR r.status = 'processing' ORDER BY r.create_time DESC")
        while (query.next()) {
            let r = Repair()
            r.id = Int64(query.valueInt(0))
            r.studentId = Int64(query.valueInt(1))
            r.studentName = query.valueString(2)
            r.studentNo = query.valueString(3)
            r.roomId = Int64(query.valueInt(4))
            r.roomNo = query.valueString(5)
            r.buildingName = query.valueString(6)
            r.title = query.valueString(7)
            r.description = query.valueString(8)
            r.category = query.valueString(9)
            r.status = query.valueString(10)
            r.createTime = query.valueString(11)
            r.resolveTime = query.valueString(12)
            r.managerId = Int64(query.valueInt(13))
            r.managerName = query.valueString(14)
            r.note = query.valueString(15)
            list.add(r)
        }
        return list
    }

    // ============================================================
    // 公告管理
    // ============================================================
    public func addAnnouncement(title: String, content: String, authorId: Int64, targetRole: String): Int64 {
        let now = getNowString()
        let sql = "INSERT INTO announcements (id, title, content, create_time, author_id, target_role) " +
            "VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM announcements), " +
            "'${title}', '${content}', '${now}', ${authorId}, '${targetRole}')"
        if (query.exec(sql)) {
            query.exec("SELECT MAX(id) FROM announcements")
            if (query.next()) { return Int64(query.valueInt(0)) }
        }
        return 0
    }

    public func deleteAnnouncement(id: Int64): Bool {
        return query.exec("DELETE FROM announcements WHERE id = ${id}")
    }

    public func getAllAnnouncements(): ArrayList<Announcement> {
        let list = ArrayList<Announcement>()
        query.exec("SELECT a.id, a.title, a.content, a.create_time, a.author_id, " +
            "COALESCE(u.display_name, ''), a.target_role FROM announcements a " +
            "LEFT JOIN users u ON a.author_id = u.id ORDER BY a.create_time DESC")
        while (query.next()) {
            let a = Announcement()
            a.id = Int64(query.valueInt(0))
            a.title = query.valueString(1)
            a.content = query.valueString(2)
            a.createTime = query.valueString(3)
            a.authorId = Int64(query.valueInt(4))
            a.authorName = query.valueString(5)
            a.targetRole = query.valueString(6)
            list.add(a)
        }
        return list
    }

    public func getAnnouncementsByRole(role: String): ArrayList<Announcement> {
        let list = ArrayList<Announcement>()
        query.exec("SELECT a.id, a.title, a.content, a.create_time, a.author_id, " +
            "COALESCE(u.display_name, ''), a.target_role FROM announcements a " +
            "LEFT JOIN users u ON a.author_id = u.id " +
            "WHERE a.target_role = 'all' OR a.target_role = '${role}' ORDER BY a.create_time DESC")
        while (query.next()) {
            let a = Announcement()
            a.id = Int64(query.valueInt(0))
            a.title = query.valueString(1)
            a.content = query.valueString(2)
            a.createTime = query.valueString(3)
            a.authorId = Int64(query.valueInt(4))
            a.authorName = query.valueString(5)
            a.targetRole = query.valueString(6)
            list.add(a)
        }
        return list
    }

    // ============================================================
    // 仪表板统计
    // ============================================================
    public func getDashboardStats(): DashboardStats {
        let stats = DashboardStats()

        query.exec("SELECT COUNT(*) FROM dorm_buildings")
        if (query.next()) { stats.totalBuildings = query.valueInt(0) }

        query.exec("SELECT COUNT(*) FROM dorm_rooms")
        if (query.next()) { stats.totalRooms = query.valueInt(0) }

        query.exec("SELECT COUNT(*) FROM students")
        if (query.next()) { stats.totalStudents = query.valueInt(0) }

        query.exec("SELECT COUNT(*) FROM users WHERE role = 'manager'")
        if (query.next()) { stats.totalManagers = query.valueInt(0) }

        query.exec("SELECT COUNT(*) FROM repairs WHERE status = 'pending' OR status = 'processing'")
        if (query.next()) { stats.pendingRepairs = query.valueInt(0) }

        let today = getTodayString()
        query.exec("SELECT COUNT(*) FROM attendance WHERE date = '${today}' AND status = 'absent'")
        if (query.next()) { stats.todayAbsent = query.valueInt(0) }

        query.exec("SELECT SUM(capacity - occupied) FROM dorm_rooms WHERE occupied < capacity")
        if (query.next()) { stats.availableBeds = query.valueInt(0) }

        return stats
    }

    public func getManagerDashboardStats(managerId: Int64): DashboardStats {
        let stats = DashboardStats()

        query.exec("SELECT COUNT(*) FROM dorm_buildings WHERE manager_id = ${managerId}")
        if (query.next()) { stats.totalBuildings = query.valueInt(0) }

        query.exec("SELECT COUNT(*) FROM dorm_rooms r JOIN dorm_buildings b " +
            "ON r.building_id = b.id WHERE b.manager_id = ${managerId}")
        if (query.next()) { stats.totalRooms = query.valueInt(0) }

        query.exec("SELECT COUNT(*) FROM students s JOIN dorm_buildings b " +
            "ON s.building_id = b.id WHERE b.manager_id = ${managerId}")
        if (query.next()) { stats.totalStudents = query.valueInt(0) }

        query.exec("SELECT COUNT(*) FROM repairs r JOIN dorm_rooms dr ON r.room_id = dr.id " +
            "JOIN dorm_buildings b ON dr.building_id = b.id " +
            "WHERE b.manager_id = ${managerId} AND (r.status = 'pending' OR r.status = 'processing')")
        if (query.next()) { stats.pendingRepairs = query.valueInt(0) }

        let today = getTodayString()
        query.exec("SELECT COUNT(*) FROM attendance a JOIN students s ON a.student_id = s.id " +
            "JOIN dorm_buildings b ON s.building_id = b.id " +
            "WHERE b.manager_id = ${managerId} AND a.date = '${today}' AND a.status = 'absent'")
        if (query.next()) { stats.todayAbsent = query.valueInt(0) }

        return stats
    }

    // ============================================================
    // 清理
    // ============================================================
    public func close(): Unit {
        query.finish()
        query.delete()
    }
}
