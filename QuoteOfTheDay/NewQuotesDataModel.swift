import UIKit


class NewQuotesDataModel: NSObject, UIPageViewControllerDataSource {
    
    var quotes = Dictionary<Int,Quote>()
    var delegate: NewQuotesDataModelProtocol
    ///////////// indicators
    var dataLoaded = false
    var dataParsed = false
    var dataParsingHadError = false
    var dataLoadingHadError = false
    var dataLoadingInProcess = false
    var hasData = false
    /////////////
    
    init(delegate: NewQuotesDataModelProtocol){
        self.delegate=delegate
        super.init()
    }
    
    func loadData(){
        if !self.dataLoadingInProcess{
            var url = Settings.quotesDataApiUrl
            var request = NSMutableURLRequest(URL:url)
            request.HTTPMethod = Settings.httpMethod
            request.timeoutInterval = Settings.httpTimeoutInterval
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: config)
            let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: {(data: NSData!, response: NSURLResponse!, error: NSError!) in
                self.dataLoadingInProcess=false
                if error==nil{
                    self.dataLoadingHadError=false
                    self.dataLoaded=true
                    self.parseData(data)
                }
                else{
                    self.dataLoadingHadError=true
                    self.dataLoaded=false
                    self.delegate.dataLoadingFailed(error.description)
                }
                });
            self.dataLoadingInProcess=true
            task.resume()
        }
    }
    
    func parseData(data: NSData){
        var error: NSError?
        if let json_array = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers | NSJSONReadingOptions.AllowFragments, error: &error) as? NSArray{
            if (error == nil) {
                let quotes_count = quotes.count
                for json_dict: AnyObject in json_array{
                    if let dict = json_dict as? NSDictionary{
                        var quote = Quote(json_dict: dict)
                        quote.row_id = quotes_count + quote.row_id
                        quotes[quote.row_id]=quote
                    }
                }
                self.dataParsed=true
                self.dataParsingHadError=false
                self.hasData=true
                NSThread.sleepForTimeInterval(1)
                self.delegate.dataLoaded()
            }
            else{
                self.dataParsed=false
                self.dataParsingHadError=true
                self.delegate.dataParsingFailed(error!.description)
            }
        }
        else{
            self.dataParsed=false
            self.dataParsingHadError=true
            self.delegate.dataParsingFailed("Wrong response format")
        }
    }
    
    func viewControllerAtIndex(index: Int, viewController: UIViewController) -> QuoteViewController {
        if (self.quotes[index] == nil) {
            let quoteVC = viewController.storyboard!.instantiateViewControllerWithIdentifier("QuoteViewController") as! QuoteViewController
            quoteVC.quoteData = Quote()
            quoteVC.quoteData!.quote_text = "Новые цитаты ещё не загружены"
            quoteVC.quoteData!.row_id = -1
            return quoteVC
        }
        else {
            let quoteVC = viewController.storyboard!.instantiateViewControllerWithIdentifier("QuoteViewController") as! QuoteViewController
            quoteVC.quoteData = self.quotes[index]
            return quoteVC
        }
    }
    
    func indexOfViewController(viewController: QuoteViewController) -> Int {
        return viewController.quoteData!.row_id
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! QuoteViewController)
        index--
        if index < 0 {return nil}
        return self.viewControllerAtIndex(index, viewController: viewController)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! QuoteViewController)
        index++
        if index >= self.quotes.count - 1 {self.loadData()}
        if index >= self.quotes.count {return nil}
        return self.viewControllerAtIndex(index, viewController: viewController)
    }
    
}