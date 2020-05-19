        if centralManager.state == .poweredOn {  
            print("Scanning for Peripherals")  
            centralManager.scanForPeripherals(withServices: [_static_ITCB_SDK_8BallServiceUUID], options: nil)  
        }
