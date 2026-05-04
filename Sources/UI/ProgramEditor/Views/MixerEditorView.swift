// MixerEditorView.swift
// MonstaGuru
// Created by Mistral Vibe Code (Program Editor Agent)

import SwiftUI
import Data

/// View for editing mixer parameters.
public struct MixerEditorView: View {
    
    @ObservedObject public var viewModel: MixerEditorViewModel
    
    // MARK: - Body
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Mixer Header
                Text("Mixer Levels")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 8)
                
                // Level Controls
                levelControlsView
                
                // Level Meter Visualization
                levelMeterView
            }
            .padding()
        }
        .navigationTitle("Mixer")
    }
    
    // MARK: - Level Controls View
    
    private var levelControlsView: some View {
        VStack(spacing: 16) {
            // Oscillator Levels
            HStack(spacing: 24) {
                KnobView(
                    value: $viewModel.osc1Level,
                    range: viewModel.levelRange,
                    label: "Osc 1",
                    color: .blue,
                    size: 80,
                    valueFormatter: viewModel.formattedLevel
                )
                
                KnobView(
                    value: $viewModel.osc2Level,
                    range: viewModel.levelRange,
                    label: "Osc 2",
                    color: .blue,
                    size: 80,
                    valueFormatter: viewModel.formattedLevel
                )
                
                KnobView(
                    value: $viewModel.osc3Level,
                    range: viewModel.levelRange,
                    label: "Osc 3",
                    color: .blue,
                    size: 80,
                    valueFormatter: viewModel.formattedLevel
                )
            }
            
            // Additional Inputs
            HStack(spacing: 24) {
                KnobView(
                    value: $viewModel.noiseLevel,
                    range: viewModel.levelRange,
                    label: "Noise",
                    color: .purple,
                    size: 80,
                    valueFormatter: viewModel.formattedLevel
                )
                
                KnobView(
                    value: $viewModel.externalLevel,
                    range: viewModel.levelRange,
                    label: "External",
                    color: .orange,
                    size: 80,
                    valueFormatter: viewModel.formattedLevel
                )
                
                KnobView(
                    value: $viewModel.ringModLevel,
                    range: viewModel.levelRange,
                    label: "Ring Mod",
                    color: .green,
                    size: 80,
                    valueFormatter: viewModel.formattedLevel
                )
            }
        }
    }
    
    // MARK: - Level Meter View
    
    private var levelMeterView: some View {
        VStack(spacing: 16) {
            Text("Level Meter")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 8) {
                // Osc 1 Meter
                levelMeterBar(value: Double(viewModel.osc1Level) / 127.0, color: .blue, label: "O1")
                levelMeterBar(value: Double(viewModel.osc2Level) / 127.0, color: .blue, label: "O2")
                levelMeterBar(value: Double(viewModel.osc3Level) / 127.0, color: .blue, label: "O3")
                levelMeterBar(value: Double(viewModel.noiseLevel) / 127.0, color: .purple, label: "N")
                levelMeterBar(value: Double(viewModel.externalLevel) / 127.0, color: .orange, label: "E")
                levelMeterBar(value: Double(viewModel.ringModLevel) / 127.0, color: .green, label: "RM")
            }
            .frame(height: 30)
        }
    }
    
    // MARK: - Level Meter Bar
    
    @ViewBuilder
    private func levelMeterBar(value: Double, color: Color, label: String) -> some View {
        VStack(spacing: 4) {
            // Meter Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.secondary.opacity(0.2))
                    
                    // Active Level
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(value))
                }
            }
            .frame(height: 20)
            
            // Label
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(width: 40)
    }
}

// MARK: - Preview

#Preview {
    let program = Program.newProgram()
    let viewModel = MixerEditorViewModel(program: program)
    return MixerEditorView(viewModel: viewModel)
        .frame(width: 800, height: 400)
}
