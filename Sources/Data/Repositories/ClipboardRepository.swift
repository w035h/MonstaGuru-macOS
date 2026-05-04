// ClipboardRepository.swift
// MonstaGuru
// Created by Mistral Vibe Code (Core Data Model Agent)

import Foundation
import SwiftData

/// Concrete implementation of ClipboardRepositoryProtocol using SwiftData.
public final class ClipboardRepository: ClipboardRepositoryProtocol {
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Fetch Operations
    
    public func fetchAll() throws -> [ClipboardEntry] {
        let descriptor = FetchDescriptor<ClipboardEntry>(
            sortBy: [SortDescriptor(\ClipboardEntry.self, keyPath: \.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    public func fetch(byId id: UUID) throws -> ClipboardEntry? {
        let descriptor = FetchDescriptor<ClipboardEntry>(
            predicate: #Predicate<ClipboardEntry> { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }
    
    public func fetch(byType type: ClipboardEntryType) throws -> [ClipboardEntry] {
        let descriptor = FetchDescriptor<ClipboardEntry>(
            predicate: #Predicate<ClipboardEntry> { $0.type == type },
            sortBy: [SortDescriptor(\ClipboardEntry.self, keyPath: \.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    public func fetchSorted(by key: ClipboardSortKey, ascending: Bool = true) throws -> [ClipboardEntry] {
        let sortDescriptor = SortDescriptor(\ClipboardEntry.self, keyPath: key.keyPath, order: ascending ? .forward : .reverse)
        let descriptor = FetchDescriptor<ClipboardEntry>(sortBy: [sortDescriptor])
        return try modelContext.fetch(descriptor)
    }
    
    public func count() throws -> Int {
        let descriptor = FetchDescriptor<ClipboardEntry>()
        return try modelContext.fetchCount(descriptor)
    }
    
    // MARK: - Save Operations
    
    public func save(_ entry: ClipboardEntry) throws {
        modelContext.insert(entry)
        try modelContext.save()
    }
    
    // MARK: - Delete Operations
    
    public func delete(byId id: UUID) throws {
        guard let entry = try fetch(byId: id) else { return }
        modelContext.delete(entry)
        try modelContext.save()
    }
    
    public func delete(_ entry: ClipboardEntry) throws {
        modelContext.delete(entry)
        try modelContext.save()
    }
    
    public func clearAll() throws {
        let entries = try fetchAll()
        for entry in entries {
            modelContext.delete(entry)
        }
        try modelContext.save()
    }
}

// MARK: - ClipboardSortKey Extension

public extension ClipboardSortKey {
    var keyPath: KeyPath<ClipboardEntry, some Comparable> {
        switch self {
        case .name: return \ClipboardEntry.name
        case .type: return \ClipboardEntry.type
        case .createdAt: return \ClipboardEntry.createdAt
        }
    }
}
