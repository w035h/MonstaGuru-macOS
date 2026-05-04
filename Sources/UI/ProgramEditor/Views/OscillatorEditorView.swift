// OscillatorEditorView.swift
// MonstaGuru
// Created by Mistral Vibe Code (Program Editor Agent)

import SwiftUI
import Data

/// View for editing oscillator parameters.
public struct OscillatorEditorView: View {
    
    @ObservedObject public var viewModel: OscillatorEditorViewModel
    
    // MARK: - Body
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Oscillator 1
                oscillatorSectionView(
                    title: "Oscillator 1",
                    waveform: $viewModel.osc1Waveform,
                    coarsePitch: $viewModel.osc1CoarsePitch,
                    finePitch: $viewModel.osc1FinePitch,
                    detune: $viewModel.osc1Detune,
                    syncEnabled: $viewModel.osc1SyncEnabled,
                    ringModEnabled: $viewModel.osc1RingModEnabled,
                    pulseWidth: $viewModel.osc1PulseWidth,
                    level: $viewModel.osc1Level,
                    pan: $viewModel.osc1Pan
                )
                
                Divider()
                
                // Oscillator 2
                oscillatorSectionView(
                    title: "Oscillator 2",
                    waveform: $viewModel.osc2Waveform,
                    coarsePitch: $viewModel.osc2CoarsePitch,
                    finePitch: $viewModel.osc2FinePitch,
                    detune: $viewModel.osc2Detune,
                    syncEnabled: $viewModel.osc2SyncEnabled,
                    ringModEnabled: $viewModel.osc2RingModEnabled,
                    pulseWidth: $viewModel.osc2PulseWidth,
                    level: $viewModel.osc2Level,
                    pan: $viewModel.osc2Pan
                )
                
                Divider()
                
                // Oscillator 3
                oscillatorSectionView(
                    title: "Oscillator 3",
                    waveform: $viewModel.osc3Waveform,
                    coarsePitch: $viewModel.osc3CoarsePitch,
                    finePitch: $viewModel.osc3FinePitch,
                    detune: $viewModel.osc3Detune,
                    syncEnabled: $viewModel.osc3SyncEnabled,
                    ringModEnabled: $viewModel.osc3RingModEnabled,
                    pulseWidth: $viewModel.osc3PulseWidth,
                    level: $viewModel.osc3Level,
                    pan: $viewModel.osc3Pan
                )
            }
            .padding()
        }
        .navigationTitle("Oscillators")
    }
    
    // MARK: - Oscillator Section View
    
    @ViewBuilder
    private func oscillatorSectionView(
        title: String,
        waveform: Binding<OscillatorWaveform>,
        coarsePitch: Binding<Int>,
        finePitch: Binding<Int>,
        detune: Binding<Int>,
        syncEnabled: Binding<Bool>,
        ringModEnabled: Binding<Bool>,
        pulseWidth: Binding<Int>,
        level: Binding<Int>,
        pan: Binding<Int>
    ) -> some View {
        VStack(spacing: 16) {
            // Section Header
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Waveform and Sync
            HStack(spacing: 16) {
                EnumPickerView(
                    selection: waveform,
                    label: "Waveform"
                )
                .frame(width: 180)
                
                Toggle("Sync", isOn: syncEnabled)
                    .toggleStyle(.checkbox)
                    .frame(width: 100)
                
                Toggle("Ring Mod", isOn: ringModEnabled)
                    .toggleStyle(.checkbox)
                    .frame(width: 100)
            }
            
            // Pitch Controls
            HStack(spacing: 16) {
                KnobView(
                    value: coarsePitch,
                    range: viewModel.coarsePitchRange,
                    label: "Coarse",
                    color: .blue,
                    size: 60,
                    valueFormatter: viewModel.formattedPitch
                )
                
                KnobView(
                    value: finePitch,
                    range: viewModel.finePitchRange,
                    label: "Fine",
                    color: .blue,
                    size: 60,
                    valueFormatter: viewModel.formattedPitch
                )
                
                KnobView(
                    value: detune,
                    range: viewModel.detuneRange,
                    label: "Detune",
                    color: .blue,
                    size: 60
                )
                
                KnobView(
                    value: pulseWidth,
                    range: viewModel.pulseWidthRange,
                    label: "PW",
                    color: .purple,
                    size: 60
                )
            }
            
            // Level and Pan
            HStack(spacing: 16) {
                KnobView(
                    value: level,
                    range: viewModel.levelRange,
                    label: "Level",
                    color: .green,
                    size: 60,
                    valueFormatter: { "$0%" }
                )
                
                KnobView(
                    value: pan,
                    range: viewModel.panRange,
                    label: "Pan",
                    color: .orange,
                    size: 60,
                    valueFormatter: viewModel.formattedPan
                )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let program = Program.newProgram()
    let viewModel = OscillatorEditorViewModel(program: program)
    return OscillatorEditorView(viewModel: viewModel)
        .frame(width: 800, height: 600)
}
