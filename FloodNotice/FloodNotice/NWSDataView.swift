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
    var stage: String
    var gageHeight: Double
}

struct XMLData: Codable {
    var pubDateUNIX: Double
    var pubDate: Date
    var gageHeight: Double
    var flowRate: String
    var observed: Bool = false

    static let example = XMLData(pubDateUNIX: Date.now.timeIntervalSince1970, pubDate: Date.now, gageHeight: -1, flowRate: "-*-", observed: false)
}

struct LoadingView: View {
    @State private var effectValue: Double = 1.0
    
    var body: some View {
        Spacer()
        Image(systemName: "drop.fill")
            .resizable()
            .scaledToFit()
            .frame(width: UIScreen.main.bounds.width / 30)
            .foregroundColor(.blue)
            .shadow(radius: 3)
            .overlay(
                Image(systemName: "drop.fill")
                    .foregroundColor(.blue)
                    .scaleEffect(effectValue)
                    .opacity(2 - effectValue)
                    .animation(
                        .easeOut(duration: 1)
                            .repeatForever(autoreverses: false),
                            value: effectValue
                    )
            )
            .onAppear {
                effectValue = 2
            }
    }
}

struct CurrentStatusView: View {
    var currentData: XMLData
    
    var body: some View {
        if currentData.gageHeight < 0 && currentData.flowRate == "---" {
            Text("Currrent Status Unavailable")
        } else if currentData.gageHeight > 0 && currentData.flowRate == "---" {
            Text("Currrent Status: \(String(format: "%.2f ft", currentData.gageHeight))")
        } else {
            Text("Currrent Status: \(String(format: "%.2f ft", currentData.gageHeight)) (\(currentData.flowRate))")
        }
    }
}

struct FloodStagesView: View {
    var floodStages: [FloodLevel]
    
    var body: some View {
        if (floodStages.filter{$0.gageHeight > 0}).isEmpty == true {
            Text("Flood Stage Levels Unavailable")
        } else {
            HStack {
                LazyVGrid(columns: [GridItem(.flexible())], alignment: .leading, spacing: 0) {
                    Group {
                        Text("Flood Stages")
                    }
                    .font(.headline)
                    ForEach(floodStages.filter{$0.gageHeight > 0}, id: \.stage) { item in
                        Text(item.stage == "flood" ? "Minor" : item.stage.capitalized)
                            .padding(.top)
                    }
                }
        
                LazyVGrid(columns: [GridItem(.flexible())], alignment: .center, spacing: 0) {
                    Group {
                        Text("Gage Height")
                    }
                    .font(.headline)
                    ForEach(floodStages.filter{$0.gageHeight > 0}, id: \.stage) { item in
                        Text(String(format: "%.1f ft", item.gageHeight))
                            .padding(.top)
                    }
                }
            }
        }
    }
}

struct XMLDataView: View {
    var data: [XMLData]
    
    var body: some View {
        HStack {
            LazyVGrid(columns: [GridItem(.flexible())], alignment: .leading, spacing: 0) {
                Group {
                    Text("Time Stamp")
                }
                .font(.headline)
                ForEach(data, id: \.pubDateUNIX) { item in
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
                ForEach(data, id: \.pubDateUNIX) { item in
                    Text(item.gageHeight == 0 ? "---" : String(format: "%.2f ft", item.gageHeight))
                        .scaledToFill()
                        .minimumScaleFactor(0.1)
                        .lineLimit(1)
                        .padding(.top)
                }
            }

            LazyVGrid(columns: [GridItem(.flexible())], alignment: .center, spacing: 0) {
                Group {
                    Text("Flow Rate")
                }
                .font(.headline)
                ForEach(data, id: \.pubDateUNIX) { item in
                    Text(item.flowRate)
                        .scaledToFill()
                        .minimumScaleFactor(0.1)
                        .lineLimit(1)
                        .padding(.top)
                }
            }
        }
    }
}


struct NWSDataView: View {
    @State var gageStation: GageLocation
    @State private var sigFloodStages = [FloodLevel]()
    @State private var nwsData = [XMLData]()
    
    var body: some View {
        VStack {
            if nwsData.isEmpty == true {
                Spacer()
                LoadingView()
                Spacer()
            } else {
                // Current Status
                CurrentStatusView(currentData: nwsData.first ?? XMLData.example)
                Divider()
                    .padding()
            
                // Flood Stages
                FloodStagesView(floodStages: sigFloodStages)
                    .padding()
                Divider()
                    .padding()
            
                // Observations
                Text("Recent Observations")
                    .bold()
                XMLDataView(data: nwsData.filter{$0.observed == true})
                    .padding()
                Divider()
                    .padding()
            
                // Forecast
                if nwsData.filter{$0.observed == false}.count == 0 {
                    Text("Forecast Unavailable")
                } else {
                    Text("Forecast")
                        .bold()
                    XMLDataView(data: nwsData.filter{$0.observed == false})
                        .padding()
                }
            }
        }
        .task {
            if gageStation.floodStages == "y" {
                sigFloodStages = [
                    FloodLevel(stage: "flood", gageHeight: Double(gageStation.flood)),
                    FloodLevel(stage: "moderate", gageHeight: Double(gageStation.moderate)),
                    FloodLevel(stage: "major", gageHeight: Double(gageStation.major))
                ]
                await loadData(nwsID: gageStation.nwsId, floodStages: true)
            } else {
                await loadData(nwsID: gageStation.nwsId, floodStages: false)
            }
        }
    }
    
    func loadData(nwsID: String, floodStages: Bool) async {
        let nwsID = nwsID.lowercased()
        guard let url = URL(string: "https://water.weather.gov/ahps2/hydrograph_to_xml.php?output=xml&gage=\(nwsID)") else {
            print("Invalid URL for \(nwsID)")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let xmlFeed = try? XMLHash.parse(NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String) {
                // Flood Stage Levels
                if floodStages == false {
                    await parseFloodStages(inputXML: xmlFeed["site"]["sigstages"])
                }
                // Observed Data
                await parseXMLData(dataType: "observed", inputXML: xmlFeed["site"]["observed"])
                // Forecast Data
                await parseXMLData(dataType: "forecast", inputXML: xmlFeed["site"]["forecast"])
            }
        } catch {
            print("Invalid data returned for \(nwsID)")
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
        // Build array of significant flood stage thresholds
        for child in inputXML.children {
            sigFloodStages.append(FloodLevel(
                stage: child.element!.name,
                gageHeight: Double(child.element!.text) ?? 0.0
            ))
        }
        let dropStages = ["low", "action"]
        sigFloodStages.removeAll(where: {dropStages.contains($0.stage)})
    }
    
    func parseXMLData(dataType: String, inputXML: XMLIndexer) async {
        // Build array of dictionaries for observation and forecast data
        let srcDateParser = DateFormatter()
        srcDateParser.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let outDateParser = DateFormatter()
        outDateParser.dateFormat = "MM/dd  HH:mm"

        if inputXML.children.count > 1 {
            for child in inputXML.children.prefix(5) {
                let xmlGageHeight = Double(child["primary"].element!.text) ?? 0.0
                let xmlPubDate = srcDateParser.date(from: child["valid"].element!.text)!
                
                if xmlGageHeight > -1 {
                    nwsData.append(XMLData(
                        pubDateUNIX: xmlPubDate.timeIntervalSince1970,
                        pubDate: xmlPubDate,
                        gageHeight: Double(child["primary"].element!.text) ?? 0.0,
                        flowRate: child.children.count > 3 ? await formatFlowValue(inputValue: Double(child["secondary"].element!.text)) : "---",
                        observed: dataType == "observed" ? true : false
                    ))
                }
            }
        }
    }
}

struct NWSDataView_Previews: PreviewProvider {
    static var previews: some View {
        NWSDataView(gageStation: GageLocation.example)
    }
}
