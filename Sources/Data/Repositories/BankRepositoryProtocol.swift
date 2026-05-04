// BankRepositoryProtocol.swift
// MonstaGuru
// Created by Mistral Vibe Code (Core Data Model Agent)

import Foundation
import SwiftData

/// Protocol defining CRUD operations for Bank models.
public protocol BankRepositoryProtocol {
    /// Fetches all banks.
    func fetchAll() throws -> [Bank]
    
    /// Fetches a bank by its ID.
    func fetch(byId id: UUID) throws -> Bank?
    
    /// Fetches banks by name (case-insensitive, partial match).
    func fetch(byName name: String) throws -> [Bank]
    
    /// Fetches banks sorted by a specified key.
    func fetchSorted(by key: BankSortKey, ascending: Bool) throws -> [Bank]
    
    /// Saves a bank (creates or updates).
    func save(_ bank: Bank) throws
    
    /// Deletes a bank by its ID.
    func delete(byId id: UUID) throws
    
    /// Deletes a bank.
    func delete(_ bank: Bank) throws
    
    /// Counts the total number of banks.
    func count() throws -> Int
    
    /// Fetches the default bank (first bank or creates one if none exists).
    func fetchDefault() throws -> Bank
}

/// Sort keys for Bank queries.
public enum BankSortKey: String {
    case name
    case createdAt
    case updatedAt
    case presetCount
}
