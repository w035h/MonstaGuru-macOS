// DesignSystem.swift
// MonstaGuru
// Created by Mistral Vibe Code (UI/UX Agent)

import SwiftUI

/// Central design system for MonstaGuru, ensuring HIG compliance and consistent styling.
public enum DesignSystem {
    
    // MARK: - Colors
    
    /// Color palette for the app, supporting both light and dark modes.
    public enum Colors {
        // Primary colors
        public static let primary = Color("PrimaryColor", bundle: .main)
        public static let primaryHover = Color("PrimaryColorHover", bundle: .main)
        public static let primaryActive = Color("PrimaryColorActive", bundle: .main)
        
        // Secondary colors
        public static let secondary = Color("SecondaryColor", bundle: .main)
        public static let secondaryHover = Color("SecondaryColorHover", bundle: .main)
        
        // Accent colors
        public static let accent = Color("AccentColor", bundle: .main)
        public static let accentOrange = Color("AccentOrange", bundle: .main)
        public static let accentPurple = Color("AccentPurple", bundle: .main)
        public static let accentGreen = Color("AccentGreen", bundle: .main)
        
        // Background colors
        public static let backgroundPrimary = Color("BackgroundPrimary", bundle: .main)
        public static let backgroundSecondary = Color("BackgroundSecondary", bundle: .main)
        public static let backgroundTertiary = Color("BackgroundTertiary", bundle: .main)
        
        // Surface colors
        public static let surface = Color("SurfaceColor", bundle: .main)
        public static let surfaceHover = Color("SurfaceHover", bundle: .main)
        
        // Text colors
        public static let textPrimary = Color("TextPrimary", bundle: .main)
        public static let textSecondary = Color("TextSecondary", bundle: .main)
        public static let textTertiary = Color("TextTertiary", bundle: .main)
        public static let textInverse = Color("TextInverse", bundle: .main)
        
        // Border colors
        public static let border = Color("BorderColor", bundle: .main)
        public static let borderSubtle = Color("BorderSubtle", bundle: .main)
        
        // Status colors
        public static let success = Color("SuccessColor", bundle: .main)
        public static let warning = Color("WarningColor", bundle: .main)
        public static let error = Color("ErrorColor", bundle: .main)
        public static let info = Color("InfoColor", bundle: .main)
        
        // MIDI status colors
        public static let midiConnected = Color("MIDIConnected", bundle: .main)
        public static let midiDisconnected = Color("MIDIDisconnected", bundle: .main)
        public static let midiError = Color("MIDIError", bundle: .main)
        
        // Gradient colors
        public static let gradientPrimary = LinearGradient(
            gradient: Gradient(colors: [.primary, .primaryHover]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        public static let gradientSurface = LinearGradient(
            gradient: Gradient(colors: [.surface, .backgroundSecondary]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Typography
    
    /// Typography system for the app.
    public enum Typography {
        // Headings
        public static let largeTitle = Font.system(size: 32, weight: .bold, design: .rounded)
        public static let title = Font.system(size: 24, weight: .bold, design: .rounded)
        public static let title2 = Font.system(size: 20, weight: .bold, design: .rounded)
        public static let title3 = Font.system(size: 18, weight: .bold, design: .rounded)
        public static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
        public static let subheadline = Font.system(size: 15, weight: .semibold, design: .rounded)
        
        // Body
        public static let body = Font.system(size: 14, weight: .regular, design: .rounded)
        public static let bodyBold = Font.system(size: 14, weight: .bold, design: .rounded)
        public static let bodySmall = Font.system(size: 12, weight: .regular, design: .rounded)
        public static let bodySmallBold = Font.system(size: 12, weight: .bold, design: .rounded)
        
        // Captions
        public static let caption = Font.system(size: 11, weight: .regular, design: .rounded)
        public static let captionBold = Font.system(size: 11, weight: .bold, design: .rounded)
        
        // Monospaced (for parameter values)
        public static let monospaced = Font.system(size: 12, weight: .regular, design: .monospaced)
        public static let monospacedBold = Font.system(size: 12, weight: .bold, design: .monospaced)
        public static let monospacedLarge = Font.system(size: 14, weight: .regular, design: .monospaced)
        
        // Fixed size for controls
        public static let controlLabel = Font.system(size: 10, weight: .regular, design: .rounded)
        public static let controlValue = Font.system(size: 11, weight: .semibold, design: .monospaced)
    }
    
    // MARK: - Spacing
    
    /// Spacing system for the app.
    public enum Spacing {
        public static let xxs: CGFloat = 2
        public static let xs: CGFloat = 4
        public static let sm: CGFloat = 8
        public static let md: CGFloat = 12
        public static let lg: CGFloat = 16
        public static let xl: CGFloat = 24
        public static let xxl: CGFloat = 32
        public static let xxxl: CGFloat = 48
        
        // Control-specific spacing
        public static let controlHeight: CGFloat = 32
        public static let controlHeightSmall: CGFloat = 24
        public static let controlHeightLarge: CGFloat = 40
        public static let controlWidth: CGFloat = 48
        public static let controlWidthSmall: CGFloat = 36
        public static let controlWidthLarge: CGFloat = 64
        
        // Section spacing
        public static let sectionPadding: CGFloat = 20
        public static let sectionSpacing: CGFloat = 24
        public static let groupSpacing: CGFloat = 16
        public static let itemSpacing: CGFloat = 8
        
        // Grid spacing
        public static let gridSpacing: CGFloat = 12
        public static let gridColumnCount: Int = 4
    }
    
    // MARK: - Corner Radii
    
    /// Corner radius system for the app.
    public enum CornerRadius {
        public static let xs: CGFloat = 4
        public static let sm: CGFloat = 6
        public static let md: CGFloat = 8
        public static let lg: CGFloat = 12
        public static let xl: CGFloat = 16
        public static let full: CGFloat = .infinity
    }
    
    // MARK: - Shadows
    
    /// Shadow system for the app.
    public enum Shadows {
        public static let sm = Shadow(
            color: Colors.border.opacity(0.2),
            radius: 2,
            x: 0,
            y: 1
        )
        
        public static let md = Shadow(
            color: Colors.border.opacity(0.3),
            radius: 4,
            x: 0,
            y: 2
        )
        
        public static let lg = Shadow(
            color: Colors.border.opacity(0.4),
            radius: 8,
            x: 0,
            y: 4
        )
        
        public static let inner = InnerShadow(
            color: Colors.border.opacity(0.2),
            radius: 2,
            x: 0,
            y: 1
        )
    }
    
    // MARK: - Animations
    
    /// Animation system for the app.
    public enum Animations {
        public static let instant = Animation.linear(duration: 0.1)
        public static let fast = Animation.linear(duration: 0.15)
        public static let normal = Animation.linear(duration: 0.2)
        public static let slow = Animation.linear(duration: 0.3)
        public static let spring = Animation.spring(response: 0.3, dampingFraction: 0.6)
        public static let springBouncy = Animation.spring(response: 0.4, dampingFraction: 0.4)
        public static let easeIn = Animation.easeIn(duration: 0.2)
        public static let easeOut = Animation.easeOut(duration: 0.2)
        public static let easeInOut = Animation.easeInOut(duration: 0.2)
    }
    
    // MARK: - Transitions
    
    /// Transition system for the app.
    public enum Transitions {
        public static let fade = AnyTransition.opacity
        public static let scale = AnyTransition.scale
        public static let slide = AnyTransition.slide
        public static let moveUp = AnyTransition.move(edge: .top)
        public static let moveDown = AnyTransition.move(edge: .bottom)
        public static let moveLeft = AnyTransition.move(edge: .leading)
        public static let moveRight = AnyTransition.move(edge: .trailing)
        public static let fadeAndScale = AnyTransition.opacity.combined(with: .scale)
    }
    
    // MARK: - View Modifiers
    
    /// Standard card style for surfaces.
    public static func cardStyle() -> some ViewModifier {
        ViewModifier { view in
            view
                .background(Colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                .shadow(shadow: Shadows.sm)
        }
    }
    
    /// Standard button style.
    public static func buttonStyle(isPrimary: Bool = false) -> some ViewModifier {
        ViewModifier { view in
            view
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(
                    isPrimary ? Colors.primary : Colors.surface
                )
                .foregroundStyle(
                    isPrimary ? Colors.textInverse : Colors.textPrimary
                )
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
                .hoverEffect(
                    isPrimary ? Colors.primaryHover : Colors.surfaceHover
                )
        }
    }
    
    /// Standard control style for knobs, sliders, etc.
    public static func controlStyle() -> some ViewModifier {
        ViewModifier { view in
            view
                .frame(width: Spacing.controlWidth, height: Spacing.controlHeight)
        }
    }
    
    /// Section header style.
    public static func sectionHeaderStyle() -> some ViewModifier {
        ViewModifier { view in
            view
                .font(Typography.headline)
                .foregroundStyle(Colors.textSecondary)
                .textCase(.uppercase)
                .letterSpacing(1.0)
                .padding(.vertical, Spacing.sm)
        }
    }
    
    /// Parameter label style.
    public static func parameterLabelStyle() -> some ViewModifier {
        ViewModifier { view in
            view
                .font(Typography.controlLabel)
                .foregroundStyle(Colors.textTertiary)
                .textCase(.uppercase)
                .letterSpacing(0.5)
        }
    }
    
    /// Parameter value style.
    public static func parameterValueStyle() -> some ViewModifier {
        ViewModifier { view in
            view
                .font(Typography.controlValue)
                .foregroundStyle(Colors.textPrimary)
                .monospacedDigit()
        }
    }
}

// MARK: - Extensions

public extension View {
    /// Applies the card style.
    func cardStyle() -> some View {
        self.modifier(DesignSystem.cardStyle())
    }
    
    /// Applies the button style.
    func buttonStyle(isPrimary: Bool = false) -> some View {
        self.modifier(DesignSystem.buttonStyle(isPrimary: isPrimary))
    }
    
    /// Applies the control style.
    func controlStyle() -> some View {
        self.modifier(DesignSystem.controlStyle())
    }
    
    /// Applies the section header style.
    func sectionHeaderStyle() -> some View {
        self.modifier(DesignSystem.sectionHeaderStyle())
    }
    
    /// Applies the parameter label style.
    func parameterLabelStyle() -> some View {
        self.modifier(DesignSystem.parameterLabelStyle())
    }
    
    /// Applies the parameter value style.
    func parameterValueStyle() -> some View {
        self.modifier(DesignSystem.parameterValueStyle())
    }
    
    /// Adds a hover effect to the view.
    func hoverEffect(_ hoverColor: Color) -> some View {
        #if os(macOS)
        return self.onHover { isHovering in
            self.background(isHovering ? hoverColor : Color.clear)
        }
        #else
        return self
        #endif
    }
    
    /// Adds a press effect to the view.
    func pressEffect(_ pressColor: Color) -> some View {
        #if os(macOS)
        return self.onTapGesture {}
            .onHover { isHovering in
                self.background(isHovering ? pressColor.opacity(0.2) : Color.clear)
            }
        #else
        return self
        #endif
    }
}

// MARK: - Inner Shadow

/// Custom inner shadow for inset effects.
public struct InnerShadow: Shape {
    public var color: Color = .black
    public var radius: CGFloat = 2
    public var x: CGFloat = 0
    public var y: CGFloat = 0
    
    public init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
    
    public func path(in rect: CGRect) -> Path {
        let path = RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md).path(in: rect)
        return path
    }
}

public extension View {
    func innerShadow(_ style: DesignSystem.Shadows) -> some View {
        return self
            .overlay(
                InnerShadow(
                    color: style.color,
                    radius: style.radius,
                    x: style.x,
                    y: style.y
                )
                .fill(style.color)
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
    }
}

// MARK: - Shadow Extension

public extension View {
    func shadow(color: Color = .black, radius: CGFloat = 4, x: CGFloat = 0, y: CGFloat = 2) -> some View {
        self.shadow(color: color.opacity(0.3), radius: radius, x: x, y: y)
    }
    
    func shadow(_ style: DesignSystem.Shadows) -> some View {
        self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}
