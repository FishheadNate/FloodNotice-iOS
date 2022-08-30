//
//  MainListView.swift
//  FloodNotice
//
//  Created by Nathan Copeland on 8/30/22.
//

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
        .navigationTitle("Stream Gages by State")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        MainListView()
    }
}
