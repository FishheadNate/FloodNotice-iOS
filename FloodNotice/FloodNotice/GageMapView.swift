//
//  GageMapView.swift
//  FloodNotice
//
//  Created by Nathan Copeland on 8/30/22.
//
// Interactive preview map of selected stream gage

import MapKit
import SwiftUI

struct GageMapView: View {
    @State var gageStation: GageLocation
    
    var body: some View {
        let gageRegion = MKCoordinateRegion(
            center:
                CLLocationCoordinate2D(latitude:
                gageStation.latitude, longitude:
                gageStation.longitude),
            span: MKCoordinateSpan(
                latitudeDelta: 0.01,
                longitudeDelta: 0.01)
        )
        
        Map(coordinateRegion: .constant(gageRegion),
            annotationItems: [gageStation]
        ) { gageStation in
            MapAnnotation(coordinate:
                CLLocationCoordinate2D(latitude:
                gageStation.latitude, longitude:
                gageStation.longitude)) {
                    Image(systemName: "drop.fill")
                        .resizable()
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 1.0))
                        .shadow(radius: 3)
            }
            
        }
    }
}

struct GageMapView_Previews: PreviewProvider {
    static var previews: some View {
        GageMapView(gageStation: GageLocation.example)
    }
}
