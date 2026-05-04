// SettingsView.swift
// MonstaGuru
// Created by Mistral Vibe Code (UI/UX Agent)

import SwiftUI
import Data
import MIDI

/// Settings view for MonstaGuru, providing MIDI configuration and app preferences.
public struct SettingsView: View {
    
    @Environment(\.
        modelContainer) private var modelContainer
    @EnvironmentObject private var midiManager: MIDIManager
    
    @StateObject private var viewModel = SettingsViewModel()
    
    @State private var selectedSection: SettingsSection = .midi
    
    // MARK: - Settings Sections
    
    public enum SettingsSection: String, Identifiable, CaseIterable {
        case midi = "MIDI"
        case general = "General"
        case appearance = "Appearance"
        case advanced = "Advanced"
        
        public var id: String { rawValue }
        
        public var title: String { rawValue }
        
        public var icon: String {
            switch self {
            case .midi: return "midifile"
            case .general: return "gearshape"
            case .appearance: return "paintpalette"
            case .advanced: return "slider.horizontal.3"
            }
        }
    }
    
    // MARK: - Main View
    
    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Settings")
                .frame(minWidth: 800, minHeight: 600)
        }
    }
    
    private var content: some View {
        HStack(spacing: 0) {
            // Sidebar
            List(SettingsSection.allCases, selection: $selectedSection) { section in
                NavigationLink(value: section) {
                    Label(section.title, systemImage: section.icon)
                        .font(DesignSystem.Typography.body)
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                        .padding(DesignSystem.Spacing.sm)
                }
                .tag(section)
            }
            .listStyle(.sidebar)
            .frame(width: 180)
            .background(DesignSystem.Colors.backgroundSecondary)
            
            // Main content
            TabView(selection: $selectedSection) {
                ForEach(SettingsSection.allCases) { section in
                    sectionView(for: section)
                        .tabItem {
                            Label(section.title, systemImage: section.icon)
                        }
                        .tag(section)
                }
            }
            .tabViewStyle(.toolbar)
            .padding(DesignSystem.Spacing.lg)
        }
    }
    
    @ViewBuilder
    private func sectionView(for section: SettingsSection) -> some View {
        switch section {
        case .midi:
            MIDISettingsView()
                .environmentObject(midiManager)
        case .general:
            GeneralSettingsView()
        case .appearance:
            AppearanceSettingsView()
        case .advanced:
            AdvancedSettingsView()
        }
    }
}

// MARK: - MIDI Settings View

private struct MIDISettingsView: View {
    @EnvironmentObject private var midiManager: MIDIManager
    
    @State private var availableInputDevices: [MIDIDevice] = []
    @State private var availableOutputDevices: [MIDIDevice] = []
    @State private var isRefreshing: Bool = false
    
    var body: some View {
        Form {
            Section(header: Text("MIDI Devices").sectionHeaderStyle()) {
                inputDevicePicker
                outputDevicePicker
            }
            
            Section(header: Text("MIDI Options").sectionHeaderStyle()) {
                sysExToggle
                midiThruToggle
                deviceIDPicker
            }
            
            Section(header: Text("Channels").sectionHeaderStyle()) {
                programChangeChannelPicker
                noteChannelPicker
            }
        }
        .formStyle(.grouped)
        .onAppear {
            refreshDevices()
        }
    }
    
    private var inputDevicePicker: some View {
        Picker("Input Device", selection: $midiManager.inputDeviceName) {
            ForEach(availableInputDevices, id: \.name) { device in
                Text(device.name).tag(device.name)
            }
        }
        .onChange(of: midiManager.inputDeviceName) { _ in
            midiManager.connectInput()
        }
    }
    
    private var outputDevicePicker: some View {
        Picker("Output Device", selection: $midiManager.outputDeviceName) {
            ForEach(availableOutputDevices, id: \.name) { device in
                Text(device.name).tag(device.name)
            }
        }
        .onChange(of: midiManager.outputDeviceName) { _ in
            midiManager.connectOutput()
        }
    }
    
    private var sysExToggle: some View {
        Toggle("Enable SysEx", isOn: $midiManager.isSysExEnabled)
            .help("Enable System Exclusive message handling for MicroMonsta 2 communication")
    }
    
    private var midiThruToggle: some View {
        Toggle("MIDI Thru", isOn: $midiManager.isMIDIThruEnabled)
            .help("Echo MIDI input to output (useful for monitoring)")
    }
    
    private var deviceIDPicker: some View {
        Picker("Device ID", selection: $midiManager.deviceID) {
            ForEach(0..<16, id: \.self) { id in
                Text("0x" + String(format: "%02X", id)).tag(UInt8(id))
            }
        }
        .help("SysEx device ID (0x00-0x0F)")
    }
    
    private var programChangeChannelPicker: some View {
        Picker("Program Change Channel", selection: $midiManager.programChangeChannel) {
            Text("Omni").tag(MIDIChannel(0))
            ForEach(1..<17, id: \.self) { channel in
                Text("Channel " + String(channel)).tag(MIDIChannel(channel))
            }
        }
        .help("MIDI channel for program change messages")
    }
    
    private var noteChannelPicker: some View {
        Picker("Note Channel", selection: $midiManager.noteChannel) {
            Text("Omni").tag(MIDIChannel(0))
            ForEach(1..<17, id: \.self) { channel in
                Text("Channel " + String(channel)).tag(MIDIChannel(channel))
            }
        }
        .help("MIDI channel for note messages")
    }
    
    private func refreshDevices() {
        isRefreshing = true
        availableInputDevices = MIDIManager.availableInputDevices()
        availableOutputDevices = MIDIManager.availableOutputDevices()
        isRefreshing = false
    }
}

// MARK: - General Settings View

private struct GeneralSettingsView: View {
    var body: some View {
        Form {
            Section(header: Text("Application").sectionHeaderStyle()) {
                Text("MonstaGuru Version 1.0.0")
                    .font(DesignSystem.Typography.bodySmall)
                    .foregroundStyle(DesignSystem.Colors.textTertiary)
            }
            
            Section(header: Text("Default Behavior").sectionHeaderStyle()) {
                Toggle("Auto-load last program", isOn: .constant(true))
                    .help("Automatically load the last edited program on launch")
                
                Toggle("Confirm before overwriting", isOn: .constant(true))
                    .help("Show confirmation dialog before overwriting presets")
            }
        }
        .formStyle(.grouped)
    }
}

// MARK: - Appearance Settings View

private struct AppearanceSettingsView: View {
    var body: some View {
        Form {
            Section(header: Text("Theme").sectionHeaderStyle()) {
                Picker("Color Scheme", selection: .constant(0)) {
                    Text("System").tag(0)
                    Text("Light").tag(1)
                    Text("Dark").tag(2)
                }
                .help("Choose the app's color scheme")
            }
            
            Section(header: Text("Editor").sectionHeaderStyle()) {
                Toggle("Show parameter labels", isOn: .constant(true))
                    .help("Show text labels for all parameters")
                
                Toggle("Show parameter values", isOn: .constant(true))
                    .help("Show numeric values for all parameters")
                
                Slider(value: .constant(1.0), in: 0.5...2.0, step: 0.1) {
                    Text("Control Size")
                }
                .help("Adjust the size of controls in the editor")
            }
        }
        .formStyle(.grouped)
    }
}

// MARK: - Advanced Settings View

private struct AdvancedSettingsView: View {
    var body: some View {
        Form {
            Section(header: Text("MIDI").sectionHeaderStyle()) {
                Toggle("Debug MIDI Messages", isOn: .constant(false))
                    .help("Log all MIDI messages to console for debugging")
                
                Toggle("Ignore SysEx Errors", isOn: .constant(false))
                    .help("Ignore malformed SysEx messages instead of showing errors")
            }
            
            Section(header: Text("Data").sectionHeaderStyle()) {
                Button("Reset Database") {
                    // Reset action
                }
                .foregroundStyle(DesignSystem.Colors.error)
                .help("Reset the entire database (cannot be undone)")
                
                Button("Export All Data") {
                    // Export action
                }
                .help("Export all presets, banks, and programs to a file")
            }
        }
        .formStyle(.grouped)
    }
}

// MARK: - View Model

private final class SettingsViewModel: ObservableObject {
    // View model for settings
}

// MARK: - Preview

#Preview {
    SettingsView()
        .environmentObject(MIDIManager())
        .frame(width: 1000, height: 700)
}
