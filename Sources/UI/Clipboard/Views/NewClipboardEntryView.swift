// NewClipboardEntryView.swift
// MonstaGuru
// Created by Mistral Vibe Code (Clipboard Agent)

import SwiftUI
import Data

/// View for creating a new clipboard entry.
public struct NewClipboardEntryView: View {
    
    @Environment(\.
        dismiss) private var dismiss
    @Environment(\.
        modelContainer) private var modelContainer
    
    @ObservedObject public var viewModel: ClipboardViewModel
    
    @State private var name: String = ""
    @State private var entryType: ClipboardEntryType = .program
    @State private var description: String = ""
    
    // MARK: - Main View
    
    public var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Header
            Text("New Clipboard Entry")
                .font(DesignSystem.Typography.title)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
            
            // Form
            Form {
                TextField("Entry Name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .help("Enter a name for the new clipboard entry")
                
                Picker("Entry Type", selection: $entryType) {
                    ForEach(ClipboardEntryType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .help("Select the type of data this entry contains")
                
                TextEditor(text: $description)
                    .frame(minHeight: 100)
                    .padding(DesignSystem.Spacing.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                            .stroke(DesignSystem.Colors.border, lineWidth: 1)
                    )
                    .help("Enter a description for this entry")
            }
            .formStyle(.grouped)
            .frame(width: 400)
            
            // Actions
            HStack(spacing: DesignSystem.Spacing.md) {
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle()
                
                Button("Create") {
                    createEntry()
                }
                .buttonStyle(isPrimary: true)
                .disabled(name.isEmpty)
                .keyboardShortcut(.return, modifiers: [])
            }
        }
        .padding(DesignSystem.Spacing.xl)
        .frame(width: 500, height: 450)
    }
    
    // MARK: - Actions
    
    private func createEntry() {
        let entry = viewModel.createEntry(
            name: name,
            entryType: entryType,
            data: nil, // Data would be set from the current selection
            description: description.isEmpty ? nil : description
        )
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    NewClipboardEntryView(viewModel: ClipboardViewModel())
        .frame(width: 500, height: 450)
}
