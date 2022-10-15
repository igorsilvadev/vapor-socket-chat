import Vapor
//Resource: https://fassko.medium.com/different-flavors-of-websockets-on-vapor-with-swift-54ce00cc60b4
func routes(_ app: Application) throws {
    
    var connections: [String: WebSocket] = [:]
    
    //The maxFrameSize allows client send large files
    app.webSocket("chat", maxFrameSize: 16_777_216) { request, webSocket in
        webSocket.send("Você se conectou ao servidor!")
        let id = UUID().uuidString
        connections[id] = webSocket
        
        webSocket.onText { ws, string in
            connections.keys.forEach { key in
                connections[key]?.send(string)
            }
        }
        
        //Resource: https://github.com/vapor/websocket-kit/issues/64
        webSocket.onBinary { ws, binary in
            print("GET DATA FROM SOCKET \(binary)")
                let bytesResponse = [UInt8]( Data(buffer: binary))
                connections.keys.forEach { key in
                    print("SEND BINARY")
                    connections[key]?.send(raw: bytesResponse, opcode: .binary)
                }
        }
        
        webSocket.onClose.whenComplete { result in
            switch result {
            case .success():
                print("Um usuário se desconectou")
                connections.keys.forEach { key in
                    connections[key]?.send("Um usuário se desconectou")
                }
            case .failure(let error):
                print("Failed to close connection \(error)")
            }
        }
    }
}

