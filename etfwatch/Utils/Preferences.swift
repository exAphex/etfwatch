//
//  Preferences.swift
//  etfwatch
//
//  Created by Aydin Tekin on 14.04.21.
//

import Foundation

enum PreferenceError: Error {
    case alreadyInPortfolio
    case notFoundInPortfolio
    case genericError(cause: String)
}

class Preferences {
    let userDefaults = UserDefaults.standard
    
    func getBoolValue(key : String) -> Bool {
        return userDefaults.bool(forKey: key)
    }
    
    func setBoolValue(key: String, value : Bool) {
        userDefaults.set(value, forKey: key)
    }
    
    func getStringValue(key : String) -> String? {
        return userDefaults.string(forKey: key)
    }
    
    func setStringValue(key: String, value : String) {
        userDefaults.set(value, forKey: key)
    }
    
    func loadPortfolioFromPreferences() -> [PortfolioElement] {
        if let data = userDefaults.object(forKey: "portfolioElements") as? Data {
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
    
    func modifyPortfolioFromPreferences(elem : PortfolioElement) throws {
        var portfolioElements = loadPortfolioFromPreferences()
        for i in portfolioElements.indices {
            if (portfolioElements[i].instrumentId == elem.instrumentId) {
                portfolioElements[i].count = elem.count
                portfolioElements[i].name = elem.name
            }
        }
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
