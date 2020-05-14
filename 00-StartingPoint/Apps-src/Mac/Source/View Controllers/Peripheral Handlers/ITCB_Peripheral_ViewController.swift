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
// MARK: - The View Controller for a Peripheral Mode app -
/* ###################################################################################################################################### */
/**
 This view controller is loaded over the mode selection, as we have decided to be a Peripheral.
 */
class ITCB_Peripheral_ViewController: ITCB_Base_ViewController {
    /// The stroryboard ID, for instantiating the class.
    static let storyboardID = "peripheral-initial-view-controller"
    
    /* ################################################################## */
    /**
     This is here to satisfy the SDK Peripheral Observer requirement.
     */
    var uuid: UUID = UUID()

    /* ################################################################## */
    /**
     This is a semaphore that prevents questions from "piling up." If a question has not yet been answered, this is true.
     */
    var workingWithQuestion: Bool = false
    
    /* ################################################################## */
    /**
     This displays the question from the Central.
     */
    @IBOutlet weak var questionAskedLabel: NSTextField!
    
    /* ################################################################## */
    /**
     If the user hits this button, a random answer will be selected and sent.
     */
    @IBOutlet weak var sendRandomButton: NSButton!
    
    /* ################################################################## */
    /**
     This is the container scroll view for the table.
     */
    @IBOutlet weak var containerScrollView: NSScrollView!

    /* ################################################################## */
    /**
     The question picker table view.
     */
    @IBOutlet var tableView: NSTableView!
    
    /* ################################################################## */
    /**
     This displays a "waiting for question" screen.
     */
    @IBOutlet weak var busyView: NSView!
    
    /* ################################################################## */
    /**
     This is the "waiting" label.
     */
    @IBOutlet weak var waitingLabel: NSTextField!
    
    /* ################################################################## */
    /**
     This is an activity spinner.
     */
    @IBOutlet weak var waitingActivityIndicator: NSProgressIndicator!
}

/* ###################################################################################################################################### */
// MARK: - IBAction Methods -
/* ###################################################################################################################################### */
extension ITCB_Peripheral_ViewController {
    /* ################################################################## */
    /**
     Called when the user clicks the "Send Random" button.
     
     - parameter inButton: The button instance.
     */
    @IBAction func sendRandomButtonHit(_ inButton: NSButton) {
        let answer = String(format: "SLUG-ANSWER-%02d", Int.random(in: 0..<20)).localizedVariant
        getDeviceSDKInstanceAsPeripheral?.central.sendAnswer(answer, toQuestion: questionAskedLabel?.stringValue ?? "ERROR")
        setUI(showItems: false)
    }
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension ITCB_Peripheral_ViewController {
    /* ################################################################## */
    /**
     Called to display the question.
     
     - parameter inQuestionString: The question.
     */
    func displayQuestion(_ inQuestion: String) {
        self.questionAskedLabel?.stringValue = inQuestion.localizedVariant
        setUI(showItems: true)
    }
    
    /* ################################################################## */
    /**
     This either shows or hides the "waiting" screen, or the answer handlers.
     
     - parameter inShowItems: True, if we want to show the items. False, if we want to show the "waiting" screen.
     */
    func setUI(showItems inShowItems: Bool) {
        busyView?.isHidden = inShowItems
        questionAskedLabel?.isHidden = !inShowItems
        sendRandomButton?.isHidden = !inShowItems
        containerScrollView?.isHidden = !inShowItems
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Override Methods -
/* ###################################################################################################################################### */
extension ITCB_Peripheral_ViewController {
    /* ################################################################## */
    /**
     Called when the view has completed loading.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceSDKInstance = ITCB_SDK.createInstance(isCentral: false)
        sendRandomButton?.title = sendRandomButton?.title.localizedVariant ?? "ERROR"
        waitingLabel?.stringValue = waitingLabel.stringValue.localizedVariant
        waitingActivityIndicator?.startAnimation(nil)
        setUI(showItems: false)
    }
    
    /* ################################################################## */
    /**
     Called just before the view appears. We use this to register as an observer.
     */
    override func viewWillAppear() {
        super.viewWillAppear()
        getDeviceSDKInstanceAsPeripheral?.addObserver(self)
    }

    /* ################################################################## */
    /**
     Called just before the view disappears. We use this to un-register as an observer.
     */
    override func viewWillDisappear() {
        super.viewWillDisappear()
        getDeviceSDKInstanceAsPeripheral?.removeObserver(self)
    }
}

/* ################################################################################################################################## */
// MARK: - NSTableViewDelegate/DataSource Methods
/* ################################################################################################################################## */
extension ITCB_Peripheral_ViewController: NSTableViewDelegate, NSTableViewDataSource {
    /* ################################################################## */
    /**
     Called to supply the number of rows in the table.
     
     - parameters:
        - inTableView: The table instance.
     
     - returns: A 1-based Int, with 0 being no rows.
     */
    func numberOfRows(in inTableView: NSTableView) -> Int {
        return Int("SLUG-NUMBER-MAX".localizedVariant) ?? 0
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
        return String(format: "SLUG-ANSWER-%02d", inRow).localizedVariant
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
            let answer = String(format: "SLUG-ANSWER-%02d", selectedRow).localizedVariant
            getDeviceSDKInstanceAsPeripheral?.central.sendAnswer(answer, toQuestion: questionAskedLabel?.stringValue ?? "ERROR")
            setUI(showItems: false)
            tableView.deselectRow(selectedRow)  // Make sure that we clean up after ourselves.
        }
    }
}
