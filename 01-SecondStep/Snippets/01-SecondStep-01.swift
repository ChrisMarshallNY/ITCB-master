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
