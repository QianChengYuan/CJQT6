package tank_battle

import CJQT6.core.*
import CJQT6.widgets.*
import CJQT6.paint.*

var gApp: ?QApplication = None
var gWidget: ?QEventWidget = None
var gTimer: ?QTimer = None
var gCount: Int32 = 0

func onPaint(painterPtr: Int64): Unit {
    let painter = QPainter.fromPtr(painterPtr)
    painter.fillRectRgb(0, 0, 832, 892, 0, 0, 128)
    
    let pen = QPen()
    pen.setColor(QColor(255, 255, 0))
    painter.setPen(pen)
    painter.drawText(10, 30, "Count: ${gCount}")
}

func onTimer(): Unit {
    gCount++
    if (let Some(w) <- gWidget) {
        w.update()
    }
    if (gCount > 1000) {
        if (let Some(t) <- gTimer) {
            t.stop()
        }
        if (let Some(a) <- gApp) {
            a.quit()
        }
    }
}

main() {
    gApp = QApplication()
    gWidget = QEventWidget()
    gTimer = QTimer()
    
    if (let Some(w) <- gWidget) {
        w.resize(832, 892)
        w.setTitle("Minimal Test")
        w.setOnPaint({ painterPtr => onPaint(painterPtr) })
        w.show()
    }
    
    if (let Some(t) <- gTimer) {
        t.setInterval(16)
        t.setOnTimeout({ => onTimer() })
        t.start()
    }
    
    if (let Some(a) <- gApp) {
        a.exec()
    }
}
