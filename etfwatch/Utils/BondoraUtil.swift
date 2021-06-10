//
//  BondoraUtil.swift
//  etfwatch
//
//  Created by Aydin Tekin on 29.05.21.
//

import Cocoa

class BondoraUtil {
    static func getBondoraData(token : String) -> [GoGrowAccount] {
        do {
            let bondoraData = try getRequest(strURL: "https://api.bondora.com/api/v1/account/balance", token: token)
            if (bondoraData != nil) {
                return bondoraData!.Payload.GoGrowAccounts
            }
        } catch {
            
        }
        return []
    }
    
    static func getRequest(strURL: String, token : String) throws -> BondoraResponse?  {
        let url = URL(string: strURL)!
        let semaphore = DispatchSemaphore(value: 0)
        var result : BondoraResponse? = nil
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            if let error = error {
                print(error) // this will print -1009
                semaphore.signal()
                return
            }
            guard let data = data else {
                semaphore.signal()
                return
            }
            do {
                let jsonDecoder = JSONDecoder()
                result = try jsonDecoder.decode(BondoraResponse.self, from: data)
            } catch {
                print("JSONSerialization error:", error)
            }
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        return result
    }
    
    static func getPortfolioModel(ggAccounts : [GoGrowAccount]) -> [PortfolioModelElement] {
        var result : [PortfolioModelElement] = []
        for g in ggAccounts {
            let diffPercent = g.NetProfit / g.NetDeposits
            result.append(PortfolioModelElement(name: g.Name + " (Bondora G&G)", count: 0, diffPercentage: diffPercent, diff: g.NetProfit, priceIndividual: 0, priceIndividualOld:0, priceTotal: g.TotalSaved, priceTotalOld: g.NetDeposits, type: PortfolioModelElementType.BONDORA))
        }
        return result
    }
}
