// LibrarianViewModel.swift
// MonstaGuru
// Created by Mistral Vibe Code (Librarian Agent)

import Foundation
import SwiftUI
import Combine
import Data

/// Main ViewModel for the Librarian functionality.
/// Manages banks, presets, programs, and library operations.
public final class LibrarianViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// All banks in the library.
    @Published public var banks: [Bank] = []
    
    /// Currently selected bank.
    @Published public var selectedBank: Bank?
    
    /// Currently selected preset.
    @Published public var selectedPreset: Preset?
    
    /// Currently selected program.
    @Published public var selectedProgram: Program?
    
    /// Search query for filtering.
    @Published public var searchQuery: String = ""
    
    /// Selected tags for filtering.
    @Published public var selectedTags: Set<String> = []
    
    /// Minimum rating for filtering.
    @Published public var minRating: Int = 0
    
    /// Sort order for presets.
    @Published public var sortOrder: PresetSortOrder = .nameAscending
    
    /// View mode (grid or list).
    @Published public var viewMode: ViewMode = .grid
    
    /// Whether to show only favorites.
    @Published public var showFavoritesOnly: Bool = false
    
    /// Whether a bank is being edited.
    @Published public var isEditingBank: Bool = false
    
    /// Whether a preset is being edited.
    @Published public var isEditingPreset: Bool = false
    
    /// Whether import/export dialog is shown.
    @Published public var isShowingImportExport: Bool = false
    
    /// Whether to show delete confirmation.
    @Published public var isShowingDeleteConfirmation: Bool = false
    
    /// Item to delete (bank or preset).
    @Published public var itemToDelete: (type: DeleteItemType, id: UUID)?
    
    // MARK: - Public Properties
    
    /// The bank repository for data operations.
    public let bankRepository: BankRepositoryProtocol
    
    /// The preset repository for data operations.
    public let presetRepository: PresetRepositoryProtocol
    
    /// The program repository for data operations.
    public let programRepository: ProgramRepositoryProtocol
    
    /// The MIDI manager for hardware communication.
    public let midiManager: MIDIManager
    
    // MARK: - Computed Properties
    
    /// Filtered banks based on search query.
    public var filteredBanks: [Bank] {
        guard !searchQuery.isEmpty else { return banks }
        return banks.filter { bank in
            bank.name.localizedCaseInsensitiveContains(searchQuery) ||
            bank.presets.contains { preset in
                preset.name.localizedCaseInsensitiveContains(searchQuery) ||
                preset.tags.contains { tag in
                    tag.localizedCaseInsensitiveContains(searchQuery)
                }
            }
        }
    }
    
    /// Filtered presets in the selected bank.
    public var filteredPresets: [Preset] {
        guard let selectedBank = selectedBank else { return [] }
        
        var presets = selectedBank.presets
        
        // Filter by search query
        if !searchQuery.isEmpty {
            presets = presets.filter { preset in
                preset.name.localizedCaseInsensitiveContains(searchQuery) ||
                preset.author.localizedCaseInsensitiveContains(searchQuery) ||
                preset.notes.localizedCaseInsensitiveContains(searchQuery) ||
                preset.tags.contains { tag in
                    tag.localizedCaseInsensitiveContains(searchQuery)
                }
            }
        }
        
        // Filter by tags
        if !selectedTags.isEmpty {
            presets = presets.filter { preset in
                !Set(preset.tags).intersection(selectedTags).isEmpty
            }
        }
        
        // Filter by rating
        presets = presets.filter { $0.rating >= minRating }
        
        // Filter by favorites
        if showFavoritesOnly {
            presets = presets.filter { $0.rating >= 4 } // 4-5 stars = favorites
        }
        
        // Sort
        return sortPresets(presets, by: sortOrder)
    }
    
    /// All unique tags across all presets.
    public var allTags: [String] {
        var tags = Set<String>()
        for bank in banks {
            for preset in bank.presets {
                tags.formUnion(Set(preset.tags))
            }
        }
        return Array(tags).sorted()
    }
    
    /// Total number of presets across all banks.
    public var totalPresetCount: Int {
        banks.reduce(0) { $0 + $1.presets.count }
    }
    
    /// Whether there are any banks.
    public var hasBanks: Bool {
        !banks.isEmpty
    }
    
    /// Whether there are any presets in the selected bank.
    public var hasPresets: Bool {
        selectedBank?.presets.isEmpty == false
    }
    
    // MARK: - Private Properties
    
    /// Cancellables for Combine subscriptions.
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initialization
    
    public init(
        bankRepository: BankRepositoryProtocol = BankRepository(modelContext: try! ModelContext(ModelContainer(for: Bank.self))),
        presetRepository: PresetRepositoryProtocol = PresetRepository(modelContext: try! ModelContext(ModelContainer(for: Preset.self))),
        programRepository: ProgramRepositoryProtocol = ProgramRepository(modelContext: try! ModelContext(ModelContainer(for: Program.self))),
        midiManager: MIDIManager = MIDIManager()
    ) {
        self.bankRepository = bankRepository
        self.presetRepository = presetRepository
        self.programRepository = programRepository
        self.midiManager = midiManager
        
        loadBanks()
        setupSubscriptions()
    }
    
    // MARK: - Setup
    
    private func setupSubscriptions() {
        // Subscribe to MIDI manager changes
        midiManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    
    /// Loads all banks from the repository.
    public func loadBanks() {
        do {
            banks = try bankRepository.fetchAll()
            if banks.isEmpty {
                // Create a default bank if none exists
                let defaultBank = Bank.newBank()
                try bankRepository.save(defaultBank)
                banks = [defaultBank]
            }
            selectedBank = banks.first
        } catch {
            print("Error loading banks: $0".replacingOccurrences(of: "$0", with: "\(error.localizedDescription)"))
        }
    }
    
    /// Reloads banks from the repository.
    public func reloadBanks() {
        loadBanks()
    }
    
    // MARK: - Bank Operations
    
    /// Creates a new bank.
    public func createBank(name: String = "Untitled Bank", color: String = "#333333") -> Bank {
        let newBank = Bank(name: name, color: color)
        do {
            try bankRepository.save(newBank)
            banks.append(newBank)
            selectedBank = newBank
            return newBank
        } catch {
            print("Error creating bank: $0".replacingOccurrences(of: "$0", with: "\(error.localizedDescription)"))
            return newBank
        }
    }
    
    /// Updates a bank.
    public func updateBank(_ bank: Bank) {
        do {
            try bankRepository.save(bank)
            if let index = banks.firstIndex(where: { $0.id == bank.id }) {
                banks[index] = bank
            }
        } catch {
            print("Error updating bank: $0".replacingOccurrences(of: "$0", with: "\(error.localizedDescription)"))
        }
    }
    
    /// Deletes a bank.
    public func deleteBank(_ bank: Bank) {
        do {
            try bankRepository.delete(bank)
            banks.removeAll { $0.id == bank.id }
            if selectedBank?.id == bank.id {
                selectedBank = banks.first
            }
        } catch {
            print("Error deleting bank: $0".replacingOccurrences(of: "$0", with: "\(error.localizedDescription)"))
        }
    }
    
    /// Reorders banks.
    public func reorderBanks(from oldIndices: IndexSet, to newIndex: Int) {
        banks.move(fromOffsets: oldIndices, toOffset: newIndex)
        // Update order in repository if needed
    }
    
    // MARK: - Preset Operations
    
    /// Creates a new preset in the selected bank.
    public func createPreset(name: String = "Untitled Preset", program: Program? = nil) -> Preset? {
        guard let selectedBank = selectedBank else { return nil }
        
        let newPreset = Preset.newPreset(program: program)
        newPreset.name = name
        
        do {
            try presetRepository.save(newPreset)
            selectedBank.addPreset(newPreset)
            updateBank(selectedBank)
            selectedPreset = newPreset
            return newPreset
        } catch {
            print("Error creating preset: $0".replacingOccurrences(of: "$0", with: "\(error.localizedDescription)"))
            return nil
        }
    }
    
    /// Creates a preset from the current program in the Program Editor.
    public func createPresetFromCurrentProgram(name: String, program: Program) -> Preset? {
        let newPreset = Preset.newPreset(program: program)
        newPreset.name = name
        newPreset.author = "User" // Could be fetched from user settings
        
        do {
            try presetRepository.save(newPreset)
            if let selectedBank = selectedBank {
                selectedBank.addPreset(newPreset)
                updateBank(selectedBank)
            }
            selectedPreset = newPreset
            return newPreset
        } catch {
            print("Error creating preset from program: $0".replacingOccurrences(of: "$0", with: "\(error.localizedDescription)"))
            return nil
        }
    }
    
    /// Updates a preset.
    public func updatePreset(_ preset: Preset) {
        do {
            try presetRepository.save(preset)
            if let selectedBank = selectedBank,
               let index = selectedBank.presets.firstIndex(where: { $0.id == preset.id }) {
                selectedBank.presets[index] = preset
                updateBank(selectedBank)
            }
            selectedPreset = preset
        } catch {
            print("Error updating preset: $0".replacingOccurrences(of: "$0", with: "\(error.localizedDescription)"))
        }
    }
    
    /// Deletes a preset.
    public func deletePreset(_ preset: Preset) {
        guard let selectedBank = selectedBank else { return }
        
        do {
            try presetRepository.delete(preset)
            selectedBank.removePreset(preset)
            updateBank(selectedBank)
            if selectedPreset?.id == preset.id {
                selectedPreset = nil
            }
        } catch {
            print("Error deleting preset: $0".replacingOccurrences(of: "$0", with: "\(error.localizedDescription)"))
        }
    }
    
    /// Moves a preset to a different bank.
    public func movePreset(_ preset: Preset, to bank: Bank) {
        guard let currentBank = selectedBank else { return }
        
        // Remove from current bank
        currentBank.removePreset(preset)
        updateBank(currentBank)
        
        // Add to new bank
        bank.addPreset(preset)
        updateBank(bank)
        
        selectedBank = bank
        selectedPreset = preset
    }
    
    /// Copies a preset to a different bank.
    public func copyPreset(_ preset: Preset, to bank: Bank) -> Preset? {
        let newPreset = Preset(
            name: preset.name + " (Copy)",
            author: preset.author,
            tags: preset.tags,
            rating: preset.rating,
            notes: preset.notes,
            program: preset.program,
            color: preset.color
        )
        
        do {
            try presetRepository.save(newPreset)
            bank.addPreset(newPreset)
            updateBank(bank)
            return newPreset
        } catch {
            print("Error copying preset: $0".replacingOccurrences(of: "$0", with: "\(error.localizedDescription)"))
            return nil
        }
    }
    
    /// Reorders presets in the selected bank.
    public func reorderPresets(from oldIndices: IndexSet, to newIndex: Int) {
        guard let selectedBank = selectedBank else { return }
        selectedBank.reorderPresets(from: oldIndices, to: newIndex)
        updateBank(selectedBank)
    }
    
    // MARK: - Program Operations
    
    /// Loads a program into the editor.
    public func loadProgram(_ program: Program) {
        selectedProgram = program
    }
    
    /// Creates a new program.
    public func createProgram() -> Program {
        let newProgram = Program.newProgram()
        do {
            try programRepository.save(newProgram)
            return newProgram
        } catch {
            print("Error creating program: $0".replacingOccurrences(of: "$0", with: "\(error.localizedDescription)"))
            return newProgram
        }
    }
    
    // MARK: - Sorting
    
    /// Sorts presets by the specified order.
    private func sortPresets(_ presets: [Preset], by order: PresetSortOrder) -> [Preset] {
        switch order {
        case .nameAscending:
            return presets.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .nameDescending:
            return presets.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
        case .dateCreatedAscending:
            return presets.sorted { $0.createdAt < $1.createdAt }
        case .dateCreatedDescending:
            return presets.sorted { $0.createdAt > $1.createdAt }
        case .dateUpdatedAscending:
            return presets.sorted { $0.updatedAt < $1.updatedAt }
        case .dateUpdatedDescending:
            return presets.sorted { $0.updatedAt > $1.updatedAt }
        case .ratingAscending:
            return presets.sorted { $0.rating < $1.rating }
        case .ratingDescending:
            return presets.sorted { $0.rating > $1.rating }
        case .authorAscending:
            return presets.sorted { $0.author.localizedCaseInsensitiveCompare($1.author) == .orderedAscending }
        }
    }
    
    // MARK: - Filtering
    
    /// Resets all filters.
    public func resetFilters() {
        searchQuery = ""
        selectedTags.removeAll()
        minRating = 0
        showFavoritesOnly = false
    }
    
    // MARK: - MIDI Operations
    
    /// Sends the selected program to the hardware.
    public func sendProgramToHardware() throws {
        guard let program = selectedProgram else {
            throw LibrarianError.noProgramSelected
        }
        guard midiManager.isOutputConnected else {
            throw MIDIError.noOutputDevicesAvailable
        }
        try midiManager.sendProgram(program)
    }
    
    /// Requests a program from the hardware.
    public func requestProgramFromHardware(programNumber: Int) throws {
        guard midiManager.isInputConnected && midiManager.isOutputConnected else {
            throw MIDIError.noOutputDevicesAvailable
        }
        try midiManager.requestProgramDump(programNumber: programNumber)
    }
    
    // MARK: - Import/Export
    
    /// Imports a bank from a file.
    public func importBank(from url: URL) throws -> Bank {
        // Implementation for importing from SysEx or .mm2 files
        // This would parse the file and create a new bank
        throw LibrarianError.importNotImplemented
    }
    
    /// Exports a bank to a file.
    public func exportBank(_ bank: Bank, to url: URL) throws {
        // Implementation for exporting to SysEx or .mm2 files
        throw LibrarianError.exportNotImplemented
    }
    
    // MARK: - Enums
    
    public enum ViewMode: String, CaseIterable, Identifiable {
        case grid
        case list
        
        public var id: String { rawValue }
        
        public var displayName: String {
            switch self {
            case .grid: return "Grid"
            case .list: return "List"
            }
        }
    }
    
    public enum PresetSortOrder: String, CaseIterable, Identifiable {
        case nameAscending
        case nameDescending
        case dateCreatedAscending
        case dateCreatedDescending
        case dateUpdatedAscending
        case dateUpdatedDescending
        case ratingAscending
        case ratingDescending
        case authorAscending
        
        public var id: String { rawValue }
        
        public var displayName: String {
            switch self {
            case .nameAscending: return "Name (A-Z)"
            case .nameDescending: return "Name (Z-A)"
            case .dateCreatedAscending: return "Created (Oldest)"
            case .dateCreatedDescending: return "Created (Newest)"
            case .dateUpdatedAscending: return "Updated (Oldest)"
            case .dateUpdatedDescending: return "Updated (Newest)"
            case .ratingAscending: return "Rating (Low-High)"
            case .ratingDescending: return "Rating (High-Low)"
            case .authorAscending: return "Author (A-Z)"
            }
        }
    }
    
    public enum DeleteItemType {
        case bank
        case preset
    }
    
    public enum LibrarianError: Error, LocalizedError {
        case noProgramSelected
        case importNotImplemented
        case exportNotImplemented
        case invalidFileFormat
        
        public var errorDescription: String? {
            switch self {
            case .noProgramSelected: return "No program selected"
            case .importNotImplemented: return "Import functionality not yet implemented"
            case .exportNotImplemented: return "Export functionality not yet implemented"
            case .invalidFileFormat: return "Invalid file format"
            }
        }
    }
}
