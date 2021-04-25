//
//  CustomPortfolioTableCell.swift
//  etfwatch
//
//  Created by Aydin Tekin on 25.04.21.
//

import Cocoa

class CustomPortfolioTableCell: NSTableCellView {

    @IBOutlet weak var lblTitle: NSTextField!
    @IBOutlet weak var lblAmount: NSTextField!
    @IBOutlet weak var lblTotalGain: NSTextField!
    @IBOutlet weak var lblPercentGain: NSTextField!
    @IBOutlet weak var lblTotal: NSTextField!
    @IBOutlet weak var lblPricePerUnit: NSTextField!
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
