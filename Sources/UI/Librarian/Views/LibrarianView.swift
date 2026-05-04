// LibrarianView.swift
// MonstaGuru
// Created by Mistral Vibe Code (Librarian Agent)

import SwiftUI
import Data
import MIDI

/// Main view for the Librarian functionality.
/// Provides a browser interface for managing banks, presets, and programs.
public struct LibrarianView: View {
    
    @StateObject private var viewModel: LibrarianViewModel
    
    // MARK: - State for Sheets
    
    @State private var isShowingBankEditor = false
    @State private var isShowingPresetEditor = false
    @State private var isShowingImportExport = false
    @State private var isShowingSettings = false
    
    // MARK: - Initialization
    
    public init(viewModel: LibrarianViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    public var body: some View {
        NavigationSplitView {
            // Sidebar: Bank List
            bankSidebarView
                .navigationTitle("Libraries")
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        addBankButton
                    }
                }
        } content: {
            // Content: Preset List
            presetContentView
                .navigationTitle(viewModel.selectedBank?.displayName ?? "No Bank Selected")
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        filterControlsView
                    }
                }
        } detail: {
            // Detail: Preset/Program Details
            presetDetailView
                .navigationTitle(viewModel.selectedPreset?.displayName ?? "No Preset Selected")
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        detailToolbarView
                    }
                }
        }
        .frame(minWidth: 800, minHeight: 600)
        .navigationTitle("Librarian")
        
        // Sheets
        .sheet(isPresented: $isShowingBankEditor) {
            BankEditorView(viewModel: BankEditorViewModel(bank: viewModel.selectedBank))
                .frame(minWidth: 400, minHeight: 300)
        }
        .sheet(isPresented: $isShowingPresetEditor) {
            if let preset = viewModel.selectedPreset {
                PresetEditorView(viewModel: PresetEditorViewModel(preset: preset))
                    .frame(minWidth: 500, minHeight: 400)
            }
        }
        .sheet(isPresented: $isShowingImportExport) {
            ImportExportView(viewModel: viewModel)
                .frame(minWidth: 500, minHeight: 400)
        }
        .sheet(isPresented: $isShowingSettings) {
            LibrarianSettingsView(viewModel: viewModel)
                .frame(minWidth: 400, minHeight: 300)
        }
        
        // Alerts
        .alert("Delete Confirmation", isPresented: $viewModel.isShowingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                handleDeleteConfirmation()
            }
        } message: {
            if let item = viewModel.itemToDelete {
                switch item.type {
                case .bank:
                    Text("Are you sure you want to delete this bank and all its presets?")
                case .preset:
                    Text("Are you sure you want to delete this preset?")
                }
            }
        }
        .onAppear {
            viewModel.loadBanks()
        }
    }
    
    // MARK: - Bank Sidebar View
    
    private var bankSidebarView: some View {
        List(selection: $viewModel.selectedBank) {
            // All Banks Section
            Section(header: Text("Banks")) {
                ForEach(viewModel.banks) { bank in
                    NavigationLink(value: bank) {
                        HStack(spacing: 8) {
                            // Color indicator
                            Circle()
                                .fill(Color(hex: bank.color))
                                .frame(width: 12, height: 12)
                            
                            // Bank name and count
                            VStack(alignment: .leading, spacing: 2) {
                                Text(bank.displayName)
                                    .font(.body)
                                Text("$0 presets".replacingOccurrences(of: "$0", with: "\(bank.presetCount)"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Context menu
                            Menu {
                                Button("Edit Bank") {
                                    viewModel.selectedBank = bank
                                    isShowingBankEditor = true
                                }
                                
                                Button("Delete Bank") {
                                    viewModel.itemToDelete = (type: .bank, id: bank.id)
                                    viewModel.isShowingDeleteConfirmation = true
                                }
                                
                                Divider()
                                
                                Button("New Preset") {
                                    viewModel.selectedBank = bank
                                    viewModel.createPreset(name: "New Preset")
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(.secondary)
                            }
                            .menuStyle(.bordered)
                        }
                        .tag(bank)
                        .contextMenu {
                            Button("Edit Bank") {
                                viewModel.selectedBank = bank
                                isShowingBankEditor = true
                            }
                            Button("Delete Bank") {
                                viewModel.itemToDelete = (type: .bank, id: bank.id)
                                viewModel.isShowingDeleteConfirmation = true
                            }
                        }
                }
            }
            
            // Smart Collections Section
            Section(header: Text("Smart Collections")) {
                Button(action: { viewModel.showFavoritesOnly.toggle() }) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Favorites")
                        Spacer()
                        if viewModel.showFavoritesOnly {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                .buttonStyle(.plain)
                
                NavigationLink {
                    RecentPresetsView(viewModel: viewModel)
                } label: {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                        Text("Recent")
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                Button(action: { isShowingSettings = true }) {
                    Label("Settings", systemImage: "gear")
                }
                .buttonStyle(.bordered)
                .padding(.trailing, 16)
                .padding(.bottom, 8)
            }
        }
    }
    
    // MARK: - Preset Content View
    
    private var presetContentView: some View {
        Group {
            if viewModel.selectedBank == nil {
                ContentUnavailableView(
                    "No Bank Selected",
                    systemImage: "folder",
                    description: Text("Select a bank from the sidebar to view its presets")
                )
            } else if viewModel.filteredPresets.isEmpty {
                ContentUnavailableView(
                    "No Presets",
                    systemImage: "music.note.list",
                    description: Text("This bank has no presets. Create one to get started.")
                )
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: { viewModel.createPreset(name: "New Preset") }) {
                            Label("New Preset", systemImage: "plus")
                        }
                    }
                }
            } else {
                ProgramBrowserView(viewModel: viewModel)
            }
        }
    }
    
    // MARK: - Preset Detail View
    
    private var presetDetailView: some View {
        Group {
            if let preset = viewModel.selectedPreset {
                PresetDetailView(viewModel: viewModel, preset: preset)
            } else {
                ContentUnavailableView(
                    "No Preset Selected",
                    systemImage: "music.note",
                    description: Text("Select a preset to view its details")
                )
            }
        }
    }
    
    // MARK: - Filter Controls View
    
    private var filterControlsView: some View {
        HStack(spacing: 8) {
            // Search field
            SearchField(text: $viewModel.searchQuery, placeholder: "Search presets...")
                .frame(width: 200)
            
            // View mode toggle
            Picker("View", selection: $viewModel.viewMode) {
                ForEach(LibrarianViewModel.ViewMode.allCases) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 120)
            
            // Sort menu
            Menu {
                Picker("Sort", selection: $viewModel.sortOrder) {
                    ForEach(LibrarianViewModel.PresetSortOrder.allCases) { order in
                        Text(order.displayName).tag(order)
                    }
                }
                .pickerStyle(.inline)
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            }
            .menuStyle(.bordered)
            
            // Filter button
            Button(action: { isShowingSettings = true }) {
                Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
            }
            .menuStyle(.bordered)
            .popover(isPresented: $isShowingSettings) {
                LibrarianSettingsView(viewModel: viewModel)
                    .frame(width: 300)
            }
        }
    }
    
    // MARK: - Detail Toolbar View
    
    private var detailToolbarView: some View {
        HStack(spacing: 8) {
            if let preset = viewModel.selectedPreset {
                Button(action: { isShowingPresetEditor = true }) {
                    Label("Edit", systemImage: "pencil")
                }
                
                Button(action: { viewModel.createPresetFromCurrentProgram(name: preset.name + " (Copy)", program: preset.program ?? Program.newProgram()) }) {
                    Label("Duplicate", systemImage: "doc.on.doc")
                }
                
                Button(action: { viewModel.itemToDelete = (type: .preset, id: preset.id); viewModel.isShowingDeleteConfirmation = true }) {
                    Label("Delete", systemImage: "trash")
                }
                .foregroundColor(.red)
            }
            
            Button(action: { isShowingImportExport = true }) {
                Label("Import/Export", systemImage: "folder")
            }
        }
    }
    
    // MARK: - Add Bank Button
    
    private var addBankButton: some View {
        Button(action: { viewModel.createBank(); isShowingBankEditor = true }) {
            Label("Add Bank", systemImage: "plus")
        }
    }
    
    // MARK: - Delete Confirmation Handler
    
    private func handleDeleteConfirmation() {
        guard let item = viewModel.itemToDelete else { return }
        
        switch item.type {
        case .bank:
            if let bank = viewModel.banks.first(where: { $0.id == item.id }) {
                viewModel.deleteBank(bank)
            }
        case .preset:
            if let preset = viewModel.selectedBank?.presets.first(where: { $0.id == item.id }) {
                viewModel.deletePreset(preset)
            }
        }
        
        viewModel.itemToDelete = nil
    }
}

// MARK: - Search Field

private struct SearchField: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(.roundedBorder)
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 8)
                    
                    if !text.isEmpty {
                        Button(action: { text = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .padding(.trailing, 8)
                        }
                        .buttonStyle(.plain)
                    }
                }
            )
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
    return LibrarianView(viewModel: viewModel)
        .frame(width: 1200, height: 800)
}
