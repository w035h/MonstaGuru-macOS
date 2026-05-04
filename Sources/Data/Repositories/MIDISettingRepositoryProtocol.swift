// MIDISettingRepositoryProtocol.swift
// MonstaGuru
// Created by Mistral Vibe Code (Core Data Model Agent)

import Foundation
import SwiftData

/// Protocol defining CRUD operations for MIDISetting models.
public protocol MIDISettingRepositoryProtocol {
    /// Fetches all MIDI settings.
    func fetchAll() throws -> [MIDISetting]
    
    /// Fetches a MIDI setting by its ID.
    func fetch(byId id: UUID) throws -> MIDISetting?
    
    /// Fetches the active MIDI setting.
    func fetchActive() throws -> MIDISetting?
    
    /// Fetches MIDI settings by name.
    func fetch(byName name: String) throws -> [MIDISetting]
    
    /// Saves a MIDI setting (creates or updates).
    func save(_ setting: MIDISetting) throws
    
    /// Deletes a MIDI setting by its ID.
    func delete(byId id: UUID) throws
    
    /// Deletes a MIDI setting.
    func delete(_ setting: MIDISetting) throws
    
    /// Sets a MIDI setting as active and deactivates all others.
    func setActive(_ setting: MIDISetting) throws
    
    /// Counts the total number of MIDI settings.
    func count() throws -> Int
}
