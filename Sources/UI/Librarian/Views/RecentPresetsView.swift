// RecentPresetsView.swift
// MonstaGuru
// Created by Mistral Vibe Code (Librarian Agent)

import SwiftUI
import Data

/// View for displaying recently accessed presets.
public struct RecentPresetsView: View {
    
    @ObservedObject public var viewModel: LibrarianViewModel
    
    // MARK: - State
    
    @State private var recentPresets: [Preset] = []
    
    // MARK: - Body
    
    public var body: some View {
        List {
            // Header
            Section {
                Text("Recently Accessed Presets")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            }
            
            // Recent presets
            ForEach(recentPresets) { preset in
                Button(action: { viewModel.selectedPreset = preset }) {
                    PresetRowView(preset: preset)
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button("Load in Editor") {
                        viewModel.selectedPreset = preset
                        viewModel.selectedProgram = preset.program
                    }
                    
                    if let program = preset.program {
                        Button("Send to Hardware") {
                            try? viewModel.sendProgramToHardware()
                        }
                    }
                }
            }
            
            // Empty state
            if recentPresets.isEmpty {
                ContentUnavailableView(
                    "No Recent Presets",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("Your recently accessed presets will appear here")
                )
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Recent")
        .onAppear {
            loadRecentPresets()
        }
    }
    
    // MARK: - Load Recent Presets
    
    private func loadRecentPresets() {
        // In a real implementation, this would load from UserDefaults or a database
        // For now, we'll get all presets and sort by updatedAt
        let allPresets = viewModel.banks.flatMap { $0.presets }
        recentPresets = allPresets
            .sorted { $0.updatedAt > $1.updatedAt }
            .prefix(20)
            .map { $0 }
    }
}

// MARK: - Preset Row View

private struct PresetRowView: View {
    let preset: Preset
    
    var body: some View {
        HStack(spacing: 12) {
            // Color indicator
            Rectangle()
                .fill(Color(hex: preset.color))
                .frame(width: 4, height: 40)
                .cornerRadius(2)
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(preset.displayName)
                    .font(.body)
                
                HStack(spacing: 8) {
                    Text(preset.author)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(preset.updatedAt.formatted(.relative(presentation: .named)))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Rating
            HStack(spacing: 2) {
                ForEach(0..<5) { star in
                    Image(systemName: star < preset.rating ? "star.fill" : "star")
                        .font(.caption)
                        .foregroundColor(star < preset.rating ? .yellow : .secondary)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .contentShape(Rectangle())
    }
}

// MARK: - Color Extension

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// MARK: - Preview

#Preview {
    let viewModel = LibrarianViewModel()
    // Add some test data
    let bank = Bank(name: "Test Bank", color: "#FF5733")
    let preset1 = Preset(name: "Lead Synth", author: "User", tags: ["Lead"], rating: 4, color: "#FF5733")
    let preset2 = Preset(name: "Bass Patch", author: "User", tags: ["Bass"], rating: 5, color: "#3357FF")
    bank.presets = [preset1, preset2]
    viewModel.banks = [bank]
    viewModel.selectedBank = bank
    
    return RecentPresetsView(viewModel: viewModel)
        .frame(width: 400, height: 500)
}
