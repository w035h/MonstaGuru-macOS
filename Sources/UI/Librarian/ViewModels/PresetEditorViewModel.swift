// PresetEditorViewModel.swift
// MonstaGuru
// Created by Mistral Vibe Code (Librarian Agent)

import Foundation
import SwiftUI
import Combine
import Data

/// ViewModel for editing preset properties.
public final class PresetEditorViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// The preset being edited.
    @Published public var preset: Preset
    
    /// Preset name.
    @Published public var name: String
    
    /// Preset author.
    @Published public var author: String
    
    /// Preset tags (comma-separated string for editing).
    @Published public var tagsString: String
    
    /// Preset rating (0-5).
    @Published public var rating: Int
    
    /// Preset notes.
    @Published public var notes: String
    
    /// Preset color (hex string).
    @Published public var color: String
    
    /// Whether the preset is being created (not yet saved).
    @Published public var isNewPreset: Bool
    
    // MARK: - Public Properties
    
    /// The preset repository for data operations.
    public let presetRepository: PresetRepositoryProtocol
    
    /// The bank repository for accessing bank data.
    public let bankRepository: BankRepositoryProtocol
    
    // MARK: - Computed Properties
    
    /// Color as a SwiftUI Color.
    public var swiftUIColor: Color {
        Color(hex: color)
    }
    
    /// Available colors for preset selection.
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
    
    /// Tags as an array.
    public var tags: [String] {
        tagsString
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    /// All available tags from the library.
    public var allAvailableTags: [String] {
        do {
            let banks = try bankRepository.fetchAll()
            var allTags = Set<String>()
            for bank in banks {
                for preset in bank.presets {
                    allTags.formUnion(Set(preset.tags))
                }
            }
            return Array(allTags).sorted()
        } catch {
            return []
        }
    }
    
    // MARK: - Initialization
    
    public init(
        preset: Preset? = nil,
        presetRepository: PresetRepositoryProtocol = PresetRepository(modelContext: try! ModelContext(ModelContainer(for: Preset.self))),
        bankRepository: BankRepositoryProtocol = BankRepository(modelContext: try! ModelContext(ModelContainer(for: Bank.self)))
    ) {
        self.presetRepository = presetRepository
        self.bankRepository = bankRepository
        
        if let preset = preset {
            self.preset = preset
            self.name = preset.name
            self.author = preset.author
            self.tagsString = preset.tags.joined(separator: ", ")
            self.rating = preset.rating
            self.notes = preset.notes
            self.color = preset.color
            self.isNewPreset = false
        } else {
            self.preset = Preset.newPreset()
            self.name = "Untitled Preset"
            self.author = "Unknown"
            self.tagsString = ""
            self.rating = 0
            self.notes = ""
            self.color = "#4A90E2"
            self.isNewPreset = true
        }
    }
    
    // MARK: - Save
    
    /// Saves the preset.
    public func save() throws {
        preset.name = name
        preset.author = author
        preset.tags = tags
        preset.rating = rating
        preset.notes = notes
        preset.color = color
        preset.updatedAt = Date()
        
        if isNewPreset {
            try presetRepository.save(preset)
            isNewPreset = false
        } else {
            try presetRepository.save(preset)
        }
    }
    
    // MARK: - Validation
    
    /// Validates the preset data.
    public func validate() -> Bool {
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Returns validation error message if any.
    public func validationError() -> String? {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Preset name cannot be empty"
        }
        return nil
    }
    
    // MARK: - Tag Management
    
    /// Adds a tag to the preset.
    public func addTag(_ tag: String) {
        var currentTags = tags
        if !currentTags.contains(tag) {
            currentTags.append(tag)
            tagsString = currentTags.joined(separator: ", ")
        }
    }
    
    /// Removes a tag from the preset.
    public func removeTag(_ tag: String) {
        var currentTags = tags
        currentTags.removeAll { $0 == tag }
        tagsString = currentTags.joined(separator: ", ")
    }
    
    /// Sets the tags from an array.
    public func setTags(_ tags: [String]) {
        tagsString = tags.joined(separator: ", ")
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
