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
    var neighbor: String
    
    var body: some View {
        HStack {
            Text("Neighbor: \(neighbor)")
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
        VStack {
            Text("Neighboring Gage Stations")
         
            JumpToNeighborView(neighbor: String(upstreamGage.dropFirst(5)))
            
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
                //queryResults.removeAll(where: {$0.properties.identifier == "USGS-\(gageStation.usgsID)"})
                print("Features count: \(queryResults.count) for \(usgsID)")
                queryResults.forEach { item in
                    neighborsGages.append(String(item.properties.identifier))
                }
                neighborsGages.removeAll(where: {$0 == "USGS-\(gageStation.usgsID)"})
                
                if navigationMode == "UM" {
                    upstreamGage = neighborsGages.sorted{$0 > $1}.first(where: {gageStations.inventory.contains($0)}) ?? "USGS-00000000"
                }
                print("Upstream: \(upstreamGage)")
                
                if navigationMode == "DM" {
                    downstreamGage = neighborsGages.sorted{$0 < $1}.first(where: {gageStations.inventory.contains($0)}) ?? "USGS-00000000"
                }
                print("Downstream: \(downstreamGage)")
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
