//
//  Entry.swift
//  Journal
//
//  Created by user on 17/7/25.
//

import Foundation
import SwiftData

@Model
class Entry: Identifiable {
    var id: UUID
    var text: [String]
    var score: Double
    
    init(text: [String], score: Double) {
        self.id = UUID()
        self.text = text
        self.score = score
    }
}
