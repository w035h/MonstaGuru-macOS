// ClipboardViewModel.swift
// MonstaGuru
// Created by Mistral Vibe Code (Clipboard Agent)

import SwiftUI
import SwiftData
import Data

/// ViewModel for the Clipboard, managing clipboard entries.
public final class ClipboardViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public var entries: [ClipboardEntry] = []
    @Published public var filteredEntries: [ClipboardEntry] = []
    
    @Published public var searchQuery: String = ""
    @Published public var filterType: FilterType = .all
    
    // MARK: - Filter Types
    
    public enum FilterType: String, CaseIterable {
        case all = "All"
        case program = "Programs"
        case oscillator = "Oscillators"
        case filter = "Filters"
        case envelope = "Envelopes"
        case lfo = "LFOs"
        case matrixSlot = "Matrix Slots"
        case effects = "Effects"
        case globalSettings = "Global Settings"
        case mixer = "Mixer"
    }
    
    // MARK: - Private Properties
    
    private var modelContainer: ModelContainer?
    
    // MARK: - Data Loading
    
    public func loadData(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        refreshData()
    }
    
    public func refreshData() {
        guard let modelContainer = modelContainer else { return }
        
        let fetchDescriptor = FetchDescriptor<ClipboardEntry>(sortBy: [SortDescriptor(\ClipboardEntry.self, keyPath: \.createdAt, order: .reverse)])
        do {
            entries = try modelContainer.mainContext.fetch(fetchDescriptor)
            filterEntries()
        } catch {
            print("Error fetching clipboard entries: \(error)")
        }
    }
    
    // MARK: - Filtering
    
    public func filterEntries() {
        var entries = self.entries
        
        // Filter by search query
        if !searchQuery.isEmpty {
            entries = entries.filter { entry in
                entry.name.localizedCaseInsensitiveContains(searchQuery) ||
                (entry.description?.localizedCaseInsensitiveContains(searchQuery) ?? false)
            }
        }
        
        // Filter by type
        if filterType != .all {
            entries = entries.filter { entry in
                entry.type == filterType.toClipboardEntryType()
            }
        }
        
        filteredEntries = entries
    }
    
    private func toClipboardEntryType() -> ClipboardEntryType {
        switch self {
        case .all: return .program
        case .program: return .program
        case .oscillator: return .oscillator
        case .filter: return .filter
        case .envelope: return .envelope
        case .lfo: return .lfo
        case .matrixSlot: return .matrixSlot
        case .effects: return .effects
        case .globalSettings: return .globalSettings
        case .mixer: return .mixer
        }
    }
    
    // MARK: - Entry Operations
    
    public func createEntry(
        name: String,
        entryType: ClipboardEntryType,
        data: Data? = nil,
        description: String? = nil
    ) -> ClipboardEntry {
        guard let modelContainer = modelContainer else { fatalError("Model container not set") }
        
        let entry = ClipboardEntry(
            type: entryType,
            name: name,
            data: data ?? Data(),
            notes: description ?? ""
        )
        modelContainer.mainContext.insert(entry)
        saveContext()
        refreshData()
        return entry
    }
    
    public func renameEntry(_ entry: ClipboardEntry) {
        // Implementation for renaming an entry
        // This would typically show a dialog
    }
    
    public func duplicateEntry(_ entry: ClipboardEntry) {
        guard let modelContainer = modelContainer else { return }
        
        let newEntry = ClipboardEntry(
            type: entry.type,
            name: entry.name + " Copy",
            data: entry.data,
            notes: entry.notes
        )
        modelContainer.mainContext.insert(newEntry)
        saveContext()
        refreshData()
    }
    
    public func deleteEntry(_ entry: ClipboardEntry) {
        guard let modelContainer = modelContainer else { return }
        
        modelContainer.mainContext.delete(entry)
        saveContext()
        refreshData()
    }
    
    public func clearAll() {
        guard let modelContainer = modelContainer else { return }
        
        for entry in entries {
            modelContainer.mainContext.delete(entry)
        }
        saveContext()
        refreshData()
    }
    
    // MARK: - Clipboard Operations
    
    public func copyToClipboard(_ data: Data, name: String, entryType: ClipboardEntryType, description: String? = nil) {
        let entry = createEntry(
            name: name,
            entryType: entryType,
            data: data,
            description: description
        )
        // Also copy to system clipboard
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setData(data, forType: .pdf) // Using PDF type as placeholder
    }
    
    public func pasteSelected() {
        // Paste the selected entry to the current editor
        // This would be handled by the ProgramEditorViewModel
    }
    
    public func pasteEntry(_ entry: ClipboardEntry) -> Data? {
        return entry.data
    }
    
    // MARK: - Private Methods
    
    private func saveContext() {
        guard let modelContainer = modelContainer else { return }
        
        do {
            try modelContainer.mainContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}

// MARK: - FilterType Extension

private extension ClipboardViewModel.FilterType {
    func toClipboardEntryType() -> ClipboardEntryType {
        switch self {
        case .all: return .program
        case .program: return .program
        case .oscillator: return .oscillator
        case .filter: return .filter
        case .envelope: return .envelope
        case .lfo: return .lfo
        case .matrixSlot: return .matrixSlot
        case .effects: return .effects
        case .globalSettings: return .globalSettings
        case .mixer: return .mixer
        }
    }
}
