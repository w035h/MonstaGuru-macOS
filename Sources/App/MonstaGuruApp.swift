// MonstaGuruApp.swift
// MonstaGuru
// Created by Mistral Vibe Code (Project Architect Agent)

import SwiftUI
import SwiftData

@main
struct MonstaGuruApp: App {
    
    // Shared ModelContainer for SwiftData
    let container: ModelContainer
    
    init() {
        do {
            // Configure SwiftData with all models
            container = try ModelContainer(
                for: Program.self, Preset.self, Bank.self, ClipboardEntry.self, MIDISetting.self
            )
        } catch {
            fatalError("Failed to initialize SwiftData container: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\container)
                .frame(minWidth: 1024, minHeight: 768) // Minimum window size for macOS
        }
        .windowStyle(.titleBar) // Standard macOS window style
        .windowResizability(.contentSize) // Allow resizing based on content
        
        // Settings scene for preferences
        Settings {
            SettingsView()
                .environment(\container)
        }
    }
}

// Placeholder for ContentView (will be implemented by UI Agent)
struct ContentView: View {
    var body: some View {
        Text("MonstaGuru")
            .font(.largeTitle)
            .padding()
    }
}

// Placeholder for SettingsView (will be implemented by UI Agent)
struct SettingsView: View {
    var body: some View {
        Text("Settings")
            .font(.title)
            .padding()
    }
}
