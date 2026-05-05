// MixerEditorViewModel.swift
// MonstaGuru
// Created by Mistral Vibe Code (Program Editor Agent)

import Foundation
import SwiftUI
import Combine
import Data

/// ViewModel for editing mixer parameters.
public final class MixerEditorViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// The program being edited.
    @Published public var program: Program {
        didSet {
            updateMixerBindings()
        }
    }
    
    // MARK: - Mixer Levels
    @Published public var osc1Level: Int = 127
    @Published public var osc2Level: Int = 127
    @Published public var osc3Level: Int = 127
    @Published public var noiseLevel: Int = 0
    @Published public var externalLevel: Int = 0
    @Published public var ringModLevel: Int = 0
    
    // MARK: - Initialization
    
    public init(program: Program) {
        self.program = program
        updateMixerBindings()
    }
    
    // MARK: - Binding Updates
    
    private func updateMixerBindings() {
        osc1Level = program.mixer.osc1Level
        osc2Level = program.mixer.osc2Level
        osc3Level = program.mixer.osc3Level
        noiseLevel = program.mixer.noiseLevel
        externalLevel = program.mixer.externalLevel
        ringModLevel = program.mixer.ringModLevel
    }
    
    // MARK: - Common Parameters
    
    /// Returns the level range.
    public var levelRange: ClosedRange<Int> {
        return 0...127
    }
    
    // MARK: - Formatted Values
    
    /// Formats a level value for display.
    public func formattedLevel(_ value: Int) -> String {
        return "$0%"
    }
    
    // MARK: - Mixer Access
    
    /// Returns the current mixer configuration.
    public var mixer: Mixer {
        return program.mixer
    }
    
    /// Updates the mixer configuration.
    public func updateMixer(_ mixer: Mixer) {
        program.mixer = mixer
        updateMixerBindings()
    }
    
    // MARK: - Individual Level Updates
    
    /// Updates the oscillator 1 level.
    public func updateOsc1Level(_ value: Int) {
        program.mixer.osc1Level = value.clamped(to: levelRange)
        osc1Level = program.mixer.osc1Level
    }
    
    /// Updates the oscillator 2 level.
    public func updateOsc2Level(_ value: Int) {
        program.mixer.osc2Level = value.clamped(to: levelRange)
        osc2Level = program.mixer.osc2Level
    }
    
    /// Updates the oscillator 3 level.
    public func updateOsc3Level(_ value: Int) {
        program.mixer.osc3Level = value.clamped(to: levelRange)
        osc3Level = program.mixer.osc3Level
    }
    
    /// Updates the noise level.
    public func updateNoiseLevel(_ value: Int) {
        program.mixer.noiseLevel = value.clamped(to: levelRange)
        noiseLevel = program.mixer.noiseLevel
    }
    
    /// Updates the external input level.
    public func updateExternalLevel(_ value: Int) {
        program.mixer.externalLevel = value.clamped(to: levelRange)
        externalLevel = program.mixer.externalLevel
    }
    
    /// Updates the ring mod level.
    public func updateRingModLevel(_ value: Int) {
        program.mixer.ringModLevel = value.clamped(to: levelRange)
        ringModLevel = program.mixer.ringModLevel
    }
}

// MARK: - Helper Extensions

private extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        return Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
