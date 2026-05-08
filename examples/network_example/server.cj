package network_example

import cjqt6.core.*
import cjqt6.network.*

main() {
    let args = getArgs()
    
    if (args.size < 2) {
        println("用法:")
        println("  UDP服务端: network_example server <端口>")
        println("  UDP客户端: network_example client <服务端IP> <服务端端口> <消息>")
        return
    }
    
    let mode = args[0]
    
    if (mode == "server") {
        runServer(args)
    } else if (mode == "client") {
        runClient(args)
    } else {
        println("未知模式: ${mode}")
    }
}

func runServer(args: Array<String>) {
    if (args.size < 2) {
        println("用法: network_example server <端口>")
        return
    }
    
    let port = UInt16.parse(args[1])
    if (port == 0) {
        println("无效端口号")
        return
    }
    
    println("启动UDP服务端，监听端口: ${port}")
    
    let socket = QUdpSocket()
    if (!socket.bind(port)) {
        println("绑定失败: ${socket.errorString()}")
        return
    }
    
    println("服务端已启动，等待接收数据...")
    
    socket.setOnReadyRead({
        while (socket.hasPendingDatagrams()) {
            let datagram = socket.readDatagram()
            let message = String.fromUtf8(datagram.data)
            println("收到来自 ${datagram.senderAddress}:${datagram.senderPort} 的消息:")
            println("  ${message}")
            
            // 回复客户端
            let reply = "已收到: ${message}"
            socket.writeStringDatagram(reply, datagram.senderAddress, datagram.senderPort)
        }
    })
    
    socket.setOnError({
        println("错误: ${socket.errorString()}")
    })
    
    // 运行事件循环
    let app = QApplication([])
    app.exec()
    
    socket.delete()
}
