/*
© Copyright 2021, Little Green Viper Software Development LLC

LICENSE:

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Little Green Viper Software Development LLC: https://littlegreenviper.com
*/

import CoreBluetooth

/* ###################################################################################################################################### */
// MARK: - This is the Peripheral Device Protocol Specialization for the Main SDK -
/* ###################################################################################################################################### */
extension ITCB_Device_Peripheral_Protocol {
    /* ################################################################## */
    /**
     The default does nothing.
     */
    func sendQuestion(_ question: String) { }
}

/* ###################################################################################################################################### */
// MARK: - Main SDK Central Variant Interface Class -
/* ###################################################################################################################################### */
/**
 Various stored properties and things we need to declare at the start.
 */
internal extension ITCB_SDK_Central {
    /* ################################################################## */
    /**
     This is a specific cast of the manager object that wil be attached to this instance.
     */
    var centralManagerInstance: CBCentralManager! {
        managerInstance as? CBCentralManager
    }

    /* ################################################################## */
    /**
     This sends the "A question was asked" message to all registered observers.
     
     - parameter device: The Peripheral device that contains the question.
     */
    func _sendSuccessInAskingMessageToAllObservers(device inDevice: ITCB_Device_Peripheral_Protocol) {
        observers.forEach {
            if let observer = $0 as? ITCB_Observer_Central_Protocol {
                observer.questionAskedOfDevice(inDevice)
            }
        }
    }
    
    /* ################################################################## */
    /**
     This sends the "A question was asked and answered" message to all registered observers.
     
     - parameter device: The Peripheral device that contains the question and the answer.
     */
    func _sendQuestionAnsweredMessageToAllObservers(device inDevice: ITCB_Device_Peripheral_Protocol) {
        observers.forEach {
            if let observer = $0 as? ITCB_Observer_Central_Protocol {
                observer.questionAnsweredByDevice(inDevice)
            }
        }
    }
    
    /* ################################################################## */
    /**
     This sends a device discovery message to all registered observers.
     
     - parameter device: The Peripheral device that was discovered.
     */
    func _sendDeviceDiscoveredMessageToAllObservers(device inDevice: ITCB_Device_Peripheral_Protocol) {
        observers.forEach {
            if let observer = $0 as? ITCB_Observer_Central_Protocol {
                observer.deviceDiscovered(inDevice)
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - ITCB_SDK_Device_PeripheralDelegate Methods -
/* ###################################################################################################################################### */
extension ITCB_SDK_Central: ITCB_SDK_Device_PeripheralDelegate {
    internal func peripheralServicesUpdated(_ inPeripheral: ITCB_SDK_Device_Peripheral) {
        _sendDeviceDiscoveredMessageToAllObservers(device: inPeripheral)
    }
}

/* ###################################################################################################################################### */
// MARK: - ITCB_SDK_Device_PeripheralDelegate Protocol (How we talk to the Central) -
/* ###################################################################################################################################### */
/**
 This protocol outlines the rules for talking back to the Central Manager that "owns" a Peripheral.
 */
internal protocol ITCB_SDK_Device_PeripheralDelegate: class {
    /* ################################################################## */
    /**
     This sends a "Peripheral Services Changed" message to the SDK.
     
     - parameter inPeripheral: The Peripheral instance that has a modified Service.
     */
    func peripheralServicesUpdated(_ inPeripheral: ITCB_SDK_Device_Peripheral)
}

/* ###################################################################################################################################### */
// MARK: - Peripheral Device Base Class -
/* ###################################################################################################################################### */
/**
 We need to keep in mind that Peripheral objects are actually owned by Central SDK instances.
 */
internal class ITCB_SDK_Device_Peripheral: ITCB_SDK_Device, ITCB_Device_Peripheral_Protocol {
    /// This is how long we have for a timeout, in seconds.
    internal let _timeoutLengthInSeconds: TimeInterval = 2.0
    
    /// This is the Central SDK that "owns" this device.
    internal var owner: ITCB_SDK_Central!
    
    /// The Timer instance that is created when we start an interaction. This will handle a timeout.
    internal var _timeoutTimer: Timer!
    
    /// This is a "holding tank" for the question. We put it in here, until we get confirmation that it was delivered.
    internal var _interimQuestion: String!

    /// The question property to conform to the protocol.
    public var question: String? = nil {
        didSet {
            owner?._sendSuccessInAskingMessageToAllObservers(device: self)
        }
    }

    /// The answer property to conform to the protocol.
    /// We use this opportunity to let everyone know that the question has been answered.
    public var answer: String? = nil {
        didSet {
            owner?._sendQuestionAnsweredMessageToAllObservers(device: self)
        }
    }
    
    /// This is the Peripheral Core Bluetooth device associated with this instance.
    internal var peripheralDeviceInstance: CBPeripheral! {
        _peerInstance as? CBPeripheral
    }
    
    /// We override the uuid property in order to get the UUID from the peripheral.
    public override var uuid: String? {
        get {
            if nil == super.uuid || (super.uuid?.isEmpty ?? false) {
                super.uuid = peripheralDeviceInstance?.identifier.uuidString
            }
            
            return super.uuid
        }
        
        set {
            super.uuid = newValue
        }
    }
    
    /// We override the name property in order to get the local name from the peripheral.
    internal override var name: String {
        get {
            if super.name.isEmpty {
                super.name = peripheralDeviceInstance?.name ?? ""
            }
            
            return super.name
        }
        
        set {
            super.name = newValue
        }
    }
    
    /* ################################################################## */
    /**
     This allows the user of an SDK to reject a connection attempt by another device (either a question or an answer).
     
     - parameter inReason: The reason for the rejection. It may be nil. If nil, .unknownError is assumed, with no error associated value.
     */
    public func rejectConnectionBecause(_ inReason: ITCB_RejectionReason! = .unknown(nil)) {
        owner?._sendErrorMessageToAllObservers(error: .coreBluetooth(inReason))
    }
    
    /* ################################################################## */
    /**
     Standard init.
     
     - parameter inCBPeripheral: The Core Bluetooth discovered Peripheral instance that will be associated with this instance.
     - parameter owner: The Central instance that "owns" this Peripheral.
     */
    init(_ inCBPeripheral: CBPeripheral, owner inOwner: ITCB_SDK_Central) {
        super.init()
        inCBPeripheral.delegate = self as? CBPeripheralDelegate // The cast, is because we aren't conformant until step 2.
        owner = inOwner
        _peerInstance = inCBPeripheral
    }
}
