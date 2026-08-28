/**
 * @file bridge_selectors.cpp
 * @brief 选择部件桥接函数 - QCheckBox, QRadioButton, QComboBox
 */

#include <QCheckBox>
#include <QRadioButton>
#include <QComboBox>
#include <QButtonGroup>
#include <QSize>
#include <functional>
#include <unordered_map>
#include "bridge_string_utils.h"

// 回调映射
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_checkBoxCallbacks;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_radioButtonCallbacks;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_comboBoxCallbacks;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_buttonGroupCallbacks;

// 由 bridge_ext_wmisc.cpp 导出：清理 QButtonGroup 信号回调 map，避免 delete 后
// 地址复用导致 connect 去重误跳。
extern "C" void qWmiscSignalCleanup(int64_t ptr);

// 由 bridge_ext_wselect.cpp 导出：清理选择控件信号回调 map（QComboBox/
// QFontComboBox/QKeySequenceEdit），避免地址复用导致 connect 去重误跳。
extern "C" void qWselectSignalCleanup(int64_t ptr);

// 由 bridge_ext_wcore.cpp 导出：清理按钮类点击回调 map（QCheckBox/QRadioButton），
// 避免地址复用导致 connect 去重误跳。
extern "C" void qWcoreSignalCleanup(int64_t ptr);

extern "C" {

// ============================================================
// QCheckBox 桥接函数
// ============================================================

int64_t qCheckBoxCreate() {
    QCheckBox* checkBox = new QCheckBox();
    return reinterpret_cast<int64_t>(checkBox);
}

void qCheckBoxSetText(int64_t ptr, const char* text) {
    QCheckBox* checkBox = reinterpret_cast<QCheckBox*>(ptr);
    if (checkBox) {
        checkBox->setText(QString::fromUtf8(text));
    }
}

const char* qCheckBoxText(int64_t ptr) {
    QCheckBox* checkBox = reinterpret_cast<QCheckBox*>(ptr);
    if (!checkBox) return cjqt6::emptyString();
    QByteArray arr = checkBox->text().toUtf8();
    char* result = (char*)malloc(arr.size() + 1);
    if (result) memcpy(result, arr.constData(), arr.size() + 1);
    return result;
}

void qCheckBoxSetChecked(int64_t ptr, bool checked) {
    QCheckBox* checkBox = reinterpret_cast<QCheckBox*>(ptr);
    if (checkBox) {
        checkBox->setChecked(checked);
    }
}

bool qCheckBoxIsChecked(int64_t ptr) {
    QCheckBox* checkBox = reinterpret_cast<QCheckBox*>(ptr);
    if (checkBox) {
        return checkBox->isChecked();
    }
    return false;
}

void qCheckBoxDelete(int64_t ptr) {
    QCheckBox* checkBox = reinterpret_cast<QCheckBox*>(ptr);
    if (checkBox) {
        qWcoreSignalCleanup(ptr);
        delete checkBox;
    }
}

// ============================================================
// QRadioButton 桥接函数
// ============================================================

int64_t qRadioButtonCreate() {
    QRadioButton* radioButton = new QRadioButton();
    return reinterpret_cast<int64_t>(radioButton);
}

void qRadioButtonSetText(int64_t ptr, const char* text) {
    QRadioButton* radioButton = reinterpret_cast<QRadioButton*>(ptr);
    if (radioButton) {
        radioButton->setText(QString::fromUtf8(text));
    }
}

const char* qRadioButtonText(int64_t ptr) {
    QRadioButton* radioButton = reinterpret_cast<QRadioButton*>(ptr);
    if (!radioButton) return cjqt6::emptyString();
    QByteArray arr = radioButton->text().toUtf8();
    char* result = (char*)malloc(arr.size() + 1);
    if (result) memcpy(result, arr.constData(), arr.size() + 1);
    return result;
}

void qRadioButtonSetChecked(int64_t ptr, bool checked) {
    QRadioButton* radioButton = reinterpret_cast<QRadioButton*>(ptr);
    if (radioButton) {
        radioButton->setChecked(checked);
    }
}

bool qRadioButtonIsChecked(int64_t ptr) {
    QRadioButton* radioButton = reinterpret_cast<QRadioButton*>(ptr);
    if (radioButton) {
        return radioButton->isChecked();
    }
    return false;
}

void qRadioButtonDelete(int64_t ptr) {
    QRadioButton* radioButton = reinterpret_cast<QRadioButton*>(ptr);
    if (radioButton) {
        qWcoreSignalCleanup(ptr);
        delete radioButton;
    }
}

// ============================================================
// QComboBox 桥接函数
// ============================================================

int64_t qComboBoxCreate() {
    QComboBox* comboBox = new QComboBox();
    return reinterpret_cast<int64_t>(comboBox);
}

void qComboBoxAddItem(int64_t ptr, const char* text) {
    QComboBox* comboBox = reinterpret_cast<QComboBox*>(ptr);
    if (comboBox) {
        comboBox->addItem(QString::fromUtf8(text));
    }
}

const char* qComboBoxCurrentText(int64_t ptr) {
    QComboBox* comboBox = reinterpret_cast<QComboBox*>(ptr);
    if (comboBox) {
        return cjqt6::dupUtf8(comboBox->currentText());
    }
    return cjqt6::emptyString();
}

void qComboBoxSetCurrentIndex(int64_t ptr, int32_t index) {
    QComboBox* comboBox = reinterpret_cast<QComboBox*>(ptr);
    if (comboBox) {
        comboBox->setCurrentIndex(index);
    }
}

int32_t qComboBoxCurrentIndex(int64_t ptr) {
    QComboBox* comboBox = reinterpret_cast<QComboBox*>(ptr);
    if (comboBox) {
        return comboBox->currentIndex();
    }
    return -1;
}

void qComboBoxClear(int64_t ptr) {
    QComboBox* comboBox = reinterpret_cast<QComboBox*>(ptr);
    if (comboBox) {
        comboBox->clear();
    }
}

int32_t qComboBoxCount(int64_t ptr) {
    QComboBox* cb = reinterpret_cast<QComboBox*>(ptr);
    return cb ? cb->count() : 0;
}
const char* qComboBoxItemText(int64_t ptr, int32_t index) {
    QComboBox* cb = reinterpret_cast<QComboBox*>(ptr);
    if (!cb || index < 0 || index >= cb->count()) return nullptr;
    QByteArray arr = cb->itemText(index).toUtf8();
    char* result = (char*)malloc(arr.size() + 1);
    if (result) memcpy(result, arr.constData(), arr.size() + 1);
    return result;
}
void qComboBoxSetEditable(int64_t ptr, bool editable) {
    QComboBox* cb = reinterpret_cast<QComboBox*>(ptr);
    if (cb) cb->setEditable(editable);
}
void qComboBoxRemoveItem(int64_t ptr, int32_t index) {
    QComboBox* cb = reinterpret_cast<QComboBox*>(ptr);
    if (cb && index >= 0 && index < cb->count()) cb->removeItem(index);
}

void qComboBoxAddItems(int64_t ptr, const char* items) {
    QComboBox* cb = reinterpret_cast<QComboBox*>(ptr);
    if (cb && items) {
        QStringList list = QString::fromUtf8(items).split('\n', Qt::SkipEmptyParts);
        cb->addItems(list);
    }
}

void qComboBoxInsertItem(int64_t ptr, int32_t index, const char* text) {
    QComboBox* cb = reinterpret_cast<QComboBox*>(ptr);
    if (cb && text) {
        cb->insertItem(index, QString::fromUtf8(text));
    }
}

void qComboBoxSetItemText(int64_t ptr, int32_t index, const char* text) {
    QComboBox* cb = reinterpret_cast<QComboBox*>(ptr);
    if (cb && text) {
        cb->setItemText(index, QString::fromUtf8(text));
    }
}

void qComboBoxSetCurrentText(int64_t ptr, const char* text) {
    QComboBox* cb = reinterpret_cast<QComboBox*>(ptr);
    if (cb && text) {
        cb->setCurrentText(QString::fromUtf8(text));
    }
}

int32_t qComboBoxFindText(int64_t ptr, const char* text) {
    QComboBox* cb = reinterpret_cast<QComboBox*>(ptr);
    if (cb && text) {
        return cb->findText(QString::fromUtf8(text));
    }
    return -1;
}

void qComboBoxSetPlaceholderText(int64_t ptr, const char* text) {
    QComboBox* cb = reinterpret_cast<QComboBox*>(ptr);
    if (cb && text) {
        cb->setPlaceholderText(QString::fromUtf8(text));
    }
}

// 设置下拉框图标尺寸
void qComboBoxSetIconSize(int64_t ptr, int32_t width, int32_t height) {
    QComboBox* cb = reinterpret_cast<QComboBox*>(ptr);
    if (cb) {
        cb->setIconSize(QSize(width, height));
    }
}

void qComboBoxDelete(int64_t ptr) {
    QComboBox* comboBox = reinterpret_cast<QComboBox*>(ptr);
    if (comboBox) {
        qWselectSignalCleanup(ptr);
        delete comboBox;
    }
}

// ============================================================
// QButtonGroup 桥接函数
// ============================================================

int64_t qButtonGroupCreate() {
    QButtonGroup* group = new QButtonGroup();
    return reinterpret_cast<int64_t>(group);
}

void qButtonGroupAddButton(int64_t ptr, int64_t btnPtr, int32_t id) {
    QButtonGroup* group = reinterpret_cast<QButtonGroup*>(ptr);
    QAbstractButton* btn = reinterpret_cast<QAbstractButton*>(btnPtr);
    if (group && btn) {
        group->addButton(btn, id);
    }
}

void qButtonGroupRemoveButton(int64_t ptr, int64_t btnPtr) {
    QButtonGroup* group = reinterpret_cast<QButtonGroup*>(ptr);
    QAbstractButton* btn = reinterpret_cast<QAbstractButton*>(btnPtr);
    if (group && btn) {
        group->removeButton(btn);
    }
}

void qButtonGroupSetExclusive(int64_t ptr, bool exclusive) {
    QButtonGroup* group = reinterpret_cast<QButtonGroup*>(ptr);
    if (group) {
        group->setExclusive(exclusive);
    }
}

bool qButtonGroupIsExclusive(int64_t ptr) {
    QButtonGroup* group = reinterpret_cast<QButtonGroup*>(ptr);
    return group ? group->exclusive() : false;
}

int32_t qButtonGroupCheckedId(int64_t ptr) {
    QButtonGroup* group = reinterpret_cast<QButtonGroup*>(ptr);
    return group ? group->checkedId() : -1;
}

int64_t qButtonGroupCheckedButton(int64_t ptr) {
    QButtonGroup* group = reinterpret_cast<QButtonGroup*>(ptr);
    if (group) {
        QAbstractButton* btn = group->checkedButton();
        return reinterpret_cast<int64_t>(btn);
    }
    return 0;
}

void qButtonGroupSetId(int64_t ptr, int64_t btnPtr, int32_t id) {
    QButtonGroup* group = reinterpret_cast<QButtonGroup*>(ptr);
    QAbstractButton* btn = reinterpret_cast<QAbstractButton*>(btnPtr);
    if (group && btn) {
        group->setId(btn, id);
    }
}

int32_t qButtonGroupId(int64_t ptr, int64_t btnPtr) {
    QButtonGroup* group = reinterpret_cast<QButtonGroup*>(ptr);
    QAbstractButton* btn = reinterpret_cast<QAbstractButton*>(btnPtr);
    return (group && btn) ? group->id(btn) : -1;
}

int32_t qButtonGroupButtonsCount(int64_t ptr) {
    QButtonGroup* group = reinterpret_cast<QButtonGroup*>(ptr);
    return group ? static_cast<int32_t>(group->buttons().size()) : 0;
}

void qButtonGroupDelete(int64_t ptr) {
    QButtonGroup* group = reinterpret_cast<QButtonGroup*>(ptr);
    if (group) {
        qWmiscSignalCleanup(ptr);
        delete group;
    }
}

} // extern "C"
