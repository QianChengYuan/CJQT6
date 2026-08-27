# 20 - Qt Charts 图表

> `import cjqt6.charts.*`
>
> 基于 Qt Charts 的图表封装，提供 QChart / QChartView / QLineSeries / QBarSeries / QBarSet / QPieSeries / QScatterSeries / QAreaSeries / QSplineSeries / QPercentBarSeries / QStackedBarSeries / QBoxSet / QBoxPlotSeries / QCandlestickSet / QCandlestickSeries / QPolarChart / QValueAxis / QBarCategoryAxis / QCategoryAxis / QLegend。
> 需 Qt Charts 组件（Qt Maintenance Tool 安装时勾选 Qt Charts）。

---

## QChart — 图表容器

管理序列、坐标轴、图例。是图表的核心容器。

```cangjie
import cjqt6.charts.*

let chart = QChart()
chart.setTitle("一周温度变化")
chart.setTheme(ChartTheme.dark)
chart.setAnimationOptions(ChartAnimation.series)

let series = QLineSeries()
series.append(0.0, 10.0)
series.append(1.0, 20.0)
chart.addSeries(series)
chart.createDefaultAxes()
```

**支持方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建图表 |
| `addSeries(series: QLineSeries)` | 添加折线序列；添加后 chart 接管 series 所有权 |
| `addSeries(series: QBarSeries)` | 添加柱状图序列（重载） |
| `addSeries(series: QPieSeries)` | 添加饼图序列（重载） |
| `addSeries(series: QScatterSeries)` | 添加散点图序列（重载） |
| `addSeries(series: QAreaSeries)` | 添加区域图序列（重载） |
| `addSeries(series: QSplineSeries)` | 添加样条曲线序列（重载） |
| `addSeries(series: QPercentBarSeries)` | 添加百分比柱状图序列（重载） |
| `addSeries(series: QStackedBarSeries)` | 添加堆叠柱状图序列（重载） |
| `addSeries(series: QBoxPlotSeries)` | 添加箱线图序列（重载） |
| `addSeries(series: QCandlestickSeries)` | 添加 K 线序列（重载） |
| `removeAllSeries()` | 移除所有序列 |
| `setTitle(title: String)` | 设置图表标题 |
| `setTheme(theme: Int32)` | 设置主题（见 ChartTheme 常量） |
| `createDefaultAxes()` | 根据已添加序列自动创建默认坐标轴 |
| `setAnimationOptions(options: Int32)` | 设置动画选项（见 ChartAnimation 常量） |
| `addAxis(axis: QValueAxis, alignment: Int32)` | 添加数值坐标轴到指定位置（见 AxisAlignment） |
| `addAxis(axis: QBarCategoryAxis, alignment: Int32)` | 添加分类坐标轴（重载） |
| `addAxis(axis: QCategoryAxis, alignment: Int32)` | 添加分类值轴（重载） |
| `getLegend(): QLegend` | 获取图例（非拥有式，由 chart 管理生命周期，勿 close） |
| `getPtr(): Int64` / `close()` | 获取指针与释放 |

**主题常量** (`ChartTheme`):
| 常量 | 值 | 说明 |
|------|-----|------|
| `ChartTheme.light` | 0 | 浅色主题（默认） |
| `ChartTheme.blueCerulean` | 1 | 蓝色主题 |
| `ChartTheme.dark` | 2 | 深色主题 |
| `ChartTheme.brownSand` | 3 | 沙色主题 |
| `ChartTheme.blueNcs` | 4 | NCS 蓝色 |
| `ChartTheme.highContrast` | 5 | 高对比度 |
| `ChartTheme.blueIcy` | 6 | 冰蓝主题 |
| `ChartTheme.qt` | 7 | Qt 主题 |

**动画常量** (`ChartAnimation`):
| 常量 | 值 | 说明 |
|------|-----|------|
| `ChartAnimation.none` | 0 | 无动画 |
| `ChartAnimation.gridAxis` | 1 | 网格轴动画 |
| `ChartAnimation.series` | 2 | 序列动画 |
| `ChartAnimation.all` | 3 | 全部动画 |

**对齐常量** (`AxisAlignment`，用于 `addAxis`):
| 常量 | 值 | 说明 |
|------|-----|------|
| `AxisAlignment.left` | 0x0001 | 左侧 |
| `AxisAlignment.right` | 0x0002 | 右侧 |
| `AxisAlignment.top` | 0x0020 | 顶部 |
| `AxisAlignment.bottom` | 0x0040 | 底部 |

---

## QChartView — 图表视图

显示 QChart 的视图 widget（继承 QGraphicsView）。

```cangjie
let view = QChartView()
view.setChart(chart)
view.resize(640, 480)
view.show()
```

**支持方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建图表视图 |
| `setChart(chart: QChart)` | 设置要显示的图表；设置后 view 接管 chart 所有权 |
| `show()` | 显示窗口 |
| `resize(width: Int32, height: Int32)` | 调整窗口大小 |
| `getPtr(): Int64` / `close()` | 获取指针与释放 |

---

## QLineSeries — 折线序列

用于绘制折线图的数据序列。

```cangjie
let series = QLineSeries()
series.setName("温度")
series.append(0.0, 10.0)
series.append(1.0, 15.0)
series.append(2.0, 20.0)
println(series.count())  // 3
```

**支持方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建折线序列 |
| `append(x: Float64, y: Float64)` | 追加一个数据点 |
| `setName(name: String)` | 设置序列名称（显示在图例中） |
| `count(): Int32` | 当前数据点数量 |
| `getPtr(): Int64` / `close()` | 获取指针与释放 |

---

## QBarSet — 柱状图数据集

一组柱状图数据（如某产品各季度的销量）。

```cangjie
let set = QBarSet("产品A")
set.append(10.0)
set.append(20.0)
set.append(15.0)
println(set.count())  // 3
println(set.sum())    // 45.0
```

**支持方法**:
| 方法 | 说明 |
|------|------|
| `init(label: String)` | 创建数据集，指定标签 |
| `append(value: Float64)` | 追加一个值 |
| `insert(index: Int32, value: Float64)` | 在指定位置插入值 |
| `remove(index: Int32, count!: Int32 = 1)` | 从指定位置移除 count 个值 |
| `replace(index: Int32, value: Float64)` | 替换指定位置的值 |
| `count(): Int32` | 值数量 |
| `sum(): Float64` | 值总和 |
| `setLabel(label: String)` | 设置标签 |
| `setColor(r, g, b)` / `setBorderColor(r, g, b)` | 设置柱子/边框颜色（RGB） |
| `getPtr(): Int64` / `close()` | 获取指针与释放 |

---

## QBarSeries — 柱状图序列

包含多个 QBarSet，每个 QBarSet 是一组数据。

```cangjie
let series = QBarSeries()
let set1 = QBarSet("产品A")
set1.append(10.0); set1.append(20.0)
let set2 = QBarSet("产品B")
set2.append(15.0); set2.append(25.0)
series.append(set1)
series.append(set2)
chart.addSeries(series)
```

**支持方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建柱状图序列 |
| `append(set: QBarSet)` | 追加数据集；追加后 series 接管 set 所有权 |
| `remove(set: QBarSet)` | 移除数据集 |
| `insert(index: Int32, set: QBarSet)` | 在指定位置插入数据集 |
| `count(): Int32` | 数据集数量 |
| `clear()` | 清除所有数据集 |
| `setBarWidth(width: Float64)` | 设置柱子宽度 |
| `setLabelsVisible(visible: Bool)` | 设置标签可见性 |
| `setLabelsPosition(position: Int32)` | 设置标签位置（见 BarLabelsPosition） |
| `getPtr(): Int64` / `close()` | 获取指针与释放 |

**标签位置常量** (`BarLabelsPosition`):
| 常量 | 值 | 说明 |
|------|-----|------|
| `BarLabelsPosition.center` | 0 | 居中 |
| `BarLabelsPosition.insideEnd` | 1 | 内端 |
| `BarLabelsPosition.insideBase` | 2 | 内基 |
| `BarLabelsPosition.outsideEnd` | 3 | 外端 |

---

## QPieSeries — 饼图序列

用于绘制饼图/环形图。

```cangjie
let series = QPieSeries()
series.append("苹果", 30.0)
series.append("香蕉", 25.0)
series.append("橙子", 45.0)
series.setHoleSize(0.4)  // 环形图
chart.addSeries(series)
```

**支持方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建饼图序列 |
| `append(label: String, value: Float64)` | 追加一个切片 |
| `clear()` | 清除所有切片 |
| `count(): Int32` | 切片数量 |
| `sum(): Float64` | 切片值总和 |
| `setHoleSize(size: Float64)` | 中心孔大小（0~1，大于 0 为环形图） |
| `setPieSize(size: Float64)` | 饼图大小（0~1） |
| `setHorizontalPosition(pos)` / `setVerticalPosition(pos)` | 水平/垂直位置（0~1） |
| `setPieStartAngle(angle)` / `setPieEndAngle(angle)` | 起始/结束角度（度） |
| `setLabelsVisible(visible: Bool)` | 切片标签可见性 |
| `getPtr(): Int64` / `close()` | 获取指针与释放 |

---

## QScatterSeries — 散点图序列

用于绘制散点图，继承 QXYSeries（与 QLineSeries 同基类）。

```cangjie
let series = QScatterSeries()
series.setName("测量点")
series.append(1.0, 10.0)
series.append(2.0, 25.0)
series.append(3.0, 18.0)
series.setMarkerShape(ScatterMarkerShape.circle)
series.setMarkerSize(10.0)
chart.addSeries(series)
```

**支持方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建散点图序列 |
| `append(x: Float64, y: Float64)` | 追加一个数据点 |
| `setName(name: String)` | 设置序列名称 |
| `count(): Int32` | 数据点数量 |
| `setMarkerShape(shape: Int32)` | 标记形状（见 ScatterMarkerShape） |
| `setMarkerSize(size: Float64)` | 标记大小 |
| `setColor(r, g, b)` / `setBorderColor(r, g, b)` | 标记/边框颜色（RGB） |
| `getPtr(): Int64` / `close()` | 获取指针与释放 |

**标记形状常量** (`ScatterMarkerShape`):
| 常量 | 值 | 说明 |
|------|-----|------|
| `ScatterMarkerShape.circle` | 0 | 圆形 |
| `ScatterMarkerShape.rectangle` | 1 | 矩形 |
| `ScatterMarkerShape.rotatedRectangle` | 2 | 旋转矩形 |
| `ScatterMarkerShape.triangle` | 3 | 三角形 |
| `ScatterMarkerShape.star` | 4 | 星形 |
| `ScatterMarkerShape.pentagon` | 5 | 五边形 |

---

## QAreaSeries — 区域图序列

用上下两条折线围成填充区域。下边界可省略（默认为 0）。

```cangjie
let upper = QLineSeries()
upper.append(0.0, 20.0); upper.append(1.0, 30.0); upper.append(2.0, 25.0)
let lower = QLineSeries()
lower.append(0.0, 5.0);  lower.append(1.0, 10.0); lower.append(2.0, 8.0)
let area = QAreaSeries(upper, lower)
area.setColor(100, 150, 200)
chart.addSeries(area)
// area 所有权转给 chart；upper/lower 需手动 close
```

**支持方法**:
| 方法 | 说明 |
|------|------|
| `init(upper: QLineSeries)` | 创建区域图，指定上边界（下边界默认为 0） |
| `init(upper: QLineSeries, lower: QLineSeries)` | 创建区域图，指定上/下边界 |
| `setColor(r: Int32, g: Int32, b: Int32)` | 设置区域颜色（RGB） |
| `setBorderColor(r: Int32, g: Int32, b: Int32)` | 设置边框颜色（RGB） |
| `setPointsVisible(visible: Bool)` | 设置数据点可见性 |
| `getPtr(): Int64` / `close()` | 获取指针与释放 |

> **所有权注意**：QAreaSeries 不拥有 upper/lower QLineSeries。`addSeries` 后 chart 接管 area，但 line series 需手动 `close()`。

---

## QSplineSeries — 样条曲线序列

绘制平滑样条曲线，API 与 QLineSeries 一致（继承 QLineSeries）。

```cangjie
let series = QSplineSeries()
series.setName("平滑曲线")
series.append(0.0, 10.0)
series.append(1.0, 20.0)
series.append(2.0, 15.0)
chart.addSeries(series)
```

**支持方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建样条曲线序列 |
| `append(x: Float64, y: Float64)` | 追加一个数据点 |
| `setName(name: String)` | 设置序列名称（显示在图例中） |
| `count(): Int32` | 当前数据点数量 |
| `getPtr(): Int64` / `close()` | 获取指针与释放 |

---

## QPercentBarSeries — 百分比柱状图序列

每组数据归一化为 100% 显示。API 与 QBarSeries 一致（继承 QAbstractBarSeries）。

```cangjie
let series = QPercentBarSeries()
let set1 = QBarSet("产品A")
set1.append(10.0); set1.append(20.0)
let set2 = QBarSet("产品B")
set2.append(30.0); set2.append(40.0)
series.append(set1)
series.append(set2)
series.setLabelsVisible(true)
chart.addSeries(series)
```

**支持方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建百分比柱状图序列 |
| `append(set: QBarSet)` | 追加数据集；追加后 series 接管 set 所有权 |
| `count(): Int32` | 数据集数量 |
| `clear()` | 清除所有数据集 |
| `setLabelsVisible(visible: Bool)` | 设置标签可见性 |
| `getPtr(): Int64` / `close()` | 获取指针与释放 |

---

## QStackedBarSeries — 堆叠柱状图序列

同组数据堆叠显示。API 与 QBarSeries 一致（继承 QAbstractBarSeries）。

```cangjie
let series = QStackedBarSeries()
let set1 = QBarSet("产品A")
set1.append(10.0); set1.append(20.0)
let set2 = QBarSet("产品B")
set2.append(15.0); set2.append(25.0)
series.append(set1)
series.append(set2)
chart.addSeries(series)
```

**支持方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建堆叠柱状图序列 |
| `append(set: QBarSet)` | 追加数据集；追加后 series 接管 set 所有权 |
| `count(): Int32` | 数据集数量 |
| `clear()` | 清除所有数据集 |
| `setLabelsVisible(visible: Bool)` | 设置标签可见性 |
| `getPtr(): Int64` / `close()` | 获取指针与释放 |

---

## QBoxSet — 箱线图数据集

表示一个箱线图的五值总结：下极值、下四分位、中位数、上四分位、上极值。

```cangjie
// 逐步追加
let box1 = QBoxSet("样本A")
box1.append(10.0)  // 下极值
box1.append(20.0)  // 下四分位
box1.append(30.0)  // 中位数
box1.append(40.0)  // 上四分位
box1.append(50.0)  // 上极值

// 或直接指定五值
let box2 = QBoxSet(15.0, 25.0, 35.0, 45.0, 55.0)
series.append(box1)
series.append(box2)
```

**支持方法**:
| 方法 | 说明 |
|------|------|
| `init(label: String)` | 创建数据集，指定标签 |
| `init(le: Float64, lq: Float64, m: Float64, uq: Float64, ue: Float64)` | 创建数据集，直接指定五值（标签默认为空） |
| `append(value: Float64)` | 追加一个值（按顺序填充五值位置） |
| `clear()` | 清除所有值 |
| `setLabel(label: String)` | 设置标签 |
| `setValue(index: Int32, value: Float64)` | 设置指定位置的值（0~4 对应五值） |
| `at(index: Int32): Float64` | 获取指定位置的值 |
| `count(): Int32` | 值数量 |
| `getPtr(): Int64` / `close()` | 获取指针与释放 |

---

## QBoxPlotSeries — 箱线图序列

包含多个 QBoxSet，每个 QBoxSet 是一组五值总结。

```cangjie
let series = QBoxPlotSeries()
series.setBoxWidth(0.5)
let box = QBoxSet(10.0, 20.0, 30.0, 40.0, 50.0)
series.append(box)
chart.addSeries(series)
```

**支持方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建箱线图序列 |
| `append(box: QBoxSet)` | 追加数据集；追加后 series 接管 box 所有权 |
| `count(): Int32` | 数据集数量 |
| `clear()` | 清除所有数据集 |
| `setBoxOutlineVisible(visible: Bool)` | 箱体边框可见性 |
| `setBoxWidth(width: Float64)` | 箱体宽度 |
| `getPtr(): Int64` / `close()` | 获取指针与释放 |

---

## QCandlestickSet — K线数据集

表示一根 K 线（OHLC + 时间戳）。

```cangjie
// 直接指定 OHLC + 时间戳
let candle1 = QCandlestickSet(100.0, 105.0, 95.0, 102.0, 1.0)

// 逐步设置
let candle2 = QCandlestickSet(2.0)
candle2.setOpen(102.0)
candle2.setHigh(108.0)
candle2.setLow(100.0)
candle2.setClose(98.0)
series.append(candle1)
```

**支持方法**:
| 方法 | 说明 |
|------|------|
| `init(timestamp: Float64)` | 创建 K 线，指定时间戳 |
| `init(open: Float64, high: Float64, low: Float64, close: Float64, timestamp: Float64)` | 创建 K 线，指定 OHLC + 时间戳 |
| `setTimestamp(ts: Float64)` / `timestamp(): Float64` | 设置/获取时间戳 |
| `setOpen(value: Float64)` / `open(): Float64` | 设置/获取开盘价 |
| `setHigh(value: Float64)` / `high(): Float64` | 设置/获取最高价 |
| `setLow(value: Float64)` / `low(): Float64` | 设置/获取最低价 |
| `setClose(value: Float64)` / `closeValue(): Float64` | 设置/获取收盘价 |
| `getPtr(): Int64` / `close()` | 获取指针与释放 |

> **注意**：获取收盘价的方法名为 `closeValue()` 而非 `close()`，因为 `close()` 是资源释放方法。

---

## QCandlestickSeries — K线序列

包含多根 K 线（QCandlestickSet）。

```cangjie
let series = QCandlestickSeries()
series.setIncreasingColor(255, 0, 0)   // 上涨红色
series.setDecreasingColor(0, 255, 0)   // 下跌绿色
series.setCapsVisible(true)
let candle = QCandlestickSet(100.0, 105.0, 95.0, 102.0, 1.0)
series.append(candle)
chart.addSeries(series)
```

**支持方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建 K 线序列 |
| `append(set: QCandlestickSet)` | 追加 K 线；追加后 series 接管 set 所有权 |
| `count(): Int32` | K 线数量 |
| `clear()` | 清除所有 K 线 |
| `setBodyWidth(width: Float64)` | 实体宽度 |
| `setBodyOutlineVisible(visible: Bool)` | 实体边框可见性 |
| `setCapsWidth(width: Float64)` | 上下影线宽度 |
| `setCapsVisible(visible: Bool)` | 上下影线可见性 |
| `setIncreasingColor(r, g, b)` | 上涨颜色（RGB） |
| `setDecreasingColor(r, g, b)` | 下跌颜色（RGB） |
| `getPtr(): Int64` / `close()` | 获取指针与释放 |

---

## QPolarChart — 极坐标图

继承 QChart，将数据以极坐标方式显示。与 QChart 的区别：`addAxis` 使用 `PolarOrientation`（径向/角向）而非 `AxisAlignment`。

```cangjie
let polar = QPolarChart()
let series = QLineSeries()
series.append(0.0, 10.0)
series.append(90.0, 20.0)
series.append(180.0, 15.0)
polar.addSeries(series)
polar.createDefaultAxes()

// 手动添加极坐标轴
let radialAxis = QValueAxis()
radialAxis.setRange(0.0, 100.0)
polar.addAxis(radialAxis, PolarOrientation.radial)
```

**支持方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建极坐标图 |
| `addSeries(series: ...)` | 添加序列（支持全部 10 种序列类型，同 QChart） |
| `addAxis(axis: QValueAxis, polarOrientation: Int32)` | 添加轴到极坐标方向（见 PolarOrientation） |
| `addAxis(axis: QBarCategoryAxis, polarOrientation: Int32)` | 添加分类轴（重载） |
| `addAxis(axis: QCategoryAxis, polarOrientation: Int32)` | 添加分类值轴（重载） |
| `setTitle(title: String)` / `setTheme(theme: Int32)` | 标题/主题（同 QChart） |
| `createDefaultAxes()` / `removeAllSeries()` | 创建默认轴/移除所有序列 |
| `setAnimationOptions(options: Int32)` | 动画选项（同 QChart） |
| `getLegend(): QLegend` | 获取图例（非拥有式，勿 close） |
| `getPtr(): Int64` / `close()` | 获取指针与释放 |

**极坐标方向常量** (`PolarOrientation`):
| 常量 | 值 | 说明 |
|------|-----|------|
| `PolarOrientation.radial` | 0x1 | 径向（从圆心向外） |
| `PolarOrientation.angular` | 0x2 | 角向（沿圆周） |

---

## QValueAxis — 数值坐标轴

用于折线图/柱状图的数值轴。

```cangjie
let axis = QValueAxis()
axis.setRange(0.0, 100.0)
axis.setTickCount(11)
axis.setLabelFormat("%.0f")
chart.addAxis(axis, AxisAlignment.bottom)
```

**支持方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建数值轴 |
| `setRange(min: Float64, max: Float64)` | 设置轴范围 |
| `setTickCount(count: Int32)` | 设置刻度数量 |
| `setLabelFormat(format: String)` | 设置刻度标签格式（如 `"%.0f"`、`"%.2f"`） |
| `setMin(min: Float64)` | 设置最小值 |
| `setMax(max: Float64)` | 设置最大值 |
| `getPtr(): Int64` / `close()` | 获取指针与释放 |

---

## QBarCategoryAxis — 分类坐标轴

用于柱状图的 X 轴分类标签（如"周一/周二/周三"）。

```cangjie
let axis = QBarCategoryAxis()
axis.append("周一")
axis.append("周二")
axis.append("周三")
chart.addAxis(axis, AxisAlignment.bottom)
```

**支持方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建分类轴 |
| `append(category: String)` | 追加一个分类 |
| `remove(category: String)` | 移除指定分类 |
| `insert(index: Int32, category: String)` | 在指定位置插入分类 |
| `replace(oldCategory: String, newCategory: String)` | 替换分类标签 |
| `clear()` | 清除所有分类 |
| `count(): Int32` | 分类数量 |
| `setMin(minCategory: String)` | 设置最小分类 |
| `setMax(maxCategory: String)` | 设置最大分类 |
| `setRange(minCategory: String, maxCategory: String)` | 设置分类范围 |
| `getPtr(): Int64` / `close()` | 获取指针与释放 |

---

## QCategoryAxis — 分类值轴

在数值轴上划分分类区间并打标签（如 0-10"低"、10-20"中"、20-30"高"）。继承 QValueAxis 的全部方法。

```cangjie
let axis = QCategoryAxis()
axis.setRange(0.0, 30.0)
axis.append("低", 10.0)
axis.append("中", 20.0)
axis.append("高", 30.0)
axis.setLabelsPosition(CategoryAxisLabelsPosition.onValue)
chart.addAxis(axis, AxisAlignment.bottom)
```

**支持方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建分类值轴 |
| `append(label: String, endValue: Float64)` | 追加分类标签及其结束值 |
| `remove(label: String)` | 移除指定分类标签 |
| `replaceLabel(oldLabel: String, newLabel: String)` | 替换分类标签 |
| `setStartValue(min: Float64)` | 设置起始值 |
| `count(): Int32` | 分类数量 |
| `setLabelsPosition(position: Int32)` | 设置标签位置（见 CategoryAxisLabelsPosition） |
| `labelsPosition(): Int32` | 获取标签位置 |
| `setRange(min: Float64, max: Float64)` | 设置轴范围（继承自 QValueAxis） |
| `setTickCount(count: Int32)` | 设置刻度数量（继承自 QValueAxis） |
| `setLabelFormat(format: String)` | 设置刻度标签格式（继承自 QValueAxis） |
| `setMin(min: Float64)` / `setMax(max: Float64)` | 设置最小/最大值（继承自 QValueAxis） |
| `getPtr(): Int64` / `close()` | 获取指针与释放 |

**标签位置常量** (`CategoryAxisLabelsPosition`):
| 常量 | 值 | 说明 |
|------|-----|------|
| `CategoryAxisLabelsPosition.center` | 0 | 标签居中 |
| `CategoryAxisLabelsPosition.onValue` | 1 | 标签对齐到值 |

---

## QLegend — 图例

由 `QChart.getLegend()` 获取，**非拥有式**（由 chart 管理生命周期，勿调用 close）。

```cangjie
let legend = chart.getLegend()
legend.setAlignment(AxisAlignment.bottom)
legend.setBackgroundVisible(true)
legend.setMarkerShape(LegendMarkerShape.circle)
legend.setColor(240, 240, 240)
```

**支持方法**:
| 方法 | 说明 |
|------|------|
| `setAlignment(alignment: Int32)` / `alignment(): Int32` | 设置/获取对齐方式（见 AxisAlignment） |
| `setBackgroundVisible(visible: Bool)` / `isBackgroundVisible(): Bool` | 背景可见性 |
| `detachFromChart()` / `attachToChart()` / `isAttachedToChart(): Bool` | 分离/附着图表 |
| `setReverseMarkers(reverse: Bool)` / `reverseMarkers(): Bool` | 反转标记顺序 |
| `setShowToolTips(show: Bool)` / `showToolTips(): Bool` | 工具提示 |
| `setInteractive(interactive: Bool)` / `isInteractive(): Bool` | 可交互性 |
| `setMarkerShape(shape: Int32)` / `markerShape(): Int32` | 标记形状（见 LegendMarkerShape） |
| `setColor(r: Int32, g: Int32, b: Int32)` | 背景颜色（RGB） |
| `setBorderColor(r: Int32, g: Int32, b: Int32)` | 边框颜色（RGB） |
| `setLabelColor(r: Int32, g: Int32, b: Int32)` | 标签颜色（RGB） |
| `getPtr(): Int64` | 获取指针（勿 close，由 chart 管理） |

**标记形状常量** (`LegendMarkerShape`):
| 常量 | 值 | 说明 |
|------|-----|------|
| `LegendMarkerShape.defaultShape` | 0 | 默认形状 |
| `LegendMarkerShape.rectangle` | 1 | 矩形 |
| `LegendMarkerShape.circle` | 2 | 圆形 |
| `LegendMarkerShape.fromSeries` | 3 | 跟随序列 |
| `LegendMarkerShape.rotatedRectangle` | 4 | 旋转矩形 |
| `LegendMarkerShape.triangle` | 5 | 三角形 |
| `LegendMarkerShape.star` | 6 | 星形 |
| `LegendMarkerShape.pentagon` | 7 | 五边形 |

---

## 所有权与生命周期

Qt Charts 的所有权链：
```
QChartView → QChart / QPolarChart → QLineSeries / QBarSeries / QPieSeries / QScatterSeries / QAreaSeries / QSplineSeries / QPercentBarSeries / QStackedBarSeries / QBoxPlotSeries / QCandlestickSeries / QValueAxis / QBarCategoryAxis / QCategoryAxis
QBarSeries / QPercentBarSeries / QStackedBarSeries → QBarSet
QBoxPlotSeries → QBoxSet
QCandlestickSeries → QCandlestickSet
QChart / QPolarChart → QLegend（chart 内部管理，非用户拥有）
```

- `QChartView.setChart(chart)` 后，view 接管 chart 所有权（适用于 QChart / QPolarChart）
- `QChart.addSeries(series)` / `QPolarChart.addSeries(series)` 后，chart 接管 series 所有权（适用于全部 10 种序列类型）
- `QBarSeries.append(set)` / `QPercentBarSeries.append(set)` / `QStackedBarSeries.append(set)` 后，series 接管 set 所有权
- `QBoxPlotSeries.append(box)` 后，series 接管 box 所有权
- `QCandlestickSeries.append(set)` 后，series 接管 set 所有权
- `QAreaSeries` 不拥有 upper/lower QLineSeries，需手动管理 line series 生命周期
- `QChart.addAxis(axis, ...)` / `QPolarChart.addAxis(axis, ...)` 后，chart 接管 axis 所有权
- `QChart.getLegend()` / `QPolarChart.getLegend()` 返回的 QLegend 是**非拥有式**引用，由 chart 管理生命周期，勿调用 close()

**最佳实践**：按所有权链从上到下创建，只需 `view.close()` 即可级联释放所有资源。已挂载的对象勿主动 `close()`，避免 double-free。

```cangjie
// 推荐模式：只需关闭 view
let view = QChartView()
let chart = QChart()
let series = QLineSeries()
series.append(0.0, 10.0)
chart.addSeries(series)      // chart 接管 series
view.setChart(chart)          // view 接管 chart
view.show()
// ... 使用 ...
view.close()                  // 级联释放 chart + series
```