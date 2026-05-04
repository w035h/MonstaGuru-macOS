// ProgramEditorView.swift
// MonstaGuru
// Created by Mistral Vibe Code (Program Editor Agent)

import SwiftUI
import Data
import MIDI

/// Main view for editing MicroMonsta 2 programs.
public struct ProgramEditorView: View {
    
    @StateObject private var viewModel: ProgramEditorViewModel
    
    // MARK: - Initialization
    
    public init(viewModel: ProgramEditorViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            toolbarView
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.windowBackgroundColor))
                .border(Color.separator, width: 1)
            
            // Program Header
            programHeaderView
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.controlBackgroundColor))
                .border(Color.separator, width: 1)
            
            // Tab View
            TabView(selection: $viewModel.selectedTab) {
                OscillatorEditorView(viewModel: viewModel.oscillatorViewModel)
                    .tabItem {
                        Label("Oscillators", systemImage: "waveform")
                    }
                    .tag(ProgramEditorViewModel.EditorTab.oscillators)
                
                MixerEditorView(viewModel: viewModel.mixerViewModel)
                    .tabItem {
                        Label("Mixer", systemImage: "slider.horizontal.3")
                    }
                    .tag(ProgramEditorViewModel.EditorTab.mixer)
                
                FilterEditorView(viewModel: viewModel.filterViewModel)
                    .tabItem {
                        Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                    }
                    .tag(ProgramEditorViewModel.EditorTab.filters)
                
                EnvelopeEditorView(viewModel: viewModel.envelopeViewModel)
                    .tabItem {
                        Label("Envelopes", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    .tag(ProgramEditorViewModel.EditorTab.envelopes)
                
                LFOEditorView(viewModel: viewModel.lfoViewModel)
                    .tabItem {
                        Label("LFOs", systemImage: "waveform.sine.inverse")
                    }
                    .tag(ProgramEditorViewModel.EditorTab.lfos)
                
                MatrixEditorView(viewModel: viewModel.matrixViewModel)
                    .tabItem {
                        Label("Matrix", systemImage: "square.grid.3x3")
                    }
                    .tag(ProgramEditorViewModel.EditorTab.matrix)
                
                EffectsEditorView(viewModel: viewModel.effectsViewModel)
                    .tabItem {
                        Label("Effects", systemImage: "speaker.wave.3")
                    }
                    .tag(ProgramEditorViewModel.EditorTab.effects)
                
                GlobalEditorView(viewModel: viewModel.globalViewModel)
                    .tabItem {
                        Label("Global", systemImage: "gear")
                    }
                    .tag(ProgramEditorViewModel.EditorTab.global)
            }
            .tabViewStyle(.toolbar)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .frame(minWidth: 800, minHeight: 600)
        .navigationTitle("Program Editor")
        .onAppear {
            viewModel.setupMIDIManager()
        }
        .onDisappear {
            // Clean up if needed
        }
    }
    
    // MARK: - Toolbar View
    
    private var toolbarView: some View {
        HStack(spacing: 16) {
            // Save Button
            Button(action: {
                try? viewModel.saveProgram()
            }) {
                Label("Save", systemImage: "square.and.arrow.down")
            }
            .keyboardShortcut("s", modifiers: [.command])
            .disabled(!viewModel.hasUnsavedChanges)
            .help("Save Program (Cmd+S)")
            
            // Revert Button
            Button(action: {
                viewModel.revertProgram()
            }) {
                Label("Revert", systemImage: "arrow.uturn.backward")
            }
            .keyboardShortcut("z", modifiers: [.command])
            .disabled(!viewModel.hasUnsavedChanges)
            .help("Revert Changes (Cmd+Z)")
            
            Spacer()
            
            // MIDI Status
            HStack(spacing: 8) {
                if viewModel.isMIDIConnected {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("MIDI Connected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                    Text("MIDI Disconnected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Send to Hardware Button
            Button(action: {
                try? viewModel.sendProgramToHardware()
            }) {
                Label("Send to Hardware", systemImage: "arrow.up.square")
            }
            .keyboardShortcut("e", modifiers: [.command, .shift])
            .disabled(!viewModel.isMIDIConnected)
            .help("Send to Hardware (Cmd+Shift+E)")
            
            // Request from Hardware Button
            Button(action: {
                try? viewModel.requestProgramFromHardware()
            }) {
                Label("Get from Hardware", systemImage: "arrow.down.square")
            }
            .keyboardShortcut("e", modifiers: [.command, .option])
            .disabled(!viewModel.isMIDIConnected)
            .help("Get from Hardware (Cmd+Opt+E)")
        }
    }
    
    // MARK: - Program Header View
    
    private var programHeaderView: some View {
        HStack(spacing: 16) {
            // Program Name
            TextField("Program Name", text: Binding(
                get: { viewModel.program.name },
                set: { newValue in
                    viewModel.program.name = newValue
                    viewModel.hasUnsavedChanges = true
                }
            ))
            .textFieldStyle(.roundedBorder)
            .frame(width: 200)
            
            // Program Number
            StepperView(
                value: Binding(
                    get: { viewModel.program.number },
                    set: { newValue in
                        viewModel.program.number = newValue
                        viewModel.hasUnsavedChanges = true
                    }
                ),
                range: 0...127,
                label: "Program",
                valueFormatter: { "#$0" }
            )
            .frame(width: 120)
            
            // Unsaved Changes Indicator
            if viewModel.hasUnsavedChanges {
                Spacer()
                Text("* Unsaved Changes")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let program = Program.newProgram()
    let viewModel = ProgramEditorViewModel(program: program)
    return ProgramEditorView(viewModel: viewModel)
        .frame(width: 1000, height: 800)
}
