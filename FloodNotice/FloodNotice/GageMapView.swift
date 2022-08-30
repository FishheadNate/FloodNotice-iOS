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
    @State var location: GageLocation
    
    var body: some View {
        let gageRegion = MKCoordinateRegion(
            center:
                CLLocationCoordinate2D(latitude:
                location.latitude, longitude:
                location.longitude),
            span: MKCoordinateSpan(
                latitudeDelta: 0.01,
                longitudeDelta: 0.01)
        )
        
        Map(coordinateRegion: .constant(gageRegion),
            annotationItems: [location]
        ) { location in
            MapAnnotation(coordinate:
                CLLocationCoordinate2D(latitude:
                location.latitude, longitude:
                location.longitude)) {
                    Image(systemName: "drop.fill")
                        .resizable()
                        .foregroundColor(.blue)
                        .shadow(radius: 3)
            }
            
        }
    }
}

struct GageMapView_Previews: PreviewProvider {
    static var previews: some View {
        GageMapView(location: GageLocation.example)
    }
}
