// MIDISettingTests.swift
// MonstaGuru
// Created by Mistral Vibe Code (Core Data Model Agent)

import XCTest
import SwiftData
@testable import Data

final class MIDISettingTests: XCTestCase {
    
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
    
    // MARK: - MIDISetting Initialization Tests
    
    func testMIDISettingDefaultInitialization() {
        let setting = MIDISetting.default
        
        XCTAssertEqual(setting.name, "Default")
        XCTAssertEqual(setting.inputDeviceName, "")
        XCTAssertEqual(setting.outputDeviceName, "")
        XCTAssertEqual(setting.programChangeChannel, 0)
        XCTAssertEqual(setting.noteChannel, 0)
        XCTAssertFalse(setting.midiThruEnabled)
        XCTAssertTrue(setting.sysexEnabled)
        XCTAssertTrue(setting.sysexTransmitEnabled)
        XCTAssertTrue(setting.isActive)
        XCTAssertNotNil(setting.id)
        XCTAssertNotNil(setting.createdAt)
        XCTAssertNotNil(setting.updatedAt)
    }
    
    func testMIDISettingNewSetting() {
        let setting = MIDISetting.newSetting()
        
        XCTAssertTrue(setting.name.contains("MIDI Config"))
        XCTAssertNotNil(setting.id)
    }
    
    func testMIDISettingWithDevices() {
        let setting = MIDISetting(
            name: "Test Config",
            inputDeviceName: "MicroMonsta 2",
            outputDeviceName: "MicroMonsta 2",
            programChangeChannel: 1,
            noteChannel: 1,
            midiThruEnabled: true,
            sysexEnabled: true,
            sysexTransmitEnabled: true,
            isActive: true
        )
        
        XCTAssertEqual(setting.name, "Test Config")
        XCTAssertEqual(setting.inputDeviceName, "MicroMonsta 2")
        XCTAssertEqual(setting.outputDeviceName, "MicroMonsta 2")
        XCTAssertEqual(setting.programChangeChannel, 1)
        XCTAssertEqual(setting.noteChannel, 1)
        XCTAssertTrue(setting.midiThruEnabled)
    }
    
    // MARK: - MIDISetting Display Properties
    
    func testMIDISettingDisplayName() {
        let setting1 = MIDISetting(name: "Test Config")
        XCTAssertEqual(setting1.displayName, "Test Config")
        
        let setting2 = MIDISetting(name: "")
        XCTAssertEqual(setting2.displayName, "Default")
    }
    
    func testMIDISettingDescription() {
        let setting1 = MIDISetting(
            inputDeviceName: "Input Device",
            outputDeviceName: "Output Device",
            programChangeChannel: 1,
            noteChannel: 2
        )
        let description = setting1.description
        XCTAssertTrue(description.contains("In: Input Device"))
        XCTAssertTrue(description.contains("Out: Output Device"))
        XCTAssertTrue(description.contains("PC: Ch 1"))
        XCTAssertTrue(description.contains("Notes: Ch 2"))
    }
    
    // MARK: - MIDISetting Hashable Conformance
    
    func testMIDISettingHashable() {
        let setting1 = MIDISetting(name: "Setting 1")
        let setting2 = MIDISetting(name: "Setting 2")
        let setting1Copy = setting1
        
        XCTAssertEqual(setting1, setting1Copy)
        XCTAssertNotEqual(setting1, setting2)
        
        let set: Set<MIDISetting> = [setting1, setting2, setting1Copy]
        XCTAssertEqual(set.count, 2)
    }
    
    // MARK: - MIDISetting Channel Clamping
    
    func testMIDISettingChannelClamping() {
        let setting1 = MIDISetting(programChangeChannel: -1)
        XCTAssertEqual(setting1.programChangeChannel, 0)
        
        let setting2 = MIDISetting(programChangeChannel: 17)
        XCTAssertEqual(setting2.programChangeChannel, 16)
        
        let setting3 = MIDISetting(noteChannel: -1)
        XCTAssertEqual(setting3.noteChannel, 0)
        
        let setting4 = MIDISetting(noteChannel: 17)
        XCTAssertEqual(setting4.noteChannel, 16)
    }
    
    // MARK: - MIDISetting Touch Method
    
    func testMIDISettingTouch() {
        let setting = MIDISetting()
        let originalDate = setting.updatedAt
        
        // Wait a tiny bit to ensure the date changes
        Thread.sleep(forTimeInterval: 0.01)
        
        setting.touch()
        
        XCTAssertNotEqual(setting.updatedAt, originalDate)
    }
}
