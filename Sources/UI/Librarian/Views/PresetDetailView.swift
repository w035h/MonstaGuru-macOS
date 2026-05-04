// PresetDetailView.swift
// MonstaGuru
// Created by Mistral Vibe Code (Librarian Agent)

import SwiftUI
import Data

/// View for displaying detailed information about a preset.
public struct PresetDetailView: View {
    
    @ObservedObject public var viewModel: LibrarianViewModel
    @State public var preset: Preset
    
    // MARK: - Body
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerView
                
                Divider()
                
                // Program Preview
                if let program = preset.program {
                    programPreviewView(program: program)
                    Divider()
                }
                
                // Metadata
                metadataView
                
                // Notes
                if !preset.notes.isEmpty {
                    Divider()
                    notesView
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 16) {
            // Color banner
            Rectangle()
                .fill(Color(hex: preset.color))
                .frame(height: 60)
                .overlay(
                    VStack {
                        // Rating
                        HStack(spacing: 4) {
                            ForEach(0..<5) { star in
                                Image(systemName: star < preset.rating ? "star.fill" : "star")
                                    .font(.title3)
                                    .foregroundColor(star < preset.rating ? .yellow : .white.opacity(0.5))
                            }
                        }
                    }
                )
            
            // Name and author
            VStack(spacing: 4) {
                Text(preset.displayName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                HStack(spacing: 8) {
                    Text("by $0".replacingOccurrences(of: "$0", with: "\(preset.author)"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(preset.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Tags
            if !preset.tags.isEmpty {
                HStack(spacing: 8) {
                    ForEach(preset.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
            }
        }
    }
    
    // MARK: - Program Preview View
    
    @ViewBuilder
    private func programPreviewView(program: Program) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Program Preview")
                .font(.headline)
            
            // Program name and number
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Name")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(program.name)
                        .font(.body)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Number")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$0".replacingOccurrences(of: "$0", with: "\(program.number)"))
                        .font(.body)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Last Updated")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(program.updatedAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.body)
                }
            }
            
            // Quick stats
            HStack(spacing: 16) {
                statView(label: "Oscillators", value: "3")
                statView(label: "Filters", value: "2")
                statView(label: "LFOs", value: "3")
                statView(label: "Effects", value: "3")
            }
            
            // Send to Hardware button
            Button(action: { try? viewModel.sendProgramToHardware() }) {
                Label("Send to Hardware", systemImage: "arrow.up.square")
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.midiManager.isOutputConnected)
        }
    }
    
    // MARK: - Stat View
    
    @ViewBuilder
    private func statView(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
        }
        .frame(minWidth: 80)
    }
    
    // MARK: - Metadata View
    
    private var metadataView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Metadata")
                .font(.headline)
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ID")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(preset.id.uuidString.prefix(8))
                        .font(.body)
                        .monospaced()
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Created")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(preset.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.body)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Updated")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(preset.updatedAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.body)
                }
            }
        }
    }
    
    // MARK: - Notes View
    
    private var notesView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.headline)
            
            Text(preset.notes)
                .font(.body)
                .padding(12)
                .background(Color(.controlBackgroundColor))
                .cornerRadius(8)
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
    let program = Program(name: "Test Program", number: 1)
    let preset = Preset(
        name: "Lead Synth",
        author: "Test User",
        tags: ["Lead", "Synth", "Bright"],
        rating: 4,
        notes: "A bright lead synth patch with detuned oscillators for a wide sound.",
        program: program,
        color: "#FF5733"
    )
    
    return PresetDetailView(viewModel: viewModel, preset: preset)
        .frame(width: 400, height: 600)
}
