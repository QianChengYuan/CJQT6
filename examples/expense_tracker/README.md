# 个人记账本 - 运行说明

## 编译

```bash
cd examples/expense_tracker
cjpm build
```

## 运行前准备

### 1. 需要的动态库

#### CJQT6 Bridge 库
将以下文件复制到可执行文件目录：
```
native/build-win64/bin/libcjqt6_bridge.dll
```

#### Qt6 库
需要 Qt6 的以下 DLL（根据你的 Qt 安装路径）：

**核心库：**
- Qt6Core.dll
- Qt6Gui.dll
- Qt6Widgets.dll

**多媒体（如使用）：**
- Qt6Multimedia.dll

**SQL（如使用）：**
- Qt6Sql.dll

**平台插件：**
- platforms/qwindows.dll

### 2. 方法一：设置 PATH 环境变量

将以下路径添加到 PATH：
```
C:\Qt\6.x.x\msvc2019_64\bin
C:\Qt\6.x.x\msvc2019_64\plugins\platforms
C:\CodeTools\cangjie_git\CJQT6\native\build-win64\bin
```

### 3. 方法二：复制 DLL 到可执行文件目录

```powershell
# 假设 Qt 安装在 C:\Qt\6.6.0\msvc2019_64
$QtBin = "C:\Qt\6.6.0\msvc2019_64\bin"
$Target = "C:\CodeTools\cangjie_git\CJQT6\examples\expense_tracker\build\debug"

# 复制 Qt DLL
Copy-Item "$QtBin\Qt6Core.dll" $Target
Copy-Item "$QtBin\Qt6Gui.dll" $Target
Copy-Item "$QtBin\Qt6Widgets.dll" $Target
Copy-Item "$QtBin\Qt6Sql.dll" $Target

# 复制平台插件
New-Item -ItemType Directory -Force -Path "$Target\platforms"
Copy-Item "$QtBin\..\plugins\platforms\qwindows.dll" "$Target\platforms"

# 复制 bridge 库
Copy-Item "C:\CodeTools\cangjie_git\CJQT6\native\build-win64\bin\libcjqt6_bridge.dll" $Target
```

## 运行

```bash
cjpm run
# 或直接运行
.\build\debug\expense_tracker.exe
```

## 常见问题

### 问题：找不到 Qt6Core.dll
**解决：** 安装 Qt6 或将 Qt6 bin 目录加入 PATH

### 问题：找不到 libcjqt6_bridge.dll
**解决：** 复制 `native/build-win64/bin/libcjqt6_bridge.dll` 到可执行文件目录

### 问题：This application failed to start because no Qt platform plugin could be found
**解决：** 复制 `platforms/qwindows.dll` 到可执行文件目录下的 `platforms` 文件夹

### 问题：数据库打开失败
**解决：** 检查是否有 SQLite 驱动（Qt6Sql.dll 及其 plugins/sqldrivers/qsqlite.dll）
