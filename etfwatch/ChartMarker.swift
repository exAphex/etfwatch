//
//  ChartMarker.swift
//  etfwatch
//
//  Created by Aydin Tekin on 14.04.21.
//

import Foundation
import Charts

class ChartMarker: MarkerView {
    var text = ""
    var time = ""

    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        super.refreshContent(entry: entry, highlight: highlight)
        text = PortfolioUtil.getFormattedEuroPrice(price: entry.y)
        time = PortfolioUtil.getReadableTimeFromTimestamp(value: entry.x)
    }

    override func draw(context: CGContext, point: CGPoint) {
        super.draw(context: context, point: point)

        let str = " \(text) @ \(time) "
        var drawAttributes = [NSAttributedString.Key : Any]()
        drawAttributes[.font] = NSUIFont.systemFont(ofSize: 11)
        drawAttributes[.foregroundColor] = NSUIColor.white
        drawAttributes[.backgroundColor] = NSUIColor.darkGray

        self.bounds.size = (str as NSString).size(withAttributes: drawAttributes)
        self.offset = CGPoint(x: 0, y: -self.bounds.size.height - 2)

        let offset = self.offsetForDrawing(atPoint: point)
        
        let maxX = self.chartView?.bounds.maxX
        let minX = point.x + offset.x
        let minDrawX = (str as NSString).size(withAttributes: drawAttributes).width  / 2.0
        let maxDrawX = minDrawX + point.x + offset.x
        
        
        if (maxDrawX > maxX!) {
            drawText(text: str as NSString, rect: CGRect(origin: CGPoint(x: point.x + offset.x + (maxX! - maxDrawX)  , y: point.y + offset.y - 10), size: self.bounds.size), withAttributes: drawAttributes)
        } else if (minDrawX > minX) {
            drawText(text: str as NSString, rect: CGRect(origin: CGPoint(x: point.x + offset.x + (minDrawX - minX)  , y: point.y + offset.y - 10), size: self.bounds.size), withAttributes: drawAttributes)
        } else {
            drawText(text: str as NSString, rect: CGRect(origin: CGPoint(x: point.x + offset.x, y: point.y + offset.y - 10), size: self.bounds.size), withAttributes: drawAttributes)
        }
    }

    func drawText(text: NSString, rect: CGRect, withAttributes attributes: [NSAttributedString.Key : Any]? = nil) {
        let size = text.size(withAttributes: attributes)
        let centeredRect = CGRect(x: rect.origin.x + (rect.size.width - size.width) / 2.0, y: rect.origin.y + (rect.size.height - size.height) / 2.0, width: size.width, height: size.height)
        text.draw(in: centeredRect, withAttributes: attributes)
    }
}
