/**
 * @file bridge_sql.cpp
 * @brief 数据库桥接函数 - QSqlDatabase, QSqlQuery
 */

#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QSqlRecord>
#include <QVariant>
#include <QStringList>

extern "C" {

// ============================================================
// QSqlDatabase 桥接函数
// ============================================================

int64_t qSqlDatabaseAddDatabase(const char* type, const char* name) {
    QSqlDatabase db = QSqlDatabase::addDatabase(QString::fromUtf8(type), QString::fromUtf8(name));
    if (db.isValid()) {
        QSqlDatabase* pdb = new QSqlDatabase(db);
        return reinterpret_cast<int64_t>(pdb);
    }
    return 0;
}

int64_t qSqlDatabaseDatabase(const char* name) {
    QSqlDatabase db = QSqlDatabase::database(QString::fromUtf8(name));
    if (db.isValid()) {
        QSqlDatabase* pdb = new QSqlDatabase(db);
        return reinterpret_cast<int64_t>(pdb);
    }
    return 0;
}

void qSqlDatabaseSetHostName(int64_t ptr, const char* host) {
    QSqlDatabase* db = reinterpret_cast<QSqlDatabase*>(ptr);
    if (db) {
        db->setHostName(QString::fromUtf8(host));
    }
}

void qSqlDatabaseSetPort(int64_t ptr, int32_t port) {
    QSqlDatabase* db = reinterpret_cast<QSqlDatabase*>(ptr);
    if (db) {
        db->setPort(port);
    }
}

void qSqlDatabaseSetDatabaseName(int64_t ptr, const char* name) {
    QSqlDatabase* db = reinterpret_cast<QSqlDatabase*>(ptr);
    if (db) {
        db->setDatabaseName(QString::fromUtf8(name));
    }
}

void qSqlDatabaseSetUserName(int64_t ptr, const char* user) {
    QSqlDatabase* db = reinterpret_cast<QSqlDatabase*>(ptr);
    if (db) {
        db->setUserName(QString::fromUtf8(user));
    }
}

void qSqlDatabaseSetPassword(int64_t ptr, const char* password) {
    QSqlDatabase* db = reinterpret_cast<QSqlDatabase*>(ptr);
    if (db) {
        db->setPassword(QString::fromUtf8(password));
    }
}

bool qSqlDatabaseOpen(int64_t ptr) {
    QSqlDatabase* db = reinterpret_cast<QSqlDatabase*>(ptr);
    if (db) {
        return db->open();
    }
    return false;
}

void qSqlDatabaseClose(int64_t ptr) {
    QSqlDatabase* db = reinterpret_cast<QSqlDatabase*>(ptr);
    if (db) {
        db->close();
    }
}

bool qSqlDatabaseIsOpen(int64_t ptr) {
    QSqlDatabase* db = reinterpret_cast<QSqlDatabase*>(ptr);
    if (db) {
        return db->isOpen();
    }
    return false;
}

const char* qSqlDatabaseLastError(int64_t ptr) {
    QSqlDatabase* db = reinterpret_cast<QSqlDatabase*>(ptr);
    static QByteArray buffer;
    if (db) {
        buffer = db->lastError().text().toUtf8();
        return buffer.constData();
    }
    return "";
}

const char* qSqlDatabaseDriverName(int64_t ptr) {
    QSqlDatabase* db = reinterpret_cast<QSqlDatabase*>(ptr);
    static QByteArray buffer;
    if (db) {
        buffer = db->driverName().toUtf8();
        return buffer.constData();
    }
    return "";
}

void qSqlDatabaseRemoveDatabase(const char* name) {
    QSqlDatabase::removeDatabase(QString::fromUtf8(name));
}

void qSqlDatabaseDelete(int64_t ptr) {
    QSqlDatabase* db = reinterpret_cast<QSqlDatabase*>(ptr);
    if (db) {
        delete db;
    }
}

// ============================================================
// QSqlQuery 桥接函数
// ============================================================

int64_t qSqlQueryCreate() {
    QSqlQuery* query = new QSqlQuery();
    return reinterpret_cast<int64_t>(query);
}

int64_t qSqlQueryCreateWithDb(int64_t dbPtr) {
    QSqlDatabase* db = reinterpret_cast<QSqlDatabase*>(dbPtr);
    if (db) {
        QSqlQuery* query = new QSqlQuery(*db);
        return reinterpret_cast<int64_t>(query);
    }
    return 0;
}

bool qSqlQueryExec(int64_t ptr, const char* sql) {
    QSqlQuery* query = reinterpret_cast<QSqlQuery*>(ptr);
    if (query) {
        return query->exec(QString::fromUtf8(sql));
    }
    return false;
}

bool qSqlQueryExecBatch(int64_t ptr) {
    QSqlQuery* query = reinterpret_cast<QSqlQuery*>(ptr);
    if (query) {
        return query->execBatch();
    }
    return false;
}

bool qSqlQueryPrepare(int64_t ptr, const char* sql) {
    QSqlQuery* query = reinterpret_cast<QSqlQuery*>(ptr);
    if (query) {
        return query->prepare(QString::fromUtf8(sql));
    }
    return false;
}

void qSqlQueryBindValue(int64_t ptr, const char* placeholder, const char* value) {
    QSqlQuery* query = reinterpret_cast<QSqlQuery*>(ptr);
    if (query) {
        query->bindValue(QString::fromUtf8(placeholder), QString::fromUtf8(value));
    }
}

void qSqlQueryBindValueInt(int64_t ptr, const char* placeholder, int32_t value) {
    QSqlQuery* query = reinterpret_cast<QSqlQuery*>(ptr);
    if (query) {
        query->bindValue(QString::fromUtf8(placeholder), value);
    }
}

void qSqlQueryBindValueDouble(int64_t ptr, const char* placeholder, double value) {
    QSqlQuery* query = reinterpret_cast<QSqlQuery*>(ptr);
    if (query) {
        query->bindValue(QString::fromUtf8(placeholder), value);
    }
}

bool qSqlQueryNext(int64_t ptr) {
    QSqlQuery* query = reinterpret_cast<QSqlQuery*>(ptr);
    if (query) {
        return query->next();
    }
    return false;
}

bool qSqlQueryPrevious(int64_t ptr) {
    QSqlQuery* query = reinterpret_cast<QSqlQuery*>(ptr);
    if (query) {
        return query->previous();
    }
    return false;
}

bool qSqlQueryFirst(int64_t ptr) {
    QSqlQuery* query = reinterpret_cast<QSqlQuery*>(ptr);
    if (query) {
        return query->first();
    }
    return false;
}

bool qSqlQueryLast(int64_t ptr) {
    QSqlQuery* query = reinterpret_cast<QSqlQuery*>(ptr);
    if (query) {
        return query->last();
    }
    return false;
}

const char* qSqlQueryValueString(int64_t ptr, int32_t index) {
    QSqlQuery* query = reinterpret_cast<QSqlQuery*>(ptr);
    static QByteArray buffer;
    if (query) {
        buffer = query->value(index).toString().toUtf8();
        return buffer.constData();
    }
    return "";
}

int32_t qSqlQueryValueInt(int64_t ptr, int32_t index) {
    QSqlQuery* query = reinterpret_cast<QSqlQuery*>(ptr);
    if (query) {
        return query->value(index).toInt();
    }
    return 0;
}

double qSqlQueryValueDouble(int64_t ptr, int32_t index) {
    QSqlQuery* query = reinterpret_cast<QSqlQuery*>(ptr);
    if (query) {
        return query->value(index).toDouble();
    }
    return 0.0;
}

int32_t qSqlQuerySize(int64_t ptr) {
    QSqlQuery* query = reinterpret_cast<QSqlQuery*>(ptr);
    if (query) {
        return query->size();
    }
    return -1;
}

int32_t qSqlQueryNumRowsAffected(int64_t ptr) {
    QSqlQuery* query = reinterpret_cast<QSqlQuery*>(ptr);
    if (query) {
        return query->numRowsAffected();
    }
    return -1;
}

int32_t qSqlQueryAt(int64_t ptr) {
    QSqlQuery* query = reinterpret_cast<QSqlQuery*>(ptr);
    if (query) {
        return query->at();
    }
    return -1;
}

bool qSqlQueryIsValid(int64_t ptr) {
    QSqlQuery* query = reinterpret_cast<QSqlQuery*>(ptr);
    if (query) {
        return query->isValid();
    }
    return false;
}

bool qSqlQueryIsActive(int64_t ptr) {
    QSqlQuery* query = reinterpret_cast<QSqlQuery*>(ptr);
    if (query) {
        return query->isActive();
    }
    return false;
}

bool qSqlQueryIsSelect(int64_t ptr) {
    QSqlQuery* query = reinterpret_cast<QSqlQuery*>(ptr);
    if (query) {
        return query->isSelect();
    }
    return false;
}

void qSqlQueryFinish(int64_t ptr) {
    QSqlQuery* query = reinterpret_cast<QSqlQuery*>(ptr);
    if (query) {
        query->finish();
    }
}

void qSqlQueryClear(int64_t ptr) {
    QSqlQuery* query = reinterpret_cast<QSqlQuery*>(ptr);
    if (query) {
        query->clear();
    }
}

const char* qSqlQueryLastError(int64_t ptr) {
    QSqlQuery* query = reinterpret_cast<QSqlQuery*>(ptr);
    static QByteArray buffer;
    if (query) {
        buffer = query->lastError().text().toUtf8();
        return buffer.constData();
    }
    return "";
}

void qSqlQueryDelete(int64_t ptr) {
    QSqlQuery* query = reinterpret_cast<QSqlQuery*>(ptr);
    if (query) {
        delete query;
    }
}

} // extern "C"
