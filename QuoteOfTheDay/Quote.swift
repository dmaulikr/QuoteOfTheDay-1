import UIKit

class Quote {
    var row_id: Int
    var quote_id: Int
    var quote_html: String
    var quote_text: String
    var quote_author: String
    var quote_date: String
    var quote_add_datetime: String
    
    init(json_dict: NSDictionary){
        if let rowId = json_dict["row_id"] as? Int {row_id=rowId}
        else {row_id = NSDecimalNumber(string: json_dict["row_id"] as? String).integerValue}
        if let quoteId = json_dict["quote_id"] as? Int {quote_id=quoteId}
        else {quote_id=NSDecimalNumber(string: json_dict["quote_id"] as? String).integerValue}
        quote_html=json_dict["quote_html"] as! String
        quote_text=json_dict["quote_text"] as! String
        quote_author=json_dict["quote_author"] as! String
        quote_date=json_dict["quote_date"] as! String
        quote_add_datetime=json_dict["quote_add_date"] as! String
    }
    
    init(){
        row_id = 0
        quote_id = -1
        quote_html = ""
        quote_text = "В избранном пока нет цитат"
        quote_author = ""
        quote_date = ""
        quote_add_datetime = ""
    }
    
    func copy() -> Quote {
        var quote: Quote = Quote()
        quote.row_id = row_id
        quote.quote_id = quote_id
        quote.quote_html = quote_html
        quote.quote_text = quote_text
        quote.quote_author = quote_author
        quote.quote_date = quote_date
        quote.quote_add_datetime = quote_add_datetime
        return quote
    }
    
    func toJson() -> String {
        var json: String = "{\"quote_add_date\":\"\(quote_add_datetime)\",\"quote_author\":\"\(quote_author)\",\"quote_date\":\"\(quote_date)\",\"quote_html\":\"\(quote_html)\",\"quote_id\":\(quote_id),\"quote_text\":\"\(quote_text)\",\"row_id\":\(row_id)}"
        return json
    }
}
