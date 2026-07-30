/**
 * @file bridge_undostack.cpp
 * @brief QUndoCommand / QUndoStack 桥接函数
 *
 * QUndoCommand 是一个抽象基类，需要通过子类化实现 undo/redo。
 * 我们采用回调方式：创建一个 CallbackUndoCommand 子类，其 undo/redo
 * 调用注册的 C 函数指针，从而允许仓颉侧通过 CFunc 提供实现。
 */

#include <QUndoCommand>
#include <QUndoStack>
#include <functional>
#include <cstring>

// ============================================================
// CallbackUndoCommand - 基于回调的 QUndoCommand
// ============================================================

typedef void (*UndoRedoCallback)(int64_t userData);

class CallbackUndoCommand : public QUndoCommand {
public:
    CallbackUndoCommand(UndoRedoCallback undoCallback,
                        UndoRedoCallback redoCallback,
                        int64_t userData,
                        const QString& text = QString())
        : QUndoCommand(text)
        , m_undoCallback(undoCallback)
        , m_redoCallback(redoCallback)
        , m_userData(userData)
    {
    }

    virtual ~CallbackUndoCommand() = default;

    virtual void undo() override {
        if (m_undoCallback) {
            m_undoCallback(m_userData);
        }
    }

    virtual void redo() override {
        if (m_redoCallback) {
            m_redoCallback(m_userData);
        }
    }

private:
    UndoRedoCallback m_undoCallback;
    UndoRedoCallback m_redoCallback;
    int64_t m_userData;
};

extern "C" {

// ============================================================
// QUndoCommand 桥接函数
// ============================================================

int64_t qUndoCommandCreate(UndoRedoCallback undoCallback,
                            UndoRedoCallback redoCallback,
                            int64_t userData,
                            const char* text) {
    QString cmdText = text ? QString::fromUtf8(text) : QString();
    CallbackUndoCommand* cmd = new CallbackUndoCommand(undoCallback, redoCallback, userData, cmdText);
    return reinterpret_cast<int64_t>(cmd);
}

void qUndoCommandSetText(int64_t ptr, const char* text) {
    QUndoCommand* cmd = reinterpret_cast<QUndoCommand*>(ptr);
    if (cmd) {
        cmd->setText(QString::fromUtf8(text));
    }
}

const char* qUndoCommandText(int64_t ptr) {
    QUndoCommand* cmd = reinterpret_cast<QUndoCommand*>(ptr);
    if (cmd) {
        static QByteArray buffer;
        buffer = cmd->text().toUtf8();
        return buffer.constData();
    }
    return "";
}

void qUndoCommandDelete(int64_t ptr) {
    // 注意：如果命令在栈上（已被 push），由栈管理删除，此处仅作安全清理
    // 我们提供一个标记，避免 double delete
    // 但通常 push 后栈拥有所有权
    CallbackUndoCommand* cmd = reinterpret_cast<CallbackUndoCommand*>(ptr);
    if (cmd) {
        delete cmd;
    }
}

// ============================================================
// QUndoStack 桥接函数
// ============================================================

int64_t qUndoStackCreate() {
    QUndoStack* stack = new QUndoStack();
    return reinterpret_cast<int64_t>(stack);
}

void qUndoStackPush(int64_t ptr, int64_t cmdPtr) {
    QUndoStack* stack = reinterpret_cast<QUndoStack*>(ptr);
    CallbackUndoCommand* cmd = reinterpret_cast<CallbackUndoCommand*>(cmdPtr);
    if (stack && cmd) {
        // push 后栈拥有命令所有权
        stack->push(cmd);
    }
}

void qUndoStackUndo(int64_t ptr) {
    QUndoStack* stack = reinterpret_cast<QUndoStack*>(ptr);
    if (stack) {
        stack->undo();
    }
}

void qUndoStackRedo(int64_t ptr) {
    QUndoStack* stack = reinterpret_cast<QUndoStack*>(ptr);
    if (stack) {
        stack->redo();
    }
}

int32_t qUndoStackCanUndo(int64_t ptr) {
    QUndoStack* stack = reinterpret_cast<QUndoStack*>(ptr);
    if (stack) {
        return stack->canUndo() ? 1 : 0;
    }
    return 0;
}

int32_t qUndoStackCanRedo(int64_t ptr) {
    QUndoStack* stack = reinterpret_cast<QUndoStack*>(ptr);
    if (stack) {
        return stack->canRedo() ? 1 : 0;
    }
    return 0;
}

const char* qUndoStackUndoText(int64_t ptr) {
    QUndoStack* stack = reinterpret_cast<QUndoStack*>(ptr);
    if (stack) {
        static QByteArray buffer;
        buffer = stack->undoText().toUtf8();
        return buffer.constData();
    }
    return "";
}

const char* qUndoStackRedoText(int64_t ptr) {
    QUndoStack* stack = reinterpret_cast<QUndoStack*>(ptr);
    if (stack) {
        static QByteArray buffer;
        buffer = stack->redoText().toUtf8();
        return buffer.constData();
    }
    return "";
}

int32_t qUndoStackCount(int64_t ptr) {
    QUndoStack* stack = reinterpret_cast<QUndoStack*>(ptr);
    if (stack) {
        return stack->count();
    }
    return 0;
}

int32_t qUndoStackIndex(int64_t ptr) {
    QUndoStack* stack = reinterpret_cast<QUndoStack*>(ptr);
    if (stack) {
        return stack->index();
    }
    return 0;
}

void qUndoStackClear(int64_t ptr) {
    QUndoStack* stack = reinterpret_cast<QUndoStack*>(ptr);
    if (stack) {
        stack->clear();
    }
}

void qUndoStackSetUndoLimit(int64_t ptr, int32_t limit) {
    QUndoStack* stack = reinterpret_cast<QUndoStack*>(ptr);
    if (stack) {
        stack->setUndoLimit(limit);
    }
}

int32_t qUndoStackUndoLimit(int64_t ptr) {
    QUndoStack* stack = reinterpret_cast<QUndoStack*>(ptr);
    if (stack) {
        return stack->undoLimit();
    }
    return 0;
}

void qUndoStackSetClean(int64_t ptr) {
    QUndoStack* stack = reinterpret_cast<QUndoStack*>(ptr);
    if (stack) {
        stack->setClean();
    }
}

int32_t qUndoStackIsClean(int64_t ptr) {
    QUndoStack* stack = reinterpret_cast<QUndoStack*>(ptr);
    if (stack) {
        return stack->isClean() ? 1 : 0;
    }
    return 0;
}

void qUndoStackBeginMacro(int64_t ptr, const char* text) {
    QUndoStack* stack = reinterpret_cast<QUndoStack*>(ptr);
    if (stack) {
        stack->beginMacro(QString::fromUtf8(text));
    }
}

void qUndoStackEndMacro(int64_t ptr) {
    QUndoStack* stack = reinterpret_cast<QUndoStack*>(ptr);
    if (stack) {
        stack->endMacro();
    }
}

void qUndoStackDelete(int64_t ptr) {
    QUndoStack* stack = reinterpret_cast<QUndoStack*>(ptr);
    if (stack) {
        delete stack;
    }
}

} // extern "C"
