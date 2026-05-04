// ClipboardRepositoryProtocol.swift
// MonstaGuru
// Created by Mistral Vibe Code (Core Data Model Agent)

import Foundation
import SwiftData

/// Protocol defining CRUD operations for ClipboardEntry models.
public protocol ClipboardRepositoryProtocol {
    /// Fetches all clipboard entries.
    func fetchAll() throws -> [ClipboardEntry]
    
    /// Fetches a clipboard entry by its ID.
    func fetch(byId id: UUID) throws -> ClipboardEntry?
    
    /// Fetches clipboard entries by type.
    func fetch(byType type: ClipboardEntryType) throws -> [ClipboardEntry]
    
    /// Fetches clipboard entries sorted by a specified key.
    func fetchSorted(by key: ClipboardSortKey, ascending: Bool) throws -> [ClipboardEntry]
    
    /// Saves a clipboard entry (creates or updates).
    func save(_ entry: ClipboardEntry) throws
    
    /// Deletes a clipboard entry by its ID.
    func delete(byId id: UUID) throws
    
    /// Deletes a clipboard entry.
    func delete(_ entry: ClipboardEntry) throws
    
    /// Clears all clipboard entries.
    func clearAll() throws
    
    /// Counts the total number of clipboard entries.
    func count() throws -> Int
}

/// Sort keys for ClipboardEntry queries.
public enum ClipboardSortKey: String {
    case name
    case type
    case createdAt
}
