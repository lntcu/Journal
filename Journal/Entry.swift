//
//  Entry.swift
//  Journal
//
//  Created by user on 17/7/25.
//

import Foundation
import SwiftData

@Model
class Entry {
    var text: String
    
    init(text: String) {
        self.text = text
    }
}
