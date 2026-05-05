// Oscillator.swift
// MonstaGuru
// Created by Mistral Vibe Code (Core Data Model Agent)

import Foundation
import SwiftData

/// Waveform types for MicroMonsta 2 oscillators.
public enum OscillatorWaveform: Int, Codable, CaseIterable, Identifiable {
    case sine
    case triangle
    case sawtooth
    case pulse
    case square
    case noise
    case audioIn
    case off
    
    public var id: Self { self }
    
    /// Localized display name for the waveform.
    public var displayName: String {
        switch self {
        case .sine: return "Sine"
        case .triangle: return "Triangle"
        case .sawtooth: return "Sawtooth"
        case .pulse: return "Pulse"
        case .square: return "Square"
        case .noise: return "Noise"
        case .audioIn: return "Audio In"
        case .off: return "Off"
        }
    }
}

/// Configuration for a single MicroMonsta 2 oscillator.
public struct Oscillator: Codable, Hashable, Equatable {
    /// Oscillator index (1, 2, or 3).
    public let index: Int
    
    /// Waveform type.
    public var waveform: OscillatorWaveform
    
    /// Coarse pitch (-48 to +48 semitones).
    public var coarsePitch: Int
    
    /// Fine pitch (-50 to +50 cents).
    public var finePitch: Int
    
    /// Detune amount (0-127).
    public var detune: Int
    
    /// Oscillator sync enabled.
    public var syncEnabled: Bool
    
    /// Ring modulation enabled.
    public var ringModEnabled: Bool
    
    /// Pulse width (0-127) for pulse waveform.
    public var pulseWidth: Int
    
    /// Oscillator level (0-127).
    public var level: Int
    
    /// Pan position (-64 to +63).
    public var pan: Int
    
    public init(
        index: Int,
        waveform: OscillatorWaveform = .sawtooth,
        coarsePitch: Int = 0,
        finePitch: Int = 0,
        detune: Int = 0,
        syncEnabled: Bool = false,
        ringModEnabled: Bool = false,
        pulseWidth: Int = 64,
        level: Int = 100,
        pan: Int = 0
    ) {
        self.index = index
        self.waveform = waveform
        self.coarsePitch = coarsePitch.clamped(to: -48...48)
        self.finePitch = finePitch.clamped(to: -50...50)
        self.detune = detune.clamped(to: 0...127)
        self.syncEnabled = syncEnabled
        self.ringModEnabled = ringModEnabled
        self.pulseWidth = pulseWidth.clamped(to: 0...127)
        self.level = level.clamped(to: 0...127)
        self.pan = pan.clamped(to: -64...63)
    }
    
    /// Clamps a value to the specified range.
    private func clamped(to range: ClosedRange<Int>) -> Int {
        return Swift.min(Swift.max(self.coarsePitch, range.lowerBound), range.upperBound)
    }
}

// MARK: - Default Values

public extension Oscillator {
    /// Default oscillator configuration for MicroMonsta 2.
    static func `default`(index: Int) -> Oscillator {
        return Oscillator(
            index: index,
            waveform: .sawtooth,
            coarsePitch: 0,
            finePitch: 0,
            detune: 0,
            syncEnabled: false,
            ringModEnabled: false,
            pulseWidth: 64,
            level: 100,
            pan: 0
        )
    }
}
