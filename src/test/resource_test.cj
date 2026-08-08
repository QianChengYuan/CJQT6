package cjqt6.test

import cjqt6.resource.*
import cjqt6.widgets.*
import cjqt6.core.*
import std.unittest.*

@Test
class ResourceContainerTests {
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
        let container = ResourceContainer()
        @Assert(container.isValid())
        @Expect(container.isClosed(), false)
    }
    
    @TestCase
    func testAdd() {
        let container = ResourceContainer()
        let btn = QPushButton()
        
        container.add(btn)
        
        let stats = container.getStats()
        @Expect(stats.totalCount, 1)
        @Expect(stats.activeCount, 1)
        
        container.close()
    }
    
    @TestCase
    func testAddAll() {
        let container = ResourceContainer()
        let btn1 = QPushButton()
        let btn2 = QPushButton()
        let btn3 = QPushButton()
        
        container.addAll([btn1, btn2, btn3])
        
        let stats = container.getStats()
        @Expect(stats.totalCount, 3)
        @Expect(stats.activeCount, 3)
        
        container.close()
    }
    
    @TestCase
    func testChainCall() {
        let container = ResourceContainer()
        let btn1 = QPushButton()
        let btn2 = QPushButton()
        let label = QLabel()
        
        container.add(btn1).add(btn2).add(label)
        
        let stats = container.getStats()
        @Expect(stats.totalCount, 3)
        
        container.close()
    }
    
    @TestCase
    func testRemove() {
        let container = ResourceContainer()
        let btn1 = QPushButton()
        let btn2 = QPushButton()
        
        container.addAll([btn1, btn2])
        
        let removed = container.remove(btn1)
        @Expect(removed, true)
        
        let stats = container.getStats()
        @Expect(stats.totalCount, 1)
        
        container.close()
    }
    
    @TestCase
    func testReleaseAll() {
        let container = ResourceContainer()
        let btn1 = QPushButton()
        let btn2 = QPushButton()
        let btn3 = QPushButton()
        
        container.addAll([btn1, btn2, btn3])
        
        let result = container.releaseAll()
        @Expect(result.totalCount, 3)
        @Expect(result.successCount, 3)
        @Expect(result.failedCount, 0)
        @Assert(result.isAllSuccess())
        
        @Expect(btn1.isClosed(), true)
        @Expect(btn2.isClosed(), true)
        @Expect(btn3.isClosed(), true)
    }
    
    @TestCase
    func testReleaseByType() {
        let container = ResourceContainer()
        let btn1 = QPushButton()
        let btn2 = QPushButton()
        let label = QLabel()
        
        container.add(btn1).add(btn2).add(label)
        
        let result = container.releaseByType("QtResource")
        @Expect(result.successCount, 3)
        
        container.close()
    }
    
    @TestCase
    func testAutoReleaseOnClose() {
        let container = ResourceContainer()
        let btn1 = QPushButton()
        let btn2 = QPushButton()
        
        container.addAll([btn1, btn2])
        container.close()
        
        @Expect(btn1.isClosed(), true)
        @Expect(btn2.isClosed(), true)
        @Expect(container.isClosed(), true)
    }
    
    @TestCase
    func testNoAutoReleaseOnClose() {
        let config = ContainerConfig(false, false)
        let container = ResourceContainer(config)
        let btn = QPushButton()
        
        container.add(btn)
        container.close()
        
        @Expect(btn.isClosed(), false)
        @Expect(container.isClosed(), true)
        
        btn.close()
    }
    
    @TestCase
    func testAddClosedWidget() {
        let container = ResourceContainer()
        let btn = QPushButton()
        btn.close()
        
        container.add(btn)
        
        let stats = container.getStats()
        @Expect(stats.totalCount, 0)
        
        container.close()
    }
    
    @TestCase
    func testStats() {
        let container = ResourceContainer()
        let btn1 = QPushButton()
        let btn2 = QPushButton()
        let label = QLabel()
        
        container.add(btn1).add(btn2).add(label)
        
        let stats = container.getStats()
        @Expect(stats.totalCount, 3)
        @Expect(stats.activeCount, 3)
        @Expect(stats.releasedCount, 0)
        
        btn1.close()
        
        let stats2 = container.getStats()
        @Expect(stats2.activeCount, 2)
        @Expect(stats2.releasedCount, 1)
        
        container.close()
    }
    
    @TestCase
    func testDoubleClose() {
        let container = ResourceContainer()
        let btn = QPushButton()
        
        container.add(btn)
        container.close()
        container.close()
        
        @Expect(container.isClosed(), true)
    }
}

@Test
class ScopeManagerTests {
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
        let scope = ScopeManager()
        @Assert(scope.isValid())
        @Expect(scope.isClosed(), false)
        
        let stats = scope.getStats()
        @Expect(stats.isActive, true)
        @Expect(stats.widgetCount, 0)
        
        scope.close()
    }
    
    @TestCase
    func testRegister() {
        let scope = ScopeManager()
        let btn = QPushButton()
        
        scope.register(btn)
        
        let stats = scope.getStats()
        @Expect(stats.widgetCount, 1)
        
        scope.close()
    }
    
    @TestCase
    func testChainCall() {
        let scope = ScopeManager()
        let btn1 = QPushButton()
        let btn2 = QPushButton()
        let label = QLabel()
        
        scope.register(btn1).register(btn2).register(label)
        
        let stats = scope.getStats()
        @Expect(stats.widgetCount, 3)
        
        scope.close()
    }
    
    @TestCase
    func testUnregister() {
        let scope = ScopeManager()
        let btn1 = QPushButton()
        let btn2 = QPushButton()
        
        scope.register(btn1).register(btn2)
        
        let removed = scope.unregister(btn1)
        @Expect(removed, true)
        
        let stats = scope.getStats()
        @Expect(stats.widgetCount, 1)
        
        scope.close()
    }
    
    @TestCase
    func testReleaseAll() {
        let scope = ScopeManager()
        let btn1 = QPushButton()
        let btn2 = QPushButton()
        let btn3 = QPushButton()
        
        scope.register(btn1).register(btn2).register(btn3)
        
        let result = scope.releaseAll()
        @Expect(result.totalCount, 3)
        @Expect(result.successCount, 3)
        @Expect(result.failedCount, 0)
        @Assert(result.isAllSuccess())
        
        @Expect(btn1.isClosed(), true)
        @Expect(btn2.isClosed(), true)
        @Expect(btn3.isClosed(), true)
        
        scope.close()
    }
    
    @TestCase
    func testAutoReleaseOnClose() {
        let scope = ScopeManager()
        let btn1 = QPushButton()
        let btn2 = QPushButton()
        
        scope.register(btn1).register(btn2)
        scope.close()
        
        @Expect(btn1.isClosed(), true)
        @Expect(btn2.isClosed(), true)
        @Expect(scope.isClosed(), true)
    }
    
    @TestCase
    func testNoAutoReleaseOnClose() {
        let config = ScopeConfig(false, false, false, 0, 1000)
        let scope = ScopeManager(config)
        let btn = QPushButton()
        
        scope.register(btn)
        scope.close()
        
        @Expect(btn.isClosed(), false)
        @Expect(scope.isClosed(), true)
        
        btn.close()
    }
    
    @TestCase
    func testRegisterClosedWidget() {
        let scope = ScopeManager()
        let btn = QPushButton()
        btn.close()
        
        scope.register(btn)
        
        let stats = scope.getStats()
        @Expect(stats.widgetCount, 0)
        
        scope.close()
    }
    
    @TestCase
    func testPreventDoubleManagement() {
        let scope1 = ScopeManager()
        let scope2 = ScopeManager()
        let btn = QPushButton()
        
        scope1.register(btn)
        
        scope2.register(btn)
        
        let stats1 = scope1.getStats()
        let stats2 = scope2.getStats()
        
        @Expect(stats1.widgetCount, 1)
        @Expect(stats2.widgetCount, 0)
        
        scope1.close()
        scope2.close()
    }
    
    @TestCase
    func testDoubleClose() {
        let scope = ScopeManager()
        let btn = QPushButton()
        
        scope.register(btn)
        scope.close()
        scope.close()
        
        @Expect(scope.isClosed(), true)
    }
    
    @TestCase
    func testConfig() {
        let config = ScopeConfig(true, true, false, 2, 500)
        let scope = ScopeManager(config)
        
        @Assert(scope.isValid())
        
        scope.close()
    }
}
