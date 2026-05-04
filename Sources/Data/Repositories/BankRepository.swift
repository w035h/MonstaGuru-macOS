// BankRepository.swift
// MonstaGuru
// Created by Mistral Vibe Code (Core Data Model Agent)

import Foundation
import SwiftData

/// Concrete implementation of BankRepositoryProtocol using SwiftData.
public final class BankRepository: BankRepositoryProtocol {
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Fetch Operations
    
    public func fetchAll() throws -> [Bank] {
        let descriptor = FetchDescriptor<Bank>(sortBy: [SortDescriptor(\Bank.self, keyPath: \.name)])
        return try modelContext.fetch(descriptor)
    }
    
    public func fetch(byId id: UUID) throws -> Bank? {
        let descriptor = FetchDescriptor<Bank>(
            predicate: #Predicate<Bank> { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }
    
    public func fetch(byName name: String) throws -> [Bank] {
        let descriptor = FetchDescriptor<Bank>(
            predicate: #Predicate<Bank> { $0.name.localizedStandardContains(name) },
            sortBy: [SortDescriptor(\Bank.self, keyPath: \.name)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    public func fetchSorted(by key: BankSortKey, ascending: Bool = true) throws -> [Bank] {
        let sortDescriptor = SortDescriptor(\Bank.self, keyPath: key.keyPath, order: ascending ? .forward : .reverse)
        let descriptor = FetchDescriptor<Bank>(sortBy: [sortDescriptor])
        return try modelContext.fetch(descriptor)
    }
    
    public func count() throws -> Int {
        let descriptor = FetchDescriptor<Bank>()
        return try modelContext.fetchCount(descriptor)
    }
    
    public func fetchDefault() throws -> Bank {
        let banks = try fetchAll()
        if let firstBank = banks.first {
            return firstBank
        }
        // Create a default bank if none exists
        let defaultBank = Bank.newBank()
        try save(defaultBank)
        return defaultBank
    }
    
    // MARK: - Save Operations
    
    public func save(_ bank: Bank) throws {
        bank.updatedAt = Date()
        modelContext.insert(bank)
        try modelContext.save()
    }
    
    // MARK: - Delete Operations
    
    public func delete(byId id: UUID) throws {
        guard let bank = try fetch(byId: id) else { return }
        modelContext.delete(bank)
        try modelContext.save()
    }
    
    public func delete(_ bank: Bank) throws {
        modelContext.delete(bank)
        try modelContext.save()
    }
}

// MARK: - BankSortKey Extension

public extension BankSortKey {
    var keyPath: KeyPath<Bank, some Comparable> {
        switch self {
        case .name: return \Bank.name
        case .createdAt: return \Bank.createdAt
        case .updatedAt: return \Bank.updatedAt
        case .presetCount: return \Bank.presetCount
        }
    }
}
