// ClipboardEntry.swift
// MonstaGuru
// Created by Mistral Vibe Code (Core Data Model Agent)

import Foundation
import SwiftData

/// Types of data that can be stored in the clipboard.
public enum ClipboardEntryType: Int, Codable, CaseIterable, Identifiable {
    case program
    case oscillator
    case filter
    case envelope
    case lfo
    case matrixSlot
    case effects
    case globalSettings
    case mixer
    
    public var id: Self { self }
    
    /// Localized display name for the entry type.
    public var displayName: String {
        switch self {
        case .program: return "Program"
        case .oscillator: return "Oscillator"
        case .filter: return "Filter"
        case .envelope: return "Envelope"
        case .lfo: return "LFO"
        case .matrixSlot: return "Matrix Slot"
        case .effects: return "Effects"
        case .globalSettings: return "Global Settings"
        case .mixer: return "Mixer"
        }
    }
}

/// Represents an entry in the persistent clipboard.
/// Clipboard entries store copies of program sections for copy/paste operations.
@Model
public final class ClipboardEntry: Identifiable, Hashable {
    /// Unique identifier for the clipboard entry.
    @Attribute(.unique) public var id: UUID
    
    /// Type of data stored in this entry.
    public var type: ClipboardEntryType
    
    /// Name for the entry (user-editable).
    public var name: String
    
    /// The actual data stored in the entry (encoded as Data).
    public var data: Data
    
    /// Date when the entry was created.
    public var createdAt: Date
    
    /// Color for UI representation (stored as hex string).
    public var color: String
    
    /// Notes for the entry.
    public var notes: String
    
    // MARK: - Initialization
    
    public init(
        id: UUID = UUID(),
        type: ClipboardEntryType,
        name: String = "Untitled",
        data: Data,
        createdAt: Date = Date(),
        color: String = "#888888",
        notes: String = ""
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.data = data
        self.createdAt = createdAt
        self.color = color
        self.notes = notes
    }
    
    // MARK: - Computed Properties
    
    /// Returns a formatted string for display.
    public var displayName: String {
        return name.isEmpty ? type.displayName : name
    }
    
    /// Returns a formatted date string.
    public var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
    
    /// Returns a human-readable size description.
    public var sizeDescription: String {
        let sizeInKB = Double(data.count) / 1024.0
        if sizeInKB < 1 {
            return "\(data.count) bytes"
        } else if sizeInKB < 1024 {
            return String(format: "%.1f KB", sizeInKB)
        } else {
            let sizeInMB = sizeInKB / 1024.0
            return String(format: "%.1f MB", sizeInMB)
        }
    }
    
    // MARK: - Hashable Conformance
    
    public static func == (lhs: ClipboardEntry, rhs: ClipboardEntry) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - ClipboardEntry Extensions

public extension ClipboardEntry {
    /// Creates a clipboard entry from a program.
    static func fromProgram(_ program: Program, name: String? = nil) -> ClipboardEntry {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(program)
        return ClipboardEntry(
            type: .program,
            name: name ?? program.name,
            data: data
        )
    }
    
    /// Creates a clipboard entry from an oscillator.
    static func fromOscillator(_ oscillator: Oscillator, name: String? = nil) -> ClipboardEntry {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(oscillator)
        return ClipboardEntry(
            type: .oscillator,
            name: name ?? "Oscillator \(oscillator.index)",
            data: data
        )
    }
    
    /// Creates a clipboard entry from a filter.
    static func fromFilter(_ filter: Filter, name: String? = nil) -> ClipboardEntry {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(filter)
        return ClipboardEntry(
            type: .filter,
            name: name ?? "Filter \(filter.index)",
            data: data
        )
    }
    
    /// Creates a clipboard entry from an envelope.
    static func fromEnvelope(_ envelope: Envelope, name: String? = nil) -> ClipboardEntry {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(envelope)
        return ClipboardEntry(
            type: .envelope,
            name: name ?? "Envelope \(envelope.index)",
            data: data
        )
    }
    
    /// Creates a clipboard entry from an LFO.
    static func fromLFO(_ lfo: LFO, name: String? = nil) -> ClipboardEntry {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(lfo)
        return ClipboardEntry(
            type: .lfo,
            name: name ?? "LFO \(lfo.index)",
            data: data
        )
    }
    
    /// Creates a clipboard entry from a matrix slot.
    static func fromMatrixSlot(_ slot: MatrixSlot, name: String? = nil) -> ClipboardEntry {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(slot)
        return ClipboardEntry(
            type: .matrixSlot,
            name: name ?? "Matrix Slot \(slot.index)",
            data: data
        )
    }
    
    /// Creates a clipboard entry from effects.
    static func fromEffects(_ effects: Effects, name: String? = nil) -> ClipboardEntry {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(effects)
        return ClipboardEntry(
            type: .effects,
            name: name ?? "Effects",
            data: data
        )
    }
    
    /// Creates a clipboard entry from global settings.
    static func fromGlobalSettings(_ global: GlobalSettings, name: String? = nil) -> ClipboardEntry {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(global)
        return ClipboardEntry(
            type: .globalSettings,
            name: name ?? "Global Settings",
            data: data
        )
    }
    
    /// Creates a clipboard entry from mixer settings.
    static func fromMixer(_ mixer: Mixer, name: String? = nil) -> ClipboardEntry {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(mixer)
        return ClipboardEntry(
            type: .mixer,
            name: name ?? "Mixer",
            data: data
        )
    }
    
    /// Decodes and returns the stored data as the specified type.
    public func decode<T: Decodable>() -> T? {
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: data)
    }
}
