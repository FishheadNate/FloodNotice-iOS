//
//  NWSDataView.swift
//  FloodNotice
//
//  Created by Nathan Copeland on 8/30/22.
//

import SwiftUI
import SWXMLHash

struct FloodLevel: Codable {
    var id: UUID
    var stage: String
    var gageHeight: String
}

struct ObservedData: Codable {
    var id: UUID = UUID()
    var pubDate: Date = Date()
    var gageHeight: String = ""
    var flowRate: String = ""
}

struct NWSDataView: View {
    @State var location: GageLocation
    @State private var sigFloodStages = [FloodLevel]()
    @State private var observations = [ObservedData]()
    
    var body: some View {
        VStack {
            Text("https://water.weather.gov/ahps2/hydrograph_to_xml.php?output=xml&gage=" + location.nwsId.lowercased())
            
            HStack {
                LazyVGrid(columns: [GridItem(.flexible())], alignment: .leading, spacing: 10) {
                    Group {
                        Text("Flood Stages")
                    }
                    .font(.headline)
                    ForEach(sigFloodStages, id: \.id) { item in
                        if item.stage == "flood" {
                            Text("Minor")
                        } else {
                            Text(item.stage.capitalized)
                        }
                    }
                }
                .padding(.horizontal)
                LazyVGrid(columns: [GridItem(.flexible())], alignment: .center, spacing: 10) {
                    Group {
                        Text("Gage Height")
                    }
                    .font(.headline)
                    ForEach(sigFloodStages, id: \.id) { item in
                        if item.gageHeight == "" {
                            Text("Unavailable")
                        } else {
                            Text(item.gageHeight + " ft")
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Text("Observations")
            HStack {
                LazyVGrid(columns: [GridItem(.flexible())], alignment: .leading, spacing: 10) {
                    Group {
                        Text("Time Stamp")
                    }
                    .font(.headline)
                    ForEach(observations.sorted {$0.pubDate < $1.pubDate}, id: \.id) { item in
                        Text(item.pubDate.formatted(date: .numeric, time: .shortened))
                    }
                }
                .padding(.horizontal)
                LazyVGrid(columns: [GridItem(.flexible())], alignment: .center, spacing: 10) {
                    Group {
                        Text("Gage Height")
                    }
                    .font(.headline)
                    ForEach(observations.sorted {$0.pubDate < $1.pubDate}, id: \.id) { item in
                        if item.gageHeight == "" {
                            Text("Unavailable")
                        } else {
                            Text(item.gageHeight + " ft")
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .task {
            await parseXML()
        }
    }
    
    func parseXML() async {
        print("<><><><>")
        let nwsID = location.nwsId.lowercased()
        guard let url = URL(string: "https://water.weather.gov/ahps2/hydrograph_to_xml.php?output=xml&gage=" + nwsID) else {
            print("Invalid URL for " + nwsID)
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            print("-- 1 --")
            
            if let xmlFeed = try? XMLHash.parse(NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String) {
                print("-- 2 --")
                
                // Flood Stage Levels
                for child in xmlFeed["site"]["sigstages"].children {
                    sigFloodStages.append(FloodLevel(
                        id: UUID(),
                        stage: child.element!.name,
                        gageHeight: xmlFeed["site"]["sigstages"][child.element!.name].element!.text
                    ))
                
                }
                print("-- 3 --")
                let dropStages = ["low", "action", "record"]
                sigFloodStages.removeAll(where: {dropStages.contains($0.stage)})
                
                // Observations
                let dateParser = DateFormatter()
                    dateParser.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                
                for elem in xmlFeed["site"]["observed"].all {
                    let item = ObservedData()
                    .id = UUID()
                    itemlet item.pubDate = dateParser.date(from: elem["valid"].element!.text)!
                    item.gageHeight = elem["primary"].element!.text
                    item.flowRate = elem["secondary"].element!.text
                    
                    observations.append(item)
                    /*
                    observations.append(ObservedData(
                        id: UUID(),
                        pubDate: dateParser.date(from: elem["valid"].element!.text)!,
                        gageHeight: elem["primary"].element!.text,
                        flowRate: elem["secondary"].element!.text
                    ))
                    */
                }
            }
            
        } catch {
            print("Invalid data returned for " + nwsID)
        }
        
        print("<><><><>")
    }
}


struct NWSDataView_Previews: PreviewProvider {
    static var previews: some View {
        NWSDataView(location: GageLocation.example)
    }
}
