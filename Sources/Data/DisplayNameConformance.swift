// DisplayNameConformance.swift
// MonstaGuru
// Created by Mistral Vibe Code (Program Editor Agent)

import Foundation

/// Protocol for types that have a display name.
public protocol HasDisplayName {
    var displayName: String { get }
}

// MARK: - Oscillator Conformance

extension OscillatorWaveform: HasDisplayName {}

// MARK: - Filter Conformance

extension FilterType: HasDisplayName {}

// MARK: - LFO Conformance

extension LFOWaveform: HasDisplayName {}
extension LFOSync: HasDisplayName {}

// MARK: - Matrix Conformance

extension MatrixSource: HasDisplayName {}
extension MatrixDestination: HasDisplayName {}

// MARK: - Effects Conformance

extension EffectType: HasDisplayName {}

// MARK: - Clipboard Conformance

extension ClipboardEntryType: HasDisplayName {}
