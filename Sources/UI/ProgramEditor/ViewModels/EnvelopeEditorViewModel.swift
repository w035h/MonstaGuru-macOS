// EnvelopeEditorViewModel.swift
// MonstaGuru
// Created by Mistral Vibe Code (Program Editor Agent)

import Foundation
import SwiftUI
import Combine
import Data

/// ViewModel for editing envelope parameters.
public final class EnvelopeEditorViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// The program being edited.
    @Published public var program: Program {
        didSet {
            updateEnvelopeBindings()
        }
    }
    
    // MARK: - Envelope 1
    @Published public var env1Attack: Int = 0
    @Published public var env1Decay: Int = 64
    @Published public var env1Sustain: Int = 127
    @Published public var env1Release: Int = 64
    @Published public var env1VelocitySensitivity: Int = 0
    @Published public var env1KeyTrack: Int = 0
    
    // MARK: - Envelope 2
    @Published public var env2Attack: Int = 0
    @Published public var env2Decay: Int = 64
    @Published public var env2Sustain: Int = 127
    @Published public var env2Release: Int = 64
    @Published public var env2VelocitySensitivity: Int = 0
    @Published public var env2KeyTrack: Int = 0
    
    // MARK: - Envelope 3
    @Published public var env3Attack: Int = 0
    @Published public var env3Decay: Int = 64
    @Published public var env3Sustain: Int = 127
    @Published public var env3Release: Int = 64
    @Published public var env3VelocitySensitivity: Int = 0
    @Published public var env3KeyTrack: Int = 0
    
    // MARK: - Initialization
    
    public init(program: Program) {
        self.program = program
        updateEnvelopeBindings()
    }
    
    // MARK: - Binding Updates
    
    private func updateEnvelopeBindings() {
        // Envelope 1
        env1Attack = program.envelopes[0].attack
        env1Decay = program.envelopes[0].decay
        env1Sustain = program.envelopes[0].sustain
        env1Release = program.envelopes[0].release
        env1VelocitySensitivity = program.envelopes[0].velocitySensitivity
        env1KeyTrack = program.envelopes[0].keyTrack
        
        // Envelope 2
        env2Attack = program.envelopes[1].attack
        env2Decay = program.envelopes[1].decay
        env2Sustain = program.envelopes[1].sustain
        env2Release = program.envelopes[1].release
        env2VelocitySensitivity = program.envelopes[1].velocitySensitivity
        env2KeyTrack = program.envelopes[1].keyTrack
        
        // Envelope 3
        env3Attack = program.envelopes[2].attack
        env3Decay = program.envelopes[2].decay
        env3Sustain = program.envelopes[2].sustain
        env3Release = program.envelopes[2].release
        env3VelocitySensitivity = program.envelopes[2].velocitySensitivity
        env3KeyTrack = program.envelopes[2].keyTrack
    }
    
    // MARK: - Envelope Access
    
    /// Returns the envelope at the specified index.
    public func envelope(at index: Int) -> Envelope {
        guard index >= 0 && index < program.envelopes.count else {
            return .default(index: index)
        }
        return program.envelopes[index]
    }
    
    /// Updates an envelope at the specified index.
    public func updateEnvelope(_ envelope: Envelope, at index: Int) {
        guard index >= 0 && index < program.envelopes.count else { return }
        program.envelopes[index] = envelope
        updateEnvelopeBindings()
    }
    
    // MARK: - Common Parameters
    
    /// Returns the ADSR parameter range.
    public var adsrRange: ClosedRange<Int> {
        return 0...127
    }
    
    // MARK: - Formatted Values
    
    /// Formats an ADSR value for display.
    public func formattedADSRValue(_ value: Int) -> String {
        return "$0"
    }
}
