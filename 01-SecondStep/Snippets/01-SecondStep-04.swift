    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        _timeoutTimer?.invalidate()
        _timeoutTimer = nil
        
        guard let error = error else {
            print("Characteristic \(characteristic.uuid.uuidString) reports that its value was accepted by the Peripheral.")
            if let questionString = _interimQuestion {
                _interimQuestion = nil
                question = questionString
            } else {
                owner?._sendErrorMessageToAllObservers(error: .sendFailed(ITCB_RejectionReason.peripheralError(nil)))
            }
            
            return
        }
        
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
