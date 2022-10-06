//
//  MainListView.swift
//  FloodNotice
//
//  Created by Nathan Copeland on 8/30/22.
//
// List of stream gages objects created by GageLocations.swift sorted by waterbody and then USGS ID

import SwiftUI

struct MainListView: View {
    @EnvironmentObject var gageStations: GageLocations
    
    var body: some View {
        let sortedGageStations = gageStations.places.sorted {
            return ($0.waterbody, $0.usgsID) < ($1.waterbody, $1.usgsID)
        }
        
        List(sortedGageStations) { gageStation in
            NavigationLink(destination: ContentView(gageStation: gageStation)){
                if gageStation.waterbody == gageStation.location {
                    Text("\(gageStation.waterbody) (\(gageStation.state))")
                        .lineLimit(1)
                } else {
                    Text("\(gageStation.waterbody) (\(gageStation.location), \(gageStation.state))")
                        .lineLimit(1)
                }
            }
        }
        .navigationTitle("FloodNotice")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        MainListView()
    }
}
