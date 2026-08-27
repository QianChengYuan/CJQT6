/**
 * @file bridge_chart.cpp
 * @brief Qt Charts 桥接 - QChart / QChartView / QLineSeries / QValueAxis 核心封装
 *
 * 提供 Qt Charts 图表能力的 C ABI 桥接，供仓颉侧 FFI 调用。
 * 当前为 MVP：覆盖折线图最常用路径（建图→加序列→建默认轴→显示）。
 *
 * 所有权约定（Qt Charts 语义）：
 * - QChartView::setChart(chart) 后 view 接管 chart 所有权
 * - QChart::addSeries(series) 后 chart 接管 series 所有权
 * - QChart::addAxis(axis, ...) 后 chart 接管 axis 所有权
 * 仓颉侧 close() 需据此判断是否主动 delete（后续可加 isMounted 查询）。
 */

#include <QtCharts/QChart>
#include <QtCharts/QChartView>
#include <QtCharts/QLineSeries>
#include <QtCharts/QValueAxis>
#include <QtCharts/QAbstractSeries>
#include <QtCharts/QAbstractAxis>
#include <QString>

extern "C" {

// ============================================================
// QChart
// ============================================================

int64_t qChartCreate() {
    return reinterpret_cast<int64_t>(new QChart());
}

void qChartDelete(int64_t ptr) {
    delete reinterpret_cast<QChart*>(ptr);
}

void qChartAddSeries(int64_t ptr, int64_t seriesPtr) {
    QChart* chart = reinterpret_cast<QChart*>(ptr);
    QAbstractSeries* series = reinterpret_cast<QAbstractSeries*>(seriesPtr);
    if (chart && series) chart->addSeries(series);
}

void qChartRemoveAllSeries(int64_t ptr) {
    QChart* chart = reinterpret_cast<QChart*>(ptr);
    if (chart) chart->removeAllSeries();
}

void qChartSetTitle(int64_t ptr, const char* title) {
    QChart* chart = reinterpret_cast<QChart*>(ptr);
    if (chart) chart->setTitle(QString::fromUtf8(title));
}

void qChartSetTheme(int64_t ptr, int32_t theme) {
    QChart* chart = reinterpret_cast<QChart*>(ptr);
    if (chart) chart->setTheme(static_cast<QChart::ChartTheme>(theme));
}

void qChartCreateDefaultAxes(int64_t ptr) {
    QChart* chart = reinterpret_cast<QChart*>(ptr);
    if (chart) chart->createDefaultAxes();
}

void qChartSetAnimationOptions(int64_t ptr, int32_t options) {
    QChart* chart = reinterpret_cast<QChart*>(ptr);
    if (chart) chart->setAnimationOptions(static_cast<QChart::AnimationOptions>(options));
}

void qChartAddAxis(int64_t ptr, int64_t axisPtr, int32_t alignment) {
    QChart* chart = reinterpret_cast<QChart*>(ptr);
    QAbstractAxis* axis = reinterpret_cast<QAbstractAxis*>(axisPtr);
    if (chart && axis) {
        chart->addAxis(axis, static_cast<Qt::AlignmentFlag>(alignment));
    }
}

// ============================================================
// QChartView
// ============================================================

int64_t qChartViewCreate() {
    return reinterpret_cast<int64_t>(new QChartView());
}

void qChartViewDelete(int64_t ptr) {
    delete reinterpret_cast<QChartView*>(ptr);
}

void qChartViewSetChart(int64_t ptr, int64_t chartPtr) {
    QChartView* view = reinterpret_cast<QChartView*>(ptr);
    QChart* chart = reinterpret_cast<QChart*>(chartPtr);
    if (view && chart) view->setChart(chart);
}

// ============================================================
// QLineSeries
// ============================================================

int64_t qLineSeriesCreate() {
    return reinterpret_cast<int64_t>(new QLineSeries());
}

void qLineSeriesDelete(int64_t ptr) {
    delete reinterpret_cast<QLineSeries*>(ptr);
}

void qLineSeriesAppend(int64_t ptr, double x, double y) {
    QLineSeries* series = reinterpret_cast<QLineSeries*>(ptr);
    if (series) series->append(static_cast<qreal>(x), static_cast<qreal>(y));
}

void qLineSeriesSetName(int64_t ptr, const char* name) {
    QLineSeries* series = reinterpret_cast<QLineSeries*>(ptr);
    if (series) series->setName(QString::fromUtf8(name));
}

int32_t qLineSeriesCount(int64_t ptr) {
    QLineSeries* series = reinterpret_cast<QLineSeries*>(ptr);
    return series ? static_cast<int32_t>(series->count()) : 0;
}

// ============================================================
// QValueAxis
// ============================================================

int64_t qValueAxisCreate() {
    return reinterpret_cast<int64_t>(new QValueAxis());
}

void qValueAxisDelete(int64_t ptr) {
    delete reinterpret_cast<QValueAxis*>(ptr);
}

void qValueAxisSetRange(int64_t ptr, double min, double max) {
    QValueAxis* axis = reinterpret_cast<QValueAxis*>(ptr);
    if (axis) axis->setRange(static_cast<qreal>(min), static_cast<qreal>(max));
}

void qValueAxisSetTickCount(int64_t ptr, int32_t count) {
    QValueAxis* axis = reinterpret_cast<QValueAxis*>(ptr);
    if (axis) axis->setTickCount(count);
}

void qValueAxisSetLabelFormat(int64_t ptr, const char* format) {
    QValueAxis* axis = reinterpret_cast<QValueAxis*>(ptr);
    if (axis) axis->setLabelFormat(QString::fromUtf8(format));
}

void qValueAxisSetMin(int64_t ptr, double min) {
    QValueAxis* axis = reinterpret_cast<QValueAxis*>(ptr);
    if (axis) axis->setMin(static_cast<qreal>(min));
}

void qValueAxisSetMax(int64_t ptr, double max) {
    QValueAxis* axis = reinterpret_cast<QValueAxis*>(ptr);
    if (axis) axis->setMax(static_cast<qreal>(max));
}

} // extern "C"