import Foundation

class Settings{
    
    class var favouritesAlertSent: Bool {
        get{
            if let aSent = NSUserDefaults.standardUserDefaults().objectForKey("FavouritesAlertSent") as? Bool{
                return aSent
            }
            else{
                return false
            }
        }
        set{
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey:"FavouritesAlertSent")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    class var newQuotesAlertSent: Bool {
        get{
        if let aSent = NSUserDefaults.standardUserDefaults().objectForKey("NewQuotesAlertSent") as? Bool{
        return aSent
    }
        else{
        return false
        }
        }
        set{
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey:"NewQuotesAlertSent")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    class var quotesDataApiUrl: NSURL {
        get{
            return NSURL(string: "http://95.84.168.105:808/quotesdata-api/quotesdata")!
        }
    }
    
    class var httpMethod: String {
        get{
            return "GET"
        }
    }
    
    class var httpTimeoutInterval: NSTimeInterval {
        get{
            return 2
        }
    }
    
    class var favouritesJson: String? {
        get{
            if let sJson = NSUserDefaults.standardUserDefaults().objectForKey("FavouritesData") as? String{
                return sJson
            }
            else{
                return nil
            }
        }
        set{
            NSUserDefaults.standardUserDefaults().setObject(newValue!, forKey:"FavouritesData")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    class func getDevicesDataApiUrl(deviceToken: String) -> NSURL {
        return NSURL(string: "http://95.84.168.105:808/quotesdata-api/devicesdata/\(deviceToken)")!
    }
    
    class func reportDeviceToken(deviceToken: String) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            var url = self.getDevicesDataApiUrl(deviceToken)
            var request = NSMutableURLRequest(URL:url)
            request.HTTPMethod = Settings.httpMethod
            request.timeoutInterval = Settings.httpTimeoutInterval
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: config)
            let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: nil)
            task.resume()
        })
    }
}
