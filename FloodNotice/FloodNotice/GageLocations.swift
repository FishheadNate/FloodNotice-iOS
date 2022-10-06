//
//  GageLocations.swift
//  FloodNotice
//
//  Created by Nathan Copeland on 8/30/22.
//
// Ingests the source JSON of stream gage sites and returns an array of
// objects matching the structure defined in GageLocation.swift

import Foundation

class GageLocations: ObservableObject {
    var places: [GageLocation]
    var inventory: [String] = []
    
    init() {
        let url = Bundle.main.url(forResource: "gage-stations-iOS",
                                  withExtension: "json")!
        let data = try! Data(contentsOf: url)
        places = try! JSONDecoder().decode([GageLocation].self, from: data)
        
        for place in places {
            inventory.append("USGS-\(place.usgsID)")
        }
    }
}
