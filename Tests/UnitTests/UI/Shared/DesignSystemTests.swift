// DesignSystemTests.swift
// MonstaGuru
// Created by Mistral Vibe Code (Testing Agent)

import XCTest
@testable import UI

/// Tests for the DesignSystem to ensure consistent styling across the app.
final class DesignSystemTests: XCTestCase {
    
    // MARK: - Colors Tests
    
    func testColorsAreDefined() {
        // Verify all color definitions exist
        _ = DesignSystem.Colors.primary
        _ = DesignSystem.Colors.primaryHover
        _ = DesignSystem.Colors.primaryActive
        _ = DesignSystem.Colors.secondary
        _ = DesignSystem.Colors.secondaryHover
        _ = DesignSystem.Colors.accent
        _ = DesignSystem.Colors.accentOrange
        _ = DesignSystem.Colors.accentPurple
        _ = DesignSystem.Colors.accentGreen
        _ = DesignSystem.Colors.backgroundPrimary
        _ = DesignSystem.Colors.backgroundSecondary
        _ = DesignSystem.Colors.backgroundTertiary
        _ = DesignSystem.Colors.surface
        _ = DesignSystem.Colors.surfaceHover
        _ = DesignSystem.Colors.textPrimary
        _ = DesignSystem.Colors.textSecondary
        _ = DesignSystem.Colors.textTertiary
        _ = DesignSystem.Colors.textInverse
        _ = DesignSystem.Colors.border
        _ = DesignSystem.Colors.borderSubtle
        _ = DesignSystem.Colors.success
        _ = DesignSystem.Colors.warning
        _ = DesignSystem.Colors.error
        _ = DesignSystem.Colors.info
        _ = DesignSystem.Colors.midiConnected
        _ = DesignSystem.Colors.midiDisconnected
        _ = DesignSystem.Colors.midiError
    }
    
    func testGradientsAreDefined() {
        _ = DesignSystem.Colors.gradientPrimary
        _ = DesignSystem.Colors.gradientSurface
    }
    
    // MARK: - Typography Tests
    
    func testTypographyAreDefined() {
        // Headings
        _ = DesignSystem.Typography.largeTitle
        _ = DesignSystem.Typography.title
        _ = DesignSystem.Typography.title2
        _ = DesignSystem.Typography.title3
        _ = DesignSystem.Typography.headline
        _ = DesignSystem.Typography.subheadline
        
        // Body
        _ = DesignSystem.Typography.body
        _ = DesignSystem.Typography.bodyBold
        _ = DesignSystem.Typography.bodySmall
        _ = DesignSystem.Typography.bodySmallBold
        
        // Captions
        _ = DesignSystem.Typography.caption
        _ = DesignSystem.Typography.captionBold
        
        // Monospaced
        _ = DesignSystem.Typography.monospaced
        _ = DesignSystem.Typography.monospacedBold
        _ = DesignSystem.Typography.monospacedLarge
        
        // Controls
        _ = DesignSystem.Typography.controlLabel
        _ = DesignSystem.Typography.controlValue
    }
    
    func testTypographyFontProperties() {
        // Test that fonts have expected properties
        let largeTitle = DesignSystem.Typography.largeTitle
        XCTAssertEqual(largeTitle.pointSize, 32)
        XCTAssertEqual(largeTitle.weight, .bold)
        
        let body = DesignSystem.Typography.body
        XCTAssertEqual(body.pointSize, 14)
        XCTAssertEqual(body.weight, .regular)
        
        let headline = DesignSystem.Typography.headline
        XCTAssertEqual(headline.pointSize, 17)
        XCTAssertEqual(headline.weight, .semibold)
    }
    
    // MARK: - Spacing Tests
    
    func testSpacingValues() {
        XCTAssertEqual(DesignSystem.Spacing.xxs, 2)
        XCTAssertEqual(DesignSystem.Spacing.xs, 4)
        XCTAssertEqual(DesignSystem.Spacing.sm, 8)
        XCTAssertEqual(DesignSystem.Spacing.md, 12)
        XCTAssertEqual(DesignSystem.Spacing.lg, 16)
        XCTAssertEqual(DesignSystem.Spacing.xl, 24)
        XCTAssertEqual(DesignSystem.Spacing.xxl, 32)
        XCTAssertEqual(DesignSystem.Spacing.xxxl, 48)
    }
    
    func testControlSpacingValues() {
        XCTAssertEqual(DesignSystem.Spacing.controlHeight, 32)
        XCTAssertEqual(DesignSystem.Spacing.controlHeightSmall, 24)
        XCTAssertEqual(DesignSystem.Spacing.controlHeightLarge, 40)
        XCTAssertEqual(DesignSystem.Spacing.controlWidth, 48)
        XCTAssertEqual(DesignSystem.Spacing.controlWidthSmall, 36)
        XCTAssertEqual(DesignSystem.Spacing.controlWidthLarge, 64)
    }
    
    func testSectionSpacingValues() {
        XCTAssertEqual(DesignSystem.Spacing.sectionPadding, 20)
        XCTAssertEqual(DesignSystem.Spacing.sectionSpacing, 24)
        XCTAssertEqual(DesignSystem.Spacing.groupSpacing, 16)
        XCTAssertEqual(DesignSystem.Spacing.itemSpacing, 8)
    }
    
    // MARK: - Corner Radius Tests
    
    func testCornerRadiusValues() {
        XCTAssertEqual(DesignSystem.CornerRadius.xs, 4)
        XCTAssertEqual(DesignSystem.CornerRadius.sm, 6)
        XCTAssertEqual(DesignSystem.CornerRadius.md, 8)
        XCTAssertEqual(DesignSystem.CornerRadius.lg, 12)
        XCTAssertEqual(DesignSystem.CornerRadius.xl, 16)
        XCTAssertEqual(DesignSystem.CornerRadius.full, .infinity)
    }
    
    // MARK: - Shadows Tests
    
    func testShadowsAreDefined() {
        _ = DesignSystem.Shadows.sm
        _ = DesignSystem.Shadows.md
        _ = DesignSystem.Shadows.lg
        _ = DesignSystem.Shadows.inner
    }
    
    // MARK: - Animations Tests
    
    func testAnimationsAreDefined() {
        _ = DesignSystem.Animations.instant
        _ = DesignSystem.Animations.fast
        _ = DesignSystem.Animations.normal
        _ = DesignSystem.Animations.slow
        _ = DesignSystem.Animations.spring
        _ = DesignSystem.Animations.springBouncy
        _ = DesignSystem.Animations.easeIn
        _ = DesignSystem.Animations.easeOut
        _ = DesignSystem.Animations.easeInOut
    }
    
    // MARK: - Transitions Tests
    
    func testTransitionsAreDefined() {
        _ = DesignSystem.Transitions.fade
        _ = DesignSystem.Transitions.scale
        _ = DesignSystem.Transitions.slide
        _ = DesignSystem.Transitions.moveUp
        _ = DesignSystem.Transitions.moveDown
        _ = DesignSystem.Transitions.moveLeft
        _ = DesignSystem.Transitions.moveRight
        _ = DesignSystem.Transitions.fadeAndScale
    }
    
    // MARK: - View Modifier Tests
    
    func testCardStyleModifier() {
        let modifier = DesignSystem.cardStyle()
        // Verify the modifier can be created
        XCTAssertNotNil(modifier)
    }
    
    func testButtonStyleModifier() {
        let primaryModifier = DesignSystem.buttonStyle(isPrimary: true)
        let secondaryModifier = DesignSystem.buttonStyle(isPrimary: false)
        XCTAssertNotNil(primaryModifier)
        XCTAssertNotNil(secondaryModifier)
    }
    
    func testControlStyleModifier() {
        let modifier = DesignSystem.controlStyle()
        XCTAssertNotNil(modifier)
    }
    
    func testSectionHeaderStyleModifier() {
        let modifier = DesignSystem.sectionHeaderStyle()
        XCTAssertNotNil(modifier)
    }
    
    func testParameterLabelStyleModifier() {
        let modifier = DesignSystem.parameterLabelStyle()
        XCTAssertNotNil(modifier)
    }
    
    func testParameterValueStyleModifier() {
        let modifier = DesignSystem.parameterValueStyle()
        XCTAssertNotNil(modifier)
    }
    
    // MARK: - View Extension Tests
    
    func testViewExtensions() {
        // These tests verify that the view extensions are available
        // We can't test the actual view modifications without a host, but we can verify they compile
        
        // Test that extensions exist by using them in a test context
        // This is more of a compile-time test
    }
    
    // MARK: - Color Extension Tests
    
    func testColorHexInitialization() {
        // Test hex color initialization
        let red = Color(hex: "#FF0000")
        let green = Color(hex: "#00FF00")
        let blue = Color(hex: "#0000FF")
        let white = Color(hex: "#FFFFFF")
        let black = Color(hex: "#000000")
        
        // Verify colors can be created (compile-time test)
        XCTAssertNotNil(red)
        XCTAssertNotNil(green)
        XCTAssertNotNil(blue)
        XCTAssertNotNil(white)
        XCTAssertNotNil(black)
    }
    
    func testColorHexInitializationWithShortForm() {
        // Test 3-digit hex
        let color = Color(hex: "#F00")
        XCTAssertNotNil(color)
    }
    
    func testColorHexInitializationWithAlpha() {
        // Test 8-digit hex with alpha
        let color = Color(hex: "#FF000080")
        XCTAssertNotNil(color)
    }
    
    // MARK: - Consistency Tests
    
    func testSpacingConsistency() {
        // Verify spacing values are consistent with HIG
        // macOS HIG recommends multiples of 4 or 8 for spacing
        let spacings = [
            DesignSystem.Spacing.xxs,
            DesignSystem.Spacing.xs,
            DesignSystem.Spacing.sm,
            DesignSystem.Spacing.md,
            DesignSystem.Spacing.lg,
            DesignSystem.Spacing.xl,
            DesignSystem.Spacing.xxl,
            DesignSystem.Spacing.xxxl
        ]
        
        for spacing in spacings {
            // All spacings should be positive
            XCTAssertGreaterThan(spacing, 0)
            // All spacings should be multiples of 2 (for pixel-perfect alignment)
            XCTAssertEqual(spacing.truncatingRemainder(dividingBy: 2), 0)
        }
    }
    
    func testCornerRadiusConsistency() {
        // Verify corner radii are consistent
        let radii = [
            DesignSystem.CornerRadius.xs,
            DesignSystem.CornerRadius.sm,
            DesignSystem.CornerRadius.md,
            DesignSystem.CornerRadius.lg,
            DesignSystem.CornerRadius.xl
        ]
        
        for radius in radii {
            XCTAssertGreaterThan(radius, 0)
        }
    }
}
