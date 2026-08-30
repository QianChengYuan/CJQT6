# CJQT6 许可证合规性分析

## 问题分析

**核心问题**：CJQT6采用MIT许可证，作为Qt6的封装库，是否对Qt6造成侵权风险？

## Qt6许可证情况

### Qt6许可证类型

Qt6采用双重许可模式：

1. **开源许可证**
   - **LGPL v3**：大多数模块（QtCore, QtGui, QtWidgets等）
   - **GPL v3**：部分模块（QtCharts, QtDataVisualization等）
   
2. **商业许可证**
   - 需要向The Qt Company购买
   - 允许闭源商业应用

### Qt6模块许可证分布

| 模块 | 许可证 | 说明 |
|------|--------|------|
| QtCore | LGPL v3 | 核心功能 |
| QtGui | LGPL v3 | GUI基础 |
| QtWidgets | LGPL v3 | 控件 |
| QtMultimedia | LGPL v3 | 多媒体 |
| QtQml | LGPL v3 | QML |
| QtSql | LGPL v3 | 数据库 |
| QtPrintSupport | LGPL v3 | 打印 |

> **注意**：CJQT6 使用的大多数模块为 LGPL v3；但 **QtCharts 模块为 GPL v3**，CJQT6 已封装 QtCharts（`src/charts/`），使用 charts 模块的应用需注意 GPL v3 的传染性要求（静态链接或整体开源）。仅使用 LGPL 模块（core/widgets/gui/dialogs/menu/paint/qml/multimedia/network/sql/views/print/resource）则不受 GPL 约束。

## MIT与LGPL v3兼容性

### 法律分析

**MIT许可证特点**：
- 极度宽松，几乎无限制
- 允许：商用、修改、分发、闭源
- 要求：保留版权声明和许可证文本

**LGPL v3许可证特点**：
- 允许动态链接而不感染主程序
- 修改LGPL库本身需要开源修改部分
- 必须提供库的源码或获取方式
- 必须允许用户替换LGPL库

### 兼容性判定

**✅ 合规的情况**：

1. **动态链接方式**
   - CJQT6通过动态链接库（DLL/SO）使用Qt6
   - LGPL v3明确允许动态链接而不要求主程序开源
   - 这是合规的使用方式

2. **封装层性质**
   - CJQT6是FFI桥接层，不是Qt6的衍生作品
   - 类似于语言绑定（如PyQt、PySide）
   - 未复制Qt6源代码，仅调用API

3. **MIT兼容LGPL**
   - MIT比LGPL更宽松
   - 用户可以使用MIT代码链接LGPL库
   - 最终用户的义务遵循LGPL

**⚠️ 需要注意的义务**：

1. **提供Qt6信息**
   - README中说明Qt6是LGPL v3许可
   - 提供Qt6源码下载链接或获取方式

2. **允许替换Qt6**
   - 用户必须能够替换Qt6库版本
   - 动态链接方式天然满足此要求

3. **版权声明**
   - 明确标注Qt6的版权和许可证
   - 保留Qt6的版权声明（在头文件中）

## 许可证合规建议

### 当前状态评估

**✅ 已满足的条件**：
- 动态链接方式（DLL/SO）
- 未修改Qt6源代码
- 仅调用Qt6 API

**⚠️ 需要补充的内容**：

### 建议修改

#### 1. 更新README.md

在许可证部分添加：

```markdown
## 许可证

### CJQT6代码
本项目采用MIT许可证，详见 [LICENSE](LICENSE) 文件。

### 依赖库
本项目依赖Qt6，Qt6采用LGPL v3许可证：
- Qt6版权所有：The Qt Company Ltd
- Qt6许可证：LGPL v3 或商业许可证
- Qt6源码：https://code.qt.io/cgit/qt/

用户有权利：
1. 自由使用、修改和分发本软件
2. 替换Qt6库为其他版本
3. 获取Qt6源码（按LGPL v3要求）

### 使用声明
- 本项目是Qt6的FFI封装层，通过动态链接使用Qt6
- 未修改Qt6源代码，仅调用Qt6公开API
- 本项目不归属Qt官方，由社区独立开发
```

#### 2. 添加NOTICE文件

创建 `NOTICE` 文件：

```
CJQT6 - Qt6 FFI Binding for Cangjie Language
Copyright (c) 2024 CJQT6 Team

This product includes software developed by third parties:

---
Qt6 Framework
Copyright (C) The Qt Company Ltd.
Licensed under LGPL v3 or commercial license.
https://www.qt.io/
---

This software is provided "as is", without warranty of any kind.
```

#### 3. 更新cjpm.toml

```toml
[package]
  name = "cjqt6"
  version = "1.9.0"
  license = "MIT"
```

> 注：`qt6` 版本与许可证约束不在 cjpm.toml 中声明（cjpm 无 `[requirements]` 段），Qt 版本与许可证由构建环境与 `docs/guides/qt-version-matrix.md` 约定。

### 法律合规性结论

**✅ 不构成侵权风险，但需要完善声明**

**理由**：
1. **动态链接**：符合LGPL v3要求
2. **API调用**：不构成衍生作品
3. **无修改**：未修改Qt6源代码
4. **宽松许可**：MIT允许用户遵守LGPL

**最佳实践**：
- 明确标注Qt6许可证
- 提供Qt6获取信息
- 允许用户替换Qt6
- 添加NOTICE文件

## 参考案例

类似项目的许可证选择：

| 项目 | 语言 | 许可证 | 合规方式 |
|------|------|--------|----------|
| PyQt | Python | GPL v3 | 要求商业应用购买许可 |
| PySide | Python | LGPL v3 | 由Qt官方维护 |
| QtJambi | Java | LGPL v3 | Java绑定 |
| Qt.py | Python | MIT | 统一接口层 |

**建议**：MIT许可证对CJQT6是合适的，因为：
- CJQT6是独立的封装层
- 动态链接符合LGPL要求
- 用户可以自由选择遵守MIT或LGPL义务

## 总结

### 风险评估

**法律风险**：**低**

- ✅ 动态链接方式合规
- ✅ 未修改Qt6源代码
- ✅ MIT与LGPL兼容
- ⚠️ 需要完善许可证声明

### 建议行动

1. **立即执行**：
   - 更新README添加Qt6许可证说明
   - 创建NOTICE文件
   - 标注Qt6版权

2. **长期维护**：
   - 关注Qt许可证变化
   - 避免使用GPL模块
   - 保持动态链接方式

### 结论

**MIT许可证合法且合适**，但需要：
- 明确标注Qt6及其许可证
- 提供Qt6源码获取方式
- 允许用户替换Qt6库

---

**免责声明**：本文档仅供参考，不构成法律意见。如有商业用途或法律疑虑，建议咨询专业律师。
