package CJQT6.widgets

// ============================================================
// 日期类 QDate
// ============================================================

public class QDate {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe { ptr = qDateCreate(1970, 1, 1) }
    }
    
    public init(year: Int32, month: Int32, day: Int32) {
        unsafe { ptr = qDateCreate(year, month, day) }
    }
    
    public static func currentDate(): QDate {
        let d = QDate()
        unsafe { d.ptr = qDateCurrentDate() }
        return d
    }
    
    public func year(): Int32 { unsafe { qDateYear(ptr) } }
    public func month(): Int32 { unsafe { qDateMonth(ptr) } }
    public func day(): Int32 { unsafe { qDateDay(ptr) } }
    public func dayOfWeek(): Int32 { unsafe { qDateDayOfWeek(ptr) } }
    public func isValid(): Bool { unsafe { qDateIsValid(ptr) != 0 } }
    
    public func setDate(year: Int32, month: Int32, day: Int32): Unit {
        unsafe { qDateSetDate(ptr, year, month, day) }
    }
    
    public func toString(): String {
        unsafe {
            var fmt = LibC.mallocCString("yyyy-MM-dd")
            let cstr = qDateToString(ptr, fmt)
            LibC.free(fmt)
            cstr.toString()
        }
    }
    
    public func toString(format: String): String {
        unsafe {
            var cstr = LibC.mallocCString(format)
            let result = qDateToString(ptr, cstr).toString()
            LibC.free(cstr)
            result
        }
    }
    
    public func getPtr(): Int64 { ptr }
    
    // 内部方法 - 用于从其他类设置指针
    public func setPtr(p: Int64): Unit {
        if (ptr != 0) {
            unsafe { qDateDelete(ptr) }
        }
        ptr = p
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe { qDateDelete(ptr) }
            ptr = 0
        }
    }
}

// ============================================================
// 时间类 QTime
// ============================================================

public class QTime {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe { ptr = qTimeCreate(0, 0, 0, 0) }
    }
    
    public init(hour: Int32, minute: Int32, second: Int32) {
        unsafe { ptr = qTimeCreate(hour, minute, second, 0) }
    }
    
    public init(hour: Int32, minute: Int32, second: Int32, msec: Int32) {
        unsafe { ptr = qTimeCreate(hour, minute, second, msec) }
    }
    
    public static func currentTime(): QTime {
        let t = QTime()
        unsafe { t.ptr = qTimeCurrentTime() }
        return t
    }
    
    public func hour(): Int32 { unsafe { qTimeHour(ptr) } }
    public func minute(): Int32 { unsafe { qTimeMinute(ptr) } }
    public func second(): Int32 { unsafe { qTimeSecond(ptr) } }
    public func msec(): Int32 { unsafe { qTimeMsec(ptr) } }
    public func isValid(): Bool { unsafe { qTimeIsValid(ptr) != 0 } }
    
    public func setHMS(hour: Int32, minute: Int32, second: Int32): QTime {
        unsafe { qTimeSetHMS(ptr, hour, minute, second, 0) }
        this
    }
    
    public func setHMS(hour: Int32, minute: Int32, second: Int32, msec: Int32): QTime {
        unsafe { qTimeSetHMS(ptr, hour, minute, second, msec) }
        this
    }
    
    public func toString(): String {
        unsafe {
            var fmt = LibC.mallocCString("hh:mm:ss")
            let cstr = qTimeToString(ptr, fmt)
            LibC.free(fmt)
            cstr.toString()
        }
    }
    
    public func toString(format: String): String {
        unsafe {
            var cstr = LibC.mallocCString(format)
            let result = qTimeToString(ptr, cstr).toString()
            LibC.free(cstr)
            result
        }
    }
    
    public func getPtr(): Int64 { ptr }
    
    // 内部方法 - 用于从其他类设置指针
    public func setPtr(p: Int64): Unit {
        if (ptr != 0) {
            unsafe { qTimeDelete(ptr) }
        }
        ptr = p
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe { qTimeDelete(ptr) }
            ptr = 0
        }
    }
}

// ============================================================
// 日期时间类 QDateTime
// ============================================================

public class QDateTime {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe { ptr = qDateTimeCreate() }
    }
    
    public init(date: QDate, time: QTime) {
        unsafe { ptr = qDateTimeFromDate(date.getPtr(), time.getPtr()) }
    }
    
    public static func currentDateTime(): QDateTime {
        let dt = QDateTime()
        unsafe { dt.ptr = qDateTimeCurrentDateTime() }
        return dt
    }
    
    public func date(): QDate {
        let d = QDate()
        unsafe { 
            let p = qDateTimeDate(ptr)
            d.setPtr(p)
        }
        return d
    }
    
    public func time(): QTime {
        let t = QTime()
        unsafe {
            let p = qDateTimeTime(ptr)
            t.setPtr(p)
        }
        return t
    }
    
    public func setDate(d: QDate): Unit {
        unsafe { qDateTimeSetDate(ptr, d.getPtr()) }
    }
    
    public func setTime(t: QTime): Unit {
        unsafe { qDateTimeSetTime(ptr, t.getPtr()) }
    }
    
    public func toString(): String {
        unsafe {
            var fmt = LibC.mallocCString("yyyy-MM-dd hh:mm:ss")
            let cstr = qDateTimeToString(ptr, fmt)
            LibC.free(fmt)
            cstr.toString()
        }
    }
    
    public func toString(format: String): String {
        unsafe {
            var cstr = LibC.mallocCString(format)
            let result = qDateTimeToString(ptr, cstr).toString()
            LibC.free(cstr)
            result
        }
    }
    
    public func getPtr(): Int64 { ptr }
    
    // 内部方法，用于设置指针
    public func setPtr(p: Int64): Unit {
        if (ptr != 0) {
            unsafe { qDateTimeDelete(ptr) }
        }
        ptr = p
    }
    
    public func delete() {
        if (ptr != 0) {
            unsafe { qDateTimeDelete(ptr) }
            ptr = 0
        }
    }
}

// ============================================================
// 日历选择模式常量
// ============================================================

public class CalendarSelectionMode {
    public static let NoSelection: Int32 = 0
    public static let SingleSelection: Int32 = 1
}

// ============================================================
// 星期常量
// ============================================================

public class DayOfWeek {
    public static let Monday: Int32 = 1
    public static let Tuesday: Int32 = 2
    public static let Wednesday: Int32 = 3
    public static let Thursday: Int32 = 4
    public static let Friday: Int32 = 5
    public static let Saturday: Int32 = 6
    public static let Sunday: Int32 = 7
}

// ============================================================
// 时间规范常量
// ============================================================

public class TimeSpec {
    public static let LocalTime: Int32 = 0
    public static let UTC: Int32 = 1
    public static let OffsetFromUTC: Int32 = 2
    public static let TimeZone: Int32 = 3
}

// ============================================================
// 日历部件 QCalendarWidget
// ============================================================

public class QCalendarWidget {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe { ptr = qCalendarWidgetCreate() }
    }
    
    public func selectedDate(): QDate {
        let d = QDate()
        unsafe {
            let p = qCalendarWidgetSelectedDate(ptr)
            d.setPtr(p)
        }
        return d
    }
    
    public func setSelectedDate(date: QDate): QCalendarWidget {
        unsafe { qCalendarWidgetSetSelectedDate(ptr, date.getPtr()) }
        this
    }
    
    public func setMinimumDate(date: QDate): QCalendarWidget {
        unsafe { qCalendarWidgetSetMinimumDate(ptr, date.getPtr()) }
        this
    }
    
    public func setMaximumDate(date: QDate): QCalendarWidget {
        unsafe { qCalendarWidgetSetMaximumDate(ptr, date.getPtr()) }
        this
    }
    
    public func minimumDate(): QDate {
        let d = QDate()
        unsafe {
            let p = qCalendarWidgetMinimumDate(ptr)
            d.setPtr(p)
        }
        return d
    }
    
    public func maximumDate(): QDate {
        let d = QDate()
        unsafe {
            let p = qCalendarWidgetMaximumDate(ptr)
            d.setPtr(p)
        }
        return d
    }
    
    public func setGridVisible(visible: Bool): QCalendarWidget {
        unsafe { qCalendarWidgetSetGridVisible(ptr, if (visible) { 1 } else { 0 }) }
        this
    }
    
    public func isGridVisible(): Bool { unsafe { qCalendarWidgetIsGridVisible(ptr) != 0 } }
    
    public func setNavigationBarVisible(visible: Bool): QCalendarWidget {
        unsafe { qCalendarWidgetSetNavigationBarVisible(ptr, if (visible) { 1 } else { 0 }) }
        this
    }
    
    public func setFirstDayOfWeek(day: Int32): QCalendarWidget {
        unsafe { qCalendarWidgetSetFirstDayOfWeek(ptr, day) }
        this
    }
    
    public func firstDayOfWeek(): Int32 { unsafe { qCalendarWidgetFirstDayOfWeek(ptr) } }
    
    public func setSelectionMode(mode: Int32): QCalendarWidget {
        unsafe { qCalendarWidgetSetSelectionMode(ptr, mode) }
        this
    }
    
    public func selectionMode(): Int32 { unsafe { qCalendarWidgetSelectionMode(ptr) } }
    
    public func showToday(): Unit { unsafe { qCalendarWidgetShowToday(ptr) } }
    public func showSelectedDate(): Unit { unsafe { qCalendarWidgetShowSelectedDate(ptr) } }
    
    public func show() { unsafe { qWidgetShow(ptr) } }
    public func hide() { unsafe { qWidgetHide(ptr) } }
    public func resize(width: Int32, height: Int32) { unsafe { qWidgetResize(ptr, width, height) } }
    public func getPtr(): Int64 { ptr }
    
    public func delete() {
        if (ptr != 0) {
            unsafe { qCalendarWidgetDelete(ptr) }
            ptr = 0
        }
    }
}

// ============================================================
// 日期编辑 QDateEdit
// ============================================================

public class QDateEdit {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe { ptr = qDateEditCreate() }
    }
    
    public init(date: QDate) {
        unsafe { ptr = qDateEditCreateWithDate(date.getPtr()) }
    }
    
    public func date(): QDate {
        let d = QDate()
        unsafe {
            let p = qDateEditDate(ptr)
            d.setPtr(p)
        }
        return d
    }
    
    public func setDate(date: QDate): QDateEdit {
        unsafe { qDateEditSetDate(ptr, date.getPtr()) }
        this
    }
    
    public func setMinimumDate(date: QDate): QDateEdit {
        unsafe { qDateEditSetMinimumDate(ptr, date.getPtr()) }
        this
    }
    
    public func setMaximumDate(date: QDate): QDateEdit {
        unsafe { qDateEditSetMaximumDate(ptr, date.getPtr()) }
        this
    }
    
    public func setDisplayFormat(format: String): QDateEdit {
        unsafe {
            var cstr = LibC.mallocCString(format)
            qDateEditSetDisplayFormat(ptr, cstr)
            LibC.free(cstr)
        }
        this
    }
    
    public func displayFormat(): String {
        unsafe { qDateEditDisplayFormat(ptr).toString() }
    }
    
    public func setCalendarPopup(enable: Bool): QDateEdit {
        unsafe { qDateEditSetCalendarPopup(ptr, if (enable) { 1 } else { 0 }) }
        this
    }
    
    public func calendarPopup(): Bool { unsafe { qDateEditCalendarPopup(ptr) != 0 } }
    
    public func show() { unsafe { qWidgetShow(ptr) } }
    public func hide() { unsafe { qWidgetHide(ptr) } }
    public func resize(width: Int32, height: Int32) { unsafe { qWidgetResize(ptr, width, height) } }
    public func getPtr(): Int64 { ptr }
    
    public func delete() {
        if (ptr != 0) {
            unsafe { qDateEditDelete(ptr) }
            ptr = 0
        }
    }
}

// ============================================================
// 时间编辑 QTimeEdit
// ============================================================

public class QTimeEdit {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe { ptr = qTimeEditCreate() }
    }
    
    public init(time: QTime) {
        unsafe { ptr = qTimeEditCreateWithTime(time.getPtr()) }
    }
    
    public func time(): QTime {
        let t = QTime()
        unsafe {
            let p = qTimeEditTime(ptr)
            t.setPtr(p)
        }
        return t
    }
    
    public func setTime(time: QTime): QTimeEdit {
        unsafe { qTimeEditSetTime(ptr, time.getPtr()) }
        this
    }
    
    public func setMinimumTime(time: QTime): QTimeEdit {
        unsafe { qTimeEditSetMinimumTime(ptr, time.getPtr()) }
        this
    }
    
    public func setMaximumTime(time: QTime): QTimeEdit {
        unsafe { qTimeEditSetMaximumTime(ptr, time.getPtr()) }
        this
    }
    
    public func setDisplayFormat(format: String): QTimeEdit {
        unsafe {
            var cstr = LibC.mallocCString(format)
            qTimeEditSetDisplayFormat(ptr, cstr)
            LibC.free(cstr)
        }
        this
    }
    
    public func displayFormat(): String {
        unsafe { qTimeEditDisplayFormat(ptr).toString() }
    }
    
    public func show() { unsafe { qWidgetShow(ptr) } }
    public func hide() { unsafe { qWidgetHide(ptr) } }
    public func resize(width: Int32, height: Int32) { unsafe { qWidgetResize(ptr, width, height) } }
    public func getPtr(): Int64 { ptr }
    
    public func delete() {
        if (ptr != 0) {
            unsafe { qTimeEditDelete(ptr) }
            ptr = 0
        }
    }
}

// ============================================================
// 日期时间编辑 QDateTimeEdit
// ============================================================

public class QDateTimeEdit {
    private var ptr: Int64 = 0
    
    public init() {
        unsafe { ptr = qDateTimeEditCreate() }
    }
    
    public init(dateTime: QDateTime) {
        unsafe { ptr = qDateTimeEditCreateWithDateTime(dateTime.getPtr()) }
    }
    
    public func dateTime(): QDateTime {
        let dt = QDateTime()
        unsafe {
            let p = qDateTimeEditDateTime(ptr)
            dt.setPtr(p)
        }
        return dt
    }
    
    public func setDateTime(dt: QDateTime): QDateTimeEdit {
        unsafe { qDateTimeEditSetDateTime(ptr, dt.getPtr()) }
        this
    }
    
    public func date(): QDate {
        let d = QDate()
        unsafe {
            let p = qDateTimeEditDate(ptr)
            d.setPtr(p)
        }
        return d
    }
    
    public func setDate(date: QDate): QDateTimeEdit {
        unsafe { qDateTimeEditSetDate(ptr, date.getPtr()) }
        this
    }
    
    public func time(): QTime {
        let t = QTime()
        unsafe {
            let p = qDateTimeEditTime(ptr)
            t.setPtr(p)
        }
        return t
    }
    
    public func setTime(time: QTime): QDateTimeEdit {
        unsafe { qDateTimeEditSetTime(ptr, time.getPtr()) }
        this
    }
    
    public func setMinimumDateTime(dt: QDateTime): QDateTimeEdit {
        unsafe { qDateTimeEditSetMinimumDateTime(ptr, dt.getPtr()) }
        this
    }
    
    public func setMaximumDateTime(dt: QDateTime): QDateTimeEdit {
        unsafe { qDateTimeEditSetMaximumDateTime(ptr, dt.getPtr()) }
        this
    }
    
    public func setDisplayFormat(format: String): QDateTimeEdit {
        unsafe {
            var cstr = LibC.mallocCString(format)
            qDateTimeEditSetDisplayFormat(ptr, cstr)
            LibC.free(cstr)
        }
        this
    }
    
    public func displayFormat(): String {
        unsafe { qDateTimeEditDisplayFormat(ptr).toString() }
    }
    
    public func setCalendarPopup(enable: Bool): QDateTimeEdit {
        unsafe { qDateTimeEditSetCalendarPopup(ptr, if (enable) { 1 } else { 0 }) }
        this
    }
    
    public func calendarPopup(): Bool { unsafe { qDateTimeEditCalendarPopup(ptr) != 0 } }
    
    public func setTimeSpec(spec: Int32): QDateTimeEdit {
        unsafe { qDateTimeEditSetTimeSpec(ptr, spec) }
        this
    }
    
    public func timeSpec(): Int32 { unsafe { qDateTimeEditTimeSpec(ptr) } }
    
    public func show() { unsafe { qWidgetShow(ptr) } }
    public func hide() { unsafe { qWidgetHide(ptr) } }
    public func resize(width: Int32, height: Int32) { unsafe { qWidgetResize(ptr, width, height) } }
    public func getPtr(): Int64 { ptr }
    
    public func delete() {
        if (ptr != 0) {
            unsafe { qDateTimeEditDelete(ptr) }
            ptr = 0
        }
    }
}

// ============================================================
// FFI 声明
// ============================================================

// QDate
foreign func qDateCreate(year: Int32, month: Int32, day: Int32): Int64
foreign func qDateDelete(ptr: Int64): Unit
foreign func qDateYear(ptr: Int64): Int32
foreign func qDateMonth(ptr: Int64): Int32
foreign func qDateDay(ptr: Int64): Int32
foreign func qDateDayOfWeek(ptr: Int64): Int32
foreign func qDateIsValid(ptr: Int64): Int32
foreign func qDateCurrentDate(): Int64
foreign func qDateToString(ptr: Int64, format: CString): CString
foreign func qDateSetDate(ptr: Int64, year: Int32, month: Int32, day: Int32): Unit

// QTime
foreign func qTimeCreate(hour: Int32, minute: Int32, second: Int32, msec: Int32): Int64
foreign func qTimeDelete(ptr: Int64): Unit
foreign func qTimeHour(ptr: Int64): Int32
foreign func qTimeMinute(ptr: Int64): Int32
foreign func qTimeSecond(ptr: Int64): Int32
foreign func qTimeMsec(ptr: Int64): Int32
foreign func qTimeIsValid(ptr: Int64): Int32
foreign func qTimeCurrentTime(): Int64
foreign func qTimeToString(ptr: Int64, format: CString): CString
foreign func qTimeSetHMS(ptr: Int64, hour: Int32, minute: Int32, second: Int32, msec: Int32): Unit

// QDateTime
foreign func qDateTimeCreate(): Int64
foreign func qDateTimeFromDate(datePtr: Int64, timePtr: Int64): Int64
foreign func qDateTimeDelete(ptr: Int64): Unit
foreign func qDateTimeDate(ptr: Int64): Int64
foreign func qDateTimeTime(ptr: Int64): Int64
foreign func qDateTimeCurrentDateTime(): Int64
foreign func qDateTimeToString(ptr: Int64, format: CString): CString
foreign func qDateTimeSetDate(ptr: Int64, datePtr: Int64): Unit
foreign func qDateTimeSetTime(ptr: Int64, timePtr: Int64): Unit

// QCalendarWidget
foreign func qCalendarWidgetCreate(): Int64
foreign func qCalendarWidgetDelete(ptr: Int64): Unit
foreign func qCalendarWidgetSelectedDate(ptr: Int64): Int64
foreign func qCalendarWidgetSetSelectedDate(ptr: Int64, datePtr: Int64): Unit
foreign func qCalendarWidgetSetMinimumDate(ptr: Int64, datePtr: Int64): Unit
foreign func qCalendarWidgetSetMaximumDate(ptr: Int64, datePtr: Int64): Unit
foreign func qCalendarWidgetMinimumDate(ptr: Int64): Int64
foreign func qCalendarWidgetMaximumDate(ptr: Int64): Int64
foreign func qCalendarWidgetSetGridVisible(ptr: Int64, visible: Int32): Unit
foreign func qCalendarWidgetIsGridVisible(ptr: Int64): Int32
foreign func qCalendarWidgetSetNavigationBarVisible(ptr: Int64, visible: Int32): Unit
foreign func qCalendarWidgetSetFirstDayOfWeek(ptr: Int64, day: Int32): Unit
foreign func qCalendarWidgetFirstDayOfWeek(ptr: Int64): Int32
foreign func qCalendarWidgetSetSelectionMode(ptr: Int64, mode: Int32): Unit
foreign func qCalendarWidgetSelectionMode(ptr: Int64): Int32
foreign func qCalendarWidgetShowToday(ptr: Int64): Unit
foreign func qCalendarWidgetShowSelectedDate(ptr: Int64): Unit

// QDateEdit
foreign func qDateEditCreate(): Int64
foreign func qDateEditCreateWithDate(datePtr: Int64): Int64
foreign func qDateEditDelete(ptr: Int64): Unit
foreign func qDateEditDate(ptr: Int64): Int64
foreign func qDateEditSetDate(ptr: Int64, datePtr: Int64): Unit
foreign func qDateEditSetMinimumDate(ptr: Int64, datePtr: Int64): Unit
foreign func qDateEditSetMaximumDate(ptr: Int64, datePtr: Int64): Unit
foreign func qDateEditSetDisplayFormat(ptr: Int64, format: CString): Unit
foreign func qDateEditDisplayFormat(ptr: Int64): CString
foreign func qDateEditSetCalendarPopup(ptr: Int64, enable: Int32): Unit
foreign func qDateEditCalendarPopup(ptr: Int64): Int32

// QTimeEdit
foreign func qTimeEditCreate(): Int64
foreign func qTimeEditCreateWithTime(timePtr: Int64): Int64
foreign func qTimeEditDelete(ptr: Int64): Unit
foreign func qTimeEditTime(ptr: Int64): Int64
foreign func qTimeEditSetTime(ptr: Int64, timePtr: Int64): Unit
foreign func qTimeEditSetMinimumTime(ptr: Int64, timePtr: Int64): Unit
foreign func qTimeEditSetMaximumTime(ptr: Int64, timePtr: Int64): Unit
foreign func qTimeEditSetDisplayFormat(ptr: Int64, format: CString): Unit
foreign func qTimeEditDisplayFormat(ptr: Int64): CString

// QDateTimeEdit
foreign func qDateTimeEditCreate(): Int64
foreign func qDateTimeEditCreateWithDateTime(dtPtr: Int64): Int64
foreign func qDateTimeEditDelete(ptr: Int64): Unit
foreign func qDateTimeEditDateTime(ptr: Int64): Int64
foreign func qDateTimeEditSetDateTime(ptr: Int64, dtPtr: Int64): Unit
foreign func qDateTimeEditDate(ptr: Int64): Int64
foreign func qDateTimeEditSetDate(ptr: Int64, datePtr: Int64): Unit
foreign func qDateTimeEditTime(ptr: Int64): Int64
foreign func qDateTimeEditSetTime(ptr: Int64, timePtr: Int64): Unit
foreign func qDateTimeEditSetMinimumDateTime(ptr: Int64, dtPtr: Int64): Unit
foreign func qDateTimeEditSetMaximumDateTime(ptr: Int64, dtPtr: Int64): Unit
foreign func qDateTimeEditSetDisplayFormat(ptr: Int64, format: CString): Unit
foreign func qDateTimeEditDisplayFormat(ptr: Int64): CString
foreign func qDateTimeEditSetCalendarPopup(ptr: Int64, enable: Int32): Unit
foreign func qDateTimeEditCalendarPopup(ptr: Int64): Int32
foreign func qDateTimeEditSetTimeSpec(ptr: Int64, spec: Int32): Unit
foreign func qDateTimeEditTimeSpec(ptr: Int64): Int32
