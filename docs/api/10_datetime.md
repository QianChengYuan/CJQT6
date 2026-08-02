# CJQT6 日期时间模块

本模块提供日期、时间、日期时间以及对应的编辑控件封装，当前实现位于 widgets 包下。

```cangjie
import cjqt6.widgets.*
```

## QDate - 日期类

```cangjie
let date = QDate(2026, 3, 11)
println(date.year())
println(date.month())
println(date.day())
println(date.toString())
```

| 方法 | 说明 |
|------|------|
| `init()` | 创建日期（默认 1970-01-01） |
| `init(year: Int32, month: Int32, day: Int32)` | 创建日期 |
| `currentDate(): QDate` | 获取当前日期 |
| `year(): Int32` | 获取年份 |
| `month(): Int32` | 获取月份 |
| `day(): Int32` | 获取日期 |
| `dayOfWeek(): Int32` | 获取星期几 |
| `setDate(year, month, day)` | 修改日期 |
| `toString(): String` | 转字符串，默认格式 `yyyy-MM-dd` |
| `toString(format: String): String` | 按格式转字符串 |
| `isValid(): Bool` | 是否有效 |
| `getPtr(): Int64` | 获取原生指针 |
| `delete()` | 释放资源 |

## QTime - 时间类

```cangjie
let time = QTime(14, 30, 0)
println(time.hour())
println(time.minute())
println(time.second())
println(time.toString())
```

| 方法 | 说明 |
|------|------|
| `init()` | 创建时间（默认 00:00:00.000） |
| `init(hour: Int32, minute: Int32, second: Int32)` | 创建时间 |
| `init(hour, minute, second, msec)` | 创建带毫秒的时间 |
| `currentTime(): QTime` | 获取当前时间 |
| `hour(): Int32` | 获取小时 |
| `minute(): Int32` | 获取分钟 |
| `second(): Int32` | 获取秒 |
| `msec(): Int32` | 获取毫秒 |
| `setHMS(hour, minute, second)` | 设置时间 |
| `setHMS(hour, minute, second, msec)` | 设置时间（含毫秒） |
| `toString(): String` | 转字符串，默认格式 `hh:mm:ss` |
| `toString(format: String): String` | 按格式转字符串 |
| `isValid(): Bool` | 是否有效 |
| `getPtr(): Int64` | 获取原生指针 |
| `delete()` | 释放资源 |

## QDateTime - 日期时间类

```cangjie
let dt = QDateTime(QDate(2026, 3, 11), QTime(14, 30, 0))
println(dt.toString())
```

| 方法 | 说明 |
|------|------|
| `init()` | 创建空日期时间 |
| `init(date: QDate, time: QTime)` | 根据日期和时间创建 |
| `currentDateTime(): QDateTime` | 获取当前日期时间 |
| `date(): QDate` | 获取日期部分 |
| `time(): QTime` | 获取时间部分 |
| `setDate(d: QDate)` | 设置日期 |
| `setTime(t: QTime)` | 设置时间 |
| `toString(): String` | 转字符串，默认格式 `yyyy-MM-dd hh:mm:ss` |
| `toString(format: String): String` | 按格式转字符串 |
| `getPtr(): Int64` | 获取原生指针 |
| `delete()` | 释放资源 |

## QCalendarWidget - 日历部件

```cangjie
let calendar = QCalendarWidget()
calendar.setGridVisible(true)
calendar.setFirstDayOfWeek(DayOfWeek.Monday)
calendar.setSelectedDate(QDate.currentDate())
```

| 方法 | 说明 |
|------|------|
| `init()` | 创建日历部件 |
| `selectedDate(): QDate` | 获取当前选中日期 |
| `setSelectedDate(date: QDate)` | 设置选中日期 |
| `setMinimumDate(date: QDate)` | 设置最小日期 |
| `setMaximumDate(date: QDate)` | 设置最大日期 |
| `minimumDate(): QDate` | 获取最小日期 |
| `maximumDate(): QDate` | 获取最大日期 |
| `setGridVisible(visible: Bool)` | 设置网格显示 |
| `isGridVisible(): Bool` | 是否显示网格 |
| `setNavigationBarVisible(visible: Bool)` | 设置导航栏可见性 |
| `setFirstDayOfWeek(day: Int32)` | 设置每周首日 |
| `firstDayOfWeek(): Int32` | 获取每周首日 |
| `setSelectionMode(mode: Int32)` | 设置选择模式（见 CalendarSelectionMode） |
| `selectionMode(): Int32` | 获取选择模式 |
| `showToday()` / `showSelectedDate()` | 显示当前日期或选中日期 |
| `show()` / `hide()` | 显示或隐藏控件 |
| `resize(width, height)` | 调整大小 |
| `getPtr(): Int64` | 获取原生指针 |
| `delete()` | 释放资源 |

### 常量

```cangjie
DayOfWeek.Monday
DayOfWeek.Tuesday
DayOfWeek.Wednesday
DayOfWeek.Thursday
DayOfWeek.Friday
DayOfWeek.Saturday
DayOfWeek.Sunday

TimeSpec.LocalTime
TimeSpec.UTC
TimeSpec.OffsetFromUTC
TimeSpec.TimeZone

CalendarSelectionMode.NoSelection
CalendarSelectionMode.SingleSelection
```

**DayOfWeek**（星期常量，1~7）:
| 常量 | 值 | 说明 |
|------|------|------|
| `Monday` | 1 | 星期一 |
| `Tuesday` | 2 | 星期二 |
| `Wednesday` | 3 | 星期三 |
| `Thursday` | 4 | 星期四 |
| `Friday` | 5 | 星期五 |
| `Saturday` | 6 | 星期六 |
| `Sunday` | 7 | 星期日 |

**TimeSpec**（时间规范）:
| 常量 | 值 | 说明 |
|------|------|------|
| `LocalTime` | 0 | 本地时间 |
| `UTC` | 1 | 协调世界时 |
| `OffsetFromUTC` | 2 | UTC 偏移 |
| `TimeZone` | 3 | 时区 |

**CalendarSelectionMode**（日历选择模式）:
| 常量 | 值 | 说明 |
|------|------|------|
| `NoSelection` | 0 | 禁止选择 |
| `SingleSelection` | 1 | 单选 |

## QDateEdit - 日期编辑器

```cangjie
let edit = QDateEdit(QDate.currentDate())
edit.setDisplayFormat("yyyy-MM-dd")
edit.setCalendarPopup(true)
```

| 方法 | 说明 |
|------|------|
| `init()` / `init(date: QDate)` | 创建日期编辑器 |
| `date(): QDate` | 获取当前日期 |
| `setDate(date: QDate)` | 设置日期 |
| `setMinimumDate(date: QDate)` | 设置最小日期 |
| `setMaximumDate(date: QDate)` | 设置最大日期 |
| `setDisplayFormat(format: String)` | 设置显示格式 |
| `displayFormat(): String` | 获取显示格式 |
| `setCalendarPopup(enable: Bool)` | 开启/关闭日历弹出 |
| `calendarPopup(): Bool` | 是否启用日历弹出 |
| `setDateFromParts(year, month, day)` | 按部件设置日期 |
| `setOnDateChanged(callback)` | 日期变化回调 |
| `setOnDateTimeChanged(callback)` | 日期时间变化回调 |
| `show()` / `hide()` | 显示或隐藏控件 |
| `resize(width, height)` | 调整大小 |
| `getPtr(): Int64` | 获取原生指针 |
| `delete()` | 释放资源 |

## QTimeEdit - 时间编辑器

```cangjie
let edit = QTimeEdit(QTime(14, 30, 0))
edit.setDisplayFormat("hh:mm:ss")
```

| 方法 | 说明 |
|------|------|
| `init()` / `init(time: QTime)` | 创建时间编辑器 |
| `time(): QTime` | 获取当前时间 |
| `setTime(time: QTime)` | 设置时间 |
| `setMinimumTime(time: QTime)` | 设置最小时间 |
| `setMaximumTime(time: QTime)` | 设置最大时间 |
| `setDisplayFormat(format: String)` | 设置显示格式 |
| `displayFormat(): String` | 获取显示格式 |
| `setTimeFromParts(hour, minute, second)` | 按部件设置时间 |
| `setOnTimeChanged(callback)` | 时间变化回调 |
| `setOnDateTimeChanged(callback)` | 日期时间变化回调 |
| `show()` / `hide()` | 显示或隐藏控件 |
| `resize(width, height)` | 调整大小 |
| `getPtr(): Int64` | 获取原生指针 |
| `delete()` | 释放资源 |

## QDateTimeEdit - 日期时间编辑器

```cangjie
let edit = QDateTimeEdit(QDateTime.currentDateTime())
edit.setDisplayFormat("yyyy-MM-dd hh:mm:ss")
edit.setCalendarPopup(true)
```

| 方法 | 说明 |
|------|------|
| `init()` / `init(dateTime: QDateTime)` | 创建日期时间编辑器 |
| `dateTime(): QDateTime` | 获取当前日期时间 |
| `setDateTime(dt: QDateTime)` | 设置日期时间 |
| `date(): QDate` | 获取日期 |
| `setDate(date: QDate)` | 设置日期 |
| `time(): QTime` | 获取时间 |
| `setTime(time: QTime)` | 设置时间 |
| `setMinimumDateTime(dt: QDateTime)` | 设置最小日期时间 |
| `setMaximumDateTime(dt: QDateTime)` | 设置最大日期时间 |
| `setDisplayFormat(format: String)` | 设置显示格式 |
| `displayFormat(): String` | 获取显示格式 |
| `setCalendarPopup(enable: Bool)` | 开启/关闭日历弹出 |
| `calendarPopup(): Bool` | 获取日历弹出状态 |
| `setTimeSpec(spec: Int32)` | 设置时间规范 |
| `timeSpec(): Int32` | 获取时间规范 |
| `setDateTimeFromParts(year, month, day, hour, minute, second)` | 按部件设置日期时间 |
| `setOnDateChanged(callback)` | 日期变化回调 |
| `setOnTimeChanged(callback)` | 时间变化回调 |
| `setOnDateTimeChanged(callback)` | 日期时间变化回调 |
| `show()` / `hide()` | 显示或隐藏控件 |
| `resize(width, height)` | 调整大小 |
| `getPtr(): Int64` | 获取原生指针 |
| `delete()` | 释放资源 |
