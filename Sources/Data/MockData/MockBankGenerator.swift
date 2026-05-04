// MockBankGenerator.swift
// MonstaGuru
// Created by Mistral Vibe Code (Core Data Model Agent)

import Foundation

/// Generates mock Bank data for testing and development.
public enum MockBankGenerator {
    
    /// Generates a default bank with mock presets.
    public static func defaultBank() -> Bank {
        let presets = MockPresetGenerator.mockPresets()
        return Bank(
            name: "Factory Bank A",
            color: "#4A90E2",
            presets: presets
        )
    }
    
    /// Generates a user bank with random presets.
    public static func userBank() -> Bank {
        let presets = MockPresetGenerator.randomPresets(count: 10)
        return Bank(
            name: "User Bank 1",
            color: "#FF5733",
            presets: presets
        )
    }
    
    /// Generates a bank with bass presets.
    public static func bassBank() -> Bank {
        let bassPresets = [
            MockPresetGenerator.bassPreset(program: MockProgramGenerator.bassProgram()),
            MockPresetGenerator.defaultPreset(program: MockProgramGenerator.initProgram())
        ]
        return Bank(
            name: "Bass Bank",
            color: "#33FF57",
            presets: bassPresets
        )
    }
    
    /// Generates a bank with lead presets.
    public static func leadBank() -> Bank {
        let leadPresets = [
            MockPresetGenerator.leadPreset(program: MockProgramGenerator.leadProgram()),
            MockPresetGenerator.defaultPreset(program: MockProgramGenerator.initProgram())
        ]
        return Bank(
            name: "Lead Bank",
            color: "#3357FF",
            presets: leadPresets
        )
    }
    
    /// Generates an array of mock banks.
    public static func mockBanks() -> [Bank] {
        return [
            defaultBank(),
            userBank(),
            bassBank(),
            leadBank()
        ]
    }
    
    /// Generates a bank with random values for testing.
    public static func randomBank() -> Bank {
        let colors = ["#FF5733", "#33FF57", "#3357FF", "#F033FF", "#FF33F0", "#33FFF0"]
        let randomColor = colors.randomElement() ?? "#888888"
        let presetCount = Int.random(in: 5...15)
        let presets = MockPresetGenerator.randomPresets(count: presetCount)
        
        return Bank(
            name: "Random Bank \(Int.random(in: 1...1000))",
            color: randomColor,
            presets: presets
        )
    }
    
    /// Generates multiple random banks.
    public static func randomBanks(count: Int) -> [Bank] {
        return (0..<count).map { _ in randomBank() }
    }
}
