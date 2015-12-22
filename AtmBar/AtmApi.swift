import Foundation
import Starscream

class AtmApi: WebSocketDelegate {

    let BASE_URL = "ws://52.62.29.150:8080/ts/"
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
        NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("connect:"), userInfo: nil, repeats: false)

        self.fetch(success)
    }


    func fetch(success: (Toilet) -> Void) {
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: "\(HTTP_BASE_URL)\(self.id)")


        let task = session.dataTaskWithURL(url!) {
            data, response, error in
            if let error = error {
                NSLog("api error: \(error)")
            }

            if let httpResponse = response as? NSHTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    let text = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
                    if let toilet = self.fromJson(text) {
                        success(toilet)
                    }
                default:
                    NSLog("api returned response: %d %@", httpResponse.statusCode, NSHTTPURLResponse.localizedStringForStatusCode(httpResponse.statusCode))
                }
            }
        }
        task.resume()
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
        id: json["id"] as! String,
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
