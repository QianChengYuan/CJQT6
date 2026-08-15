# CJQT6测试常见问题（FAQ）

## 1. 测试运行相关

### Q1：如何运行所有测试？

```bash
cjpm test
```

### Q2：如何运行指定的测试？

本项目测试统一在 `src/test/`（package `cjqt6.test`），用 `--filter` 按名称通配符过滤：

```bash
cjpm test --filter "*Widget*"   # 过滤含 Widget 的测试类
cjpm test --filter "*Paint*"    # 过滤含 Paint 的测试类
```

### Q3：如何过滤运行特定的测试？

```bash
cjpm test --filter="QPushButton*"
```

### Q4：如何查看测试列表而不执行？

```bash
cjpm test --dry-run
```

### Q5：如何设置测试超时时间？

```bash
cjpm test --timeout-each=30s
```

---

## 2. GUI测试环境

### Q6：为什么widgets测试会崩溃？

**原因**：widgets测试需要QApplication实例，无GUI环境时会崩溃。

**解决方案**：添加GUI环境管理：
```cangjie
@BeforeAll
static func setupGUI(): Unit {
    let env = GUITestEnvironment.getInstance()
    env.setupEnvironment()
}

@AfterAll
static func teardownGUI(): Unit {
    let env = GUITestEnvironment.getInstance()
    env.teardownEnvironment()
}
```

### Q7：在Linux无GUI环境下如何运行测试？

使用xvfb-run：
```bash
xvfb-run cjpm test
```

### Q8：GUITestEnvironment可以重用吗？

可以，使用单例模式：
```cangjie
let env1 = GUITestEnvironment.getInstance()
let env2 = GUITestEnvironment.getInstance()
// env1 和 env2 是同一个实例
```

### Q9：多个测试类会创建多个QApplication吗？

不会，GUITestEnvironment使用引用计数，只在第一次setup时创建QApplication，最后一次teardown时销毁。

---

## 3. 测试编写

### Q10：如何测试异常？

使用`@ExpectThrows`：
```cangjie
@TestCase
func testException() {
    let widget = QWidget()
    widget.close()
    @ExpectThrows[ResourceDisposedException](widget.show())
}
```

### Q11：如何测试浮点数近似相等？

使用delta参数：
```cangjie
@Expect(3.14159, 3.14, delta: 0.01)
```

### Q12：@Assert和@Expect有什么区别？

- `@Assert`：快速失败，断言失败时立即停止测试
- `@Expect`：软失败，断言失败时记录错误但继续执行

### Q13：如何编写参数化测试？

使用`@Test[param in values]`：
```cangjie
@Test[value in [0, 50, 100]]
func testValues(value: Int32) {
    // value会依次取0、50、100
}
```

### Q14：如何使用生命周期方法？

```cangjie
@Test
class MyTests {
    @BeforeAll
    static func beforeAll() {
        // 所有测试前执行一次
    }
    
    @BeforeEach
    func beforeEach() {
        // 每个测试前执行
    }
    
    @AfterEach
    func afterEach() {
        // 每个测试后执行
    }
    
    @AfterAll
    static func afterAll() {
        // 所有测试后执行一次
    }
}
```

---

## 4. 资源管理

### Q15：测试中如何管理Qt对象生命周期？

每个测试用例结束时清理资源：
```cangjie
@TestCase
func testSomething() {
    let widget = QWidget()
    // ... 测试代码 ...
    widget.close()  // 或 widget.delete()
}
```

### Q16：忘记清理资源会怎样？

可能导致资源泄漏，影响后续测试或程序性能。

### Q17：close()和delete()有什么区别？

- `close()`：关闭窗口，释放底层Qt对象，但仓颉对象仍存在
- `delete()`：显式释放资源，效果与close()相同

建议：优先使用`close()`，语义更清晰。

### Q18：可以多次close()吗？

可以，多次close()是安全的：
```cangjie
widget.close()
widget.close()  // 安全，不会崩溃
```

---

## 5. 测试覆盖率

### Q19：如何生成覆盖率报告？

```bash
cjpm test --coverage
```

### Q20：覆盖率报告在哪里？

由 `cjpm test --coverage` 生成在 `target/` 下默认输出目录；可用 `cjcov` 进一步生成 HTML/XML/JSON 详细报告。

---

## 6. 性能相关

### Q21：测试运行很慢怎么办？

1. 使用并行执行：`cjpm test --parallel 4`
2. 检查是否有资源未释放
3. 使用`--filter`只运行相关测试

### Q22：单个测试应该多快完成？

建议单测试执行时间不超过30秒。

---

## 7. 调试相关

### Q23：如何查看测试详细输出？

测试失败时 `cjpm test` 默认输出失败用例的断言详情与堆栈。如需聚焦查看，用 `--filter` 缩小范围：

```bash
cjpm test --filter "*失败的测试名*"
```

### Q24：测试失败时如何调试？

1. 查看失败原因（cjpm 默认输出失败用例详情）
2. 用 `--filter` 只跑失败测试，查看完整输出
3. 添加打印语句定位问题

### Q25：如何跳过某些测试？

使用`@Skip`注解：
```cangjie
@Skip
@TestCase
func testSkipped() {
    // 此测试会被跳过
}
```

---

## 8. CI/CD集成

### Q26：如何在CI中运行测试？

**GitHub Actions示例**：
```yaml
- name: Run tests
  run: |
    cjpm test
```

**GitLab CI示例**：
```yaml
test:
  script:
    - cjpm test
```

### Q27：Linux CI无GUI怎么办？

使用xvfb：
```yaml
- name: Run tests
  run: |
    sudo apt-get install xvfb
    xvfb-run cjpm test
```

---

**文档版本**：1.0  
**更新日期**：2026-05-09  
**问题数量**：27个
