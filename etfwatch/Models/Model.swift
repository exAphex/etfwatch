//
//  Model.swift
//  etfwatch
//
//  Created by Aydin Tekin on 01.04.21.
//

import Foundation

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
