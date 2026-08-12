package cjqt6.test

// =====================================================================
// 撤销栈模块测试（src/core/undostack.cj）
// 覆盖：QUndoCommand / QUndoStack + UndoRedoCallback 类型
// =====================================================================

import cjqt6.core.*
import std.unittest.*

// 全局回调状态（CFunc Lambda 不捕获局部变量，仅访问全局变量）
var gUndoCount: Int32 = 0
var gRedoCount: Int32 = 0
var gLastUndoData: Int64 = 0
var gLastRedoData: Int64 = 0

let gUndoCb: CFunc<(Int64) -> Unit> = { userData: Int64 =>
    gUndoCount += 1
    gLastUndoData = userData
}

let gRedoCb: CFunc<(Int64) -> Unit> = { userData: Int64 =>
    gRedoCount += 1
    gLastRedoData = userData
}

let gUndoCb2: CFunc<(Int64) -> Unit> = { userData: Int64 => () }
let gRedoCb2: CFunc<(Int64) -> Unit> = { userData: Int64 => () }

// ---------------------------------------------------------------------
// QUndoCommand 测试
// ---------------------------------------------------------------------
@Test
class QUndoCommandTests {
    @TestCase
    func testCreate() {
        let cmd = QUndoCommand(gUndoCb, gRedoCb, 100, "添加")
        @Assert(cmd.getPtr() != 0)
        @Expect(cmd.isPushed(), false)
        @Expect(cmd.text(), "添加")
        cmd.delete()
    }

    @TestCase
    func testSetTextRoundtrip() {
        let cmd = QUndoCommand(gUndoCb, gRedoCb, 0, "old")
        @Expect(cmd.text(), "old")
        cmd.setText("new")
        @Expect(cmd.text(), "new")
        cmd.delete()
    }

    @TestCase
    func testMarkPushed() {
        let cmd = QUndoCommand(gUndoCb, gRedoCb, 0, "x")
        @Expect(cmd.isPushed(), false)
        cmd.markPushed()
        @Expect(cmd.isPushed(), true)
        // 已标记 pushed，delete 不实际删除（由栈管理）
        cmd.delete()
        @Assert(true)
    }

    @TestCase
    func testDoubleDelete() {
        let cmd = QUndoCommand(gUndoCb, gRedoCb, 0, "x")
        cmd.delete()
        cmd.delete()  // 安全
        @Assert(true)
    }

    @TestCase
    func testCreateWithDifferentCallbacks() {
        let cmd = QUndoCommand(gUndoCb2, gRedoCb2, 42, "操作")
        @Expect(cmd.text(), "操作")
        cmd.delete()
    }
}

// ---------------------------------------------------------------------
// QUndoStack 测试
// ---------------------------------------------------------------------
@Test
class QUndoStackTests {
    @TestCase
    func testCreate() {
        let stack = QUndoStack()
        @Assert(stack.getPtr() != 0)
        @Expect(stack.count(), 0)
        @Expect(stack.index(), 0)
        @Expect(stack.canUndo(), false)
        @Expect(stack.canRedo(), false)
        @Expect(stack.isClean(), true)
        stack.close()
    }

    @TestCase
    func testPushSingleCommand() {
        gUndoCount = 0
        gRedoCount = 0
        let stack = QUndoStack()
        let cmd = QUndoCommand(gUndoCb, gRedoCb, 1, "操作1")
        stack.push(cmd)
        @Expect(stack.count(), 1)
        @Expect(stack.index(), 1)
        @Expect(stack.canUndo(), true)
        @Expect(stack.canRedo(), false)
        @Expect(cmd.isPushed(), true)
        stack.close()
    }

    @TestCase
    func testPushMultipleCommands() {
        let stack = QUndoStack()
        let c1 = QUndoCommand(gUndoCb, gRedoCb, 1, "op1")
        let c2 = QUndoCommand(gUndoCb, gRedoCb, 2, "op2")
        let c3 = QUndoCommand(gUndoCb, gRedoCb, 3, "op3")
        stack.push(c1)
        stack.push(c2)
        stack.push(c3)
        @Expect(stack.count(), 3)
        @Expect(stack.index(), 3)
        @Expect(stack.canUndo(), true)
        stack.close()
    }

    @TestCase
    func testUndoRedo() {
        gUndoCount = 0
        gRedoCount = 0
        let stack = QUndoStack()
        let cmd = QUndoCommand(gUndoCb, gRedoCb, 7, "操作")
        stack.push(cmd)
        @Expect(stack.canUndo(), true)
        // push 会触发一次 redo
        @Expect(gRedoCount, 1)
        stack.undo()
        @Expect(gUndoCount, 1)
        @Expect(gLastUndoData, 7)
        @Expect(stack.canRedo(), true)
        @Expect(stack.canUndo(), false)
        stack.redo()
        @Expect(gRedoCount, 2)
        @Expect(gLastRedoData, 7)
        @Expect(stack.canUndo(), true)
        @Expect(stack.canRedo(), false)
        stack.close()
    }

    @TestCase
    func testUndoRedoText() {
        let stack = QUndoStack()
        let cmd = QUndoCommand(gUndoCb, gRedoCb, 0, "添加行")
        stack.push(cmd)
        @Expect(stack.undoText(), "添加行")
        stack.undo()
        @Expect(stack.redoText(), "添加行")
        stack.close()
    }

    @TestCase
    func testClear() {
        let stack = QUndoStack()
        let c1 = QUndoCommand(gUndoCb, gRedoCb, 0, "a")
        let c2 = QUndoCommand(gUndoCb, gRedoCb, 0, "b")
        stack.push(c1)
        stack.push(c2)
        @Expect(stack.count(), 2)
        stack.clear()
        @Expect(stack.count(), 0)
        @Expect(stack.index(), 0)
        stack.close()
    }

    @TestCase
    func testUndoLimitRoundtrip() {
        let stack = QUndoStack()
        stack.setUndoLimit(10)
        @Expect(stack.undoLimit(), 10)
        stack.setUndoLimit(0)
        @Expect(stack.undoLimit(), 0)
        stack.close()
    }

    @TestCase
    func testSetClean() {
        let stack = QUndoStack()
        let cmd = QUndoCommand(gUndoCb, gRedoCb, 0, "x")
        stack.push(cmd)
        @Expect(stack.isClean(), false)
        stack.setClean()
        @Expect(stack.isClean(), true)
        stack.close()
    }

    @TestCase
    func testMacro() {
        let stack = QUndoStack()
        stack.beginMacro("复合操作")
        let c1 = QUndoCommand(gUndoCb, gRedoCb, 1, "子操作1")
        let c2 = QUndoCommand(gUndoCb, gRedoCb, 2, "子操作2")
        stack.push(c1)
        stack.push(c2)
        stack.endMacro()
        @Expect(stack.count(), 1)
        @Expect(stack.canUndo(), true)
        stack.close()
    }

    @TestCase
    func testDoubleClose() {
        let stack = QUndoStack()
        stack.close()
        stack.close()  // 安全
        @Assert(true)
    }
}