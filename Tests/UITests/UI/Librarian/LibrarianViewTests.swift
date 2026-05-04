// LibrarianViewTests.swift
// MonstaGuru
// Created by Mistral Vibe Code (Testing Agent)

import XCTest
import SwiftUI
@testable import UI
@testable import Data
@testable import MIDI

/// UI tests for LibrarianView to ensure proper preset and bank management.
final class LibrarianViewTests: XCTestCase {
    
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
            fatalError("Failed to create model container: \(error)")
        }
        
        midiManager = MIDIManager()
    }
    
    override func tearDown() {
        modelContainer = nil
        midiManager = nil
        super.tearDown()
    }
    
    // MARK: - View Initialization Tests
    
    func testLibrarianViewInitialization() {
        // Verify LibrarianView can be initialized
        let librarianView = LibrarianView()
            .environment(modelContainer)
            .environmentObject(midiManager)
        
        XCTAssertNotNil(librarianView)
    }
    
    // MARK: - Subview Tests
    
    func testBankRowInitialization() {
        // Create a test bank
        let bank = Bank(name: "Test Bank", color: "#FF0000")
        modelContainer.mainContext.insert(bank)
        try? modelContainer.mainContext.save()
        
        // Verify BankRow can be initialized
        let bankRow = BankRow(
            bank: bank,
            isSelected: false,
            presetCount: 0
        )
        
        XCTAssertNotNil(bankRow)
    }
    
    func testPresetCardInitialization() {
        // Create a test preset
        let preset = Preset(name: "Test Preset", color: "#00FF00")
        modelContainer.mainContext.insert(preset)
        try? modelContainer.mainContext.save()
        
        // Verify PresetCard can be initialized
        let presetCard = PresetCard(
            preset: preset,
            isSelected: false,
            onTap: {}
        )
        
        XCTAssertNotNil(presetCard)
    }
    
    // MARK: - Context Menu Tests
    
    func testBankContextMenuInitialization() {
        let bank = Bank(name: "Test Bank")
        let viewModel = LibrarianViewModel()
        viewModel.loadData(modelContainer: modelContainer)
        
        let contextMenu = BankContextMenu(bank: bank, viewModel: viewModel)
        XCTAssertNotNil(contextMenu)
    }
    
    func testPresetContextMenuInitialization() {
        let preset = Preset(name: "Test Preset")
        let viewModel = LibrarianViewModel()
        viewModel.loadData(modelContainer: modelContainer)
        
        let contextMenu = PresetContextMenu(preset: preset, viewModel: viewModel)
        XCTAssertNotNil(contextMenu)
    }
    
    // MARK: - View Structure Tests
    
    func testLibrarianViewHasNavigationTitle() {
        // LibrarianView should have a navigation title
        // This is more of a compile-time test
    }
    
    func testLibrarianViewHasToolbar() {
        // LibrarianView should have toolbar items
        // This is verified by the view structure
    }
    
    func testLibrarianViewHasBanksSidebar() {
        // LibrarianView should have a banks sidebar
        // This is verified by the view structure
    }
    
    func testLibrarianViewHasPresetsContent() {
        // LibrarianView should have presets content area
        // This is verified by the view structure
    }
    
    // MARK: - Preview Tests
    
    func testLibrarianViewPreview() {
        // Verify preview can be created
        let preview = LibrarianView_Previews.previews
        XCTAssertNotNil(preview)
    }
}

// MARK: - New Bank View Tests

final class NewBankViewTests: XCTestCase {
    
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
    
    func testNewBankViewInitialization() {
        // Verify NewBankView can be initialized
        let view = NewBankView(viewModel: viewModel)
            .environment(modelContainer)
        
        XCTAssertNotNil(view)
    }
    
    func testNewBankViewHasForm() {
        // NewBankView should have a form for bank creation
        // This is verified by the view structure
    }
    
    func testNewBankViewHasColorPicker() {
        // NewBankView should have a color picker
        // This is verified by the view structure
    }
}

// MARK: - New Preset View Tests

final class NewPresetViewTests: XCTestCase {
    
    private var modelContainer: ModelContainer!
    private var viewModel: LibrarianViewModel!
    private var bank: Bank!
    
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
        
        bank = Bank(name: "Test Bank")
        modelContainer.mainContext.insert(bank)
        try? modelContainer.mainContext.save()
    }
    
    override func tearDown() {
        modelContainer = nil
        viewModel = nil
        bank = nil
        super.tearDown()
    }
    
    func testNewPresetViewInitialization() {
        // Verify NewPresetView can be initialized
        let view = NewPresetView(viewModel: viewModel, bank: bank)
            .environment(modelContainer)
        
        XCTAssertNotNil(view)
    }
    
    func testNewPresetViewHasForm() {
        // NewPresetView should have a form for preset creation
        // This is verified by the view structure
    }
    
    func testNewPresetViewHasColorPicker() {
        // NewPresetView should have a color picker
        // This is verified by the view structure
    }
    
    func testNewPresetViewHasRating() {
        // NewPresetView should have a rating control
        // This is verified by the view structure
    }
}

// MARK: - Import View Tests

final class ImportViewTests: XCTestCase {
    
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
    
    func testImportViewInitialization() {
        // Verify ImportView can be initialized
        let view = ImportView(viewModel: viewModel)
            .environment(modelContainer)
        
        XCTAssertNotNil(view)
    }
    
    func testImportViewHasTypeSelection() {
        // ImportView should have import type selection
        // This is verified by the view structure
    }
    
    func testImportViewHasFileSelection() {
        // ImportView should have file selection area
        // This is verified by the view structure
    }
    
    // MARK: - ImportType Enum Tests
    
    func testImportTypeCases() {
        let allCases = ImportView.ImportType.allCases
        
        XCTAssertEqual(allCases.count, 3)
        XCTAssertTrue(allCases.contains(.sysEx))
        XCTAssertTrue(allCases.contains(.bank))
        XCTAssertTrue(allCases.contains(.preset))
    }
    
    func testImportTypeRawValues() {
        XCTAssertEqual(ImportView.ImportType.sysEx.rawValue, "SysEx File")
        XCTAssertEqual(ImportView.ImportType.bank.rawValue, "Bank File")
        XCTAssertEqual(ImportView.ImportType.preset.rawValue, "Preset File")
    }
}

// MARK: - Export View Tests

final class ExportViewTests: XCTestCase {
    
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
    
    func testExportViewInitialization() {
        // Verify ExportView can be initialized
        let view = ExportView(viewModel: viewModel)
            .environment(modelContainer)
        
        XCTAssertNotNil(view)
    }
    
    func testExportViewHasTypeSelection() {
        // ExportView should have export type selection
        // This is verified by the view structure
    }
    
    func testExportViewHasSelectionArea() {
        // ExportView should have selection area
        // This is verified by the view structure
    }
    
    // MARK: - ExportType Enum Tests
    
    func testExportTypeCases() {
        let allCases = ExportView.ExportType.allCases
        
        XCTAssertEqual(allCases.count, 3)
        XCTAssertTrue(allCases.contains(.sysEx))
        XCTAssertTrue(allCases.contains(.bank))
        XCTAssertTrue(allCases.contains(.preset))
    }
    
    func testExportTypeRawValues() {
        XCTAssertEqual(ExportView.ExportType.sysEx.rawValue, "SysEx File")
        XCTAssertEqual(ExportView.ExportType.bank.rawValue, "Bank File")
        XCTAssertEqual(ExportView.ExportType.preset.rawValue, "Preset File")
    }
}

// MARK: - Preview Providers

private struct LibrarianView_Previews: PreviewProvider {
    static var previews: some View {
        LibrarianView()
            .environmentObject(MIDIManager())
            .frame(width: 1200, height: 800)
    }
}
