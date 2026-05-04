// MIDIUtilitiesTests.swift
// MonstaGuru
// Created by Mistral Vibe Code (MIDI Integration Agent)

import XCTest
@testable import MIDI

final class MIDIUtilitiesTests: XCTestCase {
    
    // MARK: - Checksum Tests
    
    func testCalculateChecksum() {
        // Test with known values
        let data1: [UInt8] = [0x01, 0x02, 0x03]
        let checksum1 = MIDIUtilities.calculateChecksum(data1)
        XCTAssertEqual(checksum1, 0x06) // 1 + 2 + 3 = 6
        
        let data2: [UInt8] = [0xFF, 0xFF, 0xFF]
        let checksum2 = MIDIUtilities.calculateChecksum(data2)
        XCTAssertEqual(checksum2, 0x7D) // (255 + 255 + 255) % 128 = 49
    }
    
    func testValidateChecksum() {
        // Valid SysEx message with correct checksum
        // F0 00 20 7F 00 01 00 01 [checksum] F7
        // Data bytes: 00 20 7F 00 01 00 01
        // Sum: 0 + 32 + 127 + 0 + 1 + 0 + 1 = 161
        // Checksum: 161 % 128 = 33
        let validMessage: [UInt8] = [0xF0, 0x00, 0x20, 0x7F, 0x00, 0x01, 0x00, 0x01, 0x21, 0xF7]
        XCTAssertTrue(MIDIUtilities.validateChecksum(validMessage))
        
        // Invalid checksum
        let invalidMessage: [UInt8] = [0xF0, 0x00, 0x20, 0x7F, 0x00, 0x01, 0x00, 0x01, 0x00, 0xF7]
        XCTAssertFalse(MIDIUtilities.validateChecksum(invalidMessage))
        
        // Message without F0 and F7
        let noSysEx: [UInt8] = [0x00, 0x20, 0x7F]
        XCTAssertFalse(MIDIUtilities.validateChecksum(noSysEx))
        
        // Empty message
        let emptyMessage: [UInt8] = []
        XCTAssertFalse(MIDIUtilities.validateChecksum(emptyMessage))
    }
    
    // MARK: - Value Conversion Tests
    
    func testValue14BitTo7Bit() {
        let (msb, lsb) = MIDIUtilities.value14BitTo7Bit(0x0000)
        XCTAssertEqual(msb, 0x00)
        XCTAssertEqual(lsb, 0x00)
        
        let (msb2, lsb2) = MIDIUtilities.value14BitTo7Bit(0x7F7F)
        XCTAssertEqual(msb2, 0x7F)
        XCTAssertEqual(lsb2, 0x7F)
        
        let (msb3, lsb3) = MIDIUtilities.value14BitTo7Bit(0x1234)
        XCTAssertEqual(msb3, 0x24) // 0x1234 >> 7 = 0x24
        XCTAssertEqual(lsb3, 0x34) // 0x1234 & 0x7F = 0x34
    }
    
    func testValue7BitTo14Bit() {
        let value1 = MIDIUtilities.value7BitTo14Bit(msb: 0x00, lsb: 0x00)
        XCTAssertEqual(value1, 0x0000)
        
        let value2 = MIDIUtilities.value7BitTo14Bit(msb: 0x7F, lsb: 0x7F)
        XCTAssertEqual(value2, 0x7F7F)
        
        let value3 = MIDIUtilities.value7BitTo14Bit(msb: 0x24, lsb: 0x34)
        XCTAssertEqual(value3, 0x1234)
    }
    
    func testSigned7BitToInt() {
        XCTAssertEqual(MIDIUtilities.signed7BitToInt(0x00), 0)
        XCTAssertEqual(MIDIUtilities.signed7BitToInt(0x3F), 63)
        XCTAssertEqual(MIDIUtilities.signed7BitToInt(0x40), -64)
        XCTAssertEqual(MIDIUtilities.signed7BitToInt(0x7F), -1)
        XCTAssertEqual(MIDIUtilities.signed7BitToInt(0x41), -63)
    }
    
    func testIntToSigned7Bit() {
        XCTAssertEqual(MIDIUtilities.intToSigned7Bit(0), 0x00)
        XCTAssertEqual(MIDIUtilities.intToSigned7Bit(63), 0x3F)
        XCTAssertEqual(MIDIUtilities.intToSigned7Bit(-64), 0x40)
        XCTAssertEqual(MIDIUtilities.intToSigned7Bit(-1), 0x7F)
        XCTAssertEqual(MIDIUtilities.intToSigned7Bit(-63), 0x41)
        
        // Clamping
        XCTAssertEqual(MIDIUtilities.intToSigned7Bit(100), 0x3F) // Clamped to 63
        XCTAssertEqual(MIDIUtilities.intToSigned7Bit(-100), 0x40) // Clamped to -64
    }
    
    // MARK: - MIDI Message Tests
    
    func testMIDIMessageFromBytesNoteOn() {
        let bytes: [UInt8] = [0x90, 0x3C, 0x7F] // Note On, channel 0, note 60 (Middle C), velocity 127
        
        if let message = MIDIMessage.fromBytes(bytes) {
            switch message {
            case .noteOn(let channel, let note, let velocity):
                XCTAssertEqual(channel, 0)
                XCTAssertEqual(note, 60)
                XCTAssertEqual(velocity, 127)
            default:
                XCTFail("Expected noteOn message")
            }
        } else {
            XCTFail("Failed to parse noteOn message")
        }
    }
    
    func testMIDIMessageFromBytesNoteOff() {
        let bytes: [UInt8] = [0x80, 0x3C, 0x40] // Note Off, channel 0, note 60, velocity 64
        
        if let message = MIDIMessage.fromBytes(bytes) {
            switch message {
            case .noteOff(let channel, let note, let velocity):
                XCTAssertEqual(channel, 0)
                XCTAssertEqual(note, 60)
                XCTAssertEqual(velocity, 64)
            default:
                XCTFail("Expected noteOff message")
            }
        } else {
            XCTFail("Failed to parse noteOff message")
        }
    }
    
    func testMIDIMessageFromBytesControlChange() {
        let bytes: [UInt8] = [0xB0, 0x01, 0x7F] // Control Change, channel 0, control 1 (Mod Wheel), value 127
        
        if let message = MIDIMessage.fromBytes(bytes) {
            switch message {
            case .controlChange(let channel, let control, let value):
                XCTAssertEqual(channel, 0)
                XCTAssertEqual(control, 1)
                XCTAssertEqual(value, 127)
            default:
                XCTFail("Expected controlChange message")
            }
        } else {
            XCTFail("Failed to parse controlChange message")
        }
    }
    
    func testMIDIMessageFromBytesProgramChange() {
        let bytes: [UInt8] = [0xC0, 0x2A] // Program Change, channel 0, program 42
        
        if let message = MIDIMessage.fromBytes(bytes) {
            switch message {
            case .programChange(let channel, let program):
                XCTAssertEqual(channel, 0)
                XCTAssertEqual(program, 42)
            default:
                XCTFail("Expected programChange message")
            }
        } else {
            XCTFail("Failed to parse programChange message")
        }
    }
    
    func testMIDIMessageFromBytesPitchBend() {
        let bytes: [UInt8] = [0xE0, 0x00, 0x40] // Pitch Bend, channel 0, value 0 (center)
        
        if let message = MIDIMessage.fromBytes(bytes) {
            switch message {
            case .pitchBend(let channel, let value):
                XCTAssertEqual(channel, 0)
                XCTAssertEqual(value, 0)
            default:
                XCTFail("Expected pitchBend message")
            }
        } else {
            XCTFail("Failed to parse pitchBend message")
        }
        
        let bytes2: [UInt8] = [0xE0, 0x00, 0x7F] // Pitch Bend, channel 0, value +8191
        if let message2 = MIDIMessage.fromBytes(bytes2) {
            switch message2 {
            case .pitchBend(_, let value):
                XCTAssertEqual(value, 8191)
            default:
                XCTFail("Expected pitchBend message")
            }
        } else {
            XCTFail("Failed to parse pitchBend message")
        }
    }
    
    func testMIDIMessageFromBytesSystemExclusive() {
        let bytes: [UInt8] = [0xF0, 0x01, 0x02, 0x03, 0xF7] // SysEx message
        
        if let message = MIDIMessage.fromBytes(bytes) {
            switch message {
            case .systemExclusive(let data):
                XCTAssertEqual(data, bytes)
            default:
                XCTFail("Expected systemExclusive message")
            }
        } else {
            XCTFail("Failed to parse systemExclusive message")
        }
    }
    
    func testMIDIMessageToBytes() {
        let message = MIDIMessage.noteOn(channel: 1, note: 60, velocity: 100)
        let bytes = message.toBytes()
        XCTAssertEqual(bytes, [0x91, 0x3C, 0x64])
        
        let message2 = MIDIMessage.controlChange(channel: 2, control: 64, value: 127)
        let bytes2 = message2.toBytes()
        XCTAssertEqual(bytes2, [0xB2, 0x40, 0x7F])
        
        let message3 = MIDIMessage.programChange(channel: 3, program: 50)
        let bytes3 = message3.toBytes()
        XCTAssertEqual(bytes3, [0xC3, 0x32])
    }
    
    // MARK: - MIDIError Tests
    
    func testMIDIErrorDescriptions() {
        XCTAssertEqual(MIDIError.noInputDevicesAvailable.errorDescription, "No MIDI input devices available")
        XCTAssertEqual(MIDIError.noOutputDevicesAvailable.errorDescription, "No MIDI output devices available")
        XCTAssertEqual(MIDIError.failedToCreateInputPort.errorDescription, "Failed to create MIDI input port")
        XCTAssertEqual(MIDIError.failedToCreateOutputPort.errorDescription, "Failed to create MIDI output port")
        XCTAssertEqual(MIDIError.failedToConnectInputSource.errorDescription, "Failed to connect to MIDI input source")
        XCTAssertEqual(MIDIError.failedToConnectOutputDestination.errorDescription, "Failed to connect to MIDI output destination")
        XCTAssertEqual(MIDIError.failedToSendMessage.errorDescription, "Failed to send MIDI message")
        XCTAssertEqual(MIDIError.invalidSysExMessage.errorDescription, "Invalid SysEx message format")
        XCTAssertEqual(MIDIError.checksumMismatch.errorDescription, "SysEx message checksum mismatch")
        XCTAssertEqual(MIDIError.unsupportedMessageType.errorDescription, "Unsupported MIDI message type")
        XCTAssertEqual(MIDIError.deviceNotFound.errorDescription, "MIDI device not found")
    }
}
