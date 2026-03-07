#ifndef CJQT6_CORE_H
#define CJQT6_CORE_H

// 标准C库 - 必须放在所有其他头文件之前
#include <cstddef>
#include <cstring>
#include <cstdlib>
#include <cstdio>
#include <cstdint>
#include <functional>

// Qt头文件
#include <QObject>
#include <QTimer>
#include <QEventLoop>
#include <QCoreApplication>
#include <QDebug>
#include <QThread>
#include <QMap>

// 项目头文件 (必须在标准库和Qt头文件之后)
#include "types.h"
#include "cj_string.h"

namespace cjqt6 {

// ============================================================
// Application - 应用程序类
// ============================================================

/**
 * @brief 仓颉风格的应用程序类
 */
class Application : public QObject {
    Q_OBJECT
public:
    Application(int& argc, char** argv);
    virtual ~Application() = default;

    int exec();
    void quit();
    void exit(int returnCode = 0);

    // 属性
    String applicationName() const;
    void setApplicationName(const String& name);
    
    String applicationVersion() const;
    void setApplicationVersion(const String& version);
    
    String organizationName() const;
    void setOrganizationName(const String& name);

    // 延迟执行
    static void delay(int milliseconds);
    static void callLater(int milliseconds, std::function<void()> callback);

private:
    QCoreApplication* m_app;
};

// ============================================================
// Timer - 定时器类
// ============================================================

/**
 * @brief 仓颉风格的定时器类
 */
class Timer : public QObject {
    Q_OBJECT
public:
    explicit Timer(QObject* parent = nullptr);
    virtual ~Timer() = default;

    void setInterval(int milliseconds);
    void setSingleShot(bool singleShot);
    void setRepeating(bool repeating);
    
    void start();
    void start(int milliseconds);
    void stop();
    
    bool isActive() const;
    int interval() const;
    bool isSingleShot() const;

    // 信号
    std::function<void()> onTimeout;

private slots:
    void timeoutHandler();

private:
    QTimer* m_timer;
};

// ============================================================
// Log - 日志类
// ============================================================

/**
 * @brief 仓颉风格的日志类
 */
class Log {
public:
    static void debug(const String& message);
    static void info(const String& message);
    static void warning(const String& message);
    static void error(const String& message);
    static void critical(const String& message);
    
    static void setEnabled(bool enabled);
    static bool isEnabled();
    
    template<typename... Args>
    static void debug(const String& pattern, Args... args);
    template<typename... Args>
    static void info(const String& pattern, Args... args);

private:
    static bool s_enabled;
};

// ============================================================
// Config - 配置类
// ============================================================

/**
 * @brief 仓颉风格的配置管理类
 */
class Config {
public:
    static Option<String> get(const String& key);
    static void set(const String& key, const String& value);
    static void remove(const String& key);
    static void clear();
    
    static bool contains(const String& key);
    static std::vector<String> keys();

    static void save();
    static void load();

private:
    static QMap<QString, QString> s_config;
};

} // namespace cjqt6

#endif // CJQT6_CORE_H