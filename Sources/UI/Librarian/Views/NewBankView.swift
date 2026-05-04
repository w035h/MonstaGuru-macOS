// NewBankView.swift
// MonstaGuru
// Created by Mistral Vibe Code (Librarian Agent)

import SwiftUI
import Data

/// View for creating a new bank.
public struct NewBankView: View {
    
    @Environment(\.
        dismiss) private var dismiss
    @Environment(\.
        modelContainer) private var modelContainer
    
    @ObservedObject public var viewModel: LibrarianViewModel
    
    @State private var name: String = ""
    @State private var color: String = "#333333"
    @State private var showColorPicker: Bool = false
    
    // MARK: - Main View
    
    public var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Header
            Text("New Bank")
                .font(DesignSystem.Typography.title)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
            
            // Form
            Form {
                TextField("Bank Name", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .help("Enter a name for the new bank")
                
                HStack {
                    Text("Color")
                    
                    Spacer()
                    
                    ColorPicker(selection: Color(hex: color)) {
                        Text("Select Color")
                    }
                    .labelsHidden()
                    .onChange(of: color) { _ in
                        // Color changed
                    }
                    
                    Text(color)
                        .font(DesignSystem.Typography.monospaced)
                        .foregroundStyle(DesignSystem.Colors.textTertiary)
                }
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
                    createBank()
                }
                .buttonStyle(isPrimary: true)
                .disabled(name.isEmpty)
                .keyboardShortcut(.return, modifiers: [])
            }
        }
        .padding(DesignSystem.Spacing.xl)
        .frame(width: 500)
    }
    
    // MARK: - Actions
    
    private func createBank() {
        let bank = viewModel.createBank(name: name, color: color)
        dismiss()
    }
}

// MARK: - Color Picker

private struct ColorPicker: View {
    @Binding var selection: Color
    let label: () -> Text
    
    @State private var showPicker: Bool = false
    
    var body: some View {
        Button(action: { showPicker = true }) {
            Circle()
                .fill(selection)
                .frame(width: 32, height: 32)
                .overlay(
                    Circle()
                        .stroke(DesignSystem.Colors.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showPicker) {
            ColorPickerView(selection: $selection)
                .padding(DesignSystem.Spacing.md)
                .frame(width: 250)
        }
    }
}

private struct ColorPickerView: View {
    @Binding var selection: Color
    
    let colors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink,
        .gray, .black, .white, .primary, .secondary
    ]
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Current color
            Circle()
                .fill(selection)
                .frame(width: 64, height: 64)
                .overlay(
                    Circle()
                        .stroke(DesignSystem.Colors.border, lineWidth: 2)
                )
            
            // Preset colors
            LazyVGrid(columns: [GridItem(.flexible(), spacing: DesignSystem.Spacing.sm)], spacing: DesignSystem.Spacing.sm) {
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .stroke(color == selection ? DesignSystem.Colors.primary : Color.clear, lineWidth: 2)
                        )
                        .onTapGesture {
                            selection = color
                        }
                }
            }
            
            // Hex input
            HStack {
                Text("Hex:")
                TextField("#RRGGBB", text: .constant(""))
                    .textFieldStyle(.roundedBorder)
                    .font(DesignSystem.Typography.monospaced)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NewBankView(viewModel: LibrarianViewModel())
        .frame(width: 500, height: 400)
}
