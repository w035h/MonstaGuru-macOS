// LFOEditorView.swift
// MonstaGuru
// Created by Mistral Vibe Code (Program Editor Agent)

import SwiftUI
import Data

/// View for editing LFO parameters.
public struct LFOEditorView: View {
    
    @ObservedObject public var viewModel: LFOEditorViewModel
    
    // MARK: - Body
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // LFO 1
                lfoSectionView(
                    title: "LFO 1",
                    waveform: $viewModel.lfo1Waveform,
                    rate: $viewModel.lfo1Rate,
                    sync: $viewModel.lfo1Sync,
                    keySync: $viewModel.lfo1KeySync,
                    delay: $viewModel.lfo1Delay,
                    fade: $viewModel.lfo1Fade,
                    phase: $viewModel.lfo1Phase
                )
                
                Divider()
                
                // LFO 2
                lfoSectionView(
                    title: "LFO 2",
                    waveform: $viewModel.lfo2Waveform,
                    rate: $viewModel.lfo2Rate,
                    sync: $viewModel.lfo2Sync,
                    keySync: $viewModel.lfo2KeySync,
                    delay: $viewModel.lfo2Delay,
                    fade: $viewModel.lfo2Fade,
                    phase: $viewModel.lfo2Phase
                )
                
                Divider()
                
                // LFO 3
                lfoSectionView(
                    title: "LFO 3",
                    waveform: $viewModel.lfo3Waveform,
                    rate: $viewModel.lfo3Rate,
                    sync: $viewModel.lfo3Sync,
                    keySync: $viewModel.lfo3KeySync,
                    delay: $viewModel.lfo3Delay,
                    fade: $viewModel.lfo3Fade,
                    phase: $viewModel.lfo3Phase
                )
            }
            .padding()
        }
        .navigationTitle("LFOs")
    }
    
    // MARK: - LFO Section View
    
    @ViewBuilder
    private func lfoSectionView(
        title: String,
        waveform: Binding<LFOWaveform>,
        rate: Binding<Int>,
        sync: Binding<LFOSync>,
        keySync: Binding<Bool>,
        delay: Binding<Int>,
        fade: Binding<Int>,
        phase: Binding<Int>
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
                .frame(width: 140)
                
                EnumPickerView(
                    selection: sync,
                    label: "Sync"
                )
                .frame(width: 120)
                
                Toggle("Key Sync", isOn: keySync)
                    .toggleStyle(.checkbox)
                    .frame(width: 100)
            }
            
            // Rate Control
            HStack(spacing: 16) {
                KnobView(
                    value: rate,
                    range: viewModel.rateRange,
                    label: "Rate",
                    color: .blue,
                    size: 80
                )
                
                // LFO Waveform Visualization
                lfoWaveformView(waveform: waveform.wrappedValue, rate: rate.wrappedValue)
                    .frame(width: 120, height: 60)
            }
            
            // Timing Controls
            HStack(spacing: 16) {
                KnobView(
                    value: delay,
                    range: viewModel.timingRange,
                    label: "Delay",
                    color: .green,
                    size: 60
                )
                
                KnobView(
                    value: fade,
                    range: viewModel.timingRange,
                    label: "Fade",
                    color: .orange,
                    size: 60
                )
                
                KnobView(
                    value: phase,
                    range: viewModel.timingRange,
                    label: "Phase",
                    color: .purple,
                    size: 60
                )
            }
        }
    }
    
    // MARK: - LFO Waveform Visualization
    
    @ViewBuilder
    private func lfoWaveformView(waveform: LFOWaveform, rate: Int) -> some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let centerY = height / 2
            
            // Draw waveform
            Path { path in
                let segments = 100
                for i in 0...segments {
                    let x = width * Double(i) / Double(segments)
                    let progress = Double(i) / Double(segments)
                    let y = centerY - height * 0.4 * waveformValue(waveform: waveform, progress: progress)
                    
                    if i == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color.accentColor, lineWidth: 2)
            
            // Rate indicator
            VStack {
                Spacer()
                Text("Rate: $0".replacingOccurrences(of: "$0", with: "\(rate)"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Waveform Value Calculation
    
    private func waveformValue(waveform: LFOWaveform, progress: Double) -> Double {
        switch waveform {
        case .sine:
            return sin(2 * .pi * progress)
        case .triangle:
            return 2 * abs(progress.truncatingRemainder(dividingBy: 1.0) - 0.5) - 0.5
        case .square:
            return progress.truncatingRemainder(dividingBy: 1.0) < 0.5 ? -1 : 1
        case .sawtooth:
            return 2 * (progress.truncatingRemainder(dividingBy: 1.0) - 0.5)
        case .reverseSawtooth:
            return -2 * (progress.truncatingRemainder(dividingBy: 1.0) - 0.5)
        case .random:
            return Double.random(in: -1...1)
        }
    }
}

// MARK: - Preview

#Preview {
    let program = Program.newProgram()
    let viewModel = LFOEditorViewModel(program: program)
    return LFOEditorView(viewModel: viewModel)
        .frame(width: 800, height: 600)
}
