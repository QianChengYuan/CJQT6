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
#include <QtCharts/QAreaSeries>
#include <QtCharts/QSplineSeries>
#include <QtCharts/QPercentBarSeries>
#include <QtCharts/QStackedBarSeries>
#include <QtCharts/QBoxSet>
#include <QtCharts/QBoxPlotSeries>
#include <QtCharts/QCandlestickSet>
#include <QtCharts/QCandlestickSeries>
#include <QtCharts/QPolarChart>
#include <QtCharts/QPieSlice>
#include <QtCharts/QDateTimeAxis>
#include <QtCharts/QLogValueAxis>
#include <QtCharts/QHorizontalBarSeries>
#include <QtCharts/QHorizontalPercentBarSeries>
#include <QtCharts/QHorizontalStackedBarSeries>
#include <QString>
#include <QColor>
#include <QDateTime>

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

void qPieSeriesAppendSlice(int64_t ptr, int64_t slicePtr) {
    QPieSeries* series = reinterpret_cast<QPieSeries*>(ptr);
    QPieSlice* slice = reinterpret_cast<QPieSlice*>(slicePtr);
    if (series && slice) series->append(slice);
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

// ============================================================
// QAreaSeries - 区域图序列
// ============================================================

int64_t qAreaSeriesCreate(int64_t upperPtr, int64_t lowerPtr) {
    QLineSeries* upper = reinterpret_cast<QLineSeries*>(upperPtr);
    QLineSeries* lower = lowerPtr ? reinterpret_cast<QLineSeries*>(lowerPtr) : nullptr;
    return reinterpret_cast<int64_t>(new QAreaSeries(upper, lower));
}

void qAreaSeriesDelete(int64_t ptr) {
    delete reinterpret_cast<QAreaSeries*>(ptr);
}

void qAreaSeriesSetColor(int64_t ptr, int32_t r, int32_t g, int32_t b) {
    QAreaSeries* series = reinterpret_cast<QAreaSeries*>(ptr);
    if (series) series->setColor(QColor(r, g, b));
}

void qAreaSeriesSetBorderColor(int64_t ptr, int32_t r, int32_t g, int32_t b) {
    QAreaSeries* series = reinterpret_cast<QAreaSeries*>(ptr);
    if (series) series->setBorderColor(QColor(r, g, b));
}

void qAreaSeriesSetPointsVisible(int64_t ptr, int32_t visible) {
    QAreaSeries* series = reinterpret_cast<QAreaSeries*>(ptr);
    if (series) series->setPointsVisible(visible != 0);
}

// ============================================================
// QSplineSeries - 样条曲线序列（继承 QLineSeries）
// ============================================================

int64_t qSplineSeriesCreate() {
    return reinterpret_cast<int64_t>(new QSplineSeries());
}

void qSplineSeriesDelete(int64_t ptr) {
    delete reinterpret_cast<QSplineSeries*>(ptr);
}

void qSplineSeriesAppend(int64_t ptr, double x, double y) {
    QSplineSeries* series = reinterpret_cast<QSplineSeries*>(ptr);
    if (series) series->append(static_cast<qreal>(x), static_cast<qreal>(y));
}

void qSplineSeriesSetName(int64_t ptr, const char* name) {
    QSplineSeries* series = reinterpret_cast<QSplineSeries*>(ptr);
    if (series) series->setName(QString::fromUtf8(name));
}

int32_t qSplineSeriesCount(int64_t ptr) {
    QSplineSeries* series = reinterpret_cast<QSplineSeries*>(ptr);
    return series ? static_cast<int32_t>(series->count()) : 0;
}

// ============================================================
// QPercentBarSeries - 百分比柱状图序列（继承 QAbstractBarSeries）
// ============================================================

int64_t qPercentBarSeriesCreate() {
    return reinterpret_cast<int64_t>(new QPercentBarSeries());
}

void qPercentBarSeriesDelete(int64_t ptr) {
    delete reinterpret_cast<QPercentBarSeries*>(ptr);
}

void qPercentBarSeriesAppend(int64_t ptr, int64_t setPtr) {
    QPercentBarSeries* series = reinterpret_cast<QPercentBarSeries*>(ptr);
    QBarSet* set = reinterpret_cast<QBarSet*>(setPtr);
    if (series && set) series->append(set);
}

int32_t qPercentBarSeriesCount(int64_t ptr) {
    QPercentBarSeries* series = reinterpret_cast<QPercentBarSeries*>(ptr);
    return series ? static_cast<int32_t>(series->count()) : 0;
}

void qPercentBarSeriesClear(int64_t ptr) {
    QPercentBarSeries* series = reinterpret_cast<QPercentBarSeries*>(ptr);
    if (series) series->clear();
}

void qPercentBarSeriesSetLabelsVisible(int64_t ptr, int32_t visible) {
    QPercentBarSeries* series = reinterpret_cast<QPercentBarSeries*>(ptr);
    if (series) series->setLabelsVisible(visible != 0);
}

// ============================================================
// QStackedBarSeries - 堆叠柱状图序列（继承 QAbstractBarSeries）
// ============================================================

int64_t qStackedBarSeriesCreate() {
    return reinterpret_cast<int64_t>(new QStackedBarSeries());
}

void qStackedBarSeriesDelete(int64_t ptr) {
    delete reinterpret_cast<QStackedBarSeries*>(ptr);
}

void qStackedBarSeriesAppend(int64_t ptr, int64_t setPtr) {
    QStackedBarSeries* series = reinterpret_cast<QStackedBarSeries*>(ptr);
    QBarSet* set = reinterpret_cast<QBarSet*>(setPtr);
    if (series && set) series->append(set);
}

int32_t qStackedBarSeriesCount(int64_t ptr) {
    QStackedBarSeries* series = reinterpret_cast<QStackedBarSeries*>(ptr);
    return series ? static_cast<int32_t>(series->count()) : 0;
}

void qStackedBarSeriesClear(int64_t ptr) {
    QStackedBarSeries* series = reinterpret_cast<QStackedBarSeries*>(ptr);
    if (series) series->clear();
}

void qStackedBarSeriesSetLabelsVisible(int64_t ptr, int32_t visible) {
    QStackedBarSeries* series = reinterpret_cast<QStackedBarSeries*>(ptr);
    if (series) series->setLabelsVisible(visible != 0);
}

// ============================================================
// QBoxSet - 箱线图数据集
// ============================================================

int64_t qBoxSetCreate(const char* label) {
    return reinterpret_cast<int64_t>(new QBoxSet(QString::fromUtf8(label)));
}

int64_t qBoxSetCreate5(double le, double lq, double m, double uq, double ue, const char* label) {
    return reinterpret_cast<int64_t>(new QBoxSet(static_cast<qreal>(le), static_cast<qreal>(lq),
        static_cast<qreal>(m), static_cast<qreal>(uq), static_cast<qreal>(ue), QString::fromUtf8(label)));
}

void qBoxSetDelete(int64_t ptr) {
    delete reinterpret_cast<QBoxSet*>(ptr);
}

void qBoxSetAppend(int64_t ptr, double value) {
    QBoxSet* set = reinterpret_cast<QBoxSet*>(ptr);
    if (set) set->append(static_cast<qreal>(value));
}

void qBoxSetClear(int64_t ptr) {
    QBoxSet* set = reinterpret_cast<QBoxSet*>(ptr);
    if (set) set->clear();
}

void qBoxSetSetLabel(int64_t ptr, const char* label) {
    QBoxSet* set = reinterpret_cast<QBoxSet*>(ptr);
    if (set) set->setLabel(QString::fromUtf8(label));
}

void qBoxSetSetValue(int64_t ptr, int32_t index, double value) {
    QBoxSet* set = reinterpret_cast<QBoxSet*>(ptr);
    if (set) set->setValue(static_cast<int>(index), static_cast<qreal>(value));
}

double qBoxSetAt(int64_t ptr, int32_t index) {
    QBoxSet* set = reinterpret_cast<QBoxSet*>(ptr);
    return set ? static_cast<double>(set->at(static_cast<int>(index))) : 0.0;
}

int32_t qBoxSetCount(int64_t ptr) {
    QBoxSet* set = reinterpret_cast<QBoxSet*>(ptr);
    return set ? static_cast<int32_t>(set->count()) : 0;
}

// ============================================================
// QBoxPlotSeries - 箱线图序列
// ============================================================

int64_t qBoxPlotSeriesCreate() {
    return reinterpret_cast<int64_t>(new QBoxPlotSeries());
}

void qBoxPlotSeriesDelete(int64_t ptr) {
    delete reinterpret_cast<QBoxPlotSeries*>(ptr);
}

void qBoxPlotSeriesAppend(int64_t ptr, int64_t boxPtr) {
    QBoxPlotSeries* series = reinterpret_cast<QBoxPlotSeries*>(ptr);
    QBoxSet* box = reinterpret_cast<QBoxSet*>(boxPtr);
    if (series && box) series->append(box);
}

int32_t qBoxPlotSeriesCount(int64_t ptr) {
    QBoxPlotSeries* series = reinterpret_cast<QBoxPlotSeries*>(ptr);
    return series ? static_cast<int32_t>(series->count()) : 0;
}

void qBoxPlotSeriesClear(int64_t ptr) {
    QBoxPlotSeries* series = reinterpret_cast<QBoxPlotSeries*>(ptr);
    if (series) series->clear();
}

void qBoxPlotSeriesSetBoxOutlineVisible(int64_t ptr, int32_t visible) {
    QBoxPlotSeries* series = reinterpret_cast<QBoxPlotSeries*>(ptr);
    if (series) series->setBoxOutlineVisible(visible != 0);
}

void qBoxPlotSeriesSetBoxWidth(int64_t ptr, double width) {
    QBoxPlotSeries* series = reinterpret_cast<QBoxPlotSeries*>(ptr);
    if (series) series->setBoxWidth(static_cast<qreal>(width));
}

// ============================================================
// QCandlestickSet - K线数据集
// ============================================================

int64_t qCandlestickSetCreate(double timestamp) {
    return reinterpret_cast<int64_t>(new QCandlestickSet(static_cast<qreal>(timestamp)));
}

int64_t qCandlestickSetCreateOHLC(double open, double high, double low, double close, double timestamp) {
    return reinterpret_cast<int64_t>(new QCandlestickSet(static_cast<qreal>(open), static_cast<qreal>(high),
        static_cast<qreal>(low), static_cast<qreal>(close), static_cast<qreal>(timestamp)));
}

void qCandlestickSetDelete(int64_t ptr) {
    delete reinterpret_cast<QCandlestickSet*>(ptr);
}

void qCandlestickSetSetTimestamp(int64_t ptr, double timestamp) {
    QCandlestickSet* set = reinterpret_cast<QCandlestickSet*>(ptr);
    if (set) set->setTimestamp(static_cast<qreal>(timestamp));
}

double qCandlestickSetTimestamp(int64_t ptr) {
    QCandlestickSet* set = reinterpret_cast<QCandlestickSet*>(ptr);
    return set ? static_cast<double>(set->timestamp()) : 0.0;
}

void qCandlestickSetSetOpen(int64_t ptr, double value) {
    QCandlestickSet* set = reinterpret_cast<QCandlestickSet*>(ptr);
    if (set) set->setOpen(static_cast<qreal>(value));
}

double qCandlestickSetOpen(int64_t ptr) {
    QCandlestickSet* set = reinterpret_cast<QCandlestickSet*>(ptr);
    return set ? static_cast<double>(set->open()) : 0.0;
}

void qCandlestickSetSetHigh(int64_t ptr, double value) {
    QCandlestickSet* set = reinterpret_cast<QCandlestickSet*>(ptr);
    if (set) set->setHigh(static_cast<qreal>(value));
}

double qCandlestickSetHigh(int64_t ptr) {
    QCandlestickSet* set = reinterpret_cast<QCandlestickSet*>(ptr);
    return set ? static_cast<double>(set->high()) : 0.0;
}

void qCandlestickSetSetLow(int64_t ptr, double value) {
    QCandlestickSet* set = reinterpret_cast<QCandlestickSet*>(ptr);
    if (set) set->setLow(static_cast<qreal>(value));
}

double qCandlestickSetLow(int64_t ptr) {
    QCandlestickSet* set = reinterpret_cast<QCandlestickSet*>(ptr);
    return set ? static_cast<double>(set->low()) : 0.0;
}

void qCandlestickSetSetClose(int64_t ptr, double value) {
    QCandlestickSet* set = reinterpret_cast<QCandlestickSet*>(ptr);
    if (set) set->setClose(static_cast<qreal>(value));
}

double qCandlestickSetClose(int64_t ptr) {
    QCandlestickSet* set = reinterpret_cast<QCandlestickSet*>(ptr);
    return set ? static_cast<double>(set->close()) : 0.0;
}

// ============================================================
// QCandlestickSeries - K线序列
// ============================================================

int64_t qCandlestickSeriesCreate() {
    return reinterpret_cast<int64_t>(new QCandlestickSeries());
}

void qCandlestickSeriesDelete(int64_t ptr) {
    delete reinterpret_cast<QCandlestickSeries*>(ptr);
}

void qCandlestickSeriesAppend(int64_t ptr, int64_t setPtr) {
    QCandlestickSeries* series = reinterpret_cast<QCandlestickSeries*>(ptr);
    QCandlestickSet* set = reinterpret_cast<QCandlestickSet*>(setPtr);
    if (series && set) series->append(set);
}

int32_t qCandlestickSeriesCount(int64_t ptr) {
    QCandlestickSeries* series = reinterpret_cast<QCandlestickSeries*>(ptr);
    return series ? static_cast<int32_t>(series->count()) : 0;
}

void qCandlestickSeriesClear(int64_t ptr) {
    QCandlestickSeries* series = reinterpret_cast<QCandlestickSeries*>(ptr);
    if (series) series->clear();
}

void qCandlestickSeriesSetBodyWidth(int64_t ptr, double width) {
    QCandlestickSeries* series = reinterpret_cast<QCandlestickSeries*>(ptr);
    if (series) series->setBodyWidth(static_cast<qreal>(width));
}

void qCandlestickSeriesSetBodyOutlineVisible(int64_t ptr, int32_t visible) {
    QCandlestickSeries* series = reinterpret_cast<QCandlestickSeries*>(ptr);
    if (series) series->setBodyOutlineVisible(visible != 0);
}

void qCandlestickSeriesSetCapsWidth(int64_t ptr, double width) {
    QCandlestickSeries* series = reinterpret_cast<QCandlestickSeries*>(ptr);
    if (series) series->setCapsWidth(static_cast<qreal>(width));
}

void qCandlestickSeriesSetCapsVisible(int64_t ptr, int32_t visible) {
    QCandlestickSeries* series = reinterpret_cast<QCandlestickSeries*>(ptr);
    if (series) series->setCapsVisible(visible != 0);
}

void qCandlestickSeriesSetIncreasingColor(int64_t ptr, int32_t r, int32_t g, int32_t b) {
    QCandlestickSeries* series = reinterpret_cast<QCandlestickSeries*>(ptr);
    if (series) series->setIncreasingColor(QColor(r, g, b));
}

void qCandlestickSeriesSetDecreasingColor(int64_t ptr, int32_t r, int32_t g, int32_t b) {
    QCandlestickSeries* series = reinterpret_cast<QCandlestickSeries*>(ptr);
    if (series) series->setDecreasingColor(QColor(r, g, b));
}

// ============================================================
// QPolarChart - 极坐标图（继承 QChart）
// ============================================================

int64_t qPolarChartCreate() {
    return reinterpret_cast<int64_t>(new QPolarChart());
}

void qPolarChartDelete(int64_t ptr) {
    delete reinterpret_cast<QPolarChart*>(ptr);
}

void qPolarChartAddAxis(int64_t ptr, int64_t axisPtr, int32_t polarOrientation) {
    QPolarChart* chart = reinterpret_cast<QPolarChart*>(ptr);
    QAbstractAxis* axis = reinterpret_cast<QAbstractAxis*>(axisPtr);
    if (chart && axis) {
        chart->addAxis(axis, static_cast<QPolarChart::PolarOrientation>(polarOrientation));
    }
}

// ============================================================
// QPieSlice - 饼图切片
// ============================================================

int64_t qPieSliceCreate() {
    return reinterpret_cast<int64_t>(new QPieSlice());
}

int64_t qPieSliceCreateLabelValue(const char* label, double value) {
    return reinterpret_cast<int64_t>(new QPieSlice(QString::fromUtf8(label), static_cast<qreal>(value)));
}

void qPieSliceDelete(int64_t ptr) {
    delete reinterpret_cast<QPieSlice*>(ptr);
}

void qPieSliceSetLabel(int64_t ptr, const char* label) {
    QPieSlice* slice = reinterpret_cast<QPieSlice*>(ptr);
    if (slice) slice->setLabel(QString::fromUtf8(label));
}

const char* qPieSliceLabel(int64_t ptr) {
    QPieSlice* slice = reinterpret_cast<QPieSlice*>(ptr);
    if (!slice) return nullptr;
    static QByteArray ba;
    ba = slice->label().toUtf8();
    return ba.constData();
}

void qPieSliceSetValue(int64_t ptr, double value) {
    QPieSlice* slice = reinterpret_cast<QPieSlice*>(ptr);
    if (slice) slice->setValue(static_cast<qreal>(value));
}

double qPieSliceValue(int64_t ptr) {
    QPieSlice* slice = reinterpret_cast<QPieSlice*>(ptr);
    return slice ? static_cast<double>(slice->value()) : 0.0;
}

void qPieSliceSetLabelVisible(int64_t ptr, int32_t visible) {
    QPieSlice* slice = reinterpret_cast<QPieSlice*>(ptr);
    if (slice) slice->setLabelVisible(visible != 0);
}

int32_t qPieSliceIsLabelVisible(int64_t ptr) {
    QPieSlice* slice = reinterpret_cast<QPieSlice*>(ptr);
    return slice ? (slice->isLabelVisible() ? 1 : 0) : 0;
}

void qPieSliceSetLabelPosition(int64_t ptr, int32_t position) {
    QPieSlice* slice = reinterpret_cast<QPieSlice*>(ptr);
    if (slice) slice->setLabelPosition(static_cast<QPieSlice::LabelPosition>(position));
}

int32_t qPieSliceLabelPosition(int64_t ptr) {
    QPieSlice* slice = reinterpret_cast<QPieSlice*>(ptr);
    return slice ? static_cast<int32_t>(slice->labelPosition()) : 0;
}

void qPieSliceSetExploded(int64_t ptr, int32_t exploded) {
    QPieSlice* slice = reinterpret_cast<QPieSlice*>(ptr);
    if (slice) slice->setExploded(exploded != 0);
}

int32_t qPieSliceIsExploded(int64_t ptr) {
    QPieSlice* slice = reinterpret_cast<QPieSlice*>(ptr);
    return slice ? (slice->isExploded() ? 1 : 0) : 0;
}

void qPieSliceSetColor(int64_t ptr, int32_t r, int32_t g, int32_t b, int32_t a) {
    QPieSlice* slice = reinterpret_cast<QPieSlice*>(ptr);
    if (slice) slice->setColor(QColor(r, g, b, a));
}

void qPieSliceSetBorderColor(int64_t ptr, int32_t r, int32_t g, int32_t b, int32_t a) {
    QPieSlice* slice = reinterpret_cast<QPieSlice*>(ptr);
    if (slice) slice->setBorderColor(QColor(r, g, b, a));
}

void qPieSliceSetBorderWidth(int64_t ptr, int32_t width) {
    QPieSlice* slice = reinterpret_cast<QPieSlice*>(ptr);
    if (slice) slice->setBorderWidth(width);
}

void qPieSliceSetLabelColor(int64_t ptr, int32_t r, int32_t g, int32_t b, int32_t a) {
    QPieSlice* slice = reinterpret_cast<QPieSlice*>(ptr);
    if (slice) slice->setLabelColor(QColor(r, g, b, a));
}

void qPieSliceSetLabelArmLengthFactor(int64_t ptr, double factor) {
    QPieSlice* slice = reinterpret_cast<QPieSlice*>(ptr);
    if (slice) slice->setLabelArmLengthFactor(static_cast<qreal>(factor));
}

double qPieSliceLabelArmLengthFactor(int64_t ptr) {
    QPieSlice* slice = reinterpret_cast<QPieSlice*>(ptr);
    return slice ? static_cast<double>(slice->labelArmLengthFactor()) : 0.0;
}

void qPieSliceSetExplodeDistanceFactor(int64_t ptr, double factor) {
    QPieSlice* slice = reinterpret_cast<QPieSlice*>(ptr);
    if (slice) slice->setExplodeDistanceFactor(static_cast<qreal>(factor));
}

double qPieSliceExplodeDistanceFactor(int64_t ptr) {
    QPieSlice* slice = reinterpret_cast<QPieSlice*>(ptr);
    return slice ? static_cast<double>(slice->explodeDistanceFactor()) : 0.0;
}

double qPieSlicePercentage(int64_t ptr) {
    QPieSlice* slice = reinterpret_cast<QPieSlice*>(ptr);
    return slice ? static_cast<double>(slice->percentage()) : 0.0;
}

double qPieSliceStartAngle(int64_t ptr) {
    QPieSlice* slice = reinterpret_cast<QPieSlice*>(ptr);
    return slice ? static_cast<double>(slice->startAngle()) : 0.0;
}

double qPieSliceAngleSpan(int64_t ptr) {
    QPieSlice* slice = reinterpret_cast<QPieSlice*>(ptr);
    return slice ? static_cast<double>(slice->angleSpan()) : 0.0;
}

// ============================================================
// QDateTimeAxis - 日期时间轴
// ============================================================

int64_t qDateTimeAxisCreate() {
    return reinterpret_cast<int64_t>(new QDateTimeAxis());
}

void qDateTimeAxisDelete(int64_t ptr) {
    delete reinterpret_cast<QDateTimeAxis*>(ptr);
}

void qDateTimeAxisSetMin(int64_t ptr, double secsSinceEpoch) {
    QDateTimeAxis* axis = reinterpret_cast<QDateTimeAxis*>(ptr);
    if (axis) axis->setMin(QDateTime::fromSecsSinceEpoch(static_cast<qint64>(secsSinceEpoch)));
}

double qDateTimeAxisMin(int64_t ptr) {
    QDateTimeAxis* axis = reinterpret_cast<QDateTimeAxis*>(ptr);
    if (!axis) return 0.0;
    return static_cast<double>(axis->min().toSecsSinceEpoch());
}

void qDateTimeAxisSetMax(int64_t ptr, double secsSinceEpoch) {
    QDateTimeAxis* axis = reinterpret_cast<QDateTimeAxis*>(ptr);
    if (axis) axis->setMax(QDateTime::fromSecsSinceEpoch(static_cast<qint64>(secsSinceEpoch)));
}

double qDateTimeAxisMax(int64_t ptr) {
    QDateTimeAxis* axis = reinterpret_cast<QDateTimeAxis*>(ptr);
    if (!axis) return 0.0;
    return static_cast<double>(axis->max().toSecsSinceEpoch());
}

void qDateTimeAxisSetRange(int64_t ptr, double minSecs, double maxSecs) {
    QDateTimeAxis* axis = reinterpret_cast<QDateTimeAxis*>(ptr);
    if (axis) {
        axis->setRange(QDateTime::fromSecsSinceEpoch(static_cast<qint64>(minSecs)),
                       QDateTime::fromSecsSinceEpoch(static_cast<qint64>(maxSecs)));
    }
}

void qDateTimeAxisSetFormat(int64_t ptr, const char* format) {
    QDateTimeAxis* axis = reinterpret_cast<QDateTimeAxis*>(ptr);
    if (axis) axis->setFormat(QString::fromUtf8(format));
}

const char* qDateTimeAxisFormat(int64_t ptr) {
    QDateTimeAxis* axis = reinterpret_cast<QDateTimeAxis*>(ptr);
    if (!axis) return nullptr;
    static QByteArray ba;
    ba = axis->format().toUtf8();
    return ba.constData();
}

void qDateTimeAxisSetTickCount(int64_t ptr, int32_t count) {
    QDateTimeAxis* axis = reinterpret_cast<QDateTimeAxis*>(ptr);
    if (axis) axis->setTickCount(count);
}

int32_t qDateTimeAxisTickCount(int64_t ptr) {
    QDateTimeAxis* axis = reinterpret_cast<QDateTimeAxis*>(ptr);
    return axis ? axis->tickCount() : 0;
}

// ============================================================
// QLogValueAxis - 对数轴
// ============================================================

int64_t qLogValueAxisCreate() {
    return reinterpret_cast<int64_t>(new QLogValueAxis());
}

void qLogValueAxisDelete(int64_t ptr) {
    delete reinterpret_cast<QLogValueAxis*>(ptr);
}

void qLogValueAxisSetMin(int64_t ptr, double min) {
    QLogValueAxis* axis = reinterpret_cast<QLogValueAxis*>(ptr);
    if (axis) axis->setMin(static_cast<qreal>(min));
}

double qLogValueAxisMin(int64_t ptr) {
    QLogValueAxis* axis = reinterpret_cast<QLogValueAxis*>(ptr);
    return axis ? static_cast<double>(axis->min()) : 0.0;
}

void qLogValueAxisSetMax(int64_t ptr, double max) {
    QLogValueAxis* axis = reinterpret_cast<QLogValueAxis*>(ptr);
    if (axis) axis->setMax(static_cast<qreal>(max));
}

double qLogValueAxisMax(int64_t ptr) {
    QLogValueAxis* axis = reinterpret_cast<QLogValueAxis*>(ptr);
    return axis ? static_cast<double>(axis->max()) : 0.0;
}

void qLogValueAxisSetRange(int64_t ptr, double min, double max) {
    QLogValueAxis* axis = reinterpret_cast<QLogValueAxis*>(ptr);
    if (axis) axis->setRange(static_cast<qreal>(min), static_cast<qreal>(max));
}

void qLogValueAxisSetLabelFormat(int64_t ptr, const char* format) {
    QLogValueAxis* axis = reinterpret_cast<QLogValueAxis*>(ptr);
    if (axis) axis->setLabelFormat(QString::fromUtf8(format));
}

const char* qLogValueAxisLabelFormat(int64_t ptr) {
    QLogValueAxis* axis = reinterpret_cast<QLogValueAxis*>(ptr);
    if (!axis) return nullptr;
    static QByteArray ba;
    ba = axis->labelFormat().toUtf8();
    return ba.constData();
}

void qLogValueAxisSetBase(int64_t ptr, double base) {
    QLogValueAxis* axis = reinterpret_cast<QLogValueAxis*>(ptr);
    if (axis) axis->setBase(static_cast<qreal>(base));
}

double qLogValueAxisBase(int64_t ptr) {
    QLogValueAxis* axis = reinterpret_cast<QLogValueAxis*>(ptr);
    return axis ? static_cast<double>(axis->base()) : 10.0;
}

int32_t qLogValueAxisTickCount(int64_t ptr) {
    QLogValueAxis* axis = reinterpret_cast<QLogValueAxis*>(ptr);
    return axis ? axis->tickCount() : 0;
}

void qLogValueAxisSetMinorTickCount(int64_t ptr, int32_t count) {
    QLogValueAxis* axis = reinterpret_cast<QLogValueAxis*>(ptr);
    if (axis) axis->setMinorTickCount(count);
}

int32_t qLogValueAxisMinorTickCount(int64_t ptr) {
    QLogValueAxis* axis = reinterpret_cast<QLogValueAxis*>(ptr);
    return axis ? axis->minorTickCount() : 0;
}

// ============================================================
// QHorizontalBarSeries - 水平柱状图序列
// ============================================================

int64_t qHorizontalBarSeriesCreate() {
    return reinterpret_cast<int64_t>(new QHorizontalBarSeries());
}

void qHorizontalBarSeriesDelete(int64_t ptr) {
    delete reinterpret_cast<QHorizontalBarSeries*>(ptr);
}

void qHorizontalBarSeriesAppend(int64_t ptr, int64_t setPtr) {
    QHorizontalBarSeries* series = reinterpret_cast<QHorizontalBarSeries*>(ptr);
    QBarSet* set = reinterpret_cast<QBarSet*>(setPtr);
    if (series && set) series->append(set);
}

void qHorizontalBarSeriesRemove(int64_t ptr, int64_t setPtr) {
    QHorizontalBarSeries* series = reinterpret_cast<QHorizontalBarSeries*>(ptr);
    QBarSet* set = reinterpret_cast<QBarSet*>(setPtr);
    if (series && set) series->remove(set);
}

void qHorizontalBarSeriesInsert(int64_t ptr, int32_t index, int64_t setPtr) {
    QHorizontalBarSeries* series = reinterpret_cast<QHorizontalBarSeries*>(ptr);
    QBarSet* set = reinterpret_cast<QBarSet*>(setPtr);
    if (series && set) series->insert(static_cast<int>(index), set);
}

int32_t qHorizontalBarSeriesCount(int64_t ptr) {
    QHorizontalBarSeries* series = reinterpret_cast<QHorizontalBarSeries*>(ptr);
    return series ? static_cast<int32_t>(series->count()) : 0;
}

void qHorizontalBarSeriesClear(int64_t ptr) {
    QHorizontalBarSeries* series = reinterpret_cast<QHorizontalBarSeries*>(ptr);
    if (series) series->clear();
}

void qHorizontalBarSeriesSetBarWidth(int64_t ptr, double width) {
    QHorizontalBarSeries* series = reinterpret_cast<QHorizontalBarSeries*>(ptr);
    if (series) series->setBarWidth(static_cast<qreal>(width));
}

void qHorizontalBarSeriesSetLabelsVisible(int64_t ptr, int32_t visible) {
    QHorizontalBarSeries* series = reinterpret_cast<QHorizontalBarSeries*>(ptr);
    if (series) series->setLabelsVisible(visible != 0);
}

void qHorizontalBarSeriesSetLabelsPosition(int64_t ptr, int32_t position) {
    QHorizontalBarSeries* series = reinterpret_cast<QHorizontalBarSeries*>(ptr);
    if (series) series->setLabelsPosition(static_cast<QAbstractBarSeries::LabelsPosition>(position));
}

// ============================================================
// QHorizontalPercentBarSeries - 水平百分比柱状图序列
// ============================================================

int64_t qHorizontalPercentBarSeriesCreate() {
    return reinterpret_cast<int64_t>(new QHorizontalPercentBarSeries());
}

void qHorizontalPercentBarSeriesDelete(int64_t ptr) {
    delete reinterpret_cast<QHorizontalPercentBarSeries*>(ptr);
}

void qHorizontalPercentBarSeriesAppend(int64_t ptr, int64_t setPtr) {
    QHorizontalPercentBarSeries* series = reinterpret_cast<QHorizontalPercentBarSeries*>(ptr);
    QBarSet* set = reinterpret_cast<QBarSet*>(setPtr);
    if (series && set) series->append(set);
}

void qHorizontalPercentBarSeriesRemove(int64_t ptr, int64_t setPtr) {
    QHorizontalPercentBarSeries* series = reinterpret_cast<QHorizontalPercentBarSeries*>(ptr);
    QBarSet* set = reinterpret_cast<QBarSet*>(setPtr);
    if (series && set) series->remove(set);
}

void qHorizontalPercentBarSeriesInsert(int64_t ptr, int32_t index, int64_t setPtr) {
    QHorizontalPercentBarSeries* series = reinterpret_cast<QHorizontalPercentBarSeries*>(ptr);
    QBarSet* set = reinterpret_cast<QBarSet*>(setPtr);
    if (series && set) series->insert(static_cast<int>(index), set);
}

int32_t qHorizontalPercentBarSeriesCount(int64_t ptr) {
    QHorizontalPercentBarSeries* series = reinterpret_cast<QHorizontalPercentBarSeries*>(ptr);
    return series ? static_cast<int32_t>(series->count()) : 0;
}

void qHorizontalPercentBarSeriesClear(int64_t ptr) {
    QHorizontalPercentBarSeries* series = reinterpret_cast<QHorizontalPercentBarSeries*>(ptr);
    if (series) series->clear();
}

void qHorizontalPercentBarSeriesSetBarWidth(int64_t ptr, double width) {
    QHorizontalPercentBarSeries* series = reinterpret_cast<QHorizontalPercentBarSeries*>(ptr);
    if (series) series->setBarWidth(static_cast<qreal>(width));
}

void qHorizontalPercentBarSeriesSetLabelsVisible(int64_t ptr, int32_t visible) {
    QHorizontalPercentBarSeries* series = reinterpret_cast<QHorizontalPercentBarSeries*>(ptr);
    if (series) series->setLabelsVisible(visible != 0);
}

void qHorizontalPercentBarSeriesSetLabelsPosition(int64_t ptr, int32_t position) {
    QHorizontalPercentBarSeries* series = reinterpret_cast<QHorizontalPercentBarSeries*>(ptr);
    if (series) series->setLabelsPosition(static_cast<QAbstractBarSeries::LabelsPosition>(position));
}

// ============================================================
// QHorizontalStackedBarSeries - 水平堆叠柱状图序列
// ============================================================

int64_t qHorizontalStackedBarSeriesCreate() {
    return reinterpret_cast<int64_t>(new QHorizontalStackedBarSeries());
}

void qHorizontalStackedBarSeriesDelete(int64_t ptr) {
    delete reinterpret_cast<QHorizontalStackedBarSeries*>(ptr);
}

void qHorizontalStackedBarSeriesAppend(int64_t ptr, int64_t setPtr) {
    QHorizontalStackedBarSeries* series = reinterpret_cast<QHorizontalStackedBarSeries*>(ptr);
    QBarSet* set = reinterpret_cast<QBarSet*>(setPtr);
    if (series && set) series->append(set);
}

void qHorizontalStackedBarSeriesRemove(int64_t ptr, int64_t setPtr) {
    QHorizontalStackedBarSeries* series = reinterpret_cast<QHorizontalStackedBarSeries*>(ptr);
    QBarSet* set = reinterpret_cast<QBarSet*>(setPtr);
    if (series && set) series->remove(set);
}

void qHorizontalStackedBarSeriesInsert(int64_t ptr, int32_t index, int64_t setPtr) {
    QHorizontalStackedBarSeries* series = reinterpret_cast<QHorizontalStackedBarSeries*>(ptr);
    QBarSet* set = reinterpret_cast<QBarSet*>(setPtr);
    if (series && set) series->insert(static_cast<int>(index), set);
}

int32_t qHorizontalStackedBarSeriesCount(int64_t ptr) {
    QHorizontalStackedBarSeries* series = reinterpret_cast<QHorizontalStackedBarSeries*>(ptr);
    return series ? static_cast<int32_t>(series->count()) : 0;
}

void qHorizontalStackedBarSeriesClear(int64_t ptr) {
    QHorizontalStackedBarSeries* series = reinterpret_cast<QHorizontalStackedBarSeries*>(ptr);
    if (series) series->clear();
}

void qHorizontalStackedBarSeriesSetBarWidth(int64_t ptr, double width) {
    QHorizontalStackedBarSeries* series = reinterpret_cast<QHorizontalStackedBarSeries*>(ptr);
    if (series) series->setBarWidth(static_cast<qreal>(width));
}

void qHorizontalStackedBarSeriesSetLabelsVisible(int64_t ptr, int32_t visible) {
    QHorizontalStackedBarSeries* series = reinterpret_cast<QHorizontalStackedBarSeries*>(ptr);
    if (series) series->setLabelsVisible(visible != 0);
}

void qHorizontalStackedBarSeriesSetLabelsPosition(int64_t ptr, int32_t position) {
    QHorizontalStackedBarSeries* series = reinterpret_cast<QHorizontalStackedBarSeries*>(ptr);
    if (series) series->setLabelsPosition(static_cast<QAbstractBarSeries::LabelsPosition>(position));
}

} // extern "C"