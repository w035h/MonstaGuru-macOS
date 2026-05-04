// ProgramEditorViewModel.swift
// MonstaGuru
// Created by Mistral Vibe Code (Program Editor Agent)

import Foundation
import SwiftUI
import Combine
import Data
import MIDI

/// Main ViewModel for the Program Editor.
/// Manages the current program, coordinates with sub-ViewModels, and handles MIDI integration.
public final class ProgramEditorViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// The current program being edited.
    @Published public var program: Program
    
    /// The original program for cancel/revert functionality.
    @Published public private(set) var originalProgram: Program
    
    /// Whether the program has unsaved changes.
    @Published public var hasUnsavedChanges: Bool = false
    
    /// The current selected tab.
    @Published public var selectedTab: EditorTab = .oscillators
    
    /// Whether MIDI is connected and ready.
    @Published public var isMIDIConnected: Bool = false
    
    /// The last received MIDI parameter change (for real-time feedback).
    @Published public var lastParameterChange: (address: ParameterAddress, value: Int)?
    
    // MARK: - Public Properties
    
    /// The MIDI manager for hardware communication.
    public let midiManager: MIDIManager
    
    /// The program repository for saving/loading programs.
    public let programRepository: ProgramRepositoryProtocol
    
    /// The clipboard repository for copy/paste operations.
    public let clipboardRepository: ClipboardRepositoryProtocol
    
    // MARK: - Sub-ViewModels
    
    /// Oscillator editor ViewModel.
    public let oscillatorViewModel: OscillatorEditorViewModel
    
    /// Mixer editor ViewModel.
    public let mixerViewModel: MixerEditorViewModel
    
    /// Filter editor ViewModel.
    public let filterViewModel: FilterEditorViewModel
    
    /// Envelope editor ViewModel.
    public let envelopeViewModel: EnvelopeEditorViewModel
    
    /// LFO editor ViewModel.
    public let lfoViewModel: LFOEditorViewModel
    
    /// Matrix editor ViewModel.
    public let matrixViewModel: MatrixEditorViewModel
    
    /// Effects editor ViewModel.
    public let effectsViewModel: EffectsEditorViewModel
    
    /// Global settings editor ViewModel.
    public let globalViewModel: GlobalEditorViewModel
    
    // MARK: - Private Properties
    
    /// Cancellables for Combine subscriptions.
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initialization
    
    public init(
        program: Program = Program.newProgram(),
        midiManager: MIDIManager = MIDIManager(),
        programRepository: ProgramRepositoryProtocol = ProgramRepository(modelContext: ModelContext(try! ModelContainer(for: Program.self))),
        clipboardRepository: ClipboardRepositoryProtocol = ClipboardRepository(modelContext: ModelContext(try! ModelContainer(for: ClipboardEntry.self)))
    ) {
        self.program = program
        self.originalProgram = program.copy()
        self.midiManager = midiManager
        self.programRepository = programRepository
        self.clipboardRepository = clipboardRepository
        
        // Initialize sub-ViewModels
        self.oscillatorViewModel = OscillatorEditorViewModel(program: program)
        self.mixerViewModel = MixerEditorViewModel(program: program)
        self.filterViewModel = FilterEditorViewModel(program: program)
        self.envelopeViewModel = EnvelopeEditorViewModel(program: program)
        self.lfoViewModel = LFOEditorViewModel(program: program)
        self.matrixViewModel = MatrixEditorViewModel(program: program)
        self.effectsViewModel = EffectsEditorViewModel(program: program)
        self.globalViewModel = GlobalEditorViewModel(program: program)
        
        setupSubscriptions()
        setupMIDIManager()
    }
    
    // MARK: - Setup
    
    private func setupSubscriptions() {
        // Subscribe to program changes from sub-ViewModels
        oscillatorViewModel.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
                self?.hasUnsavedChanges = true
            }
            .store(in: &cancellables)
        
        mixerViewModel.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
                self?.hasUnsavedChanges = true
            }
            .store(in: &cancellables)
        
        filterViewModel.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
                self?.hasUnsavedChanges = true
            }
            .store(in: &cancellables)
        
        envelopeViewModel.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
                self?.hasUnsavedChanges = true
            }
            .store(in: &cancellables)
        
        lfoViewModel.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
                self?.hasUnsavedChanges = true
            }
            .store(in: &cancellables)
        
        matrixViewModel.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
                self?.hasUnsavedChanges = true
            }
            .store(in: &cancellables)
        
        effectsViewModel.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
                self?.hasUnsavedChanges = true
            }
            .store(in: &cancellables)
        
        globalViewModel.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
                self?.hasUnsavedChanges = true
            }
            .store(in: &cancellables)
    }
    
    private func setupMIDIManager() {
        midiManager.delegate = self
        
        // Subscribe to MIDI connection changes
        midiManager.objectWillChange
            .sink { [weak self] _ in
                self?.updateMIDIConnectionStatus()
            }
            .store(in: &cancellables)
        
        updateMIDIConnectionStatus()
    }
    
    private func updateMIDIConnectionStatus() {
        isMIDIConnected = midiManager.isInputConnected && midiManager.isOutputConnected
    }
    
    // MARK: - Program Management
    
    /// Loads a program from the repository.
    public func loadProgram(_ program: Program) {
        self.program = program
        self.originalProgram = program.copy()
        self.hasUnsavedChanges = false
        
        // Update all sub-ViewModels
        oscillatorViewModel.program = program
        mixerViewModel.program = program
        filterViewModel.program = program
        envelopeViewModel.program = program
        lfoViewModel.program = program
        matrixViewModel.program = program
        effectsViewModel.program = program
        globalViewModel.program = program
    }
    
    /// Creates a new program.
    public func newProgram() {
        let newProgram = Program.newProgram()
        loadProgram(newProgram)
    }
    
    /// Saves the current program.
    public func saveProgram() throws {
        try programRepository.save(program)
        originalProgram = program.copy()
        hasUnsavedChanges = false
    }
    
    /// Reverts to the original program.
    public func revertProgram() {
        program = originalProgram.copy()
        hasUnsavedChanges = false
        
        // Update all sub-ViewModels
        oscillatorViewModel.program = program
        mixerViewModel.program = program
        filterViewModel.program = program
        envelopeViewModel.program = program
        lfoViewModel.program = program
        matrixViewModel.program = program
        effectsViewModel.program = program
        globalViewModel.program = program
    }
    
    /// Sends the current program to the hardware.
    public func sendProgramToHardware() throws {
        guard isMIDIConnected else {
            throw MIDIError.noOutputDevicesAvailable
        }
        try midiManager.sendProgram(program)
    }
    
    /// Requests the current program from the hardware.
    public func requestProgramFromHardware() throws {
        guard isMIDIConnected else {
            throw MIDIError.noOutputDevicesAvailable
        }
        try midiManager.requestProgramDump(programNumber: program.number)
    }
    
    // MARK: - Clipboard Operations
    
    /// Copies the entire program to the clipboard.
    public func copyProgramToClipboard() {
        let entry = ClipboardEntry.fromProgram(program)
        try? clipboardRepository.save(entry)
    }
    
    /// Copies an oscillator to the clipboard.
    public func copyOscillatorToClipboard(_ oscillator: Oscillator) {
        let entry = ClipboardEntry.fromOscillator(oscillator)
        try? clipboardRepository.save(entry)
    }
    
    /// Copies a filter to the clipboard.
    public func copyFilterToClipboard(_ filter: Filter) {
        let entry = ClipboardEntry.fromFilter(filter)
        try? clipboardRepository.save(entry)
    }
    
    /// Copies an envelope to the clipboard.
    public func copyEnvelopeToClipboard(_ envelope: Envelope) {
        let entry = ClipboardEntry.fromEnvelope(envelope)
        try? clipboardRepository.save(entry)
    }
    
    /// Copies an LFO to the clipboard.
    public func copyLFOToClipboard(_ lfo: LFO) {
        let entry = ClipboardEntry.fromLFO(lfo)
        try? clipboardRepository.save(entry)
    }
    
    /// Copies a matrix slot to the clipboard.
    public func copyMatrixSlotToClipboard(_ slot: MatrixSlot) {
        let entry = ClipboardEntry.fromMatrixSlot(slot)
        try? clipboardRepository.save(entry)
    }
    
    /// Pastes from the clipboard to the specified target.
    public func pasteFromClipboard(to target: PasteTarget) {
        // This would be implemented with actual clipboard functionality
        // For now, just a placeholder
    }
    
    // MARK: - Editor Tabs
    
    public enum EditorTab: String, CaseIterable, Identifiable {
        case oscillators = "Oscillators"
        case mixer = "Mixer"
        case filters = "Filters"
        case envelopes = "Envelopes"
        case lfos = "LFOs"
        case matrix = "Matrix"
        case effects = "Effects"
        case global = "Global"
        
        public var id: String { rawValue }
    }
    
    // MARK: - Paste Targets
    
    public enum PasteTarget {
        case program
        case oscillator(index: Int)
        case filter(index: Int)
        case envelope(index: Int)
        case lfo(index: Int)
        case matrixSlot(index: Int)
        case effects
        case global
    }
}

// MARK: - MIDIManagerDelegate Conformance

extension ProgramEditorViewModel: MIDIManagerDelegate {
    
    public func midiManager(_ manager: MIDIManager, didReceiveNoteOn channel: MIDIChannel, note: MIDINote, velocity: MIDIVelocity) {
        // Handle note on for preview
    }
    
    public func midiManager(_ manager: MIDIManager, didReceiveNoteOff channel: MIDIChannel, note: MIDINote, velocity: MIDIVelocity) {
        // Handle note off for preview
    }
    
    public func midiManager(_ manager: MIDIManager, didReceiveControlChange channel: MIDIChannel, control: MIDIControl, value: MIDIVelocity) {
        // Handle control change for preview
    }
    
    public func midiManager(_ manager: MIDIManager, didReceiveProgramChange channel: MIDIChannel, program: MIDIProgram) {
        // Handle program change
    }
    
    public func midiManager(_ manager: MIDIManager, didReceivePitchBend channel: MIDIChannel, value: MIDIPitchBend) {
        // Handle pitch bend for preview
    }
    
    public func midiManager(_ manager: MIDIManager, didReceiveSysEx message: [UInt8]) {
        // SysEx messages are handled by the parser
    }
    
    public func midiManager(_ manager: MIDIManager, didReceiveProgram receivedProgram: Program) {
        // Load the received program
        DispatchQueue.main.async {
            self.loadProgram(receivedProgram)
        }
    }
    
    public func midiManager(_ manager: MIDIManager, didReceiveParameterChange address: ParameterAddress, value: Int) {
        // Update the parameter in the current program
        DispatchQueue.main.async {
            self.lastParameterChange = (address, value)
            self.applyParameterChange(address: address, value: value)
        }
    }
    
    public func midiManager(_ manager: MIDIManager, didEncounterError error: MIDIError) {
        // Handle MIDI errors
        print("MIDI Error: \(error.localizedDescription)")
    }
    
    // MARK: - Parameter Change Handling
    
    private func applyParameterChange(address: ParameterAddress, value: Int) {
        switch address {
        // Oscillator 1
        case .osc1Waveform: program.oscillators[0].waveform = OscillatorWaveform(rawValue: value) ?? .sawtooth
        case .osc1CoarsePitch: program.oscillators[0].coarsePitch = value - 64
        case .osc1FinePitch: program.oscillators[0].finePitch = value - 64
        case .osc1Detune: program.oscillators[0].detune = value
        case .osc1Sync: program.oscillators[0].syncEnabled = value != 0
        case .osc1RingMod: program.oscillators[0].ringModEnabled = value != 0
        case .osc1PulseWidth: program.oscillators[0].pulseWidth = value
        case .osc1Level: program.oscillators[0].level = value
        case .osc1Pan: program.oscillators[0].pan = value - 64
        
        // Oscillator 2
        case .osc2Waveform: program.oscillators[1].waveform = OscillatorWaveform(rawValue: value) ?? .sawtooth
        case .osc2CoarsePitch: program.oscillators[1].coarsePitch = value - 64
        case .osc2FinePitch: program.oscillators[1].finePitch = value - 64
        case .osc2Detune: program.oscillators[1].detune = value
        case .osc2Sync: program.oscillators[1].syncEnabled = value != 0
        case .osc2RingMod: program.oscillators[1].ringModEnabled = value != 0
        case .osc2PulseWidth: program.oscillators[1].pulseWidth = value
        case .osc2Level: program.oscillators[1].level = value
        case .osc2Pan: program.oscillators[1].pan = value - 64
        
        // Oscillator 3
        case .osc3Waveform: program.oscillators[2].waveform = OscillatorWaveform(rawValue: value) ?? .sawtooth
        case .osc3CoarsePitch: program.oscillators[2].coarsePitch = value - 64
        case .osc3FinePitch: program.oscillators[2].finePitch = value - 64
        case .osc3Detune: program.oscillators[2].detune = value
        case .osc3Sync: program.oscillators[2].syncEnabled = value != 0
        case .osc3RingMod: program.oscillators[2].ringModEnabled = value != 0
        case .osc3PulseWidth: program.oscillators[2].pulseWidth = value
        case .osc3Level: program.oscillators[2].level = value
        case .osc3Pan: program.oscillators[2].pan = value - 64
        
        // Mixer
        case .mixerOsc1Level: program.mixer.osc1Level = value
        case .mixerOsc2Level: program.mixer.osc2Level = value
        case .mixerOsc3Level: program.mixer.osc3Level = value
        case .mixerNoiseLevel: program.mixer.noiseLevel = value
        case .mixerExternalLevel: program.mixer.externalLevel = value
        case .mixerRingModLevel: program.mixer.ringModLevel = value
        
        // Filter 1
        case .filter1Type: program.filters[0].type = FilterType(rawValue: value) ?? .lowPass24dB
        case .filter1Cutoff: program.filters[0].cutoff = value
        case .filter1Resonance: program.filters[0].resonance = value
        case .filter1KeyTrack: program.filters[0].keyTrack = value
        case .filter1EnvelopeAmount: program.filters[0].envelopeAmount = value - 64
        case .filter1EnvelopePolarity: program.filters[0].envelopePolarity = value != 0
        case .filter1LFOAmount: program.filters[0].lfoAmount = value - 64
        case .filter1VelocityAmount: program.filters[0].velocityAmount = value - 64
        case .filter1PressureAmount: program.filters[0].pressureAmount = value - 64
        
        // Filter 2
        case .filter2Type: program.filters[1].type = FilterType(rawValue: value) ?? .lowPass24dB
        case .filter2Cutoff: program.filters[1].cutoff = value
        case .filter2Resonance: program.filters[1].resonance = value
        case .filter2KeyTrack: program.filters[1].keyTrack = value
        case .filter2EnvelopeAmount: program.filters[1].envelopeAmount = value - 64
        case .filter2EnvelopePolarity: program.filters[1].envelopePolarity = value != 0
        case .filter2LFOAmount: program.filters[1].lfoAmount = value - 64
        case .filter2VelocityAmount: program.filters[1].velocityAmount = value - 64
        case .filter2PressureAmount: program.filters[1].pressureAmount = value - 64
        
        // Envelope 1
        case .env1Attack: program.envelopes[0].attack = value
        case .env1Decay: program.envelopes[0].decay = value
        case .env1Sustain: program.envelopes[0].sustain = value
        case .env1Release: program.envelopes[0].release = value
        case .env1VelocitySensitivity: program.envelopes[0].velocitySensitivity = value
        case .env1KeyTrack: program.envelopes[0].keyTrack = value
        
        // Envelope 2
        case .env2Attack: program.envelopes[1].attack = value
        case .env2Decay: program.envelopes[1].decay = value
        case .env2Sustain: program.envelopes[1].sustain = value
        case .env2Release: program.envelopes[1].release = value
        case .env2VelocitySensitivity: program.envelopes[1].velocitySensitivity = value
        case .env2KeyTrack: program.envelopes[1].keyTrack = value
        
        // Envelope 3
        case .env3Attack: program.envelopes[2].attack = value
        case .env3Decay: program.envelopes[2].decay = value
        case .env3Sustain: program.envelopes[2].sustain = value
        case .env3Release: program.envelopes[2].release = value
        case .env3VelocitySensitivity: program.envelopes[2].velocitySensitivity = value
        case .env3KeyTrack: program.envelopes[2].keyTrack = value
        
        // LFO 1
        case .lfo1Waveform: program.lfos[0].waveform = LFOWaveform(rawValue: value) ?? .sine
        case .lfo1Rate: program.lfos[0].rate = value
        case .lfo1Sync: program.lfos[0].sync = LFOSync(rawValue: value) ?? .free
        case .lfo1KeySync: program.lfos[0].keySync = value != 0
        case .lfo1Delay: program.lfos[0].delay = value
        case .lfo1Fade: program.lfos[0].fade = value
        case .lfo1Phase: program.lfos[0].phase = value
        
        // LFO 2
        case .lfo2Waveform: program.lfos[1].waveform = LFOWaveform(rawValue: value) ?? .sine
        case .lfo2Rate: program.lfos[1].rate = value
        case .lfo2Sync: program.lfos[1].sync = LFOSync(rawValue: value) ?? .free
        case .lfo2KeySync: program.lfos[1].keySync = value != 0
        case .lfo2Delay: program.lfos[1].delay = value
        case .lfo2Fade: program.lfos[1].fade = value
        case .lfo2Phase: program.lfos[1].phase = value
        
        // LFO 3
        case .lfo3Waveform: program.lfos[2].waveform = LFOWaveform(rawValue: value) ?? .sine
        case .lfo3Rate: program.lfos[2].rate = value
        case .lfo3Sync: program.lfos[2].sync = LFOSync(rawValue: value) ?? .free
        case .lfo3KeySync: program.lfos[2].keySync = value != 0
        case .lfo3Delay: program.lfos[2].delay = value
        case .lfo3Fade: program.lfos[2].fade = value
        case .lfo3Phase: program.lfos[2].phase = value
        
        // Matrix
        case .matrixSlot1Source: program.matrix[0].source = MatrixSource(rawValue: value) ?? .off
        case .matrixSlot1Destination: program.matrix[0].destination = MatrixDestination(rawValue: value) ?? .off
        case .matrixSlot1Amount: program.matrix[0].amount = value - 64
        case .matrixSlot2Source: program.matrix[1].source = MatrixSource(rawValue: value) ?? .off
        case .matrixSlot2Destination: program.matrix[1].destination = MatrixDestination(rawValue: value) ?? .off
        case .matrixSlot2Amount: program.matrix[1].amount = value - 64
        case .matrixSlot3Source: program.matrix[2].source = MatrixSource(rawValue: value) ?? .off
        case .matrixSlot3Destination: program.matrix[2].destination = MatrixDestination(rawValue: value) ?? .off
        case .matrixSlot3Amount: program.matrix[2].amount = value - 64
        case .matrixSlot4Source: program.matrix[3].source = MatrixSource(rawValue: value) ?? .off
        case .matrixSlot4Destination: program.matrix[3].destination = MatrixDestination(rawValue: value) ?? .off
        case .matrixSlot4Amount: program.matrix[3].amount = value - 64
        case .matrixSlot5Source: program.matrix[4].source = MatrixSource(rawValue: value) ?? .off
        case .matrixSlot5Destination: program.matrix[4].destination = MatrixDestination(rawValue: value) ?? .off
        case .matrixSlot5Amount: program.matrix[4].amount = value - 64
        case .matrixSlot6Source: program.matrix[5].source = MatrixSource(rawValue: value) ?? .off
        case .matrixSlot6Destination: program.matrix[5].destination = MatrixDestination(rawValue: value) ?? .off
        case .matrixSlot6Amount: program.matrix[5].amount = value - 64
        case .matrixSlot7Source: program.matrix[6].source = MatrixSource(rawValue: value) ?? .off
        case .matrixSlot7Destination: program.matrix[6].destination = MatrixDestination(rawValue: value) ?? .off
        case .matrixSlot7Amount: program.matrix[6].amount = value - 64
        case .matrixSlot8Source: program.matrix[7].source = MatrixSource(rawValue: value) ?? .off
        case .matrixSlot8Destination: program.matrix[7].destination = MatrixDestination(rawValue: value) ?? .off
        case .matrixSlot8Amount: program.matrix[7].amount = value - 64
        case .matrixSlot9Source: program.matrix[8].source = MatrixSource(rawValue: value) ?? .off
        case .matrixSlot9Destination: program.matrix[8].destination = MatrixDestination(rawValue: value) ?? .off
        case .matrixSlot9Amount: program.matrix[8].amount = value - 64
        case .matrixSlot10Source: program.matrix[9].source = MatrixSource(rawValue: value) ?? .off
        case .matrixSlot10Destination: program.matrix[9].destination = MatrixDestination(rawValue: value) ?? .off
        case .matrixSlot10Amount: program.matrix[9].amount = value - 64
        case .matrixSlot11Source: program.matrix[10].source = MatrixSource(rawValue: value) ?? .off
        case .matrixSlot11Destination: program.matrix[10].destination = MatrixDestination(rawValue: value) ?? .off
        case .matrixSlot11Amount: program.matrix[10].amount = value - 64
        case .matrixSlot12Source: program.matrix[11].source = MatrixSource(rawValue: value) ?? .off
        case .matrixSlot12Destination: program.matrix[11].destination = MatrixDestination(rawValue: value) ?? .off
        case .matrixSlot12Amount: program.matrix[11].amount = value - 64
        
        // Effects
        case .effect1Type: program.effects.effect1.type = EffectType(rawValue: value) ?? .off
        case .effect1Param1: program.effects.effect1.param1 = value
        case .effect1Param2: program.effects.effect1.param2 = value
        case .effect1Param3: program.effects.effect1.param3 = value
        case .effect1Level: program.effects.effect1.level = value
        case .effect2Type: program.effects.effect2.type = EffectType(rawValue: value) ?? .off
        case .effect2Param1: program.effects.effect2.param1 = value
        case .effect2Param2: program.effects.effect2.param2 = value
        case .effect2Param3: program.effects.effect2.param3 = value
        case .effect2Level: program.effects.effect2.level = value
        case .effect3Type: program.effects.effect3.type = EffectType(rawValue: value) ?? .off
        case .effect3Param1: program.effects.effect3.param1 = value
        case .effect3Param2: program.effects.effect3.param2 = value
        case .effect3Param3: program.effects.effect3.param3 = value
        case .effect3Level: program.effects.effect3.level = value
        case .effectsMasterLevel: program.effects.masterLevel = value
        
        // Global
        case .globalPolyphony: program.global.polyphony = value
        case .globalPortamentoEnabled: program.global.portamentoEnabled = value != 0
        case .globalPortamentoTime: program.global.portamentoTime = value
        case .globalPitchBendRange: program.global.pitchBendRange = value - 12
        case .globalMasterVolume: program.global.masterVolume = value
        case .globalMasterTune: program.global.masterTune = value - 64
        case .globalVelocityCurve: program.global.velocityCurve = value
        
        // Metadata
        case .programName:
            // Name is handled separately
            break
        case .programNumber:
            program.number = value
        }
        
        hasUnsavedChanges = true
    }
}
