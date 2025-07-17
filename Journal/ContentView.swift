//
//  ContentView.swift
//  Journal
//
//  Created by user on 17/7/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        WriteView()
    }
}

#Preview {
    ContentView()
}
