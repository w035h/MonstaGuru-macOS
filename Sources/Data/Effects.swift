// Effects.swift
// MonstaGuru
// Created by Mistral Vibe Code (Core Data Model Agent)

import Foundation
import SwiftData

/// Effect types for MicroMonsta 2.
public enum EffectType: Int, Codable, CaseIterable, Identifiable {
    case off
    case delay
    case reverb
    case chorus
    case flanger
    case phaser
    case distortion
    case eq
    
    public var id: Self { self }
    
    /// Localized display name for the effect type.
    public var displayName: String {
        switch self {
        case .off: return "Off"
        case .delay: return "Delay"
        case .reverb: return "Reverb"
        case .chorus: return "Chorus"
        case .flanger: return "Flanger"
        case .phaser: return "Phaser"
        case .distortion: return "Distortion"
        case .eq: return "EQ"
        }
    }
}

/// Configuration for MicroMonsta 2 effects.
public struct Effects: Codable, Hashable, Equatable {
    /// Effect 1 type and parameters.
    public var effect1: EffectSlot
    
    /// Effect 2 type and parameters.
    public var effect2: EffectSlot
    
    /// Effect 3 type and parameters.
    public var effect3: EffectSlot
    
    /// Master effect level (0-127).
    public var masterLevel: Int
    
    public init(
        effect1: EffectSlot = .default(index: 1),
        effect2: EffectSlot = .default(index: 2),
        effect3: EffectSlot = .default(index: 3),
        masterLevel: Int = 100
    ) {
        self.effect1 = effect1
        self.effect2 = effect2
        self.effect3 = effect3
        self.masterLevel = masterLevel.clamped(to: 0...127)
    }
}

/// Configuration for a single effect slot.
public struct EffectSlot: Codable, Hashable, Equatable {
    /// Slot index (1, 2, or 3).
    public let index: Int
    
    /// Effect type.
    public var type: EffectType
    
    /// Parameter 1 (varies by effect type, 0-127).
    public var param1: Int
    
    /// Parameter 2 (varies by effect type, 0-127).
    public var param2: Int
    
    /// Parameter 3 (varies by effect type, 0-127).
    public var param3: Int
    
    /// Effect level (0-127).
    public var level: Int
    
    public init(
        index: Int,
        type: EffectType = .off,
        param1: Int = 0,
        param2: Int = 0,
        param3: Int = 0,
        level: Int = 0
    ) {
        self.index = index
        self.type = type
        self.param1 = param1.clamped(to: 0...127)
        self.param2 = param2.clamped(to: 0...127)
        self.param3 = param3.clamped(to: 0...127)
        self.level = level.clamped(to: 0...127)
    }
}

// MARK: - Default Values

public extension EffectSlot {
    /// Default effect slot configuration.
    static func `default`(index: Int) -> EffectSlot {
        return EffectSlot(
            index: index,
            type: .off,
            param1: 0,
            param2: 0,
            param3: 0,
            level: 0
        )
    }
}

public extension Effects {
    /// Default effects configuration for MicroMonsta 2.
    static var `default`: Effects {
        return Effects()
    }
}

// MARK: - Helper Extensions

private extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
