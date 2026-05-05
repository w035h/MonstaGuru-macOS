// MatrixSlot.swift
// MonstaGuru
// Created by Mistral Vibe Code (Core Data Model Agent)

import Foundation
import SwiftData

/// Modulation source types for MicroMonsta 2 matrix.
public enum MatrixSource: Int, Codable, CaseIterable, Identifiable {
    case off
    case lfo1
    case lfo2
    case lfo3
    case envelope1
    case envelope2
    case envelope3
    case velocity
    case pressure
    case modWheel
    case pitchBend
    case noteNumber
    case random
    case aftertouch
    
    public var id: Self { self }
    
    /// Localized display name for the source.
    public var displayName: String {
        switch self {
        case .off: return "Off"
        case .lfo1: return "LFO 1"
        case .lfo2: return "LFO 2"
        case .lfo3: return "LFO 3"
        case .envelope1: return "Env 1"
        case .envelope2: return "Env 2"
        case .envelope3: return "Env 3"
        case .velocity: return "Velocity"
        case .pressure: return "Pressure"
        case .modWheel: return "Mod Wheel"
        case .pitchBend: return "Pitch Bend"
        case .noteNumber: return "Note Number"
        case .random: return "Random"
        case .aftertouch: return "Aftertouch"
        }
    }
}

/// Modulation destination types for MicroMonsta 2 matrix.
public enum MatrixDestination: Int, Codable, CaseIterable, Identifiable {
    case off
    case pitch1
    case pitch2
    case pitch3
    case pulseWidth1
    case pulseWidth2
    case pulseWidth3
    case filter1Cutoff
    case filter1Resonance
    case filter2Cutoff
    case filter2Resonance
    case ampLevel
    case pan1
    case pan2
    case pan3
    case lfo1Rate
    case lfo2Rate
    case lfo3Rate
    case envelope1Attack
    case envelope1Decay
    case envelope1Sustain
    case envelope1Release
    case envelope2Attack
    case envelope2Decay
    case envelope2Sustain
    case envelope2Release
    case envelope3Attack
    case envelope3Decay
    case envelope3Sustain
    case envelope3Release
    
    public var id: Self { self }
    
    /// Localized display name for the destination.
    public var displayName: String {
        switch self {
        case .off: return "Off"
        case .pitch1: return "Osc 1 Pitch"
        case .pitch2: return "Osc 2 Pitch"
        case .pitch3: return "Osc 3 Pitch"
        case .pulseWidth1: return "Osc 1 PW"
        case .pulseWidth2: return "Osc 2 PW"
        case .pulseWidth3: return "Osc 3 PW"
        case .filter1Cutoff: return "Filter 1 Cutoff"
        case .filter1Resonance: return "Filter 1 Resonance"
        case .filter2Cutoff: return "Filter 2 Cutoff"
        case .filter2Resonance: return "Filter 2 Resonance"
        case .ampLevel: return "Amp Level"
        case .pan1: return "Osc 1 Pan"
        case .pan2: return "Osc 2 Pan"
        case .pan3: return "Osc 3 Pan"
        case .lfo1Rate: return "LFO 1 Rate"
        case .lfo2Rate: return "LFO 2 Rate"
        case .lfo3Rate: return "LFO 3 Rate"
        case .envelope1Attack: return "Env 1 Attack"
        case .envelope1Decay: return "Env 1 Decay"
        case .envelope1Sustain: return "Env 1 Sustain"
        case .envelope1Release: return "Env 1 Release"
        case .envelope2Attack: return "Env 2 Attack"
        case .envelope2Decay: return "Env 2 Decay"
        case .envelope2Sustain: return "Env 2 Sustain"
        case .envelope2Release: return "Env 2 Release"
        case .envelope3Attack: return "Env 3 Attack"
        case .envelope3Decay: return "Env 3 Decay"
        case .envelope3Sustain: return "Env 3 Sustain"
        case .envelope3Release: return "Env 3 Release"
        }
    }
}

/// A single slot in the MicroMonsta 2 modulation matrix.
public struct MatrixSlot: Codable, Hashable, Equatable {
    /// Slot index (1-12 for MicroMonsta 2).
    public let index: Int
    
    /// Modulation source.
    public var source: MatrixSource
    
    /// Modulation destination.
    public var destination: MatrixDestination
    
    /// Modulation amount (-64 to +63).
    public var amount: Int
    
    public init(
        index: Int,
        source: MatrixSource = .off,
        destination: MatrixDestination = .off,
        amount: Int = 0
    ) {
        self.index = index
        self.source = source
        self.destination = destination
        self.amount = amount.clamped(to: -64...63)
    }
}

// MARK: - Default Values

public extension MatrixSlot {
    /// Default matrix slot configuration.
    static func `default`(index: Int) -> MatrixSlot {
        return MatrixSlot(
            index: index,
            source: .off,
            destination: .off,
            amount: 0
        )
    }
}

// MARK: - Helper Extensions

private extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        return Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
