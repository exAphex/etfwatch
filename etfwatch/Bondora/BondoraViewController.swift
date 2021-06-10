//
//  BondoraViewController.swift
//  etfwatch
//
//  Created by Aydin Tekin on 29.05.21.
//

import Cocoa

class BondoraViewController: NSViewController {
    var delegate : MainAppDelegate?
    let preferences = Preferences()
    var window : BondoraWindowController?
    @IBOutlet weak var txtToken: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func loadPreferences() {
        let strToken = preferences.getStringValue(key: "bondoraToken")
        txtToken.stringValue = (strToken != nil ? strToken! : "")
    }
    
    @IBAction func onSaveBondora(_ sender: Any) {
        preferences.setStringValue(key: "bondoraToken", value: txtToken.stringValue)
        delegate?.preferencesDidUpdate()
        self.window?.close()
    }
}
