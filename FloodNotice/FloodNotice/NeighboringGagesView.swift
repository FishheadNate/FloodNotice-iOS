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

struct NeighborsView: View {
    var neighbors: [Feature]
    var upstream: Bool
    
    var body: some View {
        HStack {
            Text("Downstream")
            Text("Upstream")
        }
    }
}

struct NeighboringGagesView: View {
    @State var gageStation: GageLocation
    //@State private var neighboringGages = [Feature]()
    @State private var queryResults = [Feature]()
    //
    @State private var upstreamGages: [String] = []
    @State private var upstreamGage: String = "00000000"
    
    var body: some View {
        VStack {
            Text("Neighboring Gage Stations")
         
            NeighborsView(neighbors: queryResults, upstream: true)
            
        }.task {
            await loadData(usgsID: gageStation.usgsID, navigationMode: "UM")
            await sortNeighbors(neighbors: upstreamGages, upstream: true)
        }
    }
    
    func loadData(usgsID: String, navigationMode: String) async {
        guard let queryURL = URL(string: "https://labs.waterdata.usgs.gov/api/nldi/linked-data/nwissite/USGS-\(usgsID)/navigation/\(navigationMode)/nwissite?f=json&distance=50") else {
            print("Invalid URL")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: queryURL)
            
            if let jsonFeed = try? JSONDecoder().decode(NLDIResults.self, from: data) {
                DispatchQueue.main.async {
                    queryResults = jsonFeed.features
                    queryResults.removeAll(where: {$0.properties.identifier == "USGS-\(usgsID)"})
                    
                    for item in queryResults {
                        let neighborID = String(item.properties.identifier.dropFirst(5))
                        upstreamGages.append(neighborID)
                    }
                }
            }
        } catch {
            print("Invalid data returned")
        }
        return
    }
    
    func sortNeighbors(neighbors: [String], upstream: Bool) async {
        let upstreamSorted = neighbors.sorted{$0 < $1}
        print("=============")
        for i in upstreamSorted {
            print(i)
        }
        print("=============")
    }
}

struct NeighboringGagesView_Previews: PreviewProvider {
    static var previews: some View {
        NeighboringGagesView(gageStation: GageLocation.example)
    }
}


/*
 func sortNeighbors(usgsID: String, neighbors: [Feature], upstream: Bool) async {
     if upstream == true {
         var upstreamSorted = neighbors.sorted{$0.properties.identifier > $1.properties.identifier}
         upstreamSorted.removeAll(where: {$0.properties.identifier == "USGS-\(usgsID)"})
         print("=============")
         for i in upstreamSorted {
             print(i.properties.identifier)
         }
         print("=============")
     }
 }
 */
