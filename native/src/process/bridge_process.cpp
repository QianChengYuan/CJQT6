/**
 * @file bridge_process.cpp
 * @brief QProcess 进程管理桥接函数
 */

#include <QProcess>
#include <QProcessEnvironment>
#include <QStringList>
#include <functional>
#include <unordered_map>
#include "bridge_string_utils.h"

// 回调映射
static std::unordered_map<int64_t, std::function<void(int, int)>> g_finishedCallbacks;
static std::unordered_map<int64_t, std::function<void()>> g_startedCallbacks;
static std::unordered_map<int64_t, std::function<void()>> g_readyReadStdOutCallbacks;
static std::unordered_map<int64_t, std::function<void()>> g_readyReadStdErrCallbacks;
static std::unordered_map<int64_t, std::function<void(int)>> g_errorCallbacks;
static std::unordered_map<int64_t, std::function<void(int)>> g_stateChangedCallbacks;

// S4 修复：各信号分别保存连接句柄。原先每次 SetOnXxx 都 QObject::connect 新
// lambda 且不断开旧连接——替换回调后旧 lambda 仍挂在 process 上，同一信号
// 触发时回调被执行多次。改为替换式语义（与 bridge_signal.cpp 一致）。
static std::unordered_map<int64_t, QMetaObject::Connection> g_procFinishedConns;
static std::unordered_map<int64_t, QMetaObject::Connection> g_procStartedConns;
static std::unordered_map<int64_t, QMetaObject::Connection> g_procStdOutConns;
static std::unordered_map<int64_t, QMetaObject::Connection> g_procStdErrConns;
static std::unordered_map<int64_t, QMetaObject::Connection> g_procErrorConns;
static std::unordered_map<int64_t, QMetaObject::Connection> g_procStateConns;

// 替换式登记连接：断开同 (表, ptr) 的旧连接后登记新连接
static void replaceConn(std::unordered_map<int64_t, QMetaObject::Connection>& conns,
                        int64_t ptr, QMetaObject::Connection conn) {
    auto cit = conns.find(ptr);
    if (cit != conns.end()) {
        if (cit->second) QObject::disconnect(cit->second);
        cit->second = conn;
    } else {
        conns.emplace(ptr, conn);
    }
}

// 断开并移除同 (表, ptr) 的连接；返回是否确有连接被断开
static bool dropConn(std::unordered_map<int64_t, QMetaObject::Connection>& conns, int64_t ptr) {
    auto cit = conns.find(ptr);
    if (cit != conns.end()) {
        if (cit->second) QObject::disconnect(cit->second);
        conns.erase(cit);
        return true;
    }
    return false;
}

extern "C" {

// ============================================================
// QProcess 桥接函数
// ============================================================

int64_t qProcessCreate() {
    QProcess* process = new QProcess();
    return reinterpret_cast<int64_t>(process);
}

void qProcessDelete(int64_t ptr) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        dropConn(g_procFinishedConns, ptr);
        dropConn(g_procStartedConns, ptr);
        dropConn(g_procStdOutConns, ptr);
        dropConn(g_procStdErrConns, ptr);
        dropConn(g_procErrorConns, ptr);
        dropConn(g_procStateConns, ptr);
        g_finishedCallbacks.erase(ptr);
        g_startedCallbacks.erase(ptr);
        g_readyReadStdOutCallbacks.erase(ptr);
        g_readyReadStdErrCallbacks.erase(ptr);
        g_errorCallbacks.erase(ptr);
        g_stateChangedCallbacks.erase(ptr);
        delete process;
    }
}

// 启动进程
void qProcessStart(int64_t ptr, const char* program) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        process->start(QString::fromUtf8(program));
    }
}

void qProcessStartWithArgs(int64_t ptr, const char* program, const char* args) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        QStringList argList = QString::fromUtf8(args).split(' ', Qt::SkipEmptyParts);
        process->start(QString::fromUtf8(program), argList);
    }
}

// 启动命令（带参数数组，以NULL结尾）
void qProcessStartWithArgv(int64_t ptr, const char* program, const char** args, int argCount) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        QStringList argList;
        for (int i = 0; i < argCount; ++i) {
            argList.append(QString::fromUtf8(args[i]));
        }
        process->start(QString::fromUtf8(program), argList);
    }
}

// 启动命令字符串
void qProcessStartCommand(int64_t ptr, const char* command) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        process->startCommand(QString::fromUtf8(command));
    }
}

// 启动分离进程
int qProcessStartDetached(int64_t ptr) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        qint64 pid = 0;
        bool result = process->startDetached(&pid);
        return result ? static_cast<int>(pid) : -1;
    }
    return -1;
}

// 静态方法：启动分离进程
int qProcessStartDetachedStatic(const char* program, const char* args, const char* workingDir) {
    QStringList argList;
    if (args && strlen(args) > 0) {
        argList = QString::fromUtf8(args).split(' ', Qt::SkipEmptyParts);
    }
    qint64 pid = 0;
    bool result = QProcess::startDetached(
        QString::fromUtf8(program),
        argList,
        QString::fromUtf8(workingDir ? workingDir : ""),
        &pid
    );
    return result ? static_cast<int>(pid) : -1;
}

// 静态方法：执行并等待
int qProcessExecute(const char* program, const char* args) {
    QStringList argList;
    if (args && strlen(args) > 0) {
        argList = QString::fromUtf8(args).split(' ', Qt::SkipEmptyParts);
    }
    return QProcess::execute(QString::fromUtf8(program), argList);
}

// 等待
int qProcessWaitForStarted(int64_t ptr, int msecs) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        return process->waitForStarted(msecs) ? 1 : 0;
    }
    return 0;
}

int qProcessWaitForFinished(int64_t ptr, int msecs) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        return process->waitForFinished(msecs) ? 1 : 0;
    }
    return 0;
}

// 状态
int qProcessState(int64_t ptr) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        return static_cast<int>(process->state());
    }
    return 0; // NotRunning
}

int qProcessExitCode(int64_t ptr) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        return process->exitCode();
    }
    return -1;
}

int qProcessExitStatus(int64_t ptr) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        return static_cast<int>(process->exitStatus());
    }
    return 0; // NormalExit
}

int qProcessError(int64_t ptr) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        return static_cast<int>(process->error());
    }
    return 5; // UnknownError
}

// 进程ID
int64_t qProcessProcessId(int64_t ptr) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        return process->processId();
    }
    return 0;
}

// 终止
void qProcessKill(int64_t ptr) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        process->kill();
    }
}

void qProcessTerminate(int64_t ptr) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        process->terminate();
    }
}

// 设置程序和参数
void qProcessSetProgram(int64_t ptr, const char* program) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        process->setProgram(QString::fromUtf8(program));
    }
}

const char* qProcessProgram(int64_t ptr) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        return cjqt6::dupUtf8(process->program());
    }
    return cjqt6::emptyString();
}

void qProcessSetArguments(int64_t ptr, const char* args) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        QStringList argList = QString::fromUtf8(args).split(' ', Qt::SkipEmptyParts);
        process->setArguments(argList);
    }
}

const char* qProcessArguments(int64_t ptr) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        return cjqt6::dupUtf8(process->arguments().join(' '));
    }
    return cjqt6::emptyString();
}

// 工作目录
void qProcessSetWorkingDirectory(int64_t ptr, const char* dir) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        process->setWorkingDirectory(QString::fromUtf8(dir));
    }
}

const char* qProcessWorkingDirectory(int64_t ptr) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        return cjqt6::dupUtf8(process->workingDirectory());
    }
    return cjqt6::emptyString();
}

// 读写
int64_t qProcessWrite(int64_t ptr, const char* data) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        return process->write(data);
    }
    return -1;
}

int64_t qProcessWriteData(int64_t ptr, const char* data, int64_t len) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        return process->write(data, len);
    }
    return -1;
}

const char* qProcessReadAllStandardOutput(int64_t ptr) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        return cjqt6::dupUtf8(process->readAllStandardOutput());
    }
    return cjqt6::emptyString();
}

const char* qProcessReadAllStandardError(int64_t ptr) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        return cjqt6::dupUtf8(process->readAllStandardError());
    }
    return cjqt6::emptyString();
}

int64_t qProcessReadAllStandardOutputLength(int64_t ptr) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        return process->readAllStandardOutput().size();
    }
    return 0;
}

int64_t qProcessReadAllStandardErrorLength(int64_t ptr) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        return process->readAllStandardError().size();
    }
    return 0;
}

void qProcessCloseWriteChannel(int64_t ptr) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        process->closeWriteChannel();
    }
}

void qProcessCloseReadChannel(int64_t ptr, int channel) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        process->closeReadChannel(static_cast<QProcess::ProcessChannel>(channel));
    }
}

// 通道模式
void qProcessSetProcessChannelMode(int64_t ptr, int mode) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        process->setProcessChannelMode(static_cast<QProcess::ProcessChannelMode>(mode));
    }
}

int qProcessProcessChannelMode(int64_t ptr) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        return static_cast<int>(process->processChannelMode());
    }
    return 0;
}

void qProcessSetReadChannel(int64_t ptr, int channel) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        process->setReadChannel(static_cast<QProcess::ProcessChannel>(channel));
    }
}

int qProcessReadChannel(int64_t ptr) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process) {
        return static_cast<int>(process->readChannel());
    }
    return 0;
}

// ============================================================
// 信号回调
// ============================================================

void qProcessSetOnFinished(int64_t ptr, void (*callback)(int, int)) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process && callback) {
        dropConn(g_procFinishedConns, ptr);
        g_finishedCallbacks[ptr] = [callback](int exitCode, int exitStatus) {
            callback(exitCode, exitStatus);
        };
        replaceConn(g_procFinishedConns, ptr,
            QObject::connect(process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
                [ptr](int exitCode, QProcess::ExitStatus exitStatus) {
                    auto it = g_finishedCallbacks.find(ptr);
                    if (it != g_finishedCallbacks.end()) {
                        it->second(exitCode, static_cast<int>(exitStatus));
                    }
                }));
    }
}

void qProcessSetOnStarted(int64_t ptr, void (*callback)()) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process && callback) {
        dropConn(g_procStartedConns, ptr);
        g_startedCallbacks[ptr] = callback;
        replaceConn(g_procStartedConns, ptr,
            QObject::connect(process, &QProcess::started, [ptr]() {
                auto it = g_startedCallbacks.find(ptr);
                if (it != g_startedCallbacks.end()) {
                    it->second();
                }
            }));
    }
}

void qProcessSetOnReadyReadStandardOutput(int64_t ptr, void (*callback)()) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process && callback) {
        dropConn(g_procStdOutConns, ptr);
        g_readyReadStdOutCallbacks[ptr] = callback;
        replaceConn(g_procStdOutConns, ptr,
            QObject::connect(process, &QProcess::readyReadStandardOutput, [ptr]() {
                auto it = g_readyReadStdOutCallbacks.find(ptr);
                if (it != g_readyReadStdOutCallbacks.end()) {
                    it->second();
                }
            }));
    }
}

void qProcessSetOnReadyReadStandardError(int64_t ptr, void (*callback)()) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process && callback) {
        dropConn(g_procStdErrConns, ptr);
        g_readyReadStdErrCallbacks[ptr] = callback;
        replaceConn(g_procStdErrConns, ptr,
            QObject::connect(process, &QProcess::readyReadStandardError, [ptr]() {
                auto it = g_readyReadStdErrCallbacks.find(ptr);
                if (it != g_readyReadStdErrCallbacks.end()) {
                    it->second();
                }
            }));
    }
}

void qProcessSetOnErrorOccurred(int64_t ptr, void (*callback)(int)) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process && callback) {
        dropConn(g_procErrorConns, ptr);
        g_errorCallbacks[ptr] = callback;
        replaceConn(g_procErrorConns, ptr,
            QObject::connect(process, &QProcess::errorOccurred, [ptr](QProcess::ProcessError error) {
                auto it = g_errorCallbacks.find(ptr);
                if (it != g_errorCallbacks.end()) {
                    it->second(static_cast<int>(error));
                }
            }));
    }
}

void qProcessSetOnStateChanged(int64_t ptr, void (*callback)(int)) {
    QProcess* process = reinterpret_cast<QProcess*>(ptr);
    if (process && callback) {
        dropConn(g_procStateConns, ptr);
        g_stateChangedCallbacks[ptr] = callback;
        replaceConn(g_procStateConns, ptr,
            QObject::connect(process, &QProcess::stateChanged, [ptr](QProcess::ProcessState state) {
                auto it = g_stateChangedCallbacks.find(ptr);
                if (it != g_stateChangedCallbacks.end()) {
                    it->second(static_cast<int>(state));
                }
            }));
    }
}

// ============================================================
// 系统环境
// ============================================================

const char* qProcessSystemEnvironment() {
    return cjqt6::dupUtf8(QProcess::systemEnvironment().join('\n'));
}

// ============================================================
// QProcessEnvironment 桥接函数
// ============================================================

int64_t qProcessEnvironmentCreate() {
    QProcessEnvironment* env = new QProcessEnvironment();
    return reinterpret_cast<int64_t>(env);
}

int64_t qProcessEnvironmentCreateSystem() {
    QProcessEnvironment* env = new QProcessEnvironment(QProcessEnvironment::systemEnvironment());
    return reinterpret_cast<int64_t>(env);
}

void qProcessEnvironmentDelete(int64_t ptr) {
    QProcessEnvironment* env = reinterpret_cast<QProcessEnvironment*>(ptr);
    if (env) {
        delete env;
    }
}

void qProcessEnvironmentInsert(int64_t ptr, const char* name, const char* value) {
    QProcessEnvironment* env = reinterpret_cast<QProcessEnvironment*>(ptr);
    if (env) {
        env->insert(QString::fromUtf8(name), QString::fromUtf8(value));
    }
}

void qProcessEnvironmentRemove(int64_t ptr, const char* name) {
    QProcessEnvironment* env = reinterpret_cast<QProcessEnvironment*>(ptr);
    if (env) {
        env->remove(QString::fromUtf8(name));
    }
}

const char* qProcessEnvironmentValue(int64_t ptr, const char* name) {
    QProcessEnvironment* env = reinterpret_cast<QProcessEnvironment*>(ptr);
    if (env) {
        return cjqt6::dupUtf8(env->value(QString::fromUtf8(name)));
    }
    return cjqt6::emptyString();
}

int qProcessEnvironmentContains(int64_t ptr, const char* name) {
    QProcessEnvironment* env = reinterpret_cast<QProcessEnvironment*>(ptr);
    if (env) {
        return env->contains(QString::fromUtf8(name)) ? 1 : 0;
    }
    return 0;
}

void qProcessEnvironmentClear(int64_t ptr) {
    QProcessEnvironment* env = reinterpret_cast<QProcessEnvironment*>(ptr);
    if (env) {
        env->clear();
    }
}

int qProcessEnvironmentIsEmpty(int64_t ptr) {
    QProcessEnvironment* env = reinterpret_cast<QProcessEnvironment*>(ptr);
    if (env) {
        return env->isEmpty() ? 1 : 0;
    }
    return 1;
}

void qProcessSetProcessEnvironment(int64_t procPtr, int64_t envPtr) {
    QProcess* process = reinterpret_cast<QProcess*>(procPtr);
    QProcessEnvironment* env = reinterpret_cast<QProcessEnvironment*>(envPtr);
    if (process && env) {
        process->setProcessEnvironment(*env);
    }
}

} // extern "C"
