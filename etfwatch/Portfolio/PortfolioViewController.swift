//
//  PortfolioViewController.swift
//  etfwatch
//
//  Created by Aydin Tekin on 05.04.21.
//

import Cocoa
import Charts

class PortfolioViewController: NSViewController {
    @IBOutlet weak var tableView: NSTableView!
    var portfolio: [PortfolioElement] = []
    var popOver : NSPopover!
    var delegate : MainAppDelegate?
    var preferences = Preferences()
    var portfolioElementController: PortfolioElementController!
    var preferencesWindowController: PreferencesWindowController!
    @IBOutlet weak var chtChart: LineChartView!
    @IBOutlet weak var btnPreferences: NSButton!
    @IBOutlet weak var btnAddElement: NSPopUpButton!
    
    weak var axisFormatDelegate: IAxisValueFormatter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        axisFormatDelegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        portfolioElementController = createPortfolioElementWindow()
        preferencesWindowController = createPreferencesWindow()
        
        resetSize()
    }
    
    func createPortfolioElementWindow() -> PortfolioElementController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("PortfolioElementController")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? PortfolioElementController else {
          fatalError("Why cant i find PortfolioViewController? - Check Main.storyboard")
        }
        let controller = viewcontroller.window!.contentViewController as! PortfolioElementViewController
        controller.delegate = delegate
        controller.window = viewcontroller
        return viewcontroller
    }
    
    func createPreferencesWindow() -> PreferencesWindowController {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("PreferencesWindowController")
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? PreferencesWindowController else {
          fatalError("Why cant i find PortfolioViewController? - Check Main.storyboard")
        }
        let controller = viewcontroller.window!.contentViewController as! PreferencesViewController
        controller.delegate = delegate
        return viewcontroller
    }
    
    @IBAction func onShowPreferences(_ sender: Any) {
        preferencesWindowController.showWindow(self)
    }
  
    @IBAction func onAddLuSSecurity(_ sender: Any) {
        portfolioElementController.showWindow(self)
    }
    
    @IBAction func onEditPortfolioElement(_ sender: Any) {
        let selectedRow = tableView.selectedRow
        if (selectedRow < 0) {
            return
        }
        
        let pElement = portfolio[tableView.selectedRow]
        if (pElement.instrumentId < 0) {
            return
        }
        
        portfolioElementController.modifyElement(sender: sender, elem: pElement)
    }
    
    @IBAction func onShowGraph(_ sender: Any) {
        let pElement = portfolio[tableView.clickedRow]
        if (pElement.instrumentId < 0) {
            return
        }
        
        setupGraph(portfolioElement: pElement)
        showGraph()
    }
    
    func resetSize() {
        self.preferredContentSize = NSSize(width: 666, height: 296)
        //self.view.frame = CGRect(x: 0, y: 0, width: 666, height: 285)
    }
    
    func showGraph() {
        self.preferredContentSize = NSSize(width: 666, height: 457)
        //self.view.frame = CGRect(x: 0, y: 0, width: 666, height: 448)
    }
    
    func setupGraph(portfolioElement: PortfolioElement) {
        chtChart.legend.enabled = false
        chtChart.drawBordersEnabled = false
        chtChart.borderColor = NSColor.systemPink
        chtChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        chtChart.xAxis.labelTextColor = NSUIColor.systemGray
        chtChart.leftAxis.labelTextColor = NSUIColor.systemGray
        chtChart.rightAxis.enabled = false
        chtChart.doubleTapToZoomEnabled = false
        
        let marker = ChartMarker()
        marker.chartView = chtChart
        chtChart.marker = marker

        
        
        var lineChartEntry = [ChartDataEntry]()
        
        for d in portfolioElement.intraDay {
            let tmpVal = ChartDataEntry(x: d[0], y: d[1] * portfolioElement.count)
            lineChartEntry.append(tmpVal)
        }

        let line1 = LineChartDataSet(entries: lineChartEntry, label : "LEL")
        line1.colors = [NSUIColor.systemGreen]
        line1.drawCirclesEnabled = false
        line1.drawFilledEnabled = true
        line1.fillColor = NSColor.systemGreen
        line1.drawValuesEnabled = false
        
        
        let data = LineChartData()
        data.addDataSet(line1)
        
        let xaxis = chtChart.xAxis
        xaxis.valueFormatter = axisFormatDelegate
        
        chtChart.data = data
    }
    
    func setModel(portfolio: [PortfolioElement]) {
        self.portfolio = portfolio

        if (tableView != nil) {
            tableView.reloadData()
        }
    }
    
    @IBAction func onAddPortfolioElement(_ sender: Any) {
        portfolioElementController.showWindow(self)
    }
    
    @IBAction func onDeletePortfolioElement(_ sender: Any) {
        let selectedRow = tableView.selectedRow
        if (selectedRow < 0) {
            return
        }
        
        let pElement = portfolio[tableView.selectedRow]
        if (pElement.instrumentId < 0) {
            return
        }
        
        do {
            try preferences.deletePortfolioElementFromPreferences(elem: pElement)
            delegate?.preferencesDidUpdate()
        } catch {
            print("error")
        }
    }
    
    @IBAction func onQuitApp(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
}

extension PortfolioViewController: IAxisValueFormatter {
  
  func stringForValue(_ value: Double, axis: AxisBase?) -> String {
    let dateFormatter = DateFormatter()
    let newValue = value / 1000
    dateFormatter.dateFormat = "HH:mm"
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    return dateFormatter.string(from: Date(timeIntervalSince1970: newValue))
  }
}

extension PortfolioViewController {
    static func freshController(popOver: NSPopover) -> PortfolioViewController {
    let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
    let identifier = NSStoryboard.SceneIdentifier("PortfolioViewController")
    guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? PortfolioViewController else {
      fatalError("Why cant i find PortfolioViewController? - Check Main.storyboard")
    }
    viewcontroller.popOver = popOver
    return viewcontroller
  }
}

extension PortfolioViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return portfolio.count
    }
}

extension PortfolioViewController: NSTableViewDelegate {
    
    func setCellAlignment(userCell : CustomPortfolioTableCell) {
        userCell.lblTotal.alignment = .right
        userCell.lblTotalGain.alignment = .right
        userCell.lblAmount.alignment = .right
        userCell.lblPricePerUnit.alignment = .right
        userCell.lblPercentGain.alignment = .right
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let currentPortfolioElement = portfolio[row]
        guard let userCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "userCell"), owner: self) as? CustomPortfolioTableCell else { return nil }
                
        let fontSize = NSFont.systemFontSize
        if (currentPortfolioElement.instrumentId == -1) {
            userCell.lblTitle.font = NSFont.boldSystemFont(ofSize: fontSize)
        } else {
            userCell.lblTitle.font = NSFont.systemFont(ofSize: fontSize)
        }
        
        userCell.lblTitle.stringValue = currentPortfolioElement.name ?? "-"
        
        setCellAlignment(userCell: userCell)
        
        if (currentPortfolioElement.instrumentId == -1) {
            userCell.lblAmount.stringValue = ""
            userCell.lblPricePerUnit.stringValue = ""
            userCell.lblTotal.frame = CGRect(x: 496, y: 11, width: 115 , height: 16)
        } else {
            userCell.lblAmount.stringValue = String(currentPortfolioElement.count)
            userCell.lblPricePerUnit.stringValue = PortfolioUtil.getFormattedEuroPrice(price: currentPortfolioElement.resultData.latestPrice)
            userCell.lblTotal.frame = CGRect(x: 496, y: 19, width: 115 , height: 16)
        }
        
        
        let priceString = (currentPortfolioElement.instrumentId == -1 ? PortfolioUtil.getFormattedEuroPrice(price: currentPortfolioElement.resultData.latestPrice) : PortfolioUtil.getFormattedEuroPrice(price: currentPortfolioElement.resultData.latestPrice * currentPortfolioElement.count))
        userCell.lblTotal.stringValue = priceString
        
        let diffPercent =  (1 - (currentPortfolioElement.resultData.oldestPrice / currentPortfolioElement.resultData.latestPrice)) * 100
        var percentString = String(format: "%.2f", diffPercent)
        percentString = (diffPercent < 0 ? "" + percentString + "%"  : "+" + percentString + "%")
        userCell.lblPercentGain.stringValue = percentString
        
        var diffPrice = currentPortfolioElement.resultData.latestPrice - currentPortfolioElement.resultData.oldestPrice
        if (currentPortfolioElement.instrumentId == -1) {
            diffPrice = 1 * diffPrice
        } else {
            diffPrice = currentPortfolioElement.count * diffPrice
        }
        userCell.lblTotalGain.stringValue = PortfolioUtil.getFormattedEuroPrice(price: diffPrice)
        
        
        //userCell.roleLabel.stringValue = users[row]["role"] ?? "unknown role"
        if (currentPortfolioElement.resultData.latestPrice >= currentPortfolioElement.resultData.oldestPrice) {
            userCell.lblPercentGain.textColor = NSColor.systemGreen
            userCell.lblTotalGain.textColor = NSColor.systemGreen
        } else {
            userCell.lblPercentGain.textColor = NSColor.systemRed
            userCell.lblTotalGain.textColor = NSColor.systemRed
        }
        
        return userCell
        
        /*
        let currentPortfolioElement = portfolio[row]
        guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else { return nil }
        if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "nameColumn") {
            let fontSize = NSFont.systemFontSize
            if (currentPortfolioElement.instrumentId == -1) {
                cell.textField?.font = NSFont.boldSystemFont(ofSize: fontSize)
            } else {
                cell.textField?.font = NSFont.systemFont(ofSize: fontSize)
            }
            cell.textField?.stringValue = currentPortfolioElement.name ?? "-"
        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "amountColumn") {
            if (currentPortfolioElement.instrumentId == -1) {
                cell.textField?.stringValue = ""
            } else {
                cell.textField?.stringValue = String(currentPortfolioElement.count)
            }
        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "priceColumn") {
            if (currentPortfolioElement.instrumentId == -1) {
                cell.textField?.stringValue = ""
            } else {
                cell.textField?.stringValue = PortfolioUtil.getFormattedEuroPrice(price: currentPortfolioElement.resultData.latestPrice)
            }
        } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "totalColumn") {
            let diffPercent =  (1 - (currentPortfolioElement.resultData.oldestPrice / currentPortfolioElement.resultData.latestPrice)) * 100
            let priceString = (currentPortfolioElement.instrumentId == -1 ? PortfolioUtil.getFormattedEuroPrice(price: currentPortfolioElement.resultData.latestPrice) : PortfolioUtil.getFormattedEuroPrice(price: currentPortfolioElement.resultData.latestPrice * currentPortfolioElement.count))
            var percentString = String(format: "%.2f", diffPercent)
            percentString = (diffPercent < 0 ? "(" + percentString + "%)"  : "(+" + percentString + "%)")

            if (currentPortfolioElement.resultData.latestPrice >= currentPortfolioElement.resultData.oldestPrice) {
                cell.textField?.textColor = NSColor.systemGreen
            } else {
                cell.textField?.textColor = NSColor.systemRed
            }
            
            let fontSize = NSFont.systemFontSize
            if (currentPortfolioElement.instrumentId == -1) {
                cell.textField?.font = NSFont.boldSystemFont(ofSize: fontSize)
                cell.textField?.stringValue = priceString + " " + percentString
            } else {
                cell.textField?.font = NSFont.systemFont(ofSize: fontSize)
                cell.textField?.stringValue = priceString + " " + percentString
            }
        }
        return cell*/
    }
}
