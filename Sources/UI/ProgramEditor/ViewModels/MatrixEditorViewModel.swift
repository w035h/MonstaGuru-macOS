// MatrixEditorViewModel.swift
// MonstaGuru
// Created by Mistral Vibe Code (Program Editor Agent)

import Foundation
import SwiftUI
import Combine
import Data

/// ViewModel for editing modulation matrix parameters.
public final class MatrixEditorViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// The program being edited.
    @Published public var program: Program {
        didSet {
            updateMatrixBindings()
        }
    }
    
    // MARK: - Matrix Slots (12 slots for MicroMonsta 2)
    @Published public var matrixSlots: [MatrixSlotViewModel] = []
    
    // MARK: - Initialization
    
    public init(program: Program) {
        self.program = program
        updateMatrixBindings()
    }
    
    // MARK: - Binding Updates
    
    private func updateMatrixBindings() {
        matrixSlots = program.matrix.enumerated().map { index, slot in
            MatrixSlotViewModel(
                index: index,
                source: slot.source,
                destination: slot.destination,
                amount: slot.amount
            )
        }
    }
    
    // MARK: - Matrix Slot Access
    
    /// Returns the matrix slot at the specified index.
    public func matrixSlot(at index: Int) -> MatrixSlot {
        guard index >= 0 && index < program.matrix.count else {
            return .default(index: index)
        }
        return program.matrix[index]
    }
    
    /// Updates a matrix slot at the specified index.
    public func updateMatrixSlot(_ slot: MatrixSlot, at index: Int) {
        guard index >= 0 && index < program.matrix.count else { return }
        program.matrix[index] = slot
        updateMatrixBindings()
    }
    
    // MARK: - Common Parameters
    
    /// Returns the available source types.
    public var sourceTypes: [MatrixSource] {
        return Array(MatrixSource.allCases)
    }
    
    /// Returns the available destination types.
    public var destinationTypes: [MatrixDestination] {
        return Array(MatrixDestination.allCases)
    }
    
    /// Returns the amount range (signed).
    public var amountRange: ClosedRange<Int> {
        return -64...63
    }
    
    // MARK: - Formatted Values
    
    /// Formats an amount value for display.
    public func formattedAmount(_ value: Int) -> String {
        if value > 0 {
            return "+$0"
        } else if value < 0 {
            return "$0"
        } else {
            return "0"
        }
    }
}

/// ViewModel for a single matrix slot.
public struct MatrixSlotViewModel: Identifiable {
    public let id: Int
    public var source: MatrixSource
    public var destination: MatrixDestination
    public var amount: Int
    
    public init(
        index: Int,
        source: MatrixSource,
        destination: MatrixDestination,
        amount: Int
    ) {
        self.id = index
        self.source = source
        self.destination = destination
        self.amount = amount
    }
}
