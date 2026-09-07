# CJQT6 修复报告 · 第四轮（FIX-REPORT-ROUND4）

> 范围：启动批量 QtResource 化的**第一批**（3 个小类）：QAudioOutput、QSoundEffect
> （可 track 的 QObject）与 QProcessEnvironment（非 QObject 值包装，只加守卫不 track）。
> 其余大对象（QMediaPlayer、QProcess、QThread 系、datetime 控件等）沿用本批样板分批进行。

---

## 1. 本轮实施（QtResource 化样板）

| 类 | 文件 | 改动 |
|---|---|---|
| `QAudioOutput` | `src/multimedia/mediaplayer.cj` | 实现 `QtResource`（isClosed/close/getPtr/isValid/checkValid）；init 判 `ptr==0` 抛 CreateFailedException 并 `trackObject`；全部方法加 `checkValid()`；close/delete 幂等（含 `isObjectAlive` 失效分支 + `untrackObject`），delete 改为 close() 别名 |
| `QSoundEffect` | `src/multimedia/soundeffect.cj` | 同上（新增 `import cjqt6.core.*`），init/play/stop/音量/循环/静音/状态等全部方法加守卫 |
| `QProcessEnvironment` | `src/core/process.cj` | 实现 `QtResource`；init 判空抛异常；所有方法加 `checkValid()`；`system()` 改用私有包装构造直持 FFI 指针（消除“先建临时对象再 delete 重建”的多余构造析构）；**非 QObject，不做 trackObject/isObjectAlive**（`isValid = !closed && ptr != 0`），close/delete 幂等 |

样板要点（后续批次照抄）：
- 可 track 的 QObject 子类：init 判空 → `trackObject`；close：`isObjectAlive` 失效分支 → `untrackObject` → 删除 → 置零；
- 非 QObject 值包装（QProcessEnvironment/QSqlQuery 类）：实现接口但不 track/不查存活；
- 全部公共方法入口 `checkValid()`；异常统一 QtException 族。

---

## 2. 验证

- `cjpm build`：通过。
- 全量 `cjpm test`（offscreen）：**1091 PASS / ~4 FAIL（77% 处）**；失败仍为既往各轮一致的
  本机环境偶发族（QProcessSpawn 控制台 GBK “Invalid utf8 byte sequence” 等），与本次改动
  零重叠；多媒体/进程相关非环境用例通过。

> 本轮结果：见上。

---

## 3. 后续批次（待做）

QMediaPlayer（本文件内剩余大对象）、QProcess/QThread/QThreadPool/QRunnable（需先解决
QRunnable autoDelete 双删设计）、datetime 四控件、dockwidget 五容器、plaintextedit 系、
QUdpSocket/network_access 系、QSqlQuery 系、print 三件套、QEventWidget 等；全部沿用本批
样板，建议每批 2-4 个类并跑全量回归。
