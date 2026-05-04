// PresetRepository.swift
// MonstaGuru
// Created by Mistral Vibe Code (Core Data Model Agent)

import Foundation
import SwiftData

/// Concrete implementation of PresetRepositoryProtocol using SwiftData.
public final class PresetRepository: PresetRepositoryProtocol {
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Fetch Operations
    
    public func fetchAll() throws -> [Preset] {
        let descriptor = FetchDescriptor<Preset>(sortBy: [SortDescriptor(\Preset.self, keyPath: \.name)])
        return try modelContext.fetch(descriptor)
    }
    
    public func fetch(byId id: UUID) throws -> Preset? {
        let descriptor = FetchDescriptor<Preset>(
            predicate: #Predicate<Preset> { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }
    
    public func fetch(byName name: String) throws -> [Preset] {
        let descriptor = FetchDescriptor<Preset>(
            predicate: #Predicate<Preset> { $0.name.localizedStandardContains(name) },
            sortBy: [SortDescriptor(\Preset.self, keyPath: \.name)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    public func fetch(byAuthor author: String) throws -> [Preset] {
        let descriptor = FetchDescriptor<Preset>(
            predicate: #Predicate<Preset> { $0.author.localizedStandardContains(author) },
            sortBy: [SortDescriptor(\Preset.self, keyPath: \.name)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    public func fetch(byTag tag: String) throws -> [Preset] {
        let descriptor = FetchDescriptor<Preset>(
            predicate: #Predicate<Preset> { $0.tags.contains(tag) },
            sortBy: [SortDescriptor(\Preset.self, keyPath: \.name)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    public func fetchSorted(by key: PresetSortKey, ascending: Bool = true) throws -> [Preset] {
        let sortDescriptor = SortDescriptor(\Preset.self, keyPath: key.keyPath, order: ascending ? .forward : .reverse)
        let descriptor = FetchDescriptor<Preset>(sortBy: [sortDescriptor])
        return try modelContext.fetch(descriptor)
    }
    
    public func fetch(byRating rating: Int) throws -> [Preset] {
        let descriptor = FetchDescriptor<Preset>(
            predicate: #Predicate<Preset> { $0.rating == rating },
            sortBy: [SortDescriptor(\Preset.self, keyPath: \.name)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    public func count() throws -> Int {
        let descriptor = FetchDescriptor<Preset>()
        return try modelContext.fetchCount(descriptor)
    }
    
    // MARK: - Save Operations
    
    public func save(_ preset: Preset) throws {
        preset.updatedAt = Date()
        modelContext.insert(preset)
        try modelContext.save()
    }
    
    // MARK: - Delete Operations
    
    public func delete(byId id: UUID) throws {
        guard let preset = try fetch(byId: id) else { return }
        modelContext.delete(preset)
        try modelContext.save()
    }
    
    public func delete(_ preset: Preset) throws {
        modelContext.delete(preset)
        try modelContext.save()
    }
}

// MARK: - PresetSortKey Extension

public extension PresetSortKey {
    var keyPath: KeyPath<Preset, some Comparable> {
        switch self {
        case .name: return \Preset.name
        case .author: return \Preset.author
        case .createdAt: return \Preset.createdAt
        case .updatedAt: return \Preset.updatedAt
        case .rating: return \Preset.rating
        }
    }
}
