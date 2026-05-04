// GlobalEditorViewModel.swift
// MonstaGuru
// Created by Mistral Vibe Code (Program Editor Agent)

import Foundation
import SwiftUI
import Combine
import Data

/// ViewModel for editing global program settings.
public final class GlobalEditorViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// The program being edited.
    @Published public var program: Program {
        didSet {
            updateGlobalBindings()
        }
    }
    
    // MARK: - Global Settings
    @Published public var polyphony: Int = 8
    @Published public var portamentoEnabled: Bool = false
    @Published public var portamentoTime: Int = 0
    @Published public var pitchBendRange: Int = 2
    @Published public var masterVolume: Int = 100
    @Published public var masterTune: Int = 0
    @Published public var velocityCurve: Int = 1
    
    // MARK: - Initialization
    
    public init(program: Program) {
        self.program = program
        updateGlobalBindings()
    }
    
    // MARK: - Binding Updates
    
    private func updateGlobalBindings() {
        polyphony = program.global.polyphony
        portamentoEnabled = program.global.portamentoEnabled
        portamentoTime = program.global.portamentoTime
        pitchBendRange = program.global.pitchBendRange
        masterVolume = program.global.masterVolume
        masterTune = program.global.masterTune
        velocityCurve = program.global.velocityCurve
    }
    
    // MARK: - Common Parameters
    
    /// Returns the polyphony range.
    public var polyphonyRange: ClosedRange<Int> {
        return 1...8
    }
    
    /// Returns the portamento time range.
    public var portamentoTimeRange: ClosedRange<Int> {
        return 0...127
    }
    
    /// Returns the pitch bend range.
    public var pitchBendRangeRange: ClosedRange<Int> {
        return -12...12
    }
    
    /// Returns the master volume range.
    public var masterVolumeRange: ClosedRange<Int> {
        return 0...127
    }
    
    /// Returns the master tune range.
    public var masterTuneRange: ClosedRange<Int> {
        return -50...50
    }
    
    /// Returns the velocity curve range.
    public var velocityCurveRange: ClosedRange<Int> {
        return 0...3
    }
    
    // MARK: - Velocity Curve Types
    
    /// Returns the available velocity curve types.
    public var velocityCurveTypes: [String] {
        return ["Linear", "Soft", "Medium", "Hard"]
    }
    
    /// Returns the display name for a velocity curve value.
    public func velocityCurveDisplayName(for value: Int) -> String {
        switch value {
        case 0: return "Linear"
        case 1: return "Soft"
        case 2: return "Medium"
        case 3: return "Hard"
        default: return "Unknown"
        }
    }
    
    // MARK: - Formatted Values
    
    /// Formats the polyphony value for display.
    public func formattedPolyphony(_ value: Int) -> String {
        return "$0 voice(s)"
    }
    
    /// Formats the portamento time value for display.
    public func formattedPortamentoTime(_ value: Int) -> String {
        return "$0 ms"
    }
    
    /// Formats the pitch bend range value for display.
    public func formattedPitchBendRange(_ value: Int) -> String {
        if value > 0 {
            return "+$0 semitones"
        } else if value < 0 {
            return "$0 semitones"
        } else {
            return "0 semitones"
        }
    }
    
    /// Formats the master volume value for display.
    public func formattedMasterVolume(_ value: Int) -> String {
        return "$0%"
    }
    
    /// Formats the master tune value for display.
    public func formattedMasterTune(_ value: Int) -> String {
        if value > 0 {
            return "+$0 cents"
        } else if value < 0 {
            return "$0 cents"
        } else {
            return "0 cents"
        }
    }
    
    // MARK: - Global Settings Access
    
    /// Returns the current global settings.
    public var globalSettings: GlobalSettings {
        return program.global
    }
    
    /// Updates the global settings.
    public func updateGlobalSettings(_ settings: GlobalSettings) {
        program.global = settings
        updateGlobalBindings()
    }
}
