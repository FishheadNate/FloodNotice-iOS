//
//  MainListView.swift
//  FloodNotice
//
//  Created by Nathan Copeland on 8/30/22.
//
// List of stream gages objects created by GageLocations.swift sorted by state and then waterbody

import SwiftUI

struct MainListView: View {
    @EnvironmentObject var locations: GageLocations
    
    var body: some View {
        List(locations.places) { location in
            NavigationLink(destination: ContentView(location: location)){
                Text(location.waterbody + " (" +  location.location + ")")
                    .lineLimit(1)
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
