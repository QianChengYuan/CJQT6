package cjqt6_test.paint

import cjqt6.paint.*
import std.unittest.*

@Test
class BrushTests {
    @TestCase
    func testDefaultConstructor() {
        let brush = QBrush()
        @Expect(brush.isValid(), true)
        brush.delete()
        @Expect(brush.isValid(), false)
    }

    @TestCase
    func testColorConstructor() {
        let color = QColor(255, 128, 64)
        let brush = QBrush(color)
        @Expect(brush.isValid(), true)
        brush.delete()
        color.delete()
    }

    @TestCase
    func testSetters() {
        let brush = QBrush()
        let color = QColor(100, 150, 200)
        brush.setColor(color)
        @Expect(brush.isValid(), true)
        brush.delete()
        color.delete()
    }
}
