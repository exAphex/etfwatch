//
//  AppDelegate.swift
//  etfwatch
//
//  Created by Aydin Tekin on 31.03.21.
//

import Cocoa
import SwiftUI
import UserNotifications

let VERSION = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String

protocol MainAppDelegate {
    func preferencesDidUpdate()
}

@main
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate, MainAppDelegate {

    var popover: NSPopover!
    var portfolioViewController: PortfolioViewController!
    var statusBarItem: NSStatusItem!
    var portfolio: [PortfolioElement] = []
    var timer: Timer? = nil
    var preferences = Preferences()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupNotifications()
        
        preparePopover()
        prepareStatusItem()
        
        let portfolio = preferences.loadPortfolioFromPreferences()
        setPortfolio(portfolioElements: portfolio)
        createTimer()
        
        checkUpdate()
    }
    
    func preparePopover() {
        let popover = NSPopover()
        let viewController = PortfolioViewController.freshController(popOver: popover)
        viewController.delegate = self
        popover.behavior = .transient
        popover.contentViewController = viewController
        self.popover = popover
        self.portfolioViewController = viewController
    }
    
    func checkUpdate() {
        let updater = Updater(version:VERSION)
        updater.checkUpdate(callback:{(version) in
            DispatchQueue.main.async {
                Updater.notification(title:"New version available!", subtitle:"Version: " + version, tag:"")
            }
            
        })
    }
    
    func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (permissionGranted, error) in
                }

        let etfWatchCategory = UNNotificationCategory(identifier: "etfwatchCategory", actions: [], intentIdentifiers: [], options: [])

        UNUserNotificationCenter.current().setNotificationCategories([etfWatchCategory])
        UNUserNotificationCenter.current().delegate = self
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
        
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let strURL = "https://github.com/exAphex/etfwatch/releases"
        let url = URL(string: strURL)!
        NSWorkspace.shared.open(url)
    }
    
    func prepareStatusItem() {
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        if let button = self.statusBarItem.button {
            button.action = #selector(togglePopover(_:))
        }
    }
    
    func setPortfolio(portfolioElements: [PortfolioElement]) {
        self.portfolio = portfolioElements
    }
    
    func createTimer() {
        if (timer != nil) {
            timer!.invalidate()
            timer = nil
        }

        let refreshRateInt = 60
        
        getPortfolioData()

        timer = Timer.scheduledTimer(withTimeInterval: Double(refreshRateInt), repeats: true) { timer in
            self.getPortfolioData()
        }
    }
    
    func getPortfolioData() {
        let portfolioData = PortfolioUtil.injectTotalValue(portfolio: PortfolioUtil.getPortfolioData(portfolio: self.portfolio))
        self.setTitle(portfolioData: portfolioData)
        self.portfolioViewController.setModel(portfolio: portfolioData)
    }
    
    func setTitle(portfolioData : [PortfolioElement]) {
        if let button = self.statusBarItem.button {
            var latestTotalPrice : Float64 = 0
            var oldestTotalPrice : Float64 = 0
            for p in portfolioData {
                latestTotalPrice += p.resultData.latestPrice * p.count
                oldestTotalPrice += p.resultData.oldestPrice * p.count
            }
            let diffPercent : Float64 = ((latestTotalPrice > 0) ? ((1 - (oldestTotalPrice / latestTotalPrice)) * 100) : 0)
            let diffPrice = (latestTotalPrice - oldestTotalPrice)
            let strDiffPrice = (diffPrice < 0 ? "(" + PortfolioUtil.getFormattedEuroPrice(price: (latestTotalPrice - oldestTotalPrice)) + ")" : "(+" + PortfolioUtil.getFormattedEuroPrice(price: diffPrice) + ")")
            let priceString = PortfolioUtil.getFormattedEuroPrice(price: latestTotalPrice)
            var percentString = String(format: "%.2f", diffPercent)
            percentString = (diffPercent < 0 ? "(" + percentString + "%)"  : "(+" + percentString + "%)")
            let statusString = (diffPercent < 0 ? "🔴" : "🟢")
            
            var strFinalTitle = priceString
            if (preferences.getBoolValue(key: "showPercentInTitle")) {
                strFinalTitle += " " + percentString
            }
            if (preferences.getBoolValue(key: "showNetGainInTitle")) {
                strFinalTitle += " " + strDiffPrice
            }
            if (preferences.getBoolValue(key: "showIndicatorInTitle")) {
                strFinalTitle += " " + statusString
            }
            button.title = strFinalTitle
        }
    }
    
    func preferencesDidUpdate() {
        let portfolio = preferences.loadPortfolioFromPreferences()
        setPortfolio(portfolioElements: portfolio)
        createTimer()
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func showPopover(sender: Any?) {
      if let button = statusBarItem.button {
        portfolioViewController.resetSize()
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
      }
    }

    func closePopover(sender: Any?) {
      popover.performClose(sender)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

