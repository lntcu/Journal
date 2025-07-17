//
//  WriteView.swift
//  Journal
//
//  Created by user on 17/7/25.
//

import SwiftUI
import SwiftData
import FoundationModels

@MainActor
@Observable
class Generator {
    let session: LanguageModelSession
    private(set) var response: [String].PartiallyGenerated?
    init() {
        self.session = LanguageModelSession() {
            "Generate a haiku based on the prompt. Try to include parts of the prompt in the haiku. Output only the haiku and nothing else."
        }
    }
    func generate(text: String) async throws {
        self.response = nil
        let prompt = "Generate a haiku based on this text: \(text)"
        let stream = session.streamResponse(to: prompt, generating: [String].self)
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

struct WriteView: View {
    @State private var thought: String = ""
    @State private var path = [Entry]()
    @Environment(\.modelContext) var modelContext
    @State private var generator: Generator? = nil
    @State private var inspiration: Inspiration? = nil
    @State private var generating: Bool = false
    var scorer = Scorer()
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack(alignment: .leading) {
                if path.isEmpty {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("How's your day coming along?")
                                .font(.title)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                        Spacer()
                    }
                    .transition(.opacity.combined(with: .blurReplace).combined(with: .move(edge: .bottom)))
                }
                else {
                    List {
                        ForEach(path) { entry in
                            HStack {
                                VStack(alignment: .leading) {
                                    ForEach(entry.text, id: \.self) { line in
                                        Text(line)
                                            .font(.title2)
                                            .fontWeight(.medium)
                                            .transition(.blurReplace.combined(with: .opacity))
                                            .transition(.opacity.combined(with: .blurReplace).combined(with: .move(edge: .bottom)))
                                    }
                                    Text("Positiveness: \(entry.score, specifier: "%.1f")")
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .transition(.opacity.combined(with: .blurReplace).combined(with: .move(edge: .bottom)))
                        }
                        .onDelete(perform: delete)
                    }
                    .listStyle(.plain)
                }
            }
            .padding()
            .padding(.bottom, 50)
            VStack {
                Spacer()
                if generating {
                    VStack(spacing: 5) {
                        HStack {
                            let text: [String] = {
                                withAnimation {
                                    if let partial = generator?.response {
                                        return partial
                                    } else {
                                        return ["Writing a haiku ..."]
                                    }
                                }
                            }()
                            VStack(alignment: .leading) {
                                ForEach(text, id: \.self) { line in
                                    Text(line)
                                        .font(.title2)
                                        .fontWeight(.medium)
                                        .transition(.opacity.combined(with: .blurReplace))
                                }
                            }
                            Spacer()
                        }
                        HStack {
                            Button(action: generate) {
                                Label("Regenerate", systemImage: "arrow.clockwise")
                            }
                            .buttonStyle(GlassButtonStyle())
                            .glassEffect()
                            Button(action: save) {
                                Label("Save", systemImage: "checkmark")
                            }
                            .disabled(generator?.session.isResponding ?? false)
                            .buttonStyle(GlassButtonStyle())
                            .glassEffect()
                            Spacer()
                        }
                    }
                    .padding()
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 30))
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .blurReplace).combined(with: .move(edge: .bottom)))
                }
                if inspiration != nil && !generating {
                    VStack(spacing: 5) {
                        HStack {
                            let text: String = {
                                withAnimation {
                                    if let partial = inspiration?.response {
                                        return String(describing: partial)
                                    } else {
                                        return "Finding inspiration ..."
                                    }
                                }
                            }()
                            Text(text)
                                .font(.title2)
                                .fontWeight(.medium)
                                .transition(.opacity.combined(with: .blurReplace))
                            Spacer()
                        }
                        HStack {
                            Button(action: inspire) {
                                Label("Another", systemImage: "arrow.clockwise")
                            }
                            .buttonStyle(GlassButtonStyle())
                            .glassEffect()
                            Button(action: { withAnimation { inspiration = nil } }) {
                                Label("Hide", systemImage: "xmark")
                            }
                            .buttonStyle(GlassButtonStyle())
                            .glassEffect()
                            Spacer()
                        }
                    }
                    .padding()
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 30))
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .blurReplace).combined(with: .move(edge: .bottom)))
                }
                VStack(spacing: 5) {
                    if thought == "" && inspiration == nil {
                        HStack {
                            Button(action: inspire) {
                                Label("Reflection Guide", systemImage: "sparkles")
                            }
                            .glassEffect()
                            .buttonStyle(GlassButtonStyle())
                            Spacer()
                        }
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .blurReplace).combined(with: .move(edge: .bottom)))
                    }
                    HStack(alignment: .bottom, spacing: 5) {
                        TextField("What's on your mind?", text: $thought, axis: .vertical)
                            .font(.title2)
                            .fontWeight(.medium)
                            .lineLimit(5)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 7)
                            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 30))
                            .onSubmit { generate() }
                            .disabled(generator?.session.isResponding ?? false)
                        Button(action: generate) {
                            Label("Save", systemImage: "return")
                                .font(.title2)
                                .padding(.horizontal, 3)
                                .padding(.vertical, 3)
                        }
                        .glassEffect()
                        .buttonStyle(GlassButtonStyle())
                        .labelStyle(.iconOnly)
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    func save() {
        let text = generator?.response
        let score = scorer.score(text?.joined(separator: "; ") ?? "")
        let newEntry = Entry(
            text: text ?? ["Error"],
            score: score
        )
        withAnimation {
            modelContext.insert(newEntry)
            path.append(newEntry)
            thought = ""
            generating = false
        }
    }
    
    func delete(_ indexSet: IndexSet) {
        for index in indexSet {
            let entry = path[index]
            modelContext.delete(entry)
        }
    }
    
    func generate() {
        if generator == nil {
            withAnimation {
                generator = Generator()
            }
        }
        Task {
            withAnimation {
                generating = true
            }
            try await generator?.generate(text: thought)
        }
    }
    
    func inspire() {
        if inspiration == nil {
            withAnimation {
                inspiration = Inspiration()
            }
        }
        Task {
            try await inspiration?.generate()
        }
    }
}

#Preview {
    WriteView()
}
