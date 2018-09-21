//
//  StocksModel.swift
//  Stocks
//
//  Created by Andrey Koltsov on 12/09/2018.
//  Copyright © 2018 Polytechnic University. All rights reserved.
//

import Foundation

protocol StocksDelegate: class {
    func addListOfCompanies(fetchedList list:[String:String])
    func showNetworkErrorAlert(withMessage message:String)
    func displayStockInfo(forStock stock:Stock)
}


class StocksModel {
    
    public weak var delegate: StocksDelegate?
    
    init() {
        self.checkNetworkConnection()
        self.getListOfCompanies()
        
    }
    
    private func checkNetworkConnection() {
        if (!NetworkAcessChecker.isConnectedToNetwork()) {
            let misleadingMsg = "Network is not enabled."
            self.delegate?.showNetworkErrorAlert(withMessage: misleadingMsg)
            print(misleadingMsg)
        }
    }
    
    private func getListOfCompanies() {
        let urlForListOfCompanies = Constants.IEXTRADING_SERVER_BASE_URL + Constants.IEXTRADING_LIST_OF_COMPANIES_REQUEST
        guard let url = URL(string: urlForListOfCompanies) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                let misleadingMsg = "Couldn't fetch list of companies."
                self.delegate?.showNetworkErrorAlert(withMessage: misleadingMsg)
                print(misleadingMsg + error!.localizedDescription)
            }
            guard let data = data else {
                let misleadingMessage = "List of companies hasn't been found."
                self.delegate?.showNetworkErrorAlert(withMessage: misleadingMessage)
                let METHOD_TAG = "Stocks.getListOfCompanies: "
                print(METHOD_TAG + misleadingMessage)
                return
            }
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String:Any]] else { return }
                var companiesContainer = [String:String]()
                for companyInfo in json {
                    let currentName = companyInfo[Constants.IEXTRADING_RESPONSE_COMPANY_NAME_TAG] as? String ?? Constants.DEFAULT_VALUE_IF_COMPANY_NOT_FOUND
                    let currentTag = companyInfo[Constants.IEXTRADING_RESPONSE_COMPANY_SYMBOL_TAG] as? String ?? Constants.DEFAULT_VALUE_IF_COMPANY_NOT_FOUND
                    print("secotr: \(companyInfo["sector"])" )
                    companiesContainer.updateValue(currentName, forKey: currentTag)
                }
                self.delegate?.addListOfCompanies(fetchedList: companiesContainer)
            } catch {
                let misleadingMessage = "Couldn't process server response."
                self.delegate?.showNetworkErrorAlert(withMessage: misleadingMessage)
                let METHOD_TAG = "Stocks.getListOfCompanies: "
                print(METHOD_TAG + misleadingMessage + error.localizedDescription)
            }
        }.resume()
    }
    
    public func requestQuote(for symbol: String) {
        let url = URL(string: Constants.IEXTRADING_SERVER_BASE_URL + "stock/\(symbol)/quote")!
        
        let dataTask = URLSession.shared.dataTask(with: url) {
            data, response, error in
            guard error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
                else {
                    let METHOD_TAG = "StocksViewController.requestQuote: "
                    if (response as? HTTPURLResponse)?.statusCode == 404 {
                        let misleadingMessage = "Incorrect URL: Page couldn't be found";
                        print(METHOD_TAG + misleadingMessage + "for \(url)")
                        self.delegate?.showNetworkErrorAlert(withMessage: misleadingMessage)
                    } else {
                        let misleadingMessage = "An error has occured while trying to get an HTTP response from the server."
                        self.delegate?.showNetworkErrorAlert(withMessage: misleadingMessage)
                        print(METHOD_TAG + "An error has occured while trying to get an HTTP response from the server.")
                    }
                    return
            }
            DispatchQueue.main.async {
                let processingStock = Stock(data: data)
                self.delegate?.displayStockInfo(forStock: processingStock)
            }
        }
        dataTask.resume();
    }
    
    public func getLogoURL(for stock: Stock) -> URL? {
        if let url = URL(string: Constants.IEXTRADING_SERVER_BASE_URL_FOR_IMAGE + stock.companySymbol + Constants.IEXTRADING_SERVER_DEFAULT_IMAGE_EXTENSION) {
            return url
        } else {
            let misleadingMessage = "URL for" + stock.companySymbol + "is not valid."
            print("StockModel.getLogoURL: " + misleadingMessage)
            return nil
        }
    }
    
}
