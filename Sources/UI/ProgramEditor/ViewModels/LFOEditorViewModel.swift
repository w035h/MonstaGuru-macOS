// LFOEditorViewModel.swift
// MonstaGuru
// Created by Mistral Vibe Code (Program Editor Agent)

import Foundation
import SwiftUI
import Combine
import Data

/// ViewModel for editing LFO parameters.
public final class LFOEditorViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// The program being edited.
    @Published public var program: Program {
        didSet {
            updateLFOBindings()
        }
    }
    
    // MARK: - LFO 1
    @Published public var lfo1Waveform: LFOWaveform = .sine
    @Published public var lfo1Rate: Int = 64
    @Published public var lfo1Sync: LFOSync = .free
    @Published public var lfo1KeySync: Bool = false
    @Published public var lfo1Delay: Int = 0
    @Published public var lfo1Fade: Int = 0
    @Published public var lfo1Phase: Int = 0
    
    // MARK: - LFO 2
    @Published public var lfo2Waveform: LFOWaveform = .sine
    @Published public var lfo2Rate: Int = 64
    @Published public var lfo2Sync: LFOSync = .free
    @Published public var lfo2KeySync: Bool = false
    @Published public var lfo2Delay: Int = 0
    @Published public var lfo2Fade: Int = 0
    @Published public var lfo2Phase: Int = 0
    
    // MARK: - LFO 3
    @Published public var lfo3Waveform: LFOWaveform = .sine
    @Published public var lfo3Rate: Int = 64
    @Published public var lfo3Sync: LFOSync = .free
    @Published public var lfo3KeySync: Bool = false
    @Published public var lfo3Delay: Int = 0
    @Published public var lfo3Fade: Int = 0
    @Published public var lfo3Phase: Int = 0
    
    // MARK: - Initialization
    
    public init(program: Program) {
        self.program = program
        updateLFOBindings()
    }
    
    // MARK: - Binding Updates
    
    private func updateLFOBindings() {
        // LFO 1
        lfo1Waveform = program.lfos[0].waveform
        lfo1Rate = program.lfos[0].rate
        lfo1Sync = program.lfos[0].sync
        lfo1KeySync = program.lfos[0].keySync
        lfo1Delay = program.lfos[0].delay
        lfo1Fade = program.lfos[0].fade
        lfo1Phase = program.lfos[0].phase
        
        // LFO 2
        lfo2Waveform = program.lfos[1].waveform
        lfo2Rate = program.lfos[1].rate
        lfo2Sync = program.lfos[1].sync
        lfo2KeySync = program.lfos[1].keySync
        lfo2Delay = program.lfos[1].delay
        lfo2Fade = program.lfos[1].fade
        lfo2Phase = program.lfos[1].phase
        
        // LFO 3
        lfo3Waveform = program.lfos[2].waveform
        lfo3Rate = program.lfos[2].rate
        lfo3Sync = program.lfos[2].sync
        lfo3KeySync = program.lfos[2].keySync
        lfo3Delay = program.lfos[2].delay
        lfo3Fade = program.lfos[2].fade
        lfo3Phase = program.lfos[2].phase
    }
    
    // MARK: - LFO Access
    
    /// Returns the LFO at the specified index.
    public func lfo(at index: Int) -> LFO {
        guard index >= 0 && index < program.lfos.count else {
            return .default(index: index)
        }
        return program.lfos[index]
    }
    
    /// Updates an LFO at the specified index.
    public func updateLFO(_ lfo: LFO, at index: Int) {
        guard index >= 0 && index < program.lfos.count else { return }
        program.lfos[index] = lfo
        updateLFOBindings()
    }
    
    // MARK: - Common Parameters
    
    /// Returns the available waveform types.
    public var waveformTypes: [LFOWaveform] {
        return Array(LFOWaveform.allCases)
    }
    
    /// Returns the available sync modes.
    public var syncModes: [LFOSync] {
        return Array(LFOSync.allCases)
    }
    
    /// Returns the rate range.
    public var rateRange: ClosedRange<Int> {
        return 0...127
    }
    
    /// Returns the delay/fade/phase range.
    public var timingRange: ClosedRange<Int> {
        return 0...127
    }
}
