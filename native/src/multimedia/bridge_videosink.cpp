/**
 * @file bridge_videosink.cpp
 * @brief QVideoSink 桥接函数
 *
 * Qt 6.10.3 的 QVideoSink 继承自 QObject，API 包括：
 * - videoSize(): 视频帧尺寸
 * - subtitleText()/setSubtitleText(): 字幕文本
 * - setVideoFrame()/videoFrame(): 视频帧（需 QVideoFrame 封装，暂不桥接）
 * - 信号: videoFrameChanged, subtitleTextChanged, videoSizeChanged
 *
 * 注意：Qt5/Qt6 早期版本的 brightness/contrast/hue/saturation 属性
 * 在 Qt 6.10.3 中已不存在，视频调节需通过着色器或帧处理实现。
 */

#include <QVideoSink>
#include <QSize>
#include "bridge_string_utils.h"

extern "C" {

// ============================================================
// QVideoSink 桥接函数
// ============================================================

int64_t qVideoSinkCreate() {
    QVideoSink* sink = new QVideoSink();
    return reinterpret_cast<int64_t>(sink);
}

void qVideoSinkDelete(int64_t ptr) {
    QVideoSink* sink = reinterpret_cast<QVideoSink*>(ptr);
    if (sink) {
        delete sink;
    }
}

// ============================================================
// 视频尺寸 (videoSize)
// ============================================================

int32_t qVideoSinkVideoWidth(int64_t ptr) {
    QVideoSink* sink = reinterpret_cast<QVideoSink*>(ptr);
    if (sink) {
        return static_cast<int32_t>(sink->videoSize().width());
    }
    return 0;
}

int32_t qVideoSinkVideoHeight(int64_t ptr) {
    QVideoSink* sink = reinterpret_cast<QVideoSink*>(ptr);
    if (sink) {
        return static_cast<int32_t>(sink->videoSize().height());
    }
    return 0;
}

// ============================================================
// 字幕文本 (subtitleText)
// ============================================================

void qVideoSinkSetSubtitleText(int64_t ptr, const char* text) {
    QVideoSink* sink = reinterpret_cast<QVideoSink*>(ptr);
    if (sink && text) {
        sink->setSubtitleText(QString::fromUtf8(text));
    }
}

const char* qVideoSinkSubtitleText(int64_t ptr) {
    QVideoSink* sink = reinterpret_cast<QVideoSink*>(ptr);
    if (sink) {
        // 修复：原实现返回临时 QByteArray 的 constData（悬垂）与字面量 ""（free 崩溃），
        // 统一改为 dupUtf8/emptyString（std::malloc，仓颉侧 freeBridgeString 释放）
        return cjqt6::dupUtf8(sink->subtitleText());
    }
    return cjqt6::emptyString();
}

} // extern "C"
