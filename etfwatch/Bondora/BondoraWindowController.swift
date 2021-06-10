//
//  BondoraWindowController.swift
//  etfwatch
//
//  Created by Aydin Tekin on 29.05.21.
//

import Cocoa

class BondoraWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        let controller = self.window!.contentViewController as! BondoraViewController
        controller.loadPreferences()
    }

}
