//
//  PortfolioElementViewController.swift
//  etfwatch
//
//  Created by Aydin Tekin on 07.04.21.
//

import Cocoa

class PortfolioElementViewController: NSViewController {

    @IBOutlet weak var btnSave: NSButton!
    @IBOutlet weak var txtAmount: NSTextField!
    @IBOutlet weak var txtPrice: NSTextField!
    @IBOutlet weak var txtName: NSTextField!
    @IBOutlet weak var searchButton: NSButton!
    @IBOutlet weak var txtISIN: NSTextField!
    var currentInstrumentId : Int = -1
    var delegate : MainAppDelegate?
    var preferences = Preferences()
    var window : PortfolioElementController?
    var isEdit = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func clearAll() {
        disableUIElements()
    }
    
    func disableUIElements() {
        self.isEdit = false
        self.currentInstrumentId = -1
        
        self.txtISIN.isEnabled = true
        self.txtISIN.stringValue = ""
        
        self.txtAmount.isEnabled = false
        self.txtAmount.stringValue = "0.0"
        
        self.btnSave.isEnabled = false
        self.searchButton.isEnabled = true
        
        self.txtName.stringValue = ""
        self.txtName.isEnabled = false
        
        self.txtPrice.isEnabled = false
        self.txtPrice.stringValue = ""
        
    }
    
    func modifyElement(elem : PortfolioElement) {
        self.isEdit = true
        self.currentInstrumentId = elem.instrumentId
        
        self.txtISIN.isEnabled = false
        self.txtISIN.stringValue = ""
        
        self.btnSave.isEnabled = true
        self.searchButton.isEnabled = false
        
        self.txtPrice.isEnabled = false
        self.txtPrice.stringValue = PortfolioUtil.getFormattedEuroPrice(price: elem.resultData.latestPrice)
        
        self.txtAmount.isEnabled = true
        self.txtAmount.stringValue = String(elem.count)
        
        self.txtName.isEnabled = true
        self.txtName.stringValue = elem.name!
    }
    
    @IBAction func onSave(_ sender: Any) {
        let strAmount = self.txtAmount.stringValue
        let strName = self.txtName.stringValue
        if currentInstrumentId < 0 {
            showAlert(message: "Error saving information", informativeText: "ISIN could not be resolved. Please try again")
        }
        
        if let amount = Float64(strAmount) {
            do {
                if (isEdit) {
                    try preferences.modifyPortfolioFromPreferences(elem: PortfolioElement(name : strName, instrumentId : currentInstrumentId, count : amount))
                } else {
                    try preferences.addPortfolioFromPreferences(elem: PortfolioElement(name : strName, instrumentId : currentInstrumentId, count : amount))
                }
                delegate?.preferencesDidUpdate()
                self.window?.close()
            } catch PreferenceError.alreadyInPortfolio {
                showAlert(message: "Error saving information", informativeText: "Element is already in the portfolio. Please use the edit element functionality to change the amount of existing portfolio elements!")
            } catch {
                showAlert(message: "Error saving information", informativeText: error.localizedDescription)
            }
        } else {
            showAlert(message: "Error saving information", informativeText: "Amount is not a valid number. Please use a pattern like this: 10.201")
        }
        
    }
    
    @IBAction func onSearch(_ sender: Any) {
        let isin = txtISIN.stringValue
        self.disableUIElements()
        
        if (isin.isEmpty) {
            return
        }
        
        HTTPUtil.getSearch(strURL: "https://www.ls-tc.de/_rpc/json/.lstc/instrument/search/main?q=" + isin + "&localeId=2") { (data, response, error) in
            self.handleSearchISIN(data: data, response: response, error: error)
        }
    }
    
    func handleSearchISIN(data: Data?, response: URLResponse?, error: Error?) {
        if (error != nil) {
            showAlert(message: "Error retrieving information", informativeText: error!.localizedDescription)
            return
        }
        
        guard let data = data else {
            showAlert(message: "Error retrieving information", informativeText: "No data received!")
            return
        }
        do {
            let jsonDecoder = JSONDecoder()
            let json = try jsonDecoder.decode([Position].self, from: data)
            if (json.count == 1) {
                self.currentInstrumentId = json[0].instrumentId
                DispatchQueue.main.async {
                    self.txtAmount.isEnabled = true
                    self.btnSave.isEnabled = true
                    self.txtName.isEnabled = true
                    self.txtName.stringValue = json[0].displayname!
                }
                HTTPUtil.getSearch(strURL: "https://www.ls-tc.de/_rpc/json/instrument/chart/dataForInstrument?container=chart1&instrumentId=" + String(self.currentInstrumentId) + "&marketId=1&quotetype=mid&series=intraday&type=&localeId=2") { (data, response, error) in
                    self.handleSearchInstrument(data: data, response: response, error: error)
                }
                return
            } else if (json.count > 1) {
                DispatchQueue.main.async {
                    self.disableUIElements()
                }
                showAlert(message: "Multiple elements found!", informativeText: "Please check given ISIN!")
            } else {
                DispatchQueue.main.async {
                    self.disableUIElements()
                }
                showAlert(message: "No element found!", informativeText: "Please check given ISIN!")
            }
        } catch {
            showAlert(message: "JSONSerialization error", informativeText: error.localizedDescription)
        }
    }
    
    func showAlert(message : String, informativeText: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = message
            alert.informativeText = informativeText
            alert.alertStyle = .critical
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    func handleSearchInstrument(data: Data?, response: URLResponse?, error: Error?) {
        if (error != nil) {
            showAlert(message: "Error retrieving information", informativeText: error!.localizedDescription)
            return
        }
        guard let data = data else {
            showAlert(message: "Error retrieving information", informativeText: "No data received!")
            return
        }
        
        do {
            let jsonDecoder = JSONDecoder()
            let json = try jsonDecoder.decode(HistoricDataStruct.self, from: data)
            let sortedTimeline = json.series.intraday.data.sorted {
                $0[0] > $1[0]
            }
            if (sortedTimeline.count > 0) {
                let elemPrice = sortedTimeline[0][1]
                DispatchQueue.main.async {
                    self.txtPrice.stringValue = PortfolioUtil.getFormattedEuroPrice(price: elemPrice)
                }
            }
        } catch {
            showAlert(message: "JSONSerialization error", informativeText: error.localizedDescription)
        }
    }
}
