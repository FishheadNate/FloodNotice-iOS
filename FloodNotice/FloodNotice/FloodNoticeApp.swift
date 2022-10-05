//
//  FloodNoticeApp.swift
//  FloodNotice
//
//  Created by Nathan Copeland on 8/30/22.
//

import SwiftUI

@main
struct FloodNoticeApp: App {
    @StateObject var locations = GageLocations()
    //@StateObject var stationIDs = StationCrosswalk()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationView {
                    MainMapView()
                }
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Map")
                }
                
                NavigationView{
                    MainListView()
                }
                .tabItem {
                    Image(systemName: "binoculars.fill")
                    Text("Stream Gages List")
                }
            }
            .environmentObject(locations)
        }
    }
}
