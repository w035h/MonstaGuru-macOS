// GlobalEditorView.swift
// MonstaGuru
// Created by Mistral Vibe Code (Program Editor Agent)

import SwiftUI
import Data

/// View for editing global program settings.
public struct GlobalEditorView: View {
    
    @ObservedObject public var viewModel: GlobalEditorViewModel
    
    // MARK: - Body
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Global Settings Header
                Text("Global Settings")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Polyphony and Portamento
                polyphonyAndPortamentoView
                
                Divider()
                
                // Pitch and Tuning
                pitchAndTuningView
                
                Divider()
                
                // Volume and Velocity
                volumeAndVelocityView
            }
            .padding()
        }
        .navigationTitle("Global")
    }
    
    // MARK: - Polyphony and Portamento View
    
    private var polyphonyAndPortamentoView: some View {
        VStack(spacing: 16) {
            Text("Polyphony & Portamento")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 24) {
                // Polyphony
                VStack(spacing: 8) {
                    Text("Polyphony")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    StepperView(
                        value: $viewModel.polyphony,
                        range: viewModel.polyphonyRange,
                        label: "Voices",
                        valueFormatter: viewModel.formattedPolyphony
                    )
                    .frame(width: 140)
                }
                
                // Portamento
                VStack(spacing: 8) {
                    Toggle("Portamento", isOn: $viewModel.portamentoEnabled)
                        .toggleStyle(.checkbox)
                    
                    if viewModel.portamentoEnabled {
                        KnobView(
                            value: $viewModel.portamentoTime,
                            range: viewModel.portamentoTimeRange,
                            label: "Time",
                            color: .blue,
                            size: 60,
                            valueFormatter: viewModel.formattedPortamentoTime
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Pitch and Tuning View
    
    private var pitchAndTuningView: some View {
        VStack(spacing: 16) {
            Text("Pitch & Tuning")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 24) {
                // Pitch Bend Range
                VStack(spacing: 8) {
                    Text("Pitch Bend Range")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    SliderView(
                        value: $viewModel.pitchBendRange,
                        range: viewModel.pitchBendRangeRange,
                        label: "",
                        valueFormatter: viewModel.formattedPitchBendRange
                    )
                    .frame(width: 200)
                }
                
                // Master Tune
                VStack(spacing: 8) {
                    Text("Master Tune")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    KnobView(
                        value: $viewModel.masterTune,
                        range: viewModel.masterTuneRange,
                        label: "Tune",
                        color: .green,
                        size: 70,
                        valueFormatter: viewModel.formattedMasterTune
                    )
                }
            }
        }
    }
    
    // MARK: - Volume and Velocity View
    
    private var volumeAndVelocityView: some View {
        VStack(spacing: 16) {
            Text("Volume & Velocity")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 24) {
                // Master Volume
                VStack(spacing: 8) {
                    Text("Master Volume")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    KnobView(
                        value: $viewModel.masterVolume,
                        range: viewModel.masterVolumeRange,
                        label: "Volume",
                        color: .blue,
                        size: 80,
                        valueFormatter: viewModel.formattedMasterVolume
                    )
                }
                
                // Velocity Curve
                VStack(spacing: 8) {
                    Text("Velocity Curve")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Curve", selection: $viewModel.velocityCurve) {
                        ForEach(0..<viewModel.velocityCurveTypes.count, id: \.self) { index in
                            Text(viewModel.velocityCurveTypes[index])
                                .tag(index)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 140)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let program = Program.newProgram()
    let viewModel = GlobalEditorViewModel(program: program)
    return GlobalEditorView(viewModel: viewModel)
        .frame(width: 800, height: 400)
}
