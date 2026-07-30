/**
 * @file bridge_animation.cpp
 * @brief QAbstractAnimation / QParallelAnimationGroup 桥接函数
 */

#include <QAbstractAnimation>
#include <QParallelAnimationGroup>
#include <QPropertyAnimation>
#include <QObject>

extern "C" {

// ============================================================
// QParallelAnimationGroup 桥接函数
// ============================================================

int64_t qParallelAnimationGroupCreate() {
    QParallelAnimationGroup* group = new QParallelAnimationGroup();
    return reinterpret_cast<int64_t>(group);
}

void qAnimationGroupAddAnimation(int64_t groupPtr, int64_t animPtr) {
    QParallelAnimationGroup* group = reinterpret_cast<QParallelAnimationGroup*>(groupPtr);
    QAbstractAnimation* anim = reinterpret_cast<QAbstractAnimation*>(animPtr);
    if (group && anim) {
        group->addAnimation(anim);
    }
}

void qAnimationGroupRemoveAnimation(int64_t groupPtr, int64_t animPtr) {
    QParallelAnimationGroup* group = reinterpret_cast<QParallelAnimationGroup*>(groupPtr);
    QAbstractAnimation* anim = reinterpret_cast<QAbstractAnimation*>(animPtr);
    if (group && anim) {
        group->removeAnimation(anim);
    }
}

int32_t qAnimationGroupAnimationCount(int64_t groupPtr) {
    QParallelAnimationGroup* group = reinterpret_cast<QParallelAnimationGroup*>(groupPtr);
    if (group) {
        return group->animationCount();
    }
    return 0;
}

// ============================================================
// QAbstractAnimation 桥接函数
// ============================================================

void qAbstractAnimationStart(int64_t ptr) {
    QAbstractAnimation* anim = reinterpret_cast<QAbstractAnimation*>(ptr);
    if (anim) {
        anim->start();
    }
}

void qAbstractAnimationStop(int64_t ptr) {
    QAbstractAnimation* anim = reinterpret_cast<QAbstractAnimation*>(ptr);
    if (anim) {
        anim->stop();
    }
}

void qAbstractAnimationPause(int64_t ptr) {
    QAbstractAnimation* anim = reinterpret_cast<QAbstractAnimation*>(ptr);
    if (anim) {
        anim->pause();
    }
}

void qAbstractAnimationResume(int64_t ptr) {
    QAbstractAnimation* anim = reinterpret_cast<QAbstractAnimation*>(ptr);
    if (anim) {
        anim->resume();
    }
}

int32_t qAbstractAnimationState(int64_t ptr) {
    QAbstractAnimation* anim = reinterpret_cast<QAbstractAnimation*>(ptr);
    if (anim) {
        return static_cast<int32_t>(anim->state());
    }
    return 0;
}

int64_t qAbstractAnimationDuration(int64_t ptr) {
    QAbstractAnimation* anim = reinterpret_cast<QAbstractAnimation*>(ptr);
    if (anim) {
        return anim->duration();
    }
    return 0;
}

void qAbstractAnimationSetLoopCount(int64_t ptr, int32_t count) {
    QAbstractAnimation* anim = reinterpret_cast<QAbstractAnimation*>(ptr);
    if (anim) {
        anim->setLoopCount(count);
    }
}

int32_t qAbstractAnimationLoopCount(int64_t ptr) {
    QAbstractAnimation* anim = reinterpret_cast<QAbstractAnimation*>(ptr);
    if (anim) {
        return anim->loopCount();
    }
    return 0;
}

int32_t qAbstractAnimationCurrentTime(int64_t ptr) {
    QAbstractAnimation* anim = reinterpret_cast<QAbstractAnimation*>(ptr);
    if (anim) {
        return static_cast<int32_t>(anim->currentTime());
    }
    return 0;
}

void qAbstractAnimationSetCurrentTime(int64_t ptr, int32_t ms) {
    QAbstractAnimation* anim = reinterpret_cast<QAbstractAnimation*>(ptr);
    if (anim) {
        anim->setCurrentTime(ms);
    }
}

int32_t qAbstractAnimationCurrentLoop(int64_t ptr) {
    QAbstractAnimation* anim = reinterpret_cast<QAbstractAnimation*>(ptr);
    if (anim) {
        return anim->currentLoop();
    }
    return 0;
}

void qAbstractAnimationSetDirection(int64_t ptr, int32_t direction) {
    QAbstractAnimation* anim = reinterpret_cast<QAbstractAnimation*>(ptr);
    if (anim) {
        anim->setDirection(static_cast<QAbstractAnimation::Direction>(direction));
    }
}

int32_t qAbstractAnimationDirection(int64_t ptr) {
    QAbstractAnimation* anim = reinterpret_cast<QAbstractAnimation*>(ptr);
    if (anim) {
        return static_cast<int32_t>(anim->direction());
    }
    return 0;
}

void qParallelAnimationGroupDelete(int64_t ptr) {
    QParallelAnimationGroup* group = reinterpret_cast<QParallelAnimationGroup*>(ptr);
    if (group) {
        delete group;
    }
}

void qAbstractAnimationDelete(int64_t ptr) {
    QAbstractAnimation* anim = reinterpret_cast<QAbstractAnimation*>(ptr);
    if (anim) {
        delete anim;
    }
}

} // extern "C"
