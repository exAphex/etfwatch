//
//  PortfolioElementController.swift
//  etfwatch
//
//  Created by Aydin Tekin on 06.04.21.
//

import Cocoa


class PortfolioElementController: NSWindowController, NSWindowDelegate {
    var delegate : MainAppDelegate?
    
    @IBOutlet weak var t: NSWindow!
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        let controller = self.window!.contentViewController as! PortfolioElementViewController
        controller.clearAll()
    }

}

extension PortfolioElementController {
  static func freshController() -> PortfolioElementController {
    let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
    let identifier = NSStoryboard.SceneIdentifier("PortfolioElementController")
    guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? PortfolioElementController else {
      fatalError("Why cant i find PortfolioViewController? - Check Main.storyboard")
    }
    return viewcontroller
  }
}
