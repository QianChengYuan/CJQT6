/**
 * @file bridge_sql.cpp
 * @brief 数据库桥接函数 - QSqlDatabase, QSqlQuery
 */

#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QSqlRecord>
#include <QSqlField>
#include <QSqlTableModel>
#include <QVariant>
#include <QStringList>
#include "bridge_string_utils.h"

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
    if (db) {
        return cjqt6::dupUtf8(db->lastError().text());
    }
    return cjqt6::emptyString();
}

const char* qSqlDatabaseDriverName(int64_t ptr) {
    QSqlDatabase* db = reinterpret_cast<QSqlDatabase*>(ptr);
    if (db) {
        return cjqt6::dupUtf8(db->driverName());
    }
    return cjqt6::emptyString();
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
    if (query) {
        return cjqt6::dupUtf8(query->value(index).toString());
    }
    return cjqt6::emptyString();
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
    if (query) {
        return cjqt6::dupUtf8(query->lastError().text());
    }
    return cjqt6::emptyString();
}

void qSqlQueryDelete(int64_t ptr) {
    QSqlQuery* query = reinterpret_cast<QSqlQuery*>(ptr);
    if (query) {
        delete query;
    }
}

// ============================================================
// QSqlRecord 桥接函数
// ============================================================

int64_t qSqlQueryRecord(int64_t ptr) {
    QSqlQuery* query = reinterpret_cast<QSqlQuery*>(ptr);
    if (query) {
        QSqlRecord* record = new QSqlRecord(query->record());
        return reinterpret_cast<int64_t>(record);
    }
    return 0;
}

int32_t qSqlRecordCount(int64_t ptr) {
    QSqlRecord* record = reinterpret_cast<QSqlRecord*>(ptr);
    if (record) return record->count();
    return 0;
}

const char* qSqlRecordFieldName(int64_t ptr, int32_t index) {
    QSqlRecord* record = reinterpret_cast<QSqlRecord*>(ptr);
    if (record) {
        return cjqt6::dupUtf8(record->fieldName(index));
    }
    return cjqt6::emptyString();
}

int32_t qSqlRecordIndexOf(int64_t ptr, const char* name) {
    QSqlRecord* record = reinterpret_cast<QSqlRecord*>(ptr);
    if (record) {
        return record->indexOf(QString::fromUtf8(name));
    }
    return -1;
}

bool qSqlRecordIsNull(int64_t ptr, int32_t index) {
    QSqlRecord* record = reinterpret_cast<QSqlRecord*>(ptr);
    if (record) return record->isNull(index);
    return true;
}

const char* qSqlRecordValueString(int64_t ptr, int32_t index) {
    QSqlRecord* record = reinterpret_cast<QSqlRecord*>(ptr);
    if (record) {
        return cjqt6::dupUtf8(record->value(index).toString());
    }
    return cjqt6::emptyString();
}

int32_t qSqlRecordValueInt(int64_t ptr, int32_t index) {
    QSqlRecord* record = reinterpret_cast<QSqlRecord*>(ptr);
    if (record) return record->value(index).toInt();
    return 0;
}

double qSqlRecordValueDouble(int64_t ptr, int32_t index) {
    QSqlRecord* record = reinterpret_cast<QSqlRecord*>(ptr);
    if (record) return record->value(index).toDouble();
    return 0.0;
}

int64_t qSqlRecordField(int64_t ptr, int32_t index) {
    QSqlRecord* record = reinterpret_cast<QSqlRecord*>(ptr);
    if (record) {
        QSqlField* field = new QSqlField(record->field(index));
        return reinterpret_cast<int64_t>(field);
    }
    return 0;
}

void qSqlRecordDelete(int64_t ptr) {
    QSqlRecord* record = reinterpret_cast<QSqlRecord*>(ptr);
    if (record) delete record;
}

// ============================================================
// QSqlField 桥接函数
// ============================================================

const char* qSqlFieldName(int64_t ptr) {
    QSqlField* field = reinterpret_cast<QSqlField*>(ptr);
    if (field) {
        return cjqt6::dupUtf8(field->name());
    }
    return cjqt6::emptyString();
}

bool qSqlFieldIsNull(int64_t ptr) {
    QSqlField* field = reinterpret_cast<QSqlField*>(ptr);
    return field ? field->isNull() : true;
}

bool qSqlFieldIsReadOnly(int64_t ptr) {
    QSqlField* field = reinterpret_cast<QSqlField*>(ptr);
    return field ? field->isReadOnly() : true;
}

bool qSqlFieldIsAutoValue(int64_t ptr) {
    QSqlField* field = reinterpret_cast<QSqlField*>(ptr);
    return field ? field->isAutoValue() : false;
}

const char* qSqlFieldValueString(int64_t ptr) {
    QSqlField* field = reinterpret_cast<QSqlField*>(ptr);
    if (field) {
        return cjqt6::dupUtf8(field->value().toString());
    }
    return cjqt6::emptyString();
}

void qSqlFieldDelete(int64_t ptr) {
    QSqlField* field = reinterpret_cast<QSqlField*>(ptr);
    if (field) delete field;
}

// ============================================================
// QSqlTableModel 桥接函数
// ============================================================

int64_t qSqlTableModelCreate(int64_t parent, const char* dbName) {
    QSqlDatabase db = QSqlDatabase::database(QString::fromUtf8(dbName));
    QSqlTableModel* model = new QSqlTableModel(reinterpret_cast<QObject*>(parent), db);
    return reinterpret_cast<int64_t>(model);
}

void qSqlTableModelDelete(int64_t ptr) {
    delete reinterpret_cast<QSqlTableModel*>(ptr);
}

void qSqlTableModelSetTable(int64_t ptr, const char* tableName) {
    reinterpret_cast<QSqlTableModel*>(ptr)->setTable(QString::fromUtf8(tableName));
}

const char* qSqlTableModelTableName(int64_t ptr) {
    return cjqt6::dupUtf8(reinterpret_cast<QSqlTableModel*>(ptr)->tableName());
}

bool qSqlTableModelSelect(int64_t ptr) {
    return reinterpret_cast<QSqlTableModel*>(ptr)->select();
}

int32_t qSqlTableModelRowCount(int64_t ptr) {
    return reinterpret_cast<QSqlTableModel*>(ptr)->rowCount();
}

int32_t qSqlTableModelColumnCount(int64_t ptr) {
    return reinterpret_cast<QSqlTableModel*>(ptr)->columnCount();
}

void qSqlTableModelSetFilter(int64_t ptr, const char* filter) {
    reinterpret_cast<QSqlTableModel*>(ptr)->setFilter(QString::fromUtf8(filter));
}

const char* qSqlTableModelFilter(int64_t ptr) {
    return cjqt6::dupUtf8(reinterpret_cast<QSqlTableModel*>(ptr)->filter());
}

void qSqlTableModelSetSort(int64_t ptr, int32_t col, int32_t order) {
    reinterpret_cast<QSqlTableModel*>(ptr)->setSort(col, static_cast<Qt::SortOrder>(order));
}

const char* qSqlTableModelData(int64_t ptr, int32_t row, int32_t col) {
    QModelIndex idx = reinterpret_cast<QSqlTableModel*>(ptr)->index(row, col);
    return cjqt6::dupUtf8(idx.data(Qt::DisplayRole).toString());
}

bool qSqlTableModelSetData(int64_t ptr, int32_t row, int32_t col, const char* val) {
    QModelIndex idx = reinterpret_cast<QSqlTableModel*>(ptr)->index(row, col);
    return reinterpret_cast<QSqlTableModel*>(ptr)->setData(idx, QString::fromUtf8(val));
}

const char* qSqlTableModelHeaderData(int64_t ptr, int32_t section) {
    return cjqt6::dupUtf8(reinterpret_cast<QSqlTableModel*>(ptr)->headerData(section, Qt::Horizontal, Qt::DisplayRole).toString());
}

bool qSqlTableModelInsertRow(int64_t ptr, int32_t row) {
    return reinterpret_cast<QSqlTableModel*>(ptr)->insertRow(row);
}

bool qSqlTableModelRemoveRow(int64_t ptr, int32_t row) {
    return reinterpret_cast<QSqlTableModel*>(ptr)->removeRow(row);
}

bool qSqlTableModelSubmitAll(int64_t ptr) {
    return reinterpret_cast<QSqlTableModel*>(ptr)->submitAll();
}

void qSqlTableModelRevertAll(int64_t ptr) {
    reinterpret_cast<QSqlTableModel*>(ptr)->revertAll();
}

const char* qSqlTableModelDatabaseError(int64_t ptr) {
    return cjqt6::dupUtf8(reinterpret_cast<QSqlTableModel*>(ptr)->lastError().text());
}

void qSqlTableModelSetEditStrategy(int64_t ptr, int32_t strategy) {
    reinterpret_cast<QSqlTableModel*>(ptr)->setEditStrategy(static_cast<QSqlTableModel::EditStrategy>(strategy));
}

int32_t qSqlTableModelEditStrategy(int64_t ptr) {
    return static_cast<int32_t>(reinterpret_cast<QSqlTableModel*>(ptr)->editStrategy());
}

void qSqlTableModelClearTable(int64_t ptr) {
    reinterpret_cast<QSqlTableModel*>(ptr)->clear();
}

void qSqlTableModelFetchMore(int64_t ptr) {
    reinterpret_cast<QSqlTableModel*>(ptr)->fetchMore(QModelIndex());
}

bool qSqlTableModelCanFetchMore(int64_t ptr) {
    return reinterpret_cast<QSqlTableModel*>(ptr)->canFetchMore(QModelIndex());
}

} // extern "C"
