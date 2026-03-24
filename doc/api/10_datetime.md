# CJQT6 日期时间模块

本模块提供日历、日期编辑、时间编辑和日期时间编辑控件。

```cangjie
import CJQT6.widgets.*
```

## QDate - 日期类

```cangjie
// 创建日期
let date = QDate(2026, 3, 11)  // 年、月、日
let today = QDate.currentDate()  // 当前日期

// 获取日期信息
let year = date.year()      // 2026
let month = date.month()    // 3
let day = date.day()        // 11
let str = date.toString()   // "2026-03-11"

// 日期运算
let tomorrow = date.addDays(1)
let nextMonth = date.addMonths(1)
let nextYear = date.addYears(1)
```

**QDate 方法**:
| 方法 | 说明 |
|------|------|
| `init(year, month, day)` | 创建日期 |
| `currentDate()` | 获取当前日期（静态方法） |
| `year(): Int32` | 获取年份 |
| `month(): Int32` | 获取月份 |
| `day(): Int32` | 获取日期 |
| `toString(): String` | 转为字符串 |
| `addDays(days: Int32): QDate` | 添加天数 |
| `addMonths(months: Int32): QDate` | 添加月份 |
| `addYears(years: Int32): QDate` | 添加年份 |
| `isValid(): Bool` | 是否有效 |

---

## QTime - 时间类

```cangjie
// 创建时间
let time = QTime(14, 30, 0)  // 时、分、秒
let now = QTime.currentTime()  // 当前时间

// 获取时间信息
let hour = time.hour()       // 14
let minute = time.minute()   // 30
let second = time.second()   // 0
let str = time.toString()    // "14:30:00"

// 时间运算
let later = time.addSecs(3600)  // 加1小时
```

**QTime 方法**:
| 方法 | 说明 |
|------|------|
| `init(h, m, s)` | 创建时间（时、分、秒） |
| `init(h, m, s, ms)` | 创建时间（时、分、秒、毫秒） |
| `currentTime()` | 获取当前时间（静态方法） |
| `hour(): Int32` | 获取小时 |
| `minute(): Int32` | 获取分钟 |
| `second(): Int32` | 获取秒 |
| `msec(): Int32` | 获取毫秒 |
| `toString(): String` | 转为字符串 |
| `addSecs(secs: Int32): QTime` | 添加秒数 |
| `addMSecs(ms: Int32): QTime` | 添加毫秒 |
| `isValid(): Bool` | 是否有效 |

---

## QDateTime - 日期时间类

```cangjie
// 创建日期时间
let dt = QDateTime(2026, 3, 11, 14, 30, 0)
let now = QDateTime.currentDateTime()  // 当前日期时间

// 获取日期时间信息
let date = dt.date()        // QDate
let time = dt.time()        // QTime
let str = dt.toString()     // "2026-03-11 14:30:00"

// 日期时间运算
let tomorrow = dt.addDays(1)
let later = dt.addSecs(3600)
```

**QDateTime 方法**:
| 方法 | 说明 |
|------|------|
| `init(year, month, day, h, m, s)` | 创建日期时间 |
| `currentDateTime()` | 获取当前日期时间（静态方法） |
| `date(): QDate` | 获取日期部分 |
| `time(): QTime` | 获取时间部分 |
| `toString(): String` | 转为字符串 |
| `addDays(days: Int32): QDateTime` | 添加天数 |
| `addMonths(months: Int32): QDateTime` | 添加月份 |
| `addSecs(secs: Int32): QDateTime` | 添加秒数 |
| `isValid(): Bool` | 是否有效 |

---

## QCalendarWidget - 日历部件

```cangjie
let calendar = QCalendarWidget()
calendar.setGridVisible(true)           // 显示网格
calendar.setFirstDayOfWeek(DayOfWeek.Monday)  // 周一为每周首日

let today = QDate.currentDate()
calendar.setSelectedDate(today)         // 设置选中日期

// 获取选中的日期
let selected = calendar.selectedDate()
```

**QCalendarWidget 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建日历部件 |
| `setGridVisible(visible: Bool)` | 设置网格可见 |
| `setFirstDayOfWeek(day: Int32)` | 设置每周首日 |
| `setSelectedDate(date: QDate)` | 设置选中日期 |
| `selectedDate(): QDate` | 获取选中日期 |
| `setMinimumDate(date: QDate)` | 设置最小日期 |
| `setMaximumDate(date: QDate)` | 设置最大日期 |

**DayOfWeek 常量**:
```cangjie
DayOfWeek.Monday     // 周一
DayOfWeek.Tuesday    // 周二
DayOfWeek.Wednesday  // 周三
DayOfWeek.Thursday   // 周四
DayOfWeek.Friday     // 周五
DayOfWeek.Saturday   // 周六
DayOfWeek.Sunday     // 周日
```

---

## QDateEdit - 日期编辑器

```cangjie
let dateEdit = QDateEdit()
dateEdit.setDisplayFormat("yyyy-MM-dd")  // 显示格式
dateEdit.setCalendarPopup(true)           // 允许弹出日历

let today = QDate.currentDate()
dateEdit.setDate(today)                   // 设置日期

// 获取日期
let date = dateEdit.date()
```

**QDateEdit 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建日期编辑器 |
| `setDate(date: QDate)` | 设置日期 |
| `date(): QDate` | 获取日期 |
| `setDisplayFormat(format: String)` | 设置显示格式 |
| `setCalendarPopup(enable: Bool)` | 设置日历弹出 |
| `setMinimumDate(date: QDate)` | 设置最小日期 |
| `setMaximumDate(date: QDate)` | 设置最大日期 |

---

## QTimeEdit - 时间编辑器

```cangjie
let timeEdit = QTimeEdit()
timeEdit.setDisplayFormat("hh:mm:ss")  // 显示格式

let now = QTime.currentTime()
timeEdit.setTime(now)                   // 设置时间

// 获取时间
let time = timeEdit.time()
```

**QTimeEdit 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建时间编辑器 |
| `setTime(time: QTime)` | 设置时间 |
| `time(): QTime` | 获取时间 |
| `setDisplayFormat(format: String)` | 设置显示格式 |

---

## QDateTimeEdit - 日期时间编辑器

```cangjie
let datetimeEdit = QDateTimeEdit()
datetimeEdit.setDisplayFormat("yyyy-MM-dd hh:mm:ss")  // 显示格式
datetimeEdit.setCalendarPopup(true)                    // 允许弹出日历

let now = QDateTime.currentDateTime()
datetimeEdit.setDateTime(now)  // 设置日期时间

// 获取日期时间
let dt = datetimeEdit.dateTime()
```

**QDateTimeEdit 方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建日期时间编辑器 |
| `setDateTime(dt: QDateTime)` | 设置日期时间 |
| `dateTime(): QDateTime` | 获取日期时间 |
| `setDisplayFormat(format: String)` | 设置显示格式 |
| `setCalendarPopup(enable: Bool)` | 设置日历弹出 |
