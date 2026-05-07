#ifndef CJFW_TYPES_H
#define CJFW_TYPES_H

// 标准C库 - 必须放在所有其他头文件之前
#include <cstddef>
#include <cstring>
#include <cstdlib>
#include <cstdio>
#include <cstdint>
#include <string>
#include <vector>
#include <map>
#include <optional>
#include <variant>
#include <functional>
#include <stdexcept>

namespace cjfw {

// 前向声明 String 类
class String;

// ============================================================
// Option<T> - 可选类型
// ============================================================

/**
 * @brief 仓颉风格的可选类型,类似 Rust 的 Option 或 C++17 的 std::optional
 */
template<typename T>
class Option {
public:
    Option() = default;
    Option(const T& value);
    Option(T&& value) noexcept;
    Option(std::nullopt_t) noexcept;
    
    [[nodiscard]] bool isSome() const;
    [[nodiscard]] bool isNone() const;
    [[nodiscard]] explicit operator bool() const;
    
    [[nodiscard]] T& unwrap();
    [[nodiscard]] const T& unwrap() const;
    [[nodiscard]] T unwrapOr(const T& defaultValue) const;
    
    [[nodiscard]] T& unwrapOrThrow(const char* errorMessage = "Option is None");
    
    template<typename F>
    auto map(F&& func) -> Option<decltype(func(std::declval<T>()))>;
    
    template<typename F>
    auto andThen(F&& func) -> decltype(func(std::declval<T>()));
    
    template<typename F>
    Option<T> orElse(F&& func);

private:
    std::optional<T> m_value;
};

// None 类型
inline constexpr struct NoneType {} None;

// ============================================================
// Result<T, E> - 结果类型
// ============================================================

/**
 * @brief 仓颉风格的结果类型,用于错误处理
 */
template<typename T, typename E = std::string>
class Result {
public:
    Result(const T& value);
    Result(T&& value) noexcept;
    Result(const E& error);
    Result(E&& error) noexcept;
    
    [[nodiscard]] bool isOk() const;
    [[nodiscard]] bool isErr() const;
    [[nodiscard]] explicit operator bool() const;
    
    [[nodiscard]] T& unwrap();
    [[nodiscard]] const T& unwrap() const;
    [[nodiscard]] T unwrapOr(const T& defaultValue) const;
    
    [[nodiscard]] E& unwrapErr();
    [[nodiscard]] const E& unwrapErr() const;
    
    template<typename F>
    auto map(F&& func) -> Result<decltype(func(std::declval<T>())), E>;
    
    template<typename F>
    auto andThen(F&& func) -> decltype(func(std::declval<T>()));

private:
    std::variant<T, E> m_value;
};

// ============================================================
// Array<T> - 数组类型
// ============================================================

/**
 * @brief 仓颉风格的数组封装
 */
template<typename T>
class Array {
public:
    Array() = default;
    Array(std::initializer_list<T> init);
    
    // 容量
    [[nodiscard]] int size() const;
    [[nodiscard]] bool isEmpty() const;
    [[nodiscard]] bool isNotEmpty() const;
    
    // 元素访问
    [[nodiscard]] T& operator[](int index);
    [[nodiscard]] const T& operator[](int index) const;
    [[nodiscard]] T& first();
    [[nodiscard]] const T& first() const;
    [[nodiscard]] T& last();
    [[nodiscard]] const T& last() const;
    
    // 添加和删除
    void append(const T& item);
    void append(T&& item);
    void prepend(const T& item);
    void prepend(T&& item);
    void insert(int index, const T& item);
    void removeAt(int index);
    void removeFirst();
    void removeLast();
    void clear();
    
    // 查找
    [[nodiscard]] int indexOf(const T& item) const;
    [[nodiscard]] bool contains(const T& item) const;
    
    // 转换
    [[nodiscard]] std::vector<T> toStdVector() const;
    
    // 迭代器
    [[nodiscard]] auto begin() { return m_data.begin(); }
    [[nodiscard]] auto end() { return m_data.end(); }
    [[nodiscard]] auto begin() const { return m_data.begin(); }
    [[nodiscard]] auto end() const { return m_data.end(); }

private:
    std::vector<T> m_data;
};

// ============================================================
// Func<R(Args...)> - 函数类型
// ============================================================

/**
 * @brief 仓颉风格的函数类型封装
 */
template<typename R, typename... Args>
class Func {
public:
    Func() = default;
    Func(std::function<R(Args...)> func);
    Func(R (*func)(Args...));
    
    [[nodiscard]] bool isValid() const;
    [[nodiscard]] explicit operator bool() const;
    
    R operator()(Args... args) const;
    
    template<typename F>
    Func& operator=(F&& func);

private:
    std::function<R(Args...)> m_func;
};

// ============================================================
// 类型别名
// ============================================================

template<typename T>
using List = Array<T>;

template<typename T>
using Vec = Array<T>;

using Int32 = int32_t;
using Int64 = int64_t;
using UInt32 = uint32_t;
using UInt64 = uint64_t;
using Float32 = float;
using Float64 = double;

// ============================================================
// 模板类实现 (需要在头文件中定义)
// ============================================================

// Option<T> 实现
template<typename T>
Option<T>::Option(const T& value) : m_value(value) {}

template<typename T>
Option<T>::Option(T&& value) noexcept : m_value(std::move(value)) {}

template<typename T>
Option<T>::Option(std::nullopt_t) noexcept : m_value(std::nullopt) {}

template<typename T>
bool Option<T>::isSome() const { return m_value.has_value(); }

template<typename T>
bool Option<T>::isNone() const { return !m_value.has_value(); }

template<typename T>
Option<T>::operator bool() const { return m_value.has_value(); }

template<typename T>
T& Option<T>::unwrap() {
    if (!m_value.has_value()) throw std::runtime_error("Option is None");
    return m_value.value();
}

template<typename T>
const T& Option<T>::unwrap() const {
    if (!m_value.has_value()) throw std::runtime_error("Option is None");
    return m_value.value();
}

template<typename T>
T Option<T>::unwrapOr(const T& defaultValue) const {
    return m_value.value_or(defaultValue);
}

template<typename T>
T& Option<T>::unwrapOrThrow(const char* errorMessage) {
    if (!m_value.has_value()) throw std::runtime_error(errorMessage);
    return m_value.value();
}

// Array<T> 实现
template<typename T>
Array<T>::Array(std::initializer_list<T> init) : m_data(init) {}

template<typename T>
int Array<T>::size() const { return static_cast<int>(m_data.size()); }

template<typename T>
bool Array<T>::isEmpty() const { return m_data.empty(); }

template<typename T>
bool Array<T>::isNotEmpty() const { return !m_data.empty(); }

template<typename T>
T& Array<T>::operator[](int index) { return m_data.at(static_cast<size_t>(index)); }

template<typename T>
const T& Array<T>::operator[](int index) const { return m_data.at(static_cast<size_t>(index)); }

template<typename T>
T& Array<T>::first() { return m_data.front(); }

template<typename T>
const T& Array<T>::first() const { return m_data.front(); }

template<typename T>
T& Array<T>::last() { return m_data.back(); }

template<typename T>
const T& Array<T>::last() const { return m_data.back(); }

template<typename T>
void Array<T>::append(const T& item) { m_data.push_back(item); }

template<typename T>
void Array<T>::append(T&& item) { m_data.push_back(std::move(item)); }

template<typename T>
void Array<T>::prepend(const T& item) { m_data.insert(m_data.begin(), item); }

template<typename T>
void Array<T>::prepend(T&& item) { m_data.insert(m_data.begin(), std::move(item)); }

template<typename T>
void Array<T>::insert(int index, const T& item) { m_data.insert(m_data.begin() + index, item); }

template<typename T>
void Array<T>::removeAt(int index) { m_data.erase(m_data.begin() + index); }

template<typename T>
void Array<T>::removeFirst() { m_data.erase(m_data.begin()); }

template<typename T>
void Array<T>::removeLast() { m_data.pop_back(); }

template<typename T>
void Array<T>::clear() { m_data.clear(); }

template<typename T>
int Array<T>::indexOf(const T& item) const {
    auto it = std::find(m_data.begin(), m_data.end(), item);
    if (it != m_data.end()) {
        return static_cast<int>(std::distance(m_data.begin(), it));
    }
    return -1;
}

template<typename T>
bool Array<T>::contains(const T& item) const { return indexOf(item) != -1; }

template<typename T>
std::vector<T> Array<T>::toStdVector() const { return m_data; }

// Result<T, E> 实现
template<typename T, typename E>
Result<T, E>::Result(const T& value) : m_value(value) {}

template<typename T, typename E>
Result<T, E>::Result(T&& value) noexcept : m_value(std::move(value)) {}

template<typename T, typename E>
Result<T, E>::Result(const E& error) : m_value(error) {}

template<typename T, typename E>
Result<T, E>::Result(E&& error) noexcept : m_value(std::move(error)) {}

template<typename T, typename E>
bool Result<T, E>::isOk() const { return std::holds_alternative<T>(m_value); }

template<typename T, typename E>
bool Result<T, E>::isErr() const { return std::holds_alternative<E>(m_value); }

template<typename T, typename E>
Result<T, E>::operator bool() const { return isOk(); }

template<typename T, typename E>
T& Result<T, E>::unwrap() {
    if (!isOk()) throw std::runtime_error("Result is Err");
    return std::get<T>(m_value);
}

template<typename T, typename E>
const T& Result<T, E>::unwrap() const {
    if (!isOk()) throw std::runtime_error("Result is Err");
    return std::get<T>(m_value);
}

template<typename T, typename E>
T Result<T, E>::unwrapOr(const T& defaultValue) const {
    if (isOk()) return std::get<T>(m_value);
    return defaultValue;
}

template<typename T, typename E>
E& Result<T, E>::unwrapErr() {
    if (isErr()) return std::get<E>(m_value);
    throw std::runtime_error("Result is Ok");
}

template<typename T, typename E>
const E& Result<T, E>::unwrapErr() const {
    if (isErr()) return std::get<E>(m_value);
    throw std::runtime_error("Result is Ok");
}

} // namespace cjfw

#endif // CJFW_TYPES_H