/**
 * @file bridge_camera.cpp
 * @brief QCamera / QMediaCaptureSession / QMediaDevices 桥接函数
 */

#include <QCamera>
#include <QCameraDevice>
#include <QMediaCaptureSession>
#include <QMediaDevices>
#include <QImageCapture>
#include <QMediaRecorder>
#include <QVideoWidget>

extern "C" {

// ============================================================
// QMediaDevices 桥接函数
// ============================================================

int64_t qMediaDevicesDefaultVideoInput() {
    QCameraDevice device = QMediaDevices::defaultVideoInput();
    // 返回 QCameraDevice 的拷贝（值类型），通过堆分配保持指针有效
    QCameraDevice* dev = new QCameraDevice(device);
    return reinterpret_cast<int64_t>(dev);
}

int32_t qMediaDevicesVideoInputCount() {
    return QMediaDevices::videoInputs().size();
}

const char* qCameraDeviceDescription(int64_t ptr) {
    QCameraDevice* dev = reinterpret_cast<QCameraDevice*>(ptr);
    if (dev) {
        static QByteArray buffer;
        buffer = dev->description().toUtf8();
        return buffer.constData();
    }
    return "";
}

const char* qCameraDeviceId(int64_t ptr) {
    QCameraDevice* dev = reinterpret_cast<QCameraDevice*>(ptr);
    if (dev) {
        static QByteArray buffer;
        buffer = dev->id();
        return buffer.constData();
    }
    return "";
}

void qCameraDeviceDelete(int64_t ptr) {
    QCameraDevice* dev = reinterpret_cast<QCameraDevice*>(ptr);
    if (dev) {
        delete dev;
    }
}

// ============================================================
// QCamera 桥接函数
// ============================================================

int64_t qCameraCreate(int64_t devicePtr) {
    QCameraDevice* dev = reinterpret_cast<QCameraDevice*>(devicePtr);
    QCamera* camera = nullptr;
    if (dev) {
        camera = new QCamera(*dev);
    } else {
        camera = new QCamera();
    }
    return reinterpret_cast<int64_t>(camera);
}

void qCameraStart(int64_t ptr) {
    QCamera* camera = reinterpret_cast<QCamera*>(ptr);
    if (camera) {
        camera->start();
    }
}

void qCameraStop(int64_t ptr) {
    QCamera* camera = reinterpret_cast<QCamera*>(ptr);
    if (camera) {
        camera->stop();
    }
}

int32_t qCameraIsActive(int64_t ptr) {
    QCamera* camera = reinterpret_cast<QCamera*>(ptr);
    if (camera) {
        return camera->isActive() ? 1 : 0;
    }
    return 0;
}

int32_t qCameraErrorCode(int64_t ptr) {
    QCamera* camera = reinterpret_cast<QCamera*>(ptr);
    if (camera) {
        return static_cast<int32_t>(camera->error());
    }
    return 0;
}

const char* qCameraErrorString(int64_t ptr) {
    QCamera* camera = reinterpret_cast<QCamera*>(ptr);
    if (camera) {
        static QByteArray buffer;
        buffer = camera->errorString().toUtf8();
        return buffer.constData();
    }
    return "";
}

void qCameraDelete(int64_t ptr) {
    QCamera* camera = reinterpret_cast<QCamera*>(ptr);
    if (camera) {
        delete camera;
    }
}

// ============================================================
// QMediaCaptureSession 桥接函数
// ============================================================

int64_t qMediaCaptureSessionCreate() {
    QMediaCaptureSession* session = new QMediaCaptureSession();
    return reinterpret_cast<int64_t>(session);
}

void qMediaCaptureSessionSetCamera(int64_t ptr, int64_t cameraPtr) {
    QMediaCaptureSession* session = reinterpret_cast<QMediaCaptureSession*>(ptr);
    QCamera* camera = reinterpret_cast<QCamera*>(cameraPtr);
    if (session && camera) {
        session->setCamera(camera);
    }
}

void qMediaCaptureSessionSetVideoOutput(int64_t ptr, int64_t outputPtr) {
    QMediaCaptureSession* session = reinterpret_cast<QMediaCaptureSession*>(ptr);
    QVideoWidget* output = reinterpret_cast<QVideoWidget*>(outputPtr);
    if (session && output) {
        session->setVideoOutput(output);
    }
}

void qMediaCaptureSessionDelete(int64_t ptr) {
    QMediaCaptureSession* session = reinterpret_cast<QMediaCaptureSession*>(ptr);
    if (session) {
        delete session;
    }
}

} // extern "C"
