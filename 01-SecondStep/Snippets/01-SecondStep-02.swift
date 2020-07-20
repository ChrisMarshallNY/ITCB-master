extension ITCB_SDK_Device_Peripheral {
    public func sendQuestion(_ inQuestion: String) {
        question = nil
        if  let peripheral = _peerInstance as? CBPeripheral,
            let service = peripheral.services?[_static_ITCB_SDK_8BallServiceUUID.uuidString],
            let answerCharacteristic = service.characteristics?[_static_ITCB_SDK_8BallService_Answer_UUID.uuidString] {
            _timeoutTimer = Timer.scheduledTimer(withTimeInterval: _timeoutLengthInSeconds, repeats: false) { [unowned self] (_) in
                self._timeoutTimer = nil
                self.owner?._sendErrorMessageToAllObservers(error: .sendFailed(ITCB_RejectionReason.deviceOffline))
            }
            _interimQuestion = inQuestion
            
            print("We have received the question \"\(inQuestion)\", and are setting it aside, as we ask the Peripheral to set the notify to true for the answer Characteristic.")
            peripheral.setNotifyValue(true, for: answerCharacteristic)
        } else {
            self.owner?._sendErrorMessageToAllObservers(error: .sendFailed(ITCB_RejectionReason.deviceOffline))
        }
    }
}
