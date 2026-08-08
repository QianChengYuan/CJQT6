package cjqt6.test

import cjqt6.paint.*
import cjqt6.widgets.*
import std.unittest.*

@Test
class BridgeTests {
    @TestCase
    func testPointerValidity() {
        let color = QColor(255, 0, 0)
        @Expect(color.getPtr() != 0, true)
        @Expect(color.isValid(), true)
        
        color.delete()
        @Expect(color.getPtr(), 0)
        @Expect(color.isValid(), false)
    }

    @TestCase
    func testMultipleObjectsIndependence() {
        let c1 = QColor(255, 0, 0)
        let c2 = QColor(0, 255, 0)
        let c3 = QColor(0, 0, 255)
        
        @Expect(c1.getPtr() != c2.getPtr(), true)
        @Expect(c2.getPtr() != c3.getPtr(), true)
        @Expect(c1.getPtr() != c3.getPtr(), true)
        
        c1.delete()
        c2.delete()
        c3.delete()
    }

    @TestCase
    func testNullPointerHandling() {
        let color = QColor()
        color.delete()
        @Expect(color.isValid(), false)
        @Expect(color.getPtr(), 0)
    }
}
