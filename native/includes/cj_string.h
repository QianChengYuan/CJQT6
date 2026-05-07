#ifndef CJFW_STRING_H
#define CJFW_STRING_H

// 标准C库 - 必须放在所有其他头文件之前
#include <cstddef>
#include <cstring>
#include <cstdlib>
#include <cstdio>
#include <string>
#include <string_view>
#include <vector>

// Qt头文件
#include <QString>
#include <QStringList>

namespace cjfw {

/**
 * @brief 仓颉风格的字符串封装
 * 提供类似仓颉语言的字符串操作接口
 */
class String {
public:
    // 构造函数
    String() = default;
    String(const QString& str);
    String(QString&& str) noexcept;
    String(const char* str);
    String(const std::string& str);
    String(const std::string_view& str);

    // 拷贝和移动
    String(const String& other) = default;
    String(String&& other) noexcept = default;
    String& operator=(const String& other) = default;
    String& operator=(String&& other) noexcept = default;

    // 基础操作
    [[nodiscard]] int length() const;
    [[nodiscard]] bool isEmpty() const;
    [[nodiscard]] bool isEmptyOrWhitespace() const;
    
    // 转换
    [[nodiscard]] QString toQt() const;
    [[nodiscard]] std::string toStdString() const;
    [[nodiscard]] const char* toCString() const;
    
    // 大小写
    [[nodiscard]] String toUpper() const;
    [[nodiscard]] String toLower() const;
    [[nodiscard]] String toTitleCase() const;
    
    // 查找和替换
    [[nodiscard]] bool contains(const String& str) const;
    [[nodiscard]] bool startsWith(const String& str) const;
    [[nodiscard]] bool endsWith(const String& str) const;
    [[nodiscard]] int indexOf(const String& str, int from = 0) const;
    [[nodiscard]] String replace(const String& before, const String& after) const;
    
    // 子字符串
    [[nodiscard]] String substring(int start, int length = -1) const;
    [[nodiscard]] String left(int n) const;
    [[nodiscard]] String right(int n) const;
    
    // 分割和连接
    [[nodiscard]] std::vector<String> split(const String& separator) const;
    static String join(const std::vector<String>& strings, const String& separator);
    
    // 修剪
    [[nodiscard]] String trimmed() const;
    [[nodiscard]] String trimmedLeft() const;
    [[nodiscard]] String trimmedRight() const;
    
    // 比较
    bool equals(const String& other, bool caseSensitive = true) const;
    int compare(const String& other) const;
    
    // 格式化
    template<typename... Args>
    static String format(const String& pattern, Args... args);
    
    // 操作符
    String operator+(const String& other) const;
    String& operator+=(const String& other);
    bool operator==(const String& other) const;
    bool operator!=(const String& other) const;
    bool operator<(const String& other) const;
    
    // 类型转换
    [[nodiscard]] int toInt(bool* ok = nullptr) const;
    [[nodiscard]] double toDouble(bool* ok = nullptr) const;
    [[nodiscard]] bool toBool() const;
    
    static String fromInt(int value);
    static String fromDouble(double value);
    static String fromBool(bool value);

private:
    QString m_data;
};

// 类型别名
using Text = String;

} // namespace cjfw

#endif // CJFW_STRING_H