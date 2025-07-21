//
//  Models.swift
//  Journal
//
//  Created by user on 21/7/25.
//

import FoundationModels
import SwiftData
import SwiftUI

@MainActor
@Observable
class Poet {
    let session: LanguageModelSession
    private(set) var response: String.PartiallyGenerated?
    init() {
        self.session = LanguageModelSession() {
            "Generate a poem based on the prompt. Try to include parts of the prompt in the poem. Output only the poem and nothing else. Use _n for a new line (e.g. in a haiku), and _b for a text return (e.g. one paragraph in a sonnet)."
        }
    }
    func generate(text: String, format: String) async throws {
        self.response = nil
        let prompt = "Generate a \(format) based on this text: \(text)"
        let stream = session.streamResponse(to: prompt, generating: String.self)
        for try await partial in stream {
            withAnimation {
                self.response = partial
            }
        }
    }
}

@MainActor
@Observable
class Inspiration {
    let session: LanguageModelSession
    private(set) var response: String.PartiallyGenerated?
    init() {
        self.session = LanguageModelSession() {
            "Generate a inspirational question to prompt the reader to reflect on their day. Make the question short and to the point. Output only the question and nothing else."
        }
    }
    func generate() async throws {
        self.response = nil
        let prompt = "Generate a inspiration question."
        let stream = session.streamResponse(to: prompt, generating: String.self)
        for try await partial in stream {
            withAnimation {
                self.response = partial
            }
        }
    }
}

@Generable
struct FactsFormat {
    var title: String
    var text: String
}

@MainActor
@Observable
class Facts {
    let session: LanguageModelSession
    private(set) var response: FactsFormat.PartiallyGenerated?
    init() {
        self.session = LanguageModelSession() {
            "Write a short text about reflection. Depending on what the user requested, provide facts, practical advice, examples of poetic reflection, or benefits of reflecting. Write a short title, and one short sentence."
        }
    }
    func generate(type: String) async throws {
        self.response = nil
        let prompt = "Generate a \(type) about reflection."
        let stream = session.streamResponse(to: prompt, generating: FactsFormat.self)
        for try await partial in stream {
            withAnimation {
                self.response = partial
            }
        }
    }
}
