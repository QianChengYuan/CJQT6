# CJQT6 打印模块

打印模块提供打印和打印预览功能。

```cangjie
import cjqt6.print.*
```

## QPrinter - 打印机

```cangjie
let printer = QPrinter()

// 设置输出格式
printer.setOutputFormat(OutputFormat.NativeFormat)  // 打印到打印机
printer.setOutputFormat(OutputFormat.PdfFormat)     // 输出PDF

// 设置PDF文件名
printer.setOutputFileName("/path/to/output.pdf")

// 页面设置
printer.setPageSize(PageSize.A4)
printer.setOrientation(PageOrientation.Portrait)

// 打印份数
printer.setNumCopies(2)

// 双面打印
printer.setDoubleSidedPrinting(true)
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建打印机 |
| `init(mode: Int32)` | 创建打印机（高分辨率/屏幕分辨率） |
| `setOutputFormat(format: Int32)` | 设置输出格式 |
| `outputFormat(): Int32` | 获取输出格式 |
| `setOutputFileName(name: String)` | 设置输出文件名 |
| `outputFileName(): String` | 获取输出文件名 |
| `setPageSize(size: Int32)` | 设置页面大小 |
| `pageSize(): Int32` | 获取页面大小 |
| `setOrientation(orientation: Int32)` | 设置页面方向 |
| `orientation(): Int32` | 获取页面方向 |
| `setPageMargins(left, top, right, bottom)` | 设置页边距 |
| `setNumCopies(copies: Int32)` | 设置打印份数 |
| `numCopies(): Int32` | 获取打印份数 |
| `setDoubleSidedPrinting(enabled: Bool)` | 设置双面打印 |
| `doubleSidedPrinting(): Bool` | 是否双面打印 |
| `setColorMode(mode: Int32)` | 设置颜色模式 |
| `colorMode(): Int32` | 获取颜色模式 |
| `setResolution(dpi: Int32)` | 设置分辨率 |
| `resolution(): Int32` | 获取分辨率 |
| `setPrinterName(name: String)` | 设置打印机名称 |
| `printerName(): String` | 获取打印机名称 |
| `setDocName(name: String)` | 设置文档名称 |
| `docName(): String` | 获取文档名称 |
| `setFromTo(from, to)` | 设置打印页范围 |
| `fromPage(): Int32` | 获取起始页 |
| `toPage(): Int32` | 获取结束页 |
| `newPage(): Bool` | 新建一页 |
| `width(): Int32` | 获取页面宽度 |
| `height(): Int32` | 获取页面高度 |

**输出格式常量** (OutputFormat):
```cangjie
NativeFormat   // 打印机
PdfFormat      // PDF文件
```

**页面大小常量** (PageSize):
```cangjie
A3      // A3
A4      // A4
A5      // A5
Letter  // Letter
Legal   // Legal
B4      // B4
B5      // B5
```

**页面方向常量** (PageOrientation):
```cangjie
Portrait   // 纵向
Landscape  // 横向
```

**颜色模式常量** (ColorMode):
```cangjie
GrayScale  // 灰度
Color      // 彩色
```

---

## QPrintDialog - 打印对话框

```cangjie
let printer = QPrinter()
let dialog = QPrintDialog(printer)

let result = dialog.exec()
if (result == 1) {  // Accepted
    // 用户点击了打印
    textEdit.print(printer.getPtr())
}

dialog.delete()
printer.delete()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init(printer: QPrinter)` | 创建打印对话框 |
| `exec(): Int32` | 执行对话框（1=接受，0=取消） |
| `printer(): QPrinter` | 获取关联的打印机 |

---

## QPrintPreviewDialog - 打印预览对话框

```cangjie
let printer = QPrinter()

// 创建预览对话框（关联QTextEdit）
let previewDialog = QPrintPreviewDialog(printer, textEdit)
previewDialog.exec()

previewDialog.delete()
printer.delete()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init(printer: QPrinter)` | 创建预览对话框 |
| `init(printer: QPrinter, textEdit: QTextEdit)` | 创建预览对话框（关联文本编辑器） |
| `exec(): Int32` | 执行预览对话框 |
