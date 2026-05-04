// ProgramRepository.swift
// MonstaGuru
// Created by Mistral Vibe Code (Core Data Model Agent)

import Foundation
import SwiftData

/// Concrete implementation of ProgramRepositoryProtocol using SwiftData.
public final class ProgramRepository: ProgramRepositoryProtocol {
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Fetch Operations
    
    public func fetchAll() throws -> [Program] {
        let descriptor = FetchDescriptor<Program>(sortBy: [SortDescriptor(\Program.self, keyPath: \.number)])
        return try modelContext.fetch(descriptor)
    }
    
    public func fetch(byId id: UUID) throws -> Program? {
        let descriptor = FetchDescriptor<Program>(
            predicate: #Predicate<Program> { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }
    
    public func fetch(byName name: String) throws -> [Program] {
        let descriptor = FetchDescriptor<Program>(
            predicate: #Predicate<Program> { $0.name.localizedStandardContains(name) },
            sortBy: [SortDescriptor(\Program.self, keyPath: \.name)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    public func fetch(byNumber number: Int) throws -> [Program] {
        let descriptor = FetchDescriptor<Program>(
            predicate: #Predicate<Program> { $0.number == number },
            sortBy: [SortDescriptor(\Program.self, keyPath: \.name)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    public func fetchSorted(by key: SortKey, ascending: Bool = true) throws -> [Program] {
        let sortDescriptor = SortDescriptor(\Program.self, keyPath: key.keyPath, order: ascending ? .forward : .reverse)
        let descriptor = FetchDescriptor<Program>(sortBy: [sortDescriptor])
        return try modelContext.fetch(descriptor)
    }
    
    public func count() throws -> Int {
        let descriptor = FetchDescriptor<Program>()
        return try modelContext.fetchCount(descriptor)
    }
    
    public func fetchCreatedAfter(_ date: Date) throws -> [Program] {
        let descriptor = FetchDescriptor<Program>(
            predicate: #Predicate<Program> { $0.createdAt > date },
            sortBy: [SortDescriptor(\Program.self, keyPath: \.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    public func fetchUpdatedAfter(_ date: Date) throws -> [Program] {
        let descriptor = FetchDescriptor<Program>(
            predicate: #Predicate<Program> { $0.updatedAt > date },
            sortBy: [SortDescriptor(\Program.self, keyPath: \.updatedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    // MARK: - Save Operations
    
    public func save(_ program: Program) throws {
        program.updatedAt = Date()
        modelContext.insert(program)
        try modelContext.save()
    }
    
    // MARK: - Delete Operations
    
    public func delete(byId id: UUID) throws {
        guard let program = try fetch(byId: id) else { return }
        modelContext.delete(program)
        try modelContext.save()
    }
    
    public func delete(_ program: Program) throws {
        modelContext.delete(program)
        try modelContext.save()
    }
}

// MARK: - SortKey Extension

public extension SortKey {
    var keyPath: KeyPath<Program, some Comparable> {
        switch self {
        case .name: return \Program.name
        case .number: return \Program.number
        case .createdAt: return \Program.createdAt
        case .updatedAt: return \Program.updatedAt
        }
    }
}
