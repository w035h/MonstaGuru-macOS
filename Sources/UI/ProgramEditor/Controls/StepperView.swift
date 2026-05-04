// StepperView.swift
// MonstaGuru
// Created by Mistral Vibe Code (Program Editor Agent)

import SwiftUI

/// A stepper control for precise parameter adjustment.
/// Supports +/- buttons, text field input, and keyboard shortcuts.
public struct StepperView: View {
    
    /// The binding to the value being controlled.
    @Binding public var value: Int
    
    /// The range of valid values.
    public let range: ClosedRange<Int>
    
    /// The step size for adjustments.
    public let step: Int
    
    /// The label displayed next to the stepper.
    public let label: String
    
    /// The width of the text field.
    public let textFieldWidth: CGFloat
    
    /// The default value for reset.
    public let defaultValue: Int
    
    /// The formatting for the value display.
    public let valueFormatter: (Int) -> String
    
    @State private var textValue: String = ""
    @FocusState private var isFocused: Bool
    
    public init(
        value: Binding<Int>,
        range: ClosedRange<Int> = 0...127,
        step: Int = 1,
        label: String = "",
        textFieldWidth: CGFloat = 50,
        defaultValue: Int? = nil,
        valueFormatter: @escaping (Int) -> String = { String($0) }
    ) {
        self._value = value
        self.range = range
        self.step = step
        self.label = label
        self.textFieldWidth = textFieldWidth
        self.defaultValue = defaultValue ?? range.lowerBound
        self.valueFormatter = valueFormatter
        self._textValue = State(initialValue: valueFormatter(value.wrappedValue))
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            // Label
            if !label.isEmpty {
                Text(label)
                    .frame(width: 80, alignment: .trailing)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Decrement button
            Button(action: decrement) {
                Image(systemName: "minus")
                    .font(.system(size: 10, weight: .bold))
                    .frame(width: 24, height: 24)
                    .background(
                        Circle()
                            .fill(Color.secondary.opacity(0.2))
                    )
            }
            .buttonStyle(.plain)
            .keyboardShortcut("-", modifiers: [])
            .help("Decrement")
            .disabled(value <= range.lowerBound)
            
            // Text field
            TextField("", text: $textValue, onCommit: commitTextValue)
                .frame(width: textFieldWidth)
                .multilineTextAlignment(.center)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .textFieldStyle(.plain)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.1))
                )
                .focused($isFocused)
                .onChange(of: value) { newValue in
                    if !isFocused {
                        textValue = valueFormatter(newValue)
                    }
                }
                .onTapGesture(count: 2) {
                    value = defaultValue
                    textValue = valueFormatter(defaultValue)
                }
            
            // Increment button
            Button(action: increment) {
                Image(systemName: "plus")
                    .font(.system(size: 10, weight: .bold))
                    .frame(width: 24, height: 24)
                    .background(
                        Circle()
                            .fill(Color.secondary.opacity(0.2))
                    )
            }
            .buttonStyle(.plain)
            .keyboardShortcut("+", modifiers: [])
            .help("Increment")
            .disabled(value >= range.upperBound)
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
    
    // MARK: - Value Handling
    
    private func increment() {
        value = min(value + step, range.upperBound)
        textValue = valueFormatter(value)
    }
    
    private func decrement() {
        value = max(value - step, range.lowerBound)
        textValue = valueFormatter(value)
    }
    
    private func commitTextValue() {
        if let intValue = Int(textValue) {
            value = min(max(intValue, range.lowerBound), range.upperBound)
            textValue = valueFormatter(value)
        } else {
            textValue = valueFormatter(value)
        }
        isFocused = false
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        StepperView(
            value: .constant(64),
            range: 0...127,
            label: "Cutoff",
            textFieldWidth: 40
        )
        
        StepperView(
            value: .constant(50),
            range: -64...63,
            label: "Pan",
            textFieldWidth: 40,
            valueFormatter: { $0 >= 0 ? "+$0" : "$0" }
        )
        
        StepperView(
            value: .constant(75),
            range: 0...100,
            step: 5,
            label: "Volume",
            textFieldWidth: 40,
            valueFormatter: { "$0%" }
        )
        
        StepperView(
            value: .constant(0),
            range: 0...12,
            label: "Octave",
            textFieldWidth: 30
        )
    }
    .padding()
    .previewLayout(.sizeThatFits)
}
