// ClipboardEntryComputedPropertiesTests.swift
// MonstaGuru
// Created by Mistral Vibe Code (Testing Agent)

import XCTest
@testable import Data

/// Tests for ClipboardEntry computed properties added for UI support.
final class ClipboardEntryComputedPropertiesTests: XCTestCase {
    
    // MARK: - Test Data
    
    private var testEntry: ClipboardEntry!
    private var testEntryWithName: ClipboardEntry!
    
    override func setUp() {
        super.setUp()
        
        // Create test entries with known data
        let testData = "test data".data(using: .utf8)!
        
        testEntry = ClipboardEntry(
            type: .program,
            name: "",
            data: testData,
            createdAt: Date(timeIntervalSince1970: 0)
        )
        
        testEntryWithName = ClipboardEntry(
            type: .oscillator,
            name: "Test Oscillator",
            data: testData,
            createdAt: Date(timeIntervalSince1970: 1234567890)
        )
    }
    
    override func tearDown() {
        testEntry = nil
        testEntryWithName = nil
        super.tearDown()
    }
    
    // MARK: - displayName Tests
    
    func testDisplayNameWithEmptyName() {
        XCTAssertEqual(testEntry.displayName, "Program")
    }
    
    func testDisplayNameWithNonEmptyName() {
        XCTAssertEqual(testEntryWithName.displayName, "Test Oscillator")
    }
    
    func testDisplayNameUsesTypeDisplayName() {
        let entry = ClipboardEntry(
            type: .filter,
            name: "",
            data: Data(),
            createdAt: Date()
        )
        XCTAssertEqual(entry.displayName, "Filter")
    }
    
    // MARK: - dateFormatted Tests
    
    func testDateFormatted() {
        // Test with a known date
        let date = Date(timeIntervalSince1970: 0) // Jan 1, 1970
        let entry = ClipboardEntry(
            type: .program,
            name: "Test",
            data: Data(),
            createdAt: date
        )
        
        let formattedDate = entry.dateFormatted
        
        // Verify it's not empty
        XCTAssertFalse(formattedDate.isEmpty)
        
        // Verify it contains date components
        // Note: The exact format depends on the locale, so we just check it's not empty
        XCTAssertTrue(formattedDate.count > 0)
    }
    
    func testDateFormattedWithDifferentDate() {
        let date = Date(timeIntervalSince1970: 1234567890) // Feb 14, 2009
        let entry = ClipboardEntry(
            type: .program,
            name: "Test",
            data: Data(),
            createdAt: date
        )
        
        let formattedDate = entry.dateFormatted
        XCTAssertFalse(formattedDate.isEmpty)
    }
    
    // MARK: - sizeDescription Tests
    
    func testSizeDescriptionForBytes() {
        // Create entry with small data (< 1KB)
        let smallData = Data(repeating: 0, count: 512) // 512 bytes
        let entry = ClipboardEntry(
            type: .program,
            name: "Test",
            data: smallData,
            createdAt: Date()
        )
        
        let sizeDescription = entry.sizeDescription
        XCTAssertTrue(sizeDescription.contains("bytes"))
        XCTAssertTrue(sizeDescription.contains("512"))
    }
    
    func testSizeDescriptionForKilobytes() {
        // Create entry with data between 1KB and 1MB
        let kbData = Data(repeating: 0, count: 2048) // 2KB
        let entry = ClipboardEntry(
            type: .program,
            name: "Test",
            data: kbData,
            createdAt: Date()
        )
        
        let sizeDescription = entry.sizeDescription
        XCTAssertTrue(sizeDescription.contains("KB"))
    }
    
    func testSizeDescriptionForMegabytes() {
        // Create entry with data > 1MB
        let mbData = Data(repeating: 0, count: 2 * 1024 * 1024) // 2MB
        let entry = ClipboardEntry(
            type: .program,
            name: "Test",
            data: mbData,
            createdAt: Date()
        )
        
        let sizeDescription = entry.sizeDescription
        XCTAssertTrue(sizeDescription.contains("MB"))
    }
    
    func testSizeDescriptionForExactBoundaries() {
        // Test at exact boundaries
        let oneKB = Data(repeating: 0, count: 1024)
        let entry1KB = ClipboardEntry(
            type: .program,
            name: "Test",
            data: oneKB,
            createdAt: Date()
        )
        
        // At exactly 1KB, should show as KB
        let size1KB = entry1KB.sizeDescription
        XCTAssertTrue(size1KB.contains("KB"))
        
        let oneMB = Data(repeating: 0, count: 1024 * 1024)
        let entry1MB = ClipboardEntry(
            type: .program,
            name: "Test",
            data: oneMB,
            createdAt: Date()
        )
        
        // At exactly 1MB, should show as MB
        let size1MB = entry1MB.sizeDescription
        XCTAssertTrue(size1MB.contains("MB"))
    }
    
    // MARK: - All Entry Types Tests
    
    func testAllEntryTypesHaveDisplayNames() {
        let allTypes: [ClipboardEntryType] = [
            .program, .oscillator, .filter, .envelope, .lfo,
            .matrixSlot, .effects, .globalSettings, .mixer
        ]
        
        for entryType in allTypes {
            let entry = ClipboardEntry(
                type: entryType,
                name: "",
                data: Data(),
                createdAt: Date()
            )
            
            // Should use type display name when entry name is empty
            XCTAssertEqual(entry.displayName, entryType.displayName)
            
            // Verify display name is not empty
            XCTAssertFalse(entry.displayName.isEmpty)
        }
    }
    
    // MARK: - Edge Cases
    
    func testEmptyData() {
        let entry = ClipboardEntry(
            type: .program,
            name: "Test",
            data: Data(),
            createdAt: Date()
        )
        
        let sizeDescription = entry.sizeDescription
        XCTAssertTrue(sizeDescription.contains("0 bytes"))
    }
    
    func testVeryLargeData() {
        // Test with very large data (100MB)
        let largeData = Data(repeating: 0, count: 100 * 1024 * 1024)
        let entry = ClipboardEntry(
            type: .program,
            name: "Test",
            data: largeData,
            createdAt: Date()
        )
        
        let sizeDescription = entry.sizeDescription
        XCTAssertTrue(sizeDescription.contains("MB"))
    }
    
    // MARK: - Consistency Tests
    
    func testDisplayNameConsistency() {
        // Test that displayName always returns a non-empty string
        let entryTypes: [ClipboardEntryType] = [.program, .oscillator, .filter, .envelope, .lfo]
        
        for entryType in entryTypes {
            let entryWithName = ClipboardEntry(
                type: entryType,
                name: "Custom Name",
                data: Data(),
                createdAt: Date()
            )
            
            let entryWithoutName = ClipboardEntry(
                type: entryType,
                name: "",
                data: Data(),
                createdAt: Date()
            )
            
            // With name should use custom name
            XCTAssertEqual(entryWithName.displayName, "Custom Name")
            
            // Without name should use type display name
            XCTAssertEqual(entryWithoutName.displayName, entryType.displayName)
            
            // Both should be non-empty
            XCTAssertFalse(entryWithName.displayName.isEmpty)
            XCTAssertFalse(entryWithoutName.displayName.isEmpty)
        }
    }
}
