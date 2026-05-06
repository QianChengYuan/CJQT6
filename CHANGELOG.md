# 更新日志

所有重要的变更都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
并遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [1.0.0] - 2026-05-07

### 新增
- 首次发布到仓颉中心仓
- 支持 Linux x86_64、Windows x86_64、macOS x86_64/arm64 多平台
- 实现核心 Qt6 控件封装
  - QApplication、QWidget、QPushButton、QLabel
  - QVBoxLayout、QHBoxLayout
  - QString、QSize、QPoint
- 实现 Qt6 信号槽机制
- 提供完整的安装和验证脚本
- 提供平台自动检测功能
- 提供 Qt6 依赖检测功能
- CI/CD 多平台自动化构建流水线

### 文档
- 安装指南 (docs/installation.md)
- 快速开始教程 (docs/quick-start.md)
- 平台支持矩阵
- API 参考文档（部分）

### 示例
- hello_window: 最简单的窗口示例

### 已知问题
- Linux arm64 平台尚未完全测试
- 部分 Qt6 模块尚未封装 (QtNetwork, QtXml 等)
- 文档仍在完善中

## [未发布]

### 计划新增
- 更多 Qt6 控件封装
  - QLineEdit 文本输入框
  - QComboBox 下拉框
  - QTableView 表格视图
  - QTreeView 树形视图
- Qt6 多媒体模块 (QtMultimedia)
- Qt6 数据库模块 (QtSql)
- 更多示例程序
  - 计算器应用
  - 记事本应用
  - 控件演示

### 计划改进
- 优化 FFI 调用性能
- 完善错误处理机制
- 提供更多中英文档
- 支持更多 Qt6 版本

---

## 版本说明

- **主版本号 (MAJOR)**: 不兼容的 API 变更
- **次版本号 (MINOR)**: 向后兼容的功能新增
- **修订号 (PATCH)**: 向后兼容的问题修复
