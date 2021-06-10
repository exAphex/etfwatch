//
//  PortfolioUtil.swift
//  etfwatch
//
//  Created by Aydin Tekin on 04.04.21.
//

import Foundation

class PortfolioUtil {
    
    static func getPortfolioData(portfolio: [PortfolioElement]) -> [PortfolioModelElement] {
        var resultArr : [PortfolioModelElement] = []
        for p in portfolio {
            do {
                let historicData = try HTTPUtil.getRequest(strURL: "https://www.ls-tc.de/_rpc/json/instrument/chart/dataForInstrument?container=chart1&instrumentId=" + String(p.instrumentId) + "&marketId=1&quotetype=mid&series=intraday&type=&localeId=2")
                if (historicData != nil) {
                    let sortedTimeline = historicData?.series.intraday.data.sorted {
                        $0[0] < $1[0]
                    }
                    if (sortedTimeline!.count > 0) {
                        let elemLowPrice = sortedTimeline![0][1]
                        let elemPrice = sortedTimeline![sortedTimeline!.count - 1][1]
                        let tempElem = getPortfolioModelElement(portfolioelem : PortfolioElement(name: p.name, instrumentId: p.instrumentId, count: p.count, resultData: ResultStruct(latestPrice: elemPrice, oldestPrice: elemLowPrice), intraDay: sortedTimeline!))
                        resultArr.append(tempElem)
                    } else {
                        let tempElem = getPortfolioModelElement(portfolioelem :PortfolioElement(name: p.name, instrumentId: p.instrumentId, count: p.count, resultData: ResultStruct(latestPrice: p.resultData.latestPrice, oldestPrice: p.resultData.oldestPrice)))
                        resultArr.append(tempElem)
                    }
                } else {
                    resultArr.append(getPortfolioModelElement(portfolioelem :PortfolioElement(name: p.name, instrumentId: p.instrumentId, count: p.count, resultData: ResultStruct(latestPrice: p.resultData.latestPrice, oldestPrice: p.resultData.oldestPrice))))
                }
            } catch {
                resultArr.append(getPortfolioModelElement(portfolioelem :PortfolioElement(name: p.name, instrumentId: p.instrumentId, count: p.count, resultData: ResultStruct(latestPrice: p.resultData.latestPrice, oldestPrice: p.resultData.oldestPrice))))
            }
        }
        
        return resultArr
    }
    
    static func getPortfolioModelElement(portfolioelem : PortfolioElement) -> PortfolioModelElement {
        
        let total = portfolioelem.resultData.latestPrice * portfolioelem.count
        let totalOld = portfolioelem.resultData.oldestPrice * portfolioelem.count
        let diffPrice = total - totalOld
        let diffPercent = (1 - (totalOld / total)) * 100
        let retElem = PortfolioModelElement(name: portfolioelem.name, count: portfolioelem.count, diffPercentage: diffPercent, diff: diffPrice, priceIndividual: portfolioelem.resultData.latestPrice, priceIndividualOld:portfolioelem.resultData.oldestPrice, priceTotal: total, priceTotalOld: totalOld, intraDay: portfolioelem.intraDay, type: PortfolioModelElementType.LUS, securityElem: portfolioelem)
        return retElem
    }
    
    static func getFormattedEuroPrice(price : Float64) -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        return currencyFormatter.string(from: NSNumber(value: price))!
    }
    
    static func getReadableTimeFromTimestamp(value: Float64) -> String {
        let dateFormatter = DateFormatter()
        let newValue = value / 1000
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.string(from: Date(timeIntervalSince1970: newValue))
    }
    
    static func injectTotalValue(portfolio : [PortfolioModelElement]) -> [PortfolioModelElement] {
        var totalValue : Float64 = 0
        var totalOldValue : Float64 = 0
        var retPortfolio : [PortfolioModelElement] = portfolio
        for p in retPortfolio {
            totalValue += p.priceTotal
            totalOldValue += p.priceTotalOld
        }
        let diffPercent = (1 - (totalOldValue / totalValue)) * 100
        let diffPrice = totalValue - totalOldValue
        retPortfolio.append(PortfolioModelElement(name: "Total", count: 0, diffPercentage: diffPercent, diff: diffPrice, priceIndividual: 0, priceIndividualOld: 0, priceTotal: totalValue, priceTotalOld: totalOldValue, type: PortfolioModelElementType.TOTAL))
        return retPortfolio
    }
}
