package cjqt6.test

import cjqt6.core.*
import cjqt6.richwidgets.*
import std.unittest.*

// ============================================================
// Tag / Rate / Cascader / Descriptions 测试
// ============================================================

@Test
class TagTests {
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
    func testCreate() {
        let tag = Tag("默认")
        @Expect(tag.isValid(), true)
        tag.close()
    }

    @TestCase
    func testSetText() {
        let tag = Tag("原标签")
        tag.setText("新标签")
        @Expect(tag.isValid(), true)
        tag.close()
    }

    @TestCase
    func testSetColor() {
        let tag = Tag("彩色")
        tag.setColor("#52c41a")
        tag.setForegroundColor("#000000")
        @Expect(tag.isValid(), true)
        tag.close()
    }
}

@Test
class RateTests {
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
    func testCreate() {
        let r = Rate(5)
        @Expect(r.getRating(), 0)
        @Expect(r.maxCount(), 5)
        @Expect(r.isValid(), true)
        r.close()
    }

    @TestCase
    func testSetRating() {
        let r = Rate(5)
        r.setRating(3)
        @Expect(r.getRating(), 3)
        r.close()
    }

    @TestCase
    func testClampHigh() {
        let r = Rate(5)
        r.setRating(10)
        @Expect(r.getRating(), 5)
        r.close()
    }

    @TestCase
    func testClampLow() {
        let r = Rate(5)
        r.setRating(-1)
        @Expect(r.getRating(), 0)
        r.close()
    }
}

@Test
class CascaderTests {
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
    func testSetLevel1Items() {
        let c = Cascader()
        c.setLevel1Items(["省份", "城市"])
        @Expect(c.level1Count(), 2)
        c.close()
    }

    @TestCase
    func testSetLevel2Items() {
        let c = Cascader()
        c.setLevel2Items(["杭州", "宁波", "温州"])
        @Expect(c.level2Count(), 3)
        c.close()
    }

    @TestCase
    func testGetCurrent() {
        let c = Cascader()
        c.setLevel1Items(["A", "B"])
        c.setLevel1Current(1)
        @Expect(c.getLevel1Current(), "B")
        c.close()
    }

    @TestCase
    func testCascadeData() {
        let c = Cascader()
        c.setCascadeData(["浙江省", "江苏省"], [["杭州", "宁波"], ["南京", "苏州"]])
        @Expect(c.level1Count(), 2)
        @Expect(c.level2Count(), 2) // 默认显示第一项的二级
        @Expect(c.getLevel2Current(), "杭州")
        c.setLevel1Current(1) // 触发联动，自动更新二级
        @Expect(c.level2Count(), 2)
        @Expect(c.getLevel2Current(), "南京")
        c.close()
    }
}

@Test
class DescriptionsTests {
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
    func testAddItem() {
        let d = Descriptions("用户详情")
        d.addItem("姓名", "张三")
        d.addItem("年龄", "28")
        d.addItem("邮箱", "zhangsan-mail")
        @Expect(d.itemCount(), Int64(3))
        d.close()
    }

    @TestCase
    func testSetTitle() {
        let d = Descriptions()
        d.setTitle("商品信息")
        d.addItem("名称", "商品A")
        @Expect(d.isValid(), true)
        d.close()
    }
}