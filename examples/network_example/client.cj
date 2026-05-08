package network_example

import cjqt6.core.*
import cjqt6.network.*

func runClient(args: Array<String>) {
    if (args.size < 4) {
        println("用法: network_example client <服务端IP> <服务端端口> <消息>")
        return
    }
    
    let serverHost = args[1]
    let serverPort = UInt16.parse(args[2])
    let message = args[3]
    
    if (serverPort == 0) {
        println("无效端口号")
        return
    }
    
    println("UDP客户端发送消息到 ${serverHost}:${serverPort}")
    println("消息内容: ${message}")
    
    let socket = QUdpSocket()
    
    socket.setOnReadyRead({
        while (socket.hasPendingDatagrams()) {
            let datagram = socket.readDatagram()
            let reply = String.fromUtf8(datagram.data)
            println("收到服务端回复:")
            println("  ${reply}")
        }
    })
    
    socket.setOnError({
        println("错误: ${socket.errorString()}")
    })
    
    // 发送消息
    let sent = socket.writeStringDatagram(message, serverHost, serverPort)
    println("已发送 ${sent} 字节")
    
    // 等待回复
    println("等待服务端回复...")
    
    // 运行事件循环
    let app = QApplication([])
    app.exec()
    
    socket.delete()
}
