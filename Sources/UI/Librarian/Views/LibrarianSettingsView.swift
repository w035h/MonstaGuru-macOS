// LibrarianSettingsView.swift
// MonstaGuru
// Created by Mistral Vibe Code (Librarian Agent)

import SwiftUI
import Data

/// View for configuring librarian settings and filters.
public struct LibrarianSettingsView: View {
    
    @ObservedObject public var viewModel: LibrarianViewModel
    
    // MARK: - State
    
    @State private var newTag: String = ""
    
    // MARK: - Body
    
    public var body: some View {
        NavigationStack {
            Form {
                // Filters Section
                Section(header: Text("Filters")) {
                    // Tags Filter
                    if !viewModel.allTags.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags")
                                .font(.subheadline)
                            
                            // Selected tags
                            if !viewModel.selectedTags.isEmpty {
                                HStack(spacing: 8) {
                                    ForEach(Array(viewModel.selectedTags), id: \.self) { tag in
                                        HStack(spacing: 4) {
                                            Text(tag)
                                                .font(.caption)
                                            
                                            Button(action: { viewModel.selectedTags.remove(tag) }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.accentColor.opacity(0.2))
                                        .cornerRadius(4)
                                    }
                                }
                            } else {
                                Text("No tags selected")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            // Tag picker
                            Picker("Add Tag", selection: $newTag) {
                                Text("Select a tag...").tag("")
                                ForEach(viewModel.allTags, id: \.self) { tag in
                                    Text(tag).tag(tag)
                                }
                            }
                            .pickerStyle(.menu)
                            .onChange(of: newTag) { newValue in
                                if !newValue.isEmpty {
                                    viewModel.selectedTags.insert(newValue)
                                    newTag = ""
                                }
                            }
                        }
                    } else {
                        Text("No tags available")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Rating Filter
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Minimum Rating")
                            .font(.subheadline)
                        
                        Slider(value: Binding(
                            get: { Double(viewModel.minRating) },
                            set: { viewModel.minRating = Int($0.rounded()) }
                        ), in: 0...5, step: 1)
                        
                        HStack(spacing: 4) {
                            ForEach(0..<6) { star in
                                Image(systemName: star <= viewModel.minRating ? "star.fill" : "star")
                                    .font(.caption)
                                    .foregroundColor(star <= viewModel.minRating ? .yellow : .secondary)
                            }
                        }
                    }
                    
                    // Favorites Toggle
                    Toggle("Show Favorites Only", isOn: $viewModel.showFavoritesOnly)
                }
                
                // Actions Section
                Section {
                    Button("Reset All Filters") {
                        viewModel.resetFilters()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .formStyle(.grouped)
            .padding()
            
            // Toolbar
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        // Dismiss action handled by parent
                    }
                }
            }
            
            .navigationTitle("Filter Settings")
        }
        .frame(minWidth: 300, minHeight: 400)
    }
}

// MARK: - Preview

#Preview {
    let viewModel = LibrarianViewModel()
    // Add some test data
    let bank = Bank(name: "Test Bank", color: "#FF5733")
    let preset1 = Preset(name: "Lead", author: "User", tags: ["Lead", "Synth"], rating: 4)
    let preset2 = Preset(name: "Bass", author: "User", tags: ["Bass", "Deep"], rating: 5)
    bank.presets = [preset1, preset2]
    viewModel.banks = [bank]
    viewModel.selectedBank = bank
    
    return LibrarianSettingsView(viewModel: viewModel)
        .frame(width: 400, height: 500)
}
