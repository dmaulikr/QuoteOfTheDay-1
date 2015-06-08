import UIKit

protocol RootViewControllerProtocol {
    func quoteAddedToFavourites(quote: Quote)
    func goToFavouritesNow()
    func goToNewQuotesNow()
    func changeGoTofavouritesViewController(quoteViewController: QuoteViewController)
    func changeGoToNewQuotesViewController(quoteViewController: QuoteViewController)
}
