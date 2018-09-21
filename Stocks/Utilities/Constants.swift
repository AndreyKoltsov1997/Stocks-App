//
//  Constants.swift
//  Stocks
//
//  Created by Andrey Koltsov on 12/09/2018.
//  Copyright © 2018 Polytechnic University. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    
    // MARK: - Server-related constants
    static let IEXTRADING_SERVER_BASE_URL = "https://api.iextrading.com/1.0/"
    static let IEXTRADING_LIST_OF_COMPANIES_REQUEST = "stock/market/list/infocus"
    

    static let DEFAULT_VALUE_FOR_LABEL_IF_ERROR = "NOT AVALIABLE"
    static let DEFAULT_TEXT_COLOR_IF_ERROR = UIColor.red
    static let DEFAULT_ERROR_IMAGE_NAME = "ErrorImage"

    
    static let IEXTRADING_RESPONSE_COMPANY_NAME_TAG = "companyName"
    static let IEXTRADING_RESPONSE_COMPANY_SYMBOL_TAG = "symbol"
    static let IEXTRADING_RESPONSE_COMPANY_PRICE_TAG = "latestPrice"
    static let IEXTRADING_RESPONSE_COMPANY_PRICE_CHANGE_TAG = "change"
    
    
    static let IEXTRADING_SERVER_BASE_URL_FOR_IMAGE = "https://storage.googleapis.com/iex/api/logos/"
    static let IEXTRADING_SERVER_DEFAULT_IMAGE_EXTENSION = ".png"
    
    //  MARK: - UI-related constants
    static let BASIC_DELIMITER = " "
    static let DEFAULT_TEXT_COLOR_FOR_PRICE_CHANGE = UIColor.black
    static let DEFAULT_VALUE_IF_COMPANY_NOT_FOUND = ""
    static let AMOUNT_OF_COMPONENTS_IN_COMPANY_PICKER_VIEW = 1;
        // Search bar
    static let COMPANY_SEARCH_BAR_PLACEHOLDER = "Search company by name.."
    static let COMPANY_SEARCH_BAR_ESTIMATED_HEIGHT = CGFloat(50)
        // Error alert
    static let ERROR_GENERAL_TITLE = "An error has occured"
    static let ERROR_DISMISS_TITLE = "Dismiss"
        // Displaying price
    static let DOLLAR_CURRENCY_TAG = "$"
    
    static let PERCENTAGE_OF_SCREEN_FOR_TABLE_VIEW_EXPANDING = CGFloat(0.25)

}
