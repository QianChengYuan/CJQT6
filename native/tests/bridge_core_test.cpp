// ============================================================
// bridge_core_test.cpp —— 桥接层 C++ 单元测试（P0-3）
//
// 覆盖对象：
//   1. QObject 存活注册表三件套 qTrackObject / qUntrackObject / qIsObjectAlive
//      - 注册后存活、析构后置脏（destroyed 信号级联触发）
//      - 级联析构（父控件销毁 → 子对象 destroyed）置脏
//      - 注销后条目删除、未注册对象按存活处理、null 返回 0
//      - 多线程并发注册/注销（AliveSpinLock 保护）
//   2. 字符串工具 dupUtf8 / emptyString / qCStringFree
//      - malloc 拷贝内容正确、空串返回可释放的 1 字节 '\0'
//      - 所有分配均经 qCStringFree 释放（ASAN detect_leaks 下零泄漏）
//
// 无第三方测试框架依赖；断言失败累计并以退出码表达，便于 ctest 集成。
// 构建时用 -DCJQT6_BUILD_TESTS=ON 启用；配合 -DCJQT6_NATIVE_TESTS_ASAN=ON
// 可用 AddressSanitizer 校验字符串泄漏。
// ============================================================

#include <QObject>
#include <atomic>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <thread>
#include <vector>

#include "bridge_string_utils.h"

// 桥接库导出的 extern "C" 符号（与 native/src/core/bridge_core.cpp 声明一致）
extern "C" {
void qTrackObject(int64_t ptr);
void qUntrackObject(int64_t ptr);
int32_t qIsObjectAlive(int64_t ptr);
void qCStringFree(const char* s);
}

// ---------------- 极简断言框架 ----------------
static int g_checks = 0;
static int g_failed = 0;

#define CHECK(cond)                                                        \
    do {                                                                   \
        ++g_checks;                                                        \
        if (!(cond)) {                                                     \
            ++g_failed;                                                    \
            std::fprintf(stderr, "FAIL %s:%d: %s\n", __FILE__, __LINE__, #cond); \
        }                                                                  \
    } while (0)

#define RUN_SUITE(name)                                    \
    do {                                                   \
        int before = g_failed;                             \
        name();                                            \
        std::printf("[%s] %s: %s\n",                       \
                    g_failed == before ? "PASS" : "FAIL",  \
                    #name,                                 \
                    g_failed == before ? "ok" : "see above"); \
    } while (0)

// ---------------- 字符串工具 ----------------
static void testStringUtils() {
    // dupUtf8(QString)：正常内容
    char* s1 = cjqt6::dupUtf8(QStringLiteral("hello 世界"));
    CHECK(s1 != nullptr);
    CHECK(std::strcmp(s1, "hello 世界") == 0);
    qCStringFree(s1);

    // dupUtf8(QString)：空串 → malloc 的 1 字节 '\0'
    char* s2 = cjqt6::dupUtf8(QString());
    CHECK(s2 != nullptr);
    CHECK(s2[0] == '\0');
    qCStringFree(s2);

    // dupUtf8(QByteArray)：含内部 '\0' 的字节串按原始长度拷贝
    QByteArray bin("ab\0cd", 5);
    char* s3 = cjqt6::dupUtf8(bin);
    CHECK(s3 != nullptr);
    CHECK(std::memcmp(s3, bin.constData(), 5) == 0);
    CHECK(s3[5] == '\0');
    qCStringFree(s3);

    // emptyString：返回可释放的空串
    char* e = cjqt6::emptyString();
    CHECK(e != nullptr);
    CHECK(e[0] == '\0');
    qCStringFree(e);

    // qCStringFree 可释放 dupUtf8/emptyString 分配的内存（同堆约定）
    char* s4 = cjqt6::dupUtf8(QStringLiteral("release-me"));
    qCStringFree(s4);
    char* e2 = cjqt6::emptyString();
    qCStringFree(e2);
}

// ---------------- 存活表基础 ----------------
static void testAliveBasics() {
    QObject* obj = new QObject();
    int64_t p = reinterpret_cast<int64_t>(obj);

    // 未注册 → 按存活处理
    CHECK(qIsObjectAlive(p) == 1);

    // 注册后存活
    qTrackObject(p);
    CHECK(qIsObjectAlive(p) == 1);

    // 对象析构 → destroyed 信号 → 置脏
    delete obj;
    CHECK(qIsObjectAlive(p) == 0);

    // null 恒为 0
    CHECK(qIsObjectAlive(0) == 0);

    // 注销后条目删除 → 重新按存活处理
    QObject* obj2 = new QObject();
    int64_t p2 = reinterpret_cast<int64_t>(obj2);
    qTrackObject(p2);
    CHECK(qIsObjectAlive(p2) == 1);
    qUntrackObject(p2);
    CHECK(qIsObjectAlive(p2) == 1);
    delete obj2;
}

// ---------------- 级联析构置脏 ----------------
static void testCascadeDestroy() {
    QObject* parent = new QObject();
    QObject* child = new QObject(parent);  // 父子关系，父销毁级联销毁子
    int64_t pp = reinterpret_cast<int64_t>(parent);
    int64_t cp = reinterpret_cast<int64_t>(child);

    qTrackObject(pp);
    qTrackObject(cp);
    CHECK(qIsObjectAlive(pp) == 1);
    CHECK(qIsObjectAlive(cp) == 1);

    // 删除父对象 → 子对象被级联析构，destroyed 信号把子条目置脏
    delete parent;
    CHECK(qIsObjectAlive(pp) == 0);
    CHECK(qIsObjectAlive(cp) == 0);
}

// ---------------- 并发注册 / 注销 ----------------
static void testConcurrentTrackUntrack() {
    std::atomic<bool> anyFail(false);
    std::vector<std::thread> threads;
    const int kThreads = 8;
    const int kObjsPerThread = 64;
    const int kIters = 200;

    for (int t = 0; t < kThreads; ++t) {
        threads.emplace_back([&anyFail]() {
            // 每个线程持有一批独立 QObject，全部操作（创建/注册/注销/析构）
            // 都在本线程内完成，避免 QObject 线程亲和性告警；
            // 全局 g_aliveObjs 表仍被 8 线程并发读写，考验 AliveSpinLock。
            std::vector<QObject*> objs;
            objs.reserve(kObjsPerThread);
            for (int i = 0; i < kObjsPerThread; ++i) {
                objs.push_back(new QObject());
            }
            for (int iter = 0; iter < kIters; ++iter) {
                for (QObject* o : objs) {
                    int64_t p = reinterpret_cast<int64_t>(o);
                    qTrackObject(p);
                    if (qIsObjectAlive(p) != 1) {
                        anyFail.store(true);
                    }
                    qUntrackObject(p);
                    if (qIsObjectAlive(p) != 1) {  // 注销后应按存活处理
                        anyFail.store(true);
                    }
                }
            }
            for (QObject* o : objs) {
                delete o;
            }
        });
    }
    for (auto& th : threads) {
        th.join();
    }
    CHECK(!anyFail.load());
}

int main() {
    RUN_SUITE(testStringUtils);
    RUN_SUITE(testAliveBasics);
    RUN_SUITE(testCascadeDestroy);
    RUN_SUITE(testConcurrentTrackUntrack);

    std::printf("bridge_core_test: %d checks, %d failed\n", g_checks, g_failed);
    return g_failed == 0 ? 0 : 1;
}
