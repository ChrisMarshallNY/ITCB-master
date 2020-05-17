/*
© Copyright 2020, Little Green Viper Software Development LLC

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

import Foundation
import CoreBluetooth

/* ###################################################################################################################################### */
// MARK: - Main SDK Interface Base Class -
/* ###################################################################################################################################### */
/**
 This is an internal-scope extension of the public SDK class, containing the actual implementations that fulfill the protocol contract.
 
 Internal-scope methods and properties are indicated by a leading underscore (_) in the name.
 */
extension ITCB_SDK {    
    /* ################################################################## */
    /**
      Any error condition associated with this instance. It may be nil.
     */
    internal var _error: ITCB_Errors? { nil }
    
    /* ################################################################## */
    /**
     This is a base class cast of the manager object that wil be attached to this instance.
     */
    internal var managerInstance: CBManager! {
        _managerInstance as? CBManager
    }

    /* ################################################################## */
    /**
     This is true, if Core Bluetooth reports that the device Bluetooth interface is powered on and available for use.
     */
    internal var _isCoreBluetoothPoweredOn: Bool {
        guard let manager = managerInstance else { return false }
        return .poweredOn == manager.state
    }
    
    /* ################################################################## */
    /**
      This adds the given observer to the list of observers for this SDK object. If the observer is already registered, nothing happens.
     
     - parameter inObserver: The Observer Instance to add.
     - returns: The newly-assigned UUID. Nil, if the observer was not added.
     */
    internal func _addObserver(_ inObserver: ITCB_Observer_Protocol) -> UUID! {
        if !isObserving(inObserver) {
            observers.append(inObserver)
            observers[observers.count - 1].uuid = UUID()    // This assigns a concrete UUID for use in comparing for removal and testing.
            return observers[observers.count - 1].uuid
        }
        return nil
    }
    
    /* ################################################################## */
    /**
     This removes the given observer from the list of observers for this SDK object. If the observer is not registered, nothing happens.
     
     - parameter inObserver: The Observer Instance to remove.
     */
    internal func _removeObserver(_ inObserver: ITCB_Observer_Protocol) {
        // There's a number of ways to do this. This way works fine.
        for index in 0..<observers.count where inObserver.uuid == observers[index].uuid {
            observers.remove(at: index)
            return
        }
    }
    
    /* ################################################################## */
    /**
     This checks the given observer, to see if it is currently observing this SDK instance.
     
     - parameter inObserver: The Observer Instance to check.
    
     - returns: True, if the observer is currently in the list of SDK observers.
     */
    internal func _isObserving(_ inObserver: ITCB_Observer_Protocol) -> Bool {
        for observer in observers where inObserver.uuid == observer.uuid {
            return true
        }
        
        return false
    }
    
    /* ################################################################## */
    /**
     This sends an error message to all registered observers.
     
     - parameter error: The error that we are sending.
     */
    internal func _sendErrorMessageToAllObservers(error inError: ITCB_Errors) {
        observers.forEach {
            $0.errorOccurred(inError, sdk: self)
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Special Comparator for the devices Array -
/* ###################################################################################################################################### */
/**
 This extension implements a method like contains(_:), to compare the UUIDs of Peripherals.
 */
extension Array where Element == ITCB_Device_Peripheral_Protocol {
    /* ################################################################## */
    /**
     This searches the Array for instances of a given device, comparing UUIDs
     
     - parameter inCBPeripheral: The device that we are comparing, but as a CBPeripheral.
     
     - returns: True, if the Array contains the device.
     */
    func contains(_ inCBPeripheral: CBPeripheral) -> Bool {
        let peripheralStringID = inCBPeripheral.identifier.uuidString
        guard let myself = self as? [ITCB_SDK_Device_Peripheral], !peripheralStringID.isEmpty else { return false }
        return myself.reduce(false) { (current, nextItem) in
            return current || nextItem.uuid == peripheralStringID
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Special Comparator for the Services and Characteristics Arrays -
/* ###################################################################################################################################### */
/**
 This allows us to fetch Attributes by their UUID.
 */
extension Array where Element: CBAttribute {
    /* ################################################################## */
    /**
     Special String subscript that allows us to retrieve a Service, by its CBUUID
     
     - parameter inUUIDString: The String for the UUID we're looking to match.
     - returns: The found Attribute, or nil, if not found.
     */
    public subscript(_ inUUIDString: String) -> Element! {
        for element in self where element.uuid.uuidString == inUUIDString {
            return element
        }
        
        return nil
    }
}

/* ###################################################################################################################################### */
// MARK: - General Device Base Class -
/* ###################################################################################################################################### */
/**
 This is the general base class for Central and Peripheral devices.
 
 It derives from NSObject, as its subclasses are Core Bluetooth delegates.
 */
internal class ITCB_SDK_Device: NSObject {
    /// The name property to conform to the protocol.
    public var name: String = ""
    
    /// The error property to conform to the protocol.
    public var error: ITCB_Errors!
    
    /// This is an internal stored property that is used to reference a Core Bluetooth peer instance (either a Central or Peripheral), associated with this device.
    internal var _peerInstance: CBPeer!

    /// This is a String, representing a unique UUID for this device.
    public var uuid: String?
    
    /* ################################################################## */
    /**
     This is a "faux Equatable" method. It allows us to compare something that is expressed only as a protocol instance with ourselves, without the need to be Equatable.
     
     - parameter inDevice: The device that we are comparing.
     
     - returns: True, if we are the device.
     */
    public func amIThisDevice(_ inDevice: ITCB_Device_Protocol) -> Bool {
        if let device = inDevice as? ITCB_SDK_Device {
            return device.uuid == uuid
        }
        
        return false
    }
}
