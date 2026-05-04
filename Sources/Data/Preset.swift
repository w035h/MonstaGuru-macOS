// Preset.swift
// MonstaGuru
// Created by Mistral Vibe Code (Core Data Model Agent)

import Foundation
import SwiftData

/// Represents a named preset that references a Program.
/// Presets are user-created snapshots of programs with metadata.
@Model
public final class Preset: Identifiable, Hashable {
    /// Unique identifier for the preset.
    @Attribute(.unique) public var id: UUID
    
    /// Preset name (user-editable).
    public var name: String
    
    /// Author of the preset.
    public var author: String
    
    /// Date when the preset was created.
    public var createdAt: Date
    
    /// Date when the preset was last modified.
    public var updatedAt: Date
    
    /// Tags for categorizing the preset.
    public var tags: [String]
    
    /// Rating (0-5 stars).
    public var rating: Int
    
    /// Notes/description for the preset.
    public var notes: String
    
    /// The program data associated with this preset.
    public var program: Program?
    
    /// Color for UI representation (stored as hex string, e.g., "#FF5733").
    public var color: String
    
    /// The bank this preset belongs to (optional).
    @Relationship(deleteRule: .nullify, inverse: \Bank.presets)
    public var bank: Bank?
    
    // MARK: - Initialization
    
    public init(
        id: UUID = UUID(),
        name: String = "Untitled",
        author: String = "Unknown",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        tags: [String] = [],
        rating: Int = 0,
        notes: String = "",
        program: Program? = nil,
        color: String = "#4A90E2"
    ) {
        self.id = id
        self.name = name
        self.author = author
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tags = tags
        self.rating = rating.clamped(to: 0...5)
        self.notes = notes
        self.program = program
        self.color = color
    }
    
    // MARK: - Computed Properties
    
    /// Returns a formatted string for display.
    public var displayName: String {
        return name.isEmpty ? "Untitled" : name
    }
    
    /// Returns the first tag if available, otherwise "No Tags".
    public var firstTag: String {
        return tags.first ?? "No Tags"
    }
    
    // MARK: - Hashable Conformance
    
    public static func == (lhs: Preset, rhs: Preset) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Default Values

public extension Preset {
    /// Creates a default preset.
    static var `default`: Preset {
        return Preset()
    }
    
    /// Creates a new preset with a unique name based on the current date.
    static func newPreset(program: Program? = nil) -> Preset {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let timestamp = dateFormatter.string(from: Date())
        return Preset(
            name: "Preset " + timestamp,
            program: program
        )
    }
    
    /// Updates the `updatedAt` timestamp to the current date.
    public func touch() {
        updatedAt = Date()
    }
}

// MARK: - Helper Extensions

private extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
