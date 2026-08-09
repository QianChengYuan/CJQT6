// ============================================================
// gen.cj — .ui 结构 → CJQT6 仓颉源码 生成器
//
// 移植自 Python 脚手架 uic2cj.py 的核心逻辑：
//   - 控件/布局/信号映射表；
//   - 布局（hbox/vbox/grid/form，可嵌套）与绝对定位两种形态；
//   - 属性按控件类型分派；import 自动按需合并；
//   - 信号连接 → setOnXxx(回调)，回调骨架生成在 main 之前。
// ============================================================

package Ui2Cj

import std.collection.*
import std.convert.*
import std.fs.*
import std.sort.*

// ------------------------------------------------------------
// 全局生成状态（单次运行）
// ------------------------------------------------------------
var gUsedImports = HashMap<String, HashSet<String>>()
var gCallbacks = ArrayList<CallbackInfo>()
var gUsedNames = HashSet<String>()
var gNameMap = HashMap<String, String>()

public class CallbackInfo {
    public var varName: String
    public var cbType: String
    public var sender: String
    public var signal: String

    public init(varName: String, cbType: String, sender: String, signal: String) {
        this.varName = varName
        this.cbType = cbType
        this.sender = sender
        this.signal = signal
    }
}

func initGenState(): Unit {
    gUsedImports = HashMap<String, HashSet<String>>()
    gCallbacks = ArrayList<CallbackInfo>()
    gUsedNames = HashSet<String>()
    gNameMap = HashMap<String, String>()
    addImport("QApplication", "cjqt6.core")
}

func addImport(cls: String, mod: String): Unit {
    let set = gUsedImports.get(mod)
    if (let Some(s) <- set) {
        s.add(cls)
    } else {
        let ns = HashSet<String>()
        ns.add(cls)
        gUsedImports[mod] = ns
    }
}

// ------------------------------------------------------------
// 名称处理
// ------------------------------------------------------------
func safeName(name: String): String {
    if (let Some(existing) <- gNameMap.get(name)) {
        return existing
    }
    var safe = StringBuilder()
    for (r in name.runes()) {
        if ((r >= r'a' && r <= r'z') || (r >= r'A' && r <= r'Z') ||
            (r >= r'0' && r <= r'9') || r == r'_') {
            safe.append(r)
        } else {
            safe.append(r'_')
        }
    }
    var base = safe.toString()
    if (base.isEmpty()) {
        base = "_"
    } else {
        let first = Rune(base[0])
        if (first >= r'0' && first <= r'9') {
            base = "_" + base
        }
    }
    var candidate = base
    var n: Int64 = 2
    while (gUsedNames.contains(candidate)) {
        candidate = "${base}_${n}"
        n++
    }
    gUsedNames.add(candidate)
    gNameMap[name] = candidate
    return candidate
}

// Cangjie 字符串字面量转义
func cstr(s: String): String {
    let sb = StringBuilder()
    for (r in s.runes()) {
        if (r == r'\\') {
            sb.append("\\\\")
        } else if (r == r'"') {
            sb.append("\\\"")
        } else if (r == r'\n') {
            sb.append("\\n")
        } else if (r == r'\r') {
            sb.append("\\r")
        } else {
            sb.append(r)
        }
    }
    return sb.toString()
}

// ------------------------------------------------------------
// 映射表
// ------------------------------------------------------------
// Qt 类名 → (CJQT6 构造类, import 模块)
var WIDGET_MAP = HashMap<String, String>()
var WIDGET_MOD = HashMap<String, String>()

func initMaps(): Unit {
    WIDGET_MAP = HashMap<String, String>()
    WIDGET_MOD = HashMap<String, String>()
    // (class, cjqt6 class, module)
    let entries = [
        ("QWidget", "QWidget", "cjqt6.core"),
        ("QPushButton", "QPushButton", "cjqt6.widgets"),
        ("QToolButton", "QToolButton", "cjqt6.widgets"),
        ("QLabel", "QLabel", "cjqt6.widgets"),
        ("QLineEdit", "QLineEdit", "cjqt6.widgets"),
        ("QTextEdit", "QTextEdit", "cjqt6.widgets"),
        ("QPlainTextEdit", "QPlainTextEdit", "cjqt6.widgets"),
        ("QTextBrowser", "QTextBrowser", "cjqt6.widgets"),
        ("QCheckBox", "QCheckBox", "cjqt6.widgets"),
        ("QRadioButton", "QRadioButton", "cjqt6.widgets"),
        ("QComboBox", "QComboBox", "cjqt6.widgets"),
        ("QSpinBox", "QSpinBox", "cjqt6.widgets"),
        ("QDoubleSpinBox", "QDoubleSpinBox", "cjqt6.widgets"),
        ("QSlider", "QSlider", "cjqt6.widgets"),
        ("QProgressBar", "QProgressBar", "cjqt6.widgets"),
        ("QGroupBox", "QGroupBox", "cjqt6.widgets"),
        ("QTabWidget", "QTabWidget", "cjqt6.widgets"),
        ("QScrollArea", "QScrollArea", "cjqt6.widgets"),
        ("QFrame", "QFrame", "cjqt6.widgets"),
        ("QSplitter", "QSplitter", "cjqt6.widgets"),
        ("QCalendarWidget", "QCalendarWidget", "cjqt6.widgets"),
        ("QDateEdit", "QDateEdit", "cjqt6.widgets"),
        ("QTimeEdit", "QTimeEdit", "cjqt6.widgets"),
        ("QDateTimeEdit", "QDateTimeEdit", "cjqt6.widgets"),
        ("QListWidget", "QListWidget", "cjqt6.views"),
        ("QTableWidget", "QTableWidget", "cjqt6.views"),
        ("QTreeWidget", "QTreeWidget", "cjqt6.views"),
        ("QMainWindow", "QMainWindow", "cjqt6.menu"),
        ("QMenuBar", "QMenuBar", "cjqt6.menu"),
        ("QMenu", "QMenu", "cjqt6.menu"),
        ("QAction", "QAction", "cjqt6.menu"),
        ("QToolBar", "QToolBar", "cjqt6.menu"),
        ("QStatusBar", "QStatusBar", "cjqt6.menu"),
        ("QStackedWidget", "QStackedWidget", "cjqt6.widgets"),
        ("QDockWidget", "QDockWidget", "cjqt6.widgets"),
    ]
    for (e in entries) {
        WIDGET_MAP[e[0]] = e[1]
        WIDGET_MOD[e[0]] = e[2]
    }
}

// 布局类名 → (CJQT6 布局类, import 模块)
var LAYOUT_TAGS = HashMap<String, String>()
var LAYOUT_MOD = HashMap<String, String>()

func initLayoutMaps(): Unit {
    LAYOUT_TAGS = HashMap<String, String>()
    LAYOUT_MOD = HashMap<String, String>()
    let entries = [
        ("hboxlayout", "QHBoxLayout", "cjqt6.gui"),
        ("vboxlayout", "QVBoxLayout", "cjqt6.gui"),
        ("gridlayout", "QGridLayout", "cjqt6.gui"),
        ("formlayout", "QFormLayout", "cjqt6.gui"),
    ]
    for (e in entries) {
        LAYOUT_TAGS[e[0]] = e[1]
        LAYOUT_MOD[e[0]] = e[2]
    }
}

// 信号 → (setter, 回调类型)
var SIGNAL_MAP = HashMap<String, (String, String)>()

func initSignalMaps(): Unit {
    SIGNAL_MAP = HashMap<String, (String, String)>()
    let entries = [
        ("clicked()", "setOnClick", "VoidCallback"),
        ("clicked(bool)", "setOnClickedChecked", "Int32Callback"),
        ("toggled(bool)", "setOnToggled", "Int32Callback"),
        ("textChanged(QString)", "setOnTextChanged", "CStringCallback"),
        ("returnPressed()", "setOnReturnPressed", "VoidCallback"),
        ("editingFinished()", "setOnEditingFinished", "VoidCallback"),
        ("valueChanged(int)", "setOnValueChanged", "Int32Callback"),
        ("valueChanged(double)", "setOnValueChanged", "Float64Callback"),
        ("currentIndexChanged(int)", "setOnCurrentIndexChanged", "Int32Callback"),
        ("currentTextChanged(QString)", "setOnCurrentTextChanged", "CStringCallback"),
        ("stateChanged(int)", "setOnStateChanged", "Int32Callback"),
        ("sliderMoved(int)", "setOnSliderMoved", "Int32Callback"),
        ("activated(int)", "setOnActivated", "Int32Callback"),
    ]
    for (e in entries) {
        SIGNAL_MAP[e[0]] = (e[1], e[2])
    }
}

// 对齐 → 16 进制值
func alignValue(v: String): String {
    match (v) {
        case "AlignLeft" => "0x0001"
        case "AlignRight" => "0x0002"
        case "AlignHCenter" => "0x0004"
        case "AlignTop" => "0x0020"
        case "AlignBottom" => "0x0040"
        case "AlignVCenter" => "0x0080"
        case "AlignCenter" => "0x0084"
        case _ => "0x0001"
    }
}

// ------------------------------------------------------------
// .ui 属性取值辅助
// ------------------------------------------------------------
// <string>xxx</string>
func getString(pr: XmlNode): String {
    for (c in pr.children) {
        if (c.tag == "string") {
            return c.text
        }
    }
    return ""
}

// <bool>true</bool>
func getBool(pr: XmlNode): Bool {
    for (c in pr.children) {
        if (c.tag == "bool") {
            return c.text == "true"
        }
    }
    return false
}

// <enum>xxx</enum> 或 <set>xxx</set>，去掉 'Qt::' 作用域前缀
func getEnum(pr: XmlNode): String {
    var e = ""
    for (c in pr.children) {
        if (c.tag == "enum" || c.tag == "set") {
            e = c.text
            break
        }
    }
    let idx = e.lastIndexOf("::")
    if (let Some(i) <- idx) {
        return e[i + 2..]
    }
    return e
}

// <number>8</number>
func getNumber(pr: XmlNode): Int64 {
    for (c in pr.children) {
        if (c.tag == "number") {
            let t = c.text.trimAscii()
            if (let Some(n) <- Int64.tryParse(t)) {
                return n
            }
            return 0
        }
    }
    return 0
}

// <rect><x>..</x><y>..</y><width>..</width><height>..</height></rect>
func rectValue(pr: XmlNode): (Int64, Int64, Int64, Int64) {
    if (let Some(rect) <- pr.findChild("rect")) {
        var x = 0
        var y = 0
        var w = 0
        var h = 0
        for (c in rect.children) {
            let n = getChildNumber(c)
            match (c.tag) {
                case "x" => x = n
                case "y" => y = n
                case "width" => w = n
                case "height" => h = n
                case _ => ()
            }
        }
        return (x, y, w, h)
    }
    return (0, 0, 0, 0)
}

func getChildNumber(node: XmlNode): Int64 {
    let t = node.text.trimAscii()
    if (let Some(n) <- Int64.tryParse(t)) {
        return n
    }
    return 0
}

// <size><width>..</width><height>..</height></size>
func sizeValue(elem: XmlNode): (Int64, Int64) {
    var w: Int64 = 0
    var h: Int64 = 0
    for (c in elem.children) {
        if (c.tag == "width") {
            w = getChildNumber(c)
        } else if (c.tag == "height") {
            h = getChildNumber(c)
        }
    }
    return (w, h)
}

// ------------------------------------------------------------
// 属性处理
// ------------------------------------------------------------
func handleProperty(widgetType: String, propName: String, pr: XmlNode, varName: String): ArrayList<String> {
    let lines = ArrayList<String>()
    let wtype = widgetType
    let v = varName

    if (propName == "geometry") {
        // 由上层决定绝对定位或布局接管
        return lines
    } else if (propName == "windowTitle") {
        lines.add("    ${v}.setTitle(\"${cstr(getString(pr))}\")")
    } else if (propName == "enabled") {
        if (!getBool(pr)) {
            lines.add("    ${v}.setEnabled(false)")
        }
    } else if (propName == "toolTip") {
        lines.add("    ${v}.setToolTip(\"${cstr(getString(pr))}\")")
    } else if (propName == "statusTip") {
        lines.add("    ${v}.setToolTip(\"${cstr(getString(pr))}\")")
    } else if (propName == "styleSheet") {
        lines.add("    ${v}.setStyleSheet(\"${cstr(getString(pr))}\")")
    } else if (propName == "minimumSize") {
        let (w, h) = sizeValue(pr)
        if (w != 0 || h != 0) {
            lines.add("    ${v}.setMinimumSize(${w}, ${h})")
        }
    } else if (propName == "maximumSize") {
        let (w, h) = sizeValue(pr)
        lines.add("    ${v}.setMaximumSize(${w}, ${h})")
    } else if (propName == "font") {
        // CJQT6 暂无通用 setFont
        return lines
    }

    // === 按钮 ===
    if (wtype == "QPushButton" || wtype == "QToolButton" || wtype == "QCommandLinkButton") {
        if (propName == "text") {
            lines.add("    ${v}.setText(\"${cstr(getString(pr))}\")")
        } else if (propName == "checkable" && getBool(pr)) {
            lines.add("    ${v}.setCheckable(true)")
        } else if (propName == "checked" && getBool(pr)) {
            lines.add("    ${v}.setChecked(true)")
        } else if (propName == "default" && getBool(pr)) {
            lines.add("    ${v}.setDefault(true)")
        }
    }

    // === 标签 ===
    if (wtype == "QLabel") {
        if (propName == "text") {
            lines.add("    ${v}.setText(\"${cstr(getString(pr))}\")")
        } else if (propName == "alignment") {
            lines.add("    ${v}.setAlignment(${alignValue(getEnum(pr))})")
        } else if (propName == "wordWrap" && getBool(pr)) {
            lines.add("    ${v}.setWordWrap(true)")
        }
    }

    // === 单行输入 ===
    if (wtype == "QLineEdit") {
        if (propName == "text") {
            lines.add("    ${v}.setText(\"${cstr(getString(pr))}\")")
        } else if (propName == "placeholderText") {
            lines.add("    ${v}.setPlaceholder(\"${cstr(getString(pr))}\")")
        } else if (propName == "readOnly" && getBool(pr)) {
            lines.add("    ${v}.setReadOnly(true)")
        } else if (propName == "echoMode" && getEnum(pr) == "Password") {
            lines.add("    ${v}.setEchoMode(2)")
        } else if (propName == "maxLength") {
            lines.add("    ${v}.setMaxLength(${getNumber(pr)})")
        } else if (propName == "alignment") {
            lines.add("    ${v}.setAlignment(${alignValue(getEnum(pr))})")
        }
    }

    // === 多行输入 ===
    if (wtype == "QTextEdit" || wtype == "QPlainTextEdit" || wtype == "QTextBrowser") {
        if (propName == "html" || propName == "plainText") {
            lines.add("    ${v}.setText(\"${cstr(getString(pr))}\")")
        } else if (propName == "readOnly" && getBool(pr)) {
            lines.add("    ${v}.setReadOnly(true)")
        }
    }

    // === 选择框 ===
    if (wtype == "QCheckBox" || wtype == "QRadioButton") {
        if (propName == "text") {
            lines.add("    ${v}.setText(\"${cstr(getString(pr))}\")")
        } else if (propName == "checked" && getBool(pr)) {
            lines.add("    ${v}.setChecked(true)")
        }
    }

    // === 滑块 ===
    if (wtype == "QSlider") {
        if (propName == "orientation") {
            let e = getEnum(pr)
            let horiz = if (e == "Horizontal") { "Horizontal" } else { "Vertical" }
            lines.add("    ${v}.setOrientation(Orientation.${horiz}.value())")
        } else if (propName == "maximum") {
            lines.add("    ${v}.setRange(0, ${getNumber(pr)})")
        } else if (propName == "value") {
            lines.add("    ${v}.setValue(${getNumber(pr)})")
        } else if (propName == "singleStep") {
            lines.add("    ${v}.setSingleStep(${getNumber(pr)})")
        }
    }

    // === 进度条 ===
    if (wtype == "QProgressBar") {
        if (propName == "minimum") {
            lines.add("    ${v}.setRange(${getNumber(pr)}, 100)")
        } else if (propName == "maximum") {
            lines.add("    ${v}.setRange(0, ${getNumber(pr)})")
        } else if (propName == "value") {
            lines.add("    ${v}.setValue(${getNumber(pr)})")
        }
    }

    // === 数值框 ===
    if (wtype == "QSpinBox" || wtype == "QDoubleSpinBox") {
        if (propName == "minimum") {
            lines.add("    ${v}.setMinimum(${getNumber(pr)})")
        } else if (propName == "maximum") {
            lines.add("    ${v}.setMaximum(${getNumber(pr)})")
        } else if (propName == "value") {
            lines.add("    ${v}.setValue(${getNumber(pr)})")
        } else if (propName == "prefix") {
            lines.add("    ${v}.setPrefix(\"${cstr(getString(pr))}\")")
        } else if (propName == "suffix") {
            lines.add("    ${v}.setSuffix(\"${cstr(getString(pr))}\")")
        }
    }

    // === 组合框 ===
    if (wtype == "QComboBox") {
        if (propName == "currentIndex") {
            let idx = getNumber(pr)
            if (idx != 0) {
                lines.add("    ${v}.setCurrentIndex(${idx})")
            }
        } else if (propName == "editable" && getBool(pr)) {
            lines.add("    ${v}.setEditable(true)")
        }
    }

    // === 分组框 ===
    if (wtype == "QGroupBox") {
        if (propName == "title") {
            lines.add("    ${v}.setTitle(\"${cstr(getString(pr))}\")")
        } else if (propName == "checkable" && getBool(pr)) {
            lines.add("    ${v}.setCheckable(true)")
        }
    }

    // === 页签 ===
    if (wtype == "QTabWidget") {
        if (propName == "currentIndex") {
            lines.add("    ${v}.setCurrentIndex(${getNumber(pr)})")
        }
    }

    return lines
}

func processWidgetProps(widget: XmlNode, varName: String, codeLines: ArrayList<String>): Unit {
    let wtype = widget.attr("class")
    for (pr in widget.findChildren("property")) {
        let pn = pr.attr("name")
        for (line in handleProperty(wtype, pn, pr, varName)) {
            codeLines.add(line)
        }
    }
}

// ------------------------------------------------------------
// 控件树生成
// ------------------------------------------------------------
func genWidget(widget: XmlNode, varName: String, codeLines: ArrayList<String>, indent: Int64): Unit {
    let prefix = " " * indent
    let cls = widget.attr("class")
    codeLines.add("${prefix}let ${varName} = ${cls}()")
    processWidgetProps(widget, varName, codeLines)

    if (let Some(layout) <- widget.findChild("layout")) {
        genLayout(layout, varName, codeLines, indent)
        return
    }

    // 绝对定位：几何 + 父子关系
    for (child in widget.children) {
        if (child.tag != "widget") {
            continue
        }
        let ctype = child.attr("class")
        if (!WIDGET_MAP.contains(ctype)) {
            continue
        }
        let cName = child.attr("name")
        let cVar = safeName(cName)
        let wCls = WIDGET_MAP.get(ctype).getOrThrow()
        addImport(wCls, WIDGET_MOD.get(ctype).getOrThrow())
        codeLines.add("${prefix}let ${cVar} = ${wCls}()")

        for (pr in child.findChildren("property")) {
            if (pr.attr("name") == "geometry") {
                let (x, y, w, h) = rectValue(pr)
                codeLines.add("${prefix}setWidgetGeometry(${cVar}.getPtr(), ${x}, ${y}, ${w}, ${h})")
            }
        }
        processWidgetProps(child, cVar, codeLines)
        codeLines.add("${prefix}setWidgetParent(${cVar}.getPtr(), ${varName}.getPtr())")

        if (let Some(sub) <- child.findChild("layout")) {
            genLayout(sub, cVar, codeLines, indent)
        }
        for (subchild in child.children) {
            if (subchild.tag == "widget") {
                let subVar = safeName(subchild.attr("name"))
                genWidget(subchild, subVar, codeLines, indent)
                codeLines.add("${prefix}setWidgetParent(${subVar}.getPtr(), ${cVar}.getPtr())")
            }
        }
    }
}

// 创建布局对象并填充 items（不挂载到父）；返回是否成功
func createLayout(layoutElem: XmlNode, lname: String, codeLines: ArrayList<String>, indent: Int64): Bool {
    let prefix = " " * indent
    let layoutClass = layoutElem.attr("class")
    var tag = ""
    if (layoutClass.startsWith("Q")) {
        tag = layoutClass[1..].toAsciiLower()
    } else {
        tag = layoutClass.toAsciiLower()
    }
    if (!LAYOUT_TAGS.contains(tag)) {
        return false
    }
    let cls = LAYOUT_TAGS.get(tag).getOrThrow()
    addImport(cls, LAYOUT_MOD.get(tag).getOrThrow())
    codeLines.add("${prefix}let ${lname} = ${cls}()")

    for (pr in layoutElem.findChildren("property")) {
        let pn = pr.attr("name")
        if (pn == "spacing") {
            codeLines.add("${prefix}${lname}.setSpacing(${getNumber(pr)})")
        } else if (pn == "margin") {
            codeLines.add("${prefix}${lname}.setMargin(${getNumber(pr)})")
        }
    }

    if (tag == "formlayout") {
        fillFormLayout(layoutElem, lname, codeLines, indent)
        return true
    }

    var row: Int64 = 0
    for (item in layoutElem.children) {
        if (item.tag != "item") {
            continue
        }
        var r: Int64 = row
        let rtxt = findItemText(item, "row")
        if (!rtxt.isEmpty()) {
            if (let Some(n) <- Int64.tryParse(rtxt)) {
                r = n
            }
        }
        var c: Int64 = 0
        let ctxt = findItemText(item, "column")
        if (!ctxt.isEmpty()) {
            if (let Some(n) <- Int64.tryParse(ctxt)) {
                c = n
            }
        }
        let rs = findItemText(item, "rowspan")
        let cs = findItemText(item, "colspan")

        if (let Some(w) <- item.findChild("widget")) {
            let wtype = w.attr("class")
            let wName = w.attr("name")
            if (WIDGET_MAP.contains(wtype)) {
                let wCls = WIDGET_MAP.get(wtype).getOrThrow()
                addImport(wCls, WIDGET_MOD.get(wtype).getOrThrow())
                let wv = safeName(wName)
                genWidget(w, wv, codeLines, indent)
                if (tag == "gridlayout") {
                    if (!rs.isEmpty() || !cs.isEmpty()) {
                        let rsv: Int64 = if (rs.isEmpty()) { 1 } else { Int64.tryParse(rs).getOrThrow() }
                        let csv: Int64 = if (cs.isEmpty()) { 1 } else { Int64.tryParse(cs).getOrThrow() }
                        codeLines.add("${prefix}${lname}.addWidget(${wv}.getPtr(), ${r}, ${c}, ${rsv}, ${csv})")
                    } else {
                        codeLines.add("${prefix}${lname}.addWidget(${wv}.getPtr(), ${r}, ${c})")
                    }
                } else {
                    codeLines.add("${prefix}${lname}.addWidget(${wv}.getPtr())")
                }
            }
        }

        if (!item.findChild("spacer").isNone()) {
            codeLines.add("${prefix}${lname}.addStretch()")
        }

        if (let Some(subLayout) <- item.findChild("layout")) {
            let subLname = layoutVarName(subLayout, "${lname}_sub")
            if (createLayout(subLayout, subLname, codeLines, indent)) {
                codeLines.add("${prefix}${lname}.addLayout(${subLname}.getPtr())")
            }
        }

        if (tag != "gridlayout") {
            row++
        }    }
    return true
}

func findItemText(item: XmlNode, tagName: String): String {
    if (let Some(c) <- item.findChild(tagName)) {
        return c.text.trimAscii()
    }
    return ""
}

// QFormLayout：按行分组，label+field 成对 addRowWidget，否则 addRow("", ptr)
func fillFormLayout(layoutElem: XmlNode, lname: String, codeLines: ArrayList<String>, indent: Int64): Unit {
    let prefix = " " * indent
    // 收集每行 widget（按行号）
    var rowOrder = ArrayList<Int64>()
    var rows: HashMap<Int64, ArrayList<String>> = HashMap<Int64, ArrayList<String>>()
    for (item in layoutElem.children) {
        if (item.tag != "item") {
            continue
        }
        var r: Int64 = 0
        let rtxt = findItemText(item, "row")
        if (!rtxt.isEmpty()) {
            if (let Some(n) <- Int64.tryParse(rtxt)) {
                r = n
            }
        }
        if (let Some(w) <- item.findChild("widget")) {
            let wtype = w.attr("class")
            if (WIDGET_MAP.contains(wtype)) {
                let wCls = WIDGET_MAP.get(wtype).getOrThrow()
                addImport(wCls, WIDGET_MOD.get(wtype).getOrThrow())
                let wv = safeName(w.attr("name"))
                genWidget(w, wv, codeLines, indent)
                if (!rows.contains(r)) {
                    rows[r] = ArrayList<String>()
                    rowOrder.add(r)
                }
                rows.get(r).getOrThrow().add(wv)
            }
        }
    }
    // 按行号排序输出
    sort(rowOrder)
    for (r in rowOrder) {
        let ws = rows.get(r).getOrThrow()
        if (ws.size >= 2) {
            codeLines.add("${prefix}${lname}.addRowWidget(${ws[0]}.getPtr(), ${ws[1]}.getPtr())")
        } else if (ws.size == 1) {
            codeLines.add("${prefix}${lname}.addRow(\"\", ${ws[0]}.getPtr())")
        }
    }
}

func genLayout(layoutElem: XmlNode, parentVar: String, codeLines: ArrayList<String>, indent: Int64): Unit {
    let prefix = " " * indent
    let lname = layoutVarName(layoutElem, "${parentVar}_layout")
    if (createLayout(layoutElem, lname, codeLines, indent)) {
        codeLines.add("${prefix}${parentVar}.setLayout(${lname}.getPtr())")
    }
}

// 布局变量名：优先取 .ui 布局元素自身的 name 属性（如 verticalLayout_4），
// 缺失时退回派生命名。Qt Designer 保证布局 name 唯一，可避免同名冲突。
func layoutVarName(layoutElem: XmlNode, fallback: String): String {
    let n = layoutElem.attr("name")
    if (n.isEmpty()) {
        return safeName(fallback)
    }
    safeName(n)
}

// ------------------------------------------------------------
// 信号连接
// ------------------------------------------------------------
func sigName(s: String): String {
    let idx = s.indexOf("(")
    if (let Some(i) <- idx) {
        return s[0..i]
    }
    return s
}

func handleConnections(root: XmlNode, codeLines: ArrayList<String>): Unit {
    if (let Some(conns) <- root.findChild("connections")) {
        var count: Int64 = 0
        for (conn in conns.findChildren("connection")) {
            let sender = findItemText(conn, "sender")
            let signal = findItemText(conn, "signal")
            if (sender.isEmpty() || signal.isEmpty() || !SIGNAL_MAP.contains(signal)) {
                continue
            }
            let (method, cbType) = SIGNAL_MAP.get(signal).getOrThrow()
            let sv = safeName(sender)
            let cv = safeName("on_${sv}_${sigName(signal)}")
            if (count == 0) {
                codeLines.add("")
                codeLines.add("    // ===== 信号连接 =====")
            }
            codeLines.add("    ${sv}.${method}(${cv})")
            gCallbacks.add(CallbackInfo(cv, cbType, sender, signal))
            count++
        }
    }
}

// ------------------------------------------------------------
// QMainWindow 专用
// ------------------------------------------------------------
func genMainwindow(uiWidget: XmlNode, topVar: String, lines: ArrayList<String>): Unit {
    var menubar: ?XmlNode = None
    var statusbar: ?XmlNode = None
    var central: ?XmlNode = None
    for (child in uiWidget.children) {
        if (child.tag != "widget") {
            continue
        }
        let cn = child.attr("name")
        let ct = child.attr("class")
        if (cn == "menubar" || ct == "QMenuBar") {
            menubar = child
        } else if (cn == "statusbar" || ct == "QStatusBar") {
            statusbar = child
        } else if (cn == "centralwidget") {
            central = child
        } else if (central.isNone()) {
            central = child
        }
    }

    if (let Some(centralWidget) <- central) {
        let cVar = safeName(centralWidget.attr("name"))
        addImport("QWidget", "cjqt6.core")
        genWidget(centralWidget, cVar, lines, 4)
        lines.add("    ${topVar}.setCentralWidget(${cVar}.getPtr())")
        lines.add("")
    }

    if (let Some(menubar) <- menubar) {
        let mb = safeName(menubar.attr("name"))
        addImport("QMenuBar", "cjqt6.menu")
        lines.add("    let ${mb} = QMenuBar()")
        lines.add("    ${topVar}.setMenuBar(${mb}.getPtr())")
    }

    if (let Some(statusbar) <- statusbar) {
        let sb = safeName(statusbar.attr("name"))
        addImport("QStatusBar", "cjqt6.menu")
        lines.add("    let ${sb} = QStatusBar()")
        lines.add("    ${topVar}.setStatusBar(${sb}.getPtr())")
    }
}

// ------------------------------------------------------------
// 主生成入口
// ------------------------------------------------------------
public class UiInfo {
    public var pkgName: String
    public var code: String

    public init(pkgName: String, code: String) {
        this.pkgName = pkgName
        this.code = code
    }
}

public func generate(uiPath: String, outputPath: String, pkgName: String): String {
    initGenState()
    initMaps()
    initLayoutMaps()
    initSignalMaps()

    let src = File.readFrom(uiPath)
    let text = String.fromUtf8(src)
    let root = parseXml(text)

    let uiWidget = root.findChild("widget")
    if (uiWidget.isNone()) {
        throw Exception("Invalid .ui file: no <widget> found")
    }

    let topType = uiWidget.getOrThrow().attr("class")
    let topName = uiWidget.getOrThrow().attr("name")
    if (!WIDGET_MAP.contains(topType)) {
        throw Exception("Unsupported top-level widget: ${topType}")
    }

    let topCls = WIDGET_MAP.get(topType).getOrThrow()
    addImport(topCls, WIDGET_MOD.get(topType).getOrThrow())
    let isMainwindow = (topType == "QMainWindow")

    let lines = ArrayList<String>()
    let topVar = safeName(topName)
    lines.add("    let app = QApplication()")
    lines.add("")

    if (isMainwindow) {
        lines.add("    let ${topVar} = QMainWindow()")
        processWidgetProps(uiWidget.getOrThrow(), topVar, lines)
        lines.add("")
        genMainwindow(uiWidget.getOrThrow(), topVar, lines)
    } else {
        genWidget(uiWidget.getOrThrow(), topVar, lines, 4)
    }

    handleConnections(root, lines)

    lines.add("")
    lines.add("    ${topVar}.show()")
    lines.add("    let result = app.exec()")
    lines.add("    return Int64(result)")
    lines.add("}")

    // 回调骨架（main 之前）
    let callbacksCode = ArrayList<String>()
    if (gCallbacks.size > 0) {
        callbacksCode.add("// ===== 事件回调骨架（请在函数体内编写业务逻辑） =====")
        for (cb in gCallbacks) {
            callbacksCode.add("let ${cb.varName}: ${cb.cbType} = { =>")
            callbacksCode.add("    // TODO: 处理 ${cb.sender} 的 ${cb.signal} 事件")
            callbacksCode.add("}")
        }
        callbacksCode.add("")
    }

    // 合并 import
    let importLines = ArrayList<String>()
    let mods = ArrayList<String>()
    for (key in gUsedImports.keys()) {
        mods.add(key)
    }
    sort(mods)
    for (mod in mods) {
        let clsList = gUsedImports.get(mod).getOrThrow()
        let classes = ArrayList<String>()
        for (c in clsList) {
            classes.add(c)
        }
        sort(classes)
        importLines.add("import ${mod}.*")
    }

    // 组装
    var header = ArrayList<String>()
    if (!pkgName.isEmpty()) {
        header.add("package ${pkgName}")
        header.add("")
    }
    header.add("// ===== Auto-generated by ui2cj — DO NOT EDIT BY HAND =====")
    header.add("// Source: ${basename(uiPath)}")
    header.add("// Build: cjpm build (requires CJQT6 + Qt6)")
    header.add("")
    for (il in importLines) {
        header.add(il)
    }
    header.add("")

    var body = ArrayList<String>()
    body.add("main(): Int64 {")
    for (l in lines) {
        body.add(l)
    }

    var code = ArrayList<String>()
    for (h in header) {
        code.add(h)
    }
    for (cb in callbacksCode) {
        code.add(cb)
    }
    for (b in body) {
        code.add(b)
    }

    let finalCode = String.join(code.toArray(), delimiter: "\n")
    File.writeTo(outputPath, finalCode.toArray())
    return finalCode
}

func basename(path: String): String {
    let idx = path.lastIndexOf("\\")
    if (let Some(i) <- idx) {
        return path[i + 1..]
    }
    let idx2 = path.lastIndexOf("/")
    if (let Some(i) <- idx2) {
        return path[i + 1..]
    }
    return path
}

