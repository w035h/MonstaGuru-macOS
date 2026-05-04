// EffectsEditorView.swift
// MonstaGuru
// Created by Mistral Vibe Code (Program Editor Agent)

import SwiftUI
import Data

/// View for editing effects parameters.
public struct EffectsEditorView: View {
    
    @ObservedObject public var viewModel: EffectsEditorViewModel
    
    // MARK: - Body
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Effect 1
                effectSectionView(
                    title: "Effect 1",
                    type: $viewModel.effect1Type,
                    param1: $viewModel.effect1Param1,
                    param2: $viewModel.effect1Param2,
                    param3: $viewModel.effect1Param3,
                    level: $viewModel.effect1Level
                )
                
                Divider()
                
                // Effect 2
                effectSectionView(
                    title: "Effect 2",
                    type: $viewModel.effect2Type,
                    param1: $viewModel.effect2Param1,
                    param2: $viewModel.effect2Param2,
                    param3: $viewModel.effect2Param3,
                    level: $viewModel.effect2Level
                )
                
                Divider()
                
                // Effect 3
                effectSectionView(
                    title: "Effect 3",
                    type: $viewModel.effect3Type,
                    param1: $viewModel.effect3Param1,
                    param2: $viewModel.effect3Param2,
                    param3: $viewModel.effect3Param3,
                    level: $viewModel.effect3Level
                )
                
                Divider()
                
                // Master Level
                HStack(spacing: 16) {
                    Text("Master Level")
                        .font(.headline)
                    
                    Spacer()
                    
                    KnobView(
                        value: $viewModel.masterLevel,
                        range: viewModel.masterLevelRange,
                        label: "Master",
                        color: .accentColor,
                        size: 80,
                        valueFormatter: viewModel.formattedLevel
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Effects")
    }
    
    // MARK: - Effect Section View
    
    @ViewBuilder
    private func effectSectionView(
        title: String,
        type: Binding<EffectType>,
        param1: Binding<Int>,
        param2: Binding<Int>,
        param3: Binding<Int>,
        level: Binding<Int>
    ) -> some View {
        VStack(spacing: 16) {
            // Section Header
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Type Selector
            EnumPickerView(
                selection: type,
                label: "Type"
            )
            .frame(width: 180)
            
            // Parameters
            if type.wrappedValue != .off {
                let paramLabels = viewModel.parameterLabels(for: type.wrappedValue)
                
                HStack(spacing: 16) {
                    KnobView(
                        value: param1,
                        range: viewModel.parameterRange,
                        label: paramLabels[0],
                        color: .blue,
                        size: 60
                    )
                    
                    KnobView(
                        value: param2,
                        range: viewModel.parameterRange,
                        label: paramLabels[1],
                        color: .green,
                        size: 60
                    )
                    
                    KnobView(
                        value: param3,
                        range: viewModel.parameterRange,
                        label: paramLabels[2],
                        color: .purple,
                        size: 60
                    )
                    
                    KnobView(
                        value: level,
                        range: viewModel.levelRange,
                        label: "Level",
                        color: .orange,
                        size: 60,
                        valueFormatter: viewModel.formattedLevel
                    )
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let program = Program.newProgram()
    let viewModel = EffectsEditorViewModel(program: program)
    return EffectsEditorView(viewModel: viewModel)
        .frame(width: 800, height: 600)
}
