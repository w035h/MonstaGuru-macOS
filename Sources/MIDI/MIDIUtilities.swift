// MIDIUtilities.swift
// MonstaGuru
// Created by Mistral Vibe Code (MIDI Integration Agent)

import Foundation
import CoreMIDI

/// MIDI Channel numbers (1-16, 0 = Omni).
public typealias MIDIChannel = UInt8

/// MIDI Note numbers (0-127, 60 = Middle C).
public typealias MIDINote = UInt8

/// MIDI Velocity values (0-127).
public typealias MIDIVelocity = UInt8

/// MIDI Control Change numbers (0-127).
public typealias MIDIControl = UInt8

/// MIDI Program Change numbers (0-127).
public typealias MIDIProgram = UInt8

/// MIDI Pitch Bend values (-8192 to +8191, 0 = center).
public typealias MIDIPitchBend = Int16

/// MIDI Status Bytes (first byte of MIDI messages).
public enum MIDIStatus: UInt8 {
    case noteOff = 0x80
    case noteOn = 0x90
    case polyphonicAftertouch = 0xA0
    case controlChange = 0xB0
    case programChange = 0xC0
    case channelAftertouch = 0xD0
    case pitchBend = 0xE0
    case systemExclusive = 0xF0
    case timeCodeQuarterFrame = 0xF1
    case songPositionPointer = 0xF2
    case songSelect = 0xF3
    case tuneRequest = 0xF6
    case timingClock = 0xF8
    case start = 0xFA
    case continueSequence = 0xFB
    case stop = 0xFC
    case activeSensing = 0xFE
    case reset = 0xFF
}

/// MIDI Control Change numbers.
public enum MIDIControlChange: UInt8 {
    case bankSelectMSB = 0x00
    case modulationWheelMSB = 0x01
    case breathControllerMSB = 0x02
    case footControllerMSB = 0x04
    case portamentoTimeMSB = 0x05
    case dataEntryMSB = 0x06
    case channelVolumeMSB = 0x07
    case balanceMSB = 0x08
    case panMSB = 0x0A
    case expressionControllerMSB = 0x0B
    case effectControl1MSB = 0x0C
    case effectControl2MSB = 0x0D
    case generalPurposeController1MSB = 0x10
    case generalPurposeController2MSB = 0x11
    case generalPurposeController3MSB = 0x12
    case generalPurposeController4MSB = 0x13
    case bankSelectLSB = 0x20
    case modulationWheelLSB = 0x21
    case breathControllerLSB = 0x22
    case footControllerLSB = 0x24
    case portamentoTimeLSB = 0x25
    case dataEntryLSB = 0x26
    case channelVolumeLSB = 0x27
    case balanceLSB = 0x28
    case panLSB = 0x2A
    case expressionControllerLSB = 0x2B
    case effectControl1LSB = 0x2C
    case effectControl2LSB = 0x2D
    case generalPurposeController1LSB = 0x30
    case generalPurposeController2LSB = 0x31
    case generalPurposeController3LSB = 0x32
    case generalPurposeController4LSB = 0x33
    case sustainPedal = 0x40
    case portamentoOnOff = 0x41
    case sostenutoOnOff = 0x42
    case softPedalOnOff = 0x43
    case legatoFootSwitch = 0x44
    case hold2FootSwitch = 0x45
    case soundController1 = 0x46
    case soundController2 = 0x47
    case soundController3 = 0x48
    case soundController4 = 0x49
    case soundController5 = 0x4A
    case soundController6 = 0x4B
    case soundController7 = 0x4C
    case soundController8 = 0x4D
    case soundController9 = 0x4E
    case soundController10 = 0x4F
    case generalPurposeController5MSB = 0x50
    case generalPurposeController6MSB = 0x51
    case generalPurposeController7MSB = 0x52
    case generalPurposeController8MSB = 0x53
    case generalPurposeController5LSB = 0x58
    case generalPurposeController6LSB = 0x59
    case generalPurposeController7LSB = 0x5A
    case generalPurposeController8LSB = 0x5B
    case damperPedalOnOff = 0x5C
    case portamentoControl = 0x5D
    case highResolutionVelocityPrefix = 0x5E
    case effects1Depth = 0x5F
    case effects2Depth = 0x60
    case effects3Depth = 0x61
    case effects4Depth = 0x62
    case effects5Depth = 0x63
    case dataIncrement = 0x64
    case dataDecrement = 0x65
    case nonRegisteredParameterNumberLSB = 0x66
    case nonRegisteredParameterNumberMSB = 0x67
    case registeredParameterNumberLSB = 0x68
    case registeredParameterNumberMSB = 0x69
    case allSoundOff = 0x78
    case resetAllControllers = 0x79
    case localControlOnOff = 0x7A
    case allNotesOff = 0x7B
    case omniModeOff = 0x7C
    case omniModeOn = 0x7D
    case monoModeOn = 0x7E
    case polyModeOn = 0x7F
}

/// MIDI Message types for easier handling.
public enum MIDIMessage {
    case noteOff(channel: MIDIChannel, note: MIDINote, velocity: MIDIVelocity)
    case noteOn(channel: MIDIChannel, note: MIDINote, velocity: MIDIVelocity)
    case polyphonicAftertouch(channel: MIDIChannel, note: MIDINote, pressure: MIDIVelocity)
    case controlChange(channel: MIDIChannel, control: MIDIControl, value: MIDIVelocity)
    case programChange(channel: MIDIChannel, program: MIDIProgram)
    case channelAftertouch(channel: MIDIChannel, pressure: MIDIVelocity)
    case pitchBend(channel: MIDIChannel, value: MIDIPitchBend)
    case systemExclusive(data: [UInt8])
    case timeCodeQuarterFrame(type: UInt8, values: UInt8)
    case songPositionPointer(position: UInt16)
    case songSelect(song: UInt8)
    case tuneRequest
    case timingClock
    case start
    case continueSequence
    case stop
    case activeSensing
    case reset
    case unknown(status: UInt8, data1: UInt8?, data2: UInt8?)
    
    /// Parses raw MIDI bytes into a MIDIMessage.
    public static func fromBytes(_ bytes: [UInt8]) -> MIDIMessage? {
        guard !bytes.isEmpty else { return nil }
        
        let status = bytes[0]
        let statusByte = status & 0xF0 // Mask out channel for status type
        
        if let statusType = MIDIStatus(rawValue: statusByte) {
            switch statusType {
            case .noteOff:
                guard bytes.count >= 3 else { return nil }
                return .noteOff(
                    channel: status & 0x0F,
                    note: bytes[1],
                    velocity: bytes[2]
                )
            case .noteOn:
                guard bytes.count >= 3 else { return nil }
                return .noteOn(
                    channel: status & 0x0F,
                    note: bytes[1],
                    velocity: bytes[2]
                )
            case .polyphonicAftertouch:
                guard bytes.count >= 3 else { return nil }
                return .polyphonicAftertouch(
                    channel: status & 0x0F,
                    note: bytes[1],
                    pressure: bytes[2]
                )
            case .controlChange:
                guard bytes.count >= 3 else { return nil }
                return .controlChange(
                    channel: status & 0x0F,
                    control: bytes[1],
                    value: bytes[2]
                )
            case .programChange:
                guard bytes.count >= 2 else { return nil }
                return .programChange(
                    channel: status & 0x0F,
                    program: bytes[1]
                )
            case .channelAftertouch:
                guard bytes.count >= 2 else { return nil }
                return .channelAftertouch(
                    channel: status & 0x0F,
                    pressure: bytes[1]
                )
            case .pitchBend:
                guard bytes.count >= 3 else { return nil }
                let lsb = UInt16(bytes[1])
                let msb = UInt16(bytes[2])
                let value = Int16((msb << 7) | lsb) - 8192
                return .pitchBend(
                    channel: status & 0x0F,
                    value: value
                )
            case .systemExclusive:
                // SysEx messages start with F0 and end with F7
                // The entire message including F0 and F7 is included
                return .systemExclusive(data: bytes)
            case .timeCodeQuarterFrame:
                guard bytes.count >= 2 else { return nil }
                return .timeCodeQuarterFrame(type: bytes[1] & 0x70, values: bytes[1] & 0x0F)
            case .songPositionPointer:
                guard bytes.count >= 3 else { return nil }
                let position = (UInt16(bytes[1]) << 7) | UInt16(bytes[2])
                return .songPositionPointer(position: position)
            case .songSelect:
                guard bytes.count >= 2 else { return nil }
                return .songSelect(song: bytes[1])
            case .tuneRequest:
                return .tuneRequest
            case .timingClock:
                return .timingClock
            case .start:
                return .start
            case .continueSequence:
                return .continueSequence
            case .stop:
                return .stop
            case .activeSensing:
                return .activeSensing
            case .reset:
                return .reset
            }
        }
        
        return nil
    }
    
    /// Converts the message to raw MIDI bytes.
    public func toBytes() -> [UInt8] {
        switch self {
        case .noteOff(let channel, let note, let velocity):
            return [MIDIStatus.noteOff.rawValue | channel, note, velocity]
        case .noteOn(let channel, let note, let velocity):
            return [MIDIStatus.noteOn.rawValue | channel, note, velocity]
        case .polyphonicAftertouch(let channel, let note, let pressure):
            return [MIDIStatus.polyphonicAftertouch.rawValue | channel, note, pressure]
        case .controlChange(let channel, let control, let value):
            return [MIDIStatus.controlChange.rawValue | channel, control, value]
        case .programChange(let channel, let program):
            return [MIDIStatus.programChange.rawValue | channel, program]
        case .channelAftertouch(let channel, let pressure):
            return [MIDIStatus.channelAftertouch.rawValue | channel, pressure]
        case .pitchBend(let channel, let value):
            let bendValue = UInt16(value + 8192)
            let lsb = UInt8(bendValue & 0x7F)
            let msb = UInt8((bendValue >> 7) & 0x7F)
            return [MIDIStatus.pitchBend.rawValue | channel, lsb, msb]
        case .systemExclusive(let data):
            return data
        case .timeCodeQuarterFrame(let type, let values):
            return [MIDIStatus.timeCodeQuarterFrame.rawValue, type | values]
        case .songPositionPointer(let position):
            let lsb = UInt8(position & 0x7F)
            let msb = UInt8((position >> 7) & 0x7F)
            return [MIDIStatus.songPositionPointer.rawValue, lsb, msb]
        case .songSelect(let song):
            return [MIDIStatus.songSelect.rawValue, song]
        case .tuneRequest:
            return [MIDIStatus.tuneRequest.rawValue]
        case .timingClock:
            return [MIDIStatus.timingClock.rawValue]
        case .start:
            return [MIDIStatus.start.rawValue]
        case .continueSequence:
            return [MIDIStatus.continueSequence.rawValue]
        case .stop:
            return [MIDIStatus.stop.rawValue]
        case .activeSensing:
            return [MIDIStatus.activeSensing.rawValue]
        case .reset:
            return [MIDIStatus.reset.rawValue]
        case .unknown(let status, let data1, let data2):
            var bytes: [UInt8] = [status]
            if let data1 = data1 { bytes.append(data1) }
            if let data2 = data2 { bytes.append(data2) }
            return bytes
        }
    }
}

/// MIDI Device information.
public struct MIDIDevice {
    public let endpoint: MIDIEndpointRef
    public let name: String
    public let isInput: Bool
    
    public init(endpoint: MIDIEndpointRef) {
        self.endpoint = endpoint
        
        var namePtr: Unmanaged<CFString>?
        MIDIObjectGetStringProperty(endpoint, kMIDIPropertyName, &namePtr)
        self.name = namePtr?.takeRetainedValue() as String? ?? "Unknown Device"
        
        var isInputValue: DarwinBoolean = false
        MIDIObjectGetIntegerProperty(endpoint, kMIDIPropertyIsInput, &isInputValue)
        self.isInput = isInputValue.boolValue
    }
}

/// MIDI Connection error types.
public enum MIDIError: Error, LocalizedError {
    case noInputDevicesAvailable
    case noOutputDevicesAvailable
    case failedToCreateInputPort
    case failedToCreateOutputPort
    case failedToConnectInputSource
    case failedToConnectOutputDestination
    case failedToSendMessage
    case invalidSysExMessage
    case checksumMismatch
    case unsupportedMessageType
    case deviceNotFound
    
    public var errorDescription: String? {
        switch self {
        case .noInputDevicesAvailable: return "No MIDI input devices available"
        case .noOutputDevicesAvailable: return "No MIDI output devices available"
        case .failedToCreateInputPort: return "Failed to create MIDI input port"
        case .failedToCreateOutputPort: return "Failed to create MIDI output port"
        case .failedToConnectInputSource: return "Failed to connect to MIDI input source"
        case .failedToConnectOutputDestination: return "Failed to connect to MIDI output destination"
        case .failedToSendMessage: return "Failed to send MIDI message"
        case .invalidSysExMessage: return "Invalid SysEx message format"
        case .checksumMismatch: return "SysEx message checksum mismatch"
        case .unsupportedMessageType: return "Unsupported MIDI message type"
        case .deviceNotFound: return "MIDI device not found"
        }
    }
}

/// Utility functions for MIDI data manipulation.
public enum MIDIUtilities {
    
    /// Calculates the checksum for a SysEx message (sum of all data bytes modulo 128).
    /// - Parameter data: The data bytes (excluding F0 and F7).
    /// - Returns: The checksum byte.
    public static func calculateChecksum(_ data: [UInt8]) -> UInt8 {
        var sum: UInt16 = 0
        for byte in data {
            sum += UInt16(byte)
        }
        return UInt8(sum % 128)
    }
    
    /// Validates the checksum of a SysEx message.
    /// - Parameter message: The complete SysEx message including F0 and F7.
    /// - Returns: True if the checksum is valid.
    public static func validateChecksum(_ message: [UInt8]) -> Bool {
        guard message.count > 3, message.first == 0xF0, message.last == 0xF7 else {
            return false
        }
        
        // Extract data bytes (excluding F0 and F7)
        let dataBytes = Array(message[1..<message.count-1])
        guard !dataBytes.isEmpty else { return false }
        
        // The checksum is the last byte before F7
        let receivedChecksum = dataBytes.last!
        let calculatedChecksum = calculateChecksum(Array(dataBytes.dropLast()))
        
        return receivedChecksum == calculatedChecksum
    }
    
    /// Converts a 14-bit value to two 7-bit bytes (MSB, LSB).
    public static func value14BitTo7Bit(_ value: UInt16) -> (msb: UInt8, lsb: UInt8) {
        let msb = UInt8((value >> 7) & 0x7F)
        let lsb = UInt8(value & 0x7F)
        return (msb, lsb)
    }
    
    /// Converts two 7-bit bytes (MSB, LSB) to a 14-bit value.
    public static func value7BitTo14Bit(msb: UInt8, lsb: UInt8) -> UInt16 {
        return (UInt16(msb) << 7) | UInt16(lsb)
    }
    
    /// Converts a signed 7-bit value (-64 to +63) to a signed integer.
    public static func signed7BitToInt(_ value: UInt8) -> Int {
        if value < 64 {
            return Int(value)
        } else {
            return Int(value) - 128
        }
    }
    
    /// Converts a signed integer to a signed 7-bit value (-64 to +63).
    public static func intToSigned7Bit(_ value: Int) -> UInt8 {
        var clamped = max(-64, min(63, value))
        if clamped < 0 {
            clamped += 128
        }
        return UInt8(clamped)
    }
    
    /// Gets all available MIDI input devices.
    public static func availableInputDevices() -> [MIDIDevice] {
        var devices: [MIDIDevice] = []
        let count = MIDIGetNumberOfDevices()
        
        for deviceIndex in 0..<count {
            let device = MIDIGetDevice(deviceIndex)
            let endpointCount = MIDIDeviceGetNumberOfEntities(device)
            
            for entityIndex in 0..<endpointCount {
                let entity = MIDIDeviceGetEntity(device, entityIndex)
                let sourceCount = MIDIEntityGetNumberOfSources(entity)
                
                for sourceIndex in 0..<sourceCount {
                    let endpoint = MIDIEntityGetSource(entity, sourceIndex)
                    devices.append(MIDIDevice(endpoint: endpoint))
                }
            }
        }
        
        return devices
    }
    
    /// Gets all available MIDI output devices.
    public static func availableOutputDevices() -> [MIDIDevice] {
        var devices: [MIDIDevice] = []
        let count = MIDIGetNumberOfDevices()
        
        for deviceIndex in 0..<count {
            let device = MIDIGetDevice(deviceIndex)
            let endpointCount = MIDIDeviceGetNumberOfEntities(device)
            
            for entityIndex in 0..<endpointCount {
                let entity = MIDIDeviceGetEntity(device, entityIndex)
                let destinationCount = MIDIEntityGetNumberOfDestinations(entity)
                
                for destinationIndex in 0..<destinationCount {
                    let endpoint = MIDIEntityGetDestination(entity, destinationIndex)
                    devices.append(MIDIDevice(endpoint: endpoint))
                }
            }
        }
        
        return devices
    }
    
    /// Finds a MIDI device by name.
    public static func findDevice(named name: String, isInput: Bool) -> MIDIDevice? {
        let devices = isInput ? availableInputDevices() : availableOutputDevices()
        return devices.first { $0.name == name }
    }
}
