//
//  Bondora.swift
//  etfwatch
//
//  Created by Aydin Tekin on 29.05.21.
//

import Foundation

struct Payload: Codable {
    let Balance: Float64
    let Reserved: Float64
    let BidRequestAmount: Float64
    let TotalAvailable : Float64
    let GoGrowAccounts : [GoGrowAccount]
    
}

struct GoGrowAccount : Codable {
    let Name : String
    let NetDeposits : Float64
    let NetProfit : Float64
    let TotalSaved : Float64
}

struct BondoraResponse : Codable {
    let Payload : Payload
    let Success : Bool
}
