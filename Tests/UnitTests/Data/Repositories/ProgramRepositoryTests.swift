// ProgramRepositoryTests.swift
// MonstaGuru
// Created by Mistral Vibe Code (Core Data Model Agent)

import XCTest
import SwiftData
@testable import Data

final class ProgramRepositoryTests: XCTestCase {
    
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var repository: ProgramRepository!
    
    override func setUp() {
        super.setUp()
        do {
            modelContainer = try ModelContainer(
                for: Program.self, Preset.self, Bank.self, ClipboardEntry.self, MIDISetting.self,
                configurations: ModelConfiguration(url: URL(fileURLWithPath: "/dev/null"))
            )
            modelContext = ModelContext(modelContainer)
            repository = ProgramRepository(modelContext: modelContext)
        } catch {
            XCTFail("Failed to create ModelContainer: \(error)")
        }
    }
    
    override func tearDown() {
        modelContainer = nil
        modelContext = nil
        repository = nil
        super.tearDown()
    }
    
    // MARK: - Save and Fetch Tests
    
    func testSaveAndFetchProgram() throws {
        let program = Program(name: "Test Program", number: 1)
        
        try repository.save(program)
        
        let fetchedProgram = try repository.fetch(byId: program.id)
        XCTAssertNotNil(fetchedProgram)
        XCTAssertEqual(fetchedProgram?.name, "Test Program")
        XCTAssertEqual(fetchedProgram?.number, 1)
    }
    
    func testFetchAllPrograms() throws {
        let program1 = Program(name: "Program 1", number: 1)
        let program2 = Program(name: "Program 2", number: 2)
        
        try repository.save(program1)
        try repository.save(program2)
        
        let allPrograms = try repository.fetchAll()
        XCTAssertEqual(allPrograms.count, 2)
    }
    
    func testFetchByName() throws {
        let program1 = Program(name: "Bass Program", number: 1)
        let program2 = Program(name: "Lead Program", number: 2)
        
        try repository.save(program1)
        try repository.save(program2)
        
        let bassPrograms = try repository.fetch(byName: "Bass")
        XCTAssertEqual(bassPrograms.count, 1)
        XCTAssertEqual(bassPrograms.first?.name, "Bass Program")
    }
    
    func testFetchByNumber() throws {
        let program1 = Program(name: "Program 1", number: 5)
        let program2 = Program(name: "Program 2", number: 5)
        let program3 = Program(name: "Program 3", number: 10)
        
        try repository.save(program1)
        try repository.save(program2)
        try repository.save(program3)
        
        let programs = try repository.fetch(byNumber: 5)
        XCTAssertEqual(programs.count, 2)
    }
    
    // MARK: - Sort Tests
    
    func testFetchSortedByName() throws {
        let program1 = Program(name: "Zebra", number: 1)
        let program2 = Program(name: "Apple", number: 2)
        let program3 = Program(name: "Banana", number: 3)
        
        try repository.save(program1)
        try repository.save(program2)
        try repository.save(program3)
        
        let sortedAscending = try repository.fetchSorted(by: .name, ascending: true)
        XCTAssertEqual(sortedAscending.first?.name, "Apple")
        XCTAssertEqual(sortedAscending.last?.name, "Zebra")
        
        let sortedDescending = try repository.fetchSorted(by: .name, ascending: false)
        XCTAssertEqual(sortedDescending.first?.name, "Zebra")
        XCTAssertEqual(sortedDescending.last?.name, "Apple")
    }
    
    func testFetchSortedByNumber() throws {
        let program1 = Program(name: "Program 1", number: 3)
        let program2 = Program(name: "Program 2", number: 1)
        let program3 = Program(name: "Program 3", number: 2)
        
        try repository.save(program1)
        try repository.save(program2)
        try repository.save(program3)
        
        let sorted = try repository.fetchSorted(by: .number, ascending: true)
        XCTAssertEqual(sorted.first?.number, 1)
        XCTAssertEqual(sorted[1].number, 2)
        XCTAssertEqual(sorted.last?.number, 3)
    }
    
    // MARK: - Count Tests
    
    func testCount() throws {
        let program1 = Program(name: "Program 1")
        let program2 = Program(name: "Program 2")
        
        try repository.save(program1)
        XCTAssertEqual(try repository.count(), 1)
        
        try repository.save(program2)
        XCTAssertEqual(try repository.count(), 2)
    }
    
    // MARK: - Delete Tests
    
    func testDeleteProgram() throws {
        let program = Program(name: "Test Program")
        
        try repository.save(program)
        XCTAssertEqual(try repository.count(), 1)
        
        try repository.delete(program)
        XCTAssertEqual(try repository.count(), 0)
    }
    
    func testDeleteById() throws {
        let program = Program(name: "Test Program")
        
        try repository.save(program)
        XCTAssertEqual(try repository.count(), 1)
        
        try repository.delete(byId: program.id)
        XCTAssertEqual(try repository.count(), 0)
    }
    
    // MARK: - Date Filter Tests
    
    func testFetchCreatedAfter() throws {
        let oldProgram = Program(name: "Old Program")
        oldProgram.createdAt = Date(timeIntervalSince1970: 0)
        
        let newProgram = Program(name: "New Program")
        newProgram.createdAt = Date()
        
        try repository.save(oldProgram)
        try repository.save(newProgram)
        
        let recentPrograms = try repository.fetchCreatedAfter(Date(timeIntervalSince1970: 1000))
        XCTAssertEqual(recentPrograms.count, 1)
        XCTAssertEqual(recentPrograms.first?.name, "New Program")
    }
    
    func testFetchUpdatedAfter() throws {
        let program = Program(name: "Test Program")
        
        try repository.save(program)
        
        // Update the program
        program.name = "Updated Program"
        program.updatedAt = Date()
        try repository.save(program)
        
        let recentUpdates = try repository.fetchUpdatedAfter(program.createdAt)
        XCTAssertEqual(recentUpdates.count, 1)
        XCTAssertEqual(recentUpdates.first?.name, "Updated Program")
    }
}
