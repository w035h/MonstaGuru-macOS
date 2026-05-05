// MIDISetting.swift
// MonstaGuru
// Created by Mistral Vibe Code (Core Data Model Agent)

import Foundation
import SwiftData

/// Represents MIDI device configuration for the MicroMonsta 2.
/// Stores input/output device selections and channel settings.
@Model
public final class MIDISetting: Identifiable, Hashable {
    /// Unique identifier for the MIDI setting.
    @Attribute(.unique) public var id: UUID
    
    /// Name for this MIDI configuration (user-editable).
    public var name: String
    
    /// MIDI input device name (e.g., "MicroMonsta 2" or "IAC Driver Bus 1").
    public var inputDeviceName: String
    
    /// MIDI output device name (e.g., "MicroMonsta 2" or "IAC Driver Bus 1").
    public var outputDeviceName: String
    
    /// MIDI channel for program changes (1-16, 0 = Omni).
    public var programChangeChannel: Int
    
    /// MIDI channel for note data (1-16, 0 = Omni).
    public var noteChannel: Int
    
    /// Enable MIDI thru (echoes input to output).
    public var midiThruEnabled: Bool
    
    /// Enable SysEx reception.
    public var sysexEnabled: Bool
    
    /// Enable SysEx transmission.
    public var sysexTransmitEnabled: Bool
    
    /// Date when the setting was created.
    public var createdAt: Date
    
    /// Date when the setting was last modified.
    public var updatedAt: Date
    
    /// Whether this is the currently active MIDI configuration.
    public var isActive: Bool
    
    // MARK: - Initialization
    
    public init(
        id: UUID = UUID(),
        name: String = "Default",
        inputDeviceName: String = "",
        outputDeviceName: String = "",
        programChangeChannel: Int = 0,
        noteChannel: Int = 0,
        midiThruEnabled: Bool = false,
        sysexEnabled: Bool = true,
        sysexTransmitEnabled: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.inputDeviceName = inputDeviceName
        self.outputDeviceName = outputDeviceName
        self.programChangeChannel = programChangeChannel.clamped(to: 0...16)
        self.noteChannel = noteChannel.clamped(to: 0...16)
        self.midiThruEnabled = midiThruEnabled
        self.sysexEnabled = sysexEnabled
        self.sysexTransmitEnabled = sysexTransmitEnabled
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isActive = isActive
    }
    
    // MARK: - Computed Properties
    
    /// Returns a formatted string for display.
    public var displayName: String {
        return name.isEmpty ? "Default" : name
    }
    
    /// Returns a description of the MIDI configuration.
    public var description: String {
        var parts: [String] = []
        if !inputDeviceName.isEmpty {
            parts.append("In: \(inputDeviceName)")
        }
        if !outputDeviceName.isEmpty {
            parts.append("Out: \(outputDeviceName)")
        }
        if programChangeChannel > 0 {
            parts.append("PC: Ch \(programChangeChannel)")
        }
        if noteChannel > 0 {
            parts.append("Notes: Ch \(noteChannel)")
        }
        return parts.joined(separator: ", ")
    }
    
    // MARK: - Hashable Conformance
    
    public static func == (lhs: MIDISetting, rhs: MIDISetting) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Default Values

public extension MIDISetting {
    /// Creates a default MIDI setting.
    static var `default`: MIDISetting {
        return MIDISetting()
    }
    
    /// Creates a new MIDI setting with a unique name.
    static func newSetting() -> MIDISetting {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let timestamp = dateFormatter.string(from: Date())
        return MIDISetting(name: "MIDI Config " + timestamp)
    }
    
    /// Updates the `updatedAt` timestamp to the current date.
    public func touch() {
        updatedAt = Date()
    }
}

// MARK: - Helper Extensions

private extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        return Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
