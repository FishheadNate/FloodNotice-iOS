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
    let waterbody: String
    let location: String
    let nwsURL: String
    let latitude: Double
    let longitude: Double
    
    static let example = GageLocation(id: 0, nwsId: "wtto2", waterbody: "Example River", location: "Example City, AA", nwsURL: "https://water.weather.gov/ahps2/hydrograph.php?wfo=tsa&gage=wtto2", latitude: -91.5529, longitude: 37.3756)
}
