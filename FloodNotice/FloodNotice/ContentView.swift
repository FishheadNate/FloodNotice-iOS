//
//  ContentView.swift
//  FloodNotice
//
//  Created by Nathan Copeland on 8/30/22.
//

import MapKit
import SwiftUI

struct ContentView: View {
    let location: GageLocation

    var body: some View {
        ScrollView {
            GageMapView(location: location)
                .frame(width: 200, height: 200, alignment: .center)
                .cornerRadius(5)
                .clipShape(Circle())
            
            Text(location.waterbody.trimmingCharacters(in: .whitespaces) + " near " + location.location)
                .bold()
                .padding(.top)
            
            Divider()
                .padding()
            NWSDataView(location: location)
        }
        .navigationBarTitle(Text(location.nwsId))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(location: GageLocation.example)
    }
}
