package cjqt6_test.ffi

import cjqt6.paint.*
import std.unittest.*

@Test
class LifecycleTests {
    @TestCase
    func testExplicitDelete() {
        let color = QColor(255, 128, 64)
        @Expect(color.isValid(), true)
        
        color.delete()
        @Expect(color.isValid(), false)
        @Expect(color.getPtr(), 0)
    }

    @TestCase
    func testMultipleDeleteSafe() {
        let color = QColor(100, 150, 200)
        color.delete()
        color.delete()
        @Expect(color.isValid(), false)
    }

    @TestCase
    func testObjectCreationDeletionCycle() {
        for (i in 0..100) {
            let color = QColor(i, i * 2, i * 3)
            @Expect(color.isValid(), true)
            color.delete()
        }
    }

    @TestCase
    func testComplexObjectLifecycle() {
        let color = QColor(255, 0, 0)
        let pen = QPen(color, 5)
        let brush = QBrush(color)
        
        @Expect(color.isValid(), true)
        @Expect(pen.isValid(), true)
        @Expect(brush.isValid(), true)
        
        pen.delete()
        brush.delete()
        color.delete()
        
        @Expect(color.isValid(), false)
        @Expect(pen.isValid(), false)
        @Expect(brush.isValid(), false)
    }
}
