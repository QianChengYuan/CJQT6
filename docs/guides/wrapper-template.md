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
/// 注意：控件类请实现 **QtWidget**（而非 QtResource）——样式 / 尺寸 / 可见性 / 启用态 /
/// 尺寸查询等 11 个通用能力由该接口默认实现提供，无需自行编码，也无需自行声明 qWidget* FFI。
/// 若控件尚未接入 QtResource 基础设施（无 close/isValid/checkValid），实现 **QtWidgetCore**
/// 即可（只要求提供 getPtr()）；非控件的资源类（如 QMyPlayer）才直接实现 QtResource。
/// 三者关系：`QtWidget <: QtResource & QtWidgetCore`、`QtWidgetCore` 只要求 `getPtr()`。
public class QMyControl <: QtWidget {
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

跑测试：根目录 `cjpm build` 后 `cjpm test`（Windows 无显示环境用 `.\scripts\deploy-qt-test.ps1 -RunTest`，Linux 用 `xvfb-run cjpm test`）。

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

## 附：跨包调用与语义约定（易误用点）

> 来源：`docs/internal/cjmonitor-findings.md`（P2-1 / P2-4 / P2-5）。这些是「能跑但极易写错」的点，新增封装时请一并遵守。

### 1. 常量取整写法已统一为 `.value`（无括号）

| 类型 | 定义形态 | 取整数写法 | 示例 |
|------|----------|------------|------|
| `RenderHint` / `PenStyle` / `BrushStyle` / `ImageFormat` / `Orientation` | **enum**，取整成员为**只读属性** `prop value: Int32` | **`.value`（无括号）** | `painter.setRenderHint(RenderHint.Antialiasing.value)` |
| `TextAlignment` | **struct**，`public let value: Int32` | `.value`（无括号） | `painter.drawTextRect(..., TextAlignment.Left.value)` |
| `Alignment`（布局） | **struct**，`public let value: Int32` | `.value`（无括号） | `layout.addWidget(ptr, stretch, Alignment.Left.value)` |

**统一结论（2026-09-19，findings P2-1 闭环）**：5 个存量 enum 的 `func value(): Int32` 已改为只读属性 `prop value: Int32`，与 struct 的 `let value` 写法一致——**取整一律写 `.value`，不再带括号**，无需再按类型区分。

- 新增常量类两种形态皆可：enum 用 `public prop value: Int32 { get() { … } }`，struct 用 `public let value: Int32`；只要取整的对外写法都是 `.value` 即可。
- **破坏性变更**：同一类型内同名 `func value()` 与 `prop value` 不能共存（编译器报 `redefinition of declaration 'value'`），故**不存在过渡别名**，既有 `.value()` 调用必须去括号（迁移说明见 `docs/CHANGELOG.md`）。
- 不受影响：控件 / SQL 等**非取整**的 `.value()` 保持原样（如 `QSpinBox.value()`、`QSqlQuery.valueString`）。

### 2. 同名同义对照表（同名不可得时以此为准）

| 需求 | CJQT6 真实写法 | 常见误写 |
|------|----------------|----------|
| 全局样式表 | `QApp.setStyleSheet(String)` | `QApplication.setStyleSheet(...)` |
| 窗口标题 | `setWindowTitle(String)` 与 `setTitle(String)` 等价（前者为 Qt 惯用名，二者可互换）；`QChart` / `QGroupBox` / `QMenu` / `QMenuBar` 的标题方法名本就是 `setTitle` | 建议统一用 `setWindowTitle` |
| 布局/容器收控件 | 优选用新增的 `QtResource` 重载（`layout.addWidget(widget)`、`tabs.addTab(widget, title)`、`win.setCentralWidget(widget)`），编译期即可拦住类型误配 | 传裸 `widget.getPtr()` |
| 取窗口菜单/状态栏 | 无 getter，只能 `setMenuBar(ptr)` / `setStatusBar(ptr)` | `menuBar()` / `statusBar()` |
| 颜色构造 | `QColor(Int32,Int32,Int32)` / `QColor.rgba(r,g,b,a)` | `QColor.rgb(...)` |
| 矩形填充 | `fillRectColor(x,y,w,h,c)` / `setBrush(QBrush)` | `setBrushColor(...)` |
| 网格跨行列 | `QGridLayout.addWidgetSpan(ptr,r,c,rowSpan,colSpan)` | `addWidget(ptr,r,c,rs,cs)` |
| 打印常量 | `OutputFormat.pdfFormat()` / `PageSize.a4()` / `PageOrientation.landscape()` | `PrintFormat` / `Orientation` |
| SQL 绑定 | 命名占位符 `:x` 用 `bindValue` / `bindValueInt` / `bindValueDouble`；位置占位符 `?` 用 `addBindValue` / `addBindValueInt` / `addBindValueDouble` | 混用两种占位符风格 |
| SQL 取值 | `valueString` / `valueInt` / `valueDouble(Int32)` | `value(...)` |
| SQL 事务 | `QSqlDatabase.transaction()` / `commit()` / `rollback()`（返回 `Bool`） | 手工 `exec("BEGIN")` / `exec("COMMIT")` |
| 本地音频 | `QSoundEffect.setSourceFile(path)` | `setSource("qrc:/...")` |
| 本地图标 | `QIcon(filename)` 构造 | `QIcon.fromFile(...)` |
| 表格填值 | `setItem(row,col,text)` / `item(r,c).setText(...)` | `setItemText(...)` |
| 表格表头 | `setColumnWidth` / `setHorizontalHeaderStretchLastSection` | `horizontalHeader()` |
| 控件显隐 | 79 个已采纳控件类统一具备 `setVisible(Bool)` / `isVisible()`（由 `QtWidget` 提供）；未采纳的非控件类型只能 `show()` / `hide()` | 已无此坑，可直接调 `setVisible` |
| 定宽/定高 | 只有 `setMinimumSize(Int32,Int32)` / `setMaximumSize` / `setFixedSize` | `setMinimumWidth` / `setFixedWidth` |
| 时间戳换算 | `QDateTime.toSecsSinceEpoch()` / `QDateTime.fromSecsSinceEpoch(secs)`；`QDateTimeAxis` 另有 `setMin(QDateTime)` / `setMax(QDateTime)` 重载 | `toMSecsSinceEpoch()`（不存在） |
| 子进程参数 | 逐个追加用 `QProcess.addArgument(arg)`（含空格路径安全）；`setArguments(String)` 按**空格切分** | 用 `setArguments` 传含空格路径 |
| 折线样式 | `QLineSeries.setColor(r,g,b[,a])` / `setPen(QPen)` / `clear()` | 依赖 `setName` 后重建图表 |
| 对象样式定位 | `setObjectName(String)`（QWidget / QEventWidget）或 `cjqt6.core.setWidgetObjectName(ptr, name)`（任意控件指针） | 以为 QSS `#id` 不可用 |
| 序列多态 | `QChart.addSeries` 只按具体序列类型重载 | `addSeries(series.getPtr())` 通用调用 |

### 3. 所有权与释放责任（必须写进新类的注释）

| 场景 | 规则 |
|------|------|
| 自建 QObject 封装 | `init` 内 `trackObject(ptr)`；`close()` 先判 `isObjectAlive(ptr)` |
| 被父容器接管（`chart.addSeries` / `view.setChart` / 布局 `addWidget` 等） | **只 untrack，不 delete**，交由父对象级联释放 |
| `QPainter.fromPtr(ptr)` | **借用**包装（`owned=false`），其 `close()` 是**空操作**，不构成泄漏源 |
| `QPainter()` / `QPainter(device)` | **自建**（`owned=true`），**必须 `close()`**，且 `close()` 后不可复用该实例 |
| `QEventWidget.close()` | 先 `clearAllCallbacks()` 再删底层对象（幂等） |
| `QProcess` 退出 | 先 `kill()` 再 `close()`，防僵尸进程 |

**回调体内禁止释放所属对象（P1-5）**：`setOnXxxCapture` / `setOnXxx` 的回调体内**不要**调用 `close()`、`SignalConnection.disconnect()`，也不要删除该回调所属的 QTimer/QObject——否则正在派发的事件源会在自己的回调中途被销毁。正确分工是：**回调内只更新状态**，释放由**回调之外**的 `close()` 统一负责（范式见 `src/richwidgets/toast.cj` 的 `handleTimeout()` 与 `release()`）。

**GUI 对象必须在 `QApplication` 所属线程操作（P1-5，已用 native 栈坐实）**：Qt 要求控件的创建、显示、销毁都在 app 所属线程执行，**顶层窗口**（无父的 `QWidget` / `QLabel` / 对话框）尤其严格。在其它线程销毁一个**已显示**的顶层控件，会阻塞在

```text
QWidget::~QWidget() → QWindow::close()
   → QWindowSystemInterface::flushWindowSystemEvents() → QWaitCondition::wait()
```

上：该等待需要 app 线程处理事件才会被唤醒；若 app 线程此刻没在跑事件循环（后台线程、测试框架的 adopted worker 线程都属于这种情况）就**永久挂起（CPU 0%，不会自愈）**。

- 库侧已提供快速失败入口：`cjqt6.core.isGuiThread()` / `checkGuiThread(op)`，违规抛 `GuiThreadViolationException`；`Toast.show()` 与「已显示实例的 `close()`」已接入守卫（`/// throws:` 已标注）。
- 应用侧：GUI 操作一律回到主线程（事件循环线程），不要从后台线程 `show()` / `close()` 窗口。
- 测试侧：涉及顶层窗口或 `exec()` 的用例应在**用例内/`@BeforeEach`** 建 `QApplication`，且不要与其它线程混跑（`GUITestEnvironment` 只在 `@BeforeAll` 建 app，会把 app 钉在首个线程上）。

### 4. 自绘控件（`QEventWidget`）可用能力

`QEventWidget` 已与 `QWidget` 对齐下列通用能力，自绘时**不需要**再自行声明 `foreign func`：

`setStyleSheet` / `styleSheet` / `setObjectName` / `setMinimumSize` / `setMaximumSize` / `setVisible` / `isVisible` / `setEnabled` / `isEnabled` / `width` / `height` / `show` / `hide` / `setTitle` / `resize` / `setGeometry` / `setLayout` / `update` / `setFocus`，外加鼠标 / 键盘 / 绘制回调。

需要**任意指针**（非 `QEventWidget` 实例）的尺寸或 objectName 时，用 `cjqt6.core.widgetWidth(ptr)` / `widgetHeight(ptr)` / `setWidgetObjectName(ptr, name)`。

### 5. 轻提示（`Toast`）的两类入口

```cangjie
import cjqt6.richwidgets.*

Toast.info("采集已启动")                              // 静态便捷入口
Toast.warning("CPU 超阈值", durationMs: 3000)
Toast.showThrottled("磁盘 IO 超阈值", windowMs: 5000)  // 同内容窗口内只弹一次
```

> `Toast` 实例入口（`Toast(msg, durationMs)` + `show()`）仍可用；静态入口内部持有最近一条并负责替换。

---

## 验证清单（完成前逐项打勾）

- [ ] `update-bridge.ps1` / `build-linux-x64.sh` 成功且产物进 `releases/<platform>/`
- [ ] `cjpm build` 通过（含新类）
- [ ] `cjpm test` 新增用例全绿 + 全量无回归
- [ ] `docs/api/` 新控件有章节
- [ ] `docs/CHANGELOG.md` 记一条（`[Unreleased]` 段）
- [ ] 中文注释 + 类大驼峰 / 函数小驼峰 / 桥接 `qXxx` 命名