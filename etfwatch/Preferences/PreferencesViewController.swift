//
//  PreferencesViewController.swift
//  etfwatch
//
//  Created by Aydin Tekin on 15.04.21.
//

import Cocoa

class PreferencesViewController: NSViewController {
    @IBOutlet weak var chbShowPercentage: NSButton!
    @IBOutlet weak var chbShowNetGain: NSButton!
    @IBOutlet weak var chbShowIndicator: NSButton!
    var delegate : MainAppDelegate?
    let preferences = Preferences()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func loadPreferences() {
        chbShowPercentage.state = (preferences.getBoolValue(key: "showPercentInTitle") ?  NSControl.StateValue.on : NSControl.StateValue.off)
        chbShowNetGain.state = (preferences.getBoolValue(key: "showNetGainInTitle") ?  NSControl.StateValue.on : NSControl.StateValue.off)
        chbShowIndicator.state = (preferences.getBoolValue(key: "showIndicatorInTitle") ?  NSControl.StateValue.on : NSControl.StateValue.off)
    }
    
    @IBAction func pressShowPercentage(_ sender: Any) {
        preferences.setBoolValue(key: "showPercentInTitle", value: (chbShowPercentage.state == NSControl.StateValue.on))
        delegate?.preferencesDidUpdate()
    }
    
    @IBAction func pressShowNetGain(_ sender: Any) {
        preferences.setBoolValue(key: "showNetGainInTitle", value: (chbShowNetGain.state == NSControl.StateValue.on))
        delegate?.preferencesDidUpdate()
    }
    
    @IBAction func pressShowIndicator(_ sender: Any) {
        preferences.setBoolValue(key: "showIndicatorInTitle", value: (chbShowIndicator.state == NSControl.StateValue.on))
        delegate?.preferencesDidUpdate()
    }
}
