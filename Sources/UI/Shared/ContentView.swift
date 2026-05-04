// ContentView.swift
// MonstaGuru
// Created by Mistral Vibe Code (UI/UX Agent)

import SwiftUI
import Data
import MIDI

/// Main content view for MonstaGuru, providing navigation between major app sections.
public struct ContentView: View {
    
    @Environment(\.
        modelContainer) private var modelContainer
    @EnvironmentObject private var midiManager: MIDIManager
    
    @State private var selectedTab: AppTab = .programEditor
    @State private var showMIDIStatus: Bool = false
    
    // MARK: - App Tabs
    
    public enum AppTab: String, Identifiable, CaseIterable {
        case programEditor = "Editor"
        case librarian = "Librarian"
        case clipboard = "Clipboard"
        
        public var id: String { rawValue }
        
        public var title: String { rawValue }
        
        public var icon: String {
            switch self {
            case .programEditor: return "slider.horizontal.3"
            case .librarian: return "folder.fill"
            case .clipboard: return "clipboard.fill"
            }
        }
    }
    
    // MARK: - Main View
    
    public var body: some View {
        NavigationStack {
            mainContent
                .navigationTitle("MonstaGuru")
                .navigationSubtitle(subtitle)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        midiStatusButton
                    }
                    ToolbarItem(placement: .secondaryAction) {
                        SettingsLink {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                    }
                }
        }
        .frame(minWidth: 1024, minHeight: 768)
    }
    
    // MARK: - Subviews
    
    private var mainContent: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases) { tab in
                tabView(for: tab)
                    .tabItem {
                        Label(tab.title, systemImage: tab.icon)
                    }
                    .tag(tab)
            }
        }
        .tabViewStyle(.toolbar)
    }
    
    @ViewBuilder
    private func tabView(for tab: AppTab) -> some View {
        switch tab {
        case .programEditor:
            ProgramEditorView()
                .environment(modelContainer)
                .environmentObject(midiManager)
        case .librarian:
            LibrarianView()
                .environment(modelContainer)
                .environmentObject(midiManager)
        case .clipboard:
            ClipboardView()
                .environment(modelContainer)
        }
    }
    
    private var subtitle: String {
        switch selectedTab {
        case .programEditor:
            return "Edit MicroMonsta 2 Programs"
        case .librarian:
            return "Manage Presets and Banks"
        case .clipboard:
            return "Persistent Clipboard"
        }
    }
    
    private var midiStatusButton: some View {
        Button(action: { showMIDIStatus.toggle() }) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: midiStatusIcon)
                    .foregroundStyle(midiStatusColor)
                
                if showMIDIStatus {
                    Text(midiStatusText)
                        .font(DesignSystem.Typography.bodySmall)
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                }
            }
            .animation(DesignSystem.Animations.fast, value: showMIDIStatus)
        }
        .buttonStyle(.plain)
        .help("MIDI Status: " + midiStatusText)
        .popover(isPresented: $showMIDIStatus) {
            MIDIStatusPopover()
                .environmentObject(midiManager)
                .padding(DesignSystem.Spacing.md)
                .frame(width: 250)
        }
    }
    
    private var midiStatusIcon: String {
        if midiManager.isInputConnected && midiManager.isOutputConnected {
            return "checkmark.circle.fill"
        } else if midiManager.isInputConnected || midiManager.isOutputConnected {
            return "exclamationmark.triangle.fill"
        } else {
            return "xmark.circle.fill"
        }
    }
    
    private var midiStatusColor: Color {
        if midiManager.isInputConnected && midiManager.isOutputConnected {
            return DesignSystem.Colors.midiConnected
        } else if midiManager.isInputConnected || midiManager.isOutputConnected {
            return DesignSystem.Colors.warning
        } else {
            return DesignSystem.Colors.midiDisconnected
        }
    }
    
    private var midiStatusText: String {
        if midiManager.isInputConnected && midiManager.isOutputConnected {
            return "Connected"
        } else if midiManager.isInputConnected {
            return "Input Only"
        } else if midiManager.isOutputConnected {
            return "Output Only"
        } else {
            return "Disconnected"
        }
    }
}

// MARK: - MIDI Status Popover

private struct MIDIStatusPopover: View {
    @EnvironmentObject private var midiManager: MIDIManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("MIDI Status")
                .font(DesignSystem.Typography.headline)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
            
            Divider()
            
            statusRow(label: "Input", value: midiManager.inputDeviceName, isConnected: midiManager.isInputConnected)
            statusRow(label: "Output", value: midiManager.outputDeviceName, isConnected: midiManager.isOutputConnected)
            
            Divider()
            
            HStack(spacing: DesignSystem.Spacing.sm) {
                Button("Refresh Devices") {
                    midiManager.refreshDevices()
                }
                .buttonStyle(isPrimary: true)
                
                Spacer()
                
                Button("Settings") {
                    // Will open settings
                }
                .buttonStyle()
            }
        }
    }
    
    private func statusRow(label: String, value: String, isConnected: Bool) -> some View {
        HStack {
            Text(label)
                .font(DesignSystem.Typography.bodySmall)
                .foregroundStyle(DesignSystem.Colors.textSecondary)
                .frame(width: 60, alignment: .leading)
            
            Spacer()
            
            Circle()
                .fill(isConnected ? DesignSystem.Colors.midiConnected : DesignSystem.Colors.midiDisconnected)
                .frame(width: 8, height: 8)
            
            Text(value.isEmpty ? "None" : value)
                .font(DesignSystem.Typography.bodySmallBold)
                .foregroundStyle(isConnected ? DesignSystem.Colors.textPrimary : DesignSystem.Colors.textTertiary)
                .lineLimit(1)
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(MIDIManager())
        .frame(width: 1200, height: 800)
}
