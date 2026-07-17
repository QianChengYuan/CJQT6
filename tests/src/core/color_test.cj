package cjqt6_test.core

import cjqt6.paint.*
import std.unittest.*

@Test
class ColorTests {
    @TestCase
    func testDefaultConstructor() {
        let color = QColor()
        @Expect(color.isValid(), true)
        color.delete()
        @Expect(color.isValid(), false)
    }

    @TestCase
    func testRGBConstructor() {
        let color = QColor(255, 128, 64)
        @Expect(color.red(), 255)
        @Expect(color.green(), 128)
        @Expect(color.blue(), 64)
        @Expect(color.alpha(), 255)
        color.delete()
    }

    @TestCase
    func testRGBAConstructor() {
        let color = QColor.rgba(100, 150, 200, 128)
        @Expect(color.red(), 100)
        @Expect(color.green(), 150)
        @Expect(color.blue(), 200)
        @Expect(color.alpha(), 128)
        color.delete()
    }

    @TestCase
    func testFromName() {
        let red = QColor.fromName("red")
        @Expect(red.red(), 255)
        @Expect(red.green(), 0)
        @Expect(red.blue(), 0)
        red.delete()
        
        let blue = QColor.fromName("blue")
        @Expect(blue.red(), 0)
        @Expect(blue.blue(), 255)
        blue.delete()
    }

    @TestCase
    func testSetters() {
        let color = QColor()
        color.setRed(100)
        @Expect(color.red(), 100)
        
        color.setGreen(150)
        @Expect(color.green(), 150)
        
        color.setBlue(200)
        @Expect(color.blue(), 200)
        
        color.setAlpha(128)
        @Expect(color.alpha(), 128)
        color.delete()
    }

    @TestCase
    func testMultipleObjects() {
        let c1 = QColor(255, 0, 0)
        let c2 = QColor(0, 255, 0)
        let c3 = QColor(0, 0, 255)
        
        @Expect(c1.red(), 255)
        @Expect(c2.green(), 255)
        @Expect(c3.blue(), 255)
        
        c1.delete()
        c2.delete()
        c3.delete()
    }
}
