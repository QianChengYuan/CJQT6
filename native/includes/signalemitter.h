#ifndef CJFW_SIGNALEMITTER_H
#define CJFW_SIGNALEMITTER_H

#include <QObject>
#include <QString>

namespace cjfw {

// ============================================================
// SignalEmitter - 通用自定义信号发射器（P2）
// ------------------------------------------------------------
// 仓颉无法从 C++ 侧派生 Q_OBJECT 子类，因此这里提供一个固定的
// 通用发射器：暴露 void / int / double / string 四种参数信号，
// 并配套 emit 包装，供 Cangjie 侧以「用户自定义信号」的方式发射，
// 从而支持跨对象 / 跨线程通信（连接时传入 Qt::ConnectionType）。
// ============================================================

class SignalEmitter : public QObject {
    Q_OBJECT
public:
    explicit SignalEmitter(QObject* parent = nullptr);

    // 发射包装（供 Cangjie 经 FFI 调用）
    void emitVoid();
    void emitInt(int v);
    void emitDouble(double v);
    void emitString(const QString& s);

signals:
    void signalVoid();
    void signalInt(int v);
    void signalDouble(double v);
    void signalString(const QString& s);
};

} // namespace cjfw

#endif // CJFW_SIGNALEMITTER_H
