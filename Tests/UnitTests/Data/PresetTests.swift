// PresetTests.swift
// MonstaGuru
// Created by Mistral Vibe Code (Core Data Model Agent)

import XCTest
import SwiftData
@testable import Data

final class PresetTests: XCTestCase {
    
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
    
    // MARK: - Preset Initialization Tests
    
    func testPresetDefaultInitialization() {
        let preset = Preset.default
        
        XCTAssertEqual(preset.name, "Untitled")
        XCTAssertEqual(preset.author, "Unknown")
        XCTAssertEqual(preset.rating, 0)
        XCTAssertEqual(preset.tags.count, 0)
        XCTAssertNotNil(preset.id)
        XCTAssertNotNil(preset.createdAt)
        XCTAssertNotNil(preset.updatedAt)
    }
    
    func testPresetNewPreset() {
        let preset = Preset.newPreset()
        
        XCTAssertTrue(preset.name.contains("Preset"))
        XCTAssertNotNil(preset.id)
    }
    
    func testPresetWithProgram() {
        let program = Program(name: "Test Program")
        let preset = Preset.newPreset(program: program)
        
        XCTAssertNotNil(preset.program)
        XCTAssertEqual(preset.program?.name, "Test Program")
    }
    
    // MARK: - Preset Display Properties
    
    func testPresetDisplayName() {
        let preset1 = Preset(name: "Test Preset")
        XCTAssertEqual(preset1.displayName, "Test Preset")
        
        let preset2 = Preset(name: "")
        XCTAssertEqual(preset2.displayName, "Untitled")
    }
    
    func testPresetFirstTag() {
        let preset1 = Preset(tags: ["bass", "lead"])
        XCTAssertEqual(preset1.firstTag, "bass")
        
        let preset2 = Preset(tags: [])
        XCTAssertEqual(preset2.firstTag, "No Tags")
    }
    
    // MARK: - Preset Hashable Conformance
    
    func testPresetHashable() {
        let preset1 = Preset(name: "Preset 1")
        let preset2 = Preset(name: "Preset 2")
        let preset1Copy = preset1
        
        XCTAssertEqual(preset1, preset1Copy)
        XCTAssertNotEqual(preset1, preset2)
        
        let set: Set<Preset> = [preset1, preset2, preset1Copy]
        XCTAssertEqual(set.count, 2)
    }
    
    // MARK: - Preset Rating Clamping
    
    func testPresetRatingClamping() {
        let preset1 = Preset(rating: -1)
        XCTAssertEqual(preset1.rating, 0)
        
        let preset2 = Preset(rating: 10)
        XCTAssertEqual(preset2.rating, 5)
    }
    
    // MARK: - Preset Touch Method
    
    func testPresetTouch() {
        let preset = Preset()
        let originalDate = preset.updatedAt
        
        // Wait a tiny bit to ensure the date changes
        Thread.sleep(forTimeInterval: 0.01)
        
        preset.touch()
        
        XCTAssertNotEqual(preset.updatedAt, originalDate)
    }
}
