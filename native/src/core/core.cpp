#include "core.h"
#include "string.h"
#include "types.h"
#include <QThread>
#include <QEventLoop>
#include <QTimer>

namespace cjfw {

// ============================================================
// Log 实现
// ============================================================

bool Log::s_enabled = true;

void Log::debug(const String& message) {
    if (s_enabled) {
        qDebug() << "[DEBUG]" << message.toQt();
    }
}

void Log::info(const String& message) {
    if (s_enabled) {
        qInfo() << "[INFO]" << message.toQt();
    }
}

void Log::warning(const String& message) {
    if (s_enabled) {
        qWarning() << "[WARNING]" << message.toQt();
    }
}

void Log::error(const String& message) {
    if (s_enabled) {
        qCritical() << "[ERROR]" << message.toQt();
    }
}

void Log::critical(const String& message) {
    if (s_enabled) {
        qCritical() << "[CRITICAL]" << message.toQt();
    }
}

void Log::setEnabled(bool enabled) {
    s_enabled = enabled;
}

bool Log::isEnabled() {
    return s_enabled;
}

// ============================================================
// Config 实现
// ============================================================

QMap<QString, QString> Config::s_config;

Option<String> Config::get(const String& key) {
    if (s_config.contains(key.toQt())) {
        return Option<String>(String(s_config.value(key.toQt())));
    }
    return Option<String>();
}

void Config::set(const String& key, const String& value) {
    s_config[key.toQt()] = value.toQt();
}

void Config::remove(const String& key) {
    s_config.remove(key.toQt());
}

void Config::clear() {
    s_config.clear();
}

bool Config::contains(const String& key) {
    return s_config.contains(key.toQt());
}

std::vector<String> Config::keys() {
    QStringList qKeys = s_config.keys();
    std::vector<String> result;
    result.reserve(qKeys.size());
    for (const auto& key : qKeys) {
        result.emplace_back(key);
    }
    return result;
}

void Config::save() {
    // TODO: 实现保存到文件
}

void Config::load() {
    // TODO: 实现从文件加载
}

// ============================================================
// Application 实现
// ============================================================

void Application::delay(int milliseconds) {
    QThread::msleep(milliseconds);
}

void Application::callLater(int milliseconds, std::function<void()> callback) {
    QTimer::singleShot(milliseconds, QCoreApplication::instance(), [callback]() {
        callback();
    });
}

} // namespace cjfw