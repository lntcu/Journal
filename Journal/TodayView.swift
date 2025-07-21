//
//  TodayView.swift
//  Journal
//
//  Created by user on 20/7/25.
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) var modelContext
    @Query var entries: [Entry]
    @State private var inspiration: Inspiration? = nil
    @State private var facts: Facts? = nil
    @State private var type: [String] = ["Facts", "Advice", "Examples", "Benefits"]
    @State private var selected: String = "Facts"
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Welcome back!")
                            .font(.title)
                            .fontWeight(.semibold)
                            .padding()
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                let text: String = {
                                    withAnimation {
                                        if let partial = inspiration?.response {
                                            return String(describing: partial)
                                        } else if inspiration != nil {
                                            return "Finding inspiration ..."
                                        } else {
                                            return "How has your day been coming along?"
                                        }
                                    }
                                }()
                                Text(text)
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .transition(.opacity.combined(with: .blurReplace).combined(with: .move(edge: .bottom)))
                                HStack {
                                    Button(action: inspire) {
                                        Label("Another", systemImage: "arrow.clockwise")
                                    }
                                    .buttonStyle(GlassButtonStyle())
                                    .glassEffect()
                                    Spacer()
                                    NavigationLink(destination: WriteView(prompt: inspiration?.response ?? "How's your day coming along?")) {
                                        Label("Reflect about this", systemImage: "pencil.and.scribble")
                                    }
                                    .buttonStyle(GlassButtonStyle())
                                    .glassEffect()
                                }
                            }
                            Spacer()
                        }
                        .padding()
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 30))
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                let title: String = {
                                    withAnimation {
                                        if let partial = facts?.response?.title {
                                            return String(describing: partial)
                                        } else if facts != nil {
                                            return "Coming up with \(selected) ..."
                                        } else {
                                            return "Learn \(selected) about Reflection"
                                        }
                                    }
                                }()
                                let text: String = {
                                    withAnimation {
                                        if let partial = facts?.response?.text {
                                            return String(describing: partial)
                                        } else if facts != nil {
                                            return "Please wait a short moment"
                                        } else {
                                            return "Press the generate button."
                                        }
                                    }
                                }()
                                Text(title)
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .transition(.opacity.combined(with: .blurReplace).combined(with: .move(edge: .bottom)))
                                Text(text)
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                                    .transition(.opacity.combined(with: .blurReplace).combined(with: .move(edge: .bottom)))
                                HStack {
                                    Button(action: generate) {
                                        Label("Learn", systemImage: "bubble.left")
                                    }
                                    .buttonStyle(GlassButtonStyle())
                                    .glassEffect()
                                    Spacer()
                                    Picker("Fact type", selection: $selected) {
                                        ForEach(type, id: \.self) {
                                            Text($0)
                                        }
                                    }
                                    .buttonStyle(GlassButtonStyle())
                                    .glassEffect()
                                }
                            }
                            Spacer()
                        }
                        .padding()
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 30))
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Total reflections so far")
                                    .font(.title2)
                                    .fontWeight(.medium)
                                HStack(alignment: .bottom) {
                                    Text("\(entries.count)")
                                        .font(.system(size: 50))
                                        .fontWeight(.semibold)
                                    Spacer()
                                    NavigationLink(destination: WriteView(prompt: "How's your day coming along?")) {
                                        Text("Reflect on Today")
                                    }
                                    .buttonStyle(GlassButtonStyle())
                                    .glassEffect()
                                }
                            }
                            Spacer()
                        }
                        .padding()
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 30))
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Recent reflections")
                                    .font(.title2)
                                    .fontWeight(.medium)
                                if entries.isEmpty {
                                    HStack {
                                        Text("None written yet")
                                            .foregroundStyle(.secondary)
                                            .font(.title2)
                                        Spacer()
                                        NavigationLink(destination: WriteView(prompt: "How's your day coming along?")) {
                                            Text("Write one now")
                                        }
                                        .buttonStyle(GlassButtonStyle())
                                        .glassEffect()
                                    }
                                }
                                else {
                                    Divider()
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
                                                Spacer()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 30))
                    }
                    .padding()
                    .padding(.bottom, 40)
                }
                VStack {
                    Spacer()
                    NavigationLink(destination: WriteView(prompt: "How's your day coming along?")) {
                        HStack {
                            Spacer()
                            Text("Start Reflection")
                                .font(.title2)
                                .fontWeight(.medium)
                            Spacer()
                        }
                        .padding(.vertical, 5)
                    }
                    .buttonStyle(GlassButtonStyle())
                    .glassEffect()
                    .padding(.horizontal)
                }
            }
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
    
    func generate() {
        if facts == nil {
            withAnimation {
                facts = Facts()
            }
        }
        Task {
            try await facts?.generate(type: selected)
        }
    }
}

#Preview {
    TodayView()
}
