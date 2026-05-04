// Bank.swift
// MonstaGuru
// Created by Mistral Vibe Code (Core Data Model Agent)

import Foundation
import SwiftData

/// Represents a bank of presets for the MicroMonsta 2.
/// Banks are collections of presets that can be saved/loaded as a group.
@Model
public final class Bank: Identifiable, Hashable {
    /// Unique identifier for the bank.
    @Attribute(.unique) public var id: UUID
    
    /// Bank name (user-editable).
    public var name: String
    
    /// Date when the bank was created.
    public var createdAt: Date
    
    /// Date when the bank was last modified.
    public var updatedAt: Date
    
    /// Color for UI representation (stored as hex string).
    public var color: String
    
    /// The presets in this bank (ordered).
    @Relationship(deleteRule: .nullify, inverse: \Preset.bank)
    public var presets: [Preset]
    
    // MARK: - Initialization
    
    public init(
        id: UUID = UUID(),
        name: String = "Untitled Bank",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        color: String = "#333333",
        presets: [Preset] = []
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.color = color
        self.presets = presets
    }
    
    // MARK: - Computed Properties
    
    /// Returns a formatted string for display.
    public var displayName: String {
        return name.isEmpty ? "Untitled Bank" : name
    }
    
    /// Returns the number of presets in the bank.
    public var presetCount: Int {
        return presets.count
    }
    
    // MARK: - Hashable Conformance
    
    public static func == (lhs: Bank, rhs: Bank) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Default Values

public extension Bank {
    /// Creates a default bank.
    static var `default`: Bank {
        return Bank()
    }
    
    /// Creates a new bank with a unique name based on the current date.
    static func newBank() -> Bank {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let timestamp = dateFormatter.string(from: Date())
        return Bank(name: "Bank " + timestamp)
    }
    
    /// Updates the `updatedAt` timestamp to the current date.
    public func touch() {
        updatedAt = Date()
    }
    
    /// Adds a preset to the bank.
    public func addPreset(_ preset: Preset) {
        presets.append(preset)
        updatedAt = Date()
    }
    
    /// Removes a preset from the bank.
    public func removePreset(_ preset: Preset) {
        presets.removeAll { $0.id == preset.id }
        updatedAt = Date()
    }
    
    /// Reorders presets in the bank.
    public func reorderPresets(from oldIndices: IndexSet, to newIndex: Int) {
        presets.move(fromOffsets: oldIndices, toOffset: newIndex)
        updatedAt = Date()
    }
}


