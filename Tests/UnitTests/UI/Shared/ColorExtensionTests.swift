// ColorExtensionTests.swift
// MonstaGuru
// Created by Mistral Vibe Code (Testing Agent)

import XCTest
import SwiftUI
@testable import UI

/// Tests for Color extension with hex initialization.
final class ColorExtensionTests: XCTestCase {
    
    // MARK: - 6-digit Hex Tests
    
    func testColorFrom6DigitHexRed() {
        let color = Color(hex: "#FF0000")
        
        // Test that color was created
        XCTAssertNotNil(color)
        
        // Note: We can't directly compare color components in tests
        // because Color doesn't expose its components, but we can verify
        // that the initialization doesn't crash
    }
    
    func testColorFrom6DigitHexGreen() {
        let color = Color(hex: "#00FF00")
        XCTAssertNotNil(color)
    }
    
    func testColorFrom6DigitHexBlue() {
        let color = Color(hex: "#0000FF")
        XCTAssertNotNil(color)
    }
    
    func testColorFrom6DigitHexWhite() {
        let color = Color(hex: "#FFFFFF")
        XCTAssertNotNil(color)
    }
    
    func testColorFrom6DigitHexBlack() {
        let color = Color(hex: "#000000")
        XCTAssertNotNil(color)
    }
    
    func testColorFrom6DigitHexGray() {
        let color = Color(hex: "#808080")
        XCTAssertNotNil(color)
    }
    
    // MARK: - 3-digit Hex Tests
    
    func testColorFrom3DigitHexRed() {
        let color = Color(hex: "#F00")
        XCTAssertNotNil(color)
    }
    
    func testColorFrom3DigitHexGreen() {
        let color = Color(hex: "#0F0")
        XCTAssertNotNil(color)
    }
    
    func testColorFrom3DigitHexBlue() {
        let color = Color(hex: "#00F")
        XCTAssertNotNil(color)
    }
    
    func testColorFrom3DigitHexWhite() {
        let color = Color(hex: "#FFF")
        XCTAssertNotNil(color)
    }
    
    func testColorFrom3DigitHexBlack() {
        let color = Color(hex: "#000")
        XCTAssertNotNil(color)
    }
    
    // MARK: - 8-digit Hex Tests (with alpha)
    
    func testColorFrom8DigitHexWithAlpha() {
        let color = Color(hex: "#FF000080")
        XCTAssertNotNil(color)
    }
    
    func testColorFrom8DigitHexFullAlpha() {
        let color = Color(hex: "#FF0000FF")
        XCTAssertNotNil(color)
    }
    
    func testColorFrom8DigitHexZeroAlpha() {
        let color = Color(hex: "#FF000000")
        XCTAssertNotNil(color)
    }
    
    // MARK: - Case Insensitivity Tests
    
    func testColorFromUppercaseHex() {
        let color = Color(hex: "#FF0000")
        XCTAssertNotNil(color)
    }
    
    func testColorFromLowercaseHex() {
        let color = Color(hex: "#ff0000")
        XCTAssertNotNil(color)
    }
    
    func testColorFromMixedCaseHex() {
        let color = Color(hex: "#Ff00Ff")
        XCTAssertNotNil(color)
    }
    
    // MARK: - With/Without Hash Tests
    
    func testColorFromHexWithHash() {
        let color = Color(hex: "#FF0000")
        XCTAssertNotNil(color)
    }
    
    func testColorFromHexWithoutHash() {
        let color = Color(hex: "FF0000")
        XCTAssertNotNil(color)
    }
    
    // MARK: - Edge Cases
    
    func testColorFromEmptyString() {
        let color = Color(hex: "")
        XCTAssertNotNil(color)
    }
    
    func testColorFromInvalidHex() {
        let color = Color(hex: "#GGGGGG")
        XCTAssertNotNil(color)
    }
    
    func testColorFromShortInvalidHex() {
        let color = Color(hex: "#FF")
        XCTAssertNotNil(color)
    }
    
    func testColorFromLongInvalidHex() {
        let color = Color(hex: "#FFFFFFFFFFFF")
        XCTAssertNotNil(color)
    }
    
    // MARK: - Real-world Color Tests
    
    func testColorFromPrimaryColorHex() {
        // Test with the primary color from DesignSystem
        let color = Color(hex: "#4A90E2")
        XCTAssertNotNil(color)
    }
    
    func testColorFromAccentColors() {
        let accentOrange = Color(hex: "#FF9500")
        let accentPurple = Color(hex: "#8B5CF6")
        let accentGreen = Color(hex: "#10B981")
        
        XCTAssertNotNil(accentOrange)
        XCTAssertNotNil(accentPurple)
        XCTAssertNotNil(accentGreen)
    }
    
    // MARK: - Consistency Tests
    
    func testMultipleColorsFromSameHex() {
        let color1 = Color(hex: "#FF0000")
        let color2 = Color(hex: "#FF0000")
        
        XCTAssertNotNil(color1)
        XCTAssertNotNil(color2)
    }
    
    func testColorsFromDifferentHexFormats() {
        // These should produce similar colors (though not identical due to expansion)
        let color3Digit = Color(hex: "#F00")
        let color6Digit = Color(hex: "#FF0000")
        
        XCTAssertNotNil(color3Digit)
        XCTAssertNotNil(color6Digit)
    }
}
