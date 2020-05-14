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

/* ###################################################################################################################################### */
// MARK: - Main SDK Interface Protocol -
/* ###################################################################################################################################### */
/**
 This is the main "generic" protocol, applicable to both Central and Peripheral.
 
 The SDK defines an interface between Bluetooth LE devices and abstracts [Apple's Core Bluetooth Library](https://developer.apple.com/documentation/corebluetooth).
 
 The SDK can be instantiated as either a Bluetooth LE ["Central,"](https://developer.apple.com/documentation/corebluetooth/cbcentralmanager) or as a ["Peripheral."](https://developer.apple.com/documentation/corebluetooth/cbperipheralmanager).
 
 The role of the SDK is determined by which variant of the SDK is instantiated.
 
 This is a teaching aid, and, as such, has an extremely limited and tightly-defined functionality. It is a Bluetooth expression of [a "Magic 8-Ball" app](https://en.wikipedia.org/wiki/Magic_8-Ball).
 
 Centrals are instantiated as `ITCB_SDK_Central` instances, and Peripherals are instantiated as `ITCB_SDK_Peripheral` instances. They are described as protocols, instead of concrete classes or structs, in order to assure opacity and flexibility.

 All protocol members are required (Except for the internal `createInstance()` method; which is, in reality, required).
 */
public protocol ITCB_SDK_Protocol {
    /* ################################################################## */
    /**
     Factory function for instantiating Centrals or Peripherals.
     
     This is really for internal use only.
     
     - returns: A new instance of an SDK.
     */
    static func createInstance() -> ITCB_SDK_Protocol?

    /* ################################################################## */
    /**
      Any error condition associated with this instance. It may be nil.
     */
    var error: ITCB_Errors? { get }

    /* ################################################################## */
    /**
     This is true, if Core Bluetooth reports that the device Bluetooth interface is powered on and available for use.
     */
    var isCoreBluetoothPoweredOn: Bool { get }
    
    /* ################################################################## */
    /**
     This is a String that can be applied by the user. It will be advertised, or set to local CoreBluetooth Peripherals and Centrals.
     */
    var localName: String { get set }
    
    /* ################################################################## */
    /**
     This is an Array of observer objects associated with this SDK instance.
     */
    var observers: [ITCB_Observer_Protocol] { get set }

    /* ################################################################## */
    /**
      This adds the given observer to the list of observers for this SDK object. If the observer is already registered, nothing happens.
     
     - parameter observer: The Observer Instance to add.
     - returns: The newly-assigned UUID. Nil, if the observer was not added.
     */
    func addObserver(_ observer: ITCB_Observer_Protocol) -> UUID!
    
    /* ################################################################## */
    /**
     This removes the given observer from the list of observers for this SDK object. If the observer is not registered, nothing happens.
     
     - parameter observer: The Observer Instance to remove.
     */
    func removeObserver(_ observer: ITCB_Observer_Protocol)
    
    /* ################################################################## */
    /**
     This checks the given observer, to see if it is currently observing this SDK instance.
     
     - parameter observer: The Observer Instance to check.
    
     - returns: True, if the observer is currently in the list of SDK observers.
     */
    func isObserving(_ observer: ITCB_Observer_Protocol) -> Bool
}

/* ###################################################################################################################################### */
// MARK: - Main SDK Interface Protocol Defaults -
/* ###################################################################################################################################### */
extension ITCB_SDK_Protocol {
    /* ################################################################## */
    /**
     This is just here to allow the protocol to make the func optional. It returns nil.
     
     - returns: nil
     */
    public static func createInstance() -> ITCB_SDK_Protocol? { return nil }
}

/* ###################################################################################################################################### */
// MARK: - This is the protocol for a Central Instance of the SDK -
/* ###################################################################################################################################### */
/**
 This specializes the general SDK for Centrals.
 */
public protocol ITCB_SDK_Central_Protocol: ITCB_SDK_Protocol {
    /* ################################################################## */
    /**
     This is a list of discovered 8-balls.
     */
    var devices: [ITCB_Device_Peripheral_Protocol] { get }
}

/* ###################################################################################################################################### */
// MARK: - This is the protocol for a Peripheral Instance of the SDK -
/* ###################################################################################################################################### */
/**
 This specializes the general SDK for Peripherals.
 */
public protocol ITCB_SDK_Peripheral_Protocol: ITCB_SDK_Protocol {
    /* ################################################################## */
    /**
     This is a reference to the Central device that is "managing" this Peripheral.
     */
    var central: ITCB_Device_Central_Protocol! { get }
}

/* ###################################################################################################################################### */
// MARK: - This is the "Base" Device Protocol for the Main SDK -
/* ###################################################################################################################################### */
/**
 This just has a couple of common properties.
 */
public protocol ITCB_Device_Protocol {
    /* ################################################################## */
    /**
     This is the device name.
     */
    var name: String { get }
    
    /* ################################################################## */
    /**
     This is any errors that may have occurred. It may be nil.
     */
    var error: ITCB_Errors! { get }
    
    /* ################################################################## */
    /**
     This is a "faux Equatable" method. It allows us to compare something that is expressed only as a protocol instance with ourselves, without the need to be Equatable.
     
     The reason for doing this, is that I don't want to have to conform to the whole Equatable protocol. We just need a quick identity test, and this will give it to us without requiring anything too fancy.
     
     - parameter inDevice: The device that we are comparing.
     
     - returns: True, if we are the device.
     */
    func amIThisDevice(_ inDevice: ITCB_Device_Protocol) -> Bool
    
    /* ################################################################## */
    /**
     This allows the user of an SDK to reject a connection attempt by another device (either a question or an answer).
     
     The reason that we have this, as opposed to a function return from the observer, is because I think observer should be one-way. Outgoing only.
     
     - parameter reason: The reason for the rejection. It may be nil. If nil, .unknownError is assumed, with no error associated value.
     */
    func rejectConnectionBecause(_ reason: ITCB_RejectionReason!)
}

/* ###################################################################################################################################### */
// MARK: - This is the Central Device Protocol Specialization for the Main SDK -
/* ###################################################################################################################################### */
/**
 We simply add a "send question" method.
 */
public protocol ITCB_Device_Central_Protocol: ITCB_Device_Protocol {
    /* ################################################################## */
    /**
     This is used by a Peripheral to respond to a Central with an answer.
     
     - parameter answer: The answer sent by this Peripheral to the Central.
     - parameter toQuestion: The question that we are answering.
     */
    func sendAnswer(_ answer: String, toQuestion: String)
}

/* ###################################################################################################################################### */
// MARK: - This is the Peripheral Device Protocol Specialization for the Main SDK -
/* ###################################################################################################################################### */
/**
 We add a couple of properties to hold the last question and answer to the peripheral.
 */
public protocol ITCB_Device_Peripheral_Protocol: ITCB_Device_Protocol {
    /* ################################################################## */
    /**
     This is any question that may have been asked. It can be nil.
     */
    var question: String! { get }

    /* ################################################################## */
    /**
     This is any answer that has been provided by this Peripheral. It can be nil.
     */
    var answer: String! { get }

    /* ################################################################## */
    /**
     This is used by a Central to ask a Peripheral a question.
     
     IMPLEMENTATION NOTE: This method should set the `question` and `answer` properties to nil, and not set the `question` property until receiving confirmation from the device.

     - parameter question: The question sent by this Central to the Peripheral.
     */
    func sendQuestion(_ question: String)
}

/* ###################################################################################################################################### */
// MARK: - Observer Protocol for the Main SDK -
/* ###################################################################################################################################### */
/**
 This protocol describes an instance that can register to observe the main SDK.
 
 All members are required.
 */
public protocol ITCB_Observer_Protocol {
    /* ################################################################## */
    /**
      This is a unique UUID that will allow us to identify this instance.
     
      The implementor should define this, then ignore it.
     */
    var uuid: UUID { get set }
    
    /* ################################################################## */
    /**
     Called when an error condition is encountered by the SDK.
     This is required.
     
     - parameter error: The error code that occurred.
     - parameter sdk: The SDK instance that experienced the error.
     */
    func errorOccurred(_ error: ITCB_Errors, sdk: ITCB_SDK_Protocol)
}

/* ###################################################################################################################################### */
// MARK: - This is the protocol for an Observer of the Central Instance of the SDK -
/* ###################################################################################################################################### */
/**
 This is an observer specialization for Central instances.
 
 All members are required.
 */
public protocol ITCB_Observer_Central_Protocol: ITCB_Observer_Protocol {
    /* ################################################################## */
    /**
     This is called when a Peripheral returns an answer to the Central.
     
     This may not be called in the main thread.

     - parameter device: The Peripheral device that provided the answer (this will have both the question and answer in its properties).
     */
    func questionAnsweredByDevice(_ device: ITCB_Device_Peripheral_Protocol)
    
    /* ################################################################## */
    /**
     This is called when a Central successfully asks a question of a peripheral.
     
     This may not be called in the main thread.

     - parameter device: The Peripheral device that was asked the question (The question will be in the device properties).
     */
    func questionAskedOfDevice(_ device: ITCB_Device_Peripheral_Protocol)
    
    /* ################################################################## */
    /**
     This is called when a Central discovers and registers a peripheral.
     
     This may not be called in the main thread.

     - parameter device: The Peripheral device that was discovered.
     */
    func deviceDiscovered(_ device: ITCB_Device_Peripheral_Protocol)
}

/* ###################################################################################################################################### */
// MARK: - This is the protocol for an Observer of the Peripheral Instance of the SDK -
/* ###################################################################################################################################### */
/**
 This is an observer specialization for Peripheral instances.
 
 All members are required.
 */
public protocol ITCB_Observer_Peripheral_Protocol: ITCB_Observer_Protocol {
    /* ################################################################## */
    /**
     This is called when a Central asks a Peripheral a question.
     
     This may not be called in the main thread.

     - parameter device: The Central device that provided the question.
     - parameter question: The question that was asked by the Central.
     */
    func questionAskedByDevice(_ device: ITCB_Device_Central_Protocol, question: String)
    
    /* ################################################################## */
    /**
     This is called when a Peripheral successfully answers a Central's question.
     
     This may not be called in the main thread.
     
     - parameter device: The Central device that provided the question.
     - parameter answer: The answer that was sent to the Central.
     - parameter toQuestion: The question that was asked by the Central.
     */
    func answerSentToDevice(_ device: ITCB_Device_Central_Protocol, answer: String, toQuestion: String)
}

/* ###################################################################################################################################### */
// MARK: - Error Codes and Reporting Enum -
/* ###################################################################################################################################### */
/**
 This enum encapsulates the errors that are possible from the SDK.
 */
public enum ITCB_Errors: Error {
    /* ################################################################## */
    /**
      These are Core Bluetooth internal errors.
     
      - parameter error: The error from Core Bluetooth, associated with this enum instance.
     */
    case coreBluetooth(Error?)
    
    /* ################################################################## */
    /**
      The send (question or answer) failed. Which one will be obvious by the context.
     
      - parameter error: The error from the system, associated with this enum instance. NOTE: This may be an instance of ITCB_RejectionReason
     */
    case sendFailed(Error?)
    
    /* ################################################################## */
    /**
      Unknown error or connection rejection.
     
      - parameter error: Possible error code associated with this enum instance.
     */
    case unknown(Error?)
    
    /* ################################################################## */
    /**
     We send back text slugs, to be interpreted by the user app.
     
     Possible values are:
        - `"ITCB-SDK-ERROR-UNKNOWN"`: Unknown error
        - `"ITCB-SDK-ERROR-BLUETOOTH"`: Some Bluetooth error
        - `"ITCB-SDK-ERROR-SEND-FAILURE"`: Sending Failed
     
     The user app should also extract any associated values.
     */
    public var localizedDescription: String {
        var ret: String
        
        switch self {
            case .coreBluetooth:
                ret = "ITCB-SDK-ERROR-BLUETOOTH"
            
            case .sendFailed:
                ret = "ITCB-SDK-ERROR-SEND-FAILURE"

            case .unknown:
                ret = "ITCB-SDK-ERROR-UNKNOWN"
        }
        
        return ret
    }
    
    /* ################################################################## */
    /**
     This will return any associated value. It may be nil.
    */
    var associatedValue: Error? {
        var ret: Error!
        
        switch self {
        case .coreBluetooth(let val):
            ret = val
            
        case .sendFailed(let val):
            ret = val
            
        case .unknown(let val):
            ret = val
        }
        
        return ret
    }
}

/* ###################################################################################################################################### */
// MARK: - Rejection Reasons Enum -
/* ###################################################################################################################################### */
/**
 This enum encapsulates the reasons that a device communication may have been received, but rejected, on the other end.
 */
public enum ITCB_RejectionReason: Error {
    /* ################################################################## */
    /**
      The device is offline, and cannot receive the connection.
     */
    case deviceOffline

    /* ################################################################## */
    /**
      The device is busy, and cannot receive the connection.
     */
    case deviceBusy

    /* ################################################################## */
    /**
      The String needs to be phrased in the form of a question (question mark at the end).
     */
    case questionPlease

    /* ################################################################## */
    /**
      There was some kind of error in the Peripheral.
     
      - parameter error: Possible error code associated with this enum instance.
     */
    case peripheralError(Error?)

    /* ################################################################## */
    /**
      Unknown error
     
      - parameter error: Possible error code associated with this enum instance.
     */
    case unknown(Error?)
    
    /* ################################################################## */
    /**
     We send back text slugs, to be interpreted by the user app.
     
     Possible values are:
        - `"ITCB-SDK-REJECT-OFFLINE"`           : Device is Offline
        - `"ITCB-SDK-REJECT-BUSY"`              : Device is busy
        - `"ITCB-SDK-REJECT-NO-QUESTION-MARK"`  : The String needs to be phrased in the form of a question (question mark at the end).
        - `"ITCB-SDK-REJECT-PERIPHERAL-ERROR"`  : There was some kind of error in the Peripheral.
        - `"ITCB-SDK-REJECT-UNKNOWN"`           : Unspecified reason
     
     The user app should also extract any associated values (Unknown).
     */
    public var localizedDescription: String {
        var ret: String
        
        switch self {
            case .deviceOffline:
                ret = "ITCB-SDK-REJECT-OFFLINE"
            
            case .deviceBusy:
                ret = "ITCB-SDK-REJECT-BUSY"
            
            case .questionPlease:
                ret = "ITCB-SDK-REJECT-NO-QUESTION-MARK"
            
            case .peripheralError:
                ret = "ITCB-SDK-REJECT-PERIPHERAL-ERROR"

            case .unknown:
                ret = "ITCB-SDK-REJECT-UNKNOWN"
        }
            
        return ret
    }
    
    /* ################################################################## */
    /**
     This will return any associated value (unknown error only has one). It may be nil.
    */
    var associatedValue: Error? {
        var ret: Error!
        
        switch self {
        case .unknown(let val): // We can associate an error with the unknown type.
            ret = val
            
        case .peripheralError(let val): // The Peripheral Error can have an associated error.
            ret = val
            
        default:    // All others will return nil.
            break
        }
        
        return ret
    }
}
