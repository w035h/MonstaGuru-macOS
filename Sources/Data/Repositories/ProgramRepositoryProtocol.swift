// ProgramRepositoryProtocol.swift
// MonstaGuru
// Created by Mistral Vibe Code (Core Data Model Agent)

import Foundation
import SwiftData

/// Protocol defining CRUD operations for Program models.
public protocol ProgramRepositoryProtocol {
    /// Fetches all programs.
    func fetchAll() throws -> [Program]
    
    /// Fetches a program by its ID.
    func fetch(byId id: UUID) throws -> Program?
    
    /// Fetches programs by name (case-insensitive, partial match).
    func fetch(byName name: String) throws -> [Program]
    
    /// Fetches programs by number.
    func fetch(byNumber number: Int) throws -> [Program]
    
    /// Fetches programs sorted by a specified key.
    func fetchSorted(by key: SortKey, ascending: Bool) throws -> [Program]
    
    /// Saves a program (creates or updates).
    func save(_ program: Program) throws
    
    /// Deletes a program by its ID.
    func delete(byId id: UUID) throws
    
    /// Deletes a program.
    func delete(_ program: Program) throws
    
    /// Counts the total number of programs.
    func count() throws -> Int
    
    /// Fetches programs created after a specific date.
    func fetchCreatedAfter(_ date: Date) throws -> [Program]
    
    /// Fetches programs updated after a specific date.
    func fetchUpdatedAfter(_ date: Date) throws -> [Program]
}

/// Sort keys for Program queries.
public enum SortKey: String {
    case name
    case number
    case createdAt
    case updatedAt
}
