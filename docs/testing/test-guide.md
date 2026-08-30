# CJQT6测试运行指南

## 一、快速开始

### 1.1 运行所有测试

```bash
cd C:/CodeTools/cangjie_git/CJQT6
cjpm test
```

### 1.2 运行指定测试（按名称过滤）

本项目测试统一在 `src/test/`（package `cjqt6.test`），用 `--filter` 按测试类/方法名通配符过滤：

```bash
# 过滤含 Paint 的测试类
cjpm test --filter "*Paint*"

# 过滤含 Widget 的测试类
cjpm test --filter "*Widget*"

# 组合通配符：包含 + 排除
cjpm test --filter "*Test* -*Audio*"
```

### 1.3 查看测试列表

```bash
cjpm test --dry-run
```

---

## 二、测试环境配置

### 2.1 GUI测试环境

CJQT6使用`GUITestEnvironment`类自动管理GUI测试环境：

```cangjie
@Test
class MyWidgetTests {
    private static var guiEnv: ?GUITestEnvironment = None
    
    @BeforeAll
    static func setupGUI(): Unit {
        let env = GUITestEnvironment.getInstance()
        env.setupEnvironment()  // 创建QApplication实例
        guiEnv = Some(env)
    }
    
    @AfterAll
    static func teardownGUI(): Unit {
        if (let Some(env) <- guiEnv) {
            env.teardownEnvironment()  // 销毁QApplication实例
        }
    }
    
    @TestCase
    func testSomething() {
        // 测试代码，QApplication已就绪
    }
}
```

### 2.2 平台特定配置

**Windows**：
- 无需额外配置，GUI测试自动运行

**Linux**：
- 如无DISPLAY环境变量，建议使用xvfb-run：
  ```bash
  xvfb-run cjpm test
  ```

**macOS**：
- 无需额外配置，GUI测试自动运行

---

## 三、测试命令速查

| 命令 | 说明 |
|------|------|
| `cjpm test` | 运行所有测试 |
| `cjpm test --filter <pattern>` | 按测试类/方法名通配符过滤 |
| `cjpm test --parallel <N>` | 并行执行测试（N 为并行数） |
| `cjpm test --timeout-each=10s` | 设置单测试超时 |
| `cjpm test --dry-run` | 打印测试列表不执行 |
| `cjpm test --coverage` | 生成覆盖率信息 |

---

## 四、测试结果解读

### 4.1 成功输出

```
Summary: TOTAL: 1417
    PASSED: 1417, SKIPPED: 0, ERROR: 0
    FAILED: 0
```

> 注：用例总数随版本迭代持续增长，以上为近期统计（`@TestCase` 注解计数，参数化测试运行时可能更多）。

### 4.2 失败输出

```
[FAILED] CASE: testSomething
REASON: Expected 42, found 0
```

### 4.3 崩溃输出

```
[ERROR] CASE: testWidget
REASON: Crashed with exit code 3221227010
```

**常见崩溃原因**：
- 缺少QApplication实例（需要GUI环境）
- 资源已释放但仍被访问
- 空指针访问

---

## 五、测试覆盖率

### 5.1 生成覆盖率报告

```bash
cjpm test --coverage
```

### 5.2 查看覆盖率统计

覆盖率报告由 `cjpm test --coverage` 生成在 `target/` 下默认输出目录；可用 `cjcov` 进一步生成 HTML/XML/JSON 详细报告。

---

## 六、最佳实践

### 6.1 测试命名规范

- 测试类名：`<ClassName>Tests`（如`QPushButtonTests`）
- 测试方法名：`test<Feature>`（如`testCreate`、`testSetText`）

### 6.2 资源清理

每个测试用例后清理资源：

```cangjie
@TestCase
func testSomething() {
    let widget = QWidget()
    // ... 测试代码 ...
    widget.close()  // 或 widget.delete()
}
```

### 6.3 异常测试

使用`@ExpectThrows`验证异常：

```cangjie
@TestCase
func testOperationsAfterClose() {
    let widget = QWidget()
    widget.close()
    @ExpectThrows[ResourceDisposedException](widget.show())
}
```

---

## 七、故障排除

### Q1：测试崩溃，退出代码3221227010

**原因**：缺少QApplication实例  
**解决**：添加`GUITestEnvironment.setupEnvironment()`

### Q2：测试超时

**原因**：测试执行时间过长  
**解决**：使用`--timeout-each`增加超时时间

### Q3：找不到测试

**原因**：测试文件命名不符合规范  
**解决**：确保测试文件名为`*_test.cj`

---

**文档版本**：1.0  
**更新日期**：2026-05-09
