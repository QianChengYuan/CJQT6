#ifndef CJFW_VERSION_H
#define CJFW_VERSION_H

namespace cjfw {

/**
 * @brief 获取 CJFW 库版本
 * @return 版本字符串
 */
inline const char* getVersion() {
    return "1.0.0";
}

/**
 * @brief 获取 CJFW 库主版本号
 * @return 主版本号
 */
inline int getMajorVersion() {
    return 1;
}

/**
 * @brief 获取 CJFW 库次版本号
 * @return 次版本号
 */
inline int getMinorVersion() {
    return 0;
}

/**
 * @brief 获取 CJFW 库补丁版本号
 * @return 补丁版本号
 */
inline int getPatchVersion() {
    return 0;
}

} // namespace cjfw

#endif // CJFW_VERSION_H