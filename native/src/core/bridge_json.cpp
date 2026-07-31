#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonValue>
#include <QJsonParseError>
#include <QStringList>

static QByteArray g_jsonBuffer;
static QStringList g_jsonKeyList;

extern "C" {

// ============================================================
// QJsonDocument 桥接函数
// ============================================================

int64_t qJsonDocumentFromJson(const char* json) {
    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(QByteArray(json), &err);
    if (err.error == QJsonParseError::NoError) {
        return reinterpret_cast<int64_t>(new QJsonDocument(doc));
    }
    return 0;
}

void qJsonDocumentDelete(int64_t ptr) {
    delete reinterpret_cast<QJsonDocument*>(ptr);
}

const char* qJsonDocumentToJson(int64_t ptr, int32_t indent) {
    QJsonDocument* doc = reinterpret_cast<QJsonDocument*>(ptr);
    if (doc) {
        QJsonDocument::JsonFormat fmt = (indent > 0) ? QJsonDocument::Indented : QJsonDocument::Compact;
        g_jsonBuffer = doc->toJson(fmt);
        return g_jsonBuffer.constData();
    }
    return "";
}

bool qJsonDocumentIsNull(int64_t ptr) {
    QJsonDocument* doc = reinterpret_cast<QJsonDocument*>(ptr);
    return doc ? doc->isNull() : true;
}

bool qJsonDocumentIsArray(int64_t ptr) {
    QJsonDocument* doc = reinterpret_cast<QJsonDocument*>(ptr);
    return doc ? doc->isArray() : false;
}

bool qJsonDocumentIsObject(int64_t ptr) {
    QJsonDocument* doc = reinterpret_cast<QJsonDocument*>(ptr);
    return doc ? doc->isObject() : false;
}

int64_t qJsonDocumentObject(int64_t ptr) {
    QJsonDocument* doc = reinterpret_cast<QJsonDocument*>(ptr);
    if (doc && doc->isObject()) {
        return reinterpret_cast<int64_t>(new QJsonObject(doc->object()));
    }
    return 0;
}

int64_t qJsonDocumentArray(int64_t ptr) {
    QJsonDocument* doc = reinterpret_cast<QJsonDocument*>(ptr);
    if (doc && doc->isArray()) {
        return reinterpret_cast<int64_t>(new QJsonArray(doc->array()));
    }
    return 0;
}

// ============================================================
// QJsonObject 桥接函数
// ============================================================

int64_t qJsonObjectCreate() {
    return reinterpret_cast<int64_t>(new QJsonObject());
}

void qJsonObjectDelete(int64_t ptr) {
    delete reinterpret_cast<QJsonObject*>(ptr);
}

void qJsonObjectInsert(int64_t ptr, const char* key, int64_t valuePtr) {
    QJsonObject* obj = reinterpret_cast<QJsonObject*>(ptr);
    QJsonValue* val = reinterpret_cast<QJsonValue*>(valuePtr);
    if (obj && val) {
        obj->insert(QString::fromUtf8(key), *val);
    }
}

int64_t qJsonObjectValue(int64_t ptr, const char* key) {
    QJsonObject* obj = reinterpret_cast<QJsonObject*>(ptr);
    if (obj) {
        return reinterpret_cast<int64_t>(new QJsonValue(obj->value(QString::fromUtf8(key))));
    }
    return 0;
}

bool qJsonObjectContains(int64_t ptr, const char* key) {
    QJsonObject* obj = reinterpret_cast<QJsonObject*>(ptr);
    return obj ? obj->contains(QString::fromUtf8(key)) : false;
}

void qJsonObjectRemove(int64_t ptr, const char* key) {
    QJsonObject* obj = reinterpret_cast<QJsonObject*>(ptr);
    if (obj) obj->remove(QString::fromUtf8(key));
}

int32_t qJsonObjectSize(int64_t ptr) {
    QJsonObject* obj = reinterpret_cast<QJsonObject*>(ptr);
    return obj ? obj->size() : 0;
}

bool qJsonObjectIsEmpty(int64_t ptr) {
    QJsonObject* obj = reinterpret_cast<QJsonObject*>(ptr);
    return obj ? obj->isEmpty() : true;
}

const char* qJsonObjectKeyAt(int64_t ptr, int32_t index) {
    QJsonObject* obj = reinterpret_cast<QJsonObject*>(ptr);
    if (obj) {
        QStringList keys = obj->keys();
        if (index >= 0 && index < keys.size()) {
            g_jsonBuffer = keys[index].toUtf8();
            return g_jsonBuffer.constData();
        }
    }
    return "";
}

// ============================================================
// QJsonArray 桥接函数
// ============================================================

int64_t qJsonArrayCreate() {
    return reinterpret_cast<int64_t>(new QJsonArray());
}

void qJsonArrayDelete(int64_t ptr) {
    delete reinterpret_cast<QJsonArray*>(ptr);
}

void qJsonArrayAppend(int64_t ptr, int64_t valuePtr) {
    QJsonArray* arr = reinterpret_cast<QJsonArray*>(ptr);
    QJsonValue* val = reinterpret_cast<QJsonValue*>(valuePtr);
    if (arr && val) {
        arr->append(*val);
    }
}

int64_t qJsonArrayAt(int64_t ptr, int32_t index) {
    QJsonArray* arr = reinterpret_cast<QJsonArray*>(ptr);
    if (arr && index >= 0 && index < arr->size()) {
        return reinterpret_cast<int64_t>(new QJsonValue(arr->at(index)));
    }
    return 0;
}

int32_t qJsonArraySize(int64_t ptr) {
    QJsonArray* arr = reinterpret_cast<QJsonArray*>(ptr);
    return arr ? arr->size() : 0;
}

bool qJsonArrayIsEmpty(int64_t ptr) {
    QJsonArray* arr = reinterpret_cast<QJsonArray*>(ptr);
    return arr ? arr->isEmpty() : true;
}

void qJsonArrayRemoveAt(int64_t ptr, int32_t index) {
    QJsonArray* arr = reinterpret_cast<QJsonArray*>(ptr);
    if (arr) arr->removeAt(index);
}

// ============================================================
// QJsonValue 桥接函数
// ============================================================

int64_t qJsonValueCreateNull() {
    return reinterpret_cast<int64_t>(new QJsonValue(QJsonValue::Null));
}

int64_t qJsonValueCreateString(const char* val) {
    return reinterpret_cast<int64_t>(new QJsonValue(QString::fromUtf8(val)));
}

int64_t qJsonValueCreateInt(int64_t val) {
    return reinterpret_cast<int64_t>(new QJsonValue(static_cast<qint64>(val)));
}

int64_t qJsonValueCreateDouble(double val) {
    return reinterpret_cast<int64_t>(new QJsonValue(val));
}

int64_t qJsonValueCreateBool(bool val) {
    return reinterpret_cast<int64_t>(new QJsonValue(val));
}

int64_t qJsonValueCreateArray(int64_t arrPtr) {
    QJsonArray* arr = reinterpret_cast<QJsonArray*>(arrPtr);
    if (arr) return reinterpret_cast<int64_t>(new QJsonValue(*arr));
    return reinterpret_cast<int64_t>(new QJsonValue(QJsonValue::Null));
}

int64_t qJsonValueCreateObject(int64_t objPtr) {
    QJsonObject* obj = reinterpret_cast<QJsonObject*>(objPtr);
    if (obj) return reinterpret_cast<int64_t>(new QJsonValue(*obj));
    return reinterpret_cast<int64_t>(new QJsonValue(QJsonValue::Null));
}

void qJsonValueDelete(int64_t ptr) {
    delete reinterpret_cast<QJsonValue*>(ptr);
}

int32_t qJsonValueType(int64_t ptr) {
    QJsonValue* val = reinterpret_cast<QJsonValue*>(ptr);
    return val ? static_cast<int32_t>(val->type()) : 6;
}

const char* qJsonValueToString(int64_t ptr) {
    QJsonValue* val = reinterpret_cast<QJsonValue*>(ptr);
    if (val && val->isString()) {
        g_jsonBuffer = val->toString().toUtf8();
        return g_jsonBuffer.constData();
    }
    return "";
}

int64_t qJsonValueToInt(int64_t ptr, int64_t defaultVal) {
    QJsonValue* val = reinterpret_cast<QJsonValue*>(ptr);
    return val ? static_cast<int64_t>(val->toInt(static_cast<qint64>(defaultVal))) : defaultVal;
}

double qJsonValueToDouble(int64_t ptr, double defaultVal) {
    QJsonValue* val = reinterpret_cast<QJsonValue*>(ptr);
    return val ? val->toDouble(defaultVal) : defaultVal;
}

bool qJsonValueToBool(int64_t ptr, bool defaultVal) {
    QJsonValue* val = reinterpret_cast<QJsonValue*>(ptr);
    return val ? val->toBool(defaultVal) : defaultVal;
}

int64_t qJsonValueToObject(int64_t ptr) {
    QJsonValue* val = reinterpret_cast<QJsonValue*>(ptr);
    if (val && val->isObject()) {
        return reinterpret_cast<int64_t>(new QJsonObject(val->toObject()));
    }
    return 0;
}

int64_t qJsonValueToArray(int64_t ptr) {
    QJsonValue* val = reinterpret_cast<QJsonValue*>(ptr);
    if (val && val->isArray()) {
        return reinterpret_cast<int64_t>(new QJsonArray(val->toArray()));
    }
    return 0;
}

bool qJsonValueIsNull(int64_t ptr) {
    QJsonValue* val = reinterpret_cast<QJsonValue*>(ptr);
    return val ? val->isNull() : true;
}

bool qJsonValueIsString(int64_t ptr) {
    QJsonValue* val = reinterpret_cast<QJsonValue*>(ptr);
    return val ? val->isString() : false;
}

bool qJsonValueIsArray(int64_t ptr) {
    QJsonValue* val = reinterpret_cast<QJsonValue*>(ptr);
    return val ? val->isArray() : false;
}

bool qJsonValueIsObject(int64_t ptr) {
    QJsonValue* val = reinterpret_cast<QJsonValue*>(ptr);
    return val ? val->isObject() : false;
}

bool qJsonValueIsBool(int64_t ptr) {
    QJsonValue* val = reinterpret_cast<QJsonValue*>(ptr);
    return val ? val->isBool() : false;
}

bool qJsonValueIsDouble(int64_t ptr) {
    QJsonValue* val = reinterpret_cast<QJsonValue*>(ptr);
    return val ? val->isDouble() : false;
}

} // extern "C"
