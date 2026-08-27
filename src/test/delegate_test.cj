package cjqt6.test

import cjqt6.core.*
import cjqt6.views.*
import std.unittest.*

// =====================================================================
// 全局状态与回调（CFunc 不捕获局部变量，只能用全局变量）
// =====================================================================

/// 记录 paint 回调收到的委托指针（用于验证回调被正确路由）
var gDelegatePaintPtr: Int64 = 0
let gDelegatePaintCb: CFunc<(Int64) -> Unit> = { dptr: Int64 =>
    gDelegatePaintPtr = dptr
}

/// sizeHint 回调：固定返回 120x40 的打包值
let gDelegateSizeHintCb: CFunc<(Int64) -> Int64> = { dptr: Int64 =>
    makeSizeHintValue(120, 40)
}

/// 空操作回调（仅验证注册不崩溃）
let gDelegateNoopPaintCb: CFunc<(Int64) -> Unit> = { _: Int64 => () }

/// 编辑回调：createEditor 返回 0（不编辑），仅验证注册不崩溃
let gDelegateNoopCreateEditorCb: CFunc<(Int64) -> Int64> = { _: Int64 => 0 }
/// 编辑回调：空操作
let gDelegateNoopSetEditorDataCb: CFunc<(Int64) -> Unit> = { _: Int64 => () }
let gDelegateNoopSetModelDataCb: CFunc<(Int64) -> Unit> = { _: Int64 => () }

// =====================================================================
// QStyledItemDelegate 测试（GUI 环境）
// =====================================================================
@Test
class QStyledItemDelegateTests {
    private static var guiEnv: ?GUITestEnvironment = None

    @BeforeAll
    static func setupGUI(): Unit {
        let env = GUITestEnvironment.getInstance()
        env.setupEnvironment()
        guiEnv = Some(env)
    }

    @AfterAll
    static func teardownGUI(): Unit {
        if (let Some(env) <- guiEnv) {
            env.teardownEnvironment()
        }
    }

    @TestCase
    func testCreateAndClose() {
        let d = QStyledItemDelegate()
        @Expect(d.getPtr() != 0, true)
        d.close()
        // 关闭后指针归零，重复 close 幂等
        @Expect(d.getPtr(), 0)
        d.close()
    }

    @TestCase
    func testRegisterCallbacks() {
        let d = QStyledItemDelegate()
        d.setOnPaint(gDelegateNoopPaintCb)
        d.setOnSizeHint(gDelegateSizeHintCb)
        @Assert(true)
        d.close()
    }

    @TestCase
    func testMountToTableView() {
        let view = QTableView()
        let model = QStandardItemModel(3, 3)
        view.setModel(model)
        let d = QStyledItemDelegate()
        d.setOnPaint(gDelegatePaintCb)
        view.setItemDelegate(d)
        // 挂载后视图接管所有权；close 只标记关闭、不删除底层对象，随后视图析构级联释放
        d.close()
        view.delete()
        model.delete()
    }

    @TestCase
    func testMountToListViewAndTreeView() {
        // QListView
        let lv = QListView()
        let m1 = QStandardItemModel(3, 1)
        lv.setModel(m1)
        let d1 = QStyledItemDelegate()
        lv.setItemDelegate(d1)
        d1.close()
        lv.delete()
        m1.delete()

        // QTreeView
        let tv = QTreeView()
        let m2 = QStandardItemModel(3, 3)
        tv.setModel(m2)
        let d2 = QStyledItemDelegate()
        tv.setItemDelegate(d2)
        d2.close()
        tv.delete()
        m2.delete()
    }

    @TestCase
    func testCloseThenUseThrows() {
        let d = QStyledItemDelegate()
        d.close()
        @ExpectThrows[ResourceDisposedException](d.setOnPaint(gDelegateNoopPaintCb))
        @ExpectThrows[ResourceDisposedException](d.getRow())
        @ExpectThrows[ResourceDisposedException](d.getPainterPtr())
    }

    @TestCase
    func testPaintStateConstants() {
        @Expect(PaintState.selected(), 0x00008000)
        @Expect(PaintState.mouseOver(), 0x00002000)
        @Expect(PaintState.hasFocus(), 0x00000100)
        @Expect(PaintState.active(), 0x00010000)
        @Expect(PaintState.has(0x00008000, PaintState.selected()), true)
        @Expect(PaintState.has(0x00008000, PaintState.mouseOver()), false)
        @Expect(PaintState.has(0x00008000 | 0x00010000, PaintState.active()), true)
    }

    @TestCase
    func testMakeSizeHintValue() {
        let v = makeSizeHintValue(100, 50)
        // 低 32 位 = 宽度，高 32 位 = 高度
        @Expect(v & 0xFFFFFFFF, Int64(100))
        @Expect((v >> 32) & 0xFFFFFFFF, Int64(50))
        // 高度 0 时只保留宽度
        let v2 = makeSizeHintValue(7, 0)
        @Expect(v2, Int64(7))
    }

    // ---- 编辑委托测试 ----

    @TestCase
    func testRegisterEditorCallbacks() {
        let d = QStyledItemDelegate()
        d.setOnCreateEditor(gDelegateNoopCreateEditorCb)
        d.setOnSetEditorData(gDelegateNoopSetEditorDataCb)
        d.setOnSetModelData(gDelegateNoopSetModelDataCb)
        @Assert(true)
        d.close()
    }

    @TestCase
    func testEditorContextGettersReturnZero() {
        // 非回调上下文调用编辑 getter 返回 0（不崩溃）
        let d = QStyledItemDelegate()
        @Expect(d.getParentPtr(), 0)
        @Expect(d.getEditorPtr(), 0)
        @Expect(d.getModelPtr(), 0)
        d.close()
    }

    @TestCase
    func testEditorMethodsAfterCloseThrow() {
        let d = QStyledItemDelegate()
        d.close()
        @ExpectThrows[ResourceDisposedException](d.setOnCreateEditor(gDelegateNoopCreateEditorCb))
        @ExpectThrows[ResourceDisposedException](d.setOnSetEditorData(gDelegateNoopSetEditorDataCb))
        @ExpectThrows[ResourceDisposedException](d.setOnSetModelData(gDelegateNoopSetModelDataCb))
        @ExpectThrows[ResourceDisposedException](d.getParentPtr())
        @ExpectThrows[ResourceDisposedException](d.getEditorPtr())
        @ExpectThrows[ResourceDisposedException](d.getModelPtr())
    }
}