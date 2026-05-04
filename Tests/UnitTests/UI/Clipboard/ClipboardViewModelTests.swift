// ClipboardViewModelTests.swift
// MonstaGuru
// Created by Mistral Vibe Code (Testing Agent)

import XCTest
import SwiftData
@testable import UI
@testable import Data

/// Tests for ClipboardViewModel to ensure proper clipboard entry management.
final class ClipboardViewModelTests: XCTestCase {
    
    private var modelContainer: ModelContainer!
    private var viewModel: ClipboardViewModel!
    
    override func setUp() {
        super.setUp()
        
        // Create in-memory model container for testing
        do {
            modelContainer = try ModelContainer(
                for: Program.self, Preset.self, Bank.self, ClipboardEntry.self, MIDISetting.self,
                configurations: ModelConfiguration(url: URL(fileURLWithPath: "/dev/null"))
            )
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
        
        viewModel = ClipboardViewModel()
        viewModel.loadData(modelContainer: modelContainer)
    }
    
    override func tearDown() {
        modelContainer = nil
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Data Loading Tests
    
    func testInitialState() {
        XCTAssertTrue(viewModel.entries.isEmpty)
        XCTAssertTrue(viewModel.filteredEntries.isEmpty)
    }
    
    func testLoadData() {
        // Verify data can be loaded
        XCTAssertNotNil(viewModel.modelContainer)
    }
    
    // MARK: - Entry Operations Tests
    
    func testCreateEntry() {
        let data = "test data".data(using: .utf8)!
        let entry = viewModel.createEntry(
            name: "Test Entry",
            entryType: .program,
            data: data,
            description: "Test description"
        )
        
        XCTAssertNotNil(entry)
        XCTAssertEqual(entry.name, "Test Entry")
        XCTAssertEqual(entry.type, .program)
        XCTAssertEqual(entry.data, data)
        XCTAssertEqual(entry.notes, "Test description")
        
        viewModel.refreshData()
        XCTAssertEqual(viewModel.entries.count, 1)
    }
    
    func testCreateMultipleEntries() {
        let data1 = "data1".data(using: .utf8)!
        let data2 = "data2".data(using: .utf8)!
        let data3 = "data3".data(using: .utf8)!
        
        let entry1 = viewModel.createEntry(name: "Entry 1", entryType: .program, data: data1)
        let entry2 = viewModel.createEntry(name: "Entry 2", entryType: .oscillator, data: data2)
        let entry3 = viewModel.createEntry(name: "Entry 3", entryType: .filter, data: data3)
        
        viewModel.refreshData()
        
        XCTAssertEqual(viewModel.entries.count, 3)
        
        let entryNames = viewModel.entries.map { $0.name }
        XCTAssertTrue(entryNames.contains("Entry 1"))
        XCTAssertTrue(entryNames.contains("Entry 2"))
        XCTAssertTrue(entryNames.contains("Entry 3"))
    }
    
    func testCreateEntryWithDifferentTypes() {
        let allTypes: [ClipboardEntryType] = [
            .program, .oscillator, .filter, .envelope, .lfo,
            .matrixSlot, .effects, .globalSettings, .mixer
        ]
        
        for entryType in allTypes {
            let entry = viewModel.createEntry(
                name: "Test \(entryType.displayName)",
                entryType: entryType,
                data: Data()
            )
            
            XCTAssertNotNil(entry)
            XCTAssertEqual(entry.type, entryType)
        }
        
        viewModel.refreshData()
        XCTAssertEqual(viewModel.entries.count, allTypes.count)
    }
    
    func testDuplicateEntry() {
        let data = "original data".data(using: .utf8)!
        let originalEntry = viewModel.createEntry(
            name: "Original Entry",
            entryType: .program,
            data: data,
            description: "Original description"
        )
        
        viewModel.duplicateEntry(originalEntry)
        
        viewModel.refreshData()
        
        XCTAssertEqual(viewModel.entries.count, 2)
        
        let duplicatedEntries = viewModel.entries.filter { $0.name == "Original Entry Copy" }
        XCTAssertEqual(duplicatedEntries.count, 1)
        XCTAssertEqual(duplicatedEntries[0].type, .program)
        XCTAssertEqual(duplicatedEntries[0].data, data)
        XCTAssertEqual(duplicatedEntries[0].notes, "Original description")
    }
    
    func testDeleteEntry() {
        let entry = viewModel.createEntry(name: "Entry to Delete", entryType: .program, data: Data())
        viewModel.deleteEntry(entry)
        
        viewModel.refreshData()
        
        XCTAssertEqual(viewModel.entries.count, 0)
    }
    
    func testClearAll() {
        let entry1 = viewModel.createEntry(name: "Entry 1", entryType: .program, data: Data())
        let entry2 = viewModel.createEntry(name: "Entry 2", entryType: .oscillator, data: Data())
        let entry3 = viewModel.createEntry(name: "Entry 3", entryType: .filter, data: Data())
        
        viewModel.refreshData()
        XCTAssertEqual(viewModel.entries.count, 3)
        
        viewModel.clearAll()
        
        viewModel.refreshData()
        XCTAssertEqual(viewModel.entries.count, 0)
    }
    
    // MARK: - Filtering Tests
    
    func testFilterEntriesBySearchQuery() {
        let entry1 = viewModel.createEntry(name: "Bass Entry", entryType: .program, data: Data())
        let entry2 = viewModel.createEntry(name: "Lead Entry", entryType: .oscillator, data: Data())
        let entry3 = viewModel.createEntry(name: "Pad Entry", entryType: .filter, data: Data())
        
        viewModel.refreshData()
        
        // Test filtering by name
        viewModel.searchQuery = "Bass"
        viewModel.filterEntries()
        
        XCTAssertEqual(viewModel.filteredEntries.count, 1)
        XCTAssertEqual(viewModel.filteredEntries[0].id, entry1.id)
        
        // Test filtering by description
        viewModel.searchQuery = "Lead"
        viewModel.filterEntries()
        
        XCTAssertEqual(viewModel.filteredEntries.count, 1)
        XCTAssertEqual(viewModel.filteredEntries[0].id, entry2.id)
    }
    
    func testFilterEntriesByType() {
        let entry1 = viewModel.createEntry(name: "Program Entry", entryType: .program, data: Data())
        let entry2 = viewModel.createEntry(name: "Oscillator Entry", entryType: .oscillator, data: Data())
        let entry3 = viewModel.createEntry(name: "Filter Entry", entryType: .filter, data: Data())
        
        viewModel.refreshData()
        
        // Test filtering by program type
        viewModel.filterType = .program
        viewModel.filterEntries()
        
        XCTAssertEqual(viewModel.filteredEntries.count, 1)
        XCTAssertEqual(viewModel.filteredEntries[0].id, entry1.id)
        
        // Test filtering by oscillator type
        viewModel.filterType = .oscillator
        viewModel.filterEntries()
        
        XCTAssertEqual(viewModel.filteredEntries.count, 1)
        XCTAssertEqual(viewModel.filteredEntries[0].id, entry2.id)
    }
    
    func testFilterEntriesByAllType() {
        let entry1 = viewModel.createEntry(name: "Entry 1", entryType: .program, data: Data())
        let entry2 = viewModel.createEntry(name: "Entry 2", entryType: .oscillator, data: Data())
        let entry3 = viewModel.createEntry(name: "Entry 3", entryType: .filter, data: Data())
        
        viewModel.refreshData()
        
        // Test filtering by all (should show all entries)
        viewModel.filterType = .all
        viewModel.filterEntries()
        
        XCTAssertEqual(viewModel.filteredEntries.count, 3)
    }
    
    func testCombinedFiltering() {
        let entry1 = viewModel.createEntry(name: "Bass Program", entryType: .program, data: Data())
        let entry2 = viewModel.createEntry(name: "Lead Program", entryType: .program, data: Data())
        let entry3 = viewModel.createEntry(name: "Bass Oscillator", entryType: .oscillator, data: Data())
        
        viewModel.refreshData()
        
        // Filter by search query and type
        viewModel.searchQuery = "Bass"
        viewModel.filterType = .program
        viewModel.filterEntries()
        
        XCTAssertEqual(viewModel.filteredEntries.count, 1)
        XCTAssertEqual(viewModel.filteredEntries[0].id, entry1.id)
    }
    
    // MARK: - FilterType Enum Tests
    
    func testFilterTypeCases() {
        // Verify all filter type cases exist
        let allCases = ClipboardViewModel.FilterType.allCases
        
        XCTAssertEqual(allCases.count, 9)
        XCTAssertTrue(allCases.contains(.all))
        XCTAssertTrue(allCases.contains(.program))
        XCTAssertTrue(allCases.contains(.oscillator))
        XCTAssertTrue(allCases.contains(.filter))
        XCTAssertTrue(allCases.contains(.envelope))
        XCTAssertTrue(allCases.contains(.lfo))
        XCTAssertTrue(allCases.contains(.matrixSlot))
        XCTAssertTrue(allCases.contains(.effects))
        XCTAssertTrue(allCases.contains(.globalSettings))
        XCTAssertTrue(allCases.contains(.mixer))
    }
    
    func testFilterTypeRawValues() {
        XCTAssertEqual(ClipboardViewModel.FilterType.all.rawValue, "All")
        XCTAssertEqual(ClipboardViewModel.FilterType.program.rawValue, "Programs")
        XCTAssertEqual(ClipboardViewModel.FilterType.oscillator.rawValue, "Oscillators")
        XCTAssertEqual(ClipboardViewModel.FilterType.filter.rawValue, "Filters")
        XCTAssertEqual(ClipboardViewModel.FilterType.envelope.rawValue, "Envelopes")
        XCTAssertEqual(ClipboardViewModel.FilterType.lfo.rawValue, "LFOs")
        XCTAssertEqual(ClipboardViewModel.FilterType.matrixSlot.rawValue, "Matrix Slots")
        XCTAssertEqual(ClipboardViewModel.FilterType.effects.rawValue, "Effects")
        XCTAssertEqual(ClipboardViewModel.FilterType.globalSettings.rawValue, "Global Settings")
        XCTAssertEqual(ClipboardViewModel.FilterType.mixer.rawValue, "Mixer")
    }
    
    // MARK: - Clipboard Operations Tests
    
    func testCopyToClipboard() {
        let data = "clipboard data".data(using: .utf8)!
        let entry = viewModel.copyToClipboard(
            data,
            name: "Clipboard Entry",
            entryType: .program,
            description: "Test description"
        )
        
        XCTAssertNotNil(entry)
        XCTAssertEqual(entry.name, "Clipboard Entry")
        XCTAssertEqual(entry.type, .program)
        
        viewModel.refreshData()
        XCTAssertEqual(viewModel.entries.count, 1)
    }
    
    func testPasteEntry() {
        let data = "paste data".data(using: .utf8)!
        let entry = viewModel.createEntry(name: "Paste Entry", entryType: .program, data: data)
        
        viewModel.refreshData()
        
        let pastedData = viewModel.pasteEntry(entry)
        XCTAssertEqual(pastedData, data)
    }
    
    func testPasteNonExistentEntry() {
        // Create an entry that's not in the model container
        let data = "test data".data(using: .utf8)!
        let entry = ClipboardEntry(
            type: .program,
            name: "Non-existent Entry",
            data: data
        )
        
        let pastedData = viewModel.pasteEntry(entry)
        XCTAssertEqual(pastedData, data)
    }
    
    // MARK: - Edge Cases
    
    func testEmptySearchQuery() {
        let entry1 = viewModel.createEntry(name: "Entry 1", entryType: .program, data: Data())
        let entry2 = viewModel.createEntry(name: "Entry 2", entryType: .oscillator, data: Data())
        
        viewModel.refreshData()
        viewModel.searchQuery = ""
        viewModel.filterEntries()
        
        XCTAssertEqual(viewModel.filteredEntries.count, 2)
    }
    
    func testSearchQueryWithNoMatches() {
        let entry1 = viewModel.createEntry(name: "Entry 1", entryType: .program, data: Data())
        let entry2 = viewModel.createEntry(name: "Entry 2", entryType: .oscillator, data: Data())
        
        viewModel.refreshData()
        viewModel.searchQuery = "NonExistent"
        viewModel.filterEntries()
        
        XCTAssertEqual(viewModel.filteredEntries.count, 0)
    }
    
    func testCreateEntryWithEmptyName() {
        let entry = viewModel.createEntry(name: "", entryType: .program, data: Data())
        
        XCTAssertNotNil(entry)
        XCTAssertEqual(entry.name, "")
        
        viewModel.refreshData()
        XCTAssertEqual(viewModel.entries.count, 1)
    }
    
    func testCreateEntryWithNilData() {
        let entry = viewModel.createEntry(name: "Entry with nil data", entryType: .program, data: nil)
        
        XCTAssertNotNil(entry)
        // Data should be empty Data() when nil is passed
        XCTAssertEqual(entry.data.count, 0)
        
        viewModel.refreshData()
        XCTAssertEqual(viewModel.entries.count, 1)
    }
    
    func testCreateEntryWithNilDescription() {
        let entry = viewModel.createEntry(
            name: "Entry with nil description",
            entryType: .program,
            data: Data(),
            description: nil
        )
        
        XCTAssertNotNil(entry)
        XCTAssertEqual(entry.notes, "")
        
        viewModel.refreshData()
        XCTAssertEqual(viewModel.entries.count, 1)
    }
    
    // MARK: - Data Consistency Tests
    
    func testEntryDataIntegrity() {
        let originalData = "original data content".data(using: .utf8)!
        let entry = viewModel.createEntry(name: "Data Test", entryType: .program, data: originalData)
        
        viewModel.refreshData()
        
        let retrievedEntry = viewModel.entries.first!
        XCTAssertEqual(retrievedEntry.data, originalData)
    }
    
    func testMultipleEntriesWithSameType() {
        let data1 = "data1".data(using: .utf8)!
        let data2 = "data2".data(using: .utf8)!
        let data3 = "data3".data(using: .utf8)!
        
        let entry1 = viewModel.createEntry(name: "Entry 1", entryType: .program, data: data1)
        let entry2 = viewModel.createEntry(name: "Entry 2", entryType: .program, data: data2)
        let entry3 = viewModel.createEntry(name: "Entry 3", entryType: .program, data: data3)
        
        viewModel.refreshData()
        
        let programEntries = viewModel.entries.filter { $0.type == .program }
        XCTAssertEqual(programEntries.count, 3)
    }
}
