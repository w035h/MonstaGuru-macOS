// Filter.swift
// MonstaGuru
// Created by Mistral Vibe Code (Core Data Model Agent)

import Foundation
import SwiftData

/// Filter types for MicroMonsta 2.
public enum FilterType: Int, Codable, CaseIterable, Identifiable {
    case lowPass12dB
    case lowPass24dB
    case highPass12dB
    case highPass24dB
    case bandPass12dB
    case bandPass24dB
    case notch
    case off
    
    public var id: Self { self }
    
    /// Localized display name for the filter type.
    public var displayName: String {
        switch self {
        case .lowPass12dB: return "Low Pass (12dB)"
        case .lowPass24dB: return "Low Pass (24dB)"
        case .highPass12dB: return "High Pass (12dB)"
        case .highPass24dB: return "High Pass (24dB)"
        case .bandPass12dB: return "Band Pass (12dB)"
        case .bandPass24dB: return "Band Pass (24dB)"
        case .notch: return "Notch"
        case .off: return "Off"
        }
    }
}

/// Filter slope types.
public enum FilterSlope: Int, Codable, CaseIterable, Identifiable {
    case slope12dB
    case slope24dB
    
    public var id: Self { self }
    
    public var displayName: String {
        switch self {
        case .slope12dB: return "12dB"
        case .slope24dB: return "24dB"
        }
    }
}

/// Configuration for a single MicroMonsta 2 filter.
public struct Filter: Codable, Hashable, Equatable {
    /// Filter index (1 or 2).
    public let index: Int
    
    /// Filter type.
    public var type: FilterType
    
    /// Cutoff frequency (0-127).
    public var cutoff: Int
    
    /// Resonance (0-127).
    public var resonance: Int
    
    /// Key tracking amount (0-127).
    public var keyTrack: Int
    
    /// Filter envelope amount (-64 to +63).
    public var envelopeAmount: Int
    
    /// Filter envelope polarity (normal or inverted).
    public var envelopePolarity: Bool
    
    /// LFO modulation amount (-64 to +63).
    public var lfoAmount: Int
    
    /// Velocity modulation amount (-64 to +63).
    public var velocityAmount: Int
    
    /// Pressure modulation amount (-64 to +63).
    public var pressureAmount: Int
    
    public init(
        index: Int,
        type: FilterType = .lowPass24dB,
        cutoff: Int = 64,
        resonance: Int = 0,
        keyTrack: Int = 64,
        envelopeAmount: Int = 0,
        envelopePolarity: Bool = true,
        lfoAmount: Int = 0,
        velocityAmount: Int = 0,
        pressureAmount: Int = 0
    ) {
        self.index = index
        self.type = type
        self.cutoff = cutoff.clamped(to: 0...127)
        self.resonance = resonance.clamped(to: 0...127)
        self.keyTrack = keyTrack.clamped(to: 0...127)
        self.envelopeAmount = envelopeAmount.clamped(to: -64...63)
        self.envelopePolarity = envelopePolarity
        self.lfoAmount = lfoAmount.clamped(to: -64...63)
        self.velocityAmount = velocityAmount.clamped(to: -64...63)
        self.pressureAmount = pressureAmount.clamped(to: -64...63)
    }
}

// MARK: - Default Values

public extension Filter {
    /// Default filter configuration for MicroMonsta 2.
    static func `default`(index: Int) -> Filter {
        return Filter(
            index: index,
            type: .lowPass24dB,
            cutoff: 64,
            resonance: 0,
            keyTrack: 64,
            envelopeAmount: 0,
            envelopePolarity: true,
            lfoAmount: 0,
            velocityAmount: 0,
            pressureAmount: 0
        )
    }
}

// MARK: - Helper Extensions

private extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        return Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
