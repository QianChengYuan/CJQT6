package qq_chat.app

import cjqt6.paint.*
import cjqt6.gui.*

public let PENGUIN_LOGO_PATH = "resources/penguin_logo.png"
public let PENGUIN_SMALL_PATH = "resources/penguin_small.png"
public let KEYBOARD_ICON_PATH = "resources/keyboard_icon.png"

public func loadPenguinLogo(size: Int32): ?QPixmap {
    let pm = QPixmap.load(PENGUIN_LOGO_PATH)
    if (!pm.isValid()) {
        pm.delete()
        return None
    }
    return Some(pm)
}

public func loadPenguinSmall(size: Int32): ?QPixmap {
    let pm = QPixmap.load(PENGUIN_SMALL_PATH)
    if (!pm.isValid()) {
        pm.delete()
        return None
    }
    return Some(pm)
}

public func loadKeyboardIcon(size: Int32): ?QPixmap {
    let pm = QPixmap.load(KEYBOARD_ICON_PATH)
    if (!pm.isValid()) {
        pm.delete()
        return None
    }
    return Some(pm)
}

public func loadStatusIcon(status: String, size: Int32): QPixmap {
    let pm = QPixmap.withSize(size, size)
    let color = if (status == "online") {
        QColor(0, 200, 0)
    } else if (status == "away") {
        QColor(255, 165, 0)
    } else if (status == "busy") {
        QColor(255, 0, 0)
    } else {
        QColor(128, 128, 128)
    }
    pm.fill(color)
    let painter = QPainter(pm.getPtr())
    painter.setPenColor(QColor(0, 0, 0))
    painter.drawCircle(size / 2, size / 2, size / 2 - 1)
    painter.end()
    color.delete()
    pm
}