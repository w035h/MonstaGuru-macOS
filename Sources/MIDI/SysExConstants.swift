//
//  SysExConstants.swift
//  MonstaGuru-macOS
//
//  Created by Mistral Vibe Code on 2026-05-04.
//

/// Constants for System Exclusive (SysEx) message handling.
/// These constants replace magic numbers throughout the codebase for better maintainability.
enum SysExConstants {
    /// SysEx message start byte (0xF0)
    static let startByte: UInt8 = 0xF0
    
    /// SysEx message end byte (0xF7)
    static let endByte: UInt8 = 0xF7
    
    /// MicroMonsta 2 manufacturer ID
    static let manufacturerID: [UInt8] = [0x00, 0x20, 0x7F]
    
    /// Expected size for a program dump SysEx message
    static let expectedProgramDumpSize = 128
    
    /// Minimum size for a program dump SysEx message
    static let minProgramDumpSize = 128
    
    /// Maximum size for a program dump SysEx message
    static let maxProgramDumpSize = 128
    
    /// Maximum SysEx buffer size to prevent memory exhaustion (64KB)
    static let maxSysExBufferSize = 64 * 1024
    
    /// Timeout for incomplete SysEx messages (in seconds)
    static let sysExTimeoutInterval: TimeInterval = 5.0
}
