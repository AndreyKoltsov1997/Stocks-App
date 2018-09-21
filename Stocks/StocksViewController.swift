//
//  ViewController.swift
//  Stocks
//
//  Created by Andrey Koltsov on 11/09/2018.
//  Copyright © 2018 Polytechnic University. All rights reserved.
//

import UIKit

//MARKL Protocol for delegating data from the server into UI

class StocksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, StocksDelegate {
    
    
    // UI-related properties
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var companyListActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var companyLogoImageView: UIImageView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var companySymbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!


    @IBOutlet weak var companiesSearchBar: UISearchBar!

    @IBOutlet weak var companiesTableView: UITableView!
    
    // NOTE: Tag-labels are used for moving it down when tableView expands
    @IBOutlet weak var companyNameTagLabel: UILabel!
    @IBOutlet weak var symbolTagLabel: UILabel!

    
    // UI non-related properties

    
    private var stocksModel = StocksModel()
    
        // NOTE: the variable hasViewLoaded prevents accessing table view before it was loaded
    private var hasViewLoaded = false
    
    private var companiesContainer = [String:String]()
    private var currentDisplayingCompanies = [String:String]()
    private var isKeyboardShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.companyListActivityIndicator.startAnimating()
        stocksModel.delegate = self
    }
    
    // NOTE: Disabling switching into landscape mode
    override open var shouldAutorotate: Bool {
        return false
    }
    private func configureUI() {
        setUpCompaniesTableView()
        self.activityIndicator.hidesWhenStopped = true
        self.companyListActivityIndicator.hidesWhenStopped = true
        
        companyNameLabel.numberOfLines = 1;
        companyNameLabel.adjustsFontSizeToFitWidth = true
    }
    
    private func setUpCompaniesSearchBar() {
        self.companiesSearchBar.delegate = self
    }
    
    private func setUpCompaniesTableView() {
        self.companiesTableView.dataSource = self
        self.companiesTableView.delegate = self
        
        // NOTE: configuring seach bar element
        self.companiesTableView.tableHeaderView = UIView()
        self.companiesTableView.estimatedSectionHeaderHeight = Constants.COMPANY_SEARCH_BAR_ESTIMATED_HEIGHT
        navigationItem.titleView = companiesSearchBar
        companiesSearchBar.showsScopeBar = false
        companiesSearchBar.placeholder = Constants.COMPANY_SEARCH_BAR_PLACEHOLDER
        setUpCompaniesSearchBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return Constants.AMOUNT_OF_COMPONENTS_IN_COMPANY_PICKER_VIEW;
    }
    
    
    // MARK: - Table view methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = Array(self.currentDisplayingCompanies.values)[indexPath.row]
        print("Array(self.currentDisplayingCompanies.values)[indexPath.row]" + Array(self.currentDisplayingCompanies.values)[indexPath.row])
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isKeyboardShown {
            processSearchBarUserIntefaction()
            self.companiesSearchBar.endEditing(true)
            let selectedCompany = Array(self.currentDisplayingCompanies)[indexPath.row].value
            self.companiesSearchBar.text = selectedCompany
        }
        
        if (self.companiesSearchBar.text != Constants.COMPANY_SEARCH_BAR_PLACEHOLDER) {
            self.companiesSearchBar.placeholder = Constants.COMPANY_SEARCH_BAR_PLACEHOLDER
        }
        requestQuoteUpdate(for: indexPath.row)
        
        if (companiesContainer.values.count != currentDisplayingCompanies.values.count) {
            currentDisplayingCompanies = companiesContainer
            companiesTableView.reloadData()
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.companiesSearchBar
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentDisplayingCompanies.keys.count;
    }
    

    // MARK: -Search bar methods
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            currentDisplayingCompanies = companiesContainer
            companiesTableView.reloadData()
            return }
        currentDisplayingCompanies = companiesContainer.filter({ companyInfo -> Bool in
            let enteredSearchingText = searchText.lowercased()
            return companyInfo.value.lowercased().contains(enteredSearchingText)
        })
        companiesTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        companiesSearchBar.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if !self.hasViewLoaded {
            self.companiesSearchBar.endEditing(true)
            return
        }
        self.isKeyboardShown = true
        processSearchBarUserIntefaction()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.isKeyboardShown = false
        processSearchBarUserIntefaction()
    }
    
    private func processSearchBarUserIntefaction() {
        var offset = CGFloat(0.0)
        if self.isKeyboardShown {
            // NOTE: Expanding tableView and moving stock info downwards in order to get space for expanded table view
            offset = getOffsetForExpandedTableView()
        } else {
            // NOTE: Moving view back to normal position
            offset = (-1) * getOffsetForExpandedTableView()
        }
        moveView(self.companiesTableView, 0, 0, offset, additionalWidth: 0)
        moveView(self.companyLogoImageView, 0, offset, 0, additionalWidth: 0)
        
        moveView(self.companyNameTagLabel, 0, 0, offset, additionalWidth: 0)
        moveView(self.symbolTagLabel, 0, offset, 0, additionalWidth: 0)
        
        moveView(self.companyNameLabel, 0, offset, 0, additionalWidth: 0)
        moveView(self.companySymbolLabel, 0, offset, 0, additionalWidth: 0)

    }
    
    private func getOffsetForExpandedTableView() -> CGFloat {
        return self.view.frame.height * Constants.PERCENTAGE_OF_SCREEN_FOR_TABLE_VIEW_EXPANDING
    }
    
    // MARK:- Private Methods
    
    private func resetViewsWhenNetworkDisabled() {
        let outOfScreenOffset = self.view.frame.height
        moveView(self.companiesTableView, 0, outOfScreenOffset, 0, additionalWidth: 0)
        
        let errorImage = UIImage(named: Constants.DEFAULT_ERROR_IMAGE_NAME)
        self.companyLogoImageView.image = errorImage
        
        
        let offsetToTheTop = self.view.frame.height - self.companyLogoImageView.frame.height
        moveView(self.companyLogoImageView, 0, offsetToTheTop, 0, additionalWidth: 0)
        
        // NOTE: Changing values of label's text
        self.companyNameLabel.text = Constants.DEFAULT_VALUE_FOR_LABEL_IF_ERROR
        self.companySymbolLabel.text = Constants.DEFAULT_VALUE_FOR_LABEL_IF_ERROR
        self.priceLabel.text = Constants.DEFAULT_VALUE_FOR_LABEL_IF_ERROR
        self.priceChangeLabel.text = Constants.DEFAULT_VALUE_FOR_LABEL_IF_ERROR
        
        // NOTE: Changing color of Labels
        self.companyNameLabel.textColor = Constants.DEFAULT_TEXT_COLOR_IF_ERROR
        self.companySymbolLabel.textColor = Constants.DEFAULT_TEXT_COLOR_IF_ERROR
        self.priceLabel.textColor = Constants.DEFAULT_TEXT_COLOR_IF_ERROR
        self.priceChangeLabel.textColor = Constants.DEFAULT_TEXT_COLOR_IF_ERROR
    }
    
    private func moveView(_ view: UIView, _ xOffset: CGFloat, _ yOffset: CGFloat, _ additionalHeight: CGFloat,
                          additionalWidth: CGFloat) {
        UIView.animate(withDuration: 0.3, animations: {
            view.frame = CGRect(x:view.frame.origin.x + xOffset, y: view.frame.origin.y + yOffset, width: view.frame.size.width + additionalWidth, height: view.frame.size.height + additionalHeight);
        })
    }
    
    
    
    private func getRequiredTextColor(for priceChange: Double) -> UIColor {
        var matchingColor = Constants.DEFAULT_TEXT_COLOR_FOR_PRICE_CHANGE
        if (priceChange < 0.0) {
            matchingColor = UIColor.red
        } else if (priceChange > 0.0) {
            matchingColor = UIColor.green
        }
        return matchingColor
    }
    
    
    private func requestQuoteUpdate(for cellNumber: Int) {
        self.activityIndicator.startAnimating()
        let selectedSymbol = Array(self.currentDisplayingCompanies)[cellNumber].key
        stocksModel.requestQuote(for: selectedSymbol)
    }
    

    // MARK: - StockDelegate methods
    
     func addListOfCompanies(fetchedList list: [String : String]) {
        self.companiesContainer = list
        self.currentDisplayingCompanies = list
        DispatchQueue.main.async {
            self.companiesTableView.reloadData()
            self.companyListActivityIndicator.stopAnimating()
            let initialCellNumber = 0
            self.requestQuoteUpdate(for: initialCellNumber)
            self.hasViewLoaded = true
            
        }
    }
    
     func showNetworkErrorAlert(withMessage message:String) {
        let alert = UIAlertController(title: Constants.ERROR_GENERAL_TITLE, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Constants.ERROR_DISMISS_TITLE, style: .default, handler: nil))
        self.present(alert, animated: true)
        resetViewsWhenNetworkDisabled()
    }
    
     func displayStockInfo(forStock stock:Stock) {
        self.activityIndicator.stopAnimating()
        self.companyListActivityIndicator.stopAnimating()
        self.companyNameLabel.text = stock.companyName
        self.companySymbolLabel.text = stock.companySymbol
        self.priceLabel.text = "\(stock.companyPrice)" + Constants.BASIC_DELIMITER + Constants.DOLLAR_CURRENCY_TAG
        self.priceChangeLabel.text = "\(stock.priceChange)" + Constants.BASIC_DELIMITER + Constants.DOLLAR_CURRENCY_TAG
        self.priceChangeLabel.textColor = getRequiredTextColor(for: stock.priceChange)
        
        if let url = stocksModel.getLogoURL(for: stock) {
            self.companyLogoImageView.loadImageFromURL(url: url)
        } else {
            self.companyLogoImageView = nil
        }
    }
}

extension UIImageView {
    func loadImageFromURL(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
