//
//  ContentView.swift
//  FloodNotice
//
//  Created by Nathan Copeland on 8/30/22.
//

import MapKit
import SwiftUI

struct ContentView: View {
    let gageStation: GageLocation
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .center) {
                GageMapView(gageStation: gageStation)
                    .frame(width: UIScreen.main.bounds.width, height: 300, alignment: .center)
                    .cornerRadius(5)
                    .clipShape(Rectangle())
                
                NeighboringGagesView(gageStation: gageStation)
            }
            
            if gageStation.waterbody == gageStation.location {
                Text("\(gageStation.waterbody) (\(gageStation.state))")
                    .bold()
                    .lineLimit(1)
                    .padding(.vertical)
            } else {
                Text("\(gageStation.waterbody) near \(gageStation.location), \(gageStation.state)")
                    .bold()
                    .lineLimit(1)
                    .padding(.vertical)
            }

            Section(footer: Text("© NOAA AHPS").font(.footnote).foregroundColor(.secondary).padding(.top)) {
                NWSDataView(gageStation: gageStation)
            }
        }
        .navigationBarTitle(Text(gageStation.nwsId))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(gageStation: GageLocation.example)
    }
}
