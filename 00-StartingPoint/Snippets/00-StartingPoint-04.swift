
    public func centralManager(_ centralManager: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi: NSNumber) {  
        if  !devices.contains(where: { $0.uuid == peripheral.identifier.uuidString }),  
            let peripheralName = peripheral.name,  
            !peripheralName.isEmpty,  
            (_static_ITCB_SDK_RSSI_Min..._static_ITCB_SDK_RSSI_Max).contains(rssi.intValue) {  
            print("Peripheral Discovered: \(peripheralName), RSSI: \(rssi)")  
            devices.append(ITCB_SDK_Device_Peripheral(peripheral, owner: self))  
            print("Connecting to \(peripheralName).")  
            centralManager.connect(peripheral, options: nil)  
        }
    }
