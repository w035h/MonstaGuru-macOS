// MIDISettingRepository.swift
// MonstaGuru
// Created by Mistral Vibe Code (Core Data Model Agent)

import Foundation
import SwiftData

/// Concrete implementation of MIDISettingRepositoryProtocol using SwiftData.
public final class MIDISettingRepository: MIDISettingRepositoryProtocol {
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Fetch Operations
    
    public func fetchAll() throws -> [MIDISetting] {
        let descriptor = FetchDescriptor<MIDISetting>(sortBy: [SortDescriptor(\MIDISetting.self, keyPath: \.name)])
        return try modelContext.fetch(descriptor)
    }
    
    public func fetch(byId id: UUID) throws -> MIDISetting? {
        let descriptor = FetchDescriptor<MIDISetting>(
            predicate: #Predicate<MIDISetting> { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }
    
    public func fetchActive() throws -> MIDISetting? {
        let descriptor = FetchDescriptor<MIDISetting>(
            predicate: #Predicate<MIDISetting> { $0.isActive == true }
        )
        return try modelContext.fetch(descriptor).first
    }
    
    public func fetch(byName name: String) throws -> [MIDISetting] {
        let descriptor = FetchDescriptor<MIDISetting>(
            predicate: #Predicate<MIDISetting> { $0.name.localizedStandardContains(name) },
            sortBy: [SortDescriptor(\MIDISetting.self, keyPath: \.name)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    public func count() throws -> Int {
        let descriptor = FetchDescriptor<MIDISetting>()
        return try modelContext.fetchCount(descriptor)
    }
    
    // MARK: - Save Operations
    
    public func save(_ setting: MIDISetting) throws {
        setting.updatedAt = Date()
        modelContext.insert(setting)
        try modelContext.save()
    }
    
    // MARK: - Delete Operations
    
    public func delete(byId id: UUID) throws {
        guard let setting = try fetch(byId: id) else { return }
        modelContext.delete(setting)
        try modelContext.save()
    }
    
    public func delete(_ setting: MIDISetting) throws {
        modelContext.delete(setting)
        try modelContext.save()
    }
    
    // MARK: - Active Setting Management
    
    public func setActive(_ setting: MIDISetting) throws {
        // Deactivate all other settings
        let allSettings = try fetchAll()
        for var otherSetting in allSettings where otherSetting.id != setting.id {
            otherSetting.isActive = false
        }
        
        // Activate the selected setting
        setting.isActive = true
        setting.updatedAt = Date()
        
        try modelContext.save()
    }
}
