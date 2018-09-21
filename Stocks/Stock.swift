//
//  Stock.swift
//  Stocks
//
//  Created by Andrey Koltsov on 12/09/2018.
//  Copyright © 2018 Polytechnic University. All rights reserved.
//

import Foundation

struct Stock {
    var companyName: String = ""
    var companySymbol: String = ""
    var companyPrice: Double = 0.0
    var priceChange: Double = 0.0
    private var isProfitable: Bool {
        get {
            return (priceChange > 0)
        }
    }
    
    init(data: Data) {
        self.parseQuote(data: data)
    }
    
    private mutating func parseQuote(data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            
            guard let json = jsonObject as? [String: Any],
                let companyName = json[Constants.IEXTRADING_RESPONSE_COMPANY_NAME_TAG] as? String,
                let companySymbol = json[Constants.IEXTRADING_RESPONSE_COMPANY_SYMBOL_TAG] as? String,
                let price = json[Constants.IEXTRADING_RESPONSE_COMPANY_PRICE_TAG] as? Double,
                let priceChange = json[Constants.IEXTRADING_RESPONSE_COMPANY_PRICE_CHANGE_TAG] as? Double
                else {
                    print("An error has occured while trying to parse JSON: format doesn't match the one you've required.")
                    return
                }
            self.companyName = companyName
            self.companySymbol = companySymbol
            self.companyPrice = price
            self.priceChange = priceChange

        } catch {
            print("An error has occured while serializing JSON object: " + error.localizedDescription)
            return
        }
    }
}
