/**
 * @file bridge_multimedia.cpp
 * @brief 多媒体桥接函数 - QMediaPlayer, QAudioOutput
 */

#include <QMediaPlayer>
#include <QAudioOutput>
#include <QUrl>
#include <QHash>
#include <QTimer>
#include <QMediaMetaData>

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
        } else if (keyStr == "duration") {
            value = metaData.value(QMediaMetaData::Duration);
        }
        
        static QByteArray buffer;
        buffer = value.toString().toUtf8();
        return buffer.constData();
    }
    return "";
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
        static QByteArray buffer;
        buffer = player->errorString().toUtf8();
        return buffer.constData();
    }
    return "";
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

} // extern "C"
