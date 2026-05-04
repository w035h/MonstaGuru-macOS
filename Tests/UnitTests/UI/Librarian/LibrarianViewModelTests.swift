// LibrarianViewModelTests.swift
// MonstaGuru
// Created by Mistral Vibe Code (Testing Agent)

import XCTest
import SwiftData
@testable import UI
@testable import Data
@testable import MIDI

/// Tests for LibrarianViewModel to ensure proper data management.
final class LibrarianViewModelTests: XCTestCase {
    
    private var modelContainer: ModelContainer!
    private var viewModel: LibrarianViewModel!
    
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
        
        viewModel = LibrarianViewModel()
        viewModel.loadData(modelContainer: modelContainer)
    }
    
    override func tearDown() {
        modelContainer = nil
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Data Loading Tests
    
    func testInitialState() {
        XCTAssertTrue(viewModel.banks.isEmpty)
        XCTAssertTrue(viewModel.allPresets.isEmpty)
        XCTAssertTrue(viewModel.filteredPresets.isEmpty)
    }
    
    func testLoadData() {
        // Verify data can be loaded
        XCTAssertNotNil(viewModel.modelContainer)
    }
    
    // MARK: - Bank Operations Tests
    
    func testCreateBank() {
        let bank = viewModel.createBank(name: "Test Bank", color: "#FF0000")
        
        XCTAssertNotNil(bank)
        XCTAssertEqual(bank.name, "Test Bank")
        XCTAssertEqual(bank.color, "#FF0000")
        
        // Verify bank was added to the list
        viewModel.refreshData()
        XCTAssertEqual(viewModel.banks.count, 1)
        XCTAssertEqual(viewModel.banks[0].name, "Test Bank")
    }
    
    func testCreateMultipleBanks() {
        let bank1 = viewModel.createBank(name: "Bank 1")
        let bank2 = viewModel.createBank(name: "Bank 2")
        let bank3 = viewModel.createBank(name: "Bank 3")
        
        viewModel.refreshData()
        
        XCTAssertEqual(viewModel.banks.count, 3)
        
        let bankNames = viewModel.banks.map { $0.name }
        XCTAssertTrue(bankNames.contains("Bank 1"))
        XCTAssertTrue(bankNames.contains("Bank 2"))
        XCTAssertTrue(bankNames.contains("Bank 3"))
    }
    
    func testDuplicateBank() {
        let originalBank = viewModel.createBank(name: "Original Bank", color: "#0000FF")
        viewModel.duplicateBank(originalBank)
        
        viewModel.refreshData()
        
        XCTAssertEqual(viewModel.banks.count, 2)
        
        // Find the duplicated bank
        let duplicatedBanks = viewModel.banks.filter { $0.name == "Original Bank Copy" }
        XCTAssertEqual(duplicatedBanks.count, 1)
        XCTAssertEqual(duplicatedBanks[0].color, "#0000FF")
    }
    
    func testDeleteBank() {
        let bank = viewModel.createBank(name: "Bank to Delete")
        viewModel.deleteBank(bank)
        
        viewModel.refreshData()
        
        XCTAssertEqual(viewModel.banks.count, 0)
    }
    
    func testDeleteBankWithPresets() {
        let bank = viewModel.createBank(name: "Bank with Presets")
        let preset = viewModel.createPreset(name: "Test Preset", bank: bank)
        
        // Verify preset was created
        viewModel.refreshData()
        XCTAssertEqual(viewModel.allPresets.count, 1)
        
        // Delete bank (should also delete presets)
        viewModel.deleteBank(bank)
        
        viewModel.refreshData()
        
        XCTAssertEqual(viewModel.banks.count, 0)
        XCTAssertEqual(viewModel.allPresets.count, 0)
    }
    
    // MARK: - Preset Operations Tests
    
    func testCreatePreset() {
        let preset = viewModel.createPreset(
            name: "Test Preset",
            author: "Test Author",
            tags: ["tag1", "tag2"],
            rating: 4,
            notes: "Test notes",
            color: "#00FF00"
        )
        
        XCTAssertNotNil(preset)
        XCTAssertEqual(preset.name, "Test Preset")
        XCTAssertEqual(preset.author, "Test Author")
        XCTAssertEqual(preset.tags, ["tag1", "tag2"])
        XCTAssertEqual(preset.rating, 4)
        XCTAssertEqual(preset.notes, "Test notes")
        XCTAssertEqual(preset.color, "#00FF00")
        
        viewModel.refreshData()
        XCTAssertEqual(viewModel.allPresets.count, 1)
    }
    
    func testCreatePresetWithBank() {
        let bank = viewModel.createBank(name: "Test Bank")
        let preset = viewModel.createPreset(name: "Test Preset", bank: bank)
        
        XCTAssertNotNil(preset)
        XCTAssertEqual(preset.bank?.id, bank.id)
        
        viewModel.refreshData()
        XCTAssertEqual(viewModel.allPresets.count, 1)
        XCTAssertEqual(viewModel.banks[0].presetCount, 1)
    }
    
    func testDuplicatePreset() {
        let originalPreset = viewModel.createPreset(name: "Original Preset")
        viewModel.duplicatePreset(originalPreset)
        
        viewModel.refreshData()
        
        XCTAssertEqual(viewModel.allPresets.count, 2)
        
        let duplicatedPresets = viewModel.allPresets.filter { $0.name == "Original Preset Copy" }
        XCTAssertEqual(duplicatedPresets.count, 1)
    }
    
    func testDeletePreset() {
        let preset = viewModel.createPreset(name: "Preset to Delete")
        viewModel.deletePreset(preset)
        
        viewModel.refreshData()
        
        XCTAssertEqual(viewModel.allPresets.count, 0)
    }
    
    func testRemoveFromBank() {
        let bank = viewModel.createBank(name: "Test Bank")
        let preset = viewModel.createPreset(name: "Test Preset", bank: bank)
        
        viewModel.refreshData()
        XCTAssertEqual(bank.presetCount, 1)
        
        viewModel.removeFromBank(preset, bank: bank)
        
        viewModel.refreshData()
        XCTAssertNil(preset.bank)
        XCTAssertEqual(bank.presetCount, 0)
    }
    
    func testAddToBank() {
        let bank = viewModel.createBank(name: "Test Bank")
        let preset = viewModel.createPreset(name: "Test Preset")
        
        viewModel.addToBank(preset, bank: bank)
        
        viewModel.refreshData()
        XCTAssertEqual(preset.bank?.id, bank.id)
        XCTAssertEqual(bank.presetCount, 1)
    }
    
    // MARK: - Filtering Tests
    
    func testFilterPresetsBySearchQuery() {
        let preset1 = viewModel.createPreset(name: "Bass Preset", tags: ["bass"])
        let preset2 = viewModel.createPreset(name: "Lead Preset", tags: ["lead"])
        let preset3 = viewModel.createPreset(name: "Pad Preset", tags: ["pad"])
        
        viewModel.refreshData()
        
        // Test filtering by name
        viewModel.searchQuery = "Bass"
        viewModel.filterPresets()
        
        XCTAssertEqual(viewModel.filteredPresets.count, 1)
        XCTAssertEqual(viewModel.filteredPresets[0].id, preset1.id)
        
        // Test filtering by tag
        viewModel.searchQuery = "lead"
        viewModel.filterPresets()
        
        XCTAssertEqual(viewModel.filteredPresets.count, 1)
        XCTAssertEqual(viewModel.filteredPresets[0].id, preset2.id)
        
        // Test filtering by author
        let preset4 = viewModel.createPreset(name: "Another Preset", author: "John Doe")
        viewModel.refreshData()
        viewModel.searchQuery = "John"
        viewModel.filterPresets()
        
        XCTAssertEqual(viewModel.filteredPresets.count, 1)
        XCTAssertEqual(viewModel.filteredPresets[0].id, preset4.id)
    }
    
    func testFilterPresetsBySortOrder() {
        let preset1 = viewModel.createPreset(name: "Zebra")
        let preset2 = viewModel.createPreset(name: "Apple")
        let preset3 = viewModel.createPreset(name: "Banana")
        
        viewModel.refreshData()
        
        // Test name ascending
        viewModel.sortOrder = .nameAscending
        viewModel.filterPresets()
        
        let namesAscending = viewModel.filteredPresets.map { $0.name }
        XCTAssertEqual(namesAscending, ["Apple", "Banana", "Zebra"])
        
        // Test name descending
        viewModel.sortOrder = .nameDescending
        viewModel.filterPresets()
        
        let namesDescending = viewModel.filteredPresets.map { $0.name }
        XCTAssertEqual(namesDescending, ["Zebra", "Banana", "Apple"])
    }
    
    func testFilterPresetsByDate() {
        // Create presets with different dates
        let calendar = Calendar.current
        let date1 = calendar.date(byAdding: .day, value: -2, to: Date())!
        let date2 = calendar.date(byAdding: .day, value: -1, to: Date())!
        let date3 = Date()
        
        // Create presets with specific dates
        let preset1 = ClipboardEntry(
            type: .program,
            name: "Old Preset",
            data: Data(),
            createdAt: date1,
            updatedAt: date1
        )
        modelContainer.mainContext.insert(preset1)
        
        let preset2 = ClipboardEntry(
            type: .program,
            name: "Middle Preset",
            data: Data(),
            createdAt: date2,
            updatedAt: date2
        )
        modelContainer.mainContext.insert(preset2)
        
        let preset3 = ClipboardEntry(
            type: .program,
            name: "New Preset",
            data: Data(),
            createdAt: date3,
            updatedAt: date3
        )
        modelContainer.mainContext.insert(preset3)
        
        try? modelContainer.mainContext.save()
        viewModel.refreshData()
        
        // Test date newest
        viewModel.sortOrder = .dateNewest
        viewModel.filterPresets()
        
        let namesNewest = viewModel.filteredPresets.map { $0.name }
        XCTAssertEqual(namesNewest, ["New Preset", "Middle Preset", "Old Preset"])
        
        // Test date oldest
        viewModel.sortOrder = .dateOldest
        viewModel.filterPresets()
        
        let namesOldest = viewModel.filteredPresets.map { $0.name }
        XCTAssertEqual(namesOldest, ["Old Preset", "Middle Preset", "New Preset"])
    }
    
    // MARK: - Sort Order Enum Tests
    
    func testSortOrderCases() {
        // Verify all sort order cases exist
        let allCases = LibrarianViewModel.SortOrder.allCases
        
        XCTAssertEqual(allCases.count, 6)
        XCTAssertTrue(allCases.contains(.nameAscending))
        XCTAssertTrue(allCases.contains(.nameDescending))
        XCTAssertTrue(allCases.contains(.dateNewest))
        XCTAssertTrue(allCases.contains(.dateOldest))
        XCTAssertTrue(allCases.contains(.ratingHighest))
        XCTAssertTrue(allCases.contains(.ratingLowest))
    }
    
    func testSortOrderRawValues() {
        XCTAssertEqual(LibrarianViewModel.SortOrder.nameAscending.rawValue, "Name (A-Z)")
        XCTAssertEqual(LibrarianViewModel.SortOrder.nameDescending.rawValue, "Name (Z-A)")
        XCTAssertEqual(LibrarianViewModel.SortOrder.dateNewest.rawValue, "Date (Newest)")
        XCTAssertEqual(LibrarianViewModel.SortOrder.dateOldest.rawValue, "Date (Oldest)")
        XCTAssertEqual(LibrarianViewModel.SortOrder.ratingHighest.rawValue, "Rating (Highest)")
        XCTAssertEqual(LibrarianViewModel.SortOrder.ratingLowest.rawValue, "Rating (Lowest)")
    }
    
    // MARK: - Edge Cases
    
    func testEmptySearchQuery() {
        let preset1 = viewModel.createPreset(name: "Preset 1")
        let preset2 = viewModel.createPreset(name: "Preset 2")
        
        viewModel.refreshData()
        viewModel.searchQuery = ""
        viewModel.filterPresets()
        
        XCTAssertEqual(viewModel.filteredPresets.count, 2)
    }
    
    func testSearchQueryWithNoMatches() {
        let preset1 = viewModel.createPreset(name: "Preset 1")
        let preset2 = viewModel.createPreset(name: "Preset 2")
        
        viewModel.refreshData()
        viewModel.searchQuery = "NonExistent"
        viewModel.filterPresets()
        
        XCTAssertEqual(viewModel.filteredPresets.count, 0)
    }
    
    func testCreatePresetWithEmptyName() {
        let preset = viewModel.createPreset(name: "")
        
        XCTAssertNotNil(preset)
        XCTAssertEqual(preset.name, "")
        
        viewModel.refreshData()
        XCTAssertEqual(viewModel.allPresets.count, 1)
    }
    
    // MARK: - Rating Sort Tests
    
    func testSortByRating() {
        let preset1 = viewModel.createPreset(name: "Preset 1", rating: 3)
        let preset2 = viewModel.createPreset(name: "Preset 2", rating: 5)
        let preset3 = viewModel.createPreset(name: "Preset 3", rating: 1)
        
        viewModel.refreshData()
        
        // Test highest rating first
        viewModel.sortOrder = .ratingHighest
        viewModel.filterPresets()
        
        let ratingsHighest = viewModel.filteredPresets.map { $0.rating }
        XCTAssertEqual(ratingsHighest, [5, 3, 1])
        
        // Test lowest rating first
        viewModel.sortOrder = .ratingLowest
        viewModel.filterPresets()
        
        let ratingsLowest = viewModel.filteredPresets.map { $0.rating }
        XCTAssertEqual(ratingsLowest, [1, 3, 5])
    }
}
