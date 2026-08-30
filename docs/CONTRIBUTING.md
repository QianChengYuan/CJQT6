# 贡献指南

感谢您对CJQT6项目的关注！欢迎参与贡献。

## 贡献方式

### 报告问题

如果您发现了Bug或有功能建议：

1. 在 [Issues](https://gitcode.com/yuan_1992/CJQT6/issues) 中搜索是否已有相关问题
2. 如果没有，创建新Issue并详细描述：
   - 问题描述
   - 复现步骤
   - 期望结果
   - 实际结果
   - 环境信息（仓颉版本、Qt版本、操作系统）

### 提交代码

1. **Fork项目**
   ```bash
   # 在GitCode上Fork项目
   git clone https://gitcode.com/your-username/CJQT6.git
   cd CJQT6
   ```

2. **创建分支**
   ```bash
   git checkout -b feature/your-feature-name
   # 或
   git checkout -b fix/your-bug-fix
   ```

3. **编写代码**
   - 遵循仓颉编码规范
   - 添加必要的注释
   - 更新相关文档

4. **测试**
   ```bash
   # 构建项目
   cjpm build
   
   # 运行测试
   cjpm test
   
    # 运行示例验证
    cd examples/all_controls_demo
    cjpm build
   ```

5. **提交更改**
   ```bash
   git add .
   git commit -m "feat: 添加新功能描述"
   # 或
   git commit -m "fix: 修复问题描述"
   ```

6. **推送到远程**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **创建Merge Request**
   - 在GitCode上创建MR
   - 描述您的更改
   - 等待审核

## 代码规范

### 仓颉代码

- 使用4空格缩进
- 类名使用大驼峰：`QPushButton`
- 函数名使用小驼峰：`setText()`
- 常量使用全大写：`MAX_SIZE`
- 添加必要的文档注释

### C++代码

- 遵循Qt编码风格
- 使用Qt智能指针管理内存
- 函数命名使用Qt风格：`qButtonCreate()`

## 文档规范

- 使用Markdown格式
- 保持文档与代码同步更新
- 添加示例代码
- 更新API文档

## 项目结构

```
CJQT6/
├── src/                # 仓颉源码
│   ├── core/          # 核心模块
│   ├── widgets/       # 控件模块
│   ├── gui/           # GUI模块
│   ├── test/          # 测试源码（package cjqt6.test）
│   └── ...
├── native/            # C++桥接代码
│   ├── src/
│   └── includes/
├── examples/          # 示例程序
├── docs/             # 文档
└── tests/            # 测试部署脚本
```

## 开发流程

### 添加新控件

> **先读 [封装新控件模板（P3-4）](../docs/guides/wrapper-template.md)**：五件套（桥接 .cpp + CMake 注册 + 仓颉类 + 测试 + docs/api）逐件照抄 QDial 范例即可 10 分钟出可编译控件。下面是简版流程。

1. 在 `native/src/widgets/` 添加C++桥接函数（`extern "C"` 导出 `qXxxCreate`/`qXxxDelete`）
2. 信号接线在 `native/src/core/bridge_signal.cpp` 添加 connect/disconnect（对照 QDial 段）
3. 把新 .cpp 加进根 `CMakeLists.txt` 相应模块 `SOURCES` 列表
4. 重编桥接库并同步 `releases/`（`.\scripts\update-bridge.ps1` 或 `bash scripts/build-linux-x64.sh`）
5. 在 `src/widgets/` 创建仓颉封装类（`QtResource` + `checkValid` + `close`，照抄同模块既有类）
6. `cjpm build` 验证，在 `src/test/` 补测试、在 `docs/api/` 补文档
7. 更新示例和 CHANGELOG

### 添加新模块

1. 创建模块目录 `src/newmodule/`
2. 添加包声明 `package cjqt6.newmodule`
3. 实现功能类
4. 更新文档

## 测试

### 单元测试

测试源码位于 `src/test/`（`package cjqt6.test`，41 个 `*_test.cj`），根目录 `cjpm test` 直接发现并运行全部用例。

```bash
cjpm test                          # 全部用例
cjpm test --filter "QPushButton*"  # 指定测试类
```

Windows 无显示环境（headless 基线）一键跑：

```bash
powershell -File tests\deploy_qt_test.ps1 -RunTest
```

Linux 无显示环境：`xvfb-run cjpm test`

### 手动测试

运行所有示例验证功能：

```bash
cd examples/all_controls_demo && cjpm build && cjpm run
cd examples/calculator && cjpm build && cjpm run
```

## 发布流程（维护者）

> 打 tag 前先跑语义化版本门禁（P3-2）校验 CHANGELOG 与版本一致性：

```powershell
.\scripts\check-release.ps1 -Version x.y.z
```

失败（退出码非 0）说明：CHANGELOG 还没有 `## [x.y.z]` 发布节、或 `[Unreleased]` 内容未转移，先补记录再发。

1. 更新版本号（cjpm.toml）
2. 更新CHANGELOG（从 `[Unreleased]` 转出 `## [x.y.z]`，含 新增/修复/文档 分类小节）
3. `powershell -File scripts\check-release.ps1 -Version x.y.z` 门禁通过
4. 构建并测试（`verify_all.ps1`）
5. 创建Git标签 `vx.y.z`（检查 tag 未重复）
6. 创建GitHub Release（附 `releases/` 预编译产物）

## 社区

- QQ群：1023882445
- Issues：https://gitcode.com/yuan_1992/CJQT6/issues

## 许可证

贡献的代码将采用MIT许可证。

---

再次感谢您的贡献！
