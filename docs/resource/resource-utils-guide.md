# CJQT6资源管理工具使用指南

## 一、快速开始

### 1.1 批量释放控件

**使用数组批量释放**：
```cangjie
import cjqt6.resource.*
import cjqt6.widgets.*

let btn1 = QPushButton()
let btn2 = QPushButton()
let btn3 = QPushButton()

// 批量释放所有控件
let result = ResourceUtils.releaseAll([btn1, btn2, btn3])
if (result.isAllSuccess()) {
    println("所有控件释放成功")
}
```

**使用便捷方法**：
```cangjie
let btn1 = QPushButton()
let btn2 = QPushButton()
let btn3 = QPushButton()

// 释放2-4个控件
ResourceUtils.releaseTwo(btn1, btn2)
ResourceUtils.releaseThree(btn1, btn2, btn3)
```

---

### 1.2 安全释放（处理可能为null的控件）

```cangjie
let btn1: ?QPushButton = Some(QPushButton())
let btn2: ?QPushButton = None
let btn3: ?QPushButton = Some(QPushButton())

// 安全释放，自动跳过None
let result = ResourceUtils.releaseSafe([btn1, btn2, btn3])
println("跳过: ${result.skippedCount}个")  // 输出: 跳过: 1个
```

---

## 二、ReleaseResult结果对象

```cangjie
public class ReleaseResult {
    public let totalCount: Int32      // 总数
    public let successCount: Int32    // 成功数
    public let failedCount: Int32     // 失败数
    public let skippedCount: Int32    // 跳过数
    public let elapsedTime: Int64     // 耗时（毫秒）
    
    public func isAllSuccess(): Bool  // 是否全部成功
    public func hasFailure(): Bool    // 是否有失败
    public func successRate(): Int32  // 成功率（0-100）
}
```

---

## 二·补、ResourceUtils API 参考

### 静态方法

| 方法 | 说明 |
|------|------|
| `releaseAll(widgets: Array<QtResource>): ReleaseResult` | 批量释放数组中的所有控件，已关闭的自动跳过，失败计数 |
| `releaseSafe(widgets: Array<?QtResource>): ReleaseResult` | 安全释放 Option 类型控件数组，None 值跳过并计入 skipped |
| `releaseTwo(w1: QtResource, w2: QtResource): ReleaseResult` | 释放两个控件（免数组开销） |
| `releaseThree(w1: QtResource, w2: QtResource, w3: QtResource): ReleaseResult` | 释放三个控件 |
| `releaseFour(w1: QtResource, w2: QtResource, w3: QtResource, w4: QtResource): ReleaseResult` | 释放四个控件 |

### 注意事项

- `releaseAll` / `releaseSafe` 遍历过程中单个控件释放失败会捕获异常并计入 `failedCount`，不会中断后续控件释放。
- 释放结果通过返回的 `ReleaseResult` 统计，`isAllSuccess()` 等价于 `failedCount == 0`。

---

## 三、完整示例

### 示例1：批量创建和释放按钮

```cangjie
import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.resource.*

main() {
    let app = QApplication()
    
    // 批量创建10个按钮
    var buttons: Array<QPushButton> = []
    for (i in 0..10) {
        let btn = QPushButton()
        btn.setText("Button ${i}")
        buttons = buttons.concat([btn])
    }
    
    // 使用按钮...
    
    // 批量释放所有按钮
    let result = ResourceUtils.releaseAll(buttons)
    println("释放结果: 成功${result.successCount}个, 跳过${result.skippedCount}个")
    
    app.delete()
}
```

---

### 示例2：混合控件批量释放

```cangjie
import cjqt6.resource.*
import cjqt6.widgets.*

func createUI(): Array<QtResource> {
    let btn = QPushButton()
    let label = QLabel()
    let edit = QLineEdit()
    
    return [btn, label, edit]
}

main() {
    let widgets = createUI()
    
    // 使用控件...
    
    // 批量释放
    ResourceUtils.releaseAll(widgets)
}
```

---

### 示例3：条件释放

```cangjie
import cjqt6.resource.*
import cjqt6.widgets.*

main() {
    let btn1 = QPushButton()
    let btn2 = QPushButton()
    let btn3 = QPushButton()
    
    btn2.close()  // 提前关闭btn2
    
    // 批量释放，自动跳过已关闭的btn2
    let result = ResourceUtils.releaseAll([btn1, btn2, btn3])
    // result.successCount = 2 (btn1, btn3)
    // result.skippedCount = 1 (btn2)
}
```

---

## 四、最佳实践

### 4.1 及时释放资源

```cangjie
// ❌ 不推荐：忘记释放
let btn = QPushButton()
// 使用btn...
// 忘记调用btn.close()

// ✅ 推荐：批量释放
let btn1 = QPushButton()
let btn2 = QPushButton()
// 使用控件...
ResourceUtils.releaseTwo(btn1, btn2)
```

---

### 4.2 使用数组管理相关控件

```cangjie
// ✅ 推荐：将相关控件放在数组中统一管理
var formWidgets: Array<QtResource> = []
formWidgets = formWidgets.concat([nameEdit])
formWidgets = formWidgets.concat([emailEdit])
formWidgets = formWidgets.concat([submitBtn])

// 窗口关闭时批量释放
ResourceUtils.releaseAll(formWidgets)
```

---

### 4.3 处理释放失败

```cangjie
let result = ResourceUtils.releaseAll(widgets)

if (result.hasFailure()) {
    println("警告: ${result.failedCount}个控件释放失败")
    // 记录日志或进行其他处理
}
```

---

## 五、对比：手动vs批量释放

### 手动释放（繁琐）

```cangjie
let btn1 = QPushButton()
let btn2 = QPushButton()
let btn3 = QPushButton()
let btn4 = QPushButton()
let btn5 = QPushButton()

// 使用控件...

btn1.close()
btn2.close()
btn3.close()
btn4.close()
btn5.close()
```

### 批量释放（简洁）

```cangjie
let btn1 = QPushButton()
let btn2 = QPushButton()
let btn3 = QPushButton()
let btn4 = QPushButton()
let btn5 = QPushButton()

// 使用控件...

ResourceUtils.releaseAll([btn1, btn2, btn3, btn4, btn5])
```

---

**文档版本**：1.0  
**更新日期**：2026-05-09
