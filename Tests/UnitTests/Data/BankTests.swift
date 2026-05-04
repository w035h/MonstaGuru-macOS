// BankTests.swift
// MonstaGuru
// Created by Mistral Vibe Code (Core Data Model Agent)

import XCTest
import SwiftData
@testable import Data

final class BankTests: XCTestCase {
    
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    
    override func setUp() {
        super.setUp()
        do {
            modelContainer = try ModelContainer(
                for: Program.self, Preset.self, Bank.self, ClipboardEntry.self, MIDISetting.self,
                configurations: ModelConfiguration(url: URL(fileURLWithPath: "/dev/null"))
            )
            modelContext = ModelContext(modelContainer)
        } catch {
            XCTFail("Failed to create ModelContainer: \(error)")
        }
    }
    
    override func tearDown() {
        modelContainer = nil
        modelContext = nil
        super.tearDown()
    }
    
    // MARK: - Bank Initialization Tests
    
    func testBankDefaultInitialization() {
        let bank = Bank.default
        
        XCTAssertEqual(bank.name, "Untitled Bank")
        XCTAssertEqual(bank.presets.count, 0)
        XCTAssertNotNil(bank.id)
        XCTAssertNotNil(bank.createdAt)
        XCTAssertNotNil(bank.updatedAt)
    }
    
    func testBankNewBank() {
        let bank = Bank.newBank()
        
        XCTAssertTrue(bank.name.contains("Bank"))
        XCTAssertNotNil(bank.id)
    }
    
    func testBankWithPresets() {
        let presets = MockPresetGenerator.mockPresets()
        let bank = Bank(name: "Test Bank", presets: presets)
        
        XCTAssertEqual(bank.presets.count, presets.count)
    }
    
    // MARK: - Bank Display Properties
    
    func testBankDisplayName() {
        let bank1 = Bank(name: "Test Bank")
        XCTAssertEqual(bank1.displayName, "Test Bank")
        
        let bank2 = Bank(name: "")
        XCTAssertEqual(bank2.displayName, "Untitled Bank")
    }
    
    func testBankPresetCount() {
        let presets = MockPresetGenerator.mockPresets()
        let bank = Bank(presets: presets)
        
        XCTAssertEqual(bank.presetCount, presets.count)
    }
    
    // MARK: - Bank Hashable Conformance
    
    func testBankHashable() {
        let bank1 = Bank(name: "Bank 1")
        let bank2 = Bank(name: "Bank 2")
        let bank1Copy = bank1
        
        XCTAssertEqual(bank1, bank1Copy)
        XCTAssertNotEqual(bank1, bank2)
        
        let set: Set<Bank> = [bank1, bank2, bank1Copy]
        XCTAssertEqual(set.count, 2)
    }
    
    // MARK: - Bank Mutating Methods
    
    func testBankAddPreset() {
        let bank = Bank()
        let preset = Preset(name: "Test Preset")
        
        let originalCount = bank.presets.count
        bank.addPreset(preset)
        
        XCTAssertEqual(bank.presets.count, originalCount + 1)
        XCTAssertEqual(bank.presets.last?.name, "Test Preset")
    }
    
    func testBankRemovePreset() {
        let preset = Preset(name: "Test Preset")
        let bank = Bank(presets: [preset])
        
        bank.removePreset(preset)
        
        XCTAssertEqual(bank.presets.count, 0)
    }
    
    func testBankReorderPresets() {
        let preset1 = Preset(name: "Preset 1")
        let preset2 = Preset(name: "Preset 2")
        let preset3 = Preset(name: "Preset 3")
        let bank = Bank(presets: [preset1, preset2, preset3])
        
        bank.reorderPresets(from: IndexSet(integer: 0), to: 2)
        
        XCTAssertEqual(bank.presets[0].name, "Preset 2")
        XCTAssertEqual(bank.presets[1].name, "Preset 3")
        XCTAssertEqual(bank.presets[2].name, "Preset 1")
    }
    
    // MARK: - Bank Touch Method
    
    func testBankTouch() {
        let bank = Bank()
        let originalDate = bank.updatedAt
        
        // Wait a tiny bit to ensure the date changes
        Thread.sleep(forTimeInterval: 0.01)
        
        bank.touch()
        
        XCTAssertNotEqual(bank.updatedAt, originalDate)
    }
}
