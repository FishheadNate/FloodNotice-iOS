//
//  NWSDataView.swift
//  FloodNotice
//
//  Created by Nathan Copeland on 8/30/22.
//
// Fetches NWS ADHPS XML for selected stream gage. Shows the current status, flood stage levels,
// along with a subsample of the observations and forecast.

import SwiftUI
import SWXMLHash

struct FloodLevel: Codable {
    var id: UUID
    var stage: String
    var gageHeight: String
}

struct ObservedData: Codable, Identifiable {
    var id: UUID
    var pubDate: Date
    var gageHeight: String
    var flowRate: String
}

struct NWSDataView: View {
    @State var location: GageLocation
    @State private var sigFloodStages = [FloodLevel]()
    @State private var dataValues = [
        "forecast": [ObservedData](),
        "observed": [ObservedData]()
    ]
    
    var body: some View {
        VStack {
            HStack {
                Text("Currrent Status: ")
                ForEach(dataValues["observed"]!.prefix(1), id: \.id) { item in
                    if item.gageHeight != "" {
                        Text(item.gageHeight + " ft")
                    }
                }
                ForEach(dataValues["observed"]!.prefix(1), id: \.id) { item in
                    if item.flowRate != "---" {
                        Text("(\(item.flowRate))")
                    }
                }
            }
            
            Divider()
                .padding()
            
            // Flood Stages
            if sigFloodStages.count == 0 {
                Text("Flood Stage Levels Unavailable")
            } else {
                HStack {
                    LazyVGrid(columns: [GridItem(.flexible())], alignment: .leading, spacing: 0) {
                        Group {
                            Text("Flood Stages")
                        }
                        .font(.headline)
                        ForEach(sigFloodStages, id: \.id) { item in
                            if item.stage == "flood" {
                                Text("Minor")
                                    .padding(.top)
                            } else {
                                Text(item.stage.capitalized)
                                    .padding(.top)
                            }
                        }
                    }
            
                    LazyVGrid(columns: [GridItem(.flexible())], alignment: .center, spacing: 0) {
                        Group {
                            Text("Gage Height")
                        }
                        .font(.headline)
                        ForEach(sigFloodStages, id: \.id) { item in
                            if item.gageHeight == "" {
                                Text("Unavailable")
                                    .padding(.top)
                            } else {
                                Text(item.gageHeight + " ft")
                                    .padding(.top)
                            }
                        }
                    }
                }
                .padding()
            }
            
            Divider()
                .padding()
            
            Text("Recent Observations")
                .bold()
            HStack {
                LazyVGrid(columns: [GridItem(.flexible())], alignment: .leading, spacing: 0) {
                    Group {
                        Text("Time Stamp")
                    }
                    .font(.headline)
                    ForEach(dataValues["observed"]!, id: \.id) { item in
                        Text(item.pubDate, format:
                            .dateTime
                            .month(.abbreviated)
                            .day()
                            .hour(.defaultDigits(amPM: .abbreviated))
                            .minute()
                        )
                            .scaledToFill()
                            .minimumScaleFactor(0.1)
                            .lineLimit(1)
                            .padding(.top)
                    }
                }

                LazyVGrid(columns: [GridItem(.flexible())], alignment: .center, spacing: 0) {
                    Group {
                        Text("Gage Height")
                    }
                    .font(.headline)
                    ForEach(dataValues["observed"]!, id: \.id) { item in
                        if item.gageHeight == "" {
                            Text("---")
                                .scaledToFill()
                                .minimumScaleFactor(0.1)
                                .lineLimit(1)
                                .padding(.top)
                        } else {
                            Text(item.gageHeight + " ft")
                                .scaledToFill()
                                .minimumScaleFactor(0.1)
                                .lineLimit(1)
                                .padding(.top)
                        }
                    }
                }

                LazyVGrid(columns: [GridItem(.flexible())], alignment: .center, spacing: 0) {
                    Group {
                        Text("Flow Rate")
                    }
                    .font(.headline)
                    ForEach(dataValues["observed"]!, id: \.id) { item in
                        Text(item.flowRate)
                            .scaledToFill()
                            .minimumScaleFactor(0.1)
                            .lineLimit(1)
                            .padding(.top)
                    }
                }
            }
            .padding()
            
            Divider()
                .padding()
            
            if dataValues["forecast"]!.count == 0 {
                Text("Forecast Unavailable")
            } else {
                Text("Forecast")
                    .bold()
                HStack {
                    LazyVGrid(columns: [GridItem(.flexible())], alignment: .leading, spacing: 0) {
                        Group {
                            Text("Time Stamp")
                        }
                        .font(.headline)
                        ForEach(dataValues["forecast"]!, id: \.id) { item in
                            Text(item.pubDate, format:
                                .dateTime
                                .month(.abbreviated)
                                .day()
                                .hour(.defaultDigits(amPM: .abbreviated))
                                .minute()
                            )
                                .scaledToFill()
                                .minimumScaleFactor(0.1)
                                .lineLimit(1)
                                .padding(.top)
                        }
                    }

                    LazyVGrid(columns: [GridItem(.flexible())], alignment: .center, spacing: 0) {
                        Group {
                            Text("Gage Height")
                        }
                        .font(.headline)
                        ForEach(dataValues["forecast"]!, id: \.id) { item in
                            if item.gageHeight == "" {
                                Text("---")
                                    .scaledToFill()
                                    .minimumScaleFactor(0.1)
                                    .lineLimit(1)
                                    .padding(.top)
                            } else {
                                Text(item.gageHeight + " ft")
                                    .scaledToFill()
                                    .minimumScaleFactor(0.1)
                                    .lineLimit(1)
                                    .padding(.top)
                            }
                        }
                    }

                    LazyVGrid(columns: [GridItem(.flexible())], alignment: .center, spacing: 0) {
                        Group {
                            Text("Flow Rate")
                        }
                        .font(.headline)
                        ForEach(dataValues["forecast"]!, id: \.id) { item in
                            Text(item.flowRate)
                                .scaledToFill()
                                .minimumScaleFactor(0.1)
                                .lineLimit(1)
                                .padding(.top)
                        }
                    }
                }
                .padding()
            }

        }
        .task {
            await loadData(locationID: location.nwsId)
        }
    }
    
    func loadData(locationID: String) async {
        let nwsID = locationID.lowercased()
        guard let url = URL(string: "https://water.weather.gov/ahps2/hydrograph_to_xml.php?output=xml&gage=" + nwsID) else {
            print("Invalid URL for " + nwsID)
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let xmlFeed = try? XMLHash.parse(NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String) {
                // Flood Stage Levels
                await parseFloodStages(inputXML: xmlFeed["site"]["sigstages"])
                print("Flood Stages parsed")
                // Observed Data
                await parseXMLData(dataType: "observed", inputXML: xmlFeed["site"]["observed"])
                print("Observed parsed")
                // Forecast Data
                await parseXMLData(dataType: "forecast", inputXML: xmlFeed["site"]["forecast"])
                print("Forecast parsed")
            }
        } catch {
            print("Invalid data returned for " + nwsID)
        }
        return
    }
    
    func formatFlowValue(inputValue: Double?) async -> String {
        // Format raw flow rate values
        if inputValue! < 0 {
            return "---"
        } else if inputValue! < 1 {
            let adjValue = Int(inputValue! * Double(1000))
            return String(format: "\(adjValue) cfs")
        } else {
            return String(format: "%.2fk cfs", inputValue!)
        }
    }
    
    func parseFloodStages(inputXML: XMLIndexer) async {
        // Build array of significate flood stage thresholds
        for child in inputXML.children {
            sigFloodStages.append(FloodLevel(
                id: UUID(),
                stage: child.element!.name,
                gageHeight: child.element!.text
            ))
        }
        
        let dropStages = ["low", "action"]
        sigFloodStages.removeAll(where: {dropStages.contains($0.stage)})
    }
    
    func parseXMLData(dataType: String, inputXML: XMLIndexer) async {
        // Build dictionary of arrays for observation and forecast dateTime stamps, gage heights, & flow rates
        let dateParser = DateFormatter()
        dateParser.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

        if inputXML.children.count > 1 {
            for child in inputXML.children.prefix(5) {
                if child.children.count > 3 {
                    let adjustedFlowRate = await formatFlowValue(inputValue: Double(child["secondary"].element!.text))
                    
                    dataValues[dataType]!.append(ObservedData(
                        id: UUID(),
                        pubDate: dateParser.date(from: child["valid"].element!.text)!,
                        gageHeight: child["primary"].element!.text,
                        flowRate: adjustedFlowRate
                    ))
                } else {
                    dataValues[dataType]!.append(ObservedData(
                        id: UUID(),
                        pubDate: dateParser.date(from: child["valid"].element!.text)!,
                        gageHeight: child["primary"].element!.text,
                        flowRate: "---"
                    ))
                }
            }
        }
    }
}

struct NWSDataView_Previews: PreviewProvider {
    static var previews: some View {
        NWSDataView(location: GageLocation.example)
    }
}
