import UIKit


class GoToFavouritesViewController: UIViewController{
    
    var color = UIColor(red: 0, green: 122, blue: 255, alpha: 1).CGColor
    var isCustomColor = true
    
    @IBOutlet var icon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.icon.layer.shadowColor = color
        self.icon.layer.shadowOpacity = 1
        self.icon.layer.shadowRadius = 30
        self.icon.layer.shadowOffset = CGSize.zeroSize
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func doBlink(done: (() -> Void))
    {
        self.icon.layer.shadowColor = UIColor.blueColor().CGColor
        UIView.animateWithDuration(1, animations: {
            self.icon.alpha = 0.01
            }, completion: {complete in
                if complete {
                    self.icon.layer.shadowColor = self.color
                    done()
                }
            })
    }
}