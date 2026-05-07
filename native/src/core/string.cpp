#include "cj_string.h"
#include "types.h"
#include <algorithm>
#include <sstream>
#include <QStringList>
#include <QRegularExpression>

namespace cjfw {

// ============================================================
// String 实现
// ============================================================

String::String(const QString& str) : m_data(str) {}
String::String(QString&& str) noexcept : m_data(std::move(str)) {}
String::String(const char* str) : m_data(str) {}
String::String(const std::string& str) : m_data(QString::fromStdString(str)) {}
String::String(const std::string_view& str) : m_data(QString::fromStdString(std::string(str))) {}

int String::length() const {
    return m_data.length();
}

bool String::isEmpty() const {
    return m_data.isEmpty();
}

bool String::isEmptyOrWhitespace() const {
    return m_data.trimmed().isEmpty();
}

QString String::toQt() const {
    return m_data;
}

std::string String::toStdString() const {
    return m_data.toStdString();
}

const char* String::toCString() const {
    return m_data.toLocal8Bit().constData();
}

String String::toUpper() const {
    return String(m_data.toUpper());
}

String String::toLower() const {
    return String(m_data.toLower());
}

String String::toTitleCase() const {
    // Qt6 中没有 toTitleCase 方法,这里简化实现
    return String(m_data.toLower());
}

bool String::contains(const String& str) const {
    return m_data.contains(str.m_data);
}

bool String::startsWith(const String& str) const {
    return m_data.startsWith(str.m_data);
}

bool String::endsWith(const String& str) const {
    return m_data.endsWith(str.m_data);
}

int String::indexOf(const String& str, int from) const {
    return m_data.indexOf(str.m_data, from);
}

String String::replace(const String& before, const String& after) const {
    QString temp = m_data;
    return String(temp.replace(before.m_data, after.m_data));
}

String String::substring(int start, int length) const {
    if (length < 0) {
        return String(m_data.mid(start));
    }
    return String(m_data.mid(start, length));
}

String String::left(int n) const {
    return String(m_data.left(n));
}

String String::right(int n) const {
    return String(m_data.right(n));
}

std::vector<String> String::split(const String& separator) const {
    QStringList parts = m_data.split(separator.m_data, Qt::KeepEmptyParts);
    std::vector<String> result;
    result.reserve(parts.size());
    for (const auto& part : parts) {
        result.emplace_back(part);
    }
    return result;
}

String String::join(const std::vector<String>& strings, const String& separator) {
    QStringList parts;
    parts.reserve(strings.size());
    for (const auto& str : strings) {
        parts.append(str.m_data);
    }
    return String(parts.join(separator.m_data));
}

String String::trimmed() const {
    return String(m_data.trimmed());
}

String String::trimmedLeft() const {
    QString temp = m_data;
    return String(temp.remove(QRegularExpression("^\\s+")));
}

String String::trimmedRight() const {
    QString temp = m_data;
    return String(temp.remove(QRegularExpression("\\s+$")));
}

bool String::equals(const String& other, bool caseSensitive) const {
    if (caseSensitive) {
        return m_data == other.m_data;
    }
    return m_data.compare(other.m_data, Qt::CaseInsensitive) == 0;
}

int String::compare(const String& other) const {
    return m_data.compare(other.m_data);
}

String String::operator+(const String& other) const {
    return String(m_data + other.m_data);
}

String& String::operator+=(const String& other) {
    m_data += other.m_data;
    return *this;
}

bool String::operator==(const String& other) const {
    return m_data == other.m_data;
}

bool String::operator!=(const String& other) const {
    return m_data != other.m_data;
}

bool String::operator<(const String& other) const {
    return m_data < other.m_data;
}

int String::toInt(bool* ok) const {
    return m_data.toInt(ok);
}

double String::toDouble(bool* ok) const {
    return m_data.toDouble(ok);
}

bool String::toBool() const {
    return m_data.toLower() == "true";
}

String String::fromInt(int value) {
    return String(QString::number(value));
}

String String::fromDouble(double value) {
    return String(QString::number(value));
}

String String::fromBool(bool value) {
    return String(value ? "true" : "false");
}

} // namespace cjfw