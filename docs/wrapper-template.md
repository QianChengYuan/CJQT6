# 封装新控件模板（P3-4）

> 目标：按本模板 10 分钟内出一个可编译的控件 —— 对照真实范例 **QDial**（`src/widgets/dial.cj` + `native/src/widgets/bridge_values.cpp` + `native/src/core/bridge_signal.cpp`）逐件复制即可，下面的「占位符」用的是 `MyControl`（可整体替换成你的控件名，统一用大驼峰）。

## 五件套清单

封装一个控件需动 **5 类文件**，顺序如下（不可颠倒，改桥接必须重编）：

| 件 | 文件 | 内容 |
|----|------|------|
| ① | `native/src/<模块>/bridge_xxx.cpp` | `extern "C"` 导出 `qMyControl*` 函数（含 `qMyControlCreate` / `qMyControlDelete`） |
| ② | 根 `CMakeLists.txt` | 新 .cpp 加入对应模块 `SOURCES` 列表；信号接线加入 `native/src/core/bridge_signal.cpp`（该文件已在 core SOURCES，无需改 CMake） |
| ③ | `src/<模块>/mycontrol.cj` | 仓颉封装 class：`QtResource` + `foreign func` + `checkValid` + `close` |
| ④ | `src/test/xxx_test.cj` | `@Test` 类：建/设/取/close 后 `@ExpectThrows[ResourceDisposedException]` |
| ⑤ | `docs/api/0X_xxx.md` | 章节：示例 + 方法表 |

> 注：现存 `native/includes/*.h` 大多是旧式 `cjfw::` 包装类声明，**新控件不强制加头文件声明**——桥接函数直接写进 .cpp 的 `extern "C" { }` 块（见 `bridge_values.cpp:28`），仓颉侧用 `foreign func` 声明同名符号即可链接。只有需要自定义类（如带 Qt 信号槽的 MOC 类）才动 `gui.h`/`widgets.h`/`signalemitter.h`。

---

## ① 桥接 .cpp（`native/src/widgets/bridge_mycontrol.cpp`）

```cpp
/**
 * @file bridge_mycontrol.cpp
 * @brief MyControl 桥接函数（P3-4 模板，对照 bridge_values.cpp 的 QDial 段）
 */

#include <QMyControl>          // Qt 头文件
#include "bridge_string_utils.h"

extern "C" {

// ============================================================
// MyControl 桥接函数
// ============================================================

int64_t qMyControlCreate() {
    QMyControl* w = new QMyControl();
    return reinterpret_cast<int64_t>(w);
}

void qMyControlSetSomething(int64_t ptr, int32_t value) {
    QMyControl* w = reinterpret_cast<QMyControl*>(ptr);
    if (w) { w->setSomething(value); }
}

int32_t qMyControlSomething(int64_t ptr) {
    QMyControl* w = reinterpret_cast<QMyControl*>(ptr);
    return w ? w->something() : 0;
}

// 字符串参数：CString → QString（对照 qWidgetSetStyleSheet 的写法）
void qMyControlSetLabel(int64_t ptr, const char* text) {
    QMyControl* w = reinterpret_cast<QMyControl*>(ptr);
    if (w && text) { w->setLabel(QString::fromUtf8(text)); }
}

void qMyControlDelete(int64_t ptr) {
    QMyControl* w = reinterpret_cast<QMyControl*>(ptr);
    if (w) { delete w; }
}

} // extern "C"
```

**信号接线放 `native/src/core/bridge_signal.cpp`**（不自建文件），照抄 QDial 段（`bridge_signal.cpp:395`）：

```cpp
// MyControl 信号
void qMyControlConnectValueChanged(int64_t ptr, void (*callback)(int32_t)) {
    QMyControl* w = reinterpret_cast<QMyControl*>(ptr);
    if (w && callback) {
        ConnKey key{ptr, SIG_MYCTRL_VAL};          // 在枚举/宏处新增 SIG_MYCTRL_VAL（对照 SIG_DIAL_VAL）
        disconnectByKey(key);
        LOCK_CALLBACKS();
        g_int32Cbs[key] = callback;                // 按信号参数类型选用 g_xxxCbs 表
        g_conns[key] = QObject::connect(w, &QMyControl::valueChanged, [key](int v) {
            std::function<void(int32_t)> cb;
            { LOCK_CALLBACKS(); auto i = g_int32Cbs.find(key); if (i != g_int32Cbs.end()) cb = i->second; }
            if (cb) { try { cb(static_cast<int32_t>(v)); } catch (...) {} }
        });
    }
}
void qMyControlDisconnectValueChanged(int64_t ptr) {
    disconnectByKey(ConnKey{ptr, SIG_MYCTRL_VAL});
}
```

## ② CMakeLists.txt 注册

根 `CMakeLists.txt` 的 `widgets` SOURCES 列表加一行（参照 `bridge_values.cpp`）：

```cmake
native/src/widgets/bridge_mycontrol.cpp
```

重编并部署桥接库（必做，改 C++ 后行为不变通常是没重编）：

- Windows：`.\scripts\update-bridge.ps1`
- Linux：`bash scripts/build-linux-x64.sh`

## ③ 仓颉封装（`src/widgets/mycontrol.cj`）

对照 `src/widgets/dial.cj` 完整结构，**基础设施（ptr/closed/getPtr/isClosed/isValid/checkValid/close/delete）一字不差照抄**，只换类名与错误文案：

```cangjie
package cjqt6.widgets

import cjqt6.core.*

// MyControl - 我的控件
foreign func qMyControlCreate(): Int64
foreign func qMyControlSetSomething(ptr: Int64, value: Int32): Unit
foreign func qMyControlSomething(ptr: Int64): Int32
foreign func qMyControlSetLabel(ptr: Int64, text: CString): Unit
foreign func qMyControlDelete(ptr: Int64): Unit
foreign func qMyControlConnectValueChanged(ptr: Int64, callback: Int32Callback): Unit
foreign func qMyControlDisconnectValueChanged(ptr: Int64): Unit

/// 我的控件
/// 支持资源管理，可使用 try-with-resources 自动释放
public class QMyControl <: QtResource {
    private var ptr: Int64 = 0
    private var closed: Bool = false

    public init() {
        unsafe {
            ptr = qMyControlCreate()
        }
        trackObject(ptr)
    }

    public func setSomething(value: Int32) {
        checkValid()          // 普通方法必须首行守卫（reverse_invalidation 依赖）
        unsafe {
            qMyControlSetSomething(ptr, value)
        }
    }

    public func something(): Int32 {
        checkValid()
        unsafe {
            return qMyControlSomething(ptr)
        }
    }

    public func setLabel(text: String) {
        checkValid()
        unsafe {
            let cstr = LibC.mallocCString(text)   // 字符串过 FFI 必须 malloc + toString 后 free
            qMyControlSetLabel(ptr, cstr)
            LibC.free(cstr)
        }
    }

    public func setOnValueChanged(callback: Int32Callback) {
        checkValid()
        unsafe {
            qMyControlConnectValueChanged(ptr, callback)
        }
    }

    public func disconnectValueChanged() {
        if (ptr != 0) {                            // disconnect* 刻意不守卫
            unsafe { qMyControlDisconnectValueChanged(ptr) }
        }
    }

    public func disconnect(): Unit { disconnectValueChanged() }

    // ---- 以下基础设施照抄 QDial，只换名字 ----
    public func getPtr(): Int64 { return ptr }
    public func isClosed(): Bool { return closed }
    public func isValid(): Bool { return !closed && ptr != 0 && isObjectAlive(ptr) }
    public func checkValid(): Unit {
        if (closed) { throw ResourceDisposedException("QMyControl 已经被释放") }
        if (ptr == 0) { throw NullPointerException("QMyControl 指针为空") }
        if (!isObjectAlive(ptr)) { throw ResourceDisposedException("QMyControl 底层 Qt 对象已失效") }
    }
    public func close(): Unit {
        if (!closed && ptr != 0) {
            if (!isObjectAlive(ptr)) { untrackObject(ptr); ptr = 0; closed = true; return }
            untrackObject(ptr)
            unsafe {
                qSignalCleanup(ptr)
                qMyControlDelete(ptr)
            }
            closed = true
            ptr = 0
        }
    }
    public func delete(): Unit { close() }
    // 终结器 ~init 保持禁用（GC 时机不确定），只留注释
}
```

**硬约束**（违反会踩坑，见 AGENTS.md）：
- 所有 `foreign func` 调用包在 `unsafe { }` 内；字符串必须 `LibC.mallocCString` + 立即 `toString` + `LibC.free`；
- `close()`/`delete()`/`disconnectXxx()` **不能加 `checkValid()`**；
- 回调用 CFunc 不捕获局部变量；需要捕获时用 `setOnXxxCapture` + `registerVoidCallback` 模式（先加载 `src/core/callback.cj` 看）；
- 布局 `addWidget`/`addLayout` 收 `Int64` 原生指针（`xxx.getPtr()`）。

## ④ 测试（`src/test/mycontrol_test.cj`）

对照 `src/test/widgets_extended_test.cj` 的 `QDialTests`（L648）：

```cangjie
package cjqt6.test

import cjqt6.widgets.*
import cjqt6.core.*
import std.unittest.*

@Test
class QMyControlTests {
    private static var guiEnv: ?GUITestEnvironment = None

    @BeforeAll
    static func setupGUI(): Unit {
        let env = GUITestEnvironment.getInstance()
        env.setupEnvironment()
        guiEnv = Some(env)
    }

    @AfterAll
    static func teardownGUI(): Unit {
        if (let Some(env) <- guiEnv) {
            env.teardownEnvironment()
        }
    }

    @TestCase
    func testCreate() {
        let w = QMyControl()
        @Expect(w.getPtr() != 0, true)
        w.delete()
    }

    @TestCase
    func testSetSomething() {
        let w = QMyControl()
        w.setSomething(42)
        @Expect(w.something(), 42)
        let _ = w.getPtr()
        w.delete()
    }

    @TestCase
    func testInvalidAfterClose() {          // 基础设施回归：close 后必须抛
        let w = QMyControl()
        let p = w.getPtr()
        @Assert(p != 0)
        w.close()
        @Expect(w.isClosed(), true)
        @ExpectThrows[ResourceDisposedException](w.setSomething(1))
    }
}
```

跑测试：根目录 `cjpm build` 后 `cjpm test`（Windows 无显示环境用 `.\tests\deploy_qt_test.ps1 -RunTest`，Linux 用 `xvfb-run cjpm test`）。

## ⑤ docs/api 章节

在 `docs/api/` 对应模块文件（如 `03_widgets_selection.md`）新增，照抄 QDial 段结构（示例 + 方法表）：

`### QMyControl - 我的控件` + 一句话说明用途，然后：

```cangjie
import cjqt6.widgets.*

let w = QMyControl()
w.setSomething(42)
w.setOnValueChanged({ value: Int32 => println(value) })
```

**方法**:
| 方法 | 说明 |
|------|------|
| `setSomething(value: Int32)` / `something(): Int32` | 设置/获取 |
| `setLabel(text: String)` | 设置文本 |
| `setOnValueChanged(callback: Int32Callback)` | 值变化回调 |
| `disconnectValueChanged()` / `disconnect()` | 断开信号 |
| `getPtr(): Int64` / `close()` / `delete()` | 指针与资源释放 |

---

## 验证清单（完成前逐项打勾）

- [ ] `update-bridge.ps1` / `build-linux-x64.sh` 成功且产物进 `releases/<platform>/`
- [ ] `cjpm build` 通过（含新类）
- [ ] `cjpm test` 新增用例全绿 + 全量无回归
- [ ] `docs/api/` 新控件有章节
- [ ] `docs/CHANGELOG.md` 记一条（`[Unreleased]` 段）
- [ ] 中文注释 + 类大驼峰 / 函数小驼峰 / 桥接 `qXxx` 命名