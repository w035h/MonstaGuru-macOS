// NewPresetView.swift
// MonstaGuru
// Created by Mistral Vibe Code (Librarian Agent)

import SwiftUI
import Data

/// View for creating a new preset.
public struct NewPresetView: View {
    
    @Environment(\.
        dismiss) private var dismiss
    @Environment(\.
        modelContainer) private var modelContainer
    
    @ObservedObject public var viewModel: LibrarianViewModel
    
    public let bank: Bank?
    
    @State private var name: String = ""
    @State private var author: String = ""
    @State private var tags: String = ""
    @State private var notes: String = ""
    @State private var color: String = "#4A90E2"
    @State private var rating: Int = 0
    
    // MARK: - Main View
    
    public var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Header
            Text("New Preset")
                .font(DesignSystem.Typography.title)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
            
            // Form
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.md) {
                    TextField("Preset Name", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .help("Enter a name for the new preset")
                    
                    TextField("Author", text: $author)
                        .textFieldStyle(.roundedBorder)
                        .help("Enter the author name")
                    
                    TextField("Tags (comma separated)", text: $tags)
                        .textFieldStyle(.roundedBorder)
                        .help("Enter tags separated by commas")
                    
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                        .padding(DesignSystem.Spacing.sm)
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                .stroke(DesignSystem.Colors.border, lineWidth: 1)
                        )
                        .help("Enter notes or description")
                    
                    HStack {
                        Text("Color")
                        
                        Spacer()
                        
                        ColorPicker(selection: Color(hex: color))
                        
                        Text(color)
                            .font(DesignSystem.Typography.monospaced)
                            .foregroundStyle(DesignSystem.Colors.textTertiary)
                    }
                    
                    HStack {
                        Text("Rating")
                        
                        Spacer()
                        
                        StarRating(rating: $rating)
                    }
                }
                .frame(width: 400)
            }
            
            // Actions
            HStack(spacing: DesignSystem.Spacing.md) {
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle()
                
                Button("Create") {
                    createPreset()
                }
                .buttonStyle(isPrimary: true)
                .disabled(name.isEmpty)
                .keyboardShortcut(.return, modifiers: [])
            }
        }
        .padding(DesignSystem.Spacing.xl)
        .frame(width: 500, height: 500)
    }
    
    // MARK: - Actions
    
    private func createPreset() {
        let parsedTags = tags
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        let preset = viewModel.createPreset(
            name: name,
            author: author.isEmpty ? "Unknown" : author,
            tags: parsedTags,
            rating: rating,
            notes: notes,
            program: nil, // Will be set later from current editor
            color: color,
            bank: bank
        )
        dismiss()
    }
}

// MARK: - Star Rating

private struct StarRating: View {
    @Binding var rating: Int
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { star in
                Button(action: { rating = star + 1 }) {
                    Image(systemName: star < rating ? "star.fill" : "star")
                        .foregroundStyle(DesignSystem.Colors.accentOrange)
                        .font(DesignSystem.Typography.title3)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NewPresetView(viewModel: LibrarianViewModel(), bank: nil)
        .frame(width: 500, height: 500)
}
