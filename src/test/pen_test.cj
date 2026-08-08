package cjqt6.test

import cjqt6.paint.*
import std.unittest.*

@Test
class PenTests {
    @TestCase
    func testDefaultConstructor() {
        let pen = QPen()
        @Expect(pen.isValid(), true)
        pen.delete()
        @Expect(pen.isValid(), false)
    }

    @TestCase
    func testColorWidthConstructor() {
        let color = QColor(255, 0, 0)
        let pen = QPen(color)
        pen.setWidth(5)
        @Expect(pen.width(), 5)
        pen.delete()
        color.delete()
    }

    @TestCase
    func testSetters() {
        let pen = QPen()
        let color = QColor(0, 128, 255)
        pen.setColor(color)
        pen.setWidth(3)
        @Expect(pen.width(), 3)
        pen.delete()
        color.delete()
    }
}
