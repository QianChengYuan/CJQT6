package datetime_demo

import CJQT6.core.*
import CJQT6.widgets.*
import CJQT6.gui.*

main(): Int32 {
    let app = QApplication()
    let window = QWidget()
    window.setTitle("CJQT6 DateTime Demo")
    window.resize(500, 400)
    
    let mainLayout = QVBoxLayout()
    
    // ========== 日历部件 ==========
    let calendarLabel = QLabel()
    calendarLabel.setText("=== QCalendarWidget ===")
    mainLayout.addWidget(calendarLabel.getPtr())
    
    let calendar = QCalendarWidget()
    calendar.setGridVisible(true)
    calendar.setFirstDayOfWeek(DayOfWeek.Monday)
    let today = QDate.currentDate()
    calendar.setSelectedDate(today)
    mainLayout.addWidget(calendar.getPtr())
    
    let dateLabel = QLabel()
    dateLabel.setText("Selected Date: ${today.toString()}")
    mainLayout.addWidget(dateLabel.getPtr())
    
    // ========== 日期编辑器 ==========
    let dateEditLabel = QLabel()
    dateEditLabel.setText("=== QDateEdit ===")
    mainLayout.addWidget(dateEditLabel.getPtr())
    
    let dateEdit = QDateEdit()
    dateEdit.setDisplayFormat("yyyy-MM-dd")
    dateEdit.setCalendarPopup(true)
    let currentDate = QDate.currentDate()
    dateEdit.setDate(currentDate)
    mainLayout.addWidget(dateEdit.getPtr())
    
    // ========== 时间编辑器 ==========
    let timeEditLabel = QLabel()
    timeEditLabel.setText("=== QTimeEdit ===")
    mainLayout.addWidget(timeEditLabel.getPtr())
    
    let timeEdit = QTimeEdit()
    timeEdit.setDisplayFormat("hh:mm:ss")
    let currentTime = QTime.currentTime()
    timeEdit.setTime(currentTime)
    mainLayout.addWidget(timeEdit.getPtr())
    
    let timeLabel = QLabel()
    timeLabel.setText("Selected Time: ${currentTime.toString()}")
    mainLayout.addWidget(timeLabel.getPtr())
    
    // ========== 日期时间编辑器 ==========
    let datetimeEditLabel = QLabel()
    datetimeEditLabel.setText("=== QDateTimeEdit ===")
    mainLayout.addWidget(datetimeEditLabel.getPtr())
    
    let datetimeEdit = QDateTimeEdit()
    datetimeEdit.setDisplayFormat("yyyy-MM-dd hh:mm:ss")
    datetimeEdit.setCalendarPopup(true)
    let currentDT = QDateTime.currentDateTime()
    datetimeEdit.setDateTime(currentDT)
    mainLayout.addWidget(datetimeEdit.getPtr())
    
    let datetimeLabel = QLabel()
    datetimeLabel.setText("Selected DateTime: ${currentDT.toString()}")
    mainLayout.addWidget(datetimeLabel.getPtr())
    
    // ========== 显示当前日期时间按钮 ==========
    let showBtn = QPushButton()
    showBtn.setText("Show Current DateTime")
    mainLayout.addWidget(showBtn.getPtr())
    
    // Set Layout
    window.setLayout(mainLayout.getPtr())
    window.show()
    
    let result = app.exec()
    
    // 清理
    calendar.delete()
    dateEdit.delete()
    timeEdit.delete()
    datetimeEdit.delete()
    window.delete()
    app.delete()
    
    return result
}