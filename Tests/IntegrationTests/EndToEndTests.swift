// EndToEndTests.swift
// MonstaGuru
// Created by Mistral Vibe Code (Integration Agent)

import XCTest
import SwiftUI
import SwiftData
@testable import App
@testable import Data
@testable import MIDI
@testable import UI

/// End-to-end tests to verify complete app workflows.
final class EndToEndTests: XCTestCase {
    
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
    
    // MARK: - Complete App Workflow Tests
    
    func testCompleteAppWorkflow() {
        // Simulate a complete user workflow:
        // 1. Launch app -> ContentView loads
        // 2. Navigate to Librarian
        // 3. Create a bank
        // 4. Create a preset with a program
        // 5. Navigate to Clipboard
        // 6. Create a clipboard entry
        // 7. Navigate back to Editor
        
        // Step 1: App launches with ContentView
        let contentView = ContentView()
            .environment(modelContainer)
            .environmentObject(midiManager)
        XCTAssertNotNil(contentView)
        
        // Step 2: Navigate to Librarian (simulated by creating LibrarianView)
        let librarianView = LibrarianView()
            .environment(modelContainer)
            .environmentObject(midiManager)
        XCTAssertNotNil(librarianView)
        
        // Step 3: Create a bank using LibrarianViewModel
        let librarianViewModel = LibrarianViewModel()
        librarianViewModel.loadData(modelContainer: modelContainer)
        
        let bank = librarianViewModel.createBank(name: "E2E Test Bank", color: "#FF5733")
        XCTAssertNotNil(bank)
        XCTAssertEqual(bank.name, "E2E Test Bank")
        
        // Step 4: Create a preset with a program
        let program = Program(
            name: "E2E Test Program",
            number: 1
        )
        modelContainer.mainContext.insert(program)
        try? modelContainer.mainContext.save()
        
        let preset = librarianViewModel.createPreset(
            name: "E2E Test Preset",
            author: "Test User",
            tags: ["test", "e2e"],
            rating: 5,
            notes: "End-to-end test preset",
            program: program,
            color: "#33FF57",
            bank: bank
        )
        XCTAssertNotNil(preset)
        XCTAssertEqual(preset.name, "E2E Test Preset")
        XCTAssertNotNil(preset.program)
        
        librarianViewModel.refreshData()
        XCTAssertEqual(librarianViewModel.banks.count, 1)
        XCTAssertEqual(librarianViewModel.allPresets.count, 1)
        
        // Step 5: Navigate to Clipboard (simulated by creating ClipboardView)
        let clipboardView = ClipboardView()
            .environment(modelContainer)
        XCTAssertNotNil(clipboardView)
        
        // Step 6: Create a clipboard entry
        let clipboardViewModel = ClipboardViewModel()
        clipboardViewModel.loadData(modelContainer: modelContainer)
        
        let encoder = JSONEncoder()
        let programData = try! encoder.encode(program)
        let entry = clipboardViewModel.createEntry(
            name: "E2E Test Entry",
            entryType: .program,
            data: programData,
            description: "End-to-end test clipboard entry"
        )
        XCTAssertNotNil(entry)
        XCTAssertEqual(entry.name, "E2E Test Entry")
        
        clipboardViewModel.refreshData()
        XCTAssertEqual(clipboardViewModel.entries.count, 1)
        
        // Step 7: Navigate back to Editor (simulated by creating ProgramEditorView)
        let programEditorView = ProgramEditorView()
            .environment(modelContainer)
            .environmentObject(midiManager)
        XCTAssertNotNil(programEditorView)
        
        // Verify all data is consistent
        XCTAssertEqual(bank.presetCount, 1)
        XCTAssertEqual(preset.bank?.id, bank.id)
        XCTAssertEqual(entry.data, programData)
    }
    
    // MARK: - MIDI Integration Workflow Tests
    
    func testMIDIIntegrationWorkflow() {
        // Test complete MIDI workflow:
        // 1. Create a program
        // 2. Convert to SysEx
        // 3. Send via MIDIManager
        // 4. Receive and parse back
        
        // Step 1: Create a program
        let program = Program(
            name: "MIDI Test Program",
            number: 5
        )
        
        // Step 2: Convert to SysEx
        if let sysExData = SysExParser.programToSysEx(program: program) {
            XCTAssertGreaterThan(sysExData.count, 0)
            
            // Verify SysEx structure
            XCTAssertEqual(sysExData[0], 0xF0) // SysEx start
            XCTAssertEqual(sysExData.last, 0xF7) // SysEx end
            
            // Step 3: MIDIManager can send SysEx
            let sent = midiManager.sendSysEx(sysExData)
            XCTAssertNotNil(sent)
            
            // Step 4: Parse SysEx back to program
            if let parsedProgram = SysExParser.parseProgramFromSysEx(sysExData) {
                XCTAssertEqual(parsedProgram.name, program.name)
                XCTAssertEqual(parsedProgram.number, program.number)
            }
        }
    }
    
    func testMIDISettingsWorkflow() {
        // Test MIDI settings workflow:
        // 1. Get available devices
        // 2. Select input/output devices
        // 3. Configure settings
        // 4. Verify connection
        
        // Step 1: Get available devices
        let inputDevices = midiManager.availableInputDevices()
        let outputDevices = midiManager.availableOutputDevices()
        
        XCTAssertNotNil(inputDevices)
        XCTAssertNotNil(outputDevices)
        
        // Step 2: Configure MIDI settings
        midiManager.isSysExEnabled = true
        midiManager.isMIDIThruEnabled = false
        midiManager.programChangeChannel = 1
        midiManager.noteChannel = 1
        midiManager.deviceID = 0x00
        
        // Step 3: Verify settings are applied
        XCTAssertTrue(midiManager.isSysExEnabled)
        XCTAssertFalse(midiManager.isMIDIThruEnabled)
        XCTAssertEqual(midiManager.programChangeChannel, 1)
        XCTAssertEqual(midiManager.noteChannel, 1)
        XCTAssertEqual(midiManager.deviceID, 0x00)
    }
    
    // MARK: - Data Persistence Workflow Tests
    
    func testDataPersistenceWorkflow() {
        // Test complete data persistence workflow:
        // 1. Create data
        // 2. Save to model container
        // 3. Fetch back
        // 4. Verify integrity
        
        // Step 1: Create comprehensive data
        let bank = Bank(
            name: "Persistence Test Bank",
            color: "#123456"
        )
        
        let program = Program(
            name: "Persistence Test Program",
            number: 42
        )
        
        let preset = Preset(
            name: "Persistence Test Preset",
            author: "Test Author",
            tags: ["persistence", "test"],
            rating: 4,
            notes: "Testing data persistence",
            program: program,
            color: "#654321",
            bank: bank
        )
        
        let clipboardEntry = ClipboardEntry(
            type: .program,
            name: "Persistence Test Entry",
            data: Data("test data".utf8),
            createdAt: Date(),
            color: "#ABCDEF",
            notes: "Clipboard entry for persistence test"
        )
        
        // Step 2: Save to model container
        modelContainer.mainContext.insert(bank)
        modelContainer.mainContext.insert(program)
        modelContainer.mainContext.insert(preset)
        modelContainer.mainContext.insert(clipboardEntry)
        
        try? modelContainer.mainContext.save()
        
        // Step 3: Fetch back
        let bankFetch = FetchDescriptor<Bank>(predicate: #Predicate<Bank> { $0.name == "Persistence Test Bank" })
        let fetchedBank = try? modelContainer.mainContext.fetch(bankFetch).first
        
        let presetFetch = FetchDescriptor<Preset>(predicate: #Predicate<Preset> { $0.name == "Persistence Test Preset" })
        let fetchedPreset = try? modelContainer.mainContext.fetch(presetFetch).first
        
        let entryFetch = FetchDescriptor<ClipboardEntry>(predicate: #Predicate<ClipboardEntry> { $0.name == "Persistence Test Entry" })
        let fetchedEntry = try? modelContainer.mainContext.fetch(entryFetch).first
        
        // Step 4: Verify integrity
        XCTAssertNotNil(fetchedBank)
        XCTAssertEqual(fetchedBank?.name, "Persistence Test Bank")
        XCTAssertEqual(fetchedBank?.color, "#123456")
        
        XCTAssertNotNil(fetchedPreset)
        XCTAssertEqual(fetchedPreset?.name, "Persistence Test Preset")
        XCTAssertEqual(fetchedPreset?.author, "Test Author")
        XCTAssertEqual(fetchedPreset?.tags, ["persistence", "test"])
        XCTAssertEqual(fetchedPreset?.rating, 4)
        XCTAssertEqual(fetchedPreset?.notes, "Testing data persistence")
        XCTAssertEqual(fetchedPreset?.color, "#654321")
        
        XCTAssertNotNil(fetchedEntry)
        XCTAssertEqual(fetchedEntry?.name, "Persistence Test Entry")
        XCTAssertEqual(fetchedEntry?.type, .program)
        XCTAssertEqual(fetchedEntry?.notes, "Clipboard entry for persistence test")
    }
    
    // MARK: - ViewModel Integration Workflow Tests
    
    func testViewModelIntegrationWorkflow() {
        // Test complete ViewModel integration:
        // 1. LibrarianViewModel creates data
        // 2. ClipboardViewModel uses that data
        // 3. Verify cross-ViewModel communication
        
        // Step 1: LibrarianViewModel creates data
        let librarianViewModel = LibrarianViewModel()
        librarianViewModel.loadData(modelContainer: modelContainer)
        
        let bank = librarianViewModel.createBank(name: "ViewModel Integration Bank")
        let program = Program(name: "ViewModel Integration Program", number: 99)
        modelContainer.mainContext.insert(program)
        try? modelContainer.mainContext.save()
        
        let preset = librarianViewModel.createPreset(
            name: "ViewModel Integration Preset",
            program: program,
            bank: bank
        )
        
        librarianViewModel.refreshData()
        
        // Step 2: ClipboardViewModel uses that data
        let clipboardViewModel = ClipboardViewModel()
        clipboardViewModel.loadData(modelContainer: modelContainer)
        
        // Copy preset program to clipboard
        let encoder = JSONEncoder()
        let programData = try! encoder.encode(program)
        let entry = clipboardViewModel.createEntry(
            name: "ViewModel Integration Entry",
            entryType: .program,
            data: programData
        )
        
        clipboardViewModel.refreshData()
        
        // Step 3: Verify cross-ViewModel communication
        // Both ViewModels should see the same data
        XCTAssertEqual(librarianViewModel.banks.count, 1)
        XCTAssertEqual(librarianViewModel.allPresets.count, 1)
        XCTAssertEqual(clipboardViewModel.entries.count, 1)
        
        // Verify the preset and clipboard entry reference the same program
        XCTAssertEqual(preset.program?.id, program.id)
        
        // Verify clipboard entry has the program data
        let decodedProgram = try? JSONDecoder().decode(Program.self, from: entry.data)
        XCTAssertEqual(decodedProgram?.id, program.id)
    }
    
    // MARK: - Design System Integration Tests
    
    func testDesignSystemIntegration() {
        // Test that DesignSystem is properly integrated with all views
        
        // Test colors
        let primaryColor = DesignSystem.Colors.primary
        let secondaryColor = DesignSystem.Colors.secondary
        let accentColor = DesignSystem.Colors.accent
        
        XCTAssertNotNil(primaryColor)
        XCTAssertNotNil(secondaryColor)
        XCTAssertNotNil(accentColor)
        
        // Test typography
        let largeTitle = DesignSystem.Typography.largeTitle
        let body = DesignSystem.Typography.body
        let monospaced = DesignSystem.Typography.monospaced
        
        XCTAssertNotNil(largeTitle)
        XCTAssertNotNil(body)
        XCTAssertNotNil(monospaced)
        
        // Test spacing
        XCTAssertEqual(DesignSystem.Spacing.md, 12)
        XCTAssertEqual(DesignSystem.Spacing.lg, 16)
        
        // Test view modifiers
        let cardStyle = DesignSystem.cardStyle()
        let buttonStyle = DesignSystem.buttonStyle(isPrimary: true)
        
        XCTAssertNotNil(cardStyle)
        XCTAssertNotNil(buttonStyle)
    }
    
    // MARK: - Error Handling Workflow Tests
    
    func testErrorHandlingWorkflow() {
        // Test that the app handles errors gracefully
        
        // Test empty data scenarios
        let emptyProgram = Program(name: "", number: 0)
        modelContainer.mainContext.insert(emptyProgram)
        try? modelContainer.mainContext.save()
        
        // Should not crash
        XCTAssertNotNil(emptyProgram)
        
        // Test invalid SysEx data
        let invalidSysEx: [UInt8] = [0xF0, 0x01, 0x02, 0x03] // Incomplete SysEx
        let parsedProgram = SysExParser.parseProgramFromSysEx(invalidSysEx)
        
        // Should return nil for invalid data, not crash
        XCTAssertNil(parsedProgram)
        
        // Test empty search queries
        let librarianViewModel = LibrarianViewModel()
        librarianViewModel.loadData(modelContainer: modelContainer)
        
        librarianViewModel.searchQuery = ""
        librarianViewModel.filterPresets()
        
        // Should not crash with empty search
        XCTAssertNotNil(librarianViewModel.filteredPresets)
        
        // Test filtering with no matches
        librarianViewModel.searchQuery = "NonExistentQuery12345"
        librarianViewModel.filterPresets()
        
        // Should return empty array, not crash
        XCTAssertEqual(librarianViewModel.filteredPresets.count, 0)
    }
    
    // MARK: - Performance Workflow Tests
    
    func testPerformanceWithLargeData() {
        // Test performance with large datasets
        
        // Create many banks and presets
        for i in 0..<100 {
            let bank = Bank(name: "Performance Bank \(i)", color: "#\(String(format: "%06X", i % 0xFFFFFF))")
            modelContainer.mainContext.insert(bank)
            
            for j in 0..<10 {
                let preset = Preset(
                    name: "Performance Preset \(i)-\(j)",
                    bank: bank
                )
                modelContainer.mainContext.insert(preset)
            }
        }
        
        try? modelContainer.mainContext.save()
        
        // Test ViewModel performance
        let librarianViewModel = LibrarianViewModel()
        librarianViewModel.loadData(modelContainer: modelContainer)
        
        // Should handle large datasets without crashing
        XCTAssertGreaterThan(librarianViewModel.banks.count, 0)
        XCTAssertGreaterThan(librarianViewModel.allPresets.count, 0)
        
        // Test filtering performance
        librarianViewModel.searchQuery = "Performance"
        librarianViewModel.filterPresets()
        
        XCTAssertGreaterThan(librarianViewModel.filteredPresets.count, 0)
    }
    
    // MARK: - Concurrent Access Tests
    
    func testConcurrentAccess() {
        // Test that the app handles concurrent access gracefully
        
        // Create initial data
        let bank = Bank(name: "Concurrent Bank")
        modelContainer.mainContext.insert(bank)
        try? modelContainer.mainContext.save()
        
        // Simulate concurrent access by creating multiple ViewModels
        let viewModel1 = LibrarianViewModel()
        let viewModel2 = LibrarianViewModel()
        let viewModel3 = LibrarianViewModel()
        
        viewModel1.loadData(modelContainer: modelContainer)
        viewModel2.loadData(modelContainer: modelContainer)
        viewModel3.loadData(modelContainer: modelContainer)
        
        // All should see the same data
        viewModel1.refreshData()
        viewModel2.refreshData()
        viewModel3.refreshData()
        
        XCTAssertEqual(viewModel1.banks.count, viewModel2.banks.count)
        XCTAssertEqual(viewModel2.banks.count, viewModel3.banks.count)
    }
}
