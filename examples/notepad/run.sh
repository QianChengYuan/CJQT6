#!/bin/bash
# 运行记事本示例

cd "$(dirname "$0")"

# 设置库路径
export LD_LIBRARY_PATH="/home/yuan123/cangjiecode/CJQT6/native/build/lib:$LD_LIBRARY_PATH"

# 运行程序
./target/release/bin/main "$@"
