// SysExParser.swift
// MonstaGuru
// Created by Mistral Vibe Code (MIDI Integration Agent)

import Foundation
import Data

/// SysEx message types for MicroMonsta 2.
public enum SysExMessageType: UInt8 {
    case programDumpRequest = 0x01
    case programDumpResponse = 0x02
    case singleParameterChange = 0x03
    case parameterChangeRequest = 0x04
    case bankDumpRequest = 0x05
    case bankDumpResponse = 0x06
    case globalSettingsDump = 0x07
    case firmwareUpdate = 0x08
    case ping = 0x7F
}

/// SysEx sub-status bytes for MicroMonsta 2.
public enum SysExSubStatus: UInt8 {
    case editBuffer = 0x00
    case currentProgram = 0x01
    case programMemory = 0x02
}

/// Address ranges for MicroMonsta 2 parameters.
public enum ParameterAddress: UInt16 {
    // Oscillator 1 parameters (0x0000 - 0x000F)
    case osc1Waveform = 0x0000
    case osc1CoarsePitch = 0x0001
    case osc1FinePitch = 0x0002
    case osc1Detune = 0x0003
    case osc1Sync = 0x0004
    case osc1RingMod = 0x0005
    case osc1PulseWidth = 0x0006
    case osc1Level = 0x0007
    case osc1Pan = 0x0008
    
    // Oscillator 2 parameters (0x0010 - 0x001F)
    case osc2Waveform = 0x0010
    case osc2CoarsePitch = 0x0011
    case osc2FinePitch = 0x0012
    case osc2Detune = 0x0013
    case osc2Sync = 0x0014
    case osc2RingMod = 0x0015
    case osc2PulseWidth = 0x0016
    case osc2Level = 0x0017
    case osc2Pan = 0x0018
    
    // Oscillator 3 parameters (0x0020 - 0x002F)
    case osc3Waveform = 0x0020
    case osc3CoarsePitch = 0x0021
    case osc3FinePitch = 0x0022
    case osc3Detune = 0x0023
    case osc3Sync = 0x0024
    case osc3RingMod = 0x0025
    case osc3PulseWidth = 0x0026
    case osc3Level = 0x0027
    case osc3Pan = 0x0028
    
    // Mixer parameters (0x0030 - 0x003F)
    case mixerOsc1Level = 0x0030
    case mixerOsc2Level = 0x0031
    case mixerOsc3Level = 0x0032
    case mixerNoiseLevel = 0x0033
    case mixerExternalLevel = 0x0034
    case mixerRingModLevel = 0x0035
    
    // Filter 1 parameters (0x0040 - 0x004F)
    case filter1Type = 0x0040
    case filter1Cutoff = 0x0041
    case filter1Resonance = 0x0042
    case filter1KeyTrack = 0x0043
    case filter1EnvelopeAmount = 0x0044
    case filter1EnvelopePolarity = 0x0045
    case filter1LFOAmount = 0x0046
    case filter1VelocityAmount = 0x0047
    case filter1PressureAmount = 0x0048
    
    // Filter 2 parameters (0x0050 - 0x005F)
    case filter2Type = 0x0050
    case filter2Cutoff = 0x0051
    case filter2Resonance = 0x0052
    case filter2KeyTrack = 0x0053
    case filter2EnvelopeAmount = 0x0054
    case filter2EnvelopePolarity = 0x0055
    case filter2LFOAmount = 0x0056
    case filter2VelocityAmount = 0x0057
    case filter2PressureAmount = 0x0058
    
    // Envelope 1 parameters (0x0060 - 0x006F)
    case env1Attack = 0x0060
    case env1Decay = 0x0061
    case env1Sustain = 0x0062
    case env1Release = 0x0063
    case env1VelocitySensitivity = 0x0064
    case env1KeyTrack = 0x0065
    
    // Envelope 2 parameters (0x0070 - 0x007F)
    case env2Attack = 0x0070
    case env2Decay = 0x0071
    case env2Sustain = 0x0072
    case env2Release = 0x0073
    case env2VelocitySensitivity = 0x0074
    case env2KeyTrack = 0x0075
    
    // Envelope 3 parameters (0x0080 - 0x008F)
    case env3Attack = 0x0080
    case env3Decay = 0x0081
    case env3Sustain = 0x0082
    case env3Release = 0x0083
    case env3VelocitySensitivity = 0x0084
    case env3KeyTrack = 0x0085
    
    // LFO 1 parameters (0x0090 - 0x009F)
    case lfo1Waveform = 0x0090
    case lfo1Rate = 0x0091
    case lfo1Sync = 0x0092
    case lfo1KeySync = 0x0093
    case lfo1Delay = 0x0094
    case lfo1Fade = 0x0095
    case lfo1Phase = 0x0096
    
    // LFO 2 parameters (0x00A0 - 0x00AF)
    case lfo2Waveform = 0x00A0
    case lfo2Rate = 0x00A1
    case lfo2Sync = 0x00A2
    case lfo2KeySync = 0x00A3
    case lfo2Delay = 0x00A4
    case lfo2Fade = 0x00A5
    case lfo2Phase = 0x00A6
    
    // LFO 3 parameters (0x00B0 - 0x00BF)
    case lfo3Waveform = 0x00B0
    case lfo3Rate = 0x00B1
    case lfo3Sync = 0x00B2
    case lfo3KeySync = 0x00B3
    case lfo3Delay = 0x00B4
    case lfo3Fade = 0x00B5
    case lfo3Phase = 0x00B6
    
    // Matrix parameters (0x00C0 - 0x00CF)
    case matrixSlot1Source = 0x00C0
    case matrixSlot1Destination = 0x00C1
    case matrixSlot1Amount = 0x00C2
    case matrixSlot2Source = 0x00C3
    case matrixSlot2Destination = 0x00C4
    case matrixSlot2Amount = 0x00C5
    case matrixSlot3Source = 0x00C6
    case matrixSlot3Destination = 0x00C7
    case matrixSlot3Amount = 0x00C8
    case matrixSlot4Source = 0x00C9
    case matrixSlot4Destination = 0x00CA
    case matrixSlot4Amount = 0x00CB
    case matrixSlot5Source = 0x00CC
    case matrixSlot5Destination = 0x00CD
    case matrixSlot5Amount = 0x00CE
    case matrixSlot6Source = 0x00CF
    case matrixSlot6Destination = 0x00D0
    case matrixSlot6Amount = 0x00D1
    case matrixSlot7Source = 0x00D2
    case matrixSlot7Destination = 0x00D3
    case matrixSlot7Amount = 0x00D4
    case matrixSlot8Source = 0x00D5
    case matrixSlot8Destination = 0x00D6
    case matrixSlot8Amount = 0x00D7
    case matrixSlot9Source = 0x00D8
    case matrixSlot9Destination = 0x00D9
    case matrixSlot9Amount = 0x00DA
    case matrixSlot10Source = 0x00DB
    case matrixSlot10Destination = 0x00DC
    case matrixSlot10Amount = 0x00DD
    case matrixSlot11Source = 0x00DE
    case matrixSlot11Destination = 0x00DF
    case matrixSlot11Amount = 0x00E0
    case matrixSlot12Source = 0x00E1
    case matrixSlot12Destination = 0x00E2
    case matrixSlot12Amount = 0x00E3
    
    // Effects parameters (0x00F0 - 0x00FF)
    case effect1Type = 0x00F0
    case effect1Param1 = 0x00F1
    case effect1Param2 = 0x00F2
    case effect1Param3 = 0x00F3
    case effect1Level = 0x00F4
    case effect2Type = 0x00F5
    case effect2Param1 = 0x00F6
    case effect2Param2 = 0x00F7
    case effect2Param3 = 0x00F8
    case effect2Level = 0x00F9
    case effect3Type = 0x00FA
    case effect3Param1 = 0x00FB
    case effect3Param2 = 0x00FC
    case effect3Param3 = 0x00FD
    case effect3Level = 0x00FE
    case effectsMasterLevel = 0x00FF
    
    // Global parameters (0x0100 - 0x010F)
    case globalPolyphony = 0x0100
    case globalPortamentoEnabled = 0x0101
    case globalPortamentoTime = 0x0102
    case globalPitchBendRange = 0x0103
    case globalMasterVolume = 0x0104
    case globalMasterTune = 0x0105
    case globalVelocityCurve = 0x0106
    
    // Program metadata (0x01F0 - 0x01FF)
    case programName = 0x01F0
    case programNumber = 0x01F1
}

/// Parser for MicroMonsta 2 SysEx messages.
/// Handles parsing of incoming SysEx messages and generation of outgoing SysEx messages.
public final class SysExParser {
    
    // MARK: - Constants
    
    /// Audiothingies manufacturer ID: 0x00, 0x20, 0x7F
    private static let manufacturerID: [UInt8] = [0x00, 0x20, 0x7F]
    
    /// Default device ID (0x00 = all devices)
    private static let defaultDeviceID: UInt8 = 0x00
    
    /// Program dump data size (128 bytes for MicroMonsta 2)
    private static let programDumpSize = 128
    
    // MARK: - Public Properties
    
    /// The device ID to use for SysEx messages.
    public var deviceID: UInt8 = defaultDeviceID
    
    // MARK: - Initialization
    
    public init(deviceID: UInt8 = defaultDeviceID) {
        self.deviceID = deviceID
    }
    
    // MARK: - Parsing Methods
    
    /// Parses a SysEx message and returns the appropriate data.
    /// - Parameter message: The complete SysEx message including F0 and F7.
    /// - Returns: A SysExResult containing the parsed data or an error.
    public func parse(message: [UInt8]) -> SysExResult {
        // Validate basic SysEx structure
        guard message.count >= 6, message.first == 0xF0, message.last == 0xF7 else {
            return .failure(.invalidSysExMessage)
        }
        
        // Check manufacturer ID
        let messageManufacturerID = Array(message[1..<4])
        guard messageManufacturerID == manufacturerID else {
            return .failure(.unsupportedManufacturer)
        }
        
        // Check device ID (position 4)
        let messageDeviceID = message[4]
        guard messageDeviceID == deviceID || messageDeviceID == 0x00 else {
            return .failure(.deviceIDMismatch)
        }
        
        // Get message type (position 5)
        let messageTypeIndex = 5
        guard message.count > messageTypeIndex else {
            return .failure(.invalidSysExMessage)
        }
        
        let messageType = message[messageTypeIndex]
        
        // Validate checksum
        guard MIDIUtilities.validateChecksum(message) else {
            return .failure(.checksumMismatch)
        }
        
        // Parse based on message type
        switch messageType {
        case SysExMessageType.programDumpResponse.rawValue:
            return parseProgramDump(message: message)
        
        case SysExMessageType.singleParameterChange.rawValue:
            return parseSingleParameterChange(message: message)
        
        case SysExMessageType.programDumpRequest.rawValue:
            return parseProgramDumpRequest(message: message)
        
        case SysExMessageType.bankDumpResponse.rawValue:
            return parseBankDump(message: message)
        
        case SysExMessageType.globalSettingsDump.rawValue:
            return parseGlobalSettingsDump(message: message)
        
        case SysExMessageType.ping.rawValue:
            return .success(.pingResponse)
        
        default:
            return .failure(.unsupportedMessageType)
        }
    }
    
    /// Parses a program dump SysEx message.
    private func parseProgramDump(message: [UInt8]) -> SysExResult {
        // Program dump format: F0 00 20 7F [deviceID] 02 [subStatus] [programNumber] [data...] [checksum] F7
        // Data is 128 bytes for MicroMonsta 2
        
        guard message.count >= 6 + programDumpSize + 2 else {
            return .failure(.invalidSysExMessage)
        }
        
        let subStatusIndex = 6
        let programNumberIndex = 7
        let dataStartIndex = 8
        let dataEndIndex = dataStartIndex + programDumpSize
        
        guard message.count >= dataEndIndex + 1 else {
            return .failure(.invalidSysExMessage)
        }
        
        let subStatus = message[subStatusIndex]
        let programNumber = Int(message[programNumberIndex])
        let dataBytes = Array(message[dataStartIndex..<dataEndIndex])
        
        // Parse the program data
        do {
            let program = try parseProgramData(data: dataBytes, number: programNumber)
            return .success(.programDump(program: program, subStatus: subStatus))
        } catch {
            return .failure(.parsingError(error))
        }
    }
    
    /// Parses a single parameter change SysEx message.
    private func parseSingleParameterChange(message: [UInt8]) -> SysExResult {
        // Single parameter change format: F0 00 20 7F [deviceID] 03 [addressMSB] [addressLSB] [value] [checksum] F7
        
        guard message.count >= 10 else {
            return .failure(.invalidSysExMessage)
        }
        
        let addressMSBIndex = 6
        let addressLSBIndex = 7
        let valueIndex = 8
        
        let addressMSB = UInt16(message[addressMSBIndex])
        let addressLSB = UInt16(message[addressLSBIndex])
        let address = (addressMSB << 7) | addressLSB
        let value = Int(message[valueIndex])
        
        // Convert address to parameter
        if let parameter = ParameterAddress(rawValue: address) {
            return .success(.singleParameterChange(address: parameter, value: value))
        }
        
        return .failure(.unknownParameterAddress(address: address))
    }
    
    /// Parses a program dump request SysEx message.
    private func parseProgramDumpRequest(message: [UInt8]) -> SysExResult {
        // Program dump request format: F0 00 20 7F [deviceID] 01 [subStatus] [programNumber] [checksum] F7
        
        guard message.count >= 9 else {
            return .failure(.invalidSysExMessage)
        }
        
        let subStatusIndex = 6
        let programNumberIndex = 7
        
        let subStatus = message[subStatusIndex]
        let programNumber = Int(message[programNumberIndex])
        
        return .success(.programDumpRequest(subStatus: subStatus, programNumber: programNumber))
    }
    
    /// Parses a bank dump SysEx message.
    private func parseBankDump(message: [UInt8]) -> SysExResult {
        // Bank dump format: F0 00 20 7F [deviceID] 06 [bankNumber] [data...] [checksum] F7
        // For MicroMonsta 2, a bank contains 128 programs (128 * 128 bytes = 16384 bytes)
        
        guard message.count >= 9 else {
            return .failure(.invalidSysExMessage)
        }
        
        let bankNumberIndex = 6
        let dataStartIndex = 7
        
        let bankNumber = Int(message[bankNumberIndex])
        let dataBytes = Array(message[dataStartIndex..<message.count-2])
        
        // Parse multiple programs from the bank data
        var programs: [Program] = []
        let programSize = programDumpSize
        
        for i in stride(from: 0, to: dataBytes.count, by: programSize) {
            let endIndex = min(i + programSize, dataBytes.count)
            let programData = Array(dataBytes[i..<endIndex])
            
            if programData.count == programSize {
                do {
                    let program = try parseProgramData(data: programData, number: i / programSize)
                    programs.append(program)
                } catch {
                    // Skip invalid programs
                    continue
                }
            }
        }
        
        return .success(.bankDump(bankNumber: bankNumber, programs: programs))
    }
    
    /// Parses global settings dump SysEx message.
    private func parseGlobalSettingsDump(message: [UInt8]) -> SysExResult {
        // Global settings dump format: F0 00 20 7F [deviceID] 07 [data...] [checksum] F7
        
        guard message.count >= 8 else {
            return .failure(.invalidSysExMessage)
        }
        
        let dataStartIndex = 6
        let dataBytes = Array(message[dataStartIndex..<message.count-2])
        
        // Parse global settings from data
        let global = parseGlobalSettingsData(data: dataBytes)
        return .success(.globalSettingsDump(global: global))
    }
    
    // MARK: - Program Data Parsing
    
    /// Parses program data bytes into a Program model.
    private func parseProgramData(data: [UInt8], number: Int) throws -> Program {
        guard data.count >= programDumpSize else {
            throw SysExError.invalidProgramData
        }
        
        // Parse oscillators
        let oscillators = [
            parseOscillator(data: Array(data[0x00..<0x10]), index: 1),
            parseOscillator(data: Array(data[0x10..<0x20]), index: 2),
            parseOscillator(data: Array(data[0x20..<0x30]), index: 3)
        ]
        
        // Parse mixer
        let mixer = parseMixer(data: Array(data[0x30..<0x40]))
        
        // Parse filters
        let filters = [
            parseFilter(data: Array(data[0x40..<0x50]), index: 1),
            parseFilter(data: Array(data[0x50..<0x60]), index: 2)
        ]
        
        // Parse envelopes
        let envelopes = [
            parseEnvelope(data: Array(data[0x60..<0x70]), index: 1),
            parseEnvelope(data: Array(data[0x70..<0x80]), index: 2),
            parseEnvelope(data: Array(data[0x80..<0x90]), index: 3)
        ]
        
        // Parse LFOs
        let lfos = [
            parseLFO(data: Array(data[0x90..<0xA0]), index: 1),
            parseLFO(data: Array(data[0xA0..<0xB0]), index: 2),
            parseLFO(data: Array(data[0xB0..<0xC0]), index: 3)
        ]
        
        // Parse matrix
        let matrix = parseMatrix(data: Array(data[0xC0..<0xE4]))
        
        // Parse effects
        let effects = parseEffects(data: Array(data[0xF0..<0x100]))
        
        // Parse global settings
        let global = parseGlobalSettingsData(data: Array(data[0x100..<0x110]))
        
        // Parse program name (last 16 bytes of program data)
        let nameData = Array(data[0x110..<0x120])
        let name = String(bytes: nameData, encoding: .ascii)?.trimmingCharacters(in: .controlCharacters) ?? "Untitled"
        
        return Program(
            name: name,
            number: number,
            oscillators: oscillators,
            mixer: mixer,
            filters: filters,
            envelopes: envelopes,
            lfos: lfos,
            matrix: matrix,
            effects: effects,
            global: global
        )
    }
    
    private func parseOscillator(data: [UInt8], index: Int) -> Oscillator {
        guard data.count >= 16 else {
            return .default(index: index)
        }
        
        let waveform = OscillatorWaveform(rawValue: Int(data[0])) ?? .sawtooth
        let coarsePitch = Int(data[1]) - 64 // Center at 0
        let finePitch = Int(data[2]) - 64 // Center at 0
        let detune = Int(data[3])
        let syncEnabled = data[4] != 0
        let ringModEnabled = data[5] != 0
        let pulseWidth = Int(data[6])
        let level = Int(data[7])
        let pan = Int(data[8]) - 64 // Center at 0
        
        return Oscillator(
            index: index,
            waveform: waveform,
            coarsePitch: coarsePitch,
            finePitch: finePitch,
            detune: detune,
            syncEnabled: syncEnabled,
            ringModEnabled: ringModEnabled,
            pulseWidth: pulseWidth,
            level: level,
            pan: pan
        )
    }
    
    private func parseMixer(data: [UInt8]) -> Mixer {
        guard data.count >= 16 else {
            return .default
        }
        
        return Mixer(
            osc1Level: Int(data[0]),
            osc2Level: Int(data[1]),
            osc3Level: Int(data[2]),
            noiseLevel: Int(data[3]),
            externalLevel: Int(data[4]),
            ringModLevel: Int(data[5])
        )
    }
    
    private func parseFilter(data: [UInt8], index: Int) -> Filter {
        guard data.count >= 16 else {
            return .default(index: index)
        }
        
        let type = FilterType(rawValue: Int(data[0])) ?? .lowPass24dB
        let cutoff = Int(data[1])
        let resonance = Int(data[2])
        let keyTrack = Int(data[3])
        let envelopeAmount = Int(data[4]) - 64 // Signed value
        let envelopePolarity = data[5] != 0
        let lfoAmount = Int(data[6]) - 64 // Signed value
        let velocityAmount = Int(data[7]) - 64 // Signed value
        let pressureAmount = Int(data[8]) - 64 // Signed value
        
        return Filter(
            index: index,
            type: type,
            cutoff: cutoff,
            resonance: resonance,
            keyTrack: keyTrack,
            envelopeAmount: envelopeAmount,
            envelopePolarity: envelopePolarity,
            lfoAmount: lfoAmount,
            velocityAmount: velocityAmount,
            pressureAmount: pressureAmount
        )
    }
    
    private func parseEnvelope(data: [UInt8], index: Int) -> Envelope {
        guard data.count >= 16 else {
            return .default(index: index)
        }
        
        return Envelope(
            index: index,
            attack: Int(data[0]),
            decay: Int(data[1]),
            sustain: Int(data[2]),
            release: Int(data[3]),
            velocitySensitivity: Int(data[4]),
            keyTrack: Int(data[5])
        )
    }
    
    private func parseLFO(data: [UInt8], index: Int) -> LFO {
        guard data.count >= 16 else {
            return .default(index: index)
        }
        
        let waveform = LFOWaveform(rawValue: Int(data[0])) ?? .sine
        let rate = Int(data[1])
        let sync = LFOSync(rawValue: Int(data[2])) ?? .free
        let keySync = data[3] != 0
        let delay = Int(data[4])
        let fade = Int(data[5])
        let phase = Int(data[6])
        
        return LFO(
            index: index,
            waveform: waveform,
            rate: rate,
            sync: sync,
            keySync: keySync,
            delay: delay,
            fade: fade,
            phase: phase
        )
    }
    
    private func parseMatrix(data: [UInt8]) -> [MatrixSlot] {
        guard data.count >= 36 else {
            return (1...12).map { .default(index: $0) }
        }
        
        var slots: [MatrixSlot] = []
        for i in 0..<12 {
            let offset = i * 3
            guard offset + 2 < data.count else {
                slots.append(.default(index: i + 1))
                continue
            }
            
            let source = MatrixSource(rawValue: Int(data[offset])) ?? .off
            let destination = MatrixDestination(rawValue: Int(data[offset + 1])) ?? .off
            let amount = Int(data[offset + 2]) - 64 // Signed value
            
            slots.append(MatrixSlot(
                index: i + 1,
                source: source,
                destination: destination,
                amount: amount
            ))
        }
        
        return slots
    }
    
    private func parseEffects(data: [UInt8]) -> Effects {
        guard data.count >= 16 else {
            return .default
        }
        
        let effect1 = EffectSlot(
            index: 1,
            type: EffectType(rawValue: Int(data[0])) ?? .off,
            param1: Int(data[1]),
            param2: Int(data[2]),
            param3: Int(data[3]),
            level: Int(data[4])
        )
        
        let effect2 = EffectSlot(
            index: 2,
            type: EffectType(rawValue: Int(data[5])) ?? .off,
            param1: Int(data[6]),
            param2: Int(data[7]),
            param3: Int(data[8]),
            level: Int(data[9])
        )
        
        let effect3 = EffectSlot(
            index: 3,
            type: EffectType(rawValue: Int(data[10])) ?? .off,
            param1: Int(data[11]),
            param2: Int(data[12]),
            param3: Int(data[13]),
            level: Int(data[14])
        )
        
        let masterLevel = Int(data[15])
        
        return Effects(
            effect1: effect1,
            effect2: effect2,
            effect3: effect3,
            masterLevel: masterLevel
        )
    }
    
    private func parseGlobalSettingsData(data: [UInt8]) -> GlobalSettings {
        guard data.count >= 16 else {
            return .default
        }
        
        return GlobalSettings(
            polyphony: Int(data[0]),
            portamentoEnabled: data[1] != 0,
            portamentoTime: Int(data[2]),
            pitchBendRange: Int(data[3]) - 12, // Center at 0
            masterVolume: Int(data[4]),
            masterTune: Int(data[5]) - 64, // Center at 0
            velocityCurve: Int(data[6])
        )
    }
    
    // MARK: - Generation Methods
    
    /// Generates a SysEx message for requesting a program dump.
    public func generateProgramDumpRequest(programNumber: Int, subStatus: SysExSubStatus = .currentProgram) -> [UInt8] {
        var message: [UInt8] = [
            0xF0,
            manufacturerID[0], manufacturerID[1], manufacturerID[2],
            deviceID,
            SysExMessageType.programDumpRequest.rawValue,
            subStatus.rawValue,
            UInt8(programNumber.clamped(to: 0...127))
        ]
        
        let checksum = MIDIUtilities.calculateChecksum(Array(message[1..<message.count]))
        message.append(checksum)
        message.append(0xF7)
        
        return message
    }
    
    /// Generates a SysEx message for a program dump.
    public func generateProgramDump(program: Program, subStatus: SysExSubStatus = .currentProgram) -> [UInt8] {
        var message: [UInt8] = [
            0xF0,
            manufacturerID[0], manufacturerID[1], manufacturerID[2],
            deviceID,
            SysExMessageType.programDumpResponse.rawValue,
            subStatus.rawValue,
            UInt8(program.number.clamped(to: 0...127))
        ]
        
        // Generate program data
        let programData = generateProgramData(program: program)
        message.append(contentsOf: programData)
        
        let checksum = MIDIUtilities.calculateChecksum(Array(message[1..<message.count]))
        message.append(checksum)
        message.append(0xF7)
        
        return message
    }
    
    /// Generates a SysEx message for a single parameter change.
    public func generateSingleParameterChange(address: ParameterAddress, value: Int) -> [UInt8] {
        let (msb, lsb) = MIDIUtilities.value14BitTo7Bit(UInt16(address.rawValue))
        let valueByte = UInt8(value.clamped(to: 0...127))
        
        var message: [UInt8] = [
            0xF0,
            manufacturerID[0], manufacturerID[1], manufacturerID[2],
            deviceID,
            SysExMessageType.singleParameterChange.rawValue,
            msb,
            lsb,
            valueByte
        ]
        
        let checksum = MIDIUtilities.calculateChecksum(Array(message[1..<message.count]))
        message.append(checksum)
        message.append(0xF7)
        
        return message
    }
    
    /// Generates program data bytes from a Program model.
    private func generateProgramData(program: Program) -> [UInt8] {
        var data: [UInt8] = Array(repeating: 0, count: programDumpSize)
        
        // Generate oscillator data
        generateOscillatorData(program.oscillators[0], into: &data, offset: 0x00)
        generateOscillatorData(program.oscillators[1], into: &data, offset: 0x10)
        generateOscillatorData(program.oscillators[2], into: &data, offset: 0x20)
        
        // Generate mixer data
        generateMixerData(program.mixer, into: &data, offset: 0x30)
        
        // Generate filter data
        generateFilterData(program.filters[0], into: &data, offset: 0x40)
        generateFilterData(program.filters[1], into: &data, offset: 0x50)
        
        // Generate envelope data
        generateEnvelopeData(program.envelopes[0], into: &data, offset: 0x60)
        generateEnvelopeData(program.envelopes[1], into: &data, offset: 0x70)
        generateEnvelopeData(program.envelopes[2], into: &data, offset: 0x80)
        
        // Generate LFO data
        generateLFOData(program.lfos[0], into: &data, offset: 0x90)
        generateLFOData(program.lfos[1], into: &data, offset: 0xA0)
        generateLFOData(program.lfos[2], into: &data, offset: 0xB0)
        
        // Generate matrix data
        generateMatrixData(program.matrix, into: &data, offset: 0xC0)
        
        // Generate effects data
        generateEffectsData(program.effects, into: &data, offset: 0xF0)
        
        // Generate global settings data
        generateGlobalSettingsData(program.global, into: &data, offset: 0x100)
        
        // Generate program name (last 16 bytes)
        generateProgramNameData(program.name, into: &data, offset: 0x110)
        
        return data
    }
    
    private func generateOscillatorData(_ oscillator: Oscillator, into data: inout [UInt8], offset: Int) {
        guard offset + 16 <= data.count else { return }
        
        data[offset + 0] = UInt8(oscillator.waveform.rawValue)
        data[offset + 1] = UInt8((oscillator.coarsePitch + 64).clamped(to: 0...127))
        data[offset + 2] = UInt8((oscillator.finePitch + 64).clamped(to: 0...127))
        data[offset + 3] = UInt8(oscillator.detune.clamped(to: 0...127))
        data[offset + 4] = oscillator.syncEnabled ? 1 : 0
        data[offset + 5] = oscillator.ringModEnabled ? 1 : 0
        data[offset + 6] = UInt8(oscillator.pulseWidth.clamped(to: 0...127))
        data[offset + 7] = UInt8(oscillator.level.clamped(to: 0...127))
        data[offset + 8] = UInt8((oscillator.pan + 64).clamped(to: 0...127))
    }
    
    private func generateMixerData(_ mixer: Mixer, into data: inout [UInt8], offset: Int) {
        guard offset + 16 <= data.count else { return }
        
        data[offset + 0] = UInt8(mixer.osc1Level.clamped(to: 0...127))
        data[offset + 1] = UInt8(mixer.osc2Level.clamped(to: 0...127))
        data[offset + 2] = UInt8(mixer.osc3Level.clamped(to: 0...127))
        data[offset + 3] = UInt8(mixer.noiseLevel.clamped(to: 0...127))
        data[offset + 4] = UInt8(mixer.externalLevel.clamped(to: 0...127))
        data[offset + 5] = UInt8(mixer.ringModLevel.clamped(to: 0...127))
    }
    
    private func generateFilterData(_ filter: Filter, into data: inout [UInt8], offset: Int) {
        guard offset + 16 <= data.count else { return }
        
        data[offset + 0] = UInt8(filter.type.rawValue)
        data[offset + 1] = UInt8(filter.cutoff.clamped(to: 0...127))
        data[offset + 2] = UInt8(filter.resonance.clamped(to: 0...127))
        data[offset + 3] = UInt8(filter.keyTrack.clamped(to: 0...127))
        data[offset + 4] = UInt8((filter.envelopeAmount + 64).clamped(to: 0...127))
        data[offset + 5] = filter.envelopePolarity ? 1 : 0
        data[offset + 6] = UInt8((filter.lfoAmount + 64).clamped(to: 0...127))
        data[offset + 7] = UInt8((filter.velocityAmount + 64).clamped(to: 0...127))
        data[offset + 8] = UInt8((filter.pressureAmount + 64).clamped(to: 0...127))
    }
    
    private func generateEnvelopeData(_ envelope: Envelope, into data: inout [UInt8], offset: Int) {
        guard offset + 16 <= data.count else { return }
        
        data[offset + 0] = UInt8(envelope.attack.clamped(to: 0...127))
        data[offset + 1] = UInt8(envelope.decay.clamped(to: 0...127))
        data[offset + 2] = UInt8(envelope.sustain.clamped(to: 0...127))
        data[offset + 3] = UInt8(envelope.release.clamped(to: 0...127))
        data[offset + 4] = UInt8(envelope.velocitySensitivity.clamped(to: 0...127))
        data[offset + 5] = UInt8(envelope.keyTrack.clamped(to: 0...127))
    }
    
    private func generateLFOData(_ lfo: LFO, into data: inout [UInt8], offset: Int) {
        guard offset + 16 <= data.count else { return }
        
        data[offset + 0] = UInt8(lfo.waveform.rawValue)
        data[offset + 1] = UInt8(lfo.rate.clamped(to: 0...127))
        data[offset + 2] = UInt8(lfo.sync.rawValue)
        data[offset + 3] = lfo.keySync ? 1 : 0
        data[offset + 4] = UInt8(lfo.delay.clamped(to: 0...127))
        data[offset + 5] = UInt8(lfo.fade.clamped(to: 0...127))
        data[offset + 6] = UInt8(lfo.phase.clamped(to: 0...127))
    }
    
    private func generateMatrixData(_ matrix: [MatrixSlot], into data: inout [UInt8], offset: Int) {
        guard offset + 36 <= data.count else { return }
        
        for (index, slot) in matrix.enumerated() {
            let slotOffset = offset + (index * 3)
            guard slotOffset + 2 < data.count else { continue }
            
            data[slotOffset + 0] = UInt8(slot.source.rawValue)
            data[slotOffset + 1] = UInt8(slot.destination.rawValue)
            data[slotOffset + 2] = UInt8((slot.amount + 64).clamped(to: 0...127))
        }
    }
    
    private func generateEffectsData(_ effects: Effects, into data: inout [UInt8], offset: Int) {
        guard offset + 16 <= data.count else { return }
        
        data[offset + 0] = UInt8(effects.effect1.type.rawValue)
        data[offset + 1] = UInt8(effects.effect1.param1.clamped(to: 0...127))
        data[offset + 2] = UInt8(effects.effect1.param2.clamped(to: 0...127))
        data[offset + 3] = UInt8(effects.effect1.param3.clamped(to: 0...127))
        data[offset + 4] = UInt8(effects.effect1.level.clamped(to: 0...127))
        
        data[offset + 5] = UInt8(effects.effect2.type.rawValue)
        data[offset + 6] = UInt8(effects.effect2.param1.clamped(to: 0...127))
        data[offset + 7] = UInt8(effects.effect2.param2.clamped(to: 0...127))
        data[offset + 8] = UInt8(effects.effect2.param3.clamped(to: 0...127))
        data[offset + 9] = UInt8(effects.effect2.level.clamped(to: 0...127))
        
        data[offset + 10] = UInt8(effects.effect3.type.rawValue)
        data[offset + 11] = UInt8(effects.effect3.param1.clamped(to: 0...127))
        data[offset + 12] = UInt8(effects.effect3.param2.clamped(to: 0...127))
        data[offset + 13] = UInt8(effects.effect3.param3.clamped(to: 0...127))
        data[offset + 14] = UInt8(effects.effect3.level.clamped(to: 0...127))
        
        data[offset + 15] = UInt8(effects.masterLevel.clamped(to: 0...127))
    }
    
    private func generateGlobalSettingsData(_ global: GlobalSettings, into data: inout [UInt8], offset: Int) {
        guard offset + 16 <= data.count else { return }
        
        data[offset + 0] = UInt8(global.polyphony.clamped(to: 1...8))
        data[offset + 1] = global.portamentoEnabled ? 1 : 0
        data[offset + 2] = UInt8(global.portamentoTime.clamped(to: 0...127))
        data[offset + 3] = UInt8((global.pitchBendRange + 12).clamped(to: 0...24))
        data[offset + 4] = UInt8(global.masterVolume.clamped(to: 0...127))
        data[offset + 5] = UInt8((global.masterTune + 64).clamped(to: 0...127))
        data[offset + 6] = UInt8(global.velocityCurve.clamped(to: 0...3))
    }
    
    private func generateProgramNameData(_ name: String, into data: inout [UInt8], offset: Int) {
        guard offset + 16 <= data.count else { return }
        
        let nameBytes = name.prefix(16).utf8
        for (index, byte) in nameBytes.enumerated() {
            data[offset + index] = byte
        }
        
        // Pad with zeros
        for index in nameBytes.count..<16 {
            data[offset + index] = 0
        }
    }
}

// MARK: - SysEx Result Types

/// Result types for SysEx parsing.
public enum SysExResult {
    case success(SysExParsedData)
    case failure(SysExError)
}

/// Parsed SysEx data.
public enum SysExParsedData {
    case programDump(program: Program, subStatus: UInt8)
    case programDumpRequest(subStatus: UInt8, programNumber: Int)
    case singleParameterChange(address: ParameterAddress, value: Int)
    case bankDump(bankNumber: Int, programs: [Program])
    case globalSettingsDump(global: GlobalSettings)
    case pingResponse
}

/// SysEx parsing/generation errors.
public enum SysExError: Error, LocalizedError {
    case invalidSysExMessage
    case unsupportedManufacturer
    case deviceIDMismatch
    case invalidProgramData
    case checksumMismatch
    case unsupportedMessageType
    case unknownParameterAddress(address: UInt16)
    case parsingError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .invalidSysExMessage: return "Invalid SysEx message format"
        case .unsupportedManufacturer: return "Unsupported manufacturer ID"
        case .deviceIDMismatch: return "Device ID mismatch"
        case .invalidProgramData: return "Invalid program data"
        case .checksumMismatch: return "SysEx checksum mismatch"
        case .unsupportedMessageType: return "Unsupported SysEx message type"
        case .unknownParameterAddress(let address): return "Unknown parameter address: 0x\(String(format: "%04X", address))"
        case .parsingError(let error): return "Parsing error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Helper Extensions

private extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
