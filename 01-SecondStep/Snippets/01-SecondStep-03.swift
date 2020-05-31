    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {

        if let error = error {
            _timeoutTimer?.invalidate()
            _timeoutTimer = nil
            owner?._sendErrorMessageToAllObservers(error: ITCB_Errors.coreBluetooth(error))
            return
        }

        if  let question = _interimQuestion,
            let data = question.data(using: .utf8),
            characteristic.isNotifying,
            let service = peripheral.services?[_static_ITCB_SDK_8BallServiceUUID.uuidString],
            let questionCharacteristic = service.characteristics?[_static_ITCB_SDK_8BallService_Question_UUID.uuidString] {
            print("The Peripheral's answer Characteristic is now notifying.")
            print("Asking the Peripheral \(peripheral.name) the question \"\(_interimQuestion)\".")
            peripheral.writeValue(data, for: questionCharacteristic, type: .withResponse)
        }
    }
