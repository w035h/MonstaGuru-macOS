// Program.swift
// MonstaGuru
// Created by Mistral Vibe Code (Core Data Model Agent)

import Foundation
import SwiftData

/// Represents a complete program (patch) for the Audiothingies MicroMonsta 2.
/// A Program contains all parameters needed to define a sound on the hardware.
@Model
public final class Program: Identifiable, Hashable, Codable {
    /// Unique identifier for the program.
    @Attribute(.unique) public var id: UUID
    
    /// Program name (user-editable).
    public var name: String
    
    /// Program number (0-127, corresponds to hardware program slots).
    public var number: Int
    
    /// Date when the program was created.
    public var createdAt: Date
    
    /// Date when the program was last modified.
    public var updatedAt: Date
    
    /// Oscillator configurations (3 oscillators).
    public var oscillators: [Oscillator]
    
    /// Mixer configuration (levels for oscillators, noise, and external input).
    public var mixer: Mixer
    
    /// Filter configurations (2 filters).
    public var filters: [Filter]
    
    /// Envelope configurations (3 envelopes).
    public var envelopes: [Envelope]
    
    /// LFO configurations (3 LFOs).
    public var lfos: [LFO]
    
    /// Modulation matrix slots (12 slots for MicroMonsta 2).
    public var matrix: [MatrixSlot]
    
    /// Effects configuration.
    public var effects: Effects
    
    /// Global program settings.
    public var global: GlobalSettings
    
    // MARK: - Initialization
    
    public init(
        id: UUID = UUID(),
        name: String = "Untitled",
        number: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        oscillators: [Oscillator] = [.default(index: 1), .default(index: 2), .default(index: 3)],
        mixer: Mixer = .default,
        filters: [Filter] = [.default(index: 1), .default(index: 2)],
        envelopes: [Envelope] = [.default(index: 1), .default(index: 2), .default(index: 3)],
        lfos: [LFO] = [.default(index: 1), .default(index: 2), .default(index: 3)],
        matrix: [MatrixSlot] = (1...12).map { .default(index: $0) },
        effects: Effects = .default,
        global: GlobalSettings = .default
    ) {
        self.id = id
        self.name = name
        self.number = number.clamped(to: 0...127)
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.oscillators = oscillators
        self.mixer = mixer
        self.filters = filters
        self.envelopes = envelopes
        self.lfos = lfos
        self.matrix = matrix
        self.effects = effects
        self.global = global
    }

    // MARK: - Codable

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.number = try container.decode(Int.self, forKey: .number)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        self.oscillators = try container.decode([Oscillator].self, forKey: .oscillators)
        self.mixer = try container.decode(Mixer.self, forKey: .mixer)
        self.filters = try container.decode([Filter].self, forKey: .filters)
        self.envelopes = try container.decode([Envelope].self, forKey: .envelopes)
        self.lfos = try container.decode([LFO].self, forKey: .lfos)
        self.matrix = try container.decode([MatrixSlot].self, forKey: .matrix)
        self.effects = try container.decode(Effects.self, forKey: .effects)
        self.global = try container.decode(GlobalSettings.self, forKey: .global)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(number, forKey: .number)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(oscillators, forKey: .oscillators)
        try container.encode(mixer, forKey: .mixer)
        try container.encode(filters, forKey: .filters)
        try container.encode(envelopes, forKey: .envelopes)
        try container.encode(lfos, forKey: .lfos)
        try container.encode(matrix, forKey: .matrix)
        try container.encode(effects, forKey: .effects)
        try container.encode(global, forKey: .global)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case number
        case createdAt
        case updatedAt
        case oscillators
        case mixer
        case filters
        case envelopes
        case lfos
        case matrix
        case effects
        case global
    }

    // MARK: - Computed Properties
    
    /// Returns a formatted string for display (e.g., "01: Init Program").
    public var displayName: String {
        return String(format: "%02d: %@", number, name)
    }
    
    // MARK: - Hashable Conformance
    
    public static func == (lhs: Program, rhs: Program) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Mixer Configuration

/// Mixer configuration for MicroMonsta 2.
public struct Mixer: Codable, Hashable, Equatable {
    /// Oscillator 1 level (0-127).
    public var osc1Level: Int
    
    /// Oscillator 2 level (0-127).
    public var osc2Level: Int
    
    /// Oscillator 3 level (0-127).
    public var osc3Level: Int
    
    /// Noise level (0-127).
    public var noiseLevel: Int
    
    /// External input level (0-127).
    public var externalLevel: Int
    
    /// Ring mod level (0-127).
    public var ringModLevel: Int
    
    public init(
        osc1Level: Int = 127,
        osc2Level: Int = 127,
        osc3Level: Int = 127,
        noiseLevel: Int = 0,
        externalLevel: Int = 0,
        ringModLevel: Int = 0
    ) {
        self.osc1Level = osc1Level.clamped(to: 0...127)
        self.osc2Level = osc2Level.clamped(to: 0...127)
        self.osc3Level = osc3Level.clamped(to: 0...127)
        self.noiseLevel = noiseLevel.clamped(to: 0...127)
        self.externalLevel = externalLevel.clamped(to: 0...127)
        self.ringModLevel = ringModLevel.clamped(to: 0...127)
    }
}

// MARK: - Default Values

public extension Mixer {
    static var `default`: Mixer {
        return Mixer()
    }
}

// MARK: - Global Settings

/// Global settings for a MicroMonsta 2 program.
public struct GlobalSettings: Codable, Hashable, Equatable {
    /// Polyphony mode (1-8 voices).
    public var polyphony: Int
    
    /// Portamento enabled.
    public var portamentoEnabled: Bool
    
    /// Portamento time (0-127).
    public var portamentoTime: Int
    
    /// Pitch bend range (-12 to +12 semitones).
    public var pitchBendRange: Int
    
    /// Master volume (0-127).
    public var masterVolume: Int
    
    /// Master tune (-50 to +50 cents).
    public var masterTune: Int
    
    /// Velocity curve (0-3).
    public var velocityCurve: Int
    
    public init(
        polyphony: Int = 8,
        portamentoEnabled: Bool = false,
        portamentoTime: Int = 0,
        pitchBendRange: Int = 2,
        masterVolume: Int = 100,
        masterTune: Int = 0,
        velocityCurve: Int = 1
    ) {
        self.polyphony = polyphony.clamped(to: 1...8)
        self.portamentoEnabled = portamentoEnabled
        self.portamentoTime = portamentoTime.clamped(to: 0...127)
        self.pitchBendRange = pitchBendRange.clamped(to: -12...12)
        self.masterVolume = masterVolume.clamped(to: 0...127)
        self.masterTune = masterTune.clamped(to: -50...50)
        self.velocityCurve = velocityCurve.clamped(to: 0...3)
    }
}

// MARK: - Default Values

public extension GlobalSettings {
    static var `default`: GlobalSettings {
        return GlobalSettings()
    }
}

// MARK: - Helper Extensions

private extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}

// MARK: - Program Extensions

public extension Program {
    /// Creates a default program with initialization values.
    static var `default`: Program {
        return Program()
    }
    
    /// Creates a new program with a unique name based on the current date.
    static func newProgram() -> Program {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let timestamp = dateFormatter.string(from: Date())
        return Program(name: "Program " + timestamp)
    }
    
    /// Updates the `updatedAt` timestamp to the current date.
    public func touch() {
        updatedAt = Date()
    }
    
    /// Returns a copy of the program with a new unique identifier.
    public func copy() -> Program {
        return Program(
            id: UUID(),
            name: name + " (Copy)",
            number: number,
            createdAt: Date(),
            updatedAt: Date(),
            oscillators: oscillators,
            mixer: mixer,
            filters: filters,
            envelopes: envelopes,
            lfos: lfos,
            matrix: matrix,
            effects: effects,
            global: global
        )
    }
}
