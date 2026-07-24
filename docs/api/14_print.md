# CJQT6 打印模块

打印模块提供打印和打印预览功能。

```cangjie
import cjqt6.print.*
```

## QPrinter - 打印机

```cangjie
import cjqt6.print.*

let printer = QPrinter()

printer.setOutputFormat(OutputFormat.nativeFormat())
printer.setOutputFileName("/path/to/output.pdf")
printer.setPageSize(PageSize.a4())
printer.setOrientation(PageOrientation.portrait())
printer.setNumCopies(2)
printer.setDoubleSidedPrinting(true)
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init()` | 创建打印机 |
| `init(mode: Int32)` | 使用指定模式创建打印机（`PrinterMode` 常量） |
| `setOutputFormat(format: Int32)` | 设置输出格式 |
| `outputFormat(): Int32` | 获取输出格式 |
| `setOutputFileName(name: String)` | 设置输出文件名 |
| `outputFileName(): String` | 获取输出文件名 |
| `setPageSize(pageSize: Int32)` | 设置页面大小 |
| `pageSize(): Int32` | 获取页面大小 |
| `setOrientation(orientation: Int32)` | 设置页面方向 |
| `orientation(): Int32` | 获取页面方向 |
| `setPageMargins(left, top, right, bottom)` | 设置页边距 |
| `setFullPage(fullPage: Bool)` | 设置是否占满整页 |
| `fullPage(): Bool` | 获取是否占满整页 |
| `setNumCopies(copies: Int32)` | 设置打印份数 |
| `numCopies(): Int32` | 获取打印份数 |
| `setCopyCollate(collate: Bool)` | 设置逐份排序 |
| `copyCollate(): Bool` | 获取逐份排序状态 |
| `setColorMode(mode: Int32)` | 设置颜色模式 |
| `colorMode(): Int32` | 获取颜色模式 |
| `setDoubleSidedPrinting(enable: Bool)` | 设置双面打印 |
| `doubleSidedPrinting(): Bool` | 是否双面打印 |
| `width(): Int32` | 获取页面宽度 |
| `height(): Int32` | 获取页面高度 |
| `resolution(): Int32` | 获取分辨率 |
| `setResolution(dpi: Int32)` | 设置分辨率 |
| `printerName(): String` | 获取打印机名称 |
| `setPrinterName(name: String)` | 设置打印机名称 |
| `docName(): String` | 获取文档名称 |
| `setDocName(name: String)` | 设置文档名称 |
| `newPage(): Bool` | 新建一页 |
| `fromPage(): Int32` | 获取起始页 |
| `toPage(): Int32` | 获取结束页 |
| `setFromTo(from, to)` | 设置打印页范围 |
| `getPtr(): Int64` | 获取原生指针 |
| `delete()` | 释放资源 |

**常量**:
| 常量类 | 说明 |
|------|------|
| `PrinterMode.screenResolution()` | 屏幕分辨率模式 |
| `PrinterMode.printerResolution()` | 打印机分辨率模式 |
| `PrinterMode.highResolution()` | 高分辨率模式 |
| `OutputFormat.nativeFormat()` | 输出到打印机 |
| `OutputFormat.pdfFormat()` | 输出为 PDF |
| `PageSize.a4()` / `PageSize.letter()` / `PageSize.legal()` / `PageSize.a3()` / `PageSize.a5()` / `PageSize.b4()` / `PageSize.b5()` | 页面大小 |
| `PageOrientation.portrait()` / `PageOrientation.landscape()` | 页面方向 |
| `ColorMode.grayScale()` / `ColorMode.color()` | 颜色模式 |

---

## QPrintDialog - 打印对话框

```cangjie
let printer = QPrinter()
let dialog = QPrintDialog(printer)

let result = dialog.exec()
if (result == 1) {
    println("用户确认打印")
}

dialog.delete()
printer.delete()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init(printer: QPrinter)` | 创建打印对话框 |
| `exec(): Int32` | 执行对话框，返回是否接受 |
| `printer(): Int64` | 返回关联的打印机指针 |
| `delete()` | 释放资源 |

---

## QPrintPreviewDialog - 打印预览对话框

```cangjie
let printer = QPrinter()
let previewDialog = QPrintPreviewDialog(printer, textEdit)

previewDialog.exec()
previewDialog.delete()
printer.delete()
```

**方法**:
| 方法 | 说明 |
|------|------|
| `init(printer: QPrinter)` | 创建预览对话框 |
| `init(printer: QPrinter, textEdit: QTextEdit)` | 创建并绑定文本编辑器的预览对话框 |
| `exec(): Int32` | 执行预览对话框 |
| `printer(): Int64` | 返回关联的打印机指针 |
| `delete()` | 释放资源 |
