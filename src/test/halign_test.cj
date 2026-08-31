package cjqt6.test

import cjqt6.gui.*
import std.unittest.*

@Test
class HAlignTests {
    // 简洁数字常量约定：0=居中, 1=左对齐, 2=右对齐
    @TestCase
    func testValues() {
        @Expect(HAlign.Center, 0)
        @Expect(HAlign.Left, 1)
        @Expect(HAlign.Right, 2)
    }

    // 到 Qt 对齐位标志（Int32）的映射
    @TestCase
    func testToAlignment() {
        @Expect(HAlign.toAlignment(HAlign.Center), Alignment.Center.value)
        @Expect(HAlign.toAlignment(HAlign.Left), Alignment.Default.value)
        @Expect(HAlign.toAlignment(HAlign.Right), Alignment.Right.value + Alignment.VCenter.value)
        // 非法值回落默认（左对齐 | 垂直居中）
        @Expect(HAlign.toAlignment(99), Alignment.Default.value)
    }
}
