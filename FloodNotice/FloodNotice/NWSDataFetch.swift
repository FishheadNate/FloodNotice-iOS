//
//  NWSDataFetch.swift
//  FloodNotice
//
//  Created by Nathan Copeland on 8/30/22.
//

import Foundation
import SWXMLHash

struct NWSDataPoint: Hashable {
    let pubDate: Date
    let gageHeight: String
    let flowRate: String
}
/*
class FloodLevel: Identifiable {
    let id: UUID
    let stage: String
    let gageHeight: String
    
    static let example = FloodStage(id: UUID(), stage: "Bankfull-Example", gageHeight: "9999")
}
*/
struct FloodStage2: Decodable, Identifiable {
    let id: UUID
    let stage: String
    let gageHeight: String
    
    static let example = FloodStage(id: UUID(), stage: "Bankfull-Example", gageHeight: "9999")
}


class NWSDataFetch: ObservableObject {
    //var floodStageLevels = [FloodStage]()
    //var floodStageLevels = [FloodLevel]()
    //var floodStageLevels: [String: String] = [:]
    var floodStageLevels = [FloodStage2]()
    
    init() {
        let url = NSURL(string: "https://water.weather.gov/ahps2/hydrograph_to_xml.php?output=xml&gage=" + "wtto2")
        print("-- 1 --")
        
        let task = URLSession.shared.dataTask(with: url! as URL) {(data, response, error) in
            print("-- 2 --")
            if data != nil {
                print("-- 3 --")
                let feed = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String
                let xml = XMLHash.parse(feed)
                
                // Flood Stage Levels
                //let dropStages = ["low", "action"]
                for child in xml["site"]["sigstages"].children {
                    //self.floodStageLevels[child.element!.name] = xml["site"]["sigstages"][child.element!.name].element!.text
                    print("-- 4 --")
                    let item = FloodStage2(
                        id: UUID(),
                        stage: child.element!.name,
                        gageHeight: xml["site"]["sigstages"][child.element!.name].element!.text
                    )
                    
                    self.floodStageLevels.append(item)
                    
                }
                //self.forcast.removeAll(where: {dropStages.contains($0.stage)})
                //print(self.floodStageLevels)
                //for i in self.floodStageLevels {
                //    print(i.stage)
                //}
            }
        }
        task.resume()
    }
}

