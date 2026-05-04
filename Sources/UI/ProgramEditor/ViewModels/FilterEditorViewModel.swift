// FilterEditorViewModel.swift
// MonstaGuru
// Created by Mistral Vibe Code (Program Editor Agent)

import Foundation
import SwiftUI
import Combine
import Data

/// ViewModel for editing filter parameters.
public final class FilterEditorViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// The program being edited.
    @Published public var program: Program {
        didSet {
            updateFilterBindings()
        }
    }
    
    // MARK: - Filter 1
    @Published public var filter1Type: FilterType = .lowPass24dB
    @Published public var filter1Cutoff: Int = 64
    @Published public var filter1Resonance: Int = 0
    @Published public var filter1KeyTrack: Int = 64
    @Published public var filter1EnvelopeAmount: Int = 0
    @Published public var filter1EnvelopePolarity: Bool = true
    @Published public var filter1LFOAmount: Int = 0
    @Published public var filter1VelocityAmount: Int = 0
    @Published public var filter1PressureAmount: Int = 0
    
    // MARK: - Filter 2
    @Published public var filter2Type: FilterType = .off
    @Published public var filter2Cutoff: Int = 64
    @Published public var filter2Resonance: Int = 0
    @Published public var filter2KeyTrack: Int = 64
    @Published public var filter2EnvelopeAmount: Int = 0
    @Published public var filter2EnvelopePolarity: Bool = true
    @Published public var filter2LFOAmount: Int = 0
    @Published public var filter2VelocityAmount: Int = 0
    @Published public var filter2PressureAmount: Int = 0
    
    // MARK: - Initialization
    
    public init(program: Program) {
        self.program = program
        updateFilterBindings()
    }
    
    // MARK: - Binding Updates
    
    private func updateFilterBindings() {
        // Filter 1
        filter1Type = program.filters[0].type
        filter1Cutoff = program.filters[0].cutoff
        filter1Resonance = program.filters[0].resonance
        filter1KeyTrack = program.filters[0].keyTrack
        filter1EnvelopeAmount = program.filters[0].envelopeAmount
        filter1EnvelopePolarity = program.filters[0].envelopePolarity
        filter1LFOAmount = program.filters[0].lfoAmount
        filter1VelocityAmount = program.filters[0].velocityAmount
        filter1PressureAmount = program.filters[0].pressureAmount
        
        // Filter 2
        filter2Type = program.filters[1].type
        filter2Cutoff = program.filters[1].cutoff
        filter2Resonance = program.filters[1].resonance
        filter2KeyTrack = program.filters[1].keyTrack
        filter2EnvelopeAmount = program.filters[1].envelopeAmount
        filter2EnvelopePolarity = program.filters[1].envelopePolarity
        filter2LFOAmount = program.filters[1].lfoAmount
        filter2VelocityAmount = program.filters[1].velocityAmount
        filter2PressureAmount = program.filters[1].pressureAmount
    }
    
    // MARK: - Filter Access
    
    /// Returns the filter at the specified index.
    public func filter(at index: Int) -> Filter {
        guard index >= 0 && index < program.filters.count else {
            return .default(index: index)
        }
        return program.filters[index]
    }
    
    /// Updates a filter at the specified index.
    public func updateFilter(_ filter: Filter, at index: Int) {
        guard index >= 0 && index < program.filters.count else { return }
        program.filters[index] = filter
        updateFilterBindings()
    }
    
    // MARK: - Common Parameters
    
    /// Returns the available filter types.
    public var filterTypes: [FilterType] {
        return Array(FilterType.allCases)
    }
    
    /// Returns the cutoff range.
    public var cutoffRange: ClosedRange<Int> {
        return 0...127
    }
    
    /// Returns the resonance range.
    public var resonanceRange: ClosedRange<Int> {
        return 0...127
    }
    
    /// Returns the key track range.
    public var keyTrackRange: ClosedRange<Int> {
        return 0...127
    }
    
    /// Returns the modulation amount range (signed).
    public var modulationAmountRange: ClosedRange<Int> {
        return -64...63
    }
    
    // MARK: - Formatted Values
    
    /// Formats a modulation amount for display.
    public func formattedModulationAmount(_ value: Int) -> String {
        if value > 0 {
            return "+$0"
        } else if value < 0 {
            return "$0"
        } else {
            return "0"
        }
    }
}
