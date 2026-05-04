// PresetEditorView.swift
// MonstaGuru
// Created by Mistral Vibe Code (Librarian Agent)

import SwiftUI
import Data

/// View for editing preset properties.
public struct PresetEditorView: View {
    
    @StateObject private var viewModel: PresetEditorViewModel
    
    @Environment(\dismiss) private var dismiss
    
    // MARK: - State
    
    @State private var showValidationAlert = false
    @State private var newTag: String = ""
    @State private var showTagSuggestions = false
    
    // MARK: - Initialization
    
    public init(viewModel: PresetEditorViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    public var body: some View {
        NavigationStack {
            Form {
                // Name and Author Section
                Section(header: Text("Preset Information")) {
                    TextField("Preset Name", text: $viewModel.name)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Author", text: $viewModel.author)
                        .textFieldStyle(.roundedBorder)
                }
                
                // Color Section
                Section(header: Text("Color")) {
                    HStack {
                        Text("Preset Color")
                        
                        Spacer()
                        
                        ColorPicker("", selection: Binding(
                            get: { viewModel.swiftUIColor },
                            set: { newColor in
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
                    
                    // Color Presets
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
                        }
                    }
                }
                
                // Tags Section
                Section(header: Text("Tags")) {
                    // Current tags
                    if !viewModel.tags.isEmpty {
                        HStack(spacing: 8) {
                            ForEach(viewModel.tags, id: \.self) { tag in
                                HStack(spacing: 4) {
                                    Text(tag)
                                        .font(.caption)
                                    
                                    Button(action: { viewModel.removeTag(tag) }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.secondary.opacity(0.2))
                                .cornerRadius(4)
                            }
                        }
                    } else {
                        Text("No tags")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    // Add tag
                    HStack(spacing: 8) {
                        TextField("Add tag", text: $newTag)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit {
                                addNewTag()
                            }
                        
                        Button(action: addNewTag) {
                            Image(systemName: "plus")
                                .frame(width: 30, height: 30)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                        .disabled(newTag.isEmpty)
                    }
                    
                    // Tag suggestions
                    if showTagSuggestions && !newTag.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(viewModel.allAvailableTags.filter { 
                                    $0.localizedCaseInsensitiveContains(newTag) 
                                }, id: \.self) { tag in
                                    Button(action: { newTag = tag; addNewTag() }) {
                                        Text(tag)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.accentColor.opacity(0.2))
                                            .cornerRadius(4)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                }
                
                // Rating Section
                Section(header: Text("Rating")) {
                    HStack(spacing: 8) {
                        ForEach(0..<5) { star in
                            Button(action: { viewModel.rating = star + 1 }) {
                                Image(systemName: star < viewModel.rating ? "star.fill" : "star")
                                    .font(.title2)
                                    .foregroundColor(star < viewModel.rating ? .yellow : .secondary)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Rating $0".replacingOccurrences(of: "$0", with: "\(star + 1)"))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Notes Section
                Section(header: Text("Notes")) {
                    TextEditor(text: $viewModel.notes)
                        .frame(minHeight: 100)
                        .border(Color.separator, width: 1)
                        .cornerRadius(6)
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
                        savePreset()
                    }
                    .disabled(!viewModel.validate())
                }
            }
            
            .navigationTitle(viewModel.isNewPreset ? "New Preset" : "Edit Preset")
            .navigationSubtitle(viewModel.preset.displayName)
            
            // Alert
            .alert("Validation Error", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.validationError() ?? "Unknown error")
            }
        }
        .frame(minWidth: 500, minHeight: 400)
        .onChange(of: newTag) { _ in
            showTagSuggestions = !newTag.isEmpty
        }
    }
    
    // MARK: - Add New Tag
    
    private func addNewTag() {
        guard !newTag.isEmpty else { return }
        viewModel.addTag(newTag)
        newTag = ""
        showTagSuggestions = false
    }
    
    // MARK: - Save Preset
    
    private func savePreset() {
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
    let preset = Preset(
        name: "Test Preset",
        author: "Test User",
        tags: ["Lead", "Synth"],
        rating: 4,
        notes: "Test notes",
        color: "#FF5733"
    )
    let viewModel = PresetEditorViewModel(preset: preset)
    return PresetEditorView(viewModel: viewModel)
        .frame(width: 600, height: 500)
}
