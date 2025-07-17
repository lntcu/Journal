//
//  JournalApp.swift
//  Journal
//
//  Created by user on 17/7/25.
//

import SwiftUI
import SwiftData

@main
struct JournalApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Entry.self)
        }
    }
}
