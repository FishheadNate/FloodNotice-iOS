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
    @State private var observations = [ObservedData]()
    @State private var forecasts = [ObservedData]()
    
    var body: some View {
        VStack {
            HStack {
                Text("Currrent Status: ")
                
                ForEach(observations.sorted {$0.pubDate < $1.pubDate}.suffix(1), id: \.id) { item in
                    if item.gageHeight != "" {
                        Text(item.gageHeight + " ft")
                    }
                }
                
                ForEach(observations.sorted {$0.pubDate < $1.pubDate}.suffix(1), id: \.id) { item in
                    if item.flowRate != "" {
                        if (item.flowRate as NSString).doubleValue < 1 {
                            Text(" (" + String(Int((item.flowRate as NSString).doubleValue * Double(1000))) + " cfs)")
                        } else {
                            Text(" (" + item.flowRate + "k cfs)")
                        }
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
                    ForEach(observations.sorted {$0.pubDate < $1.pubDate}.suffix(6), id: \.id) { item in
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
                    ForEach(observations.sorted {$0.pubDate < $1.pubDate}.suffix(6), id: \.id) { item in
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
                    ForEach(observations.sorted {$0.pubDate < $1.pubDate}.suffix(6), id: \.id) { item in
                        if item.flowRate == "" {
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
                        }
                    }
                }
            }
            .padding()
            
            Divider()
                .padding()
            
            if forecasts.count == 0 {
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
                        ForEach(forecasts.sorted {$0.pubDate < $1.pubDate}.prefix(6), id: \.id) { item in
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
                        ForEach(forecasts.sorted {$0.pubDate < $1.pubDate}.prefix(6), id: \.id) { item in
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
                        ForEach(forecasts.sorted {$0.pubDate < $1.pubDate}.prefix(6), id: \.id) { item in
                            if item.flowRate == "" {
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
                            }
                        }
                    }
                }
                .padding()
            }

        }
        .task {
            await parseXML()
        }
    }
    
    func parseXML() async {
        let nwsID = location.nwsId.lowercased()
        guard let url = URL(string: "https://water.weather.gov/ahps2/hydrograph_to_xml.php?output=xml&gage=" + nwsID) else {
            print("Invalid URL for " + nwsID)
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let xmlFeed = try? XMLHash.parse(NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String) {
                
                // Flood Stage Levels
                let dropStages = ["low", "action"]
                
                for child in xmlFeed["site"]["sigstages"].children {
                    if xmlFeed["site"]["sigstages"][child.element!.name].element!.text.count > 0 {
                        sigFloodStages.append(FloodLevel(
                            id: UUID(),
                            stage: child.element!.name,
                            gageHeight: xmlFeed["site"]["sigstages"][child.element!.name].element!.text
                        ))
                    }
                }
                sigFloodStages.removeAll(where: {dropStages.contains($0.stage)})
                
                // Observations
                let dateParser = DateFormatter()
                dateParser.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                
                for elem in xmlFeed["site"]["observed"]["datum"].all {
                    if elem.children.count > 3 {
                        observations.append(ObservedData(
                            id: UUID(),
                            pubDate: dateParser.date(from: elem["valid"].element!.text)!,
                            gageHeight: elem["primary"].element!.text,
                            flowRate: elem["secondary"].element!.text
                        ))
                    } else {
                        observations.append(ObservedData(
                            id: UUID(),
                            pubDate: dateParser.date(from: elem["valid"].element!.text)!,
                            gageHeight: elem["primary"].element!.text,
                            flowRate: ""
                        ))
                    }
                }
                
                // Forecast
                if xmlFeed["site"]["forecast"].element!.text != "There Is No Displayable Forecast Data In The Given Time Frame" {
                    for elem in xmlFeed["site"]["forecast"]["datum"].all {
                        forecasts.append(ObservedData(
                            id: UUID(),
                            pubDate: dateParser.date(from: elem["valid"].element!.text)!,
                            gageHeight: elem["primary"].element!.text,
                            flowRate: elem["secondary"].element!.text
                        ))
                    }
                }
            }
        } catch {
            print("Invalid data returned for " + nwsID)
        }
    }
}


struct NWSDataView_Previews: PreviewProvider {
    static var previews: some View {
        NWSDataView(location: GageLocation.example)
    }
}
