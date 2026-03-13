/**
 * @file bridge_dragdrop.cpp
 * @brief 拖放支持桥接函数 - QMimeData, QDrag, QDropEvent
 */

#include <QMimeData>
#include <QDrag>
#include <QDropEvent>
#include <QDragEnterEvent>
#include <QDragMoveEvent>
#include <QDragLeaveEvent>
#include <QApplication>
#include <QUrl>
#include <QStringList>
#include <QDebug>

extern "C" {

// ============================================================
// QMimeData 桥接函数
// ============================================================

int64_t qMimeDataCreate() {
    QMimeData* mimeData = new QMimeData();
    return reinterpret_cast<int64_t>(mimeData);
}

void qMimeDataSetText(int64_t ptr, const char* text) {
    QMimeData* mimeData = reinterpret_cast<QMimeData*>(ptr);
    if (mimeData) {
        mimeData->setText(QString::fromUtf8(text));
    }
}

const char* qMimeDataText(int64_t ptr) {
    QMimeData* mimeData = reinterpret_cast<QMimeData*>(ptr);
    if (mimeData) {
        static QByteArray buffer;
        buffer = mimeData->text().toUtf8();
        return buffer.constData();
    }
    return "";
}

void qMimeDataSetHtml(int64_t ptr, const char* html) {
    QMimeData* mimeData = reinterpret_cast<QMimeData*>(ptr);
    if (mimeData) {
        mimeData->setHtml(QString::fromUtf8(html));
    }
}

const char* qMimeDataHtml(int64_t ptr) {
    QMimeData* mimeData = reinterpret_cast<QMimeData*>(ptr);
    if (mimeData) {
        static QByteArray buffer;
        buffer = mimeData->html().toUtf8();
        return buffer.constData();
    }
    return "";
}

void qMimeDataSetUrls(int64_t ptr, const char** urls, int32_t count) {
    QMimeData* mimeData = reinterpret_cast<QMimeData*>(ptr);
    if (mimeData && urls) {
        QList<QUrl> urlList;
        for (int i = 0; i < count; i++) {
            urlList.append(QUrl::fromLocalFile(QString::fromUtf8(urls[i])));
        }
        mimeData->setUrls(urlList);
    }
}

int32_t qMimeDataUrlsCount(int64_t ptr) {
    QMimeData* mimeData = reinterpret_cast<QMimeData*>(ptr);
    if (mimeData) {
        return mimeData->urls().size();
    }
    return 0;
}

const char* qMimeDataUrlAt(int64_t ptr, int32_t index) {
    QMimeData* mimeData = reinterpret_cast<QMimeData*>(ptr);
    if (mimeData) {
        QList<QUrl> urls = mimeData->urls();
        if (index >= 0 && index < urls.size()) {
            static QByteArray buffer;
            buffer = urls[index].toString().toUtf8();
            return buffer.constData();
        }
    }
    return "";
}

void qMimeDataSetImageData(int64_t ptr, int64_t imagePtr) {
    QMimeData* mimeData = reinterpret_cast<QMimeData*>(ptr);
    QImage* image = reinterpret_cast<QImage*>(imagePtr);
    if (mimeData && image) {
        mimeData->setImageData(*image);
    }
}

bool qMimeDataHasText(int64_t ptr) {
    QMimeData* mimeData = reinterpret_cast<QMimeData*>(ptr);
    if (mimeData) {
        return mimeData->hasText();
    }
    return false;
}

bool qMimeDataHasHtml(int64_t ptr) {
    QMimeData* mimeData = reinterpret_cast<QMimeData*>(ptr);
    if (mimeData) {
        return mimeData->hasHtml();
    }
    return false;
}

bool qMimeDataHasUrls(int64_t ptr) {
    QMimeData* mimeData = reinterpret_cast<QMimeData*>(ptr);
    if (mimeData) {
        return mimeData->hasUrls();
    }
    return false;
}

bool qMimeDataHasImage(int64_t ptr) {
    QMimeData* mimeData = reinterpret_cast<QMimeData*>(ptr);
    if (mimeData) {
        return mimeData->hasImage();
    }
    return false;
}

void qMimeDataClear(int64_t ptr) {
    QMimeData* mimeData = reinterpret_cast<QMimeData*>(ptr);
    if (mimeData) {
        mimeData->clear();
    }
}

void qMimeDataDelete(int64_t ptr) {
    QMimeData* mimeData = reinterpret_cast<QMimeData*>(ptr);
    if (mimeData) {
        delete mimeData;
    }
}

// ============================================================
// QDrag 桥接函数
// ============================================================

int64_t qDragCreate(int64_t sourcePtr) {
    QObject* source = reinterpret_cast<QObject*>(sourcePtr);
    QDrag* drag = new QDrag(source);
    return reinterpret_cast<int64_t>(drag);
}

void qDragSetMimeData(int64_t ptr, int64_t mimeDataPtr) {
    QDrag* drag = reinterpret_cast<QDrag*>(ptr);
    QMimeData* mimeData = reinterpret_cast<QMimeData*>(mimeDataPtr);
    if (drag && mimeData) {
        drag->setMimeData(mimeData);
    }
}

void qDragSetPixmap(int64_t ptr, int64_t pixmapPtr) {
    QDrag* drag = reinterpret_cast<QDrag*>(ptr);
    QPixmap* pixmap = reinterpret_cast<QPixmap*>(pixmapPtr);
    if (drag && pixmap) {
        drag->setPixmap(*pixmap);
    }
}

void qDragSetHotSpot(int64_t ptr, int32_t x, int32_t y) {
    QDrag* drag = reinterpret_cast<QDrag*>(ptr);
    if (drag) {
        drag->setHotSpot(QPoint(x, y));
    }
}

int32_t qDragExec(int64_t ptr, int32_t supportedActions) {
    QDrag* drag = reinterpret_cast<QDrag*>(ptr);
    if (drag) {
        return static_cast<int32_t>(drag->exec(static_cast<Qt::DropActions>(supportedActions)));
    }
    return 0;
}

int32_t qDragExecWithDefault(int64_t ptr, int32_t supportedActions, int32_t defaultAction) {
    QDrag* drag = reinterpret_cast<QDrag*>(ptr);
    if (drag) {
        return static_cast<int32_t>(drag->exec(
            static_cast<Qt::DropActions>(supportedActions),
            static_cast<Qt::DropAction>(defaultAction)
        ));
    }
    return 0;
}

int64_t qDragSource(int64_t ptr) {
    QDrag* drag = reinterpret_cast<QDrag*>(ptr);
    if (drag) {
        return reinterpret_cast<int64_t>(drag->source());
    }
    return 0;
}

int64_t qDragTarget(int64_t ptr) {
    QDrag* drag = reinterpret_cast<QDrag*>(ptr);
    if (drag) {
        return reinterpret_cast<int64_t>(drag->target());
    }
    return 0;
}

void qDragCancel() {
    QDrag::cancel();
}

void qDragDelete(int64_t ptr) {
    QDrag* drag = reinterpret_cast<QDrag*>(ptr);
    if (drag) {
        // QDrag通常由Qt管理，不需要手动删除
    }
}

// ============================================================
// 拖放动作常量
// ============================================================

int32_t qDropActionCopy() { return static_cast<int32_t>(Qt::CopyAction); }
int32_t qDropActionMove() { return static_cast<int32_t>(Qt::MoveAction); }
int32_t qDropActionLink() { return static_cast<int32_t>(Qt::LinkAction); }
int32_t qDropActionIgnore() { return static_cast<int32_t>(Qt::IgnoreAction); }

int32_t qDropActionsCopy() { return static_cast<int32_t>(Qt::CopyAction); }
int32_t qDropActionsMove() { return static_cast<int32_t>(Qt::MoveAction); }
int32_t qDropActionsLink() { return static_cast<int32_t>(Qt::LinkAction); }

} // extern "C"
