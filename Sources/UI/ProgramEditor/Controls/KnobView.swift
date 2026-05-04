// KnobView.swift
// MonstaGuru
// Created by Mistral Vibe Code (Program Editor Agent)

import SwiftUI

/// A circular knob control for adjusting parameter values.
/// Supports drag gestures, double-click to reset, and value display.
public struct KnobView: View {
    
    /// The binding to the value being controlled.
    @Binding public var value: Int
    
    /// The range of valid values.
    public let range: ClosedRange<Int>
    
    /// The step size for fine adjustments.
    public let step: Int
    
    /// The label displayed below the knob.
    public let label: String
    
    /// The color of the knob's indicator.
    public let color: Color
    
    /// The size of the knob.
    public let size: CGFloat
    
    /// Whether to show the numeric value.
    public let showValue: Bool
    
    /// The default value for double-click reset.
    public let defaultValue: Int
    
    /// The formatting for the value display.
    public let valueFormatter: (Int) -> String
    
    @State private var isDragging = false
    @State private var lastLocation: CGPoint = .zero
    
    public init(
        value: Binding<Int>,
        range: ClosedRange<Int> = 0...127,
        step: Int = 1,
        label: String = "",
        color: Color = .accentColor,
        size: CGFloat = 60,
        showValue: Bool = true,
        defaultValue: Int? = nil,
        valueFormatter: @escaping (Int) -> String = { String($0) }
    ) {
        self._value = value
        self.range = range
        self.step = step
        self.label = label
        self.color = color
        self.size = size
        self.showValue = showValue
        self.defaultValue = defaultValue ?? range.lowerBound
        self.valueFormatter = valueFormatter
    }
    
    public var body: some View {
        VStack(spacing: 4) {
            // Knob
            GeometryReader { geometry in
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(
                            Color.secondary.opacity(0.3),
                            lineWidth: 2
                        )
                    
                    // Indicator arc
                    KnobArc(
                        value: normalizedValue,
                        startAngle: -135,
                        endAngle: 135
                    )
                    .stroke(
                        color,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    
                    // Center circle
                    Circle()
                        .fill(Color.primary.opacity(0.1))
                        .overlay(
                            Circle()
                                .stroke(Color.secondary, lineWidth: 1)
                        )
                    
                    // Value indicator line
                    Rectangle()
                        .fill(color)
                        .frame(width: 2, height: size * 0.3)
                        .offset(y: -size * 0.15)
                        .rotationEffect(Angle(degrees: Double(normalizedValue) * 270.0 - 135.0))
                }
                .contentShape(Circle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            handleDrag(gesture, in: geometry.size)
                        }
                        .onEnded { _ in
                            isDragging = false
                        }
                )
                .onTapGesture(count: 2) {
                    value = defaultValue
                }
            }
            .frame(width: size, height: size)
            
            // Label
            if !label.isEmpty {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Value
            if showValue {
                Text(valueFormatter(value))
                    .font(.caption)
                    .foregroundColor(.primary)
                    .monospacedDigit()
            }
        }
        .accessibilityLabel(label)
        .accessibilityValue(valueFormatter(value))
        .accessibilityAddTraits(.isAdjustable)
        .accessibilityAction(named: "Increment") {
            increment()
        }
        .accessibilityAction(named: "Decrement") {
            decrement()
        }
    }
    
    // MARK: - Computed Properties
    
    /// Normalized value (0.0 to 1.0).
    private var normalizedValue: Double {
        guard range.upperBound != range.lowerBound else { return 0.5 }
        return Double(value - range.lowerBound) / Double(range.upperBound - range.lowerBound)
    }
    
    // MARK: - Gesture Handling
    
    private func handleDrag(_ gesture: DragGesture.Value, in size: CGSize) {
        if !isDragging {
            isDragging = true
            lastLocation = gesture.location
            return
        }
        
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let currentLocation = gesture.location
        
        let deltaX = Double(currentLocation.x - lastLocation.x)
        let deltaY = Double(currentLocation.y - lastLocation.y)
        
        // Calculate angle change
        let angleChange = atan2(deltaY, deltaX) * 180.0 / .pi
        
        // Update value based on vertical drag (more intuitive for knobs)
        let valueChange = -deltaY * 0.01 // Scale factor for sensitivity
        
        // Apply step
        let steps = Int(round(valueChange / Double(step)))
        let newValue = value + steps * step
        
        value = min(max(newValue, range.lowerBound), range.upperBound)
        lastLocation = currentLocation
    }
    
    // MARK: - Accessibility Actions
    
    private func increment() {
        value = min(value + step, range.upperBound)
    }
    
    private func decrement() {
        value = max(value - step, range.lowerBound)
    }
}

/// A circular arc shape for the knob indicator.
private struct KnobArc: Shape {
    let value: Double
    let startAngle: Double
    let endAngle: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        let start = Angle(degrees: startAngle)
        let end = Angle(degrees: startAngle + (endAngle - startAngle) * value)
        
        path.addArc(
            center: center,
            radius: radius * 0.8,
            startAngle: start,
            endAngle: end,
            clockwise: false
        )
        
        return path
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        KnobView(
            value: .constant(64),
            range: 0...127,
            label: "Cutoff",
            color: .blue,
            size: 80
        )
        
        KnobView(
            value: .constant(50),
            range: -64...63,
            label: "Pan",
            color: .green,
            size: 60,
            valueFormatter: { $0 >= 0 ? "+$0" : "$0" }
        )
        
        KnobView(
            value: .constant(0),
            range: 0...100,
            step: 5,
            label: "Volume",
            color: .red,
            size: 50,
            valueFormatter: { "$0%" }
        )
    }
    .padding()
    .previewLayout(.sizeThatFits)
}
