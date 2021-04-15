//
//  PortfolioUtil.swift
//  etfwatch
//
//  Created by Aydin Tekin on 04.04.21.
//

import Foundation

class PortfolioUtil {
    
    static func getPortfolioData(portfolio: [PortfolioElement]) -> [PortfolioElement] {
        var resultArr : [PortfolioElement] = []
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
                        let tempElem = PortfolioElement(name: p.name, instrumentId: p.instrumentId, count: p.count, resultData: ResultStruct(latestPrice: elemPrice, oldestPrice: elemLowPrice), intraDay: sortedTimeline!)
                        resultArr.append(tempElem)
                    } else {
                        let tempElem = PortfolioElement(name: p.name, instrumentId: p.instrumentId, count: p.count, resultData: ResultStruct(latestPrice: p.resultData.latestPrice, oldestPrice: p.resultData.oldestPrice))
                        resultArr.append(tempElem)
                    }
                }
            } catch {
                resultArr.append(PortfolioElement(name: p.name, instrumentId: p.instrumentId, count: p.count, resultData: ResultStruct(latestPrice: p.resultData.latestPrice, oldestPrice: p.resultData.oldestPrice)))
            }
        }
        let sortedResultArr = resultArr.sorted {
            ($0.count * $0.resultData.latestPrice) > ($1.count * $1.resultData.latestPrice)
        }
        return sortedResultArr
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
        return dateFormatter.string(from: Date(timeIntervalSince1970: newValue))
    }
    
    static func injectTotalValue(portfolio : [PortfolioElement]) -> [PortfolioElement] {
        var totalValue : Float64 = 0
        var totalOldValue : Float64 = 0
        var retPortfolio : [PortfolioElement] = portfolio
        for p in retPortfolio {
            totalValue += p.resultData.latestPrice * p.count
            totalOldValue += p.resultData.oldestPrice * p.count
        }
        retPortfolio.append(PortfolioElement(name: "Total", instrumentId: -1, count: 0, resultData: ResultStruct(latestPrice: totalValue, oldestPrice: totalOldValue)))
        return retPortfolio
    }
}
