// LibrarianViewModel.swift
// MonstaGuru
// Created by Mistral Vibe Code (Librarian Agent)

import SwiftUI
import SwiftData
import Data
import MIDI

/// ViewModel for the Librarian, managing presets and banks.
public final class LibrarianViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public var banks: [Bank] = []
    @Published public var allPresets: [Preset] = []
    @Published public var filteredPresets: [Preset] = []
    
    @Published public var searchQuery: String = ""
    @Published public var sortOrder: SortOrder = .nameAscending
    
    // MARK: - Sort Order
    
    public enum SortOrder: String, CaseIterable {
        case nameAscending = "Name (A-Z)"
        case nameDescending = "Name (Z-A)"
        case dateNewest = "Date (Newest)"
        case dateOldest = "Date (Oldest)"
        case ratingHighest = "Rating (Highest)"
        case ratingLowest = "Rating (Lowest)"
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
        
        let fetchDescriptor = FetchDescriptor<Bank>(sortBy: [SortDescriptor(\Bank.self, keyPath: \.name)])
        do {
            banks = try modelContainer.mainContext.fetch(fetchDescriptor)
        } catch {
            print("Error fetching banks: \(error)")
        }
        
        let presetFetchDescriptor = FetchDescriptor<Preset>(sortBy: [SortDescriptor(\Preset.self, keyPath: \.name)])
        do {
            allPresets = try modelContainer.mainContext.fetch(presetFetchDescriptor)
            filterPresets()
        } catch {
            print("Error fetching presets: \(error)")
        }
    }
    
    // MARK: - Filtering
    
    public func filterPresets() {
        var presets = allPresets
        
        // Filter by search query
        if !searchQuery.isEmpty {
            presets = presets.filter { preset in
                preset.name.localizedCaseInsensitiveContains(searchQuery) ||
                preset.author.localizedCaseInsensitiveContains(searchQuery) ||
                preset.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchQuery) }) ||
                preset.notes.localizedCaseInsensitiveContains(searchQuery)
            }
        }
        
        // Sort
        switch sortOrder {
        case .nameAscending:
            presets.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .nameDescending:
            presets.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
        case .dateNewest:
            presets.sort { $0.updatedAt > $1.updatedAt }
        case .dateOldest:
            presets.sort { $0.updatedAt < $1.updatedAt }
        case .ratingHighest:
            presets.sort { $0.rating > $1.rating }
        case .ratingLowest:
            presets.sort { $0.rating < $1.rating }
        }
        
        filteredPresets = presets
    }
    
    // MARK: - Bank Operations
    
    public func createBank(name: String, color: String = "#333333") -> Bank {
        guard let modelContainer = modelContainer else { fatalError("Model container not set") }
        
        let bank = Bank(name: name, color: color)
        modelContainer.mainContext.insert(bank)
        saveContext()
        refreshData()
        return bank
    }
    
    public func renameBank(_ bank: Bank) {
        // Implementation for renaming a bank
        // This would typically show a dialog
    }
    
    public func duplicateBank(_ bank: Bank) {
        guard let modelContainer = modelContainer else { return }
        
        let newBank = Bank(
            name: bank.name + " Copy",
            color: bank.color,
            presets: []
        )
        modelContainer.mainContext.insert(newBank)
        saveContext()
        refreshData()
    }
    
    public func deleteBank(_ bank: Bank) {
        guard let modelContainer = modelContainer else { return }
        
        // Remove all presets in the bank first
        for preset in bank.presets {
            modelContainer.mainContext.delete(preset)
        }
        
        modelContainer.mainContext.delete(bank)
        saveContext()
        refreshData()
    }
    
    // MARK: - Preset Operations
    
    public func createPreset(
        name: String,
        author: String = "Unknown",
        tags: [String] = [],
        rating: Int = 0,
        notes: String = "",
        program: Program? = nil,
        color: String = "#4A90E2",
        bank: Bank? = nil
    ) -> Preset {
        guard let modelContainer = modelContainer else { fatalError("Model container not set") }
        
        let preset = Preset(
            name: name,
            author: author,
            tags: tags,
            rating: rating,
            notes: notes,
            program: program,
            color: color,
            bank: bank
        )
        modelContainer.mainContext.insert(preset)
        saveContext()
        refreshData()
        return preset
    }
    
    public func editPreset(_ preset: Preset) {
        // Implementation for editing a preset
        // This would typically show a dialog
    }
    
    public func duplicatePreset(_ preset: Preset) {
        guard let modelContainer = modelContainer else { return }
        
        let newPreset = Preset(
            name: preset.name + " Copy",
            author: preset.author,
            tags: preset.tags,
            rating: preset.rating,
            notes: preset.notes,
            program: preset.program,
            color: preset.color,
            bank: preset.bank
        )
        modelContainer.mainContext.insert(newPreset)
        saveContext()
        refreshData()
    }
    
    public func deletePreset(_ preset: Preset) {
        guard let modelContainer = modelContainer else { return }
        
        modelContainer.mainContext.delete(preset)
        saveContext()
        refreshData()
    }
    
    public func removeFromBank(_ preset: Preset, bank: Bank) {
        preset.bank = nil
        saveContext()
        refreshData()
    }
    
    public func addToBank(_ preset: Preset, bank: Bank) {
        preset.bank = bank
        saveContext()
        refreshData()
    }
    
    // MARK: - MIDI Operations
    
    public func sendToDevice(preset: Preset, midiManager: MIDIManager) {
        guard let program = preset.program else { return }
        
        // Convert program to SysEx and send
        if let sysExData = SysExParser.programToSysEx(program: program) {
            midiManager.sendSysEx(sysExData)
        }
    }
    
    public func requestFromDevice(programNumber: Int, midiManager: MIDIManager) {
        // Request a specific program from the device
        let requestData: [UInt8] = [0xF0, 0x00, 0x20, 0x7F, 0x00, 0x01, UInt8(programNumber), 0xF7]
        midiManager.sendSysEx(requestData)
    }
    
    // MARK: - Import/Export
    
    public func importSysExFile(url: URL) {
        // Implementation for importing SysEx files
    }
    
    public func exportSysExFile(preset: Preset, url: URL) {
        // Implementation for exporting SysEx files
    }
    
    public func importBankFile(url: URL) {
        // Implementation for importing bank files
    }
    
    public func exportBankFile(bank: Bank, url: URL) {
        // Implementation for exporting bank files
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

// MARK: - Helper Extensions

public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
