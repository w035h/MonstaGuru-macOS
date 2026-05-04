// SliderView.swift
// MonstaGuru
// Created by Mistral Vibe Code (Program Editor Agent)

import SwiftUI

/// A horizontal slider control for adjusting parameter values.
/// Supports drag gestures, double-click to reset, and value display.
public struct SliderView: View {
    
    /// The binding to the value being controlled.
    @Binding public var value: Int
    
    /// The range of valid values.
    public let range: ClosedRange<Int>
    
    /// The step size for fine adjustments.
    public let step: Int
    
    /// The label displayed above the slider.
    public let label: String
    
    /// The color of the slider's track.
    public let color: Color
    
    /// The height of the slider track.
    public let trackHeight: CGFloat
    
    /// Whether to show the numeric value.
    public let showValue: Bool
    
    /// The default value for double-click reset.
    public let defaultValue: Int
    
    /// The formatting for the value display.
    public let valueFormatter: (Int) -> String
    
    @State private var isDragging = false
    
    public init(
        value: Binding<Int>,
        range: ClosedRange<Int> = 0...127,
        step: Int = 1,
        label: String = "",
        color: Color = .accentColor,
        trackHeight: CGFloat = 6,
        showValue: Bool = true,
        defaultValue: Int? = nil,
        valueFormatter: @escaping (Int) -> String = { String($0) }
    ) {
        self._value = value
        self.range = range
        self.step = step
        self.label = label
        self.color = color
        self.trackHeight = trackHeight
        self.showValue = showValue
        self.defaultValue = defaultValue ?? range.lowerBound
        self.valueFormatter = valueFormatter
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header with label and value
            if !label.isEmpty || showValue {
                HStack {
                    if !label.isEmpty {
                        Text(label)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if showValue {
                        Text(valueFormatter(value))
                            .font(.caption)
                            .foregroundColor(.primary)
                            .monospacedDigit()
                    }
                }
            }
            
            // Slider track
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .cornerRadius(trackHeight / 2)
                    
                    // Active track
                    Rectangle()
                        .fill(color)
                        .frame(width: CGFloat(normalizedValue) * geometry.size.width)
                        .cornerRadius(trackHeight / 2)
                    
                    // Thumb
                    Circle()
                        .fill(Color.white)
                        .frame(width: trackHeight * 1.5, height: trackHeight * 1.5)
                        .shadow(radius: 2)
                        .offset(x: CGFloat(normalizedValue) * geometry.size.width - trackHeight * 1.5 / 2)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { gesture in
                                    handleDrag(gesture, in: geometry.size)
                                }
                                .onEnded { _ in
                                    isDragging = false
                                }
                        )
                }
                .contentShape(Rectangle())
                .onTapGesture { location in
                    handleTap(location, in: geometry.size)
                }
                .onTapGesture(count: 2) {
                    value = defaultValue
                }
            }
            .frame(height: trackHeight * 1.5)
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
        let location = gesture.location.x
        updateValue(from: location, in: size)
    }
    
    private func handleTap(_ location: CGPoint, in size: CGSize) {
        updateValue(from: location.x, in: size)
    }
    
    private func updateValue(from x: CGFloat, in size: CGSize) {
        let normalized = Double(x / size.width)
        let rangeSize = range.upperBound - range.lowerBound
        let newValue = Int(round(normalized * Double(rangeSize))) + range.lowerBound
        
        // Apply step
        let steps = round(Double(newValue - range.lowerBound) / Double(step))
        value = Int(steps * Double(step)) + range.lowerBound
        value = min(max(value, range.lowerBound), range.upperBound)
    }
    
    // MARK: - Accessibility Actions
    
    private func increment() {
        value = min(value + step, range.upperBound)
    }
    
    private func decrement() {
        value = max(value - step, range.lowerBound)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        SliderView(
            value: .constant(64),
            range: 0...127,
            label: "Cutoff",
            color: .blue
        )
        
        SliderView(
            value: .constant(50),
            range: -64...63,
            label: "Pan",
            color: .green,
            valueFormatter: { $0 >= 0 ? "+$0" : "$0" }
        )
        
        SliderView(
            value: .constant(75),
            range: 0...100,
            step: 5,
            label: "Volume",
            color: .red,
            valueFormatter: { "$0%" }
        )
        
        SliderView(
            value: .constant(0),
            range: 0...127,
            label: "",
            color: .orange,
            showValue: false
        )
    }
    .padding()
    .previewLayout(.sizeThatFits)
}
