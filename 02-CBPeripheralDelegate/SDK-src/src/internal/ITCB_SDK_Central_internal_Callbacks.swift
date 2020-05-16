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

internal let _static_ITCB_SDK_RSSI_Min = -60
internal let _static_ITCB_SDK_RSSI_Max = -20

extension ITCB_SDK_Central {
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

extension ITCB_SDK_Central: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ centralManager: CBCentralManager) {
        if .poweredOn == centralManager.state {
            print("Scanning for Peripherals")
            centralManager.scanForPeripherals(withServices: [_static_ITCB_SDK_8BallServiceUUID], options: nil)
        }
    }

    public func centralManager(_ centralManager: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {
        if  !devices.contains(peripheral),
            let peripheralName = peripheral.name,
            !peripheralName.isEmpty,
            (_static_ITCB_SDK_RSSI_Min..._static_ITCB_SDK_RSSI_Max).contains(rssi.intValue) {
            print("Peripheral Discovered: \(peripheralName), RSSI: \(rssi)")
            devices.append(ITCB_SDK_Device_Peripheral(peripheral, owner: self))
            print("Connecting to \(peripheralName).")
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    public func centralManager(_ centralManager: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Successfully Connected to \(peripheral.name ?? "ERROR").")
        print("Discovering Services for \(peripheral.name ?? "ERROR").")
        peripheral.discoverServices([_static_ITCB_SDK_8BallServiceUUID])
    }
}

extension ITCB_SDK_Device_Peripheral {
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
            print("Cannot send the question, because the question data is bad.")
            self.owner?._sendErrorMessageToAllObservers(error: .sendFailed(ITCB_RejectionReason.unknown(nil)))
        } else {
            print("Cannot send the question, because the Peripheral may be offline, or have other problems.")
            self.owner?._sendErrorMessageToAllObservers(error: .sendFailed(ITCB_RejectionReason.deviceOffline))
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Encountered an error \(error) for the Peripheral \(peripheral.name ?? "ERROR")")
            _timeoutTimer?.invalidate()
            _timeoutTimer = nil
            owner?._sendErrorMessageToAllObservers(error: ITCB_Errors.coreBluetooth(error))
            return
        }
        print("Successfully Discovered \(peripheral.services?.count ?? 0) Services for \(peripheral.name ?? "ERROR").")
        peripheral.services?.forEach {
            peripheral.discoverCharacteristics([_static_ITCB_SDK_8BallService_Question_UUID,
                                                _static_ITCB_SDK_8BallService_Answer_UUID], for: $0)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Encountered an error \(error) for the Peripheral \(peripheral.name ?? "ERROR")")
            _timeoutTimer?.invalidate()
            _timeoutTimer = nil
            owner?._sendErrorMessageToAllObservers(error: ITCB_Errors.coreBluetooth(error))
            return
        }
        print("Successfully Discovered \(service.characteristics?.count ?? 0) Characteristics for the Service \(service.uuid.uuidString), on the Peripheral \(peripheral.name ?? "ERROR").")
        owner.peripheralServicesUpdated(self)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        _timeoutTimer?.invalidate()
        _timeoutTimer = nil
        if  nil == error {
            print("Characteristic \(characteristic.uuid.uuidString) reports that its value was accepted by the Peripheral.")
            if let questionString = _interimQuestion {
                question = questionString
            } else {
                owner?._sendErrorMessageToAllObservers(error: .sendFailed(ITCB_RejectionReason.peripheralError(nil)))
            }
        } else {
            if let error = error as? CBATTError {
                print("Encountered an error \(error) for the Peripheral \(peripheral.name ?? "ERROR")")
                switch error {
                case CBATTError.unlikelyError:
                    owner?._sendErrorMessageToAllObservers(error: .sendFailed(ITCB_Errors.coreBluetooth(ITCB_RejectionReason.questionPlease)))

                default:
                    owner?._sendErrorMessageToAllObservers(error: .sendFailed(ITCB_Errors.coreBluetooth(ITCB_RejectionReason.peripheralError(error))))
                }
            } else {
                owner?._sendErrorMessageToAllObservers(error: .sendFailed(ITCB_RejectionReason.unknown(error)))
            }
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Encountered an error \(error) for the Peripheral \(peripheral.name ?? "ERROR")")
            _timeoutTimer?.invalidate()
            _timeoutTimer = nil
            owner?._sendErrorMessageToAllObservers(error: ITCB_Errors.coreBluetooth(error))
            return
        }
        print("Characteristic \(characteristic.uuid.uuidString) Updated its value to \(String(describing: characteristic.value)).")
        if  let answerData = characteristic.value,
            let answerString = String(data: answerData, encoding: .utf8),
            !answerString.isEmpty {
            _timeoutTimer?.invalidate()
            _timeoutTimer = nil
            peripheral.setNotifyValue(false, for: characteristic)
            answer = answerString
        }
    }
}
