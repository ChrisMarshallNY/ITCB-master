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

import CoreBluetooth

// MARK: Various Static Constants

/// This is the UUID we use for our "Magic 8-Ball" Service
internal let _static_ITCB_SDK_8BallServiceUUID = CBUUID(string: "8E38140A-27BE-4090-8955-4FC4B5698D1E")
/// This is the UUID for the "Question" String Characteristic
internal let _static_ITCB_SDK_8BallService_Question_UUID = CBUUID(string: "BDD37D7A-F66A-47B9-A49C-FE29FD235A77")
/// This is the UUID for the "Answer" String Characteristic
internal let _static_ITCB_SDK_8BallService_Answer_UUID = CBUUID(string: "349A0D7B-6215-4E2C-A095-AF078D737445")
/// This is the minimum signal strength for Peripheral discovery.
internal let _static_ITCB_SDK_RSSI_Min = -60
/// This is the maximum signal strength for Peripheral discovery.
internal let _static_ITCB_SDK_RSSI_Max = -20

/* ###################################################################################################################################### */
// MARK: - Special Computed Property -
/* ###################################################################################################################################### */
extension ITCB_SDK_Central {
    /* ################################################################## */
    /**
     We override the typeless stored property with a computed one, and instantiate our manager, the first time through.
     */
    override var _managerInstance: Any! {
        get {
            if super._managerInstance == nil {
                super._managerInstance = CBCentralManager(delegate: self, queue: nil)
            }
            
            return super._managerInstance
        }
        
        set {
            super._managerInstance = newValue
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - CBCentralManagerDelegate Conformance -
/* ###################################################################################################################################### */
extension ITCB_SDK_Central: CBCentralManagerDelegate {
    /* ################################################################## */
    /**
     This is called as the state changes for the Central manager object.
     
     - parameter centralManager: The Central Manager instance that changed state.
     */
    public func centralManagerDidUpdateState(_ centralManager: CBCentralManager) {
        assert(centralManager === managerInstance)   // Make sure that we are who we say we are...
        // Once we are powered on, we can start scanning.
        if .poweredOn == centralManager.state {
            centralManager.scanForPeripherals(withServices: [_static_ITCB_SDK_8BallServiceUUID], options: nil)
        }
    }

    /* ################################################################## */
    /**
     This is called as the state changes for the Central manager object.
     
     - parameters:
        - centralManager: The Central Manager instance that changed state.
        - didDiscover: This is the Core Bluetooth Peripheral instance that was discovered.
        - advertisementData: This is the adverstiement data that was sent by the discovered Peripheral.
        - rssi: This is the signal strength of the discovered Peripheral.
     */
    public func centralManager(_ centralManager: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        assert(centralManager === managerInstance)    // Make sure that we are who we say we are...
        if  !devices.contains(peripheral),            // Make sure that we don't already have this peripheral.
            let peripheralName = peripheral.name,     // And that it is a legit Peripheral (has a name).
            !peripheralName.isEmpty,
            (_static_ITCB_SDK_RSSI_Min..._static_ITCB_SDK_RSSI_Max).contains(rssi.intValue) { // and that we have a signal within the acceptable range.
            devices.append(ITCB_SDK_Device_Peripheral(peripheral, owner: self))   // By creating this, we develop a strong reference, which will keep the CBPeripheral around.
            centralManager.connect(peripheral, options: nil)    // We initiate a connection, which starts the voyage of discovery.
        }
    }
    
    /* ################################################################## */
    /**
     This is called when a peripheral was connected.
     
     Once the device is connected, we can start discovering services.
     
     - parameters:
        - centralManager: The Central Manager instance that changed state.
        - didConnect: This is the Core Bluetooth Peripheral instance that was discovered.
     */
    public func centralManager(_ centralManager: CBCentralManager, didConnect peripheral: CBPeripheral) {
        assert(centralManager === managerInstance)    // Make sure that we are who we say we are...
        peripheral.discoverServices([_static_ITCB_SDK_8BallServiceUUID])  // Start Service discovery on our new Peripheral.
    }
}

/* ###################################################################################################################################### */
// MARK: - CBPeripheralDelegate Conformance, and sendQuestion Method -
/* ###################################################################################################################################### */
extension ITCB_SDK_Device_Peripheral {
    /* ################################################################## */
    /**
     This sends a question to the Peripheral device, using Core Bluetooth.
     
     - parameter inQuestion: The question to be asked.
     */
    public func sendQuestion(_ inQuestion: String) {
        question = nil
        if  let data = inQuestion.data(using: .utf8),
            let peripheral = _peerInstance as? CBPeripheral,
            let service = peripheral.services?[_static_ITCB_SDK_8BallServiceUUID.uuidString],
            let questionCharacteristic = service.characteristics?[_static_ITCB_SDK_8BallService_Question_UUID.uuidString],
            let answerCharacteristic = service.characteristics?[_static_ITCB_SDK_8BallService_Answer_UUID.uuidString] {
            _timeoutTimer = Timer.scheduledTimer(withTimeInterval: _timeoutLengthInSeconds, repeats: false) { [unowned self] (_) in
                self._timeoutTimer = nil
                self.owner?._sendErrorMessageToAllObservers(error: .sendFailed(ITCB_RejectionReason.deviceOffline))
            }
            _interimQuestion = inQuestion
            peripheral.setNotifyValue(true, for: answerCharacteristic)
            peripheral.writeValue(data, for: questionCharacteristic, type: .withResponse)
        } else if inQuestion.data(using: .utf8) == nil {
            self.owner?._sendErrorMessageToAllObservers(error: .sendFailed(ITCB_RejectionReason.unknown(nil)))
        } else {
            self.owner?._sendErrorMessageToAllObservers(error: .sendFailed(ITCB_RejectionReason.deviceOffline))
        }
    }

    /* ################################################################## */
    /**
     Called after the Peripheral has discovered Services.
     
     - parameter peripheral: The Peripheral object that discovered (and now contains) the Services.
     - parameter didDiscoverServices: Any errors that may have occurred. It may be nil.
     */
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // If we suffered an error, we simply report it, and stop caring.
        if let error = error {
            _timeoutTimer?.invalidate()  // Stop our timeout timer.
            _timeoutTimer = nil
            owner?._sendErrorMessageToAllObservers(error: ITCB_Errors.coreBluetooth(error))
            return
        }
        // After discovering the Service, we ask it (even though we are using an Array visitor) to discover its three Characteristics.
        peripheral.services?.forEach {
            // Having all 3 Characteristic UUIDs in this call, means that we should get one callback, with all 3 Characteristics set at once.
            peripheral.discoverCharacteristics([_static_ITCB_SDK_8BallService_Question_UUID,
                                                _static_ITCB_SDK_8BallService_Answer_UUID], for: $0)
        }
    }
    
    /* ################################################################## */
    /**
     Called after the Peripheral has discovered Services.
     
     - parameter peripheral: The Peripheral object that discovered (and now contains) the Services (ignored).
     - parameter didDiscoverCharacteristicsFor: The Service that had the Characteristics discovered.
     - parameter error: Any errors that may have occurred. It may be nil.
     */
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // If we suffered an error, we simply report it, and stop caring.
        if let error = error {
            _timeoutTimer?.invalidate()  // Stop our timeout timer.
            _timeoutTimer = nil
            owner?._sendErrorMessageToAllObservers(error: ITCB_Errors.coreBluetooth(error))
            return
        }
        owner.peripheralServicesUpdated(self)
    }
    
    /* ################################################################## */
    /**
     Called when the Peripheral updates a Characteristic that we wanted written (the Question).
     NOTE: The characteristic.value field IS NOT VALID in this call. That's why we saved the _interimQuestion property.
     
     - parameter peripheral: The Peripheral object that discovered (and now contains) the Services.
     - parameter didWriteValueFor: The Characteristic that was updated.
     - parameter error: Any errors that may have occurred. It may be nil.
     */
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if  nil == error {
            if let questionString = _interimQuestion {  // We should have had an interim question queued up.
                question = questionString
            } else {
                _timeoutTimer?.invalidate()  // Stop our timeout timer.
                _timeoutTimer = nil
                owner?._sendErrorMessageToAllObservers(error: .sendFailed(ITCB_RejectionReason.peripheralError(nil)))
            }
        } else {
            _timeoutTimer?.invalidate()  // Stop our timeout timer. We only need the one error.
            _timeoutTimer = nil
            if let error = error as? CBATTError {
                switch error {
                // We get an "unlikely" error only when there was no question mark, so we are safe in assuming that.
                case CBATTError.unlikelyError:
                    owner?._sendErrorMessageToAllObservers(error: .sendFailed(ITCB_Errors.coreBluetooth(ITCB_RejectionReason.questionPlease)))

                // For everything else, we simply send the error back, wrapped in the "sendFailed" error.
                default:
                    owner?._sendErrorMessageToAllObservers(error: .sendFailed(ITCB_Errors.coreBluetooth(ITCB_RejectionReason.peripheralError(error))))
                }
            } else {
                owner?._sendErrorMessageToAllObservers(error: .sendFailed(ITCB_RejectionReason.unknown(error)))
            }
        }
    }

    /* ################################################################## */
    /**
     Called when the Peripheral updates a Characteristic (the Answer).
     The characteristic.value field can be considered valid.
     
     - parameter peripheral: The Peripheral object that discovered (and now contains) the Services.
     - parameter didUpdateValueFor: The Characteristic that was updated.
     - parameter error: Any errors that may have occurred. It may be nil.
     */
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // If we suffered an error, we simply report it, and stop caring.
        if let error = error {
            _timeoutTimer?.invalidate()  // Stop our timeout timer.
            _timeoutTimer = nil
            owner?._sendErrorMessageToAllObservers(error: ITCB_Errors.coreBluetooth(error))
            return
        }
        if  let answerData = characteristic.value,
            let answerString = String(data: answerData, encoding: .utf8),
            !answerString.isEmpty {
            _timeoutTimer?.invalidate()  // Stop our timeout timer.
            _timeoutTimer = nil
            peripheral.setNotifyValue(false, for: characteristic)
            answer = answerString
        }
    }
}
