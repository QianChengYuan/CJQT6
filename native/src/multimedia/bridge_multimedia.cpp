/**
 * @file bridge_multimedia.cpp
 * @brief 多媒体桥接函数 - QMediaPlayer, QAudioOutput
 */

#include <QMediaPlayer>
#include <QAudioOutput>
#include <QUrl>
#include <QHash>

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

void qMediaPlayerDelete(int64_t ptr) {
    QMediaPlayer* player = reinterpret_cast<QMediaPlayer*>(ptr);
    if (player) {
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
