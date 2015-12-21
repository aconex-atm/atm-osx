import Foundation

class AtmApi {

    let BASE_URL = "http://52.62.29.150:8080/ts/"
    
    func fetchStatus(id: String, success: (Toilet) -> Void) {
        
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: "\(BASE_URL)\(id)")

        let task = session.dataTaskWithURL(url!) { data, response, error in
            // first check for a hard error
            if let error = error {
                NSLog("api error: \(error)")
            }
            
            if let httpResponse = response as? NSHTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    if let toilet = self.toiletFromJSONData(data!) {
                        success(toilet)
                    }
                default:
                    NSLog("api returned response: %d %@", httpResponse.statusCode, NSHTTPURLResponse.localizedStringForStatusCode(httpResponse.statusCode))
                }
            }
        }
        task.resume()
    }
    
    func toiletFromJSONData(data: NSData) -> Toilet? {
        typealias JSONDict = [String:AnyObject]
        let json : JSONDict
        
        do {
            json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! JSONDict
        } catch {
            NSLog("JSON parsing failed: \(error)")
            return nil
        }
        
        
        let toilet = Toilet(
            id: json["id"] as! String,
            occupied: json["occupied"] as! Bool
        )
        
        return toilet
    }

}
