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
