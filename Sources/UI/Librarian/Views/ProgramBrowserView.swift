// ProgramBrowserView.swift
// MonstaGuru
// Created by Mistral Vibe Code (Librarian Agent)

import SwiftUI
import Data

/// View for browsing presets in a grid or list format.
public struct ProgramBrowserView: View {
    
    @ObservedObject public var viewModel: LibrarianViewModel
    
    // MARK: - Body
    
    public var body: some View {
        Group {
            switch viewModel.viewMode {
            case .grid:
                gridView
            case .list:
                listView
            }
        }
        .animation(.default, value: viewModel.viewMode)
    }
    
    // MARK: - Grid View
    
    private var gridView: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 16)], spacing: 16) {
                ForEach(viewModel.filteredPresets) { preset in
                    PresetCardView(preset: preset, isSelected: viewModel.selectedPreset?.id == preset.id)
                        .onTapGesture {
                            viewModel.selectedPreset = preset
                        }
                        .contextMenu {
                            presetContextMenu(for: preset)
                        }
                }
            }
            .padding()
        }
    }
    
    // MARK: - List View
    
    private var listView: some View {
        List(viewModel.filteredPresets, selection: $viewModel.selectedPreset) { preset in
            PresetRowView(preset: preset)
                .tag(preset)
                .contextMenu {
                    presetContextMenu(for: preset)
                }
        }
        .listStyle(.plain)
    }
    
    // MARK: - Preset Card View
    
    @ViewBuilder
    private func PresetCardView(preset: Preset, isSelected: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Color bar
            Rectangle()
                .fill(Color(hex: preset.color))
                .frame(height: 4)
            
            // Name and author
            Text(preset.displayName)
                .font(.headline)
                .lineLimit(2)
            
            // Tags
            if !preset.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(preset.tags.prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(4)
                    }
                    if preset.tags.count > 3 {
                        Text("+$0".replacingOccurrences(of: "$0", with: "\(preset.tags.count - 3)"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Rating
            HStack(spacing: 2) {
                ForEach(0..<5) { star in
                    Image(systemName: star < preset.rating ? "star.fill" : "star")
                        .font(.caption)
                        .foregroundColor(star < preset.rating ? .yellow : .secondary)
                }
            }
            
            Spacer()
            
            // Author and date
            HStack {
                Text(preset.author)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(preset.createdAt.formatted(.relative(presentation: .named)))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .frame(minWidth: 120, maxWidth: .infinity, alignment: .leading)
        .background(isSelected ? Color.accentColor.opacity(0.2) : Color(.controlBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
        )
        .accessibilityLabel(preset.displayName)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
    
    // MARK: - Preset Row View
    
    @ViewBuilder
    private func PresetRowView(preset: Preset) -> some View {
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
                    
                    if !preset.tags.isEmpty {
                        Text(preset.tags.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
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
            
            // Date
            Text(preset.createdAt.formatted(.relative(presentation: .named)))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .contentShape(Rectangle())
    }
    
    // MARK: - Context Menu
    
    @ViewBuilder
    private func presetContextMenu(for preset: Preset) -> some View {
        Group {
            Button("Edit") {
                viewModel.selectedPreset = preset
                // Edit action would be handled by parent view
            }
            
            Button("Duplicate") {
                viewModel.createPresetFromCurrentProgram(name: preset.name + " (Copy)", program: preset.program ?? Program.newProgram())
            }
            
            Button("Delete") {
                viewModel.itemToDelete = (type: .preset, id: preset.id)
                viewModel.isShowingDeleteConfirmation = true
            }
            
            Divider()
            
            Button("Send to Hardware") {
                if let program = preset.program {
                    try? viewModel.sendProgramToHardware()
                }
            }
            
            Button("Load in Editor") {
                viewModel.selectedPreset = preset
                viewModel.selectedProgram = preset.program
            }
        }
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
    // Create a test bank with presets
    let bank = Bank(name: "Test Bank", color: "#FF5733")
    let preset1 = Preset(name: "Lead Synth", author: "User", tags: ["Lead", "Synth"], rating: 4, color: "#FF5733")
    let preset2 = Preset(name: "Bass Patch", author: "User", tags: ["Bass", "Deep"], rating: 5, color: "#3357FF")
    bank.presets = [preset1, preset2]
    viewModel.banks = [bank]
    viewModel.selectedBank = bank
    
    return ProgramBrowserView(viewModel: viewModel)
        .frame(width: 600, height: 400)
}
