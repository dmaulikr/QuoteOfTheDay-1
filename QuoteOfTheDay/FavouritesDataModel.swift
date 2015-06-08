import UIKit


class FavouritesDataModel: NSObject, UIPageViewControllerDataSource {
    
    var quotes = Dictionary<Int,Quote>()
    var dataLoaded: Bool = false
    
    func loadData() {
        let json = Settings.favouritesJson
        if (json != nil) {
            var error: NSError?
            let json_array = NSJSONSerialization.JSONObjectWithData(json!.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false)!, options: NSJSONReadingOptions.MutableContainers | NSJSONReadingOptions.AllowFragments, error: &error) as? NSArray
            if  (json_array != nil) {
                if (error == nil) {
                    for json_dict: AnyObject in json_array! {
                        if let dict = json_dict as? NSDictionary{
                            var quote = Quote(json_dict: dict)
                            quotes[quote.row_id]=quote
                        }
                    }
                    self.dataLoaded = true
                }
            }
        }
    }
    
    func saveData(){
        var json: String = "["
        for quote in quotes.values{
            json += "\(quote.toJson()),"
        }
        json = "\(json.substringToIndex(json.endIndex.predecessor()))]"
        Settings.favouritesJson = json
    }
    
    func addFavourite(quote: Quote) -> Bool {
        var isNew = true
        for intQuote in quotes.values {
            if intQuote.quote_id == quote.quote_id {isNew=false}}
        if isNew {
            var row_id: Int = quotes.count
            quote.row_id = row_id
            quotes[row_id] = quote
        }
        return isNew
    }
    
    func removeFavourite(quote: Quote) -> Bool {
        if quotes.count == 0 {return false}
        else {
            for var i = quote.row_id; i < quotes.count - 1; ++i {
                quotes[i] = quotes[i+1]
                quotes[i]!.row_id = i
            }
            quotes.removeValueForKey(quotes.count - 1)
            return true
        }
    }
    
    func viewControllerWithEmptyInfo(viewController: UIViewController) -> QuoteViewController {
        let quoteVC = viewController.storyboard!.instantiateViewControllerWithIdentifier("QuoteViewController") as! QuoteViewController
        quoteVC.quoteData = Quote()
        quoteVC.quoteData!.row_id = -1
        quoteVC.useForFavourite = true
        return quoteVC
    }
    
    func viewControllerAtIndex(index: Int, viewController: UIViewController) -> QuoteViewController {
        if (self.quotes[index] == nil) {
            return viewControllerWithEmptyInfo(viewController)
        }
        else {
            let quoteVC = viewController.storyboard!.instantiateViewControllerWithIdentifier("QuoteViewController") as! QuoteViewController
            quoteVC.quoteData = self.quotes[index]
            quoteVC.quoteData!.row_id = index
            quoteVC.useForFavourite = true
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
        if index >= self.quotes.count {return nil}
        return self.viewControllerAtIndex(index, viewController: viewController)
    }

}
