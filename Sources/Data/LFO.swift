// LFO.swift
// MonstaGuru
// Created by Mistral Vibe Code (Core Data Model Agent)

import Foundation
import SwiftData

/// LFO waveform types for MicroMonsta 2.
public enum LFOWaveform: Int, Codable, CaseIterable, Identifiable {
    case sine
    case triangle
    case sawtooth
    case square
    case sampleAndHold
    case random
    
    public var id: Self { self }
    
    /// Localized display name for the LFO waveform.
    public var displayName: String {
        switch self {
        case .sine: return "Sine"
        case .triangle: return "Triangle"
        case .sawtooth: return "Sawtooth"
        case .square: return "Square"
        case .sampleAndHold: return "Sample & Hold"
        case .random: return "Random"
        }
    }
}

/// LFO sync modes.
public enum LFOSync: Int, Codable, CaseIterable, Identifiable {
    case free
    case synced
    
    public var id: Self { self }
    
    public var displayName: String {
        switch self {
        case .free: return "Free"
        case .synced: return "Synced"
        }
    }
}

/// Configuration for a MicroMonsta 2 LFO.
public struct LFO: Codable, Hashable, Equatable {
    /// LFO index (1, 2, or 3).
    public let index: Int
    
    /// Waveform type.
    public var waveform: LFOWaveform
    
    /// Rate (0-127).
    public var rate: Int
    
    /// Sync mode.
    public var sync: LFOSync
    
    /// Key sync enabled.
    public var keySync: Bool
    
    /// Delay time (0-127).
    public var delay: Int
    
    /// Fade time (0-127).
    public var fade: Int
    
    /// Phase offset (0-127).
    public var phase: Int
    
    public init(
        index: Int,
        waveform: LFOWaveform = .sine,
        rate: Int = 64,
        sync: LFOSync = .free,
        keySync: Bool = false,
        delay: Int = 0,
        fade: Int = 0,
        phase: Int = 0
    ) {
        self.index = index
        self.waveform = waveform
        self.rate = rate.clamped(to: 0...127)
        self.sync = sync
        self.keySync = keySync
        self.delay = delay.clamped(to: 0...127)
        self.fade = fade.clamped(to: 0...127)
        self.phase = phase.clamped(to: 0...127)
    }
}

// MARK: - Default Values

public extension LFO {
    /// Default LFO configuration for MicroMonsta 2.
    static func `default`(index: Int) -> LFO {
        return LFO(
            index: index,
            waveform: .sine,
            rate: 64,
            sync: .free,
            keySync: false,
            delay: 0,
            fade: 0,
            phase: 0
        )
    }
}

// MARK: - Helper Extensions

private extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        return Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
