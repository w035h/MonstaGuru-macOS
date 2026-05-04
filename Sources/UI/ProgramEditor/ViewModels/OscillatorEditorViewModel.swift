// OscillatorEditorViewModel.swift
// MonstaGuru
// Created by Mistral Vibe Code (Program Editor Agent)

import Foundation
import SwiftUI
import Combine
import Data

/// ViewModel for editing oscillator parameters.
public final class OscillatorEditorViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// The program being edited.
    @Published public var program: Program {
        didSet {
            // Update all oscillator bindings when program changes
            updateOscillatorBindings()
        }
    }
    
    // MARK: - Oscillator 1
    @Published public var osc1Waveform: OscillatorWaveform = .sawtooth
    @Published public var osc1CoarsePitch: Int = 0
    @Published public var osc1FinePitch: Int = 0
    @Published public var osc1Detune: Int = 0
    @Published public var osc1SyncEnabled: Bool = false
    @Published public var osc1RingModEnabled: Bool = false
    @Published public var osc1PulseWidth: Int = 64
    @Published public var osc1Level: Int = 100
    @Published public var osc1Pan: Int = 0
    
    // MARK: - Oscillator 2
    @Published public var osc2Waveform: OscillatorWaveform = .sawtooth
    @Published public var osc2CoarsePitch: Int = 0
    @Published public var osc2FinePitch: Int = 0
    @Published public var osc2Detune: Int = 0
    @Published public var osc2SyncEnabled: Bool = false
    @Published public var osc2RingModEnabled: Bool = false
    @Published public var osc2PulseWidth: Int = 64
    @Published public var osc2Level: Int = 100
    @Published public var osc2Pan: Int = 0
    
    // MARK: - Oscillator 3
    @Published public var osc3Waveform: OscillatorWaveform = .sawtooth
    @Published public var osc3CoarsePitch: Int = 0
    @Published public var osc3FinePitch: Int = 0
    @Published public var osc3Detune: Int = 0
    @Published public var osc3SyncEnabled: Bool = false
    @Published public var osc3RingModEnabled: Bool = false
    @Published public var osc3PulseWidth: Int = 64
    @Published public var osc3Level: Int = 0
    @Published public var osc3Pan: Int = 0
    
    // MARK: - Initialization
    
    public init(program: Program) {
        self.program = program
        updateOscillatorBindings()
    }
    
    // MARK: - Binding Updates
    
    private func updateOscillatorBindings() {
        // Oscillator 1
        osc1Waveform = program.oscillators[0].waveform
        osc1CoarsePitch = program.oscillators[0].coarsePitch
        osc1FinePitch = program.oscillators[0].finePitch
        osc1Detune = program.oscillators[0].detune
        osc1SyncEnabled = program.oscillators[0].syncEnabled
        osc1RingModEnabled = program.oscillators[0].ringModEnabled
        osc1PulseWidth = program.oscillators[0].pulseWidth
        osc1Level = program.oscillators[0].level
        osc1Pan = program.oscillators[0].pan
        
        // Oscillator 2
        osc2Waveform = program.oscillators[1].waveform
        osc2CoarsePitch = program.oscillators[1].coarsePitch
        osc2FinePitch = program.oscillators[1].finePitch
        osc2Detune = program.oscillators[1].detune
        osc2SyncEnabled = program.oscillators[1].syncEnabled
        osc2RingModEnabled = program.oscillators[1].ringModEnabled
        osc2PulseWidth = program.oscillators[1].pulseWidth
        osc2Level = program.oscillators[1].level
        osc2Pan = program.oscillators[1].pan
        
        // Oscillator 3
        osc3Waveform = program.oscillators[2].waveform
        osc3CoarsePitch = program.oscillators[2].coarsePitch
        osc3FinePitch = program.oscillators[2].finePitch
        osc3Detune = program.oscillators[2].detune
        osc3SyncEnabled = program.oscillators[2].syncEnabled
        osc3RingModEnabled = program.oscillators[2].ringModEnabled
        osc3PulseWidth = program.oscillators[2].pulseWidth
        osc3Level = program.oscillators[2].level
        osc3Pan = program.oscillators[2].pan
    }
    
    // MARK: - Oscillator Access
    
    /// Returns the oscillator at the specified index.
    public func oscillator(at index: Int) -> Oscillator {
        guard index >= 0 && index < program.oscillators.count else {
            return .default(index: index)
        }
        return program.oscillators[index]
    }
    
    /// Updates an oscillator at the specified index.
    public func updateOscillator(_ oscillator: Oscillator, at index: Int) {
        guard index >= 0 && index < program.oscillators.count else { return }
        program.oscillators[index] = oscillator
        updateOscillatorBindings()
    }
    
    // MARK: - Common Parameters
    
    /// Returns the available waveform types.
    public var waveformTypes: [OscillatorWaveform] {
        return Array(OscillatorWaveform.allCases)
    }
    
    /// Returns the coarse pitch range.
    public var coarsePitchRange: ClosedRange<Int> {
        return -48...48
    }
    
    /// Returns the fine pitch range.
    public var finePitchRange: ClosedRange<Int> {
        return -50...50
    }
    
    /// Returns the detune range.
    public var detuneRange: ClosedRange<Int> {
        return 0...127
    }
    
    /// Returns the pulse width range.
    public var pulseWidthRange: ClosedRange<Int> {
        return 0...127
    }
    
    /// Returns the level range.
    public var levelRange: ClosedRange<Int> {
        return 0...127
    }
    
    /// Returns the pan range.
    public var panRange: ClosedRange<Int> {
        return -64...63
    }
    
    // MARK: - Formatted Values
    
    /// Formats a pan value for display.
    public func formattedPan(_ value: Int) -> String {
        if value == 0 {
            return "C"
        } else if value > 0 {
            return "R+$0"
        } else {
            return "L$0"
        }
    }
    
    /// Formats a pitch value for display.
    public func formattedPitch(_ value: Int) -> String {
        if value > 0 {
            return "+$0"
        } else if value < 0 {
            return "$0"
        } else {
            return "0"
        }
    }
}
