import Foundation

protocol NewQuotesDataModelProtocol {
    func dataLoaded()
    func dataUpdated()
    func dataLoadingFailed(message: String)
    func dataParsingFailed(message: String)
}
