// MatrixEditorView.swift
// MonstaGuru
// Created by Mistral Vibe Code (Program Editor Agent)

import SwiftUI
import Data

/// View for editing modulation matrix parameters.
public struct MatrixEditorView: View {
    
    @ObservedObject public var viewModel: MatrixEditorViewModel
    
    // MARK: - Body
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Matrix Header
                Text("Modulation Matrix")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Matrix Grid
                matrixGridView
                
                // Matrix List
                matrixListView
            }
            .padding()
        }
        .navigationTitle("Matrix")
    }
    
    // MARK: - Matrix Grid View
    
    private var matrixGridView: some View {
        VStack(spacing: 8) {
            // Column Headers
            HStack(spacing: 8) {
                Text("Slot")
                    .frame(width: 40, alignment: .center)
                    .font(.caption)
                    .fontWeight(.bold)
                
                Text("Source")
                    .frame(width: 120, alignment: .leading)
                    .font(.caption)
                    .fontWeight(.bold)
                
                Text("Destination")
                    .frame(width: 120, alignment: .leading)
                    .font(.caption)
                    .fontWeight(.bold)
                
                Text("Amount")
                    .frame(width: 80, alignment: .center)
                    .font(.caption)
                    .fontWeight(.bold)
            }
            .padding(.vertical, 4)
            
            // Rows
            ForEach(0..<12, id: \.self) { index in
                matrixRowView(index: index)
            }
        }
    }
    
    // MARK: - Matrix Row View
    
    @ViewBuilder
    private func matrixRowView(index: Int) -> some View {
        HStack(spacing: 8) {
            // Slot Number
            Text("#$0".replacingOccurrences(of: "$0", with: "\(index + 1)"))
                .frame(width: 40, alignment: .center)
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Source Picker
            EnumPickerView(
                selection: Binding(
                    get: { viewModel.matrixSlots[index].source },
                    set: { newValue in
                        var slot = viewModel.matrixSlots[index]
                        slot.source = newValue
                        viewModel.matrixSlots[index] = slot
                        updateMatrixSlot(index: index)
                    }
                ),
                label: ""
            )
            .frame(width: 120)
            
            // Destination Picker
            EnumPickerView(
                selection: Binding(
                    get: { viewModel.matrixSlots[index].destination },
                    set: { newValue in
                        var slot = viewModel.matrixSlots[index]
                        slot.destination = newValue
                        viewModel.matrixSlots[index] = slot
                        updateMatrixSlot(index: index)
                    }
                ),
                label: ""
            )
            .frame(width: 120)
            
            // Amount Knob
            KnobView(
                value: Binding(
                    get: { viewModel.matrixSlots[index].amount },
                    set: { newValue in
                        var slot = viewModel.matrixSlots[index]
                        slot.amount = newValue
                        viewModel.matrixSlots[index] = slot
                        updateMatrixSlot(index: index)
                    }
                ),
                range: viewModel.amountRange,
                label: "",
                color: .accentColor,
                size: 40,
                showValue: false,
                valueFormatter: viewModel.formattedAmount
            )
            
            // Amount Value Display
            Text(viewModel.formattedAmount(viewModel.matrixSlots[index].amount))
                .frame(width: 40, alignment: .center)
                .font(.caption)
                .monospacedDigit()
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Matrix List View
    
    private var matrixListView: some View {
        VStack(spacing: 12) {
            Text("Active Modulations")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(0..<12, id: \.self) { index in
                let slot = viewModel.matrixSlots[index]
                if slot.source != .off && slot.destination != .off && slot.amount != 0 {
                    matrixSlotCardView(index: index, slot: slot)
                }
            }
        }
    }
    
    // MARK: - Matrix Slot Card View
    
    @ViewBuilder
    private func matrixSlotCardView(index: Int, slot: MatrixSlotViewModel) -> some View {
        HStack(spacing: 12) {
            // Slot Info
            VStack(alignment: .leading, spacing: 4) {
                Text("Slot $0".replacingOccurrences(of: "$0", with: "\(index + 1)"))
                    .font(.caption)
                    .fontWeight(.bold)
                
                Text("Source: $0".replacingOccurrences(of: "$0", with: "\(slot.source.displayName)"))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Destination: $0".replacingOccurrences(of: "$0", with: "\(slot.destination.displayName)"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Amount Control
            KnobView(
                value: Binding(
                    get: { slot.amount },
                    set: { newValue in
                        var updatedSlot = viewModel.matrixSlots[index]
                        updatedSlot.amount = newValue
                        viewModel.matrixSlots[index] = updatedSlot
                        updateMatrixSlot(index: index)
                    }
                ),
                range: viewModel.amountRange,
                label: "Amount",
                color: .accentColor,
                size: 50,
                valueFormatter: viewModel.formattedAmount
            )
        }
        .padding(12)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.separator, lineWidth: 1)
        )
    }
    
    // MARK: - Update Matrix Slot
    
    private func updateMatrixSlot(index: Int) {
        let slot = viewModel.matrixSlots[index]
        let matrixSlot = MatrixSlot(
            index: index + 1,
            source: slot.source,
            destination: slot.destination,
            amount: slot.amount
        )
        viewModel.updateMatrixSlot(matrixSlot, at: index)
    }
}

// MARK: - Preview

#Preview {
    let program = Program.newProgram()
    let viewModel = MatrixEditorViewModel(program: program)
    return MatrixEditorView(viewModel: viewModel)
        .frame(width: 800, height: 600)
}
