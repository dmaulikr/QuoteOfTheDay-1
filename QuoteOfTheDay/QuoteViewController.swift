import UIKit

class QuoteViewController: UIViewController {
    
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var yearLabel: UILabel!
    @IBOutlet var idLabel: UILabel!
    @IBOutlet var backgroundView: UIImageView!
    
    var quoteData: Quote?
    var useForFavourite: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (quoteData != nil) {
            if useForFavourite {
                backgroundView.image = UIImage(named: "BackgroundTornFavourite")
            }
            self.textLabel.text="\""+quoteData!.quote_text+"\""
            self.authorLabel.text=quoteData!.quote_author
            self.yearLabel.text=quoteData!.quote_date
            if quoteData!.quote_id > 0 {self.idLabel.text="№ "+quoteData!.quote_id.description}
            else {self.idLabel.text=""}
        }
        else{
            self.textLabel.text=""
            self.authorLabel.text=""
            self.yearLabel.text=""
            self.idLabel.text=""
        }
    }
    
    func copyQuoteViewController() -> QuoteViewController! {
        let quoteVC = (self.storyboard!.instantiateViewControllerWithIdentifier("QuoteViewController") as! QuoteViewController)
        quoteVC.quoteData = self.quoteData!.copy()
        quoteVC.useForFavourite = self.useForFavourite
        return quoteVC
    }
}