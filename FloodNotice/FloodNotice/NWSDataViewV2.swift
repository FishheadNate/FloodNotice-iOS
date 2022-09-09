//
//  NWSDataViewV2.swift
//  FloodNotice
//
//  Created by Nathan Copeland on 9/8/22.
//

import SwiftUI
import SWXMLHash

struct FloodLevelV2: Codable {
    var id: UUID
    var stage: String
    var gageHeight: String
}

struct ObservedDataV2: Codable, Identifiable {
    var id: UUID
    var pubDate: Date
    var gageHeight: String
    var flowRate: String
}

struct NWSDataViewV2: View {
    @State var location: GageLocation
    @State private var sigFloodStages = [FloodLevelV2]()
    @State private var dataValues = [ObservedDataV2]()
    
    @State private var observations = [ObservedDataV2]()
    @State private var forecasts = [ObservedDataV2]()
    
    var body: some View {
        VStack {
            HStack {
                Text("Currrent Status: ")
                
                //ForEach(observations.sorted {$0.pubDate < $1.pubDate}.suffix(1), id: \.id) { item in
                ForEach(dataValues.prefix(1), id: \.id) { item in
                    if item.gageHeight != "" {
                        Text(item.gageHeight + " ft")
                    }
                }
                
                ForEach(dataValues.prefix(1), id: \.id) { item in
                    if item.flowRate != "" {
                        Text(item.flowRate)
                        /*if (item.flowRate as NSString).doubleValue < 1 {
                            Text(" (" + String(Int((item.flowRate as NSString).doubleValue * Double(1000))) + " cfs)")
                        } else {
                            Text(" (" + item.flowRate + "k cfs)")
                        }*/
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
                    ForEach(dataValues.prefix(5), id: \.id) { item in
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
                    ForEach(dataValues.prefix(5), id: \.id) { item in
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
                    ForEach(dataValues.prefix(5), id: \.id) { item in
                        Text(item.flowRate)
                        /*if item.flowRate == "" {
                            Text("---")
                                .scaledToFill()
                                .minimumScaleFactor(0.1)
                                .lineLimit(1)
                                .padding(.top)
                        } else if (item.flowRate as NSString).doubleValue < 1 {
                            let adjustedFlowRate = (item.flowRate as NSString).doubleValue * Double(1000)
                            Text(String(Int(adjustedFlowRate)) + " cfs")
                                .scaledToFill()
                                .minimumScaleFactor(0.1)
                                .lineLimit(1)
                                .padding(.top)
                        } else {
                            Text(item.flowRate + "k cfs")
                                .scaledToFill()
                                .minimumScaleFactor(0.1)
                                .lineLimit(1)
                                .padding(.top)
                        }*/
                    }
                }
            }
            .padding()
            
            Divider()
                .padding()
            
            if dataValues.suffix(5).count == 0 {
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
                        ForEach(dataValues.suffix(5), id: \.id) { item in
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
                        ForEach(dataValues.suffix(5), id: \.id) { item in
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
                        ForEach(dataValues.suffix(5), id: \.id) { item in
                            Text(item.flowRate)
                            /*if item.flowRate == "" {
                                Text("---")
                                    .scaledToFill()
                                    .minimumScaleFactor(0.1)
                                    .lineLimit(1)
                                    .padding(.top)
                            } else if (item.flowRate as NSString).doubleValue < 1 {
                                let adjustedFlowRate = (item.flowRate as NSString).doubleValue * Double(1000)
                                Text(String(Int(adjustedFlowRate)) + " cfs")
                                    .scaledToFill()
                                    .minimumScaleFactor(0.1)
                                    .lineLimit(1)
                                    .padding(.top)
                            } else {
                                Text(item.flowRate + "k cfs")
                                    .scaledToFill()
                                    .minimumScaleFactor(0.1)
                                    .lineLimit(1)
                                    .padding(.top)
                            }*/
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
                await parseGageData(inputXML: xmlFeed["site"]["observed"])
                print("Observed parsed")
                // Forecast Data
                await parseGageData(inputXML: xmlFeed["site"]["forecast"])
                print("Forecast parsed")
            }
        } catch {
            print("Invalid data returned for " + nwsID)
        }
        return
    }
    
    func formatFlowValue(inputValue: Double?) async -> String {
        // Convert raw flow rate values
        // "" -> "---" | 0.99 -> 99 cfs | 9.9 -> 9.9k cfs
        let adjValue: String = String(inputValue ?? 0)
        print("format flow values")
        print(type(of: inputValue))
        print("\(String(describing: inputValue))")
        return adjValue
        //return String(adjValue)
        /*if inputValue == nil {
            return "-"
        } else {
            if inputValue == "" {
                return "---"
            } else if Int(inputValue ?? 110) < 1 {
                return String(Double(from: inputValue? ?? 0) * Double(1000))
            } else {
                return inputValue ?? "-"
            }
         }*/
    }
    
    func parseFloodStages(inputXML: XMLIndexer) async {
        // Build array of significate flood stage thresholds
        for child in inputXML.children {
            sigFloodStages.append(FloodLevelV2(
                id: UUID(),
                stage: child.element!.name,
                gageHeight: child.element!.text
            ))
        }
        
        let dropStages = ["low", "action"]
        sigFloodStages.removeAll(where: {dropStages.contains($0.stage)})
    }
    
    func parseGageData(inputXML: XMLIndexer) async {
        // Build array of observation and forecast dateTime stamps, gage heights, & flow rates
        let dateParser = DateFormatter()
        dateParser.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

        if inputXML.children.count > 1 {
            for child in inputXML.children.prefix(5) {
                if child.children.count > 3 {
                    let adjustedFlowRate = await formatFlowValue(inputValue: Double(child["secondary"].element!.text))
                    
                    dataValues.append(ObservedDataV2(
                        id: UUID(),
                        pubDate: dateParser.date(from: child["valid"].element!.text)!,
                        gageHeight: child["primary"].element!.text,
                        flowRate: adjustedFlowRate
                    ))
                } else {
                    dataValues.append(ObservedDataV2(
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

struct NWSDataViewV2_Previews: PreviewProvider {
    static var previews: some View {
        NWSDataViewV2(location: GageLocation.example)
    }
}

