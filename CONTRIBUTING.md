# 贡献指南

感谢您对CJQT6项目的关注！欢迎参与贡献。

## 贡献方式

### 报告问题

如果您发现了Bug或有功能建议：

1. 在 [Issues](https://gitcode.com/yuan_1992/CJQT6/-/issues) 中搜索是否已有相关问题
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
   cd examples/widgets_demo
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
│   └── ...
├── native/            # C++桥接代码
│   ├── src/
│   └── includes/
├── examples/          # 示例程序
├── doc/              # 文档
└── tests/            # 测试
```

## 开发流程

### 添加新控件

1. 在 `native/src/widgets/` 添加C++桥接函数
2. 在 `native/includes/widgets.h` 声明函数
3. 在 `src/widgets/` 创建仓颉封装类
4. 更新 `CMakeLists.txt`
5. 添加示例和文档

### 添加新模块

1. 创建模块目录 `src/newmodule/`
2. 添加包声明 `package cjqt6.newmodule`
3. 实现功能类
4. 更新文档

## 测试

### 单元测试

```bash
cjpm test
```

### 手动测试

运行所有示例验证功能：

```bash
cd examples/widgets_demo && cjpm build && cjpm run
cd examples/calculator && cjpm build && cjpm run
```

## 发布流程（维护者）

1. 更新版本号（cjpm.toml）
2. 更新CHANGELOG
3. 构建并测试
4. 打包：`cjpm bundle`
5. 发布到中心仓：`cjpm publish`
6. 创建Git标签
7. 创建GitHub Release

## 社区

- QQ群：1023882445
- Issues：https://gitcode.com/yuan_1992/CJQT6/-/issues

## 许可证

贡献的代码将采用MIT许可证。

---

再次感谢您的贡献！
