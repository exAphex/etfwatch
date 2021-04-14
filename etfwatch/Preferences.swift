//
//  Preferences.swift
//  etfwatch
//
//  Created by Aydin Tekin on 14.04.21.
//

import Foundation

enum PreferenceError: Error {
    case alreadyInPortfolio
    case genericError(cause: String)
}

class Preferences {
    let userDefaults = UserDefaults.standard
    
    func loadPortfolioFromPreferences() -> [PortfolioElement] {
        if let data = UserDefaults.standard.object(forKey: "portfolioElements") as? Data {
            do {
                return try JSONDecoder().decode([PortfolioElement].self, from: data)
            } catch {
                print("Error while decoding user data")
            }
        }
        return []
    }
    
    func addPortfolioFromPreferences(elem : PortfolioElement) throws {
        var portfolioElements = loadPortfolioFromPreferences()
        for p in portfolioElements {
            if p.instrumentId == elem.instrumentId {
                throw PreferenceError.alreadyInPortfolio
            }
        }
        
        portfolioElements.append(elem)
        
        portfolioElements = try savePortfolio(elements: portfolioElements)
    }
    
    func savePortfolio(elements : [PortfolioElement]) throws -> [PortfolioElement] {
        let data = try JSONEncoder().encode(elements)
        UserDefaults.standard.set(data, forKey: "portfolioElements")
        return elements
    }
    
    func deletePortfolioElementFromPreferences(elem : PortfolioElement) throws  {
        var portfolioElements = loadPortfolioFromPreferences()
        for (i, p) in portfolioElements.enumerated() {
            if p.instrumentId == elem.instrumentId {
                portfolioElements.remove(at: i)
                break;
            }
        }
        
        portfolioElements = try savePortfolio(elements: portfolioElements)
    }
}
