//
//  WriteView.swift
//  Journal
//
//  Created by user on 17/7/25.
//

import SwiftUI
import SwiftData
import FoundationModels

struct WriteView: View {
    @State private var thought: String = ""
    @Environment(\.modelContext) var modelContext
    @Query var entries: [Entry]
    @State private var poet: Poet? = nil
    @State private var inspiration: Inspiration? = nil
    @State private var generating: Bool = false
    @State private var format: String = "Haiku"
    var prompt: String
    let formats = ["Haiku", "Sonnet", "Cinquain", "Epigram", "Limerick", "Ekphrastic", "Couplet", "Free Verse", "Lyric"]
    
    var body: some View {
        ZStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading) {
                    if entries.isEmpty {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Text(prompt)
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
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(entries) { item in
                                HStack {
                                    ForEach(item.text.components(separatedBy: "_b"), id: \.self) { para in
                                        VStack(alignment: .leading) {
                                            ForEach(para.components(separatedBy: "_n"), id: \.self) { line in
                                                Text(line)
                                                    .font(.title2)
                                                    .fontWeight(.medium)
                                                    .transition(.opacity.combined(with: .blurReplace).combined(with: .move(edge: .bottom)))
                                            }
                                        }
                                    }
                                    .transition(.opacity.combined(with: .blurReplace).combined(with: .move(edge: .bottom)))
                                    Spacer()
                                }
                                .transition(.opacity.combined(with: .blurReplace).combined(with: .move(edge: .bottom)))
                            }
                            .onDelete(perform: delete)
                        }
                    }
                }
                .padding(.bottom, 80)
            }
            .padding()
            VStack(spacing: 5) {
                Spacer()
                if generating {
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            let text: String = {
                                withAnimation {
                                    if let partial = poet?.response {
                                        return partial
                                    } else {
                                        return "Writing a \(format) ..."
                                    }
                                }
                            }()
                            VStack(alignment: .leading, spacing: 20) {
                                ForEach(text.components(separatedBy: "_b"), id: \.self) { para in
                                    VStack(alignment: .leading) {
                                        ForEach(para.components(separatedBy: "_n"), id: \.self) { line in
                                            Text(line)
                                                .font(.title2)
                                                .fontWeight(.medium)
                                        }
                                        .transition(.opacity.combined(with: .blurReplace).combined(with: .move(edge: .bottom)))
                                    }
                                }
                            }
                            .transition(.opacity.combined(with: .blurReplace).combined(with: .move(edge: .bottom)))
                            Spacer()
                        }
                        HStack {
                            Button(action: generate) {
                                Label("Regenerate", systemImage: "arrow.clockwise")
                            }
                            .buttonStyle(GlassButtonStyle())
                            .glassEffect()
                            .disabled(poet?.session.isResponding ?? false)
                            .buttonStyle(GlassButtonStyle())
                            .glassEffect()
                            Picker("Poem Format", selection: $format) {
                                ForEach(formats, id: \.self) {
                                    Text($0)
                                }
                            }
                            .glassEffect()
                            .buttonStyle(GlassButtonStyle())
                            Spacer()
                            Button(action: save) {
                                Label("Save", systemImage: "checkmark")
                                    .labelStyle(.iconOnly)
                            }
                        }
                    }
                    .padding()
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 30))
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .blurReplace).combined(with: .move(edge: .bottom)))
                }
                if (inspiration != nil || prompt != "How's your day coming along?") && !generating {
                    VStack(spacing: 5) {
                        HStack {
                            let text: String = {
                                withAnimation {
                                    if let partial = inspiration?.response {
                                        return String(describing: partial)
                                    } else if inspiration != nil {
                                        return "Finding inspiration ..."
                                    } else {
                                        return prompt
                                    }
                                }
                            }()
                            Text(text)
                                .font(.title2)
                                .fontWeight(.medium)
                                .transition(.opacity.combined(with: .blurReplace).combined(with: .move(edge: .bottom)))
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
                    HStack(spacing: 5) {
                        if inspiration == nil && !generating {
                            Button(action: inspire) {
                                Label("Reflection Guide", systemImage: "sparkles")
                            }
                            .glassEffect()
                            .buttonStyle(GlassButtonStyle())
                            .transition(.opacity.combined(with: .blurReplace).combined(with: .move(edge: .bottom)))
                        }
                        if !generating {
                            Picker("Poem Format", selection: $format) {
                                ForEach(formats, id: \.self) {
                                    Text($0)
                                }
                            }
                            .glassEffect()
                            .buttonStyle(GlassButtonStyle())
                            .transition(.opacity.combined(with: .blurReplace).combined(with: .move(edge: .bottom)))
                        }
                        Spacer()
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
                            .disabled(poet?.session.isResponding ?? false)
                        Button(action: generate) {
                            Label("Send", systemImage: "paperplane")
                                .font(.title3)
                                .padding(.horizontal, 3)
                                .padding(.vertical, 3)
                        }
                        .glassEffect()
                        .buttonStyle(GlassButtonStyle())
                        .labelStyle(.iconOnly)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    func save() {
        guard let text = poet?.response else {
            print("No text generated to save.")
            return
        }
        let newEntry = Entry(text: poet?.response ?? "Error")
        withAnimation {
            modelContext.insert(newEntry)
            do {
                try modelContext.save()
            } catch {
                print("Failed to save text.")
            }
            thought = ""
            generating = false
        }
    }
    
    func delete(_ indexSet: IndexSet) {
        for index in indexSet {
            let item = entries[index]
            modelContext.delete(item)
        }
    }
    
    func generate() {
        if poet == nil {
            withAnimation {
                poet = Poet()
            }
        }
        Task {
            withAnimation {
                generating = true
            }
            try await poet?.generate(text: thought, format: format)
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
    WriteView(prompt: "How's your day coming along?")
}
