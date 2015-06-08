import UIKit
import QuartzCore

class RootViewController: UIViewController, NewQuotesDataModelProtocol, RootViewControllerProtocol {
    
    var newQuotesDM: NewQuotesDataModel?
    var newQuotesVC: NewQuotesViewController?
    var favouritesDM: FavouritesDataModel?
    var favouritesVC: FavouritesViewController?
    var waitVC: WaitViewController?
    var currentVC: UIViewController?
    var dataLoadingErrorCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        instantiateFavourites()
        instantiateNewQuotes()
        
        initFavourites()
        initNewQuotes()
        
        showWaitView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
  
    func showViewController(viewController: UIViewController) {
        if currentVC != viewController {
            dispatch_async(dispatch_get_main_queue(), {
                if (self.currentVC != nil) {self.currentVC!.view.removeFromSuperview()}
                self.currentVC = viewController
                var transition = CATransition()
                transition.duration = 0.3
                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                transition.type = kCATransitionFromBottom
                self.view.layer.addAnimation(transition, forKey: nil)
                self.view.addSubview(viewController.view)
            })
        }
    }
}

///Shake
extension RootViewController {
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if motion == UIEventSubtype.MotionShake {
                if ((currentVC! as? FavouritesViewController) != nil) {
                let quoteData = favouritesVC!.getCurrentViewController()!.quoteData!
                if quoteData.row_id != -1 {
                    UIPasteboard.generalPasteboard().string = quoteData.quote_text + "\r" + quoteData.quote_author
                    showAlert("", message: "Цитата скопирована в буфер обмена!", buttonText: "ОК")
                }
            }
        }
    }
}

///New Quotes VC
extension RootViewController {
    func instantiateNewQuotes() {
        newQuotesVC = (storyboard!.instantiateViewControllerWithIdentifier("NewQuotesViewController") as! NewQuotesViewController)
    }
    
    func initNewQuotes(){
        newQuotesDM = NewQuotesDataModel(delegate: self)
        newQuotesDM!.loadData()
        newQuotesVC!.setDataModel(newQuotesDM!)
        newQuotesVC!.setDelegate(self)
    }
    
    func showNewQuotes() {
        if (newQuotesVC != nil) {
            showViewController(newQuotesVC!)
        }
    }
}

//Favourites VC
extension RootViewController {
    func instantiateFavourites() {
        favouritesVC = (storyboard!.instantiateViewControllerWithIdentifier("FavouritesViewController") as! FavouritesViewController)
    }
    
    func initFavourites() {
        favouritesDM = FavouritesDataModel()
        favouritesDM!.loadData()
        favouritesVC!.setDataModel(favouritesDM!)
        favouritesVC!.setDelegate(self)
        favouritesVC!.initPageView()
    }
    
    func showFavourites() {
        if (favouritesVC != nil) {
            if !Settings.favouritesAlertSent {
                showAlert("", message: "Для копирования избранной цитаты в буфер обмена просто встряхните ваш iPhone!", buttonText: "OK")
                Settings.favouritesAlertSent = true
            }
            showViewController(favouritesVC!)
        }
    }
}

///Wait VC
extension RootViewController {
    func showWaitView() {
        if (waitVC == nil) {
            waitVC = (storyboard!.instantiateViewControllerWithIdentifier("WaitViewController") as! WaitViewController)
        }
        showViewController(waitVC!)
    }
}


///Root VCP
extension RootViewController {
    func quoteAddedToFavourites(quote: Quote) {
        if favouritesDM!.quotes.count < 100 {
            var isNew = favouritesDM!.addFavourite(quote.copy())
            if isNew {
                favouritesDM!.saveData()
                favouritesVC!.initPageViewWithIndex(favouritesDM!.quotes.count - 1)
            }
        }
        else {showAlert("", message: "В избранном уже 100 цитат, удалите цитаты из избранного чтобы добавить новые!", buttonText: "ОК")}
    }
    
    func goToFavouritesNow() {
        showFavourites()
    }
    
    func goToNewQuotesNow() {
        if newQuotesDM!.hasData {
            showNewQuotes()
        }
        else {
            newQuotesDM!.loadData()
            showWaitView()
            waitVC!.startAnimating()
        }
    }
    
    func changeGoTofavouritesViewController(quoteViewController: QuoteViewController) {
        if (newQuotesVC != nil) {
            newQuotesVC!.setGoToFavouritesView(quoteViewController)
        }
    }
    
    func changeGoToNewQuotesViewController(quoteViewController: QuoteViewController) {
        if (favouritesVC != nil) {
            favouritesVC!.setGoToNewQuotesView(quoteViewController)
        }
    }
    
}

///New Quotes DMP
extension RootViewController {
    func dataLoaded() {
        dataLoadingErrorCount = 0
        newQuotesVC!.initPageView()
        if ((currentVC! as? WaitViewController) !=  nil) {showNewQuotes()}
        if ((currentVC! as? FavouritesViewController) !=  nil) && (newQuotesDM!.quotes.count < 10) {showAlert("", message: "Цитаты загружены!", buttonText: "ОК")}
    }
    
    func dataLoadingFailed(message: String) {
        processDataLoadingError(message)
    }
    
    func dataParsingFailed(message: String) {
        processDataLoadingError(message)
    }
    
    func dataUpdated() {
        
    }
    
    func processDataLoadingError(message: String){
        if dataLoadingErrorCount > 4 {
            if ((currentVC! as? WaitViewController) != nil) {showAlert("", message: "Ошибка загрузки данных, попробуйте позже!", buttonText: "ОК")}
            dataLoadingErrorCount = 0
            if (waitVC != nil) {waitVC!.stopAnimating()}
            if newQuotesDM!.hasData {showNewQuotes()}
            else {
                showFavourites()
                NSThread.sleepForTimeInterval(10)
                newQuotesDM!.loadData()
            }
        }
        else {
            ++dataLoadingErrorCount
            NSThread.sleepForTimeInterval(2)
            newQuotesDM!.loadData()
        }
    }
}

///Alerts
extension RootViewController {
    func showAlert(title: String, message: String, buttonText: String) {
        dispatch_async(dispatch_get_main_queue(), {
            var alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: buttonText)
            alert.show()
        })
    }
}
