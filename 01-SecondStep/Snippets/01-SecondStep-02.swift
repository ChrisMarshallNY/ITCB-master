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
            if answerCharacteristic.isNotifying {  
                print("Asking the Peripheral \(peripheral.name ?? "ERROR") the question \"\(_interimQuestion ?? "ERROR")\".")
                peripheral.writeValue(data, for: questionCharacteristic, type: .withResponse)
            } else {  
                print("Not yet asking the Peripheral \(peripheral.name ?? "ERROR") the question \"\(_interimQuestion ?? "ERROR")\", as we need to first set the answer Characteristic to notify.")
                peripheral.setNotifyValue(true, for: answerCharacteristic)
            }
        } else if inQuestion.data(using: .utf8) == nil {  
            print("Cannot send the question, because the question data is bad.")  
            self.owner?._sendErrorMessageToAllObservers(error: .sendFailed(ITCB_RejectionReason.unknown(nil)))  
        } else {  
            print("Cannot send the question, because the Peripheral may be offline, or have other problems.")  
            self.owner?._sendErrorMessageToAllObservers(error: .sendFailed(ITCB_RejectionReason.deviceOffline))  
        }
    }
}
