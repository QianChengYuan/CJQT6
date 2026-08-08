#ifndef CJQT6_BRIDGE_STRING_UTILS_H
#define CJQT6_BRIDGE_STRING_UTILS_H

// 桥接层字符串返回统一工具
//
// 约定（P0 桥接内存安全审计定稿）：
//   - 所有导出为 const char* 的字符串返回函数，一律用 malloc+memcpy 分配堆内存；
//   - 永不返回字符串字面量 / 静态缓冲 / 调用方入参指针；
//   - 对象为空或空串时返回 qEmptyCString()（malloc 的 1 字节 '\0'）；
//   - 调用方（Cangjie FFI 侧）读取后必须 LibC.free 释放，见 src/ 封装。

#include <QByteArray>
#include <QString>
#include <cstddef>
#include <cstdlib>
#include <cstring>

namespace cjqt6 {

// 从 QString 复制一份 malloc 分配的 UTF-8 字符串
inline char* dupUtf8(const QString& s) {
    QByteArray arr = s.toUtf8();
    char* result = static_cast<char*>(std::malloc(static_cast<std::size_t>(arr.size()) + 1));
    if (result) {
        std::memcpy(result, arr.constData(), static_cast<std::size_t>(arr.size()) + 1);
    }
    return result;
}

// 从 QByteArray（UTF-8 已编码）复制一份 malloc 分配的字符串
inline char* dupUtf8(const QByteArray& arr) {
    char* result = static_cast<char*>(std::malloc(static_cast<std::size_t>(arr.size()) + 1));
    if (result) {
        std::memcpy(result, arr.constData(), static_cast<std::size_t>(arr.size()) + 1);
    }
    return result;
}

// 返回 malloc 分配的空字符串（1 字节 '\0'），供失败/空场景统一返回
inline char* emptyString() {
    char* result = static_cast<char*>(std::malloc(1));
    if (result) {
        result[0] = '\0';
    }
    return result;
}

} // namespace cjqt6

#endif // CJQT6_BRIDGE_STRING_UTILS_H
