// SysExParserTests.swift
// MonstaGuru
// Created by Mistral Vibe Code (MIDI Integration Agent)

import XCTest
@testable import MIDI
@testable import Data

final class SysExParserTests: XCTestCase {
    
    var parser: SysExParser!
    
    override func setUp() {
        super.setUp()
        parser = SysExParser()
    }
    
    override func tearDown() {
        parser = nil
        super.tearDown()
    }
    
    // MARK: - Program Dump Generation Tests
    
    func testGenerateProgramDumpRequest() {
        let message = parser.generateProgramDumpRequest(programNumber: 5)
        
        // Check basic structure
        XCTAssertEqual(message.first, 0xF0)
        XCTAssertEqual(message.last, 0xF7)
        
        // Check manufacturer ID
        XCTAssertEqual(message[1], 0x00)
        XCTAssertEqual(message[2], 0x20)
        XCTAssertEqual(message[3], 0x7F)
        
        // Check message type (program dump request = 0x01)
        XCTAssertEqual(message[5], SysExMessageType.programDumpRequest.rawValue)
        
        // Check program number
        XCTAssertEqual(message[7], 5)
    }
    
    func testGenerateProgramDump() {
        let program = MockProgramGenerator.initProgram()
        let message = parser.generateProgramDump(program: program)
        
        // Check basic structure
        XCTAssertEqual(message.first, 0xF0)
        XCTAssertEqual(message.last, 0xF7)
        
        // Check manufacturer ID
        XCTAssertEqual(message[1], 0x00)
        XCTAssertEqual(message[2], 0x20)
        XCTAssertEqual(message[3], 0x7F)
        
        // Check message type (program dump response = 0x02)
        XCTAssertEqual(message[5], SysExMessageType.programDumpResponse.rawValue)
        
        // Check that the message contains program data (128 bytes) + header + checksum
        XCTAssertGreaterThanOrEqual(message.count, 6 + 128 + 2)
    }
    
    func testGenerateSingleParameterChange() {
        let message = parser.generateSingleParameterChange(
            address: .osc1Waveform,
            value: 2
        )
        
        // Check basic structure
        XCTAssertEqual(message.first, 0xF0)
        XCTAssertEqual(message.last, 0xF7)
        
        // Check message type (single parameter change = 0x03)
        XCTAssertEqual(message[5], SysExMessageType.singleParameterChange.rawValue)
        
        // Check address (0x0000 for osc1Waveform)
        let addressMSB = message[6]
        let addressLSB = message[7]
        let address = (UInt16(addressMSB) << 7) | UInt16(addressLSB)
        XCTAssertEqual(address, ParameterAddress.osc1Waveform.rawValue)
        
        // Check value
        XCTAssertEqual(message[8], 2)
    }
    
    // MARK: - Program Dump Parsing Tests
    
    func testParseProgramDump() {
        // Create a program and generate its SysEx dump
        let originalProgram = MockProgramGenerator.bassProgram()
        let message = parser.generateProgramDump(program: originalProgram)
        
        // Parse the message
        let result = parser.parse(message: message)
        
        switch result {
        case .success(let data):
            if case .programDump(let parsedProgram, _) = data {
                // Check that the parsed program matches the original
                XCTAssertEqual(parsedProgram.name, originalProgram.name)
                XCTAssertEqual(parsedProgram.number, originalProgram.number)
                
                // Check oscillators
                XCTAssertEqual(parsedProgram.oscillators.count, originalProgram.oscillators.count)
                for (originalOsc, parsedOsc) in zip(originalProgram.oscillators, parsedProgram.oscillators) {
                    XCTAssertEqual(originalOsc.waveform, parsedOsc.waveform)
                    XCTAssertEqual(originalOsc.coarsePitch, parsedOsc.coarsePitch)
                    XCTAssertEqual(originalOsc.level, parsedOsc.level)
                }
                
                // Check filters
                XCTAssertEqual(parsedProgram.filters.count, originalProgram.filters.count)
                for (originalFilter, parsedFilter) in zip(originalProgram.filters, parsedProgram.filters) {
                    XCTAssertEqual(originalFilter.type, parsedFilter.type)
                    XCTAssertEqual(originalFilter.cutoff, parsedFilter.cutoff)
                }
                
            } else {
                XCTFail("Expected programDump result")
            }
        case .failure(let error):
            XCTFail("Parsing failed: \(error.localizedDescription)")
        }
    }
    
    func testParseSingleParameterChange() {
        // Generate a single parameter change message
        let message = parser.generateSingleParameterChange(
            address: .filter1Cutoff,
            value: 64
        )
        
        // Parse the message
        let result = parser.parse(message: message)
        
        switch result {
        case .success(let data):
            if case .singleParameterChange(let address, let value) = data {
                XCTAssertEqual(address, .filter1Cutoff)
                XCTAssertEqual(value, 64)
            } else {
                XCTFail("Expected singleParameterChange result")
            }
        case .failure(let error):
            XCTFail("Parsing failed: \(error.localizedDescription)")
        }
    }
    
    func testParseProgramDumpRequest() {
        // Generate a program dump request
        let message = parser.generateProgramDumpRequest(programNumber: 10)
        
        // Parse the message
        let result = parser.parse(message: message)
        
        switch result {
        case .success(let data):
            if case .programDumpRequest(let subStatus, let programNumber) = data {
                XCTAssertEqual(subStatus, SysExSubStatus.currentProgram.rawValue)
                XCTAssertEqual(programNumber, 10)
            } else {
                XCTFail("Expected programDumpRequest result")
            }
        case .failure(let error):
            XCTFail("Parsing failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testParseInvalidSysExMessage() {
        // Invalid message (too short)
        let invalidMessage: [UInt8] = [0xF0, 0x00]
        let result = parser.parse(message: invalidMessage)
        
        if case .failure(let error) = result {
            XCTAssertEqual(error, SysExError.invalidSysExMessage)
        } else {
            XCTFail("Expected invalidSysExMessage error")
        }
    }
    
    func testParseUnsupportedManufacturer() {
        // Message with wrong manufacturer ID
        let wrongManufacturerMessage: [UInt8] = [0xF0, 0x01, 0x02, 0x03, 0x00, 0x01, 0x00, 0x00, 0xF7]
        let result = parser.parse(message: wrongManufacturerMessage)
        
        if case .failure(let error) = result {
            XCTAssertEqual(error, SysExError.unsupportedManufacturer)
        } else {
            XCTFail("Expected unsupportedManufacturer error")
        }
    }
    
    func testParseDeviceIDMismatch() {
        // Create parser with device ID 0x01
        let parser = SysExParser(deviceID: 0x01)
        
        // Generate message with device ID 0x00
        let message = parser.generateProgramDumpRequest(programNumber: 0)
        // Manually change the device ID in the message
        var modifiedMessage = message
        modifiedMessage[4] = 0x02 // Different device ID
        
        let result = parser.parse(message: modifiedMessage)
        
        if case .failure(let error) = result {
            XCTAssertEqual(error, SysExError.deviceIDMismatch)
        } else {
            XCTFail("Expected deviceIDMismatch error")
        }
    }
    
    func testParseChecksumMismatch() {
        // Generate a valid message
        let message = parser.generateProgramDumpRequest(programNumber: 0)
        
        // Corrupt the checksum
        var modifiedMessage = message
        modifiedMessage[modifiedMessage.count - 2] = 0x00 // Wrong checksum
        
        let result = parser.parse(message: modifiedMessage)
        
        if case .failure(let error) = result {
            XCTAssertEqual(error, SysExError.checksumMismatch)
        } else {
            XCTFail("Expected checksumMismatch error")
        }
    }
    
    func testParseUnsupportedMessageType() {
        // Message with unsupported message type
        let message: [UInt8] = [0xF0, 0x00, 0x20, 0x7F, 0x00, 0xFF, 0x00, 0xF7]
        let result = parser.parse(message: message)
        
        if case .failure(let error) = result {
            XCTAssertEqual(error, SysExError.unsupportedMessageType)
        } else {
            XCTFail("Expected unsupportedMessageType error")
        }
    }
    
    // MARK: - Round-Trip Tests
    
    func testProgramRoundTrip() {
        // Test that a program can be generated and parsed back correctly
        let programs = MockProgramGenerator.mockPrograms()
        
        for program in programs {
            let message = parser.generateProgramDump(program: program)
            let result = parser.parse(message: message)
            
            switch result {
            case .success(let data):
                if case .programDump(let parsedProgram, _) = data {
                    // Check name and number
                    XCTAssertEqual(parsedProgram.name, program.name)
                    XCTAssertEqual(parsedProgram.number, program.number)
                    
                    // Check oscillators
                    for i in 0..<3 {
                        let original = program.oscillators[i]
                        let parsed = parsedProgram.oscillators[i]
                        XCTAssertEqual(original.waveform, parsed.waveform)
                        XCTAssertEqual(original.coarsePitch, parsed.coarsePitch)
                        XCTAssertEqual(original.finePitch, parsed.finePitch)
                        XCTAssertEqual(original.level, parsed.level)
                    }
                    
                    // Check filters
                    for i in 0..<2 {
                        let original = program.filters[i]
                        let parsed = parsedProgram.filters[i]
                        XCTAssertEqual(original.type, parsed.type)
                        XCTAssertEqual(original.cutoff, parsed.cutoff)
                        XCTAssertEqual(original.resonance, parsed.resonance)
                    }
                    
                    // Check envelopes
                    for i in 0..<3 {
                        let original = program.envelopes[i]
                        let parsed = parsedProgram.envelopes[i]
                        XCTAssertEqual(original.attack, parsed.attack)
                        XCTAssertEqual(original.decay, parsed.decay)
                        XCTAssertEqual(original.sustain, parsed.sustain)
                        XCTAssertEqual(original.release, parsed.release)
                    }
                    
                    // Check global settings
                    XCTAssertEqual(program.global.polyphony, parsedProgram.global.polyphony)
                    XCTAssertEqual(program.global.masterVolume, parsedProgram.global.masterVolume)
                } else {
                    XCTFail("Expected programDump result for \(program.name)")
                }
            case .failure(let error):
                XCTFail("Round-trip failed for \(program.name): \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - SysEx Error Tests
    
    func testSysExErrorDescriptions() {
        XCTAssertEqual(SysExError.invalidSysExMessage.errorDescription, "Invalid SysEx message format")
        XCTAssertEqual(SysExError.unsupportedManufacturer.errorDescription, "Unsupported manufacturer ID")
        XCTAssertEqual(SysExError.deviceIDMismatch.errorDescription, "Device ID mismatch")
        XCTAssertEqual(SysExError.invalidProgramData.errorDescription, "Invalid program data")
        XCTAssertEqual(SysExError.checksumMismatch.errorDescription, "SysEx checksum mismatch")
        XCTAssertEqual(SysExError.unsupportedMessageType.errorDescription, "Unsupported SysEx message type")
        
        let error = SysExError.unknownParameterAddress(address: 0x1234)
        XCTAssertEqual(error.errorDescription, "Unknown parameter address: 0x1234")
    }
}
