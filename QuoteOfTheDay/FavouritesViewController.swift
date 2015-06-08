import UIKit

class FavouritesViewController: UIViewController, UIPageViewControllerDelegate {
    
    var favouritesDM: FavouritesDataModel?
    var pageViewController: UIPageViewController?
    var panGestureRecognizer: UIPanGestureRecognizer?
    var removeFromFavouritesViewController: RemoveFromFavouritesViewController?
    var goToNewQuotesViewController: QuoteViewController?
    var delegate: RootViewControllerProtocol?
    var panGestureBeingPerformed: Bool = false
    var errorCounter: Int = 0
    var vY: CGFloat = 0
    var pY: CGFloat = 0
    var tY: NSDate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "panGestureAction")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setDataModel(favouritesDM: FavouritesDataModel) {
        self.favouritesDM = favouritesDM
    }
    
    func setDelegate(delegate: RootViewControllerProtocol) {
        self.delegate = delegate
    }
    
    func getCurrentViewController() -> QuoteViewController? {
        if (pageViewController != nil) {
            if (pageViewController!.viewControllers != nil) {
                if pageViewController!.viewControllers.count > 0 {
                    if let currentVC = pageViewController!.viewControllers[0] as? QuoteViewController {
                        return currentVC
                    }
                }
            }
        }
        return nil
    }
    
    func panGestureAction(){
        var point: CGPoint = panGestureRecognizer!.translationInView(self.view)
        if panGestureRecognizer!.state == UIGestureRecognizerState.Began {
            panGestureBeingPerformed = true
            vY=0
            pY=0
            tY=NSDate()
        }
        else if panGestureRecognizer!.state == UIGestureRecognizerState.Changed {            
            let timeInterval: CGFloat = CGFloat(NSDate().timeIntervalSinceDate(tY!))
            vY=abs(point.y - pY)/timeInterval
            tY=NSDate()
            pY=point.y
        }
        else if panGestureRecognizer!.state == UIGestureRecognizerState.Ended ||
            panGestureRecognizer!.state == UIGestureRecognizerState.Cancelled ||
            panGestureRecognizer!.state == UIGestureRecognizerState.Failed {
                panGestureBeingPerformed = false
        }
        
        if point.y > 0 {
            if panGestureRecognizer!.state != UIGestureRecognizerState.Ended {
                
                var bounds = self.view.frame
                var diffY:CGFloat
                
                if point.y < 70 {
                    diffY = point.y
                }
                else {
                    diffY = (abs(point.y)-70)/(2 + 2*abs(point.y)/70) + 70
                }
                bounds.origin.y += diffY
                
                pageViewController!.view.frame = bounds
                
                if point.y < 50 {removeFromFavouritesViewController!.icon.alpha = 0.01}
                else if point.y >= 50 && point.y < 140 {removeFromFavouritesViewController!.icon.alpha = (abs(point.y) - 50)/140}
                else {removeFromFavouritesViewController!.icon.alpha = 1}
                
                if point.y > 50 && point.y < 120 {
                    bounds = CGRect(x: 0, y: 0, width: removeFromFavouritesViewController!.view.bounds.width, height: abs(diffY))
                    removeFromFavouritesViewController!.view.frame = bounds
                }
            }
            else {
                if point.y < 140 {
                    panGestureRecognizer!.enabled=false
                    removeFromFavouritesViewController!.icon.alpha = 0.01
                    UIView.animateWithDuration(0.3, animations: {
                        self.pageViewController!.view.frame = self.view.frame
                        }, completion: {
                            done in
                            if done {self.panGestureRecognizer!.enabled=true}
                        })
                }
                else {
                    panGestureRecognizer!.enabled=false
                    removeCurrentQuoteFromFavourites()
                    removeFromFavouritesViewController!.doBlink({
                        UIView.animateWithDuration(0.3, animations: {
                            self.pageViewController!.view.frame = self.view.frame
                            }, completion: {
                                done in
                                if done {
                                    self.panGestureRecognizer!.enabled=true
                                }
                            })
                        })
                }
            }
        }
        else if (point.y < 0) && (goToNewQuotesViewController != nil) {
            if panGestureRecognizer!.state != UIGestureRecognizerState.Ended {
                
                var bounds = self.view.frame
                
                bounds.origin.y += point.y
                    
                pageViewController!.view.frame = bounds
                    
                bounds = getDefaultGoToNewQuotesViewBounds()
                bounds.origin.y += point.y
                goToNewQuotesViewController!.view.frame = bounds
                    
            }
            else {
                if (point.y > -self.view.bounds.height/2) && (vY < 500) {
                    panGestureRecognizer!.enabled=false
                    UIView.animateWithDuration(0.3, animations: {
                        self.pageViewController!.view.frame = self.view.frame
                        self.goToNewQuotesViewController!.view.frame = self.getDefaultGoToNewQuotesViewBounds()
                        }, completion: {
                            done in
                            if done {self.panGestureRecognizer!.enabled=true}
                        })
                }
                else{
                    panGestureRecognizer!.enabled=false
                    UIView.animateWithDuration(0.3, animations: {
                        self.pageViewController!.view.frame = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y - self.view.bounds.height, width: self.view.bounds.width, height: self.view.bounds.height)
                        self.goToNewQuotesViewController!.view.frame = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y, width: self.view.bounds.width, height: self.view.bounds.height)
                        }, completion: {
                            done in
                            if done {
                                self.delegate!.changeGoTofavouritesViewController(self.getCurrentViewController()!.copyQuoteViewController())
                                self.delegate!.goToNewQuotesNow()
                                self.panGestureRecognizer!.enabled=true
                                dispatch_async(dispatch_get_main_queue(), {
                                    UIView.animateWithDuration(0.3, delay: 0.3, options: nil, animations: {
                                        self.pageViewController!.view.frame = self.view.frame
                                        self.goToNewQuotesViewController!.view.frame = self.getDefaultGoToNewQuotesViewBounds()
                                        }, completion: nil)
                                })
                            }
                        })
                }
            }
        }
    }
    
    func initRemoveFromFavouritesView(){
        removeFromFavouritesViewController = (storyboard!.instantiateViewControllerWithIdentifier("RemoveFromFavouritesViewController") as! RemoveFromFavouritesViewController)
        removeFromFavouritesViewController!.view.frame = getDefaultRemoveFromFavouritesViewBounds()
        self.view.insertSubview(removeFromFavouritesViewController!.view, belowSubview: pageViewController!.view)
    }
    
    func getDefaultRemoveFromFavouritesViewBounds() -> CGRect {
        return CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y, width: self.view.bounds.width, height: 50)
    }
    
    func setGoToNewQuotesView(quoteViewController: QuoteViewController) {
        dispatch_async(dispatch_get_main_queue(), {
            if (self.goToNewQuotesViewController != nil) {
                quoteViewController.view.frame = self.goToNewQuotesViewController!.view.frame
                self.goToNewQuotesViewController!.view.removeFromSuperview()
            }
            else{
                quoteViewController.view.frame = self.getDefaultGoToNewQuotesViewBounds()
            }
            self.goToNewQuotesViewController = quoteViewController
            self.view.addSubview(self.goToNewQuotesViewController!.view)
            })
    }
    
    func getDefaultGoToNewQuotesViewBounds() -> CGRect {
        return CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y + self.view.bounds.height, width: self.view.bounds.width, height: self.view.bounds.height)
    }
    
    func removeCurrentQuoteFromFavourites(){
        if let quoteViewController = pageViewController!.viewControllers[0] as? QuoteViewController {
            var index = -1
            if quoteViewController.quoteData!.row_id == favouritesDM!.quotes.count - 1 {
                index = quoteViewController.quoteData!.row_id - 1
            }
            else { index = quoteViewController.quoteData!.row_id }
            var removed = favouritesDM!.removeFavourite(quoteViewController.quoteData!)
            favouritesDM!.saveData()
            if removed {initPageViewWithIndex(index)}
        }
    }
    
    func initPageView(){
        delegate!.changeGoTofavouritesViewController(self.favouritesDM!.viewControllerAtIndex(0, viewController: self as UIViewController))
        
        dispatch_async(dispatch_get_main_queue(), {
            if (self.pageViewController == nil) {
                self.pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
                self.pageViewController!.delegate = self
                
                let startingViewController = self.favouritesDM!.viewControllerAtIndex(0, viewController: self as UIViewController)
                let viewControllers: NSArray = [startingViewController]
                self.pageViewController!.setViewControllers(viewControllers as [AnyObject], direction: .Forward, animated: true, completion: nil)
                self.pageViewController!.dataSource = self.favouritesDM!
                                
                self.addChildViewController(self.pageViewController!)
                self.view.addSubview(self.pageViewController!.view)
                
                self.pageViewController!.view.addGestureRecognizer(self.panGestureRecognizer!)
                
                self.pageViewController!.view.frame = self.view.bounds
                
                self.pageViewController!.didMoveToParentViewController(self)
                
                self.initRemoveFromFavouritesView()
            }
            else{
                let startingViewController = self.favouritesDM!.viewControllerAtIndex(0, viewController: self as UIViewController)
                let viewControllers: NSArray = [startingViewController]
                self.pageViewController!.setViewControllers(viewControllers as [AnyObject], direction: .Forward, animated: true, completion: {
                    done in
                    if done {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.pageViewController!.setViewControllers(viewControllers as [AnyObject], direction: .Forward, animated: false, completion: nil)
                            })
                    }
                })
            }
        })
    }
    
    func initPageViewWithIndex(index: Int) {
        delegate!.changeGoTofavouritesViewController(self.favouritesDM!.viewControllerAtIndex(index, viewController: self as UIViewController))
        
        dispatch_async(dispatch_get_main_queue(), {
            let startingViewController: QuoteViewController = self.favouritesDM!.viewControllerAtIndex(index, viewController: self as UIViewController)
            let viewControllers: NSArray = [startingViewController]
            self.pageViewController!.setViewControllers(viewControllers as [AnyObject], direction: .Forward, animated: true, completion: {
                done in
                if done {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.pageViewController!.setViewControllers(viewControllers as [AnyObject], direction: .Forward, animated: false, completion: nil)
                        })
                }
                })
        })
    }
    
}














