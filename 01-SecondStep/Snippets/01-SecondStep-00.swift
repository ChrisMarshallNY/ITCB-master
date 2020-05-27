extension ITCB_SDK_Device_Peripheral: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Encountered an error \(error) for the Peripheral \(peripheral.name ?? "ERROR")")
            owner?._sendErrorMessageToAllObservers(error: ITCB_Errors.coreBluetooth(error))
            return
        }
        print("Successfully Discovered \(peripheral.services?.count ?? 0) Services for \(peripheral.name ?? "ERROR").")
        peripheral.services?.forEach {
            peripheral.discoverCharacteristics([_static_ITCB_SDK_8BallService_Question_UUID,
                                                _static_ITCB_SDK_8BallService_Answer_UUID], for: $0)
        }
    }
}
