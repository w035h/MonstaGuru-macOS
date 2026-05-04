// BankEditorView.swift
// MonstaGuru
// Created by Mistral Vibe Code (Librarian Agent)

import SwiftUI
import Data

/// View for editing bank properties.
public struct BankEditorView: View {
    
    @StateObject private var viewModel: BankEditorViewModel
    
    @Environment(\dismiss) private var dismiss
    
    // MARK: - State
    
    @State private var showValidationAlert = false
    
    // MARK: - Initialization
    
    public init(viewModel: BankEditorViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    public var body: some View {
        NavigationStack {
            Form {
                // Name Section
                Section(header: Text("Bank Information")) {
                    TextField("Bank Name", text: $viewModel.name)
                        .textFieldStyle(.roundedBorder)
                    
                    // Color Picker
                    HStack {
                        Text("Color")
                        
                        Spacer()
                        
                        ColorPicker("", selection: Binding(
                            get: { viewModel.swiftUIColor },
                            set: { newColor in
                                // Convert Color to hex string
                                if let components = newColor.cgColor?.components {
                                    let r = Int(components[0] * 255)
                                    let g = Int(components[1] * 255)
                                    let b = Int(components[2] * 255)
                                    viewModel.color = String(format: "#%02X%02X%02X", r, g, b)
                                }
                            }
                        ))
                        .labelsHidden()
                        .frame(width: 40, height: 40)
                    }
                }
                
                // Color Presets
                Section(header: Text("Color Presets")) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 30), spacing: 8)], spacing: 8) {
                        ForEach(viewModel.availableColors, id: \.self) { colorHex in
                            Button(action: { viewModel.color = colorHex }) {
                                Circle()
                                    .fill(Color(hex: colorHex))
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(viewModel.color == colorHex ? Color.white : Color.clear, lineWidth: 2)
                                    )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Color $0".replacingOccurrences(of: "$0", with: "\(colorHex)"))
                    }
                }
            }
            .formStyle(.grouped)
            .padding()
            
            // Toolbar
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveBank()
                    }
                    .disabled(!viewModel.validate())
                }
            }
            
            .navigationTitle(viewModel.isNewBank ? "New Bank" : "Edit Bank")
            .navigationSubtitle(viewModel.bank.displayName)
            
            // Alert
            .alert("Validation Error", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.validationError() ?? "Unknown error")
            }
        }
        .frame(minWidth: 400, minHeight: 300)
    }
    
    // MARK: - Save Bank
    
    private func saveBank() {
        do {
            try viewModel.save()
            dismiss()
        } catch {
            showValidationAlert = true
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
    let bank = Bank(name: "Test Bank", color: "#FF5733")
    let viewModel = BankEditorViewModel(bank: bank)
    return BankEditorView(viewModel: viewModel)
        .frame(width: 500, height: 400)
}
