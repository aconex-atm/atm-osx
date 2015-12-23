import Foundation
import Starscream

class AtmApi: WebSocketDelegate {

    let BASE_URL = "ws://52.62.29.150:8080/level/4/room/male/slot/"
    let HTTP_BASE_URL = "http://52.62.29.150:8080/ts/"
    var socket: WebSocket
    var id: String

    init(id: String) {
        let url = NSURL(string: "\(BASE_URL)\(id)/subscribe")

        self.id = id
        self.socket = WebSocket(url: url!)
        socket.delegate = self
    }

    func subscribeOn(success: (Toilet) -> Void) {
        socket.onText = {
            text in
            let toilet = self.fromJson(text)
            success(toilet!)
        }
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("connect:"), userInfo: nil, repeats: false)
    }

    @objc func connect(socket: WebSocket) {
        print("connecting \(self.socket)")
        self.socket.connect()
    }

    func fromJson(str: String) -> Toilet? {
        typealias JSONDict = [String:AnyObject]
        let json: JSONDict

        do {
            json = try NSJSONSerialization.JSONObjectWithData(str.dataUsingEncoding(NSUTF8StringEncoding)!, options: []) as! JSONDict
        } catch {
            NSLog("JSON parsing failed: \(error)")
            return nil
        }

        return Toilet(
        id: self.id,
                occupied: json["occupied"] as! Bool
        )
    }

    func websocketDidConnect(ws: WebSocket) {
        print("websocket is connected")
    }

    func websocketDidDisconnect(ws: WebSocket, error: NSError?) {
        if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            print("websocket disconnected")
        }
    }

    func websocketDidReceiveMessage(ws: WebSocket, text: String) {
        print("Received text: \(text)")
    }

    func websocketDidReceiveData(ws: WebSocket, data: NSData) {
        print("Received data: \(data.length)")
    }
}
