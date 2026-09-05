#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# ============================================================
# uic2cj — Qt Designer .ui → CJQT6 .cj 源码转换脚手架
#
# 用法：
#   python uic2cj.py form.ui                 # 生成 form_ui.cj
#   python uic2cj.py form.ui out.cj          # 指定输出文件
#   python uic2cj.py form.ui --package demo  # 首行生成 package 声明
#
# 特性：
#   - 支持带布局（QVBox/HBox/Grid/Form，可嵌套）与绝对定位两种 .ui 形态；
#   - 生成控件创建/属性设置/信号连接/回调骨架，import 自动按需合并；
#   - Windows 控制台编码自适应（GBK 下不再因 emoji 崩溃）。
# ============================================================

import sys
import os
import re
import xml.etree.ElementTree as ET

# Windows 控制台编码自适应（避免 GBK 下 print emoji 崩溃）
try:
    reconfigure = getattr(sys.stdout, "reconfigure", None)
    if reconfigure is not None:
        reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

# ============================================================
# 控件映射表：Qt 类名 → (CJQT6 构造类, 所属 import 模块)
# ============================================================
WIDGET_MAP = {
    "QWidget":          ("QWidget",         "cjqt6.core"),
    "QPushButton":      ("QPushButton",     "cjqt6.widgets"),
    "QToolButton":      ("QToolButton",     "cjqt6.widgets"),
    "QLabel":           ("QLabel",          "cjqt6.widgets"),
    "QLineEdit":        ("QLineEdit",       "cjqt6.widgets"),
    "QTextEdit":        ("QTextEdit",       "cjqt6.widgets"),
    "QPlainTextEdit":   ("QPlainTextEdit",  "cjqt6.widgets"),
    "QTextBrowser":     ("QTextBrowser",    "cjqt6.widgets"),
    "QCheckBox":        ("QCheckBox",       "cjqt6.widgets"),
    "QRadioButton":     ("QRadioButton",    "cjqt6.widgets"),
    "QComboBox":        ("QComboBox",       "cjqt6.widgets"),
    "QSpinBox":         ("QSpinBox",        "cjqt6.widgets"),
    "QDoubleSpinBox":   ("QDoubleSpinBox",  "cjqt6.widgets"),
    "QSlider":          ("QSlider",         "cjqt6.widgets"),
    "QProgressBar":     ("QProgressBar",    "cjqt6.widgets"),
    "QGroupBox":        ("QGroupBox",       "cjqt6.widgets"),
    "QTabWidget":       ("QTabWidget",      "cjqt6.widgets"),
    "QScrollArea":      ("QScrollArea",     "cjqt6.widgets"),
    "QFrame":           ("QFrame",          "cjqt6.widgets"),
    "QSplitter":        ("QSplitter",       "cjqt6.widgets"),
    "QCalendarWidget":  ("QCalendarWidget", "cjqt6.widgets"),
    "QDateEdit":        ("QDateEdit",       "cjqt6.widgets"),
    "QTimeEdit":        ("QTimeEdit",       "cjqt6.widgets"),
    "QDateTimeEdit":    ("QDateTimeEdit",   "cjqt6.widgets"),
    "QListWidget":      ("QListWidget",     "cjqt6.views"),
    "QTableWidget":     ("QTableWidget",    "cjqt6.views"),
    "QTreeWidget":      ("QTreeWidget",     "cjqt6.views"),
    "QMainWindow":      ("QMainWindow",     "cjqt6.menu"),
    "QMenuBar":         ("QMenuBar",        "cjqt6.menu"),
    "QMenu":            ("QMenu",           "cjqt6.menu"),
    "QAction":          ("QAction",         "cjqt6.menu"),
    "QToolBar":         ("QToolBar",        "cjqt6.menu"),
    "QStatusBar":       ("QStatusBar",      "cjqt6.menu"),
    "QStackedWidget":   ("QStackedWidget",  "cjqt6.widgets"),
    "QDockWidget":      ("QDockWidget",     "cjqt6.widgets"),
}

# 布局映射：Qt 布局类 → (CJQT6 布局类, import 模块)
LAYOUT_TAGS = {
    "hboxlayout":  ("QHBoxLayout",  "cjqt6.gui"),
    "vboxlayout":  ("QVBoxLayout",  "cjqt6.gui"),
    "gridlayout":  ("QGridLayout",  "cjqt6.gui"),
    "formlayout":  ("QFormLayout",  "cjqt6.gui"),
}

# ============================================================
# 全局状态
# ============================================================
_used_imports = set()
_generated_callbacks = []
_used_names = set()
_name_map = {}


def safe_name(name):
    """生成合法的 Cangjie 变量名，相同原始名返回相同变量名"""
    global _used_names, _name_map
    if name in _name_map:
        return _name_map[name]
    safe = re.sub(r"[^a-zA-Z0-9_]", "_", name)
    if not safe or safe[0].isdigit():
        safe = "_" + safe
    base = safe
    n = 2
    while safe in _used_names:
        safe = f"{base}_{n}"
        n += 1
    _used_names.add(safe)
    _name_map[name] = safe
    return safe


def cstr(s):
    """Cangjie 字符串字面量转义"""
    return (s.replace("\\", "\\\\").replace('"', '\\"')
             .replace("\n", "\\n").replace("\r", "\\r"))


def rect_val(prop_elem):
    """解析 <rect><x>..<y>..<width>..<height>..</rect>"""
    rect = prop_elem.find("rect")
    if rect is None:
        return {"x": 0, "y": 0, "w": 0, "h": 0}
    return {
        "x": int(float(rect.findtext("x", "0"))),
        "y": int(float(rect.findtext("y", "0"))),
        "w": int(float(rect.findtext("width", "0"))),
        "h": int(float(rect.findtext("height", "0"))),
    }


def parse_size(elem):
    """解析 <size><width>..</width><height>..</height></size>"""
    return {
        "w": int(float(elem.findtext("width", "0"))),
        "h": int(float(elem.findtext("height", "0"))),
    }


def _get_string(prop_elem):
    for child in prop_elem:
        if child.tag == "string":
            return child.text or ""
    return ""


def _get_bool(prop_elem):
    b = prop_elem.findtext("bool")
    return b is not None and b.lower() == "true"


def _get_enum(prop_elem):
    """读取 <enum> 或 <set> 子标签值，去掉 'Qt::' 等作用域前缀"""
    e = prop_elem.findtext("enum")
    if e is None:
        e = prop_elem.findtext("set")
    if e is None:
        return ""
    idx = e.rfind("::")
    if idx >= 0:
        e = e[idx + 2:]
    return e


def _get_number(prop_elem):
    return int(float(prop_elem.findtext("number", "0")))


# ============================================================
# 属性映射：按 widget 类型 + 属性名 → 代码生成
# ============================================================
ALIGN_MAP = {
    "AlignLeft": "0x0001", "AlignRight": "0x0002",
    "AlignHCenter": "0x0004", "AlignTop": "0x0020",
    "AlignBottom": "0x0040", "AlignVCenter": "0x0080",
    "AlignCenter": "0x0084",
}


def _align(v):
    return ALIGN_MAP.get(v, "0x0001")


def handle_property(widget_type, prop_name, prop_elem, var_name):
    """处理单个属性，返回生成的 setter 代码行列表"""
    lines = []
    wtype = widget_type

    # === 通用属性 ===
    if prop_name == "geometry":
        pass  # 由上层决定绝对定位（setWidgetGeometry）或布局接管
    elif prop_name == "windowTitle":
        lines.append(f'    {var_name}.setTitle("{cstr(_get_string(prop_elem))}")')
    elif prop_name == "enabled":
        if not _get_bool(prop_elem):
            lines.append(f"    {var_name}.setEnabled(false)")
    elif prop_name == "toolTip":
        lines.append(f'    {var_name}.setToolTip("{cstr(_get_string(prop_elem))}")')
    elif prop_name == "statusTip":
        lines.append(f'    {var_name}.setToolTip("{cstr(_get_string(prop_elem))}")')
    elif prop_name == "styleSheet":
        lines.append(f'    {var_name}.setStyleSheet("{cstr(_get_string(prop_elem))}")')
    elif prop_name == "minimumSize":
        sz = parse_size(prop_elem)
        if (sz["w"], sz["h"]) != (0, 0):
            lines.append(f"    {var_name}.setMinimumSize({sz['w']}, {sz['h']})")
    elif prop_name == "maximumSize":
        sz = parse_size(prop_elem)
        lines.append(f"    {var_name}.setMaximumSize({sz['w']}, {sz['h']})")
    elif prop_name == "font":
        pass  # CJQT6 暂无通用 setFont

    # === 按钮 ===
    elif wtype in ("QPushButton", "QToolButton", "QCommandLinkButton"):
        if prop_name == "text":
            lines.append(f'    {var_name}.setText("{cstr(_get_string(prop_elem))}")')
        elif prop_name == "checkable" and _get_bool(prop_elem):
            lines.append(f"    {var_name}.setCheckable(true)")
        elif prop_name == "checked" and _get_bool(prop_elem):
            lines.append(f"    {var_name}.setChecked(true)")
        elif prop_name == "default" and _get_bool(prop_elem):
            lines.append(f"    {var_name}.setDefault(true)")

    # === 标签 ===
    elif wtype == "QLabel":
        if prop_name == "text":
            lines.append(f'    {var_name}.setText("{cstr(_get_string(prop_elem))}")')
        elif prop_name == "alignment":
            lines.append(f"    {var_name}.setAlignment({_align(_get_enum(prop_elem))})")
        elif prop_name == "wordWrap" and _get_bool(prop_elem):
            lines.append(f"    {var_name}.setWordWrap(true)")

    # === 单行输入 ===
    elif wtype == "QLineEdit":
        if prop_name == "text":
            lines.append(f'    {var_name}.setText("{cstr(_get_string(prop_elem))}")')
        elif prop_name == "placeholderText":
            lines.append(f'    {var_name}.setPlaceholder("{cstr(_get_string(prop_elem))}")')
        elif prop_name == "readOnly" and _get_bool(prop_elem):
            lines.append(f"    {var_name}.setReadOnly(true)")
        elif prop_name == "echoMode" and _get_enum(prop_elem) == "Password":
            lines.append(f"    {var_name}.setEchoMode(2)")
        elif prop_name == "maxLength":
            lines.append(f"    {var_name}.setMaxLength({_get_number(prop_elem)})")
        elif prop_name == "alignment":
            lines.append(f"    {var_name}.setAlignment({_align(_get_enum(prop_elem))})")

    # === 多行输入 ===
    elif wtype in ("QTextEdit", "QPlainTextEdit", "QTextBrowser"):
        if prop_name in ("html", "plainText"):
            lines.append(f'    {var_name}.setText("{cstr(_get_string(prop_elem))}")')
        elif prop_name == "readOnly" and _get_bool(prop_elem):
            lines.append(f"    {var_name}.setReadOnly(true)")
        elif prop_name == "lineWrapMode":
            pass  # 默认合适，跳过

    # === 选择框 ===
    elif wtype in ("QCheckBox", "QRadioButton"):
        if prop_name == "text":
            lines.append(f'    {var_name}.setText("{cstr(_get_string(prop_elem))}")')
        elif prop_name == "checked" and _get_bool(prop_elem):
            lines.append(f"    {var_name}.setChecked(true)")

    # === 滑块（setRange 合并 min/max）===
    elif wtype == "QSlider":
        if prop_name == "orientation":
            v = _get_enum(prop_elem)
            horiz = "Horizontal" if v == "Horizontal" else "Vertical"
            lines.append(f"    {var_name}.setOrientation(Orientation.{horiz}.value())")
        elif prop_name == "minimum":
            pass  # 与 maximum 合并为 setRange
        elif prop_name == "maximum":
            lines.append(f"    {var_name}.setRange(0, {_get_number(prop_elem)})")
        elif prop_name == "value":
            lines.append(f"    {var_name}.setValue({_get_number(prop_elem)})")
        elif prop_name == "tickPosition":
            pass
        elif prop_name == "singleStep":
            lines.append(f"    {var_name}.setSingleStep({_get_number(prop_elem)})")

    # === 进度条 ===
    elif wtype == "QProgressBar":
        if prop_name == "minimum":
            lines.append(f"    {var_name}.setRange({_get_number(prop_elem)}, 100)")
        elif prop_name == "maximum":
            lines.append(f"    {var_name}.setRange(0, {_get_number(prop_elem)})")
        elif prop_name == "value":
            lines.append(f"    {var_name}.setValue({_get_number(prop_elem)})")

    # === 数值框 ===
    elif wtype in ("QSpinBox", "QDoubleSpinBox"):
        if prop_name == "minimum":
            lines.append(f"    {var_name}.setMinimum({_get_number(prop_elem)})")
        elif prop_name == "maximum":
            lines.append(f"    {var_name}.setMaximum({_get_number(prop_elem)})")
        elif prop_name == "value":
            lines.append(f"    {var_name}.setValue({_get_number(prop_elem)})")
        elif prop_name == "prefix":
            lines.append(f'    {var_name}.setPrefix("{cstr(_get_string(prop_elem))}")')
        elif prop_name == "suffix":
            lines.append(f'    {var_name}.setSuffix("{cstr(_get_string(prop_elem))}")')

    # === 组合框 ===
    elif wtype == "QComboBox":
        if prop_name == "currentIndex":
            idx = _get_number(prop_elem)
            if idx != 0:
                lines.append(f"    {var_name}.setCurrentIndex({idx})")
        elif prop_name == "editable" and _get_bool(prop_elem):
            lines.append(f"    {var_name}.setEditable(true)")

    # === 分组框 ===
    elif wtype == "QGroupBox":
        if prop_name == "title":
            lines.append(f'    {var_name}.setTitle("{cstr(_get_string(prop_elem))}")')
        elif prop_name == "checkable" and _get_bool(prop_elem):
            lines.append(f"    {var_name}.setCheckable(true)")

    # === 页签 ===
    elif wtype == "QTabWidget":
        if prop_name == "currentIndex":
            lines.append(f"    {var_name}.setCurrentIndex({_get_number(prop_elem)})")

    return lines


def process_widget_props(widget_elem, var_name, code_lines, indent=4):
    w_type = widget_elem.get("class", "QWidget")
    for prop in widget_elem.findall("property"):
        for line in handle_property(w_type, prop.get("name"), prop, var_name):
            code_lines.append(line)


# ============================================================
# 控件树生成
# ============================================================
def gen_widget(widget_elem, var_name, code_lines, indent=4):
    """生成单个控件的创建 + 属性 + 子元素（布局或绝对定位）"""
    prefix = " " * indent
    code_lines.append(f"{prefix}let {var_name} = {widget_elem.get('class')}()")
    process_widget_props(widget_elem, var_name, code_lines, indent)

    # 子元素：优先布局，否则绝对定位
    layout = widget_elem.find("layout")
    if layout is not None:
        gen_layout(layout, var_name, code_lines, indent)
        return

    # 绝对定位：几何 + 父子关系
    abs_count = 0
    for child in widget_elem:
        if child.tag != "widget":
            continue
        c_type = child.get("class", "QWidget")
        if c_type not in WIDGET_MAP:
            continue
        c_name = child.get("name", "")
        c_var = safe_name(c_name)
        w_cls, w_mod = WIDGET_MAP[c_type]
        _used_imports.add((w_cls, w_mod))
        code_lines.append(f"{prefix}let {c_var} = {w_cls}()")

        # 绝对定位几何
        for prop in child.findall("property"):
            if prop.get("name") == "geometry":
                r = rect_val(prop)
                code_lines.append(
                    f"{prefix}setWidgetGeometry({c_var}.getPtr(), {r['x']}, {r['y']}, {r['w']}, {r['h']})"
                )
        process_widget_props(child, c_var, code_lines, indent)
        code_lines.append(f"{prefix}setWidgetParent({c_var}.getPtr(), {var_name}.getPtr())")

        # 递归子元素（嵌套控件）
        sub = child.find("layout")
        if sub is not None:
            gen_layout(sub, c_var, code_lines, indent)
        for subchild in child:
            if subchild.tag == "widget":
                sub_c = safe_name(subchild.get("name", ""))
                gen_widget(subchild, sub_c, code_lines, indent)
                code_lines.append(f"{prefix}setWidgetParent({sub_c}.getPtr(), {c_var}.getPtr())")
        abs_count += 1
    return abs_count


def create_layout(layout_elem, lname, code_lines, indent=4):
    """创建布局对象并填充 items（不挂载到父）。返回 True 表示成功。"""
    prefix = " " * indent
    layout_class = layout_elem.get("class", "")
    tag = layout_class[1:].lower() if layout_class.startswith("Q") else layout_class.lower()
    if tag not in LAYOUT_TAGS:
        return False
    cls, mod = LAYOUT_TAGS[tag]
    _used_imports.add((cls, mod))
    code_lines.append(f"{prefix}let {lname} = {cls}()")

    for prop in layout_elem.findall("property"):
        pn = prop.get("name")
        if pn == "spacing":
            code_lines.append(f"{prefix}{lname}.setSpacing({_get_number(prop)})")
        elif pn == "margin":
            code_lines.append(f"{prefix}{lname}.setMargin({_get_number(prop)})")
        elif pn == "leftMargin":
            pass
        elif pn == "topMargin":
            pass

    is_grid = (tag == "gridlayout")
    if tag == "formlayout":
        _fill_form_layout(layout_elem, lname, code_lines, indent)
        return True

    row = 0
    for item in layout_elem:
        if item.tag != "item":
            continue
        r = int(item.findtext("row", str(row)))
        c = int(item.findtext("column", "0"))
        rs = item.findtext("rowspan")
        cs = item.findtext("colspan")

        w = item.find("widget")
        if w is not None:
            w_type = w.get("class", "QWidget")
            w_name = w.get("name", "")
            if w_type in WIDGET_MAP:
                w_cls, w_mod = WIDGET_MAP[w_type]
                _used_imports.add((w_cls, w_mod))
                var = safe_name(w_name)
                gen_widget(w, var, code_lines, indent)
                if is_grid:
                    if rs is not None or cs is not None:
                        rs_v = int(rs) if rs else 1
                        cs_v = int(cs) if cs else 1
                        code_lines.append(f"{prefix}{lname}.addWidget({var}.getPtr(), {r}, {c}, {rs_v}, {cs_v})")
                    else:
                        code_lines.append(f"{prefix}{lname}.addWidget({var}.getPtr(), {r}, {c})")
                else:
                    code_lines.append(f"{prefix}{lname}.addWidget({var}.getPtr())")

        if item.find("spacer") is not None:
            code_lines.append(f"{prefix}{lname}.addStretch()")

        # 嵌套布局
        sub_layout = item.find("layout")
        if sub_layout is not None:
            sub_lname = safe_name(f"{lname}_sub")
            if create_layout(sub_layout, sub_lname, code_lines, indent):
                code_lines.append(f"{prefix}{lname}.addLayout({sub_lname}.getPtr())")

        if not is_grid:
            row += 1
    return True


def _fill_form_layout(layout_elem, lname, code_lines, indent=4):
    """填充 QFormLayout：按行分组，label+field 成对用 addRowWidget，否则 addRow("", ptr)"""
    prefix = " " * indent
    # 收集每行 widget
    rows = {}
    for item in layout_elem:
        if item.tag != "item":
            continue
        r = int(item.findtext("row", "0"))
        w = item.find("widget")
        if w is None:
            continue
        w_type = w.get("class", "QWidget")
        if w_type not in WIDGET_MAP:
            continue
        w_cls, w_mod = WIDGET_MAP[w_type]
        _used_imports.add((w_cls, w_mod))
        var = safe_name(w.get("name", ""))
        gen_widget(w, var, code_lines, indent)
        rows.setdefault(r, []).append(var)
    # 生成 addRow / addRowWidget
    for r in sorted(rows.keys()):
        ws = rows[r]
        if len(ws) >= 2:
            code_lines.append(f"{prefix}{lname}.addRowWidget({ws[0]}.getPtr(), {ws[1]}.getPtr())")
        elif len(ws) == 1:
            code_lines.append(f'{prefix}{lname}.addRow("", {ws[0]}.getPtr())')


def gen_layout(layout_elem, parent_var, code_lines, indent=4):
    """为控件生成布局并挂载：create_layout + parent_var.setLayout"""
    prefix = " " * indent
    lname = safe_name(f"{parent_var}_layout")
    if create_layout(layout_elem, lname, code_lines, indent):
        code_lines.append(f"{prefix}{parent_var}.setLayout({lname}.getPtr())")


# ============================================================
# 信号连接
# ============================================================
SIGNAL_MAP = {
    "clicked()":                 ("setOnClick",                 "VoidCallback"),
    "clicked(bool)":             ("setOnClickedChecked",        "Int32Callback"),
    "toggled(bool)":             ("setOnToggled",               "Int32Callback"),
    "textChanged(QString)":      ("setOnTextChanged",           "CStringCallback"),
    "returnPressed()":           ("setOnReturnPressed",         "VoidCallback"),
    "editingFinished()":         ("setOnEditingFinished",       "VoidCallback"),
    "valueChanged(int)":         ("setOnValueChanged",          "Int32Callback"),
    "valueChanged(double)":      ("setOnValueChanged",          "Float64Callback"),
    "currentIndexChanged(int)":  ("setOnCurrentIndexChanged",   "Int32Callback"),
    "currentTextChanged(QString)": ("setOnCurrentTextChanged",  "CStringCallback"),
    "stateChanged(int)":         ("setOnStateChanged",          "Int32Callback"),
    "sliderMoved(int)":          ("setOnSliderMoved",           "Int32Callback"),
    "activated(int)":            ("setOnActivated",             "Int32Callback"),
}


def _sig_name(s):
    return s.split("(")[0]


def handle_connections(root_elem, code_lines):
    conns = root_elem.find("connections")
    if conns is None:
        return
    code_lines.append("")
    code_lines.append("    // ===== 信号连接 =====")
    for conn in conns.findall("connection"):
        sender = conn.findtext("sender", "")
        signal = conn.findtext("signal", "")
        if not sender or not signal or signal not in SIGNAL_MAP:
            continue
        method, cb_type = SIGNAL_MAP[signal]
        sv = safe_name(sender)
        cv = safe_name(f"on_{sv}_{_sig_name(signal)}")
        code_lines.append(f"    {sv}.{method}({cv})")
        _generated_callbacks.append((cv, cb_type, sender, signal))


# ============================================================
# QMainWindow 专用：centralwidget / menubar / statusbar / toolbar
# ============================================================
def gen_mainwindow(ui_widget, top_var, lines):
    menubar = statusbar = central = None
    for child in ui_widget:
        if child.tag != "widget":
            continue
        cn = child.get("name", "")
        ct = child.get("class", "")
        if cn == "menubar" or ct == "QMenuBar":
            menubar = child
        elif cn == "statusbar" or ct == "QStatusBar":
            statusbar = child
        elif cn == "centralwidget":
            central = child
        elif central is None:
            central = child

    if central is not None:
        c_var = safe_name(central.get("name", "centralwidget"))
        _used_imports.add(("QWidget", "cjqt6.core"))
        gen_widget(central, c_var, lines)
        lines.append(f"    {top_var}.setCentralWidget({c_var}.getPtr())")
        lines.append("")

    if menubar is not None:
        mb = safe_name(menubar.get("name", "menubar"))
        _used_imports.add(("QMenuBar", "cjqt6.menu"))
        lines.append(f"    let {mb} = QMenuBar()")
        lines.append(f"    {top_var}.setMenuBar({mb}.getPtr())")

    if statusbar is not None:
        sb = safe_name(statusbar.get("name", "statusbar"))
        _used_imports.add(("QStatusBar", "cjqt6.menu"))
        lines.append(f"    let {sb} = QStatusBar()")
        lines.append(f"    {top_var}.setStatusBar({sb}.getPtr())")


# ============================================================
# 主生成
# ============================================================
def generate(ui_path, output_path=None, package=None):
    global _used_imports, _generated_callbacks, _used_names, _name_map
    _used_imports = {("QApplication", "cjqt6.core")}
    _generated_callbacks = []
    _used_names = set()
    _name_map = {}

    tree = ET.parse(ui_path)
    root = tree.getroot()

    ui_widget = root.find("widget")
    if ui_widget is None:
        raise ValueError("Invalid .ui file: no <widget> found")

    top_type = ui_widget.get("class", "QWidget")
    top_name = ui_widget.get("name", "Form")
    if top_type not in WIDGET_MAP:
        raise ValueError(f"Unsupported top-level widget: {top_type}")

    top_cls, top_mod = WIDGET_MAP[top_type]
    _used_imports.add((top_cls, top_mod))
    is_mainwindow = (top_type == "QMainWindow")

    lines = []
    top_var = safe_name(top_name)
    lines.append(f"    let app = QApplication()")
    lines.append("")

    if is_mainwindow:
        lines.append(f"    let {top_var} = QMainWindow()")
        process_widget_props(ui_widget, top_var, lines)
        lines.append("")
        gen_mainwindow(ui_widget, top_var, lines)
    else:
        gen_widget(ui_widget, top_var, lines)

    handle_connections(root, lines)

    lines.append("")
    lines.append(f"    {top_var}.show()")
    lines.append("    let result = app.exec()")
    lines.append("    return Int64(result)")
    lines.append("}")

    # 回调骨架（main 之前）
    callbacks_code = []
    if _generated_callbacks:
        callbacks_code.append("// ===== 事件回调骨架（请在函数体内编写业务逻辑） =====")
        for cb_var, cb_type, sender, signal in _generated_callbacks:
            callbacks_code.append(f"let {cb_var}: {cb_type} = {{ =>")
            callbacks_code.append(f"    // TODO: 处理 {sender} 的 {signal} 事件")
            callbacks_code.append("}")
        callbacks_code.append("")

    # 合并 import
    imports = {}
    for cls, mod in _used_imports:
        imports.setdefault(mod, []).append(cls)

    header = ["// ===== Auto-generated by uic2cj — DO NOT EDIT BY HAND =====",
              f"// Source: {os.path.basename(ui_path)}",
              "// Build: cjpm build (requires CJQT6 + Qt6)",
              ""]
    if package:
        header = [f"package {package}"] + header
    for mod in sorted(imports.keys()):
        header.append(f"import {mod}.*")
    header.append("")

    body = []
    body.append("main(): Int64 {")
    body.extend(lines)

    code = "\n".join(header + callbacks_code + body)

    if output_path is None:
        base = os.path.splitext(ui_path)[0]
        output_path = f"{base}_ui.cj"

    with open(output_path, "w", encoding="utf-8") as f:
        f.write(code)

    return output_path, code


def _find_cjpm_root(start_dir):
    """从 start_dir 向上查找最近的 cjpm.toml，返回其所在目录（无则返回 None）。"""
    d = os.path.abspath(start_dir)
    while True:
        if os.path.exists(os.path.join(d, "cjpm.toml")):
            return d
        parent = os.path.dirname(d)
        if parent == d:
            return None
        d = parent


def _read_package_name(cjpm_dir):
    """从 cjpm.toml 的 [package] 段读取 name，返回包名（无则返回 None）。"""
    try:
        with open(os.path.join(cjpm_dir, "cjpm.toml"), "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if line.startswith("name") and "=" in line:
                    return line.split("=", 1)[1].strip().strip('"').strip("'")
    except OSError:
        pass
    return None


def _default_output(ui_path, cjpm_dir):
    """默认输出：工程根有 src/ 目录则输出 src/main.cj（标准 cjpm 入口），否则 <base>_ui.cj。"""
    if cjpm_dir and os.path.isdir(os.path.join(cjpm_dir, "src")):
        return os.path.join(cjpm_dir, "src", "main.cj")
    base = os.path.splitext(ui_path)[0]
    return f"{base}_ui.cj"


def main():
    if len(sys.argv) < 2:
        print("用法: python uic2cj.py <form.ui> [output.cj] [--package <name>]")
        print("      [--project-dir <dir>] [--build] [--no-build]")
        print("将 Qt Designer 的 .ui 文件转换为 CJQT6 仓颉源码")
        print("默认行为：向上查找 cjpm.toml 自动填 package；有 src/ 目录则输出 src/main.cj")
        sys.exit(1)

    ui_path = sys.argv[1]
    if not os.path.exists(ui_path):
        print(f"错误：文件不存在 - {ui_path}")
        sys.exit(1)

    output_path = None
    package = None
    project_dir = None
    do_build = False
    args = sys.argv[2:]

    # 解析 --xxx 选项
    opts = {"--package", "--project-dir", "--output"}
    positional = []
    i = 0
    while i < len(args):
        a = args[i]
        if a == "--package" and i + 1 < len(args):
            package = args[i + 1]
            i += 2
        elif a == "--project-dir" and i + 1 < len(args):
            project_dir = args[i + 1]
            i += 2
        elif a == "--output" and i + 1 < len(args):
            output_path = args[i + 1]
            i += 2
        elif a == "--build":
            do_build = True
            i += 1
        elif a == "--no-build":
            do_build = False
            i += 1
        else:
            positional.append(a)
            i += 1
    if positional:
        output_path = output_path or positional[0]

    # 自动探测 cjpm 工程：包名 + 默认输出
    base_dir = project_dir or os.path.dirname(os.path.abspath(ui_path))
    cjpm_dir = _find_cjpm_root(base_dir)
    if package is None and cjpm_dir:
        package = _read_package_name(cjpm_dir)
        if package:
            print(f"[探测] 从 cjpm.toml 读取包名: {package}")
    if output_path is None and cjpm_dir:
        output_path = _default_output(ui_path, cjpm_dir)

    try:
        out, code = generate(ui_path, output_path, package)
        print(f"[OK] 转换成功：{out}")
        print(f"     共 {len(code.splitlines())} 行仓颉代码")
        if out.endswith("main.cj"):
            print("提示: 输出到 src/main.cj，可执行 cjpm build 验证")
    except Exception as e:
        print(f"[FAIL] 转换失败：{e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

    if do_build:
        build_dir = project_dir or cjpm_dir
        if not build_dir:
            build_dir = _find_cjpm_root(os.path.dirname(os.path.abspath(out)))
        if not build_dir:
            print("[WARN] 未找到 cjpm.toml，跳过 cjpm build")
            return
        print(f"[BUILD] cd {build_dir} && cjpm build")
        old = os.getcwd()
        try:
            os.chdir(build_dir)
            ret = os.system("cjpm build")
            if ret != 0:
                sys.exit(ret)
        finally:
            os.chdir(old)


if __name__ == "__main__":
    main()
