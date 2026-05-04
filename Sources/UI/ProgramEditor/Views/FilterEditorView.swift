// FilterEditorView.swift
// MonstaGuru
// Created by Mistral Vibe Code (Program Editor Agent)

import SwiftUI
import Data

/// View for editing filter parameters.
public struct FilterEditorView: View {
    
    @ObservedObject public var viewModel: FilterEditorViewModel
    
    // MARK: - Body
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Filter 1
                filterSectionView(
                    title: "Filter 1",
                    type: $viewModel.filter1Type,
                    cutoff: $viewModel.filter1Cutoff,
                    resonance: $viewModel.filter1Resonance,
                    keyTrack: $viewModel.filter1KeyTrack,
                    envelopeAmount: $viewModel.filter1EnvelopeAmount,
                    envelopePolarity: $viewModel.filter1EnvelopePolarity,
                    lfoAmount: $viewModel.filter1LFOAmount,
                    velocityAmount: $viewModel.filter1VelocityAmount,
                    pressureAmount: $viewModel.filter1PressureAmount
                )
                
                Divider()
                
                // Filter 2
                filterSectionView(
                    title: "Filter 2",
                    type: $viewModel.filter2Type,
                    cutoff: $viewModel.filter2Cutoff,
                    resonance: $viewModel.filter2Resonance,
                    keyTrack: $viewModel.filter2KeyTrack,
                    envelopeAmount: $viewModel.filter2EnvelopeAmount,
                    envelopePolarity: $viewModel.filter2EnvelopePolarity,
                    lfoAmount: $viewModel.filter2LFOAmount,
                    velocityAmount: $viewModel.filter2VelocityAmount,
                    pressureAmount: $viewModel.filter2PressureAmount
                )
            }
            .padding()
        }
        .navigationTitle("Filters")
    }
    
    // MARK: - Filter Section View
    
    @ViewBuilder
    private func filterSectionView(
        title: String,
        type: Binding<FilterType>,
        cutoff: Binding<Int>,
        resonance: Binding<Int>,
        keyTrack: Binding<Int>,
        envelopeAmount: Binding<Int>,
        envelopePolarity: Binding<Bool>,
        lfoAmount: Binding<Int>,
        velocityAmount: Binding<Int>,
        pressureAmount: Binding<Int>
    ) -> some View {
        VStack(spacing: 16) {
            // Section Header
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Type and Polarity
            HStack(spacing: 16) {
                EnumPickerView(
                    selection: type,
                    label: "Type"
                )
                .frame(width: 180)
                
                Toggle("Env Polarity", isOn: envelopePolarity)
                    .toggleStyle(.checkbox)
                    .frame(width: 120)
            }
            
            // Main Controls
            HStack(spacing: 16) {
                KnobView(
                    value: cutoff,
                    range: viewModel.cutoffRange,
                    label: "Cutoff",
                    color: .blue,
                    size: 70
                )
                
                KnobView(
                    value: resonance,
                    range: viewModel.resonanceRange,
                    label: "Resonance",
                    color: .purple,
                    size: 70
                )
                
                KnobView(
                    value: keyTrack,
                    range: viewModel.keyTrackRange,
                    label: "Key Track",
                    color: .green,
                    size: 70
                )
            }
            
            // Modulation Amounts
            HStack(spacing: 16) {
                KnobView(
                    value: envelopeAmount,
                    range: viewModel.modulationAmountRange,
                    label: "Env Amount",
                    color: .orange,
                    size: 60,
                    valueFormatter: viewModel.formattedModulationAmount
                )
                
                KnobView(
                    value: lfoAmount,
                    range: viewModel.modulationAmountRange,
                    label: "LFO Amount",
                    color: .orange,
                    size: 60,
                    valueFormatter: viewModel.formattedModulationAmount
                )
                
                KnobView(
                    value: velocityAmount,
                    range: viewModel.modulationAmountRange,
                    label: "Vel Amount",
                    color: .orange,
                    size: 60,
                    valueFormatter: viewModel.formattedModulationAmount
                )
                
                KnobView(
                    value: pressureAmount,
                    range: viewModel.modulationAmountRange,
                    label: "Press Amount",
                    color: .orange,
                    size: 60,
                    valueFormatter: viewModel.formattedModulationAmount
                )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let program = Program.newProgram()
    let viewModel = FilterEditorViewModel(program: program)
    return FilterEditorView(viewModel: viewModel)
        .frame(width: 800, height: 600)
}
