/*
© Copyright 2020, Little Green Viper Software Development LLC

LICENSE:

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Little Green Viper Software Development LLC: https://littlegreenviper.com
*/

import WatchKit
import Foundation
import ITCB_SDK_Watch

/* ###################################################################################################################################### */
// MARK: - The Controller For A Single Device Row
/* ###################################################################################################################################### */
/**
 This describes one row of the table that displays devices.
 */
class ITCB_Main_Central_InterfaceController_TableRowController: NSObject {
    /* ################################################################## */
    /**
     The only item is a device name label.
     */
    @IBOutlet weak var displayLabel: WKInterfaceLabel!
}

/* ###################################################################################################################################### */
// MARK: - The main Central controller -
/* ###################################################################################################################################### */
/**
 This handles the Central screen, where the user can select from a list of devices.
 */
class ITCB_Main_Central_InterfaceController: ITCB_Watch_Base_InterfaceController {
    /* ################################################################## */
    /**
     The string used to instantiate our table rows.
     */
    let rowIDString = "ITCB_Main_Central_InterfaceController_TableRowController"
    
    /* ################################################################## */
    /**
     This is here to satisfy the SDK Central Observer requirement.
     */
    var uuid: UUID = UUID()

    /* ################################################################## */
    /**
     The main label, at the top.
     */
    @IBOutlet weak var mainLabel: WKInterfaceLabel!
    
    /* ################################################################## */
    /**
     The table that displays the list of discovered devices.
     */
    @IBOutlet weak var deviceDisplayTable: WKInterfaceTable!
    
    /* ################################################################## */
    /**
     Clean up before we go away.
     We remove ourselves from the observer pool.
     */
    deinit {
        deviceSDKInstance?.removeObserver(self)
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Overrides -
/* ###################################################################################################################################### */
extension ITCB_Main_Central_InterfaceController {
    /* ################################################################## */
    /**
     Called when the screen has loaded, and will start running.
     
     - parameter withContext: The extension context arguments.
     */
    override func awake(withContext inContext: Any?) {
        super.awake(withContext: inContext)
        setUpUI()
    }
    
    /* ################################################################## */
    /**
     Called just before we are displayed.
     
     We use this to update the UI, and reset things, if we need to do so (after settings).
     If the device has not been created yet, we do so.
     */
    override func willActivate() {
        super.willActivate()
        
        if  nil == deviceSDKInstance {
            deviceSDKInstance = ITCB_SDK.createInstance(isCentral: true)
            uuid = deviceSDKInstance.addObserver(self)
        }

        setUpUI()
    }
    
    /* ################################################################## */
    /**
     Table touch handler.
     
     - parameters:
        - withIdentifier: The segue ID for this (we ignore)
        - in: The table instance
        - rowIndex: The vertical position (0-based) of the row that was touched.
     
        - returns: The context, which is the device associated with the table row. Can be nil.
     */
    override func contextForSegue(withIdentifier inSegueIdentifier: String, in inTable: WKInterfaceTable, rowIndex inRowIndex: Int) -> Any? {
        if  let sdk = deviceSDKInstance as? ITCB_SDK_Central,
            (0..<sdk.devices.count).contains(inRowIndex) {
            return sdk.devices[inRowIndex]
        }
        
        return nil
    }
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension ITCB_Main_Central_InterfaceController {
    /* ################################################################## */
    /**
     Set Up any UI elements as necessary.
     */
    func setUpUI() {
        DispatchQueue.main.async {
            self.mainLabel.setText("SLUG-CENTRAL".localizedVariant)
            self.populateTable()
        }
    }

    /* ################################################################## */
    /**
     This adds devices to the table for display.
     */
    func populateTable() {
        if  let deviceSDKInstance = deviceSDKInstance as? ITCB_SDK_Central,
            0 < deviceSDKInstance.devices.count {
            let numberOfDevices = deviceSDKInstance.devices.count
            
            deviceDisplayTable.setNumberOfRows(numberOfDevices, withRowType: rowIDString)
            
            let rowControllerKludgeArray = [String](repeatElement("ITCB_Main_Central_InterfaceController_TableRowController", count: numberOfDevices))
            
            deviceDisplayTable.setRowTypes(rowControllerKludgeArray)
            
            for index in 0..<numberOfDevices {
                if  let deviceRowRaw = deviceDisplayTable.rowController(at: index),
                    let deviceRow = deviceRowRaw as? ITCB_Main_Central_InterfaceController_TableRowController {
                    let driverInst = deviceSDKInstance.devices[index]
                    deviceRow.displayLabel.setText(driverInst.name)
                }
            }
        } else {
            deviceDisplayTable.setNumberOfRows(0, withRowType: "")
        }
    }
}

/* ################################################################################################################################## */
// MARK: - Observer protocol Methods
/* ################################################################################################################################## */
extension ITCB_Main_Central_InterfaceController: ITCB_Observer_Central_Protocol {
    /* ################################################################## */
    /**
     This is called when a Peripheral returns an answer to the Central.
     
     This may not be called in the main thread.

     - parameter inDevice: The Peripheral device that provided the answer (this will have both the question and answer in its properties).
     */
    func questionAnsweredByDevice(_ inDevice: ITCB_Device_Peripheral_Protocol) {
    }
    
    /* ################################################################## */
    /**
     This is called when a Central successfully asks a question of a peripheral.
     
     This may not be called in the main thread.

     - parameter inDevice: The Peripheral device that was asked the question (The question will be in the device properties).
     */
    func questionAskedOfDevice(_ inDevice: ITCB_Device_Peripheral_Protocol) {
    }

    /* ################################################################## */
    /**
     Called when an error condition is encountered by the SDK.
     
     - parameter inError: The error code that occurred.
     - parameter sdk: The SDK instance that experienced the error.
     */
    func errorOccurred(_ inError: ITCB_Errors, sdk inSDKInstance: ITCB_SDK_Protocol) {
        displayAlert(header: "SLUG-ERROR", message: ITCB_ExtensionDelegate.unwindErrorReport(inError) ?? "")
    }
    
    /* ################################################################## */
    /**
     This is called when a Central discovers and registers a peripheral.
     
     This may not be called in the main thread.

     - parameter inDevice: The Peripheral device that was discovered.
     */
    func deviceDiscovered(_ inDevice: ITCB_Device_Peripheral_Protocol) {
        DispatchQueue.main.async {
            self.populateTable()
        }
    }
}
