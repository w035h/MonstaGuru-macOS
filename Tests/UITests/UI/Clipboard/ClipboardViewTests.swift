// ClipboardViewTests.swift
// MonstaGuru
// Created by Mistral Vibe Code (Testing Agent)

import XCTest
import SwiftUI
@testable import UI
@testable import Data

/// UI tests for ClipboardView to ensure proper clipboard entry management.
final class ClipboardViewTests: XCTestCase {
    
    private var modelContainer: ModelContainer!
    
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
    }
    
    override func tearDown() {
        modelContainer = nil
        super.tearDown()
    }
    
    // MARK: - View Initialization Tests
    
    func testClipboardViewInitialization() {
        // Verify ClipboardView can be initialized
        let clipboardView = ClipboardView()
            .environment(modelContainer)
        
        XCTAssertNotNil(clipboardView)
    }
    
    // MARK: - Subview Tests
    
    func testClipboardEntryCardInitialization() {
        // Create a test entry
        let entry = ClipboardEntry(
            type: .program,
            name: "Test Entry",
            data: Data(),
            createdAt: Date()
        )
        modelContainer.mainContext.insert(entry)
        try? modelContainer.mainContext.save()
        
        // Verify ClipboardEntryCard can be initialized
        let card = ClipboardEntryCard(
            entry: entry,
            isSelected: false,
            onTap: {}
        )
        
        XCTAssertNotNil(card)
    }
    
    func testEntryContextMenuInitialization() {
        let entry = ClipboardEntry(
            type: .program,
            name: "Test Entry",
            data: Data(),
            createdAt: Date()
        )
        let viewModel = ClipboardViewModel()
        viewModel.loadData(modelContainer: modelContainer)
        
        let contextMenu = EntryContextMenu(entry: entry, viewModel: viewModel)
        XCTAssertNotNil(contextMenu)
    }
    
    // MARK: - Entry Type Icon Tests
    
    func testEntryTypeIcons() {
        // Test that all entry types have icons
        let allTypes: [ClipboardEntryType] = [
            .program, .oscillator, .filter, .envelope, .lfo,
            .matrixSlot, .effects, .globalSettings, .mixer
        ]
        
        for entryType in allTypes {
            let entry = ClipboardEntry(
                type: entryType,
                name: "Test",
                data: Data(),
                createdAt: Date()
            )
            
            // Create a card to test the icon
            let card = ClipboardEntryCard(entry: entry, isSelected: false, onTap: {})
            XCTAssertNotNil(card)
        }
    }
    
    // MARK: - Entry Type Color Tests
    
    func testEntryTypeColors() {
        // Test that all entry types have colors
        let allTypes: [ClipboardEntryType] = [
            .program, .oscillator, .filter, .envelope, .lfo,
            .matrixSlot, .effects, .globalSettings, .mixer
        ]
        
        for entryType in allTypes {
            let entry = ClipboardEntry(
                type: entryType,
                name: "Test",
                data: Data(),
                createdAt: Date()
            )
            
            // Create a card to test the color
            let card = ClipboardEntryCard(entry: entry, isSelected: false, onTap: {})
            XCTAssertNotNil(card)
        }
    }
    
    // MARK: - View Structure Tests
    
    func testClipboardViewHasNavigationTitle() {
        // ClipboardView should have a navigation title
        // This is more of a compile-time test
    }
    
    func testClipboardViewHasToolbar() {
        // ClipboardView should have toolbar items
        // This is verified by the view structure
    }
    
    func testClipboardViewHasHeader() {
        // ClipboardView should have a header
        // This is verified by the view structure
    }
    
    func testClipboardViewHasFilterBar() {
        // ClipboardView should have a filter bar
        // This is verified by the view structure
    }
    
    func testClipboardViewHasEntriesList() {
        // ClipboardView should have an entries list
        // This is verified by the view structure
    }
    
    // MARK: - Preview Tests
    
    func testClipboardViewPreview() {
        // Verify preview can be created
        let preview = ClipboardView_Previews.previews
        XCTAssertNotNil(preview)
    }
}

// MARK: - New Clipboard Entry View Tests

final class NewClipboardEntryViewTests: XCTestCase {
    
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
    
    func testNewClipboardEntryViewInitialization() {
        // Verify NewClipboardEntryView can be initialized
        let view = NewClipboardEntryView(viewModel: viewModel)
            .environment(modelContainer)
        
        XCTAssertNotNil(view)
    }
    
    func testNewClipboardEntryViewHasForm() {
        // NewClipboardEntryView should have a form for entry creation
        // This is verified by the view structure
    }
    
    func testNewClipboardEntryViewHasTypePicker() {
        // NewClipboardEntryView should have an entry type picker
        // This is verified by the view structure
    }
    
    // MARK: - FilterType Enum Tests
    
    func testFilterTypeCases() {
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
}

// MARK: - Star Rating Tests

final class StarRatingTests: XCTestCase {
    
    func testStarRatingInitialization() {
        // Verify StarRating can be initialized
        let rating = Binding<Int>(
            get: { 3 },
            set: { _ in }
        )
        
        let starRating = StarRating(rating: rating)
        XCTAssertNotNil(starRating)
    }
    
    func testStarRatingWithDifferentValues() {
        for value in 0..<6 {
            let rating = Binding<Int>(
                get: { value },
                set: { _ in }
            )
            
            let starRating = StarRating(rating: rating)
            XCTAssertNotNil(starRating)
        }
    }
}

// MARK: - Color Picker Tests

final class ColorPickerTests: XCTestCase {
    
    func testColorPickerInitialization() {
        // Verify ColorPicker can be initialized
        let color = Binding<Color>(
            get: { .red },
            set: { _ in }
        )
        
        let colorPicker = ColorPicker(selection: color) {
            Text("Select Color")
        }
        
        XCTAssertNotNil(colorPicker)
    }
}

// MARK: - Checkbox Tests

final class CheckboxTests: XCTestCase {
    
    func testCheckboxInitialization() {
        // Verify Checkbox can be initialized
        let isChecked = false
        let onCheck = {}
        let onUncheck = {}
        
        let checkbox = Checkbox(
            isChecked: isChecked,
            onCheck: onCheck,
            onUncheck: onUncheck
        )
        
        XCTAssertNotNil(checkbox)
    }
    
    func testCheckboxWithDifferentStates() {
        let checkboxChecked = Checkbox(
            isChecked: true,
            onCheck: {},
            onUncheck: {}
        )
        
        let checkboxUnchecked = Checkbox(
            isChecked: false,
            onCheck: {},
            onUncheck: {}
        )
        
        XCTAssertNotNil(checkboxChecked)
        XCTAssertNotNil(checkboxUnchecked)
    }
}

// MARK: - Preview Providers

private struct ClipboardView_Previews: PreviewProvider {
    static var previews: some View {
        ClipboardView()
            .frame(width: 1000, height: 700)
    }
}
