// Envelope.swift
// MonstaGuru
// Created by Mistral Vibe Code (Core Data Model Agent)

import Foundation
import SwiftData

/// Configuration for a MicroMonsta 2 envelope (ADSR).
public struct Envelope: Codable, Hashable, Equatable {
    /// Envelope index (1, 2, or 3).
    public let index: Int
    
    /// Attack time (0-127).
    public var attack: Int
    
    /// Decay time (0-127).
    public var decay: Int
    
    /// Sustain level (0-127).
    public var sustain: Int
    
    /// Release time (0-127).
    public var release: Int
    
    /// Velocity sensitivity (0-127).
    public var velocitySensitivity: Int
    
    /// Key tracking (0-127).
    public var keyTrack: Int
    
    public init(
        index: Int,
        attack: Int = 0,
        decay: Int = 64,
        sustain: Int = 127,
        release: Int = 0,
        velocitySensitivity: Int = 0,
        keyTrack: Int = 0
    ) {
        self.index = index
        self.attack = attack.clamped(to: 0...127)
        self.decay = decay.clamped(to: 0...127)
        self.sustain = sustain.clamped(to: 0...127)
        self.release = release.clamped(to: 0...127)
        self.velocitySensitivity = velocitySensitivity.clamped(to: 0...127)
        self.keyTrack = keyTrack.clamped(to: 0...127)
    }
}

// MARK: - Default Values

public extension Envelope {
    /// Default envelope configuration for MicroMonsta 2.
    static func `default`(index: Int) -> Envelope {
        return Envelope(
            index: index,
            attack: 0,
            decay: 64,
            sustain: 127,
            release: 0,
            velocitySensitivity: 0,
            keyTrack: 0
        )
    }
}

// MARK: - Helper Extensions

private extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        return Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
