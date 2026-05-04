// BankEditorViewModel.swift
// MonstaGuru
// Created by Mistral Vibe Code (Librarian Agent)

import Foundation
import SwiftUI
import Combine
import Data

/// ViewModel for editing bank properties.
public final class BankEditorViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// The bank being edited.
    @Published public var bank: Bank
    
    /// Bank name.
    @Published public var name: String
    
    /// Bank color (hex string).
    @Published public var color: String
    
    /// Whether the bank is being created (not yet saved).
    @Published public var isNewBank: Bool
    
    // MARK: - Public Properties
    
    /// The bank repository for data operations.
    public let bankRepository: BankRepositoryProtocol
    
    // MARK: - Computed Properties
    
    /// Color as a SwiftUI Color.
    public var swiftUIColor: Color {
        Color(hex: color)
    }
    
    /// Available colors for bank selection.
    public var availableColors: [String] {
        [
            "#FF5733", // Red-Orange
            "#33FF57", // Green
            "#3357FF", // Blue
            "#F3FF33", // Yellow
            "#FF33F3", // Magenta
            "#33FFF3", // Cyan
            "#8A2BE2", // Purple
            "#FF6347", // Tomato
            "#7FFFD4", // Aquamarine
            "#FFD700", // Gold
            "#9370DB", // Medium Purple
            "#32CD32", // Lime Green
            "#FF4500", // Orange Red
            "#6495ED", // Cornflower Blue
            "#DC143C", // Crimson
            "#20B2AA"  // Light Sea Green
        ]
    }
    
    // MARK: - Initialization
    
    public init(
        bank: Bank? = nil,
        bankRepository: BankRepositoryProtocol = BankRepository(modelContext: try! ModelContext(ModelContainer(for: Bank.self)))
    ) {
        self.bankRepository = bankRepository
        
        if let bank = bank {
            self.bank = bank
            self.name = bank.name
            self.color = bank.color
            self.isNewBank = false
        } else {
            self.bank = Bank.newBank()
            self.name = "Untitled Bank"
            self.color = "#333333"
            self.isNewBank = true
        }
    }
    
    // MARK: - Save
    
    /// Saves the bank.
    public func save() throws {
        bank.name = name
        bank.color = color
        
        if isNewBank {
            try bankRepository.save(bank)
            isNewBank = false
        } else {
            try bankRepository.save(bank)
        }
    }
    
    // MARK: - Validation
    
    /// Validates the bank data.
    public func validate() -> Bool {
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Returns validation error message if any.
    public func validationError() -> String? {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Bank name cannot be empty"
        }
        return nil
    }
}

// MARK: - Color Extension

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
