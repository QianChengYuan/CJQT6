# 20 - Qt Charts 图表

> `import cjqt6.charts.*`
>
> 基于 Qt Charts 的图表封装，当前提供折线图 MVP：QChart / QChartView / QLineSeries / QValueAxis。
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
| `removeAllSeries()` | 移除所有序列 |
| `setTitle(title: String)` | 设置图表标题 |
| `setTheme(theme: Int32)` | 设置主题（见 ChartTheme 常量） |
| `createDefaultAxes()` | 根据已添加序列自动创建默认坐标轴 |
| `setAnimationOptions(options: Int32)` | 设置动画选项（见 ChartAnimation 常量） |
| `addAxis(axis: QValueAxis, alignment: Int32)` | 添加坐标轴到指定位置（见 AxisAlignment） |
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

## 所有权与生命周期

Qt Charts 的所有权链：
```
QChartView → QChart → QLineSeries / QValueAxis
```

- `QChartView.setChart(chart)` 后，view 接管 chart 所有权
- `QChart.addSeries(series)` 后，chart 接管 series 所有权
- `QChart.addAxis(axis, ...)` 后，chart 接管 axis 所有权

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