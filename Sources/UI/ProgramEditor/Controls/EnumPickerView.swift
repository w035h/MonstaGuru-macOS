// EnumPickerView.swift
// MonstaGuru
// Created by Mistral Vibe Code (Program Editor Agent)

import SwiftUI
import Data

/// A picker control for selecting from an enum with display names.
/// Supports both popup and segmented styles.
public struct EnumPickerView<EnumType: RawRepresentable & CaseIterable & Identifiable & HasDisplayName>: View 
where EnumType.RawValue: Hashable, EnumType.AllCases: RandomAccessCollection {
    
    /// The binding to the selected value.
    @Binding public var selection: EnumType
    
    /// The label displayed next to the picker.
    public let label: String
    
    /// The style of the picker.
    public let style: PickerStyle
    
    public init(
        selection: Binding<EnumType>,
        label: String = "",
        style: PickerStyle = .menu
    ) {
        self._selection = selection
        self.label = label
        self.style = style
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            if !label.isEmpty {
                Text(label)
                    .frame(width: 80, alignment: .trailing)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Picker("", selection: $selection) {
                ForEach(Array(EnumType.allCases), id: \.id) { value in
                    Text(value.displayName)
                        .tag(value)
                }
            }
            .pickerStyle(style)
            .labelsHidden()
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        EnumPickerView(
            selection: .constant(OscillatorWaveform.sawtooth),
            label: "Waveform",
            style: .menu
        )
        
        EnumPickerView(
            selection: .constant(FilterType.lowPass24dB),
            label: "Filter Type",
            style: .menu
        )
        
        EnumPickerView(
            selection: .constant(LFOWaveform.sine),
            label: "LFO Waveform",
            style: .segmented
        )
    }
    .padding()
    .previewLayout(.sizeThatFits)
}
