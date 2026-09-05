#!/usr/bin/env bash
# CJQT6 项目脚手架 —— 快速创建 CJQT6 应用骨架
# 用法: bash scripts/new-qt6-project.sh myapp
#       bash scripts/new-qt6-project.sh myapp ./projects
# 对应 roadmap 9.5：cjqt6-cli 脚手架（cjpm init --template qt6 等价物）

set -euo pipefail

NAME="${1:?用法: new-qt6-project.sh <项目名> [路径]}"
BASE_PATH="${2:-.}"
PROJECT_DIR="$BASE_PATH/$NAME"

if [ -d "$PROJECT_DIR" ]; then
    echo "❌ 目录已存在: $PROJECT_DIR"
    exit 1
fi

# 创建目录结构
mkdir -p "$PROJECT_DIR/src"

# 生成 cjpm.toml
cat > "$PROJECT_DIR/cjpm.toml" << EOF
[package]
  cjc-version = "1.1.0"
  name = "$NAME"
  description = "CJQT6 应用 - $NAME"
  version = "1.0.0"
  target-dir = ""
  output-type = "executable"
  compile-option = ""
  override-compile-option = ""
  # link-option 需指向 CJQT6 桥接库；设置 CJQT6_ROOT 环境变量指向 CJQT6 仓库根目录
  link-option = "-L\${CJQT6_ROOT}/releases/linux-x64 -lcjqt6_bridge"
  package-configuration = {}

[dependencies]
  # 方式一：git 依赖（推荐，发布时用）
  cjqt6 = { git = "https://gitcode.com/Cangjie-TPC/CJQT6.git", tag = "v1.9.0" }
  # 方式二：本地路径依赖（开发调试时用，取消注释并调整路径）
  # cjqt6 = { path = "../CJQT6" }
EOF

# 生成 src/main.cj 骨架
cat > "$PROJECT_DIR/src/main.cj" << EOF
package $NAME

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*

// ============================================================
// $NAME - CJQT6 应用入口
// ============================================================

main(): Int32 {
    let app = QApplication()

    let window = QWidget()
    window.setTitle("$NAME")
    window.resize(400, 300)

    // 在此添加控件...
    let layout = QVBoxLayout()
    layout.setMargin(20)

    let label = QLabel()
    label.setText("Hello CJQT6!")
    label.setAlignment(Alignment.Center.value)
    layout.addWidget(label.getPtr())

    window.setLayout(layout.getPtr())
    window.show()

    let result = app.exec()
    return result
}
EOF

# 生成 README
cat > "$PROJECT_DIR/README.md" << EOF
# $NAME

基于 [CJQT6](https://gitcode.com/Cangjie-TPC/CJQT6) 的仓颉 Qt6 应用。

## 构建

\`\`\`bash
# 设置 CJQT6_ROOT 环境变量指向 CJQT6 仓库根目录
# 设置 QTDIR 指向 Qt6 安装路径
cjpm build
\`\`\`

## 运行

\`\`\`bash
cjpm run
\`\`\`
EOF

echo "✅ 已创建 CJQT6 项目: $PROJECT_DIR"
echo ""
echo "目录结构:"
echo "  $PROJECT_DIR/"
echo "    ├── cjpm.toml"
echo "    ├── README.md"
echo "    └── src/"
echo "        └── main.cj"
echo ""
echo "后续步骤:"
echo "  cd $PROJECT_DIR"
echo "  cjpm build"
echo "  cjpm run"