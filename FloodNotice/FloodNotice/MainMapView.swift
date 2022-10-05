//
//  MainMapView.swift
//  FloodNotice
//
//  Created by Nathan Copeland on 8/30/22.
//
// Interactive Map of all the stream gage objects created by GageLocations.swift

import MapKit
import SwiftUI

struct MainMapView: View {
    @EnvironmentObject var gageStations: GageLocations
    
    @State var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 36.174098,
            longitude: -95.461878),
        span: MKCoordinateSpan(
            latitudeDelta: 3,
            longitudeDelta: 3)
    )
    
    var body: some View {
        Map(coordinateRegion: $region,
            annotationItems: gageStations.places) {
            gageStation in
            MapAnnotation(coordinate:
                CLLocationCoordinate2D(latitude:
                    gageStation.latitude, longitude:
                    gageStation.longitude)) {
                
                NavigationLink(destination: ContentView(gageStation: gageStation)) {
                    Image(systemName: "drop.fill")
                        .resizable()
                        .foregroundColor(.blue)
                        .shadow(radius: 3)
                }
            }
        }
        .navigationTitle("FloodNotice")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MainMapView_Previews: PreviewProvider {
    static var previews: some View {
        MainMapView()
    }
}
