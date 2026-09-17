package CjMonitor.store

import std.collection.*
import cjqt6.sql.*
import CjMonitor.common.*

// ============================================================
// 降采样落库（SQLite）
//
// 写放大控制：100ms 采样 → 每 10 次降采样一次 → 攒满 60 条（约 1 分钟）
// 批量提交。相比逐帧 insert，写放大降低约一个数量级。
//
// 两个关键事实（已核实）：
//   1. QSqlDatabase **没有** transaction()/commit()/rollback()，
//      批量提交只能用 exec("BEGIN") / exec("COMMIT") 包裹；
//   2. QSqlQuery 没有 addBindValue，bindValue 的占位符语义（命名 ? 或 :x）
//      文档未明确。本实现直接以 SQL 字面量传数值（值均由本程序生成，
//      不含外部输入，无注入面），从而绕开占位符不确定性。
// ============================================================

public class SampleStore {
    private var db: Option<QSqlDatabase> = None
    private var opened: Bool = false
    private var lastError: String = ""

    private let pending: ArrayList<Sample> = ArrayList<Sample>()
    private let downsampleN: Int64
    private let batchSize: Int64
    private let connName: String

    private var tick: Int64 = 0
    private var rowsWritten: Int64 = 0

    public init(connName: String, downsampleN: Int64, batchSize: Int64) {
        this.connName = connName
        this.downsampleN = if (downsampleN < 1) { 1 } else { downsampleN }
        this.batchSize = if (batchSize < 1) { 1 } else { batchSize }
    }

    // ========================================================
    // 生命周期
    // ========================================================

    /// 打开数据库。**任何失败都返回 false 而非抛出异常**——
    /// QSQLITE 驱动不可用（例如 plugins/sqldrivers 未随程序部署）时，
    /// QSqlQuery 构造会抛异常；若不拦截，整个进程会直接退出。
    /// 调用方据此降级为纯内存运行。
    public func open(path: String): Bool {
        try {
            let d = QSqlDatabase.addDatabase(SqlDriver.sqlite(), connName)
            d.setDatabaseName(path)
            let ok = d.open()
            if (!ok) {
                lastError = d.lastError()
                if (lastError.isEmpty()) {
                    lastError = "QSQLITE 驱动不可用或数据库文件不可写（请确认 plugins/sqldrivers 已随程序部署）"
                }
                d.close()
                return false
            }
            db = Some(d)
            opened = true
            createTable()
            true
        } catch (e: Exception) {
            lastError = "数据库初始化异常：${e.message}"
            db = None
            opened = false
            false
        }
    }

    func createTable(): Unit {
        let sql = "CREATE TABLE IF NOT EXISTS samples (" +
            "ts INTEGER PRIMARY KEY, cpu REAL, mem REAL, disk REAL, net_rx REAL, net_tx REAL)"
        if (let Some(d) <- db) {
            // 注意：QSqlQuery 的构造器即 init(db)，不能写成 obj.init(db)（init 是关键字）
            let ddl = QSqlQuery(d)
            if (!ddl.exec(sql)) {
                lastError = ddl.lastError()
            }
            ddl.close()
        }
    }

    public func close(): Unit {
        flush()
        if (let Some(d) <- db) {
            d.close()
        }
        db = None
        opened = false
    }

    public func isOpen(): Bool {
        opened
    }

    public func rows(): Int64 {
        rowsWritten
    }

    public func error(): String {
        lastError
    }

    public func pendingCount(): Int64 {
        pending.size
    }

    // ========================================================
    // 写入路径
    // ========================================================

    /// 采样回调：按 1/downsampleN 降采样，攒批到 batchSize 后提交
    public func onSample(s: Sample): Unit {
        if (!opened) {
            return
        }
        tick += 1
        if (tick % downsampleN != 0) {
            return
        }
        pending.add(s)
        if (pending.size >= batchSize) {
            flush()
        }
    }

    /// 批量提交（BEGIN/COMMIT 包裹；失败则 ROLLBACK 并记录错误）
    public func flush(): Unit {
        if (!opened || pending.size == 0) {
            return
        }
        if (let Some(d) <- db) {
            let q = QSqlQuery(d)
            if (!q.exec("BEGIN")) {
                lastError = q.lastError()
                q.close()
                return
            }
            var i: Int64 = 0
            var failed = false
            while (i < pending.size) {
                let s = pending[i]
                let sql = "INSERT OR REPLACE INTO samples(ts,cpu,mem,disk,net_rx,net_tx) VALUES(" +
                    "${s.tsMs},${s.cpu},${s.mem},${s.disk},${s.netRx},${s.netTx})"
                if (!q.exec(sql)) {
                    lastError = q.lastError()
                    failed = true
                    break
                }
                rowsWritten += 1
                i += 1
            }
            if (failed) {
                if (!q.exec("ROLLBACK")) {
                    lastError = q.lastError()
                }
            } else {
                if (!q.exec("COMMIT")) {
                    lastError = q.lastError()
                }
            }
            q.close()
        }
        pending.clear()
    }

    // ========================================================
    // 查询路径（历史页）
    // ========================================================

    /// 查询区间样本（按时间升序，最多 limit 条）
    public func queryRange(fromMs: Int64, toMs: Int64, limit: Int64): ArrayList<Sample> {
        let out = ArrayList<Sample>()
        if (!opened) {
            return out
        }
        if (let Some(d) <- db) {
            let q = QSqlQuery(d)
            let sql = "SELECT ts,cpu,mem,disk,net_rx,net_tx FROM samples " +
                "WHERE ts >= ${fromMs} AND ts <= ${toMs} ORDER BY ts ASC LIMIT ${limit}"
            if (!q.exec(sql)) {
                lastError = q.lastError()
                q.close()
                return out
            }
            while (q.next()) {
                out.add(Sample(
                    Int64(q.valueInt(0)),
                    q.valueDouble(1),
                    q.valueDouble(2),
                    q.valueDouble(3),
                    q.valueDouble(4),
                    q.valueDouble(5)
                ))
            }
            q.close()
        }
        out
    }

    /// 表内总行数与时间跨度（状态栏 / 历史页摘要）
    public func tableStats(): String {
        if (!opened) {
            return "数据库未打开"
        }
        if (let Some(d) <- db) {
            let q = QSqlQuery(d)
            if (q.exec("SELECT COUNT(*), MIN(ts), MAX(ts) FROM samples")) {
                if (q.next()) {
                    let cnt = Int64(q.valueInt(0))
                    let mn = Int64(q.valueInt(1))
                    let mx = Int64(q.valueInt(2))
                    q.close()
                    return "行数=${cnt} 跨度=${(mx - mn) / 1000}s"
                }
            }
            lastError = q.lastError()
            q.close()
        }
        "统计失败"
    }
}
