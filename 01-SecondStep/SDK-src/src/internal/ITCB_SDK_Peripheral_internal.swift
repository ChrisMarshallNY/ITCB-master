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
// MARK: - Main SDK Peripheral Variant Computed Properties -
/* ###################################################################################################################################### */
/**
 This is the internal implementation of the SDK for the Peripheral Mode.
 
 **IMPORTANT NOTE:** Peripheral Mode is not supported for WatchOS or TVOS. This file is only included in the iOS and MacOS framework targets.
 */
internal extension ITCB_SDK_Peripheral {
    /* ################################################################## */
    /**
     This is a specific cast of the manager object that wil be attached to this instance.
     */
    var peripheralManagerInstance: CBPeripheralManager! {
        managerInstance as? CBPeripheralManager
    }

    /* ################################################################## */
    /**
     We override the typeless stored property with a computed one, and instantiate our manager, the first time through.
     */
    override var _managerInstance: Any! {
        get {
            if nil == super._managerInstance {
                super._managerInstance = CBPeripheralManager(delegate: self, queue: nil)
            }
            
            return super._managerInstance
        }
        
        set {
            super._managerInstance = newValue
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension ITCB_SDK_Peripheral {
    /* ################################################################## */
    /**
     This method will load or update a given Service with new or updated Characteristics.
     
     - parameter inMutableServiceInstance: The Service that we are adding the Characteristics to.
     */
    func _setCharacteristicsForThisService(_ inMutableServiceInstance: CBMutableService) {
        let questionProperties: CBCharacteristicProperties = [.write]
        let answerProperties: CBCharacteristicProperties = [.read, .notify]
        let questionPermissions: CBAttributePermissions = [.writeable]
        let answerPermissions: CBAttributePermissions = [.readable]

        let questionCharacteristic = CBMutableCharacteristic(type: _static_ITCB_SDK_8BallService_Question_UUID, properties: questionProperties, value: nil, permissions: questionPermissions)
        let answerCharacteristic = CBMutableCharacteristic(type: _static_ITCB_SDK_8BallService_Answer_UUID, properties: answerProperties, value: nil, permissions: answerPermissions)
        
        inMutableServiceInstance.characteristics = [questionCharacteristic, answerCharacteristic]
    }
    
    /* ################################################################## */
    /**
     This sends the "An answer was successfully sent" message to all registered observers.

     - parameters:
        - device: The Central device
        - answer: The answer that was sent
        - toQuestion: The question that was asked
     */
    func _sendSuccessInSendingAnswerToAllObservers(device inDevice: ITCB_Device_Central_Protocol, answer inAnswer: String, toQuestion inToQuestion: String) {
        observers.forEach {
            if let observer = $0 as? ITCB_Observer_Peripheral_Protocol {
                observer.answerSentToDevice(inDevice, answer: inAnswer, toQuestion: inToQuestion)
            }
        }
    }
    
    /* ################################################################## */
    /**
     This sends the "A question was asked" message to all registered observers.
     
     - parameters:
        - device: The Central device
        - question: The question that was asked
     */
    func _sendQuestionAskedToAllObservers(device inDevice: ITCB_Device_Central_Protocol, question inQuestion: String) {
        observers.forEach {
            if let observer = $0 as? ITCB_Observer_Peripheral_Protocol {
                observer.questionAskedByDevice(inDevice, question: inQuestion)
            }
        }
    }
    
    /* ################################################################## */
    /**
     This sends a random answer to the central.
     
     - parameter inQuestion: The question asked by the Central.
     */
    func _sendRandomAnswerToThisQuestion(_ inQuestion: String) {
        guard let central = central as? ITCB_SDK_Device_Central else { return }

        central.sendAnswer(String(format: "SLUG-ANSWER-%02d", Int.random(in: 0..<20)), toQuestion: inQuestion)
    }
}

/* ###################################################################################################################################### */
// MARK: - CBPeripheralManagerDelegate Methods -
/* ###################################################################################################################################### */
extension ITCB_SDK_Peripheral: CBPeripheralManagerDelegate {
    /* ################################################################## */
    /**
     This method is required by the Core Bluetooth system. It informs the delegate of a state change, in the CB manager instance.
     
     - parameter inPeripheralManager: The Peripheral Manager that experienced the change.
     */
    public func peripheralManagerDidUpdateState(_ inPeripheralManager: CBPeripheralManager) {
        assert(inPeripheralManager === managerInstance)   // Make sure that we are who we say we are...
        switch inPeripheralManager.state {
        // Once we are powered on, we can start advertising.
        case .poweredOn:
            // Make sure that we have a true Peripheral Manager (should never fail, but it pays to be sure).
            if let manager = peripheralManagerInstance {
                assert(manager === inPeripheralManager)
                // We create an instance of a mutable Service. This is our primary Service.
                let mutableServiceInstance = CBMutableService(type: _static_ITCB_SDK_8BallServiceUUID, primary: true)
                // Make sure that we "clear the decks," in case of a cache.
                inPeripheralManager.removeAllServices()
                // We set up empty Characteristics.
                _setCharacteristicsForThisService(mutableServiceInstance)
                // Add it to our manager instance.
                inPeripheralManager.add(mutableServiceInstance)
                // We have our primary Service in place. We can now advertise it. We announce that we can be connected.
                inPeripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [mutableServiceInstance.uuid],
                                                      CBAdvertisementDataLocalNameKey: localName
                ])
            }
        
        // Any state other than "Powered on" is an error.
        default:
            _sendErrorMessageToAllObservers(error: .coreBluetooth(nil))
        }
    }
    
    /* ################################################################## */
    /**
     This method is called when the Central changes the value of one of the Characteristics in our Service.
     
     - parameter inPeripheralManager: The Peripheral Manager that experienced the change.
     - parameter didReceiveWrite: The Write request objects, in an Array.
     */
    public func peripheralManager(_ inPeripheralManager: CBPeripheralManager, didReceiveWrite inWriteRequests: [CBATTRequest]) {
        guard   1 == inWriteRequests.count,
                let mutableChar = inWriteRequests[0].characteristic as? CBMutableCharacteristic,
                let data = inWriteRequests[0].value,
                let stringVal = String(data: data, encoding: .utf8) else {
            return
        }

        // The last character needs to be a question mark.
        guard "?" == stringVal.last else {
            inPeripheralManager.respond(to: inWriteRequests[0], withResult: .unlikelyError)
            return
        }
        
        mutableChar.value = data
        // Let the Central know that we got the question.
        inPeripheralManager.respond(to: inWriteRequests[0], withResult: .success)
        
        _sendRandomAnswerToThisQuestion(stringVal)
    }
    
    /* ################################################################## */
    /**
     - parameter inPeripheralManager: The Peripheral Manager that experienced the change.
     */
    public func peripheralManager(_ inPeripheralManager: CBPeripheralManager, central inCentral: CBCentral, didSubscribeTo inCharacteristic: CBCharacteristic) {
        // We do this, because you can get a subscription before the write.
        if nil == central {
            central = ITCB_SDK_Device_Central(inCentral, owner: self)
        }
        
        // If the Central has already asked the question, then we generate the random answer now.
        if  let central = central as? ITCB_SDK_Device_Central {
            central._subscribedChar = inCharacteristic
            // If a question was already asked, then it's time to answer it. Otherwise, we'll wait until the next callback.
            if let question = central._question {
                _sendRandomAnswerToThisQuestion(question)
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Central Device Base Class -
/* ###################################################################################################################################### */
/**
 We need to keep in mind that Central objects are actually owned by Peripheral SDK instances.
 */
internal class ITCB_SDK_Device_Central: ITCB_SDK_Device, ITCB_Device_Central_Protocol {
    /// This is the Peripheral SDK that "owns" this device.
    internal var owner: ITCB_SDK_Peripheral!
    
    /// This will be used to hold a subscribed Characteristic.
    internal var _subscribedChar: CBCharacteristic!
    
    /// This holds the question that was asked.
    internal var _question: String!

    /// This is the Central Core Bluetooth device associated with this instance.
    internal var centralDeviceInstance: CBCentral! {
        _peerInstance as? CBCentral
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
     Initializer with CBCentral
     
     - parameter inCentral: The CBCentral peer instance for this instance.
     - parameter owner: The Peripheral SDK instance that "owns" this device.
     */
    init(_ inCentral: CBCentral, owner inOwner: ITCB_SDK_Peripheral) {
        super.init()
        owner = inOwner
        _peerInstance = inCentral
    }
    
    /* ################################################################## */
    /**
     In the base class, all we do is send the "success" message to any observers.
     
     This should be called AFTER successfully sending the message.

     - parameter inAnswer: The answer.
     - parameter toQuestion: The question that was be asked.
     */
    public func sendAnswer(_ inAnswer: String, toQuestion inToQuestion: String) {
        if  let peripheralManager = owner.peripheralManagerInstance,
            let central = owner.central as? ITCB_SDK_Device_Central,
            let centralDevice = central.centralDeviceInstance,
            let answerCharacteristic = central._subscribedChar as? CBMutableCharacteristic,
            let data = inAnswer.data(using: .utf8) {
            peripheralManager.updateValue(data, for: answerCharacteristic, onSubscribedCentrals: [centralDevice])
            owner?._sendSuccessInSendingAnswerToAllObservers(device: self, answer: inAnswer, toQuestion: inToQuestion)
        }
        
        _question = nil // Clear out the property, so it doesn't pollute the next call.
    }
}
