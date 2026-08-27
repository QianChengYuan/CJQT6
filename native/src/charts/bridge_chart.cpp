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
#include <QtCharts/QBarCategoryAxis>
#include <QtCharts/QCategoryAxis>
#include <QtCharts/QLegend>
#include <QtCharts/QBarSeries>
#include <QtCharts/QBarSet>
#include <QtCharts/QPieSeries>
#include <QtCharts/QScatterSeries>
#include <QString>
#include <QColor>

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

int64_t qChartLegend(int64_t ptr) {
    QChart* chart = reinterpret_cast<QChart*>(ptr);
    return chart ? reinterpret_cast<int64_t>(chart->legend()) : 0;
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

// ============================================================
// QBarCategoryAxis - 分类坐标轴（用于柱状图 X 轴标签）
// ============================================================

int64_t qBarCategoryAxisCreate() {
    return reinterpret_cast<int64_t>(new QBarCategoryAxis());
}

void qBarCategoryAxisDelete(int64_t ptr) {
    delete reinterpret_cast<QBarCategoryAxis*>(ptr);
}

void qBarCategoryAxisAppend(int64_t ptr, const char* category) {
    QBarCategoryAxis* axis = reinterpret_cast<QBarCategoryAxis*>(ptr);
    if (axis) axis->append(QString::fromUtf8(category));
}

void qBarCategoryAxisRemove(int64_t ptr, const char* category) {
    QBarCategoryAxis* axis = reinterpret_cast<QBarCategoryAxis*>(ptr);
    if (axis) axis->remove(QString::fromUtf8(category));
}

void qBarCategoryAxisInsert(int64_t ptr, int32_t index, const char* category) {
    QBarCategoryAxis* axis = reinterpret_cast<QBarCategoryAxis*>(ptr);
    if (axis) axis->insert(static_cast<int>(index), QString::fromUtf8(category));
}

void qBarCategoryAxisReplace(int64_t ptr, const char* oldCat, const char* newCat) {
    QBarCategoryAxis* axis = reinterpret_cast<QBarCategoryAxis*>(ptr);
    if (axis) axis->replace(QString::fromUtf8(oldCat), QString::fromUtf8(newCat));
}

void qBarCategoryAxisClear(int64_t ptr) {
    QBarCategoryAxis* axis = reinterpret_cast<QBarCategoryAxis*>(ptr);
    if (axis) axis->clear();
}

int32_t qBarCategoryAxisCount(int64_t ptr) {
    QBarCategoryAxis* axis = reinterpret_cast<QBarCategoryAxis*>(ptr);
    return axis ? static_cast<int32_t>(axis->count()) : 0;
}

void qBarCategoryAxisSetMin(int64_t ptr, const char* minCat) {
    QBarCategoryAxis* axis = reinterpret_cast<QBarCategoryAxis*>(ptr);
    if (axis) axis->setMin(QString::fromUtf8(minCat));
}

void qBarCategoryAxisSetMax(int64_t ptr, const char* maxCat) {
    QBarCategoryAxis* axis = reinterpret_cast<QBarCategoryAxis*>(ptr);
    if (axis) axis->setMax(QString::fromUtf8(maxCat));
}

void qBarCategoryAxisSetRange(int64_t ptr, const char* minCat, const char* maxCat) {
    QBarCategoryAxis* axis = reinterpret_cast<QBarCategoryAxis*>(ptr);
    if (axis) axis->setRange(QString::fromUtf8(minCat), QString::fromUtf8(maxCat));
}

// ============================================================
// QCategoryAxis - 值轴上的分类范围（继承 QValueAxis）
// ============================================================

int64_t qCategoryAxisCreate() {
    return reinterpret_cast<int64_t>(new QCategoryAxis());
}

void qCategoryAxisDelete(int64_t ptr) {
    delete reinterpret_cast<QCategoryAxis*>(ptr);
}

void qCategoryAxisAppend(int64_t ptr, const char* label, double endValue) {
    QCategoryAxis* axis = reinterpret_cast<QCategoryAxis*>(ptr);
    if (axis) axis->append(QString::fromUtf8(label), static_cast<qreal>(endValue));
}

void qCategoryAxisRemove(int64_t ptr, const char* label) {
    QCategoryAxis* axis = reinterpret_cast<QCategoryAxis*>(ptr);
    if (axis) axis->remove(QString::fromUtf8(label));
}

void qCategoryAxisReplaceLabel(int64_t ptr, const char* oldLabel, const char* newLabel) {
    QCategoryAxis* axis = reinterpret_cast<QCategoryAxis*>(ptr);
    if (axis) axis->replaceLabel(QString::fromUtf8(oldLabel), QString::fromUtf8(newLabel));
}

void qCategoryAxisSetStartValue(int64_t ptr, double min) {
    QCategoryAxis* axis = reinterpret_cast<QCategoryAxis*>(ptr);
    if (axis) axis->setStartValue(static_cast<qreal>(min));
}

int32_t qCategoryAxisCount(int64_t ptr) {
    QCategoryAxis* axis = reinterpret_cast<QCategoryAxis*>(ptr);
    return axis ? static_cast<int32_t>(axis->count()) : 0;
}

void qCategoryAxisSetLabelsPosition(int64_t ptr, int32_t position) {
    QCategoryAxis* axis = reinterpret_cast<QCategoryAxis*>(ptr);
    if (axis) axis->setLabelsPosition(static_cast<QCategoryAxis::AxisLabelsPosition>(position));
}

int32_t qCategoryAxisLabelsPosition(int64_t ptr) {
    QCategoryAxis* axis = reinterpret_cast<QCategoryAxis*>(ptr);
    return axis ? static_cast<int32_t>(axis->labelsPosition()) : 0;
}

// ============================================================
// QLegend - 图例（由 QChart::legend() 获取，非拥有式，不 delete）
// ============================================================

void qLegendSetAlignment(int64_t ptr, int32_t alignment) {
    QLegend* legend = reinterpret_cast<QLegend*>(ptr);
    if (legend) legend->setAlignment(static_cast<Qt::AlignmentFlag>(alignment));
}

int32_t qLegendAlignment(int64_t ptr) {
    QLegend* legend = reinterpret_cast<QLegend*>(ptr);
    return legend ? static_cast<int32_t>(legend->alignment()) : 0;
}

void qLegendSetBackgroundVisible(int64_t ptr, int32_t visible) {
    QLegend* legend = reinterpret_cast<QLegend*>(ptr);
    if (legend) legend->setBackgroundVisible(visible != 0);
}

int32_t qLegendIsBackgroundVisible(int64_t ptr) {
    QLegend* legend = reinterpret_cast<QLegend*>(ptr);
    return (legend && legend->isBackgroundVisible()) ? 1 : 0;
}

void qLegendDetachFromChart(int64_t ptr) {
    QLegend* legend = reinterpret_cast<QLegend*>(ptr);
    if (legend) legend->detachFromChart();
}

void qLegendAttachToChart(int64_t ptr) {
    QLegend* legend = reinterpret_cast<QLegend*>(ptr);
    if (legend) legend->attachToChart();
}

int32_t qLegendIsAttachedToChart(int64_t ptr) {
    QLegend* legend = reinterpret_cast<QLegend*>(ptr);
    return (legend && legend->isAttachedToChart()) ? 1 : 0;
}

void qLegendSetReverseMarkers(int64_t ptr, int32_t reverse) {
    QLegend* legend = reinterpret_cast<QLegend*>(ptr);
    if (legend) legend->setReverseMarkers(reverse != 0);
}

int32_t qLegendReverseMarkers(int64_t ptr) {
    QLegend* legend = reinterpret_cast<QLegend*>(ptr);
    return (legend && legend->reverseMarkers()) ? 1 : 0;
}

void qLegendSetShowToolTips(int64_t ptr, int32_t show) {
    QLegend* legend = reinterpret_cast<QLegend*>(ptr);
    if (legend) legend->setShowToolTips(show != 0);
}

int32_t qLegendShowToolTips(int64_t ptr) {
    QLegend* legend = reinterpret_cast<QLegend*>(ptr);
    return (legend && legend->showToolTips()) ? 1 : 0;
}

void qLegendSetInteractive(int64_t ptr, int32_t interactive) {
    QLegend* legend = reinterpret_cast<QLegend*>(ptr);
    if (legend) legend->setInteractive(interactive != 0);
}

int32_t qLegendIsInteractive(int64_t ptr) {
    QLegend* legend = reinterpret_cast<QLegend*>(ptr);
    return (legend && legend->isInteractive()) ? 1 : 0;
}

void qLegendSetMarkerShape(int64_t ptr, int32_t shape) {
    QLegend* legend = reinterpret_cast<QLegend*>(ptr);
    if (legend) legend->setMarkerShape(static_cast<QLegend::MarkerShape>(shape));
}

int32_t qLegendMarkerShape(int64_t ptr) {
    QLegend* legend = reinterpret_cast<QLegend*>(ptr);
    return legend ? static_cast<int32_t>(legend->markerShape()) : 0;
}

void qLegendSetColor(int64_t ptr, int32_t r, int32_t g, int32_t b) {
    QLegend* legend = reinterpret_cast<QLegend*>(ptr);
    if (legend) legend->setColor(QColor(r, g, b));
}

void qLegendSetBorderColor(int64_t ptr, int32_t r, int32_t g, int32_t b) {
    QLegend* legend = reinterpret_cast<QLegend*>(ptr);
    if (legend) legend->setBorderColor(QColor(r, g, b));
}

void qLegendSetLabelColor(int64_t ptr, int32_t r, int32_t g, int32_t b) {
    QLegend* legend = reinterpret_cast<QLegend*>(ptr);
    if (legend) legend->setLabelColor(QColor(r, g, b));
}

// ============================================================
// QBarSet - 柱状图数据集
// ============================================================

int64_t qBarSetCreate(const char* label) {
    return reinterpret_cast<int64_t>(new QBarSet(QString::fromUtf8(label)));
}

void qBarSetDelete(int64_t ptr) {
    delete reinterpret_cast<QBarSet*>(ptr);
}

void qBarSetAppend(int64_t ptr, double value) {
    QBarSet* set = reinterpret_cast<QBarSet*>(ptr);
    if (set) set->append(static_cast<qreal>(value));
}

void qBarSetInsert(int64_t ptr, int32_t index, double value) {
    QBarSet* set = reinterpret_cast<QBarSet*>(ptr);
    if (set) set->insert(static_cast<int>(index), static_cast<qreal>(value));
}

void qBarSetRemove(int64_t ptr, int32_t index, int32_t count) {
    QBarSet* set = reinterpret_cast<QBarSet*>(ptr);
    if (set) set->remove(static_cast<int>(index), static_cast<int>(count));
}

void qBarSetReplace(int64_t ptr, int32_t index, double value) {
    QBarSet* set = reinterpret_cast<QBarSet*>(ptr);
    if (set) set->replace(static_cast<int>(index), static_cast<qreal>(value));
}

int32_t qBarSetCount(int64_t ptr) {
    QBarSet* set = reinterpret_cast<QBarSet*>(ptr);
    return set ? static_cast<int32_t>(set->count()) : 0;
}

double qBarSetSum(int64_t ptr) {
    QBarSet* set = reinterpret_cast<QBarSet*>(ptr);
    return set ? static_cast<double>(set->sum()) : 0.0;
}

void qBarSetSetLabel(int64_t ptr, const char* label) {
    QBarSet* set = reinterpret_cast<QBarSet*>(ptr);
    if (set) set->setLabel(QString::fromUtf8(label));
}

void qBarSetColor(int64_t ptr, int32_t r, int32_t g, int32_t b) {
    QBarSet* set = reinterpret_cast<QBarSet*>(ptr);
    if (set) set->setColor(QColor(r, g, b));
}

void qBarSetSetBorderColor(int64_t ptr, int32_t r, int32_t g, int32_t b) {
    QBarSet* set = reinterpret_cast<QBarSet*>(ptr);
    if (set) set->setBorderColor(QColor(r, g, b));
}

// ============================================================
// QBarSeries - 柱状图序列
// ============================================================

int64_t qBarSeriesCreate() {
    return reinterpret_cast<int64_t>(new QBarSeries());
}

void qBarSeriesDelete(int64_t ptr) {
    delete reinterpret_cast<QBarSeries*>(ptr);
}

void qBarSeriesAppend(int64_t ptr, int64_t setPtr) {
    QBarSeries* series = reinterpret_cast<QBarSeries*>(ptr);
    QBarSet* set = reinterpret_cast<QBarSet*>(setPtr);
    if (series && set) series->append(set);
}

void qBarSeriesRemove(int64_t ptr, int64_t setPtr) {
    QBarSeries* series = reinterpret_cast<QBarSeries*>(ptr);
    QBarSet* set = reinterpret_cast<QBarSet*>(setPtr);
    if (series && set) series->remove(set);
}

void qBarSeriesInsert(int64_t ptr, int32_t index, int64_t setPtr) {
    QBarSeries* series = reinterpret_cast<QBarSeries*>(ptr);
    QBarSet* set = reinterpret_cast<QBarSet*>(setPtr);
    if (series && set) series->insert(static_cast<int>(index), set);
}

int32_t qBarSeriesCount(int64_t ptr) {
    QBarSeries* series = reinterpret_cast<QBarSeries*>(ptr);
    return series ? static_cast<int32_t>(series->count()) : 0;
}

void qBarSeriesClear(int64_t ptr) {
    QBarSeries* series = reinterpret_cast<QBarSeries*>(ptr);
    if (series) series->clear();
}

void qBarSeriesSetBarWidth(int64_t ptr, double width) {
    QBarSeries* series = reinterpret_cast<QBarSeries*>(ptr);
    if (series) series->setBarWidth(static_cast<qreal>(width));
}

void qBarSeriesSetLabelsVisible(int64_t ptr, int32_t visible) {
    QBarSeries* series = reinterpret_cast<QBarSeries*>(ptr);
    if (series) series->setLabelsVisible(visible != 0);
}

void qBarSeriesSetLabelsPosition(int64_t ptr, int32_t position) {
    QBarSeries* series = reinterpret_cast<QBarSeries*>(ptr);
    if (series) series->setLabelsPosition(static_cast<QAbstractBarSeries::LabelsPosition>(position));
}

// ============================================================
// QPieSeries - 饼图序列
// ============================================================

int64_t qPieSeriesCreate() {
    return reinterpret_cast<int64_t>(new QPieSeries());
}

void qPieSeriesDelete(int64_t ptr) {
    delete reinterpret_cast<QPieSeries*>(ptr);
}

void qPieSeriesAppend(int64_t ptr, const char* label, double value) {
    QPieSeries* series = reinterpret_cast<QPieSeries*>(ptr);
    if (series) series->append(QString::fromUtf8(label), static_cast<qreal>(value));
}

void qPieSeriesClear(int64_t ptr) {
    QPieSeries* series = reinterpret_cast<QPieSeries*>(ptr);
    if (series) series->clear();
}

int32_t qPieSeriesCount(int64_t ptr) {
    QPieSeries* series = reinterpret_cast<QPieSeries*>(ptr);
    return series ? static_cast<int32_t>(series->count()) : 0;
}

double qPieSeriesSum(int64_t ptr) {
    QPieSeries* series = reinterpret_cast<QPieSeries*>(ptr);
    return series ? static_cast<double>(series->sum()) : 0.0;
}

void qPieSeriesSetHoleSize(int64_t ptr, double size) {
    QPieSeries* series = reinterpret_cast<QPieSeries*>(ptr);
    if (series) series->setHoleSize(static_cast<qreal>(size));
}

void qPieSeriesSetPieSize(int64_t ptr, double size) {
    QPieSeries* series = reinterpret_cast<QPieSeries*>(ptr);
    if (series) series->setPieSize(static_cast<qreal>(size));
}

void qPieSeriesSetHorizontalPosition(int64_t ptr, double pos) {
    QPieSeries* series = reinterpret_cast<QPieSeries*>(ptr);
    if (series) series->setHorizontalPosition(static_cast<qreal>(pos));
}

void qPieSeriesSetVerticalPosition(int64_t ptr, double pos) {
    QPieSeries* series = reinterpret_cast<QPieSeries*>(ptr);
    if (series) series->setVerticalPosition(static_cast<qreal>(pos));
}

void qPieSeriesSetPieStartAngle(int64_t ptr, double angle) {
    QPieSeries* series = reinterpret_cast<QPieSeries*>(ptr);
    if (series) series->setPieStartAngle(static_cast<qreal>(angle));
}

void qPieSeriesSetPieEndAngle(int64_t ptr, double angle) {
    QPieSeries* series = reinterpret_cast<QPieSeries*>(ptr);
    if (series) series->setPieEndAngle(static_cast<qreal>(angle));
}

void qPieSeriesSetLabelsVisible(int64_t ptr, int32_t visible) {
    QPieSeries* series = reinterpret_cast<QPieSeries*>(ptr);
    if (series) series->setLabelsVisible(visible != 0);
}

// ============================================================
// QScatterSeries - 散点图序列（继承 QXYSeries）
// ============================================================

int64_t qScatterSeriesCreate() {
    return reinterpret_cast<int64_t>(new QScatterSeries());
}

void qScatterSeriesDelete(int64_t ptr) {
    delete reinterpret_cast<QScatterSeries*>(ptr);
}

void qScatterSeriesAppend(int64_t ptr, double x, double y) {
    QScatterSeries* series = reinterpret_cast<QScatterSeries*>(ptr);
    if (series) series->append(static_cast<qreal>(x), static_cast<qreal>(y));
}

void qScatterSeriesSetName(int64_t ptr, const char* name) {
    QScatterSeries* series = reinterpret_cast<QScatterSeries*>(ptr);
    if (series) series->setName(QString::fromUtf8(name));
}

int32_t qScatterSeriesCount(int64_t ptr) {
    QScatterSeries* series = reinterpret_cast<QScatterSeries*>(ptr);
    return series ? static_cast<int32_t>(series->count()) : 0;
}

void qScatterSeriesSetMarkerShape(int64_t ptr, int32_t shape) {
    QScatterSeries* series = reinterpret_cast<QScatterSeries*>(ptr);
    if (series) series->setMarkerShape(static_cast<QScatterSeries::MarkerShape>(shape));
}

void qScatterSeriesSetMarkerSize(int64_t ptr, double size) {
    QScatterSeries* series = reinterpret_cast<QScatterSeries*>(ptr);
    if (series) series->setMarkerSize(static_cast<qreal>(size));
}

void qScatterSeriesSetColor(int64_t ptr, int32_t r, int32_t g, int32_t b) {
    QScatterSeries* series = reinterpret_cast<QScatterSeries*>(ptr);
    if (series) series->setColor(QColor(r, g, b));
}

void qScatterSeriesSetBorderColor(int64_t ptr, int32_t r, int32_t g, int32_t b) {
    QScatterSeries* series = reinterpret_cast<QScatterSeries*>(ptr);
    if (series) series->setBorderColor(QColor(r, g, b));
}

} // extern "C"