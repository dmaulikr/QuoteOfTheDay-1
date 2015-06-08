import UIKit

class WaitViewController: UIViewController {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func stopAnimating() {
        dispatch_async(dispatch_get_main_queue(), {self.activityIndicator.stopAnimating()})
    }
    
    func startAnimating() {
        dispatch_async(dispatch_get_main_queue(), {self.activityIndicator.startAnimating()})
    }
}