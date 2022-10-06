//
//  NeighboringGagesView.swift
//  FloodNotice
//
//  Created by Nathan Copeland on 10/5/22.
//
// Queries the NLDI database to find all gage stations within 50km and
// returns the next gage stations upstream and downstream.
//

import SwiftUI

struct NLDIResults: Decodable {
    let features: [Feature]
}

struct Feature: Decodable {
    let geometry: Geometry
    let type: String
    let properties: Properties
}
    
struct Geometry: Decodable {
    let coordinates: [Double]
    let type: String
}
    
struct Properties: Decodable {
    let identifier: String
    let navigation: String
    let measure: Double
    let reachcode: String
    let name: String
    let source: String
    let sourceName: String
    let comid: String
    let type: String
    let uri: String
    let mainstem: String
}

struct JumpToNeighborView: View {
    @EnvironmentObject var gageStations: GageLocations
    var navDirection: String
    var neighbor: String
    let frameWidth = UIScreen.main.bounds.width * 0.12
    
    var body: some View {
        let rotateDegrees = navDirection == "down" ? -180.0 : 0.0
        let xOffset = navDirection == "down" ? 6 : -6
        
        if let navLink = try? gageStations.places.first(where: {"USGS-\($0.usgsID)" == neighbor}) {
            NavigationLink(destination: ContentView(gageStation: navLink)) {
                Image(systemName: "arrowtriangle.forward.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: frameWidth)
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 1.0))
                    .opacity(0.75)
                    .shadow(radius: 3)
                    .rotationEffect(.degrees(rotateDegrees))
                    .overlay {
                        Image(systemName: "drop.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: frameWidth * 0.3)
                            .foregroundColor(.white)
                            .shadow(radius: 3)
                            .offset(x: CGFloat(xOffset))
                    }
                    .padding(navDirection == "down" ? .leading : .trailing)
            }
        } else {
            Image(systemName: "drop.fill")
                .resizable()
                .scaledToFit()
                .frame(width: frameWidth)
                .foregroundColor(.clear)
        }
    }
}

struct NeighboringGagesView: View {
    @EnvironmentObject var gageStations: GageLocations
    @State var gageStation: GageLocation
    @State private var queryResults = [Feature]()
    @State private var upstreamGage: String = "USGS-99999999"
    @State private var downstreamGage: String = "USGS-99999999"
    
    var body: some View {
        HStack {
            JumpToNeighborView(navDirection: "down", neighbor: downstreamGage)
                .padding()
                .offset(x: UIScreen.main.bounds.width * -0.30)
            
            JumpToNeighborView(navDirection: "up", neighbor: upstreamGage)
                .padding()
                .offset(x: UIScreen.main.bounds.width * 0.30)
        }.task {
            await loadData(usgsID: gageStation.usgsID, navigationMode: "UM")
            await loadData(usgsID: gageStation.usgsID, navigationMode: "DM")
        }
    }
    
    func loadData(usgsID: String, navigationMode: String) async {
        var neighborsGages: [String] = []
        
        guard let queryURL = URL(string: "https://labs.waterdata.usgs.gov/api/nldi/linked-data/nwissite/USGS-\(usgsID)/navigation/\(navigationMode)/nwissite?f=json&distance=100") else {
            print("Invalid URL")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: queryURL)
            if let jsonFeed = try? JSONDecoder().decode(NLDIResults.self, from: data) {
                queryResults = jsonFeed.features
                
                queryResults.forEach { item in
                    neighborsGages.append(String(item.properties.identifier))
                }
                neighborsGages.removeAll(where: {$0 == "USGS-\(gageStation.usgsID)"})
                
                if navigationMode == "UM" {
                    upstreamGage = neighborsGages.sorted{$0 > $1}.first(where: {gageStations.inventory.contains($0)}) ?? "USGS-00000000"
                }
                
                if navigationMode == "DM" {
                    downstreamGage = neighborsGages.sorted{$0 < $1}.first(where: {gageStations.inventory.contains($0)}) ?? "USGS-00000000"
                }
            }
        } catch {
            print("Invalid data returned")
        }
    }
}

struct NeighboringGagesView_Previews: PreviewProvider {
    static var previews: some View {
        NeighboringGagesView(gageStation: GageLocation.example)
    }
}
