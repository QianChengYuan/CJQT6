package multimedia_demo

import CJQT6.core.*
import CJQT6.widgets.*
import CJQT6.gui.*
import CJQT6.multimedia.*

var g_player: ?QMediaPlayer = None
var g_fileEdit: ?QLineEdit = None

main(): Int32 {
    let app = QApplication()
    let window = QWidget()
    window.setTitle("多媒体播放器演示")
    window.resize(500, 300)
    
    let mainLayout = QVBoxLayout()
    
    // 标题
    let titleLabel = QLabel()
    titleLabel.setText("QMediaPlayer 演示")
    mainLayout.addWidget(titleLabel.getPtr())
    
    // 文件路径输入
    let fileLayout = QHBoxLayout()
    let fileLabel = QLabel()
    fileLabel.setText("媒体文件:")
    let fileEdit = QLineEdit()
    fileEdit.setPlaceholder("输入音频/视频文件路径")
    g_fileEdit = fileEdit
    fileLayout.addWidget(fileLabel.getPtr())
    fileLayout.addWidget(fileEdit.getPtr())
    mainLayout.addLayout(fileLayout.getPtr())
    
    // 播放器
    let player = QMediaPlayer()
    let audioOutput = QAudioOutput()
    player.setAudioOutput(audioOutput)
    player.setVolume(0.8)
    g_player = player
    
    // 音量控制
    let volumeLayout = QHBoxLayout()
    let volumeLabel = QLabel()
    volumeLabel.setText("音量:")
    let volumeSlider = QSlider()
    volumeSlider.setRange(0, 100)
    volumeSlider.setValue(80)
    volumeSlider.setOrientation(0) // Horizontal
    
    let volumeCallback: Int32Callback = { value: Int32 =>
        if (let Some(p) <- g_player) {
            p.setVolume(Float32(value) / 100.0)
        }
    }
    volumeSlider.setOnValueChanged(volumeCallback)
    
    volumeLayout.addWidget(volumeLabel.getPtr())
    volumeLayout.addWidget(volumeSlider.getPtr())
    mainLayout.addLayout(volumeLayout.getPtr())
    
    // 控制按钮
    let btnLayout = QHBoxLayout()
    
    let loadBtn = QPushButton()
    loadBtn.setText("加载")
    let loadCallback: VoidCallback = { =>
        if (let Some(p) <- g_player) {
            if (let Some(edit) <- g_fileEdit) {
                let path = edit.text()
                if (path.size > 0) {
                    p.setSource(path)
                    println("已加载: ${path}")
                }
            }
        }
    }
    loadBtn.setOnClick(loadCallback)
    
    let playBtn = QPushButton()
    playBtn.setText("播放")
    let playCallback: VoidCallback = { =>
        if (let Some(p) <- g_player) {
            p.play()
            println("开始播放")
        }
    }
    playBtn.setOnClick(playCallback)
    
    let pauseBtn = QPushButton()
    pauseBtn.setText("暂停")
    let pauseCallback: VoidCallback = { =>
        if (let Some(p) <- g_player) {
            p.pause()
            println("已暂停")
        }
    }
    pauseBtn.setOnClick(pauseCallback)
    
    let stopBtn = QPushButton()
    stopBtn.setText("停止")
    let stopCallback: VoidCallback = { =>
        if (let Some(p) <- g_player) {
            p.stop()
            println("已停止")
        }
    }
    stopBtn.setOnClick(stopCallback)
    
    btnLayout.addWidget(loadBtn.getPtr())
    btnLayout.addWidget(playBtn.getPtr())
    btnLayout.addWidget(pauseBtn.getPtr())
    btnLayout.addWidget(stopBtn.getPtr())
    mainLayout.addLayout(btnLayout.getPtr())
    
    // 说明
    let infoLabel = QLabel()
    infoLabel.setText("提示: 输入媒体文件路径后点击加载，然后播放")
    mainLayout.addWidget(infoLabel.getPtr())
    
    window.setLayout(mainLayout.getPtr())
    window.show()
    
    let result = app.exec()
    
    // 清理
    g_player = None
    g_fileEdit = None
    player.delete()
    audioOutput.delete()
    titleLabel.delete()
    fileLabel.delete()
    fileEdit.delete()
    volumeLabel.delete()
    volumeSlider.delete()
    loadBtn.delete()
    playBtn.delete()
    pauseBtn.delete()
    stopBtn.delete()
    infoLabel.delete()
    window.delete()
    app.delete()
    
    return result
}
