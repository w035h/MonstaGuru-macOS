// MockProgramGenerator.swift
// MonstaGuru
// Created by Mistral Vibe Code (Core Data Model Agent)

import Foundation

/// Generates mock Program data for testing and development.
public enum MockProgramGenerator {
    
    /// Generates a default init program.
    public static func initProgram() -> Program {
        return Program(
            name: "Init Program",
            number: 0,
            oscillators: [
                Oscillator(
                    index: 1,
                    waveform: .sawtooth,
                    coarsePitch: 0,
                    finePitch: 0,
                    detune: 0,
                    syncEnabled: false,
                    ringModEnabled: false,
                    pulseWidth: 64,
                    level: 100,
                    pan: 0
                ),
                Oscillator(
                    index: 2,
                    waveform: .sawtooth,
                    coarsePitch: 0,
                    finePitch: 0,
                    detune: 0,
                    syncEnabled: false,
                    ringModEnabled: false,
                    pulseWidth: 64,
                    level: 100,
                    pan: 0
                ),
                Oscillator(
                    index: 3,
                    waveform: .sawtooth,
                    coarsePitch: 0,
                    finePitch: 0,
                    detune: 0,
                    syncEnabled: false,
                    ringModEnabled: false,
                    pulseWidth: 64,
                    level: 0,
                    pan: 0
                )
            ],
            mixer: Mixer(
                osc1Level: 127,
                osc2Level: 127,
                osc3Level: 0,
                noiseLevel: 0,
                externalLevel: 0,
                ringModLevel: 0
            ),
            filters: [
                Filter(
                    index: 1,
                    type: .lowPass24dB,
                    cutoff: 127,
                    resonance: 0,
                    keyTrack: 64
                ),
                Filter(
                    index: 2,
                    type: .off,
                    cutoff: 64,
                    resonance: 0,
                    keyTrack: 64
                )
            ],
            envelopes: [
                Envelope(
                    index: 1,
                    attack: 0,
                    decay: 64,
                    sustain: 127,
                    release: 64
                ),
                Envelope(
                    index: 2,
                    attack: 0,
                    decay: 64,
                    sustain: 127,
                    release: 64
                ),
                Envelope(
                    index: 3,
                    attack: 0,
                    decay: 64,
                    sustain: 127,
                    release: 64
                )
            ],
            lfos: [
                LFO(
                    index: 1,
                    waveform: .sine,
                    rate: 64,
                    sync: .free
                ),
                LFO(
                    index: 2,
                    waveform: .sine,
                    rate: 64,
                    sync: .free
                ),
                LFO(
                    index: 3,
                    waveform: .sine,
                    rate: 64,
                    sync: .free
                )
            ],
            matrix: (1...12).map { 
                MatrixSlot(index: $0, source: .off, destination: .off, amount: 0)
            },
            effects: Effects(),
            global: GlobalSettings()
        )
    }
    
    /// Generates a bass program.
    public static func bassProgram() -> Program {
        var program = initProgram()
        program.name = "Deep Bass"
        program.number = 1
        
        // Configure oscillators for bass
        program.oscillators[0].waveform = .sawtooth
        program.oscillators[0].coarsePitch = -12
        program.oscillators[0].level = 127
        
        program.oscillators[1].waveform = .sawtooth
        program.oscillators[1].coarsePitch = -12
        program.oscillators[1].level = 127
        
        program.oscillators[2].waveform = .sine
        program.oscillators[2].coarsePitch = -24
        program.oscillators[2].level = 80
        
        // Configure mixer
        program.mixer = Mixer(
            osc1Level: 127,
            osc2Level: 127,
            osc3Level: 80,
            noiseLevel: 0,
            externalLevel: 0,
            ringModLevel: 0
        )
        
        // Configure filter for bass
        program.filters[0].type = .lowPass24dB
        program.filters[0].cutoff = 40
        program.filters[0].resonance = 64
        program.filters[0].envelopeAmount = -32
        
        // Configure envelopes
        program.envelopes[0] = Envelope(
            index: 1,
            attack: 0,
            decay: 32,
            sustain: 127,
            release: 32
        )
        
        program.envelopes[1] = Envelope(
            index: 2,
            attack: 0,
            decay: 64,
            sustain: 64,
            release: 64
        )
        
        // Configure matrix for filter modulation
        program.matrix[0] = MatrixSlot(
            index: 1,
            source: .envelope1,
            destination: .filter1Cutoff,
            amount: 64
        )
        
        return program
    }
    
    /// Generates a lead program.
    public static func leadProgram() -> Program {
        var program = initProgram()
        program.name = "Bright Lead"
        program.number = 2
        
        // Configure oscillators for lead
        program.oscillators[0].waveform = .sawtooth
        program.oscillators[0].level = 127
        
        program.oscillators[1].waveform = .pulse
        program.oscillators[1].pulseWidth = 32
        program.oscillators[1].detune = 10
        program.oscillators[1].level = 100
        
        program.oscillators[2].waveform = .square
        program.oscillators[2].coarsePitch = 12
        program.oscillators[2].level = 80
        
        // Configure filter for bright sound
        program.filters[0].type = .lowPass12dB
        program.filters[0].cutoff = 100
        program.filters[0].resonance = 32
        program.filters[0].envelopeAmount = 64
        
        // Configure envelopes for fast attack
        program.envelopes[0] = Envelope(
            index: 1,
            attack: 0,
            decay: 16,
            sustain: 64,
            release: 16
        )
        
        // Configure LFO for vibrato
        program.lfos[0] = LFO(
            index: 1,
            waveform: .sine,
            rate: 32,
            sync: .free
        )
        
        program.matrix[0] = MatrixSlot(
            index: 1,
            source: .lfo1,
            destination: .pitch1,
            amount: 10
        )
        
        return program
    }
    
    /// Generates a pad program.
    public static func padProgram() -> Program {
        var program = initProgram()
        program.name = "Warm Pad"
        program.number = 3
        
        // Configure oscillators for pad
        program.oscillators[0].waveform = .sawtooth
        program.oscillators[0].coarsePitch = 0
        program.oscillators[0].level = 100
        program.oscillators[0].pan = -32
        
        program.oscillators[1].waveform = .sawtooth
        program.oscillators[1].coarsePitch = 7
        program.oscillators[1].detune = 5
        program.oscillators[1].level = 100
        program.oscillators[1].pan = 32
        
        program.oscillators[2].waveform = .triangle
        program.oscillators[2].coarsePitch = -7
        program.oscillators[2].level = 80
        
        // Configure filter for warm sound
        program.filters[0].type = .lowPass24dB
        program.filters[0].cutoff = 50
        program.filters[0].resonance = 20
        
        program.filters[1].type = .highPass12dB
        program.filters[1].cutoff = 20
        
        // Configure envelopes for slow attack
        program.envelopes[0] = Envelope(
            index: 1,
            attack: 64,
            decay: 64,
            sustain: 100,
            release: 64
        )
        
        program.envelopes[1] = Envelope(
            index: 2,
            attack: 32,
            decay: 64,
            sustain: 80,
            release: 64
        )
        
        // Configure effects
        program.effects = Effects(
            effect1: EffectSlot(
                index: 1,
                type: .reverb,
                param1: 64,
                param2: 64,
                level: 80
            ),
            effect2: EffectSlot(
                index: 2,
                type: .chorus,
                param1: 32,
                param2: 32,
                level: 40
            ),
            masterLevel: 100
        )
        
        // Configure global settings
        program.global.polyphony = 8
        program.global.masterVolume = 100
        
        return program
    }
    
    /// Generates a drum-like program.
    public static func drumProgram() -> Program {
        var program = initProgram()
        program.name = "Kick Drum"
        program.number = 4
        
        // Configure oscillator for kick drum
        program.oscillators[0].waveform = .sine
        program.oscillators[0].level = 127
        
        program.oscillators[1].waveform = .sine
        program.oscillators[1].coarsePitch = -12
        program.oscillators[1].level = 100
        
        program.oscillators[2].waveform = .noise
        program.oscillators[2].level = 64
        
        // Configure mixer
        program.mixer = Mixer(
            osc1Level: 127,
            osc2Level: 100,
            osc3Level: 64,
            noiseLevel: 0,
            externalLevel: 0,
            ringModLevel: 0
        )
        
        // Configure filter for click
        program.filters[0].type = .lowPass24dB
        program.filters[0].cutoff = 127
        program.filters[0].resonance = 0
        program.filters[0].envelopeAmount = -64
        
        // Configure envelopes for fast decay
        program.envelopes[0] = Envelope(
            index: 1,
            attack: 0,
            decay: 8,
            sustain: 0,
            release: 16
        )
        
        program.envelopes[1] = Envelope(
            index: 2,
            attack: 0,
            decay: 4,
            sustain: 0,
            release: 8
        )
        
        // Configure matrix for pitch modulation
        program.matrix[0] = MatrixSlot(
            index: 1,
            source: .envelope1,
            destination: .pitch1,
            amount: -24
        )
        
        program.matrix[1] = MatrixSlot(
            index: 2,
            source: .envelope2,
            destination: .filter1Cutoff,
            amount: 64
        )
        
        // Configure global settings
        program.global.polyphony = 1
        
        return program
    }
    
    /// Generates an array of mock programs.
    public static func mockPrograms() -> [Program] {
        return [
            initProgram(),
            bassProgram(),
            leadProgram(),
            padProgram(),
            drumProgram()
        ]
    }
}
