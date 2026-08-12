/**
 * @file bridge_datetime.cpp
 * @brief 日期时间控件桥接函数 - QCalendarWidget, QDateEdit, QTimeEdit, QDateTimeEdit
 */

#include <QCalendarWidget>
#include <QDateEdit>
#include <QTimeEdit>
#include <QDateTimeEdit>
#include <QDate>
#include <QTime>
#include <QDateTime>
#include <cstring>
#include "bridge_string_utils.h"

// 辅助函数：安全复制字符串
static const char* safeCopyString(const QString& str) {
    return cjqt6::dupUtf8(str);
}

// 由 bridge_ext_wmisc.cpp 导出：清理日期时间控件信号回调 map（QDateEdit/QTimeEdit/
// QDateTimeEdit），避免 delete 后地址复用导致 connect 去重误跳。
extern "C" void qWmiscSignalCleanup(int64_t ptr);

extern "C" {

// ============================================================
// QDate 辅助函数
// ============================================================

int64_t qDateCreate(int32_t year, int32_t month, int32_t day) {
    QDate* date = new QDate(year, month, day);
    return reinterpret_cast<int64_t>(date);
}

void qDateDelete(int64_t ptr) {
    QDate* date = reinterpret_cast<QDate*>(ptr);
    if (date) {
        delete date;
    }
}

int32_t qDateYear(int64_t ptr) {
    QDate* date = reinterpret_cast<QDate*>(ptr);
    return date ? date->year() : 0;
}

int32_t qDateMonth(int64_t ptr) {
    QDate* date = reinterpret_cast<QDate*>(ptr);
    return date ? date->month() : 0;
}

int32_t qDateDay(int64_t ptr) {
    QDate* date = reinterpret_cast<QDate*>(ptr);
    return date ? date->day() : 0;
}

int32_t qDateDayOfWeek(int64_t ptr) {
    QDate* date = reinterpret_cast<QDate*>(ptr);
    return date ? date->dayOfWeek() : 0;
}

int32_t qDateIsValid(int64_t ptr) {
    QDate* date = reinterpret_cast<QDate*>(ptr);
    return date && date->isValid() ? 1 : 0;
}

int64_t qDateCurrentDate() {
    QDate* date = new QDate(QDate::currentDate());
    return reinterpret_cast<int64_t>(date);
}

const char* qDateToString(int64_t ptr, const char* format) {
    QDate* date = reinterpret_cast<QDate*>(ptr);
    if (date) {
        QString str = date->toString(QString::fromUtf8(format));
        return safeCopyString(str);
    }
    return cjqt6::emptyString();
}

void qDateSetDate(int64_t ptr, int32_t year, int32_t month, int32_t day) {
    QDate* date = reinterpret_cast<QDate*>(ptr);
    if (date) {
        date->setDate(year, month, day);
    }
}

// ============================================================
// QTime 辅助函数
// ============================================================

int64_t qTimeCreate(int32_t hour, int32_t minute, int32_t second, int32_t msec) {
    QTime* time = new QTime(hour, minute, second, msec);
    return reinterpret_cast<int64_t>(time);
}

void qTimeDelete(int64_t ptr) {
    QTime* time = reinterpret_cast<QTime*>(ptr);
    if (time) {
        delete time;
    }
}

int32_t qTimeHour(int64_t ptr) {
    QTime* time = reinterpret_cast<QTime*>(ptr);
    return time ? time->hour() : 0;
}

int32_t qTimeMinute(int64_t ptr) {
    QTime* time = reinterpret_cast<QTime*>(ptr);
    return time ? time->minute() : 0;
}

int32_t qTimeSecond(int64_t ptr) {
    QTime* time = reinterpret_cast<QTime*>(ptr);
    return time ? time->second() : 0;
}

int32_t qTimeMsec(int64_t ptr) {
    QTime* time = reinterpret_cast<QTime*>(ptr);
    return time ? time->msec() : 0;
}

int32_t qTimeIsValid(int64_t ptr) {
    QTime* time = reinterpret_cast<QTime*>(ptr);
    return time && time->isValid() ? 1 : 0;
}

int64_t qTimeCurrentTime() {
    QTime* time = new QTime(QTime::currentTime());
    return reinterpret_cast<int64_t>(time);
}

const char* qTimeToString(int64_t ptr, const char* format) {
    QTime* time = reinterpret_cast<QTime*>(ptr);
    if (time) {
        QString str = time->toString(QString::fromUtf8(format));
        return safeCopyString(str);
    }
    return cjqt6::emptyString();
}

void qTimeSetHMS(int64_t ptr, int32_t hour, int32_t minute, int32_t second, int32_t msec) {
    QTime* time = reinterpret_cast<QTime*>(ptr);
    if (time) {
        time->setHMS(hour, minute, second, msec);
    }
}

// ============================================================
// QDateTime 辅助函数
// ============================================================

int64_t qDateTimeCreate() {
    QDateTime* dt = new QDateTime();
    return reinterpret_cast<int64_t>(dt);
}

int64_t qDateTimeFromDate(int64_t datePtr, int64_t timePtr) {
    QDate* date = reinterpret_cast<QDate*>(datePtr);
    QTime* time = reinterpret_cast<QTime*>(timePtr);
    QDateTime* dt = new QDateTime(*date, *time);
    return reinterpret_cast<int64_t>(dt);
}

void qDateTimeDelete(int64_t ptr) {
    QDateTime* dt = reinterpret_cast<QDateTime*>(ptr);
    if (dt) {
        delete dt;
    }
}

int64_t qDateTimeDate(int64_t ptr) {
    QDateTime* dt = reinterpret_cast<QDateTime*>(ptr);
    if (dt) {
        QDate* date = new QDate(dt->date());
        return reinterpret_cast<int64_t>(date);
    }
    return 0;
}

int64_t qDateTimeTime(int64_t ptr) {
    QDateTime* dt = reinterpret_cast<QDateTime*>(ptr);
    if (dt) {
        QTime* time = new QTime(dt->time());
        return reinterpret_cast<int64_t>(time);
    }
    return 0;
}

int64_t qDateTimeCurrentDateTime() {
    QDateTime* dt = new QDateTime(QDateTime::currentDateTime());
    return reinterpret_cast<int64_t>(dt);
}

const char* qDateTimeToString(int64_t ptr, const char* format) {
    QDateTime* dt = reinterpret_cast<QDateTime*>(ptr);
    if (dt) {
        QString str = dt->toString(QString::fromUtf8(format));
        return safeCopyString(str);
    }
    return cjqt6::emptyString();
}

void qDateTimeSetDate(int64_t ptr, int64_t datePtr) {
    QDateTime* dt = reinterpret_cast<QDateTime*>(ptr);
    QDate* date = reinterpret_cast<QDate*>(datePtr);
    if (dt && date) {
        dt->setDate(*date);
    }
}

void qDateTimeSetTime(int64_t ptr, int64_t timePtr) {
    QDateTime* dt = reinterpret_cast<QDateTime*>(ptr);
    QTime* time = reinterpret_cast<QTime*>(timePtr);
    if (dt && time) {
        dt->setTime(*time);
    }
}

// ============================================================
// QCalendarWidget 桥接函数
// ============================================================

int64_t qCalendarWidgetCreate() {
    QCalendarWidget* calendar = new QCalendarWidget();
    return reinterpret_cast<int64_t>(calendar);
}

void qCalendarWidgetDelete(int64_t ptr) {
    QCalendarWidget* calendar = reinterpret_cast<QCalendarWidget*>(ptr);
    if (calendar) {
        delete calendar;
    }
}

int64_t qCalendarWidgetSelectedDate(int64_t ptr) {
    QCalendarWidget* calendar = reinterpret_cast<QCalendarWidget*>(ptr);
    if (calendar) {
        QDate* date = new QDate(calendar->selectedDate());
        return reinterpret_cast<int64_t>(date);
    }
    return 0;
}

void qCalendarWidgetSetSelectedDate(int64_t ptr, int64_t datePtr) {
    QCalendarWidget* calendar = reinterpret_cast<QCalendarWidget*>(ptr);
    QDate* date = reinterpret_cast<QDate*>(datePtr);
    if (calendar && date) {
        calendar->setSelectedDate(*date);
    }
}

void qCalendarWidgetSetMinimumDate(int64_t ptr, int64_t datePtr) {
    QCalendarWidget* calendar = reinterpret_cast<QCalendarWidget*>(ptr);
    QDate* date = reinterpret_cast<QDate*>(datePtr);
    if (calendar && date) {
        calendar->setMinimumDate(*date);
    }
}

void qCalendarWidgetSetMaximumDate(int64_t ptr, int64_t datePtr) {
    QCalendarWidget* calendar = reinterpret_cast<QCalendarWidget*>(ptr);
    QDate* date = reinterpret_cast<QDate*>(datePtr);
    if (calendar && date) {
        calendar->setMaximumDate(*date);
    }
}

int64_t qCalendarWidgetMinimumDate(int64_t ptr) {
    QCalendarWidget* calendar = reinterpret_cast<QCalendarWidget*>(ptr);
    if (calendar) {
        QDate* date = new QDate(calendar->minimumDate());
        return reinterpret_cast<int64_t>(date);
    }
    return 0;
}

int64_t qCalendarWidgetMaximumDate(int64_t ptr) {
    QCalendarWidget* calendar = reinterpret_cast<QCalendarWidget*>(ptr);
    if (calendar) {
        QDate* date = new QDate(calendar->maximumDate());
        return reinterpret_cast<int64_t>(date);
    }
    return 0;
}

void qCalendarWidgetSetGridVisible(int64_t ptr, int32_t visible) {
    QCalendarWidget* calendar = reinterpret_cast<QCalendarWidget*>(ptr);
    if (calendar) {
        calendar->setGridVisible(visible != 0);
    }
}

int32_t qCalendarWidgetIsGridVisible(int64_t ptr) {
    QCalendarWidget* calendar = reinterpret_cast<QCalendarWidget*>(ptr);
    return calendar && calendar->isGridVisible() ? 1 : 0;
}

void qCalendarWidgetSetNavigationBarVisible(int64_t ptr, int32_t visible) {
    QCalendarWidget* calendar = reinterpret_cast<QCalendarWidget*>(ptr);
    if (calendar) {
        calendar->setNavigationBarVisible(visible != 0);
    }
}

void qCalendarWidgetSetFirstDayOfWeek(int64_t ptr, int32_t day) {
    QCalendarWidget* calendar = reinterpret_cast<QCalendarWidget*>(ptr);
    if (calendar) {
        calendar->setFirstDayOfWeek(static_cast<Qt::DayOfWeek>(day));
    }
}

int32_t qCalendarWidgetFirstDayOfWeek(int64_t ptr) {
    QCalendarWidget* calendar = reinterpret_cast<QCalendarWidget*>(ptr);
    return calendar ? static_cast<int32_t>(calendar->firstDayOfWeek()) : 1;
}

void qCalendarWidgetSetSelectionMode(int64_t ptr, int32_t mode) {
    QCalendarWidget* calendar = reinterpret_cast<QCalendarWidget*>(ptr);
    if (calendar) {
        calendar->setSelectionMode(static_cast<QCalendarWidget::SelectionMode>(mode));
    }
}

int32_t qCalendarWidgetSelectionMode(int64_t ptr) {
    QCalendarWidget* calendar = reinterpret_cast<QCalendarWidget*>(ptr);
    return calendar ? static_cast<int32_t>(calendar->selectionMode()) : 0;
}

void qCalendarWidgetShowToday(int64_t ptr) {
    QCalendarWidget* calendar = reinterpret_cast<QCalendarWidget*>(ptr);
    if (calendar) {
        calendar->showToday();
    }
}

void qCalendarWidgetShowSelectedDate(int64_t ptr) {
    QCalendarWidget* calendar = reinterpret_cast<QCalendarWidget*>(ptr);
    if (calendar) {
        calendar->showSelectedDate();
    }
}

// ============================================================
// QDateEdit 桥接函数
// ============================================================

int64_t qDateEditCreate() {
    QDateEdit* edit = new QDateEdit();
    return reinterpret_cast<int64_t>(edit);
}

int64_t qDateEditCreateWithDate(int64_t datePtr) {
    QDate* date = reinterpret_cast<QDate*>(datePtr);
    QDateEdit* edit = new QDateEdit(*date);
    return reinterpret_cast<int64_t>(edit);
}

void qDateEditDelete(int64_t ptr) {
    QDateEdit* edit = reinterpret_cast<QDateEdit*>(ptr);
    if (edit) {
        qWmiscSignalCleanup(ptr);
        delete edit;
    }
}

int64_t qDateEditDate(int64_t ptr) {
    QDateEdit* edit = reinterpret_cast<QDateEdit*>(ptr);
    if (edit) {
        QDate* date = new QDate(edit->date());
        return reinterpret_cast<int64_t>(date);
    }
    return 0;
}

void qDateEditSetDate(int64_t ptr, int64_t datePtr) {
    QDateEdit* edit = reinterpret_cast<QDateEdit*>(ptr);
    QDate* date = reinterpret_cast<QDate*>(datePtr);
    if (edit && date) {
        edit->setDate(*date);
    }
}

void qDateEditSetMinimumDate(int64_t ptr, int64_t datePtr) {
    QDateEdit* edit = reinterpret_cast<QDateEdit*>(ptr);
    QDate* date = reinterpret_cast<QDate*>(datePtr);
    if (edit && date) {
        edit->setMinimumDate(*date);
    }
}

void qDateEditSetMaximumDate(int64_t ptr, int64_t datePtr) {
    QDateEdit* edit = reinterpret_cast<QDateEdit*>(ptr);
    QDate* date = reinterpret_cast<QDate*>(datePtr);
    if (edit && date) {
        edit->setMaximumDate(*date);
    }
}

void qDateEditSetDisplayFormat(int64_t ptr, const char* format) {
    QDateEdit* edit = reinterpret_cast<QDateEdit*>(ptr);
    if (edit) {
        edit->setDisplayFormat(QString::fromUtf8(format));
    }
}

const char* qDateEditDisplayFormat(int64_t ptr) {
    QDateEdit* edit = reinterpret_cast<QDateEdit*>(ptr);
    if (edit) {
        return safeCopyString(edit->displayFormat());
    }
    return cjqt6::emptyString();
}

void qDateEditSetCalendarPopup(int64_t ptr, int32_t enable) {
    QDateEdit* edit = reinterpret_cast<QDateEdit*>(ptr);
    if (edit) {
        edit->setCalendarPopup(enable != 0);
    }
}

int32_t qDateEditCalendarPopup(int64_t ptr) {
    QDateEdit* edit = reinterpret_cast<QDateEdit*>(ptr);
    return edit && edit->calendarPopup() ? 1 : 0;
}

// ============================================================
// QTimeEdit 桥接函数
// ============================================================

int64_t qTimeEditCreate() {
    QTimeEdit* edit = new QTimeEdit();
    return reinterpret_cast<int64_t>(edit);
}

int64_t qTimeEditCreateWithTime(int64_t timePtr) {
    QTime* time = reinterpret_cast<QTime*>(timePtr);
    QTimeEdit* edit = new QTimeEdit(*time);
    return reinterpret_cast<int64_t>(edit);
}

void qTimeEditDelete(int64_t ptr) {
    QTimeEdit* edit = reinterpret_cast<QTimeEdit*>(ptr);
    if (edit) {
        qWmiscSignalCleanup(ptr);
        delete edit;
    }
}

int64_t qTimeEditTime(int64_t ptr) {
    QTimeEdit* edit = reinterpret_cast<QTimeEdit*>(ptr);
    if (edit) {
        QTime* time = new QTime(edit->time());
        return reinterpret_cast<int64_t>(time);
    }
    return 0;
}

void qTimeEditSetTime(int64_t ptr, int64_t timePtr) {
    QTimeEdit* edit = reinterpret_cast<QTimeEdit*>(ptr);
    QTime* time = reinterpret_cast<QTime*>(timePtr);
    if (edit && time) {
        edit->setTime(*time);
    }
}

void qTimeEditSetMinimumTime(int64_t ptr, int64_t timePtr) {
    QTimeEdit* edit = reinterpret_cast<QTimeEdit*>(ptr);
    QTime* time = reinterpret_cast<QTime*>(timePtr);
    if (edit && time) {
        edit->setMinimumTime(*time);
    }
}

void qTimeEditSetMaximumTime(int64_t ptr, int64_t timePtr) {
    QTimeEdit* edit = reinterpret_cast<QTimeEdit*>(ptr);
    QTime* time = reinterpret_cast<QTime*>(timePtr);
    if (edit && time) {
        edit->setMaximumTime(*time);
    }
}

void qTimeEditSetDisplayFormat(int64_t ptr, const char* format) {
    QTimeEdit* edit = reinterpret_cast<QTimeEdit*>(ptr);
    if (edit) {
        edit->setDisplayFormat(QString::fromUtf8(format));
    }
}

const char* qTimeEditDisplayFormat(int64_t ptr) {
    QTimeEdit* edit = reinterpret_cast<QTimeEdit*>(ptr);
    if (edit) {
        return safeCopyString(edit->displayFormat());
    }
    return cjqt6::emptyString();
}

// ============================================================
// QDateTimeEdit 桥接函数
// ============================================================

int64_t qDateTimeEditCreate() {
    QDateTimeEdit* edit = new QDateTimeEdit();
    return reinterpret_cast<int64_t>(edit);
}

int64_t qDateTimeEditCreateWithDateTime(int64_t dtPtr) {
    QDateTime* dt = reinterpret_cast<QDateTime*>(dtPtr);
    QDateTimeEdit* edit = new QDateTimeEdit(*dt);
    return reinterpret_cast<int64_t>(edit);
}

void qDateTimeEditDelete(int64_t ptr) {
    QDateTimeEdit* edit = reinterpret_cast<QDateTimeEdit*>(ptr);
    if (edit) {
        qWmiscSignalCleanup(ptr);
        delete edit;
    }
}

int64_t qDateTimeEditDateTime(int64_t ptr) {
    QDateTimeEdit* edit = reinterpret_cast<QDateTimeEdit*>(ptr);
    if (edit) {
        QDateTime* dt = new QDateTime(edit->dateTime());
        return reinterpret_cast<int64_t>(dt);
    }
    return 0;
}

void qDateTimeEditSetDateTime(int64_t ptr, int64_t dtPtr) {
    QDateTimeEdit* edit = reinterpret_cast<QDateTimeEdit*>(ptr);
    QDateTime* dt = reinterpret_cast<QDateTime*>(dtPtr);
    if (edit && dt) {
        edit->setDateTime(*dt);
    }
}

int64_t qDateTimeEditDate(int64_t ptr) {
    QDateTimeEdit* edit = reinterpret_cast<QDateTimeEdit*>(ptr);
    if (edit) {
        QDate* date = new QDate(edit->date());
        return reinterpret_cast<int64_t>(date);
    }
    return 0;
}

void qDateTimeEditSetDate(int64_t ptr, int64_t datePtr) {
    QDateTimeEdit* edit = reinterpret_cast<QDateTimeEdit*>(ptr);
    QDate* date = reinterpret_cast<QDate*>(datePtr);
    if (edit && date) {
        edit->setDate(*date);
    }
}

int64_t qDateTimeEditTime(int64_t ptr) {
    QDateTimeEdit* edit = reinterpret_cast<QDateTimeEdit*>(ptr);
    if (edit) {
        QTime* time = new QTime(edit->time());
        return reinterpret_cast<int64_t>(time);
    }
    return 0;
}

void qDateTimeEditSetTime(int64_t ptr, int64_t timePtr) {
    QDateTimeEdit* edit = reinterpret_cast<QDateTimeEdit*>(ptr);
    QTime* time = reinterpret_cast<QTime*>(timePtr);
    if (edit && time) {
        edit->setTime(*time);
    }
}

void qDateTimeEditSetMinimumDateTime(int64_t ptr, int64_t dtPtr) {
    QDateTimeEdit* edit = reinterpret_cast<QDateTimeEdit*>(ptr);
    QDateTime* dt = reinterpret_cast<QDateTime*>(dtPtr);
    if (edit && dt) {
        edit->setMinimumDateTime(*dt);
    }
}

void qDateTimeEditSetMaximumDateTime(int64_t ptr, int64_t dtPtr) {
    QDateTimeEdit* edit = reinterpret_cast<QDateTimeEdit*>(ptr);
    QDateTime* dt = reinterpret_cast<QDateTime*>(dtPtr);
    if (edit && dt) {
        edit->setMaximumDateTime(*dt);
    }
}

void qDateTimeEditSetDisplayFormat(int64_t ptr, const char* format) {
    QDateTimeEdit* edit = reinterpret_cast<QDateTimeEdit*>(ptr);
    if (edit) {
        edit->setDisplayFormat(QString::fromUtf8(format));
    }
}

const char* qDateTimeEditDisplayFormat(int64_t ptr) {
    QDateTimeEdit* edit = reinterpret_cast<QDateTimeEdit*>(ptr);
    if (edit) {
        return safeCopyString(edit->displayFormat());
    }
    return cjqt6::emptyString();
}

void qDateTimeEditSetCalendarPopup(int64_t ptr, int32_t enable) {
    QDateTimeEdit* edit = reinterpret_cast<QDateTimeEdit*>(ptr);
    if (edit) {
        edit->setCalendarPopup(enable != 0);
    }
}

int32_t qDateTimeEditCalendarPopup(int64_t ptr) {
    QDateTimeEdit* edit = reinterpret_cast<QDateTimeEdit*>(ptr);
    return edit && edit->calendarPopup() ? 1 : 0;
}

void qDateTimeEditSetTimeSpec(int64_t ptr, int32_t spec) {
    QDateTimeEdit* edit = reinterpret_cast<QDateTimeEdit*>(ptr);
    if (edit) {
        edit->setTimeSpec(static_cast<Qt::TimeSpec>(spec));
    }
}

int32_t qDateTimeEditTimeSpec(int64_t ptr) {
    QDateTimeEdit* edit = reinterpret_cast<QDateTimeEdit*>(ptr);
    return edit ? static_cast<int32_t>(edit->timeSpec()) : 0;
}

} // extern "C"
