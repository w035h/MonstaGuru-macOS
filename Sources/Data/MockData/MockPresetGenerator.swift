// MockPresetGenerator.swift
// MonstaGuru
// Created by Mistral Vibe Code (Core Data Model Agent)

import Foundation

/// Generates mock Preset data for testing and development.
public enum MockPresetGenerator {
    
    /// Generates a default preset.
    public static func defaultPreset(program: Program? = nil) -> Preset {
        return Preset(
            name: "Default Preset",
            author: "System",
            tags: ["default", "factory"],
            rating: 3,
            notes: "Default preset with initialization values.",
            program: program,
            color: "#4A90E2"
        )
    }
    
    /// Generates a bass preset.
    public static func bassPreset(program: Program? = nil) -> Preset {
        return Preset(
            name: "Deep Bass",
            author: "User",
            tags: ["bass", "low", "sub"],
            rating: 5,
            notes: "A deep, powerful bass sound for sub frequencies.",
            program: program,
            color: "#FF5733"
        )
    }
    
    /// Generates a lead preset.
    public static func leadPreset(program: Program? = nil) -> Preset {
        return Preset(
            name: "Bright Lead",
            author: "User",
            tags: ["lead", "solo", "bright"],
            rating: 4,
            notes: "A bright lead sound that cuts through the mix.",
            program: program,
            color: "#33FF57"
        )
    }
    
    /// Generates a pad preset.
    public static func padPreset(program: Program? = nil) -> Preset {
        return Preset(
            name: "Warm Pad",
            author: "User",
            tags: ["pad", "atmospheric", "warm"],
            rating: 5,
            notes: "A warm, atmospheric pad for ambient textures.",
            program: program,
            color: "#3357FF"
        )
    }
    
    /// Generates a drum preset.
    public static func drumPreset(program: Program? = nil) -> Preset {
        return Preset(
            name: "Kick Drum",
            author: "User",
            tags: ["drum", "kick", "percussion"],
            rating: 4,
            notes: "A punchy kick drum sound.",
            program: program,
            color: "#F033FF"
        )
    }
    
    /// Generates an array of mock presets with associated programs.
    public static func mockPresets() -> [Preset] {
        let programs = MockProgramGenerator.mockPrograms()
        return [
            defaultPreset(program: programs[0]),
            bassPreset(program: programs[1]),
            leadPreset(program: programs[2]),
            padPreset(program: programs[3]),
            drumPreset(program: programs[4])
        ]
    }
    
    /// Generates a preset with random values for testing.
    public static func randomPreset() -> Preset {
        let colors = ["#FF5733", "#33FF57", "#3357FF", "#F033FF", "#FF33F0", "#33FFF0"]
        let tags = ["bass", "lead", "pad", "drum", "fx", "atmospheric", "bright", "dark", "warm", "cold"]
        
        let randomColor = colors.randomElement() ?? "#888888"
        let randomTags = tags.shuffled().prefix(Int.random(in: 1...3)).map { String($0) }
        
        return Preset(
            name: "Random Preset \(Int.random(in: 1...1000))",
            author: "Test User",
            tags: Array(randomTags),
            rating: Int.random(in: 0...5),
            notes: "Randomly generated preset for testing.",
            color: randomColor
        )
    }
    
    /// Generates multiple random presets.
    public static func randomPresets(count: Int) -> [Preset] {
        return (0..<count).map { _ in randomPreset() }
    }
}
