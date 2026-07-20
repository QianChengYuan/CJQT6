#!/bin/bash
export LD_LIBRARY_PATH="../../native/build_linux/lib:$LD_LIBRARY_PATH"
./target/release/bin/main
