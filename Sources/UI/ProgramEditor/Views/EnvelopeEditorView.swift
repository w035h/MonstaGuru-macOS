// EnvelopeEditorView.swift
// MonstaGuru
// Created by Mistral Vibe Code (Program Editor Agent)

import SwiftUI
import Data

/// View for editing envelope parameters.
public struct EnvelopeEditorView: View {
    
    @ObservedObject public var viewModel: EnvelopeEditorViewModel
    
    // MARK: - Body
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Envelope 1
                envelopeSectionView(
                    title: "Envelope 1",
                    attack: $viewModel.env1Attack,
                    decay: $viewModel.env1Decay,
                    sustain: $viewModel.env1Sustain,
                    release: $viewModel.env1Release,
                    velocitySensitivity: $viewModel.env1VelocitySensitivity,
                    keyTrack: $viewModel.env1KeyTrack
                )
                
                Divider()
                
                // Envelope 2
                envelopeSectionView(
                    title: "Envelope 2",
                    attack: $viewModel.env2Attack,
                    decay: $viewModel.env2Decay,
                    sustain: $viewModel.env2Sustain,
                    release: $viewModel.env2Release,
                    velocitySensitivity: $viewModel.env2VelocitySensitivity,
                    keyTrack: $viewModel.env2KeyTrack
                )
                
                Divider()
                
                // Envelope 3
                envelopeSectionView(
                    title: "Envelope 3",
                    attack: $viewModel.env3Attack,
                    decay: $viewModel.env3Decay,
                    sustain: $viewModel.env3Sustain,
                    release: $viewModel.env3Release,
                    velocitySensitivity: $viewModel.env3VelocitySensitivity,
                    keyTrack: $viewModel.env3KeyTrack
                )
            }
            .padding()
        }
        .navigationTitle("Envelopes")
    }
    
    // MARK: - Envelope Section View
    
    @ViewBuilder
    private func envelopeSectionView(
        title: String,
        attack: Binding<Int>,
        decay: Binding<Int>,
        sustain: Binding<Int>,
        release: Binding<Int>,
        velocitySensitivity: Binding<Int>,
        keyTrack: Binding<Int>
    ) -> some View {
        VStack(spacing: 16) {
            // Section Header
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // ADSR Controls
            HStack(spacing: 16) {
                KnobView(
                    value: attack,
                    range: viewModel.adsrRange,
                    label: "Attack",
                    color: .green,
                    size: 70,
                    valueFormatter: viewModel.formattedADSRValue
                )
                
                KnobView(
                    value: decay,
                    range: viewModel.adsrRange,
                    label: "Decay",
                    color: .orange,
                    size: 70,
                    valueFormatter: viewModel.formattedADSRValue
                )
                
                KnobView(
                    value: sustain,
                    range: viewModel.adsrRange,
                    label: "Sustain",
                    color: .blue,
                    size: 70,
                    valueFormatter: viewModel.formattedADSRValue
                )
                
                KnobView(
                    value: release,
                    range: viewModel.adsrRange,
                    label: "Release",
                    color: .red,
                    size: 70,
                    valueFormatter: viewModel.formattedADSRValue
                )
            }
            
            // Modulation Controls
            HStack(spacing: 16) {
                KnobView(
                    value: velocitySensitivity,
                    range: viewModel.adsrRange,
                    label: "Vel Sens",
                    color: .purple,
                    size: 60,
                    valueFormatter: viewModel.formattedADSRValue
                )
                
                KnobView(
                    value: keyTrack,
                    range: viewModel.adsrRange,
                    label: "Key Track",
                    color: .purple,
                    size: 60,
                    valueFormatter: viewModel.formattedADSRValue
                )
            }
            
            // ADSR Graph Visualization
            adsrGraphView(
                attack: attack.wrappedValue,
                decay: decay.wrappedValue,
                sustain: sustain.wrappedValue,
                release: release.wrappedValue
            )
            .frame(height: 80)
        }
    }
    
    // MARK: - ADSR Graph View
    
    @ViewBuilder
    private func adsrGraphView(attack: Int, decay: Int, sustain: Int, release: Int) -> some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            // Normalize values to 0-1 range
            let attackNorm = Double(attack) / 127.0
            let decayNorm = Double(decay) / 127.0
            let sustainNorm = Double(sustain) / 127.0
            let releaseNorm = Double(release) / 127.0
            
            // Calculate points
            let attackPoint = CGPoint(x: width * attackNorm, y: 0)
            let decayPoint = CGPoint(x: width * (attackNorm + decayNorm * 0.5), y: height * (1.0 - sustainNorm))
            let sustainPoint = CGPoint(x: width * (attackNorm + decayNorm * 0.5 + 0.2), y: height * (1.0 - sustainNorm))
            let releasePoint = CGPoint(x: width, y: height)
            
            Path { path in
                path.move(to: CGPoint(x: 0, y: height))
                path.addLine(to: attackPoint)
                path.addLine(to: decayPoint)
                path.addLine(to: sustainPoint)
                path.addLine(to: releasePoint)
            }
            .stroke(Color.accentColor, lineWidth: 2)
            
            // Labels
            VStack(alignment: .leading, spacing: 4) {
                Text("A")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .offset(x: width * attackNorm, y: -4)
                
                Text("D")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .offset(x: width * (attackNorm + decayNorm * 0.5), y: -4)
                
                Text("S")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .offset(x: width * (attackNorm + decayNorm * 0.5 + 0.2), y: -4)
                
                Text("R")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .offset(x: width, y: -4)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let program = Program.newProgram()
    let viewModel = EnvelopeEditorViewModel(program: program)
    return EnvelopeEditorView(viewModel: viewModel)
        .frame(width: 800, height: 700)
}
