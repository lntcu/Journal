//
//  Scorer.swift
//  Journal
//
//  Created by user on 17/7/25.
//

import Foundation
import NaturalLanguage

class Scorer {
    let tagger = NLTagger(tagSchemes: [.sentimentScore])
    
    func score(_ text: String) -> Double {
        var sentiment = 0.0
        tagger.string = text
        tagger.enumerateTags(
            in: text.startIndex..<text.endIndex,
            unit: .paragraph,
            scheme: .sentimentScore,
            options: []
        ) { tag, _ in
            if let sentimentString = tag?.rawValue,
               let score = Double(sentimentString) {
                sentiment = score
                return true
            }
            return false
        }
        return sentiment
    }
}
