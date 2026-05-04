// LibrarianIntegration.swift
// MonstaGuru
// Created by Mistral Vibe Code (Librarian Agent)

import SwiftUI
import Data
import MIDI

/// Integration point between Librarian and Program Editor.
/// Provides a unified interface for managing programs, presets, and banks.
public struct LibrarianIntegration {
    
    // MARK: - Properties
    
    /// The librarian view model.
    public let librarianViewModel: LibrarianViewModel
    
    /// The program editor view model.
    public let programEditorViewModel: ProgramEditorViewModel
    
    // MARK: - Initialization
    
    public init() {
        // Create shared MIDI manager
        let midiManager = MIDIManager()
        
        // Create repositories with shared model context
        let modelContext = try! ModelContext(ModelContainer(for: Program.self, Bank.self, Preset.self))
        let programRepository = ProgramRepository(modelContext: modelContext)
        let bankRepository = BankRepository(modelContext: modelContext)
        let presetRepository = PresetRepository(modelContext: modelContext)
        let clipboardRepository = ClipboardRepository(modelContext: modelContext)
        
        // Create view models
        self.librarianViewModel = LibrarianViewModel(
            bankRepository: bankRepository,
            presetRepository: presetRepository,
            programRepository: programRepository,
            midiManager: midiManager
        )
        
        self.programEditorViewModel = ProgramEditorViewModel(
            midiManager: midiManager,
            programRepository: programRepository,
            clipboardRepository: clipboardRepository
        )
        
        // Setup synchronization
        setupSynchronization()
    }
    
    // MARK: - Synchronization
    
    private func setupSynchronization() {
        // When a preset is selected in the librarian, load its program in the editor
        // When a program is saved in the editor, update the preset in the librarian
        
        // This would be implemented with Combine publishers or SwiftUI bindings
        // For now, we provide manual methods
    }
    
    // MARK: - Librarian Actions
    
    /// Loads a preset into the program editor.
    public func loadPresetInEditor(_ preset: Preset) {
        if let program = preset.program {
            programEditorViewModel.loadProgram(program)
            librarianViewModel.selectedPreset = preset
            librarianViewModel.selectedProgram = program
        }
    }
    
    /// Creates a new preset from the current program in the editor.
    public func createPresetFromEditor(name: String) -> Preset? {
        let program = programEditorViewModel.program
        return librarianViewModel.createPresetFromCurrentProgram(name: name, program: program)
    }
    
    /// Saves the current program in the editor to the selected preset.
    public func saveProgramToPreset() {
        guard let preset = librarianViewModel.selectedPreset else { return }
        let program = programEditorViewModel.program
        
        // Update the preset's program
        var updatedPreset = preset
        updatedPreset.program = program
        updatedPreset.updatedAt = Date()
        
        // Save the preset
        try? librarianViewModel.presetRepository.save(updatedPreset)
        
        // Update the bank
        if let bank = librarianViewModel.selectedBank,
           let index = bank.presets.firstIndex(where: { $0.id == preset.id }) {
            bank.presets[index] = updatedPreset
            try? librarianViewModel.bankRepository.save(bank)
        }
        
        librarianViewModel.selectedPreset = updatedPreset
    }
    
    // MARK: - Main Views
    
    /// Creates the main librarian view.
    public func makeLibrarianView() -> LibrarianView {
        LibrarianView(viewModel: librarianViewModel)
    }
    
    /// Creates the program editor view.
    public func makeProgramEditorView() -> ProgramEditorView {
        ProgramEditorView(viewModel: programEditorViewModel)
    }
    
    /// Creates a split view with both librarian and editor.
    public func makeSplitView() -> some View {
        NavigationSplitView {
            LibrarianView(viewModel: librarianViewModel)
        } detail: {
            ProgramEditorView(viewModel: programEditorViewModel)
        }
    }
}

// MARK: - Preview

#Preview {
    let integration = LibrarianIntegration()
    return integration.makeSplitView()
        .frame(width: 1200, height: 800)
}
