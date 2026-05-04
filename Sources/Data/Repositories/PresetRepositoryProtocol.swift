// PresetRepositoryProtocol.swift
// MonstaGuru
// Created by Mistral Vibe Code (Core Data Model Agent)

import Foundation
import SwiftData

/// Protocol defining CRUD operations for Preset models.
public protocol PresetRepositoryProtocol {
    /// Fetches all presets.
    func fetchAll() throws -> [Preset]
    
    /// Fetches a preset by its ID.
    func fetch(byId id: UUID) throws -> Preset?
    
    /// Fetches presets by name (case-insensitive, partial match).
    func fetch(byName name: String) throws -> [Preset]
    
    /// Fetches presets by author.
    func fetch(byAuthor author: String) throws -> [Preset]
    
    /// Fetches presets by tag.
    func fetch(byTag tag: String) throws -> [Preset]
    
    /// Fetches presets sorted by a specified key.
    func fetchSorted(by key: PresetSortKey, ascending: Bool) throws -> [Preset]
    
    /// Fetches presets by rating.
    func fetch(byRating rating: Int) throws -> [Preset]
    
    /// Saves a preset (creates or updates).
    func save(_ preset: Preset) throws
    
    /// Deletes a preset by its ID.
    func delete(byId id: UUID) throws
    
    /// Deletes a preset.
    func delete(_ preset: Preset) throws
    
    /// Counts the total number of presets.
    func count() throws -> Int
}

/// Sort keys for Preset queries.
public enum PresetSortKey: String {
    case name
    case author
    case createdAt
    case updatedAt
    case rating
}
