package all_controls_demo

import cjqt6.core.*
import cjqt6.widgets.*
import cjqt6.gui.*
import cjqt6.dialogs.*
import cjqt6.views.*
import cjqt6.richwidgets.*

// -------- 页面8: 组合控件 (Rich Widgets) --------

func createPageRichWidgets(): QScrollArea {
    let (scrollArea, _, layout) = createPageContainer()

    // 标题
    let title = QLabel()
    title.setText("组合控件演示 (Rich Widgets)")
    setLabelStyle(title, "font-size: 18px; font-weight: bold; color: #2c3e50; padding: 8px 0;")
    title.setAlignment(AlignCenter)
    layout.addWidget(title.getPtr())

    // ========== 1. Switch 开关 ==========
    let switchCard = GroupCard("1. Switch 开关")
    let sw = Switch()
    sw.setText("启用通知")
    let switchLabel = QLabel()
    switchLabel.setText("状态：关闭")
    sw.setOnChanged({ =>
        switchLabel.setText(if (sw.isChecked()) { "状态：开启" } else { "状态：关闭" })
    })
    switchCard.addWidget(sw)
    switchCard.addWidget(switchLabel)
    layout.addWidget(switchCard.getPtr())

    // ========== 2. Toast 轻提示 ==========
    let toastCard = GroupCard("2. Toast 轻提示")
    let toastBtn = QPushButton()
    toastBtn.setText("显示 Toast（3 秒后自动消失）")
    toastBtn.setStyleSheet("background-color: #3498db; color: white; padding: 6px;")
    toastBtn.setOnClickCapture({ =>
        let toast = Toast("操作成功！", 3000)
        toast.show()
    })
    toastCard.addWidget(toastBtn)
    layout.addWidget(toastCard.getPtr())

    // ========== 3. SearchBox 搜索框 ==========
    let searchCard = GroupCard("3. SearchBox 搜索框")
    let searchBox = SearchBox()
    searchBox.setPlaceholder("输入关键词后回车搜索...")
    let searchLabel = QLabel()
    searchLabel.setText("未搜索")
    searchBox.setOnSearch({ =>
        searchLabel.setText("搜索关键词：${searchBox.text()}")
    })
    searchCard.addWidget(searchBox)
    searchCard.addWidget(searchLabel)
    layout.addWidget(searchCard.getPtr())

    // ========== 4. Form 表单 ==========
    let formCard = GroupCard("4. Form 表单")
    let form = Form("用户信息")
    form.addRow("姓名", QLineEdit())
    form.addRow("邮箱", QLineEdit())
    form.addRow("年龄", QLineEdit())
    form.setLabelAlignment(HAlign.Left)
    formCard.addWidget(form)
    layout.addWidget(formCard.getPtr())

    // ========== 5. DateRangePicker 日期范围 ==========
    let dateCard = GroupCard("5. DateRangePicker 日期范围")
    let datePicker = DateRangePicker()
    datePicker.setStartDate(2024, 1, 1)
    datePicker.setEndDate(2024, 12, 31)
    dateCard.addWidget(datePicker)
    layout.addWidget(dateCard.getPtr())

    // ========== 6. Pagination 分页栏 ==========
    let pageCard = GroupCard("6. Pagination 分页栏")
    let pagination = Pagination()
    pagination.setTotalPages(10)
    let pageLabel = QLabel()
    pageLabel.setText("当前页：1")
    pagination.setOnPageChanged({ =>
        pageLabel.setText("当前页：${pagination.getCurrentPage()}")
    })
    pageCard.addWidget(pagination)
    pageCard.addWidget(pageLabel)
    layout.addWidget(pageCard.getPtr())

    // ========== 7. Avatar 头像 ==========
    let avatarCard = GroupCard("7. Avatar 头像")
    let av1 = Avatar("张", 48)
    let av2 = Avatar("李", 40)
    av2.setBackgroundColor("#52c41a")
    let av3 = Avatar("王", 56)
    av3.setBackgroundColor("#ff4d4f")
    let av4 = Avatar("赵", 32)
    av4.setBackgroundColor("#722ed1")
    avatarCard.addWidget(av1)
    avatarCard.addWidget(av2)
    avatarCard.addWidget(av3)
    avatarCard.addWidget(av4)
    layout.addWidget(avatarCard.getPtr())

    // ========== 8. Badge 徽标 ==========
    let badgeCard = GroupCard("8. Badge 徽标")
    let badge1 = Badge(5)
    let badge2 = Badge(150)
    badge2.setMaxCount(99)
    let badge3 = Badge(0)
    badge3.setCount(8)
    badge3.setBackgroundColor("#1890ff")
    badgeCard.addWidget(badge1)
    badgeCard.addWidget(badge2)
    badgeCard.addWidget(badge3)
    layout.addWidget(badgeCard.getPtr())

    // ========== 9. Steps 步骤条 ==========
    let stepsCard = GroupCard("9. Steps 步骤条")
    let steps = Steps(["启动", "配置", "开发", "测试", "上线"])
    let nextStepBtn = QPushButton()
    nextStepBtn.setText("下一步")
    nextStepBtn.setOnClickCapture({ =>
        let cur = steps.getCurrentStep()
        var next = cur + 1
        if (next >= steps.stepCount()) {
            next = 0
        }
        steps.setCurrentStep(next)
    })
    stepsCard.addWidget(steps)
    stepsCard.addWidget(nextStepBtn)
    layout.addWidget(stepsCard.getPtr())

    // ========== 10. Timeline 时间线 ==========
    let timelineCard = GroupCard("10. Timeline 时间线")
    let timeline = Timeline()
    timeline.addItem("2024-01-01 10:00", "项目启动")
    timeline.addItem("2024-01-15 14:30", "需求评审完成")
    timeline.addItem("2024-02-01 09:00", "开发阶段开始")
    timeline.addItem("2024-02-28 18:00", "首轮测试完成")
    timelineCard.addWidget(timeline)
    layout.addWidget(timelineCard.getPtr())

    // ========== 11. Transfer 穿梭框 ==========
    let transferCard = GroupCard("11. Transfer 穿梭框")
    let transfer = Transfer()
    transfer.addCandidate("张三")
    transfer.addCandidate("李四")
    transfer.addCandidate("王五")
    transfer.addCandidate("赵六")
    transfer.addCandidate("钱七")
    transferCard.addWidget(transfer)
    layout.addWidget(transferCard.getPtr())

    // ========== 12. Tag 标签 ==========
    let tagCard = GroupCard("12. Tag 标签")
    let tag1 = Tag("默认")
    let tag2 = Tag("成功")
    tag2.setColor("#52c41a")
    let tag3 = Tag("警告")
    tag3.setColor("#faad14")
    let tag4 = Tag("错误")
    tag4.setColor("#ff4d4f")
    tagCard.addWidget(tag1)
    tagCard.addWidget(tag2)
    tagCard.addWidget(tag3)
    tagCard.addWidget(tag4)
    layout.addWidget(tagCard.getPtr())

    // ========== 13. Rate 评分 ==========
    let rateCard = GroupCard("13. Rate 评分")
    let rate = Rate(5)
    rate.setRating(3)
    let rateLabel = QLabel()
    rateLabel.setText("当前评分：3")
    rate.setOnRatingChanged({ =>
        rateLabel.setText("当前评分：${rate.getRating()}")
    })
    rateCard.addWidget(rate)
    rateCard.addWidget(rateLabel)
    layout.addWidget(rateCard.getPtr())

    // ========== 14. Cascader 级联选择 ==========
    let cascaderCard = GroupCard("14. Cascader 级联选择")
    let cascader = Cascader()
    cascader.setLevel1Items(["浙江省", "江苏省"])
    cascader.setLevel2Items(["杭州", "宁波", "温州"])
    cascaderCard.addWidget(cascader)
    layout.addWidget(cascaderCard.getPtr())

    // ========== 15. Descriptions 描述列表 ==========
    let descCard = GroupCard("15. Descriptions 描述列表")
    let desc = Descriptions("商品详情")
    desc.addItem("名称", "CJQT6 组件库")
    desc.addItem("版本", "1.9.0")
    desc.addItem("协议", "MIT")
    desc.addItem("语言", "仓颉 Cangjie")
    descCard.addWidget(desc)
    layout.addWidget(descCard.getPtr())

    // ========== 16. Skeleton 骨架屏 ==========
    let skeletonCard = GroupCard("16. Skeleton 骨架屏")
    let skeleton = Skeleton(3)
    skeletonCard.addWidget(skeleton)
    layout.addWidget(skeletonCard.getPtr())

    // ========== 17. Empty 空状态 ==========
    let emptyCard = GroupCard("17. Empty 空状态")
    let empty = Empty("暂无数据", "请先添加数据后再查看")
    emptyCard.addWidget(empty)
    layout.addWidget(emptyCard.getPtr())

    // ========== 18. Statistic 统计数值 ==========
    let statCard = GroupCard("18. Statistic 统计数值")
    let stat = Statistic("今日访问", "2048", "次")
    statCard.addWidget(stat)
    layout.addWidget(statCard.getPtr())

    // ========== 19. Countdown 倒计时 ==========
    let countdownCard = GroupCard("19. Countdown 倒计时")
    let countdown = Countdown(10)
    countdownCard.addWidget(countdown)
    layout.addWidget(countdownCard.getPtr())

    // 底部说明
    let tipLabel = QLabel()
    tipLabel.setText("提示：HAlign 对齐常量（0=居中/1=左/2=右）｜内容超出可滚动")
    tipLabel.setAlignment(AlignCenter)
    layout.addWidget(tipLabel.getPtr())

    layout.addStretch()
    scrollArea
}