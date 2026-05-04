// MIDIManager.swift
// MonstaGuru
// Created by Mistral Vibe Code (MIDI Integration Agent)

import Foundation
import CoreMIDI
import Combine
import Data

/// Delegate protocol for MIDI events.
public protocol MIDIManagerDelegate: AnyObject {
    /// Called when a MIDI note on event is received.
    func midiManager(_ manager: MIDIManager, didReceiveNoteOn channel: MIDIChannel, note: MIDINote, velocity: MIDIVelocity)
    
    /// Called when a MIDI note off event is received.
    func midiManager(_ manager: MIDIManager, didReceiveNoteOff channel: MIDIChannel, note: MIDINote, velocity: MIDIVelocity)
    
    /// Called when a MIDI control change event is received.
    func midiManager(_ manager: MIDIManager, didReceiveControlChange channel: MIDIChannel, control: MIDIControl, value: MIDIVelocity)
    
    /// Called when a MIDI program change event is received.
    func midiManager(_ manager: MIDIManager, didReceiveProgramChange channel: MIDIChannel, program: MIDIProgram)
    
    /// Called when a MIDI pitch bend event is received.
    func midiManager(_ manager: MIDIManager, didReceivePitchBend channel: MIDIChannel, value: MIDIPitchBend)
    
    /// Called when a SysEx message is received.
    func midiManager(_ manager: MIDIManager, didReceiveSysEx message: [UInt8])
    
    /// Called when a complete program is received via SysEx.
    func midiManager(_ manager: MIDIManager, didReceiveProgram program: Program)
    
    /// Called when a single parameter change is received via SysEx.
    func midiManager(_ manager: MIDIManager, didReceiveParameterChange address: ParameterAddress, value: Int)
    
    /// Called when a MIDI connection error occurs.
    func midiManager(_ manager: MIDIManager, didEncounterError error: MIDIError)
}

/// Manages MIDI input and output for the MicroMonsta 2.
/// Handles device connections, message sending/receiving, and SysEx communication.
public final class MIDIManager: ObservableObject {
    
    // MARK: - Public Properties
    
    /// The current input device name.
    @Published public private(set) var inputDeviceName: String = ""
    
    /// The current output device name.
    @Published public private(set) var outputDeviceName: String = ""
    
    /// Whether MIDI input is connected.
    @Published public private(set) var isInputConnected: Bool = false
    
    /// Whether MIDI output is connected.
    @Published public private(set) var isOutputConnected: Bool = false
    
    /// Whether SysEx reception is enabled.
    @Published public var isSysExEnabled: Bool = true {
        didSet {
            if isSysExEnabled {
                startReceivingSysEx()
            } else {
                stopReceivingSysEx()
            }
        }
    }
    
    /// Whether MIDI thru is enabled (echoes input to output).
    @Published public var isMIDIThruEnabled: Bool = false
    
    /// The MIDI channel for program changes (0 = Omni).
    @Published public var programChangeChannel: MIDIChannel = 0
    
    /// The MIDI channel for note data (0 = Omni).
    @Published public var noteChannel: MIDIChannel = 0
    
    /// The device ID for SysEx messages.
    @Published public var deviceID: UInt8 = 0x00
    
    /// The SysEx parser for handling MicroMonsta 2 messages.
    public let sysExParser: SysExParser
    
    /// The delegate for MIDI events.
    public weak var delegate: MIDIManagerDelegate?
    
    // MARK: - Private Properties
    
    /// The MIDI client reference.
    private var midiClient: MIDIClientRef = 0
    
    /// The MIDI input port reference.
    private var inputPort: MIDIPortRef = 0
    
    /// The MIDI output port reference.
    private var outputPort: MIDIPortRef = 0
    
    /// The connected MIDI input source.
    private var inputSource: MIDIEndpointRef = 0
    
    /// The connected MIDI output destination.
    private var outputDestination: MIDIEndpointRef = 0
    
    /// Buffer for accumulating SysEx messages.
    private var sysExBuffer: [UInt8] = []
    
    /// Whether we are currently receiving a SysEx message.
    private var isReceivingSysEx: Bool = false
    
    /// Combine subject for MIDI events.
    private let midiEventSubject = PassthroughSubject<MIDIEvent, Never>()
    
    /// Combine subject for SysEx events.
    private let sysExEventSubject = PassthroughSubject<SysExEvent, Never>()
    
    // MARK: - Public Publishers
    
    /// Publisher for MIDI events.
    public var midiEventPublisher: AnyPublisher<MIDIEvent, Never> {
        midiEventSubject.eraseToAnyPublisher()
    }
    
    /// Publisher for SysEx events.
    public var sysExEventPublisher: AnyPublisher<SysExEvent, Never> {
        sysExEventSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    public init(deviceID: UInt8 = 0x00) {
        self.sysExParser = SysExParser(deviceID: deviceID)
        self.deviceID = deviceID
        
        setupMIDIClient()
    }
    
    deinit {
        cleanupMIDI()
    }
    
    // MARK: - MIDI Setup
    
    /// Sets up the MIDI client and ports.
    private func setupMIDIClient() {
        var client = MIDIClientRef()
        let status = MIDIClientCreateWithBlock("MonstaGuru" as CFString, &client) { notification in
            self.handleMIDINotification(notification)
        }
        
        guard status == noErr else {
            print("Failed to create MIDI client: \(status)")
            return
        }
        
        midiClient = client
        
        // Create input port
        var inPort: MIDIPortRef = 0
        let inStatus = MIDIInputPortCreateWithBlock(client, "MonstaGuru Input" as CFString, &inPort) { (packetList, _) in
            self.handleMIDIPacketList(packetList)
        }
        
        guard inStatus == noErr else {
            print("Failed to create MIDI input port: \(inStatus)")
            return
        }
        
        inputPort = inPort
        
        // Create output port
        var outPort: MIDIPortRef = 0
        let outStatus = MIDIOutputPortCreate(client, "MonstaGuru Output" as CFString, &outPort)
        
        guard outStatus == noErr else {
            print("Failed to create MIDI output port: \(outStatus)")
            return
        }
        
        outputPort = outPort
    }
    
    /// Cleans up MIDI resources.
    private func cleanupMIDI() {
        // Disconnect sources and destinations
        if inputSource != 0 && inputPort != 0 {
            MIDIPortDisconnectSource(inputPort, inputSource)
            inputSource = 0
        }
        
        if outputDestination != 0 && outputPort != 0 {
            MIDIPortDisconnectDestination(outputPort, outputDestination)
            outputDestination = 0
        }
        
        // Dispose ports
        if inputPort != 0 {
            MIDIPortDispose(inputPort)
            inputPort = 0
        }
        
        if outputPort != 0 {
            MIDIPortDispose(outputPort)
            outputPort = 0
        }
        
        // Dispose client
        if midiClient != 0 {
            MIDIClientDispose(midiClient)
            midiClient = 0
        }
    }
    
    // MARK: - Device Management
    
    /// Returns a list of available MIDI input devices.
    public func availableInputDevices() -> [MIDIDevice] {
        return MIDIUtilities.availableInputDevices()
    }
    
    /// Returns a list of available MIDI output devices.
    public func availableOutputDevices() -> [MIDIDevice] {
        return MIDIUtilities.availableOutputDevices()
    }
    
    /// Connects to a MIDI input device by name.
    /// - Parameter name: The name of the input device to connect to.
    /// - Throws: MIDIError if the connection fails.
    public func connectInputDevice(named name: String) throws {
        guard let device = MIDIUtilities.findDevice(named: name, isInput: true) else {
            throw MIDIError.deviceNotFound
        }
        
        // Disconnect current input if connected
        if inputSource != 0 && inputPort != 0 {
            MIDIPortDisconnectSource(inputPort, inputSource)
        }
        
        // Connect to new source
        let status = MIDIPortConnectSource(inputPort, device.endpoint, &inputSource)
        
        guard status == noErr else {
            throw MIDIError.failedToConnectInputSource
        }
        
        inputDeviceName = name
        inputSource = device.endpoint
        isInputConnected = true
        
        // Start receiving SysEx if enabled
        if isSysExEnabled {
            startReceivingSysEx()
        }
    }
    
    /// Connects to a MIDI output device by name.
    /// - Parameter name: The name of the output device to connect to.
    /// - Throws: MIDIError if the connection fails.
    public func connectOutputDevice(named name: String) throws {
        guard let device = MIDIUtilities.findDevice(named: name, isInput: false) else {
            throw MIDIError.deviceNotFound
        }
        
        // Disconnect current output if connected
        if outputDestination != 0 && outputPort != 0 {
            MIDIPortDisconnectDestination(outputPort, outputDestination)
        }
        
        // Connect to new destination
        let status = MIDIPortConnectDestination(outputPort, device.endpoint, &outputDestination)
        
        guard status == noErr else {
            throw MIDIError.failedToConnectOutputDestination
        }
        
        outputDeviceName = name
        outputDestination = device.endpoint
        isOutputConnected = true
    }
    
    /// Disconnects the current MIDI input device.
    public func disconnectInputDevice() {
        if inputSource != 0 && inputPort != 0 {
            MIDIPortDisconnectSource(inputPort, inputSource)
            inputSource = 0
        }
        
        inputDeviceName = ""
        isInputConnected = false
        stopReceivingSysEx()
    }
    
    /// Disconnects the current MIDI output device.
    public func disconnectOutputDevice() {
        if outputDestination != 0 && outputPort != 0 {
            MIDIPortDisconnectDestination(outputPort, outputDestination)
            outputDestination = 0
        }
        
        outputDeviceName = ""
        isOutputConnected = false
    }
    
    /// Disconnects all MIDI devices.
    public func disconnectAllDevices() {
        disconnectInputDevice()
        disconnectOutputDevice()
    }
    
    // MARK: - SysEx Management
    
    /// Starts receiving SysEx messages.
    private func startReceivingSysEx() {
        // SysEx reception is handled in the packet list handler
        isReceivingSysEx = true
    }
    
    /// Stops receiving SysEx messages.
    private func stopReceivingSysEx() {
        isReceivingSysEx = false
        sysExBuffer.removeAll()
    }
    
    // MARK: - MIDI Sending
    
    /// Sends a MIDI message.
    /// - Parameter message: The MIDI message to send.
    /// - Throws: MIDIError if the message cannot be sent.
    public func sendMessage(_ message: MIDIMessage) throws {
        guard isOutputConnected else {
            throw MIDIError.noOutputDevicesAvailable
        }
        
        let bytes = message.toBytes()
        let packetList = createMIDIPacketList(from: bytes)
        
        let status = MIDISend(outputPort, outputDestination, packetList)
        
        guard status == noErr else {
            throw MIDIError.failedToSendMessage
        }
        
        // Free the packet list
        packetList.pointer?.deallocate()
    }
    
    /// Sends a SysEx message.
    /// - Parameter message: The SysEx message bytes to send.
    /// - Throws: MIDIError if the message cannot be sent.
    public func sendSysExMessage(_ message: [UInt8]) throws {
        guard isOutputConnected else {
            throw MIDIError.noOutputDevicesAvailable
        }
        
        let packetList = createMIDIPacketList(from: message)
        
        let status = MIDISend(outputPort, outputDestination, packetList)
        
        guard status == noErr else {
            throw MIDIError.failedToSendMessage
        }
        
        // Free the packet list
        packetList.pointer?.deallocate()
    }
    
    /// Sends a program to the MicroMonsta 2.
    /// - Parameter program: The program to send.
    /// - Throws: MIDIError if the program cannot be sent.
    public func sendProgram(_ program: Program) throws {
        let message = sysExParser.generateProgramDump(program: program)
        try sendSysExMessage(message)
    }
    
    /// Requests a program dump from the MicroMonsta 2.
    /// - Parameter programNumber: The program number to request (0-127).
    /// - Throws: MIDIError if the request cannot be sent.
    public func requestProgramDump(programNumber: Int) throws {
        let message = sysExParser.generateProgramDumpRequest(programNumber: programNumber)
        try sendSysExMessage(message)
    }
    
    /// Sends a single parameter change to the MicroMonsta 2.
    /// - Parameters:
    ///   - address: The parameter address.
    ///   - value: The value to set.
    /// - Throws: MIDIError if the parameter change cannot be sent.
    public func sendParameterChange(address: ParameterAddress, value: Int) throws {
        let message = sysExParser.generateSingleParameterChange(address: address, value: value)
        try sendSysExMessage(message)
    }
    
    /// Sends a MIDI note on message.
    /// - Parameters:
    ///   - note: The note number (0-127).
    ///   - velocity: The velocity (0-127).
    ///   - channel: The MIDI channel (0-15, 0 = current channel).
    /// - Throws: MIDIError if the message cannot be sent.
    public func sendNoteOn(note: MIDINote, velocity: MIDIVelocity, channel: MIDIChannel? = nil) throws {
        let actualChannel = channel ?? self.noteChannel
        let message = MIDIMessage.noteOn(channel: actualChannel, note: note, velocity: velocity)
        try sendMessage(message)
    }
    
    /// Sends a MIDI note off message.
    /// - Parameters:
    ///   - note: The note number (0-127).
    ///   - velocity: The velocity (0-127).
    ///   - channel: The MIDI channel (0-15, 0 = current channel).
    /// - Throws: MIDIError if the message cannot be sent.
    public func sendNoteOff(note: MIDINote, velocity: MIDIVelocity, channel: MIDIChannel? = nil) throws {
        let actualChannel = channel ?? self.noteChannel
        let message = MIDIMessage.noteOff(channel: actualChannel, note: note, velocity: velocity)
        try sendMessage(message)
    }
    
    /// Sends a MIDI control change message.
    /// - Parameters:
    ///   - control: The control number (0-127).
    ///   - value: The value (0-127).
    ///   - channel: The MIDI channel (0-15, 0 = current channel).
    /// - Throws: MIDIError if the message cannot be sent.
    public func sendControlChange(control: MIDIControl, value: MIDIVelocity, channel: MIDIChannel? = nil) throws {
        let actualChannel = channel ?? self.noteChannel
        let message = MIDIMessage.controlChange(channel: actualChannel, control: control, value: value)
        try sendMessage(message)
    }
    
    /// Sends a MIDI program change message.
    /// - Parameters:
    ///   - program: The program number (0-127).
    ///   - channel: The MIDI channel (0-15, 0 = current channel).
    /// - Throws: MIDIError if the message cannot be sent.
    public func sendProgramChange(program: MIDIProgram, channel: MIDIChannel? = nil) throws {
        let actualChannel = channel ?? self.programChangeChannel
        let message = MIDIMessage.programChange(channel: actualChannel, program: program)
        try sendMessage(message)
    }
    
    /// Sends a MIDI pitch bend message.
    /// - Parameters:
    ///   - value: The pitch bend value (-8192 to +8191).
    ///   - channel: The MIDI channel (0-15, 0 = current channel).
    /// - Throws: MIDIError if the message cannot be sent.
    public func sendPitchBend(value: MIDIPitchBend, channel: MIDIChannel? = nil) throws {
        let actualChannel = channel ?? self.noteChannel
        let message = MIDIMessage.pitchBend(channel: actualChannel, value: value)
        try sendMessage(message)
    }
    
    // MARK: - MIDI Packet Handling
    
    /// Creates a MIDIPacketList from an array of bytes.
    private func createMIDIPacketList(from bytes: [UInt8]) -> Unmanaged<MIDIPacketList> {
        let packetListPointer = UnsafeMutablePointer<MIDIPacketList>.allocate(capacity: 1)
        let packetList = packetListPointer.pointee
        
        var packet = MIDIPacket(
            timeStamp: 0,
            length: UInt16(bytes.count),
            data: (bytes, count: bytes.count)
        )
        
        withUnsafeMutablePointer(to: &packetList.packet) { packetPtr in
            packetPtr.pointee = packet
        }
        
        return Unmanaged.passRetained(packetListPointer)
    }
    
    /// Handles MIDI notifications.
    private func handleMIDINotification(_ notification: UnsafePointer<MIDINotification>) {
        let message = notification.pointee.message
        
        switch message {
        case .msgIOError:
            print("MIDI I/O Error")
            delegate?.midiManager(self, didEncounterError: .failedToSendMessage)
        case .msgObjectAdded:
            print("MIDI Object Added")
            // Refresh device lists
        case .msgObjectRemoved:
            print("MIDI Object Removed")
            // Check if our connected devices were removed
            if isInputConnected {
                let devices = availableInputDevices()
                if !devices.contains(where: { $0.name == inputDeviceName }) {
                    DispatchQueue.main.async {
                        self.disconnectInputDevice()
                    }
                }
            }
            if isOutputConnected {
                let devices = availableOutputDevices()
                if !devices.contains(where: { $0.name == outputDeviceName }) {
                    DispatchQueue.main.async {
                        self.disconnectOutputDevice()
                    }
                }
            }
        default:
            break
        }
    }
    
    /// Handles incoming MIDI packet lists.
    private func handleMIDIPacketList(_ packetList: UnsafePointer<MIDIPacketList>) {
        var packetListPointer = packetList
        
        while true {
            let packet = packetListPointer.pointee.packet
            let bytes = Array(UnsafeBufferPointer(start: packet.data, count: Int(packet.length)))
            
            // Handle the packet
            handleMIDIPacket(bytes: bytes, timeStamp: packet.timeStamp)
            
            // Move to next packet
            if packetListPointer.pointee.packet.next == nil {
                break
            }
            packetListPointer = UnsafePointer(packetListPointer.pointee.packet.next!)
        }
    }
    
    /// Handles a single MIDI packet.
    private func handleMIDIPacket(bytes: [UInt8], timeStamp: MIDITimeStamp) {
        guard !bytes.isEmpty else { return }
        
        let status = bytes[0]
        
        // Check for SysEx start (F0)
        if status == MIDIStatus.systemExclusive.rawValue {
            handleSysExPacket(bytes: bytes)
            return
        }
        
        // Check for SysEx continuation
        if isReceivingSysEx {
            handleSysExPacket(bytes: bytes)
            return
        }
        
        // Handle regular MIDI messages
        if let message = MIDIMessage.fromBytes(bytes) {
            handleMIDIMessage(message, timeStamp: timeStamp)
        }
    }
    
    /// Handles SysEx packet data.
    private func handleSysExPacket(bytes: [UInt8]) {
        guard isSysExEnabled else { return }
        
        if bytes.first == MIDIStatus.systemExclusive.rawValue {
            // Start of SysEx message
            isReceivingSysEx = true
            sysExBuffer.removeAll()
        }
        
        // Append bytes to buffer (excluding F0 if it's the start)
        if isReceivingSysEx {
            if bytes.first == MIDIStatus.systemExclusive.rawValue {
                sysExBuffer.append(contentsOf: bytes)
            } else {
                sysExBuffer.append(contentsOf: bytes)
            }
            
            // Check for SysEx end (F7)
            if bytes.last == 0xF7 {
                isReceivingSysEx = false
                processSysExMessage(sysExBuffer)
                sysExBuffer.removeAll()
            }
        }
    }
    
    /// Processes a complete SysEx message.
    private func processSysExMessage(_ message: [UInt8]) {
        // Notify delegate
        DispatchQueue.main.async {
            self.delegate?.midiManager(self, didReceiveSysEx: message)
        }
        
        // Parse the message
        let result = sysExParser.parse(message: message)
        
        switch result {
        case .success(let parsedData):
            handleParsedSysExData(parsedData)
        case .failure(let error):
            print("SysEx parsing error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.delegate?.midiManager(self, didEncounterError: .invalidSysExMessage)
            }
        }
    }
    
    /// Handles parsed SysEx data.
    private func handleParsedSysExData(_ data: SysExParsedData) {
        switch data {
        case .programDump(let program, _):
            DispatchQueue.main.async {
                self.delegate?.midiManager(self, didReceiveProgram: program)
            }
            sysExEventSubject.send(.programReceived(program))
            
        case .singleParameterChange(let address, let value):
            DispatchQueue.main.async {
                self.delegate?.midiManager(self, didReceiveParameterChange: address, value: value)
            }
            sysExEventSubject.send(.parameterChanged(address: address, value: value))
            
        case .programDumpRequest(_, let programNumber):
            sysExEventSubject.send(.programRequest(programNumber: programNumber))
            
        case .bankDump(let bankNumber, let programs):
            sysExEventSubject.send(.bankReceived(bankNumber: bankNumber, programs: programs))
            
        case .globalSettingsDump(let global):
            sysExEventSubject.send(.globalSettingsReceived(global: global))
            
        case .pingResponse:
            sysExEventSubject.send(.pingResponse)
        }
    }
    
    /// Handles a parsed MIDI message.
    private func handleMIDIMessage(_ message: MIDIMessage, timeStamp: MIDITimeStamp) {
        // Publish the event
        let event = MIDIEvent(message: message, timeStamp: timeStamp)
        midiEventSubject.send(event)
        
        // Notify delegate based on message type
        switch message {
        case .noteOn(let channel, let note, let velocity):
            DispatchQueue.main.async {
                self.delegate?.midiManager(self, didReceiveNoteOn: channel, note: note, velocity: velocity)
            }
            
            // MIDI Thru
            if isMIDIThruEnabled {
                DispatchQueue.global(qos: .userInteractive).async {
                    do {
                        try self.sendMessage(message)
                    } catch {
                        print("MIDI Thru error: \(error)")
                    }
                }
            }
            
        case .noteOff(let channel, let note, let velocity):
            DispatchQueue.main.async {
                self.delegate?.midiManager(self, didReceiveNoteOff: channel, note: note, velocity: velocity)
            }
            
            // MIDI Thru
            if isMIDIThruEnabled {
                DispatchQueue.global(qos: .userInteractive).async {
                    do {
                        try self.sendMessage(message)
                    } catch {
                        print("MIDI Thru error: \(error)")
                    }
                }
            }
            
        case .controlChange(let channel, let control, let value):
            DispatchQueue.main.async {
                self.delegate?.midiManager(self, didReceiveControlChange: channel, control: control, value: value)
            }
            
            // MIDI Thru
            if isMIDIThruEnabled {
                DispatchQueue.global(qos: .userInteractive).async {
                    do {
                        try self.sendMessage(message)
                    } catch {
                        print("MIDI Thru error: \(error)")
                    }
                }
            }
            
        case .programChange(let channel, let program):
            DispatchQueue.main.async {
                self.delegate?.midiManager(self, didReceiveProgramChange: channel, program: program)
            }
            
            // MIDI Thru
            if isMIDIThruEnabled {
                DispatchQueue.global(qos: .userInteractive).async {
                    do {
                        try self.sendMessage(message)
                    } catch {
                        print("MIDI Thru error: \(error)")
                    }
                }
            }
            
        case .pitchBend(let channel, let value):
            DispatchQueue.main.async {
                self.delegate?.midiManager(self, didReceivePitchBend: channel, value: value)
            }
            
            // MIDI Thru
            if isMIDIThruEnabled {
                DispatchQueue.global(qos: .userInteractive).async {
                    do {
                        try self.sendMessage(message)
                    } catch {
                        print("MIDI Thru error: \(error)")
                    }
                }
            }
            
        case .systemExclusive:
            // Handled separately
            break
            
        default:
            // MIDI Thru for other messages
            if isMIDIThruEnabled {
                DispatchQueue.global(qos: .userInteractive).async {
                    do {
                        try self.sendMessage(message)
                    } catch {
                        print("MIDI Thru error: \(error)")
                    }
                }
            }
        }
    }
}

// MARK: - Event Types

/// MIDI event for Combine publishers.
public struct MIDIEvent {
    public let message: MIDIMessage
    public let timeStamp: MIDITimeStamp
    
    public init(message: MIDIMessage, timeStamp: MIDITimeStamp) {
        self.message = message
        self.timeStamp = timeStamp
    }
}

/// SysEx event for Combine publishers.
public enum SysExEvent {
    case programReceived(Program)
    case parameterChanged(address: ParameterAddress, value: Int)
    case programRequest(programNumber: Int)
    case bankReceived(bankNumber: Int, programs: [Program])
    case globalSettingsReceived(GlobalSettings)
    case pingResponse
}

// MARK: - Helper Extensions

private extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
