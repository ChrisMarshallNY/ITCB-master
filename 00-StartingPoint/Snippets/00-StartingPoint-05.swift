    public func centralManager(_ centralManager: CBCentralManager, didConnect peripheral: CBPeripheral) {  
        print("Successfully Connected to \(peripheral.name ?? "ERROR").")  
        print("Discovering Services for \(peripheral.name ?? "ERROR").")  
        peripheral.discoverServices([_static_ITCB_SDK_8BallServiceUUID])  
    }
