/**
 * @file bridge_multimedia.cpp
 * @brief 多媒体桥接函数 - QMediaPlayer, QAudioOutput
 */

#include <QMediaPlayer>
#include <QAudioOutput>
#include <QSoundEffect>
#include <QImageCapture>
#include <QUrl>
#include <QHash>
#include <QTimer>
#include <QMediaMetaData>
#include "bridge_string_utils.h"

// 存储播放器状态变化的回调
static QHash<int64_t, std::function<void(int)>> stateCallbacks;
static QHash<int64_t, std::function<void(int64_t)>> positionCallbacks;
static QHash<int64_t, std::function<void(int64_t)>> durationCallbacks;

extern "C" {

// ============================================================
// QMediaPlayer 桥接函数
// ============================================================

int64_t qMediaPlayerCreate() {
    QMediaPlayer* player = new QMediaPlayer();
    return reinterpret_cast<int64_t>(player);
}

void qMediaPlayerSetSource(int64_t ptr, const char* url) {
    QMediaPlayer* player = reinterpret_cast<QMediaPlayer*>(ptr);
    if (player) {
        player->setSource(QUrl(QString::fromUtf8(url)));
    }
}

void qMediaPlayerSetSourceFile(int64_t ptr, const char* filePath) {
    QMediaPlayer* player = reinterpret_cast<QMediaPlayer*>(ptr);
    if (player) {
        player->setSource(QUrl::fromLocalFile(QString::fromUtf8(filePath)));
    }
}

void qMediaPlayerSetAudioOutput(int64_t ptr, int64_t outputPtr) {
    QMediaPlayer* player = reinterpret_cast<QMediaPlayer*>(ptr);
    QAudioOutput* output = reinterpret_cast<QAudioOutput*>(outputPtr);
    if (player && output) {
        player->setAudioOutput(output);
    }
}

void qMediaPlayerPlay(int64_t ptr) {
    QMediaPlayer* player = reinterpret_cast<QMediaPlayer*>(ptr);
    if (player) {
        player->play();
    }
}

void qMediaPlayerPause(int64_t ptr) {
    QMediaPlayer* player = reinterpret_cast<QMediaPlayer*>(ptr);
    if (player) {
        player->pause();
    }
}

void qMediaPlayerStop(int64_t ptr) {
    QMediaPlayer* player = reinterpret_cast<QMediaPlayer*>(ptr);
    if (player) {
        player->stop();
    }
}

void qMediaPlayerSetPosition(int64_t ptr, int64_t position) {
    QMediaPlayer* player = reinterpret_cast<QMediaPlayer*>(ptr);
    if (player) {
        player->setPosition(position);
    }
}

int64_t qMediaPlayerPosition(int64_t ptr) {
    QMediaPlayer* player = reinterpret_cast<QMediaPlayer*>(ptr);
    if (player) {
        return player->position();
    }
    return 0;
}

int64_t qMediaPlayerDuration(int64_t ptr) {
    QMediaPlayer* player = reinterpret_cast<QMediaPlayer*>(ptr);
    if (player) {
        return player->duration();
    }
    return 0;
}

void qMediaPlayerSetVolume(int64_t ptr, float volume) {
    QMediaPlayer* player = reinterpret_cast<QMediaPlayer*>(ptr);
    if (player) {
        QAudioOutput* output = player->audioOutput();
        if (output) {
            output->setVolume(volume);
        }
    }
}

float qMediaPlayerVolume(int64_t ptr) {
    QMediaPlayer* player = reinterpret_cast<QMediaPlayer*>(ptr);
    if (player) {
        QAudioOutput* output = player->audioOutput();
        if (output) {
            return output->volume();
        }
    }
    return 0.0f;
}

int32_t qMediaPlayerPlaybackState(int64_t ptr) {
    QMediaPlayer* player = reinterpret_cast<QMediaPlayer*>(ptr);
    if (player) {
        return static_cast<int32_t>(player->playbackState());
    }
    return 0;
}

void qMediaPlayerSetLoops(int64_t ptr, int32_t loops) {
    QMediaPlayer* player = reinterpret_cast<QMediaPlayer*>(ptr);
    if (player) {
        player->setLoops(loops);
    }
}

// 播放速度 (0.5 - 4.0)
void qMediaPlayerSetPlaybackRate(int64_t ptr, float rate) {
    QMediaPlayer* player = reinterpret_cast<QMediaPlayer*>(ptr);
    if (player) {
        player->setPlaybackRate(rate);
    }
}

float qMediaPlayerPlaybackRate(int64_t ptr) {
    QMediaPlayer* player = reinterpret_cast<QMediaPlayer*>(ptr);
    if (player) {
        return player->playbackRate();
    }
    return 1.0f;
}

// 媒体元数据
const char* qMediaPlayerMetaData(int64_t ptr, const char* key) {
    QMediaPlayer* player = reinterpret_cast<QMediaPlayer*>(ptr);
    if (player) {
        QMediaMetaData metaData = player->metaData();
        QString keyStr = QString::fromUtf8(key);
        
        QVariant value;
        if (keyStr == "title") {
            value = metaData.value(QMediaMetaData::Title);
        } else if (keyStr == "author" || keyStr == "artist") {
            value = metaData.value(QMediaMetaData::Author);
        } else if (keyStr == "album") {
            value = metaData.value(QMediaMetaData::AlbumTitle);
        } else         if (keyStr == "duration") {
            value = metaData.value(QMediaMetaData::Duration);
        }
        
        return cjqt6::dupUtf8(value.toString());
    }
    return cjqt6::emptyString();
}

// 是否可播放
bool qMediaPlayerIsSeekable(int64_t ptr) {
    QMediaPlayer* player = reinterpret_cast<QMediaPlayer*>(ptr);
    if (player) {
        return player->isSeekable();
    }
    return false;
}

// 是否有音频
bool qMediaPlayerHasAudio(int64_t ptr) {
    QMediaPlayer* player = reinterpret_cast<QMediaPlayer*>(ptr);
    if (player) {
        return player->hasAudio();
    }
    return false;
}

// 媒体状态
int32_t qMediaPlayerMediaStatus(int64_t ptr) {
    QMediaPlayer* player = reinterpret_cast<QMediaPlayer*>(ptr);
    if (player) {
        return static_cast<int32_t>(player->mediaStatus());
    }
    return 0;
}

// 错误信息
int32_t qMediaPlayerError(int64_t ptr) {
    QMediaPlayer* player = reinterpret_cast<QMediaPlayer*>(ptr);
    if (player) {
        return static_cast<int32_t>(player->error());
    }
    return 0;
}

const char* qMediaPlayerErrorString(int64_t ptr) {
    QMediaPlayer* player = reinterpret_cast<QMediaPlayer*>(ptr);
    if (player) {
        return cjqt6::dupUtf8(player->errorString());
    }
    return cjqt6::emptyString();
}

// ============================================================
// 信号回调注册函数
// ============================================================

// 播放位置变化回调类型
typedef void (*PositionCallback)(int64_t position);

// 播放时长变化回调类型
typedef void (*DurationCallback)(int64_t duration);

// 播放状态变化回调类型
typedef void (*StateCallback)(int32_t state);

// 媒体状态变化回调类型
typedef void (*MediaStatusCallback)(int32_t status);

// 注册位置变化回调
void qMediaPlayerOnPositionChanged(int64_t ptr, PositionCallback callback) {
    QMediaPlayer* player = reinterpret_cast<QMediaPlayer*>(ptr);
    if (player && callback) {
        QObject::connect(player, &QMediaPlayer::positionChanged, [callback](qint64 position) {
            callback(position);
        });
    }
}

// 注册时长变化回调
void qMediaPlayerOnDurationChanged(int64_t ptr, DurationCallback callback) {
    QMediaPlayer* player = reinterpret_cast<QMediaPlayer*>(ptr);
    if (player && callback) {
        QObject::connect(player, &QMediaPlayer::durationChanged, [callback](qint64 duration) {
            callback(duration);
        });
    }
}

// 注册播放状态变化回调
void qMediaPlayerOnPlaybackStateChanged(int64_t ptr, StateCallback callback) {
    QMediaPlayer* player = reinterpret_cast<QMediaPlayer*>(ptr);
    if (player && callback) {
        QObject::connect(player, &QMediaPlayer::playbackStateChanged, [callback](QMediaPlayer::PlaybackState state) {
            callback(static_cast<int32_t>(state));
        });
    }
}

// 注册媒体状态变化回调
void qMediaPlayerOnMediaStatusChanged(int64_t ptr, MediaStatusCallback callback) {
    QMediaPlayer* player = reinterpret_cast<QMediaPlayer*>(ptr);
    if (player && callback) {
        QObject::connect(player, &QMediaPlayer::mediaStatusChanged, [callback](QMediaPlayer::MediaStatus status) {
            callback(static_cast<int32_t>(status));
        });
    }
}

void qMediaPlayerDelete(int64_t ptr) {
    QMediaPlayer* player = reinterpret_cast<QMediaPlayer*>(ptr);
    if (player) {
        stateCallbacks.remove(ptr);
        positionCallbacks.remove(ptr);
        durationCallbacks.remove(ptr);
        delete player;
    }
}

// ============================================================
// QAudioOutput 桥接函数
// ============================================================

int64_t qAudioOutputCreate() {
    QAudioOutput* output = new QAudioOutput();
    return reinterpret_cast<int64_t>(output);
}

void qAudioOutputSetVolume(int64_t ptr, float volume) {
    QAudioOutput* output = reinterpret_cast<QAudioOutput*>(ptr);
    if (output) {
        output->setVolume(volume);
    }
}

float qAudioOutputVolume(int64_t ptr) {
    QAudioOutput* output = reinterpret_cast<QAudioOutput*>(ptr);
    if (output) {
        return output->volume();
    }
    return 0.0f;
}

void qAudioOutputSetMuted(int64_t ptr, bool muted) {
    QAudioOutput* output = reinterpret_cast<QAudioOutput*>(ptr);
    if (output) {
        output->setMuted(muted);
    }
}

bool qAudioOutputIsMuted(int64_t ptr) {
    QAudioOutput* output = reinterpret_cast<QAudioOutput*>(ptr);
    if (output) {
        return output->isMuted();
    }
    return false;
}

void qAudioOutputDelete(int64_t ptr) {
    QAudioOutput* output = reinterpret_cast<QAudioOutput*>(ptr);
    if (output) {
        delete output;
    }
}

// ============================================================
// QSoundEffect 桥接函数
// ============================================================

int64_t qSoundEffectCreate() {
    QSoundEffect* effect = new QSoundEffect();
    return reinterpret_cast<int64_t>(effect);
}

void qSoundEffectSetSource(int64_t ptr, const char* url) {
    QSoundEffect* effect = reinterpret_cast<QSoundEffect*>(ptr);
    if (effect) {
        effect->setSource(QUrl(QString::fromUtf8(url)));
    }
}

void qSoundEffectSetSourceFile(int64_t ptr, const char* filePath) {
    QSoundEffect* effect = reinterpret_cast<QSoundEffect*>(ptr);
    if (effect) {
        effect->setSource(QUrl::fromLocalFile(QString::fromUtf8(filePath)));
    }
}

void qSoundEffectSetVolume(int64_t ptr, double volume) {
    QSoundEffect* effect = reinterpret_cast<QSoundEffect*>(ptr);
    if (effect) {
        effect->setVolume(volume);
    }
}

double qSoundEffectVolume(int64_t ptr) {
    QSoundEffect* effect = reinterpret_cast<QSoundEffect*>(ptr);
    if (effect) {
        return effect->volume();
    }
    return 0.0;
}

void qSoundEffectSetLoopCount(int64_t ptr, int32_t count) {
    QSoundEffect* effect = reinterpret_cast<QSoundEffect*>(ptr);
    if (effect) {
        effect->setLoopCount(count);
    }
}

int32_t qSoundEffectLoopCount(int64_t ptr) {
    QSoundEffect* effect = reinterpret_cast<QSoundEffect*>(ptr);
    if (effect) {
        return effect->loopCount();
    }
    return 0;
}

void qSoundEffectSetMuted(int64_t ptr, bool muted) {
    QSoundEffect* effect = reinterpret_cast<QSoundEffect*>(ptr);
    if (effect) {
        effect->setMuted(muted);
    }
}

bool qSoundEffectIsMuted(int64_t ptr) {
    QSoundEffect* effect = reinterpret_cast<QSoundEffect*>(ptr);
    if (effect) {
        return effect->isMuted();
    }
    return false;
}

bool qSoundEffectIsPlaying(int64_t ptr) {
    QSoundEffect* effect = reinterpret_cast<QSoundEffect*>(ptr);
    if (effect) {
        return effect->isPlaying();
    }
    return false;
}

void qSoundEffectPlay(int64_t ptr) {
    QSoundEffect* effect = reinterpret_cast<QSoundEffect*>(ptr);
    if (effect) {
        effect->play();
    }
}

void qSoundEffectStop(int64_t ptr) {
    QSoundEffect* effect = reinterpret_cast<QSoundEffect*>(ptr);
    if (effect) {
        effect->stop();
    }
}

int32_t qSoundEffectStatus(int64_t ptr) {
    QSoundEffect* effect = reinterpret_cast<QSoundEffect*>(ptr);
    if (effect) {
        return static_cast<int32_t>(effect->status());
    }
    return 0;
}

void qSoundEffectDelete(int64_t ptr) {
    QSoundEffect* effect = reinterpret_cast<QSoundEffect*>(ptr);
    if (effect) {
        delete effect;
    }
}

// ============================================================
// QImageCapture 桥接函数
// ============================================================

int64_t qImageCaptureCreate() {
    return reinterpret_cast<int64_t>(new QImageCapture());
}

void qImageCaptureDelete(int64_t ptr) {
    delete reinterpret_cast<QImageCapture*>(ptr);
}

void qImageCaptureSetCamera(int64_t ptr, int64_t cameraPtr) {
    QImageCapture* cap = reinterpret_cast<QImageCapture*>(ptr);
    // QCamera is managed separately; we just call capture()
    (void)cap;
    (void)cameraPtr;
}

int32_t qImageCaptureCapture(int64_t ptr) {
    QImageCapture* cap = reinterpret_cast<QImageCapture*>(ptr);
    if (cap) return cap->capture();
    return -1;
}

int32_t qImageCaptureCaptureToFile(int64_t ptr, const char* path) {
    QImageCapture* cap = reinterpret_cast<QImageCapture*>(ptr);
    if (cap) return cap->captureToFile(QString::fromUtf8(path));
    return -1;
}

bool qImageCaptureIsReadyForCapture(int64_t ptr) {
    QImageCapture* cap = reinterpret_cast<QImageCapture*>(ptr);
    return cap ? cap->isReadyForCapture() : false;
}

void qImageCaptureSetQuality(int64_t ptr, int32_t quality) {
    QImageCapture* cap = reinterpret_cast<QImageCapture*>(ptr);
    if (cap) cap->setQuality(static_cast<QImageCapture::Quality>(quality));
}

int32_t qImageCaptureQuality(int64_t ptr) {
    QImageCapture* cap = reinterpret_cast<QImageCapture*>(ptr);
    return cap ? static_cast<int32_t>(cap->quality()) : 0;
}

} // extern "C"
