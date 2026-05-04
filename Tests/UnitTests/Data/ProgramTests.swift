// ProgramTests.swift
// MonstaGuru
// Created by Mistral Vibe Code (Core Data Model Agent)

import XCTest
import SwiftData
@testable import Data

final class ProgramTests: XCTestCase {
    
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
    
    // MARK: - Program Initialization Tests
    
    func testProgramDefaultInitialization() {
        let program = Program.default
        
        XCTAssertEqual(program.name, "Untitled")
        XCTAssertEqual(program.number, 0)
        XCTAssertNotNil(program.id)
        XCTAssertNotNil(program.createdAt)
        XCTAssertNotNil(program.updatedAt)
        
        // Check oscillators
        XCTAssertEqual(program.oscillators.count, 3)
        XCTAssertEqual(program.oscillators[0].index, 1)
        XCTAssertEqual(program.oscillators[1].index, 2)
        XCTAssertEqual(program.oscillators[2].index, 3)
        
        // Check filters
        XCTAssertEqual(program.filters.count, 2)
        XCTAssertEqual(program.filters[0].index, 1)
        XCTAssertEqual(program.filters[1].index, 2)
        
        // Check envelopes
        XCTAssertEqual(program.envelopes.count, 3)
        
        // Check LFOs
        XCTAssertEqual(program.lfos.count, 3)
        
        // Check matrix
        XCTAssertEqual(program.matrix.count, 12)
    }
    
    func testProgramNewProgram() {
        let program = Program.newProgram()
        
        XCTAssertTrue(program.name.contains("Program"))
        XCTAssertNotNil(program.id)
    }
    
    func testProgramCopy() {
        let original = Program.default
        original.name = "Original"
        original.number = 1
        
        let copy = original.copy()
        
        XCTAssertNotEqual(copy.id, original.id)
        XCTAssertEqual(copy.name, "Original (Copy)")
        XCTAssertEqual(copy.number, original.number)
        XCTAssertEqual(copy.oscillators.count, original.oscillators.count)
    }
    
    // MARK: - Program Display Properties
    
    func testProgramDisplayName() {
        let program = Program(name: "Test Program", number: 5)
        XCTAssertEqual(program.displayName, "05: Test Program")
    }
    
    // MARK: - Program Hashable Conformance
    
    func testProgramHashable() {
        let program1 = Program(name: "Program 1")
        let program2 = Program(name: "Program 2")
        let program1Copy = program1
        
        XCTAssertEqual(program1, program1Copy)
        XCTAssertNotEqual(program1, program2)
        
        let set: Set<Program> = [program1, program2, program1Copy]
        XCTAssertEqual(set.count, 2)
    }
    
    // MARK: - Program Number Clamping
    
    func testProgramNumberClamping() {
        let program1 = Program(number: -10)
        XCTAssertEqual(program1.number, 0)
        
        let program2 = Program(number: 200)
        XCTAssertEqual(program2.number, 127)
    }
    
    // MARK: - Program Touch Method
    
    func testProgramTouch() {
        let program = Program()
        let originalDate = program.updatedAt
        
        // Wait a tiny bit to ensure the date changes
        Thread.sleep(forTimeInterval: 0.01)
        
        program.touch()
        
        XCTAssertNotEqual(program.updatedAt, originalDate)
    }
    
    // MARK: - Oscillator Tests
    
    func testOscillatorDefault() {
        let osc = Oscillator.default(index: 1)
        
        XCTAssertEqual(osc.index, 1)
        XCTAssertEqual(osc.waveform, .sawtooth)
        XCTAssertEqual(osc.coarsePitch, 0)
        XCTAssertEqual(osc.finePitch, 0)
        XCTAssertEqual(osc.detune, 0)
        XCTAssertEqual(osc.level, 100)
        XCTAssertEqual(osc.pan, 0)
    }
    
    func testOscillatorClamping() {
        let osc = Oscillator(
            index: 1,
            coarsePitch: -100,
            finePitch: 100,
            detune: 200,
            level: 200,
            pan: 100
        )
        
        XCTAssertEqual(osc.coarsePitch, -48)
        XCTAssertEqual(osc.finePitch, 50)
        XCTAssertEqual(osc.detune, 127)
        XCTAssertEqual(osc.level, 127)
        XCTAssertEqual(osc.pan, 63)
    }
    
    // MARK: - Filter Tests
    
    func testFilterDefault() {
        let filter = Filter.default(index: 1)
        
        XCTAssertEqual(filter.index, 1)
        XCTAssertEqual(filter.type, .lowPass24dB)
        XCTAssertEqual(filter.cutoff, 64)
        XCTAssertEqual(filter.resonance, 0)
    }
    
    func testFilterClamping() {
        let filter = Filter(
            index: 1,
            cutoff: -10,
            resonance: 200,
            envelopeAmount: -100,
            lfoAmount: 100
        )
        
        XCTAssertEqual(filter.cutoff, 0)
        XCTAssertEqual(filter.resonance, 127)
        XCTAssertEqual(filter.envelopeAmount, -64)
        XCTAssertEqual(filter.lfoAmount, 63)
    }
    
    // MARK: - Envelope Tests
    
    func testEnvelopeDefault() {
        let env = Envelope.default(index: 1)
        
        XCTAssertEqual(env.index, 1)
        XCTAssertEqual(env.attack, 0)
        XCTAssertEqual(env.decay, 64)
        XCTAssertEqual(env.sustain, 127)
        XCTAssertEqual(env.release, 0)
    }
    
    // MARK: - LFO Tests
    
    func testLFODefault() {
        let lfo = LFO.default(index: 1)
        
        XCTAssertEqual(lfo.index, 1)
        XCTAssertEqual(lfo.waveform, .sine)
        XCTAssertEqual(lfo.rate, 64)
        XCTAssertEqual(lfo.sync, .free)
    }
    
    // MARK: - MatrixSlot Tests
    
    func testMatrixSlotDefault() {
        let slot = MatrixSlot.default(index: 1)
        
        XCTAssertEqual(slot.index, 1)
        XCTAssertEqual(slot.source, .off)
        XCTAssertEqual(slot.destination, .off)
        XCTAssertEqual(slot.amount, 0)
    }
    
    func testMatrixSlotClamping() {
        let slot = MatrixSlot(index: 1, amount: -100)
        XCTAssertEqual(slot.amount, -64)
        
        let slot2 = MatrixSlot(index: 1, amount: 100)
        XCTAssertEqual(slot2.amount, 63)
    }
    
    // MARK: - Effects Tests
    
    func testEffectsDefault() {
        let effects = Effects.default
        
        XCTAssertEqual(effects.effect1.index, 1)
        XCTAssertEqual(effects.effect2.index, 2)
        XCTAssertEqual(effects.effect3.index, 3)
        XCTAssertEqual(effects.masterLevel, 100)
    }
    
    // MARK: - GlobalSettings Tests
    
    func testGlobalSettingsDefault() {
        let global = GlobalSettings.default
        
        XCTAssertEqual(global.polyphony, 8)
        XCTAssertEqual(global.pitchBendRange, 2)
        XCTAssertEqual(global.masterVolume, 100)
    }
    
    func testGlobalSettingsClamping() {
        let global = GlobalSettings(
            polyphony: 0,
            pitchBendRange: -20,
            masterTune: -100,
            velocityCurve: 10
        )
        
        XCTAssertEqual(global.polyphony, 1)
        XCTAssertEqual(global.pitchBendRange, -12)
        XCTAssertEqual(global.masterTune, -50)
        XCTAssertEqual(global.velocityCurve, 3)
    }
    
    // MARK: - Mixer Tests
    
    func testMixerDefault() {
        let mixer = Mixer.default
        
        XCTAssertEqual(mixer.osc1Level, 127)
        XCTAssertEqual(mixer.osc2Level, 127)
        XCTAssertEqual(mixer.osc3Level, 127)
    }
}
