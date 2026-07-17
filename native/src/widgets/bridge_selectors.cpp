/**
 * @file bridge_selectors.cpp
 * @brief 选择部件桥接函数 - QCheckBox, QRadioButton, QComboBox
 */

#include <QCheckBox>
#include <QRadioButton>
#include <QComboBox>
#include <functional>
#include <unordered_map>

// 回调映射
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_checkBoxCallbacks;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_radioButtonCallbacks;
static std::unordered_map<int64_t, std::function<void(int64_t)>> g_comboBoxCallbacks;

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
        static QString text;
        text = comboBox->currentText();
        return text.toUtf8().constData();
    }
    return "";
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

void qComboBoxDelete(int64_t ptr) {
    QComboBox* comboBox = reinterpret_cast<QComboBox*>(ptr);
    if (comboBox) {
        delete comboBox;
    }
}

} // extern "C"
