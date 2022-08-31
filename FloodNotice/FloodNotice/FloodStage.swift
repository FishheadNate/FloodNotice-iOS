//
//  FloodStage.swift
//  FloodNotice
//
//  Created by Nathan Copeland on 8/30/22.
//

import Foundation

struct FloodStage: Decodable, Identifiable {
    let id: UUID
    let stage: String
    let gageHeight: String
    
    static let example = FloodStage(id: UUID(), stage: "Bankfull-Example", gageHeight: "9999")
}
