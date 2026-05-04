// ClipboardEntryTests.swift
// MonstaGuru
// Created by Mistral Vibe Code (Core Data Model Agent)

import XCTest
import SwiftData
@testable import Data

final class ClipboardEntryTests: XCTestCase {
    
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
    
    // MARK: - ClipboardEntry Initialization Tests
    
    func testClipboardEntryFromProgram() {
        let program = Program(name: "Test Program")
        let encoder = JSONEncoder()
        let data = try! encoder.encode(program)
        
        let entry = ClipboardEntry(
            type: .program,
            name: "Test Program",
            data: data
        )
        
        XCTAssertEqual(entry.type, .program)
        XCTAssertEqual(entry.name, "Test Program")
        XCTAssertNotNil(entry.data)
        
        // Test decoding
        let decodedProgram: Program? = entry.decode()
        XCTAssertNotNil(decodedProgram)
        XCTAssertEqual(decodedProgram?.name, "Test Program")
    }
    
    func testClipboardEntryFromOscillator() {
        let oscillator = Oscillator.default(index: 1)
        let entry = ClipboardEntry.fromOscillator(oscillator)
        
        XCTAssertEqual(entry.type, .oscillator)
        XCTAssertEqual(entry.name, "Oscillator 1")
        
        let decodedOsc: Oscillator? = entry.decode()
        XCTAssertNotNil(decodedOsc)
        XCTAssertEqual(decodedOsc?.index, 1)
    }
    
    func testClipboardEntryFromFilter() {
        let filter = Filter.default(index: 1)
        let entry = ClipboardEntry.fromFilter(filter)
        
        XCTAssertEqual(entry.type, .filter)
        XCTAssertEqual(entry.name, "Filter 1")
        
        let decodedFilter: Filter? = entry.decode()
        XCTAssertNotNil(decodedFilter)
        XCTAssertEqual(decodedFilter?.index, 1)
    }
    
    func testClipboardEntryFromEnvelope() {
        let envelope = Envelope.default(index: 1)
        let entry = ClipboardEntry.fromEnvelope(envelope)
        
        XCTAssertEqual(entry.type, .envelope)
        XCTAssertEqual(entry.name, "Envelope 1")
        
        let decodedEnv: Envelope? = entry.decode()
        XCTAssertNotNil(decodedEnv)
        XCTAssertEqual(decodedEnv?.index, 1)
    }
    
    func testClipboardEntryFromLFO() {
        let lfo = LFO.default(index: 1)
        let entry = ClipboardEntry.fromLFO(lfo)
        
        XCTAssertEqual(entry.type, .lfo)
        XCTAssertEqual(entry.name, "LFO 1")
        
        let decodedLFO: LFO? = entry.decode()
        XCTAssertNotNil(decodedLFO)
        XCTAssertEqual(decodedLFO?.index, 1)
    }
    
    func testClipboardEntryFromMatrixSlot() {
        let slot = MatrixSlot.default(index: 1)
        let entry = ClipboardEntry.fromMatrixSlot(slot)
        
        XCTAssertEqual(entry.type, .matrixSlot)
        XCTAssertEqual(entry.name, "Matrix Slot 1")
        
        let decodedSlot: MatrixSlot? = entry.decode()
        XCTAssertNotNil(decodedSlot)
        XCTAssertEqual(decodedSlot?.index, 1)
    }
    
    func testClipboardEntryFromEffects() {
        let effects = Effects.default
        let entry = ClipboardEntry.fromEffects(effects)
        
        XCTAssertEqual(entry.type, .effects)
        XCTAssertEqual(entry.name, "Effects")
        
        let decodedEffects: Effects? = entry.decode()
        XCTAssertNotNil(decodedEffects)
    }
    
    func testClipboardEntryFromGlobalSettings() {
        let global = GlobalSettings.default
        let entry = ClipboardEntry.fromGlobalSettings(global)
        
        XCTAssertEqual(entry.type, .globalSettings)
        XCTAssertEqual(entry.name, "Global Settings")
        
        let decodedGlobal: GlobalSettings? = entry.decode()
        XCTAssertNotNil(decodedGlobal)
    }
    
    func testClipboardEntryFromMixer() {
        let mixer = Mixer.default
        let entry = ClipboardEntry.fromMixer(mixer)
        
        XCTAssertEqual(entry.type, .mixer)
        XCTAssertEqual(entry.name, "Mixer")
        
        let decodedMixer: Mixer? = entry.decode()
        XCTAssertNotNil(decodedMixer)
    }
    
    // MARK: - ClipboardEntry Display Properties
    
    func testClipboardEntryDisplayName() {
        let entry1 = ClipboardEntry(type: .program, name: "Test Entry", data: Data())
        XCTAssertEqual(entry1.displayName, "Test Entry")
        
        let entry2 = ClipboardEntry(type: .oscillator, name: "", data: Data())
        XCTAssertEqual(entry2.displayName, "Oscillator")
    }
    
    // MARK: - ClipboardEntry Hashable Conformance
    
    func testClipboardEntryHashable() {
        let entry1 = ClipboardEntry(type: .program, name: "Entry 1", data: Data())
        let entry2 = ClipboardEntry(type: .program, name: "Entry 2", data: Data())
        let entry1Copy = entry1
        
        XCTAssertEqual(entry1, entry1Copy)
        XCTAssertNotEqual(entry1, entry2)
        
        let set: Set<ClipboardEntry> = [entry1, entry2, entry1Copy]
        XCTAssertEqual(set.count, 2)
    }
    
    // MARK: - ClipboardEntryType Tests
    
    func testClipboardEntryTypeDisplayNames() {
        XCTAssertEqual(ClipboardEntryType.program.displayName, "Program")
        XCTAssertEqual(ClipboardEntryType.oscillator.displayName, "Oscillator")
        XCTAssertEqual(ClipboardEntryType.filter.displayName, "Filter")
        XCTAssertEqual(ClipboardEntryType.envelope.displayName, "Envelope")
        XCTAssertEqual(ClipboardEntryType.lfo.displayName, "LFO")
        XCTAssertEqual(ClipboardEntryType.matrixSlot.displayName, "Matrix Slot")
        XCTAssertEqual(ClipboardEntryType.effects.displayName, "Effects")
        XCTAssertEqual(ClipboardEntryType.globalSettings.displayName, "Global Settings")
        XCTAssertEqual(ClipboardEntryType.mixer.displayName, "Mixer")
    }
}
