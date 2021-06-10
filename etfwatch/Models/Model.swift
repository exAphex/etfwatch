//
//  Model.swift
//  etfwatch
//
//  Created by Aydin Tekin on 01.04.21.
//

import Foundation

enum PortfolioModelElementType : Int, Codable {
    case LUS, BONDORA, TOTAL
}

struct PortfolioModelElement : Codable {
    var name : String?
    var count: Float64
    var diffPercentage: Float64
    var diff: Float64
    var priceIndividual: Float64
    var priceIndividualOld: Float64
    var priceTotal: Float64
    var priceTotalOld: Float64
    var intraDay = [[Float64]]()
    var type : PortfolioModelElementType
    var securityElem : PortfolioElement?
}

struct Position: Codable {
    let id: Int
    let displayname: String?
    let isin: String?
    let categoryid: Int
    let productcount: Int
    let alias: String?
    let instrumentId: Int
    let categorySymbol: String?
    let categoryName: String?
    let url: Int
    let link: String?
}

struct PortfolioElement: Codable {
    var name: String?
    var instrumentId: Int
    var count: Float64
    var resultData : ResultStruct = ResultStruct(latestPrice: 0, oldestPrice: 0)
    var intraDay = [[Float64]]()
}

struct IntraDayStruct: Codable {
    let data: [[Float64]]
}

struct SeriesStruct: Codable {
    let intraday: IntraDayStruct
}

struct HistoricDataStruct: Codable {
    let series: SeriesStruct
}

struct ResultStruct: Codable {
    var latestPrice: Float64
    var oldestPrice: Float64
}

struct UpdateModel: Codable {
    let req_version: String
}
