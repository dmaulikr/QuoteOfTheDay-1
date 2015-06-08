import UIKit

class NewQuotesViewController: UIViewController, UIPageViewControllerDelegate {
    
    var newQuotesDM: NewQuotesDataModel?
    var pageViewController: UIPageViewController?
    var panGestureRecognizer: UIPanGestureRecognizer?
    var addToFavouritesViewController: AddToFavouritesViewController?
    var goToFavouritesViewController: QuoteViewController?
    var delegate: RootViewControllerProtocol?
    var panGestureBeingPerformed: Bool = false
    var errorCounter: Int = 0
    var vY: CGFloat = 0
    var pY: CGFloat = 0
    var tY: NSDate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tY = NSDate()
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "panGestureAction")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setDataModel(newQuotesDM: NewQuotesDataModel) {
        self.newQuotesDM = newQuotesDM
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
        
        if (point.y > 0) && (goToFavouritesViewController != nil) {
            if panGestureRecognizer!.state != UIGestureRecognizerState.Ended {
                
                var bounds = self.view.frame
                bounds.origin.y += point.y
                
                pageViewController!.view.frame = bounds
                

                bounds = getDefaultGoToFavouritesViewBounds()
                bounds.origin.y += point.y
                
                goToFavouritesViewController!.view.frame = bounds
                
            }
            else {
                if (point.y < self.view.bounds.height/2) && (vY < 500) {
                    panGestureRecognizer!.enabled=false
                    UIView.animateWithDuration(0.3, animations: {
                        self.pageViewController!.view.frame = self.view.frame
                        self.goToFavouritesViewController!.view.frame = self.getDefaultGoToFavouritesViewBounds()
                        }, completion: {
                            done in
                            if done {self.panGestureRecognizer!.enabled=true}
                        })
                }
                else {
                    panGestureRecognizer!.enabled=false
                    UIView.animateWithDuration(0.3, animations: {
                        self.pageViewController!.view.frame = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y + self.view.bounds.height, width: self.view.bounds.width, height: self.view.bounds.height)
                        self.goToFavouritesViewController!.view.frame = CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y, width: self.view.bounds.width, height: self.view.bounds.height)
                        }, completion: {
                            done in
                            if done {
                                self.delegate!.changeGoToNewQuotesViewController(self.getCurrentViewController()!.copyQuoteViewController())
                                self.delegate!.goToFavouritesNow()
                                self.panGestureRecognizer!.enabled=true
                                dispatch_async(dispatch_get_main_queue(), {
                                    UIView.animateWithDuration(0.3, delay: 0.3, options: nil, animations: {
                                        self.pageViewController!.view.frame = self.view.frame
                                        self.goToFavouritesViewController!.view.frame = self.getDefaultGoToFavouritesViewBounds()
                                        }, completion: nil)
                                })
                            }
                        })
                }
            }
        }
        else if point.y < 0 {
            if panGestureRecognizer!.state != UIGestureRecognizerState.Ended {
                
                var bounds = self.view.frame
                var diffY:CGFloat
                
                if point.y > -70 {
                    diffY = point.y
                }
                else {
                    diffY = -((abs(point.y)-70)/(2 + 2*abs(point.y)/70) + 70)
                }
                bounds.origin.y += diffY
                
                pageViewController!.view.frame = bounds
                
                if point.y > -50 {addToFavouritesViewController!.icon.alpha = 0.01}
                else if point.y <= -50 && point.y > -140 {addToFavouritesViewController!.icon.alpha = (abs(point.y) - 50)/140}
                else {addToFavouritesViewController!.icon.alpha = 1}
                
                if point.y < -50 && point.y > -120 {
                    bounds = CGRect(x: 0, y: getDefaultAddToFavouritesViewBounds().origin.y + diffY + 50, width: addToFavouritesViewController!.view.bounds.width, height: abs(diffY))
                    addToFavouritesViewController!.view.frame = bounds
                }
            }
            else {
                if point.y > -140 {
                    panGestureRecognizer!.enabled=false
                    self.addToFavouritesViewController!.icon.alpha = 0.01
                    UIView.animateWithDuration(0.3, animations: {
                        self.pageViewController!.view.frame = self.view.frame
                        self.addToFavouritesViewController!.view.frame = self.getDefaultAddToFavouritesViewBounds()
                        }, completion: {
                            done in
                            if done {self.panGestureRecognizer!.enabled=true}
                        })
                }
                else{
                    panGestureRecognizer!.enabled = false
                    addCurrentQuoteToFavourite()
                    addToFavouritesViewController!.doBlink({
                        UIView.animateWithDuration(0.5, animations: {
                            self.pageViewController!.view.frame = self.view.frame
                            self.addToFavouritesViewController!.view.frame = self.getDefaultAddToFavouritesViewBounds()
                            }, completion: {
                                done in
                                if done {self.panGestureRecognizer!.enabled=true}
                            })
                        })
                }
            }
        }
    }
    
    func initAddToFavouritesView(){
        addToFavouritesViewController = (storyboard!.instantiateViewControllerWithIdentifier("AddToFavouritesViewController") as! AddToFavouritesViewController)
        addToFavouritesViewController!.view.frame = getDefaultAddToFavouritesViewBounds()
        self.view.insertSubview(addToFavouritesViewController!.view, belowSubview: pageViewController!.view)
    }
    
    func getDefaultAddToFavouritesViewBounds() -> CGRect {
        return CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y + self.view.bounds.height-50, width: self.view.bounds.width, height: 50)
    }
    
    func setGoToFavouritesView(quoteViewController: QuoteViewController) {
        dispatch_async(dispatch_get_main_queue(), {
            if (self.goToFavouritesViewController != nil) {
                quoteViewController.view.frame = self.goToFavouritesViewController!.view.frame
                self.goToFavouritesViewController!.view.removeFromSuperview()
            }
            else{
                quoteViewController.view.frame = self.getDefaultGoToFavouritesViewBounds()
            }
            self.goToFavouritesViewController = quoteViewController
            self.view.addSubview(self.goToFavouritesViewController!.view)
        })
    }
    
    func getDefaultGoToFavouritesViewBounds() -> CGRect {
        return CGRect(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y - self.view.bounds.height, width: self.view.bounds.width, height: self.view.bounds.height)
    }
    
    func addCurrentQuoteToFavourite(){
        if let quoteViewController = pageViewController!.viewControllers[0] as? QuoteViewController {
            delegate!.quoteAddedToFavourites(quoteViewController.quoteData!)
        }
    }
    
    func initPageView(){
        dispatch_async(dispatch_get_main_queue(), {
            if (self.pageViewController == nil) {
                self.delegate!.changeGoToNewQuotesViewController(self.newQuotesDM!.viewControllerAtIndex(0, viewController: self as UIViewController))
                
                self.pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
                self.pageViewController!.delegate = self
                
                let startingViewController = self.newQuotesDM!.viewControllerAtIndex(0, viewController: self as UIViewController)
                let viewControllers: NSArray = [startingViewController]
                self.pageViewController!.setViewControllers(viewControllers as! [AnyObject], direction: .Forward, animated: true, completion: nil)
                self.pageViewController!.dataSource = self.newQuotesDM!
                
                self.addChildViewController(self.pageViewController!)
                self.view.addSubview(self.pageViewController!.view)
                
                self.pageViewController!.view.addGestureRecognizer(self.panGestureRecognizer!)
                
                self.pageViewController!.view.frame = self.view.bounds
                
                self.pageViewController!.didMoveToParentViewController(self)
                
                self.initAddToFavouritesView()
            }
            else{
                let viewControllers: NSArray = self.pageViewController!.viewControllers
                self.pageViewController!.setViewControllers(viewControllers as! [AnyObject], direction: .Forward, animated: false, completion: nil)
            }
        })
    }

}














