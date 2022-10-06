//
//  GageLocation.swift
//  FloodNotice
//
//  Created by Nathan Copeland on 8/30/22.
//
// Template for parsing stream gage JSON features into Swift objects

import Foundation

struct GageLocation: Decodable, Identifiable {
    let id: Int
    let nwsId: String
    let location: String
    let latitude: Double
    let longitude: Double
    let waterbody: String
    let state: String
    let action: Double
    let flood: Double
    let moderate: Double
    let major: Double
    let lowThreshold: Double
    let usgsID: String
    let siteType: String
    let floodStages: String
    
    static let example = GageLocation(id: 1, nwsId: "WTTO2", location: "Example City", latitude: 37.3756, longitude: -91.5529, waterbody: "Example River", state: "AA", action: 4.0, flood: 7.0, moderate: 14.0, major: 20.0, lowThreshold: 1.1, usgsID: "07195500", siteType: "surface water", floodStages: "y")
}
