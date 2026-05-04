// EffectsEditorViewModel.swift
// MonstaGuru
// Created by Mistral Vibe Code (Program Editor Agent)

import Foundation
import SwiftUI
import Combine
import Data

/// ViewModel for editing effects parameters.
public final class EffectsEditorViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// The program being edited.
    @Published public var program: Program {
        didSet {
            updateEffectsBindings()
        }
    }
    
    // MARK: - Effect 1
    @Published public var effect1Type: EffectType = .off
    @Published public var effect1Param1: Int = 0
    @Published public var effect1Param2: Int = 0
    @Published public var effect1Param3: Int = 0
    @Published public var effect1Level: Int = 0
    
    // MARK: - Effect 2
    @Published public var effect2Type: EffectType = .off
    @Published public var effect2Param1: Int = 0
    @Published public var effect2Param2: Int = 0
    @Published public var effect2Param3: Int = 0
    @Published public var effect2Level: Int = 0
    
    // MARK: - Effect 3
    @Published public var effect3Type: EffectType = .off
    @Published public var effect3Param1: Int = 0
    @Published public var effect3Param2: Int = 0
    @Published public var effect3Param3: Int = 0
    @Published public var effect3Level: Int = 0
    
    // MARK: - Master
    @Published public var masterLevel: Int = 100
    
    // MARK: - Initialization
    
    public init(program: Program) {
        self.program = program
        updateEffectsBindings()
    }
    
    // MARK: - Binding Updates
    
    private func updateEffectsBindings() {
        // Effect 1
        effect1Type = program.effects.effect1.type
        effect1Param1 = program.effects.effect1.param1
        effect1Param2 = program.effects.effect1.param2
        effect1Param3 = program.effects.effect1.param3
        effect1Level = program.effects.effect1.level
        
        // Effect 2
        effect2Type = program.effects.effect2.type
        effect2Param1 = program.effects.effect2.param1
        effect2Param2 = program.effects.effect2.param2
        effect2Param3 = program.effects.effect2.param3
        effect2Level = program.effects.effect2.level
        
        // Effect 3
        effect3Type = program.effects.effect3.type
        effect3Param1 = program.effects.effect3.param1
        effect3Param2 = program.effects.effect3.param2
        effect3Param3 = program.effects.effect3.param3
        effect3Level = program.effects.effect3.level
        
        // Master
        masterLevel = program.effects.masterLevel
    }
    
    // MARK: - Effect Access
    
    /// Returns the effect slot at the specified index.
    public func effectSlot(at index: Int) -> EffectSlot {
        switch index {
        case 1: return program.effects.effect1
        case 2: return program.effects.effect2
        case 3: return program.effects.effect3
        default: return .default(index: index)
        }
    }
    
    /// Updates an effect slot at the specified index.
    public func updateEffectSlot(_ slot: EffectSlot, at index: Int) {
        switch index {
        case 1: program.effects.effect1 = slot
        case 2: program.effects.effect2 = slot
        case 3: program.effects.effect3 = slot
        default: return
        }
        updateEffectsBindings()
    }
    
    // MARK: - Common Parameters
    
    /// Returns the available effect types.
    public var effectTypes: [EffectType] {
        return Array(EffectType.allCases)
    }
    
    /// Returns the parameter range.
    public var parameterRange: ClosedRange<Int> {
        return 0...127
    }
    
    /// Returns the level range.
    public var levelRange: ClosedRange<Int> {
        return 0...127
    }
    
    /// Returns the master level range.
    public var masterLevelRange: ClosedRange<Int> {
        return 0...127
    }
    
    // MARK: - Formatted Values
    
    /// Formats a level value for display.
    public func formattedLevel(_ value: Int) -> String {
        return "$0%"
    }
    
    /// Returns parameter labels based on effect type.
    public func parameterLabels(for effectType: EffectType) -> [String] {
        switch effectType {
        case .delay:
            return ["Time", "Feedback", "Dry/Wet"]
        case .reverb:
            return ["Decay", "Pre-Delay", "Dry/Wet"]
        case .chorus:
            return ["Rate", "Depth", "Dry/Wet"]
        case .flanger:
            return ["Rate", "Depth", "Feedback"]
        case .phaser:
            return ["Rate", "Depth", "Feedback"]
        case .distortion:
            return ["Drive", "Tone", "Dry/Wet"]
        case .eq:
            return ["Low", "Mid", "High"]
        default:
            return ["Param 1", "Param 2", "Param 3"]
        }
    }
}
