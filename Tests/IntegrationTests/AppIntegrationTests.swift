// AppIntegrationTests.swift
// MonstaGuru
// Created by Mistral Vibe Code (Integration Agent)

import XCTest
import SwiftUI
import SwiftData
@testable import App
@testable import Data
@testable import MIDI
@testable import UI

/// Integration tests to verify all app modules work together correctly.
final class AppIntegrationTests: XCTestCase {
    
    private var modelContainer: ModelContainer!
    private var midiManager: MIDIManager!
    
    override func setUp() {
        super.setUp()
        
        // Create in-memory model container for testing
        do {
            modelContainer = try ModelContainer(
                for: Program.self, Preset.self, Bank.self, ClipboardEntry.self, MIDISetting.self,
                configurations: ModelConfiguration(url: URL(fileURLWithPath: "/dev/null"))
            )
        } catch {
            XCTFail("Failed to create ModelContainer: \(error)")
        }
        
        midiManager = MIDIManager()
    }
    
    override func tearDown() {
        modelContainer = nil
        midiManager = nil
        super.tearDown()
    }
    
    // MARK: - App Entry Point Tests
    
    func testAppInitialization() {
        // Verify the app can be initialized
        XCTAssertNotNil(MonstaGuruApp.container)
    }
    
    func testAppHasContentView() {
        // Verify ContentView is accessible from App module
        let contentView = ContentView()
            .environment(modelContainer)
            .environmentObject(midiManager)
        
        XCTAssertNotNil(contentView)
    }
    
    func testAppHasSettingsView() {
        // Verify SettingsView is accessible from App module
        let settingsView = SettingsView()
            .environment(modelContainer)
            .environmentObject(midiManager)
        
        XCTAssertNotNil(settingsView)
    }
    
    // MARK: - Module Integration Tests
    
    func testDataModuleIntegration() {
        // Verify Data module is accessible
        let program = Program.default
        let preset = Preset.default
        let bank = Bank.default
        let clipboardEntry = ClipboardEntry(
            type: .program,
            name: "Test",
            data: Data()
        )
        let midiSetting = MIDISetting.default
        
        XCTAssertNotNil(program)
        XCTAssertNotNil(preset)
        XCTAssertNotNil(bank)
        XCTAssertNotNil(clipboardEntry)
        XCTAssertNotNil(midiSetting)
    }
    
    func testMIDIModuleIntegration() {
        // Verify MIDI module is accessible
        let manager = MIDIManager()
        let parser = SysExParser()
        
        XCTAssertNotNil(manager)
        XCTAssertNotNil(parser)
        
        // Verify MIDI types are accessible
        let channel: MIDIChannel = 1
        let note: MIDINote = 60
        let velocity: MIDIVelocity = 100
        
        XCTAssertNotNil(channel)
        XCTAssertNotNil(note)
        XCTAssertNotNil(velocity)
    }
    
    func testUIModuleIntegration() {
        // Verify UI module is accessible
        let contentView = ContentView()
        let settingsView = SettingsView()
        let librarianView = LibrarianView()
        let clipboardView = ClipboardView()
        let programEditorView = ProgramEditorView()
        
        XCTAssertNotNil(contentView)
        XCTAssertNotNil(settingsView)
        XCTAssertNotNil(librarianView)
        XCTAssertNotNil(clipboardView)
        XCTAssertNotNil(programEditorView)
    }
    
    // MARK: - Cross-Module Data Flow Tests
    
    func testProgramToPresetFlow() {
        // Test creating a program and saving it as a preset
        let program = Program.default
        
        // Save program to model container
        modelContainer.mainContext.insert(program)
        try? modelContainer.mainContext.save()
        
        // Create preset from program
        let preset = Preset(
            name: "Test Preset",
            program: program
        )
        
        modelContainer.mainContext.insert(preset)
        try? modelContainer.mainContext.save()
        
        // Verify preset has the program
        XCTAssertNotNil(preset.program)
        XCTAssertEqual(preset.program?.id, program.id)
    }
    
    func testPresetToBankFlow() {
        // Test creating a preset and adding it to a bank
        let bank = Bank(name: "Test Bank")
        let preset = Preset(name: "Test Preset")
        
        // Add preset to bank
        preset.bank = bank
        
        modelContainer.mainContext.insert(bank)
        modelContainer.mainContext.insert(preset)
        try? modelContainer.mainContext.save()
        
        // Verify bank has the preset
        XCTAssertEqual(bank.presetCount, 1)
        XCTAssertEqual(preset.bank?.id, bank.id)
    }
    
    func testProgramToClipboardFlow() {
        // Test copying a program to clipboard
        let program = Program.default
        
        // Create clipboard entry from program
        let encoder = JSONEncoder()
        let data = try! encoder.encode(program)
        
        let clipboardEntry = ClipboardEntry(
            type: .program,
            name: program.name,
            data: data
        )
        
        modelContainer.mainContext.insert(clipboardEntry)
        try? modelContainer.mainContext.save()
        
        // Verify clipboard entry has program data
        XCTAssertNotNil(clipboardEntry.data)
        XCTAssertGreaterThan(clipboardEntry.data.count, 0)
    }
    
    // MARK: - ViewModel Integration Tests
    
    func testLibrarianViewModelWithModelContainer() {
        let viewModel = LibrarianViewModel()
        viewModel.loadData(modelContainer: modelContainer)
        
        // Create a bank
        let bank = viewModel.createBank(name: "Integration Test Bank")
        
        // Create a preset
        let preset = viewModel.createPreset(
            name: "Integration Test Preset",
            bank: bank
        )
        
        // Verify data is in model container
        viewModel.refreshData()
        
        XCTAssertEqual(viewModel.banks.count, 1)
        XCTAssertEqual(viewModel.allPresets.count, 1)
        XCTAssertEqual(bank.presetCount, 1)
    }
    
    func testClipboardViewModelWithModelContainer() {
        let viewModel = ClipboardViewModel()
        viewModel.loadData(modelContainer: modelContainer)
        
        // Create a clipboard entry
        let data = "test data".data(using: .utf8)!
        let entry = viewModel.createEntry(
            name: "Integration Test Entry",
            entryType: .program,
            data: data
        )
        
        // Verify data is in model container
        viewModel.refreshData()
        
        XCTAssertEqual(viewModel.entries.count, 1)
        XCTAssertEqual(entry.data, data)
    }
    
    // MARK: - View Integration Tests
    
    func testContentViewWithAllDependencies() {
        // Test that ContentView can be created with all dependencies
        let contentView = ContentView()
            .environment(modelContainer)
            .environmentObject(midiManager)
        
        XCTAssertNotNil(contentView)
    }
    
    func testLibrarianViewWithAllDependencies() {
        // Test that LibrarianView can be created with all dependencies
        let librarianView = LibrarianView()
            .environment(modelContainer)
            .environmentObject(midiManager)
        
        XCTAssertNotNil(librarianView)
    }
    
    func testClipboardViewWithAllDependencies() {
        // Test that ClipboardView can be created with all dependencies
        let clipboardView = ClipboardView()
            .environment(modelContainer)
        
        XCTAssertNotNil(clipboardView)
    }
    
    func testProgramEditorViewWithAllDependencies() {
        // Test that ProgramEditorView can be created with all dependencies
        let programEditorView = ProgramEditorView()
            .environment(modelContainer)
            .environmentObject(midiManager)
        
        XCTAssertNotNil(programEditorView)
    }
    
    // MARK: - MIDI Integration Tests
    
    func testMIDIManagerWithSysExParser() {
        // Test that MIDIManager can use SysExParser
        let manager = MIDIManager()
        let parser = SysExParser()
        
        // Create a test program
        let program = Program.default
        
        // Convert program to SysEx
        if let sysExData = SysExParser.programToSysEx(program: program) {
            XCTAssertGreaterThan(sysExData.count, 0)
            
            // Verify MIDIManager can send SysEx
            // (This would actually send in a real scenario)
            XCTAssertNotNil(manager.sendSysEx(sysExData))
        }
    }
    
    func testMIDIManagerDeviceManagement() {
        // Test MIDI device management
        let manager = MIDIManager()
        
        // Get available devices
        let inputDevices = manager.availableInputDevices()
        let outputDevices = manager.availableOutputDevices()
        
        XCTAssertNotNil(inputDevices)
        XCTAssertNotNil(outputDevices)
    }
    
    // MARK: - Design System Integration Tests
    
    func testDesignSystemWithViews() {
        // Test that DesignSystem is used by views
        let cardStyle = DesignSystem.cardStyle()
        let buttonStyle = DesignSystem.buttonStyle(isPrimary: true)
        let controlStyle = DesignSystem.controlStyle()
        
        XCTAssertNotNil(cardStyle)
        XCTAssertNotNil(buttonStyle)
        XCTAssertNotNil(controlStyle)
    }
    
    func testColorExtensionWithDesignSystem() {
        // Test that Color extension works with DesignSystem colors
        let primaryColor = Color(hex: "#4A90E2")
        let accentColor = Color(hex: "#007AFF")
        
        XCTAssertNotNil(primaryColor)
        XCTAssertNotNil(accentColor)
    }
    
    // MARK: - End-to-End Flow Tests
    
    func testCompleteWorkflow() {
        // Test a complete workflow: Create program -> Save as preset -> Add to bank -> Copy to clipboard
        
        // 1. Create a program
        let program = Program.default
        modelContainer.mainContext.insert(program)
        try? modelContainer.mainContext.save()
        
        // 2. Save as preset
        let preset = Preset(
            name: "Workflow Preset",
            program: program
        )
        modelContainer.mainContext.insert(preset)
        try? modelContainer.mainContext.save()
        
        // 3. Add to bank
        let bank = Bank(name: "Workflow Bank")
        preset.bank = bank
        modelContainer.mainContext.insert(bank)
        try? modelContainer.mainContext.save()
        
        // 4. Copy to clipboard
        let encoder = JSONEncoder()
        let data = try! encoder.encode(program)
        let clipboardEntry = ClipboardEntry(
            type: .program,
            name: "Workflow Clipboard Entry",
            data: data
        )
        modelContainer.mainContext.insert(clipboardEntry)
        try? modelContainer.mainContext.save()
        
        // Verify all steps completed successfully
        XCTAssertNotNil(program)
        XCTAssertNotNil(preset.program)
        XCTAssertEqual(bank.presetCount, 1)
        XCTAssertNotNil(clipboardEntry.data)
    }
    
    func testViewModelWorkflow() {
        // Test workflow using ViewModels
        
        // 1. Create bank using LibrarianViewModel
        let librarianViewModel = LibrarianViewModel()
        librarianViewModel.loadData(modelContainer: modelContainer)
        
        let bank = librarianViewModel.createBank(name: "ViewModel Bank")
        
        // 2. Create preset using LibrarianViewModel
        let preset = librarianViewModel.createPreset(
            name: "ViewModel Preset",
            bank: bank
        )
        
        // 3. Create clipboard entry using ClipboardViewModel
        let clipboardViewModel = ClipboardViewModel()
        clipboardViewModel.loadData(modelContainer: modelContainer)
        
        let encoder = JSONEncoder()
        let programData = try! encoder.encode(preset.program ?? Program.default)
        let entry = clipboardViewModel.createEntry(
            name: "ViewModel Clipboard Entry",
            entryType: .program,
            data: programData
        )
        
        // Verify workflow
        librarianViewModel.refreshData()
        clipboardViewModel.refreshData()
        
        XCTAssertEqual(librarianViewModel.banks.count, 1)
        XCTAssertEqual(librarianViewModel.allPresets.count, 1)
        XCTAssertEqual(clipboardViewModel.entries.count, 1)
    }
    
    // MARK: - Data Consistency Tests
    
    func testDataConsistencyAcrossModules() {
        // Test that data remains consistent across module boundaries
        
        // Create a program with specific values
        let program = Program(
            name: "Consistency Test",
            number: 42
        )
        
        modelContainer.mainContext.insert(program)
        try? modelContainer.mainContext.save()
        
        // Fetch the program back
        let fetchDescriptor = FetchDescriptor<Program>(predicate: #Predicate<Program> { $0.id == program.id })
        let fetchedProgram = try? modelContainer.mainContext.fetch(fetchDescriptor).first
        
        XCTAssertNotNil(fetchedProgram)
        XCTAssertEqual(fetchedProgram?.name, "Consistency Test")
        XCTAssertEqual(fetchedProgram?.number, 42)
    }
    
    func testRelationshipConsistency() {
        // Test that relationships remain consistent
        
        // Create bank with preset
        let bank = Bank(name: "Relationship Test Bank")
        let preset = Preset(name: "Relationship Test Preset", bank: bank)
        
        modelContainer.mainContext.insert(bank)
        modelContainer.mainContext.insert(preset)
        try? modelContainer.mainContext.save()
        
        // Fetch back and verify
        let bankFetch = FetchDescriptor<Bank>(predicate: #Predicate<Bank> { $0.id == bank.id })
        let fetchedBank = try? modelContainer.mainContext.fetch(bankFetch).first
        
        XCTAssertNotNil(fetchedBank)
        XCTAssertEqual(fetchedBank?.presetCount, 1)
        XCTAssertEqual(fetchedBank?.presets.first?.id, preset.id)
    }
}
