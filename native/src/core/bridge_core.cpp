/**
 * @file bridge_core.cpp
 * @brief 核心模块桥接函数 - QApplication, QWidget, QTimer
 */

#include <QApplication>
#include <QWidget>
#include <QTimer>
#include <QDebug>
#include <functional>
#include <unordered_map>

// 全局应用程序指针
static QApplication* g_app = nullptr;

// 回调函数映射 - 非static，供其他模块使用
std::unordered_map<int64_t, std::function<void(int64_t)>> g_buttonCallbacks;
std::unordered_map<int64_t, std::function<void(int64_t)>> g_timerCallbacks;

extern "C" {

// ============================================================
// QApplication 桥接函数
// ============================================================

int64_t qApplicationCreate() {
    if (!g_app) {
        int argc = 0;
        g_app = new QApplication(argc, nullptr);
    }
    return reinterpret_cast<int64_t>(g_app);
}

int32_t qApplicationExec() {
    if (g_app) {
        return g_app->exec();
    }
    return -1;
}

void qApplicationQuit() {
    if (g_app) {
        g_app->quit();
    }
}

void qApplicationDelete(int64_t ptr) {
    // 不删除全局 QApplication
}

// ============================================================
// QWidget 桥接函数
// ============================================================

int64_t qWidgetCreate() {
    QWidget* widget = new QWidget();
    return reinterpret_cast<int64_t>(widget);
}

void qWidgetShow(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->show();
    }
}

void qWidgetHide(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->hide();
    }
}

void qWidgetSetTitle(int64_t ptr, const char* title) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->setWindowTitle(title);
    }
}

void qWidgetResize(int64_t ptr, int32_t width, int32_t height) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->resize(width, height);
    }
}

void qWidgetSetGeometry(int64_t ptr, int32_t x, int32_t y, int32_t width, int32_t height) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->setGeometry(x, y, width, height);
    }
}

void qWidgetSetLayout(int64_t widgetPtr, int64_t layoutPtr) {
    QWidget* widget = reinterpret_cast<QWidget*>(widgetPtr);
    QLayout* layout = reinterpret_cast<QLayout*>(layoutPtr);
    if (widget && layout) {
        widget->setLayout(layout);
    }
}

void qWidgetDelete(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        delete widget;
    }
}

// ============================================================
// QTimer 桥接函数
// ============================================================

int64_t qTimerCreate() {
    QTimer* timer = new QTimer();
    return reinterpret_cast<int64_t>(timer);
}

void qTimerSetInterval(int64_t ptr, int32_t interval) {
    QTimer* timer = reinterpret_cast<QTimer*>(ptr);
    if (timer) {
        timer->setInterval(interval);
    }
}

void qTimerStart(int64_t ptr) {
    QTimer* timer = reinterpret_cast<QTimer*>(ptr);
    if (timer) {
        timer->start();
    }
}

void qTimerStop(int64_t ptr) {
    QTimer* timer = reinterpret_cast<QTimer*>(ptr);
    if (timer) {
        timer->stop();
    }
}

void qTimerSetTimeout(int64_t ptr, void (*callback)(int64_t)) {
    QTimer* timer = reinterpret_cast<QTimer*>(ptr);
    if (timer) {
        int64_t timerPtr = ptr;
        g_timerCallbacks[ptr] = [callback, timerPtr](int64_t) { callback(timerPtr); };
        QObject::connect(timer, &QTimer::timeout, [timerPtr]() {
            auto it = g_timerCallbacks.find(timerPtr);
            if (it != g_timerCallbacks.end()) {
                it->second(timerPtr);
            }
        });
    }
}

void qTimerDelete(int64_t ptr) {
    QTimer* timer = reinterpret_cast<QTimer*>(ptr);
    if (timer) {
        g_timerCallbacks.erase(ptr);
        delete timer;
    }
}

} // extern "C"
// ============================================================
// QWidget 样式表支持
// ============================================================

void qWidgetSetStyleSheet(int64_t ptr, const char* styleSheet) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->setStyleSheet(QString::fromUtf8(styleSheet));
    }
}

const char* qWidgetStyleSheet(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        static QByteArray styleSheet;
        styleSheet = widget->styleSheet().toUtf8();
        return styleSheet.constData();
    }
    return "";
}

void qWidgetSetEnabled(int64_t ptr, int32_t enabled) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->setEnabled(enabled != 0);
    }
}

int32_t qWidgetIsEnabled(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        return widget->isEnabled() ? 1 : 0;
    }
    return 0;
}

void qWidgetSetVisible(int64_t ptr, int32_t visible) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->setVisible(visible != 0);
    }
}

int32_t qWidgetIsVisible(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        return widget->isVisible() ? 1 : 0;
    }
    return 0;
}

void qWidgetSetToolTip(int64_t ptr, const char* toolTip) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->setToolTip(QString::fromUtf8(toolTip));
    }
}

void qWidgetSetMinimumSize(int64_t ptr, int32_t width, int32_t height) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->setMinimumSize(width, height);
    }
}

void qWidgetSetMaximumSize(int64_t ptr, int32_t width, int32_t height) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->setMaximumSize(width, height);
    }
}

int32_t qWidgetWidth(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        return widget->width();
    }
    return 0;
}

int32_t qWidgetHeight(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        return widget->height();
    }
    return 0;
}

void qWidgetUpdate(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->update();
    }
}

void qWidgetRepaint(int64_t ptr) {
    QWidget* widget = reinterpret_cast<QWidget*>(ptr);
    if (widget) {
        widget->repaint();
    }
}

