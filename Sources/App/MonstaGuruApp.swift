// MonstaGuruApp.swift
// MonstaGuru
// Created by Mistral Vibe Code (Project Architect Agent)

import SwiftUI
import SwiftData
import Data
import MIDI
import UI

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
    
    // Shared MIDI Manager
    @StateObject private var midiManager = MIDIManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\container)
                .environmentObject(midiManager)
                .frame(minWidth: 1024, minHeight: 768) // Minimum window size for macOS
        }
        .windowStyle(.titleBar) // Standard macOS window style
        .windowResizability(.contentSize) // Allow resizing based on content
        
        // Settings scene for preferences
        Settings {
            SettingsView()
                .environment(\container)
                .environmentObject(midiManager)
        }
    }
}
