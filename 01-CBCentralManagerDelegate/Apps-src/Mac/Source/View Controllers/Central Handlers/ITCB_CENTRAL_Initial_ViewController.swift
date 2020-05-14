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

import Cocoa
import ITCB_SDK_Mac

/* ###################################################################################################################################### */
// MARK: - The View Controller for a Central Mode app -
/* ###################################################################################################################################### */
/**
 This view controller is loaded over the mode selection, as we have decided to be a Central.
 */
class ITCB_CENTRAL_Initial_ViewController: ITCB_Base_ViewController {
    /* ################################################################## */
    /**
     The stroryboard ID, for instantiating the class.
     */
    static let storyboardID = "central-initial-view-controller"
    
    /* ################################################################## */
    /**
     The device picker table view.
     */
    @IBOutlet var tableView: NSTableView!
    
    /* ################################################################## */
    /**
     This is here to satisfy the SDK Central Observer requirement.
     */
    var uuid: UUID = UUID()
}

/* ###################################################################################################################################### */
// MARK: - Base Class Override Methods -
/* ###################################################################################################################################### */
extension ITCB_CENTRAL_Initial_ViewController {
    /* ################################################################## */
    /**
     Called when the view has completed loading.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // We create our SDK instance as a Central.
        deviceSDKInstance = ITCB_SDK.createInstance(isCentral: true)
    }
    
    /* ################################################################## */
    /**
     Called just before the view appears. We use this to register as an observer.
     */
    override func viewWillAppear() {
        super.viewWillAppear()
        getDeviceSDKInstanceAsCentral?.addObserver(self)
    }
    
    /* ################################################################## */
    /**
     Called just before the view disappears. We use this to un-register as an observer.
     */
    override func viewWillDisappear() {
        super.viewWillDisappear()
        getDeviceSDKInstanceAsCentral?.removeObserver(self)
    }
}

/* ################################################################################################################################## */
// MARK: - Observer protocol Methods
/* ################################################################################################################################## */
extension ITCB_CENTRAL_Initial_ViewController: ITCB_Observer_Central_Protocol {
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
        displayAlert(header: "SLUG-ERROR", message: ITCB_AppDelegate.unwindErrorReport(inError) ?? "")
    }
    
    /* ################################################################## */
    /**
     This is called when a Central discovers and registers a peripheral.
     
     This may not be called in the main thread.

     - parameter inDevice: The Peripheral device that was discovered.
     */
    func deviceDiscovered(_ inDevice: ITCB_Device_Peripheral_Protocol) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

/* ################################################################################################################################## */
// MARK: - NSTableViewDelegate/DataSource Methods
/* ################################################################################################################################## */
extension ITCB_CENTRAL_Initial_ViewController: NSTableViewDelegate, NSTableViewDataSource {
    /* ################################################################## */
    /**
     Called to supply the number of rows in the table.
     
     - parameters:
        - inTableView: The table instance.
     
     - returns: A 1-based Int, with 0 being no rows.
     */
    func numberOfRows(in inTableView: NSTableView) -> Int {
        return getDeviceSDKInstanceAsCentral?.devices.count ?? 0
    }

    /* ################################################################## */
    /**
     This is called to supply the string display for one row that corresponds to a device.
     
     - parameters:
        - inTableView: The table instance.
        - objectValueFor: Container object for the column that holds the row.
        - row: 0-based Int, with the index of the row, within the column.
     
     - returns: A String, with the device name.
     */
    func tableView(_ inTableView: NSTableView, objectValueFor inTableColumn: NSTableColumn?, row inRow: Int) -> Any? {
        if let devices = getDeviceSDKInstanceAsCentral?.devices {
            return devices[inRow].name
        }
        
        return "NO DEVICE NAME"
    }
    
    /* ################################################################## */
    /**
     Called after a table row was selected by the user.
     
     We open a modal sheet, with the device info.
     
     - parameter: Ignored
     */
    func tableViewSelectionDidChange(_: Notification) {
        // Make sure that we have a selected row, and that the selection is valid.
        if  let selectedRow = tableView?.selectedRow,
            (0..<tableView.numberOfRows).contains(selectedRow) {
            if let newPeripheralDeviceViewController = self.storyboard?.instantiateController(withIdentifier: ITCB_Central_Peripheral_Device_ViewController.storyboardID) as? ITCB_Central_Peripheral_Device_ViewController {
                // Associate the device instance with the sheet.
                newPeripheralDeviceViewController.device = getDeviceSDKInstanceAsCentral.devices[selectedRow]
                presentAsSheet(newPeripheralDeviceViewController)
            }
            tableView.deselectRow(selectedRow)  // Make sure that we clean up after ourselves.
        }
    }
}
