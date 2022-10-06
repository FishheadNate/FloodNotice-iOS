//
//  NeighboringGagesView.swift
//  FloodNotice
//
//  Created by Nathan Copeland on 10/5/22.
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


struct NeighboringGagesView: View {
    @State var gageStation: GageLocation
    @State private var neighboringGages = [Feature]()
    
    var body: some View {
        VStack {
            Text("Neighboring Gage Stations")
         
            
        }.task {
            await loadData(usgsID: gageStation.usgsID, navigationMode: "UM")
        }
    }
    
    func loadData(usgsID: String, navigationMode: String) async {
        guard let queryURL = URL(string: "https://labs.waterdata.usgs.gov/api/nldi/linked-data/nwissite/USGS-\(usgsID)/navigation/\(navigationMode)/nwissite?f=json&distance=25") else {
            print("Invalid URL")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: queryURL)
            
            if let jsonFeed = try? JSONDecoder().decode(NLDIResults.self, from: data) {
                DispatchQueue.main.async {
                    neighboringGages = jsonFeed.features
                    print(neighboringGages)
                }
            }
        } catch {
            print("Invalid data returned")
        }
        return
    }
}

struct NeighboringGagesView_Previews: PreviewProvider {
    static var previews: some View {
        NeighboringGagesView(gageStation: GageLocation.example)
    }
}
