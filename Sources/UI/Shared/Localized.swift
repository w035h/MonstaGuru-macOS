//
//  Localized.swift
//  MonstaGuru-macOS
//
//  Created by Mistral Vibe Code on 2026-05-04.
//

import Foundation

/// Localized strings and constants for the application.
/// Centralizes all user-facing strings for easier localization and maintenance.
enum Localized {
    /// Application name
    static let appName = "MonstaGuru"
    
    /// MIDI client name
    static let midiClientName = NSLocalizedString("MonstaGuru", comment: "MIDI client name")
    
    /// Error messages
    static let midiErrorDomain = "com.monstaguru.midi"
    static let invalidSysExMessage = NSLocalizedString("Invalid SysEx message", comment: "SysEx error")
    static let unsupportedManufacturer = NSLocalizedString("Unsupported manufacturer", comment: "SysEx error")
    static let deviceIDMismatch = NSLocalizedString("Device ID mismatch", comment: "SysEx error")
    static let bufferOverflow = NSLocalizedString("SysEx buffer overflow detected", comment: "Buffer error")
    static let messageTimeout = NSLocalizedString("SysEx message timeout", comment: "Timeout error")
    
    /// MIDI Thru
    static let midiThruError = NSLocalizedString("MIDI Thru error", comment: "MIDI Thru error")
}
