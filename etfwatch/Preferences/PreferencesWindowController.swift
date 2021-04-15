//
//  PreferencesWindowController.swift
//  etfwatch
//
//  Created by Aydin Tekin on 15.04.21.
//

import Cocoa

class PreferencesWindowController: NSWindowController {
    

    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        let controller = self.window!.contentViewController as! PreferencesViewController
        controller.loadPreferences()
    }

}
