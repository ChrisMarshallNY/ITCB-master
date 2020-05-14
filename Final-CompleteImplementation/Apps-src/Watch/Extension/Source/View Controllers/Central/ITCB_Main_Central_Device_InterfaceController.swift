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
// MARK: - The main Central controller -
/* ###################################################################################################################################### */
/**
 This handles the Central screen, where the user can select from a list of devices.
 */
class ITCB_Main_Central_Device_InterfaceController: ITCB_Watch_Base_InterfaceController {
    /* ################################################################## */
    /**
     This is here to satisfy the SDK Central Observer requirement.
     */
    var uuid: UUID = UUID()

    /* ################################################################## */
    /**
     This is a device name label.
     */
    @IBOutlet weak var mainLabel: WKInterfaceLabel!
    
    /* ################################################################## */
    /**
     This label displays the question, and the response.
     */
    @IBOutlet weak var resultsLabel: WKInterfaceLabel!
    
    /* ################################################################## */
    /**
     This is the device instance that is assigned to this screen.
     */
    var device: ITCB_Device_Peripheral_Protocol! = nil
}

/* ###################################################################################################################################### */
// MARK: - Base Class Overrides -
/* ###################################################################################################################################### */
extension ITCB_Main_Central_Device_InterfaceController {
    /* ################################################################## */
    /**
     Called when the screen has loaded, and will start running.
     
     - parameter withContext: The extension context arguments.
     */
    override func awake(withContext inContext: Any?) {
        super.awake(withContext: inContext)
        if let device = inContext as? ITCB_Device_Peripheral_Protocol {
            self.device = device
        }
    }
    
    /* ################################################################## */
    /**
     Called just before we are displayed.
     
     We use this to update the UI, and reset things, if we need to do so (after settings).
     */
    override func willActivate() {
        super.willActivate()
        self.uuid = deviceSDKInstance.addObserver(self)
        setUpUI()
        // Immediately upon activating, we send a random question to the device.
        device.sendQuestion(String(format: "SLUG-QUESTION-%02d", Int.random(in: 0..<20)).localizedVariant)
    }
    
    /* ################################################################## */
    /**
     We remove ourselves as an observer.
     */
    override func willDisappear() {
        super.willDisappear()
        deviceSDKInstance?.removeObserver(self)
    }
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension ITCB_Main_Central_Device_InterfaceController {
    /* ################################################################## */
    /**
     Set Up any UI elements as necessary.
     */
    func setUpUI() {
        DispatchQueue.main.async {
            self.mainLabel?.setText(self.device?.name ?? "ERROR")
        }
    }
}

/* ################################################################################################################################## */
// MARK: - Observer protocol Methods
/* ################################################################################################################################## */
extension ITCB_Main_Central_Device_InterfaceController: ITCB_Observer_Central_Protocol {
    /* ################################################################## */
    /**
     This is called when a Peripheral returns an answer to the Central.
     
     This may not be called in the main thread.

     - parameter inDevice: The Peripheral device that provided the answer (this will have both the question and answer in its properties).
     */
    func questionAnsweredByDevice(_ inDevice: ITCB_Device_Peripheral_Protocol) {
        // Remember that the answer may come in on a non-main thread, so we need to make sure that all UI-touched code is accessed via the Main Thread.
        DispatchQueue.main.async {
            if self.device.amIThisDevice(inDevice) {
                self.resultsLabel.setText("\(inDevice.question.localizedVariant)\n•\n\(inDevice.answer.localizedVariant)")
            }
        }
    }
    
    /* ################################################################## */
    /**
     This is called when a Central successfully asks a question of a peripheral.
     
     This may not be called in the main thread.

     - parameter inDevice: The Peripheral device that was asked the question (The question will be in the device properties).
     */
    func questionAskedOfDevice(_ inDevice: ITCB_Device_Peripheral_Protocol) {
        // Remember that the answer may come in on a non-main thread, so we need to make sure that all UI-touched code is accessed via the Main Thread.
        DispatchQueue.main.async {
            if self.device.amIThisDevice(inDevice) {
                self.resultsLabel.setText(inDevice.question.localizedVariant)
            }
        }
    }

    /* ################################################################## */
    /**
     Called when an error condition is encountered by the SDK.
     
     - parameter inError: The error code that occurred.
     - parameter sdk: The SDK instance that experienced the error.
     */
    func errorOccurred(_ inError: ITCB_Errors, sdk inSDKInstance: ITCB_SDK_Protocol) {
        displayAlert(header: "SLUG-ERROR", message: inError.localizedDescription)
        DispatchQueue.main.async {
            self.resultsLabel?.setText("ERROR".localizedVariant)
        }
    }
    
    /* ################################################################## */
    /**
     This is called when a Central discovers and registers a peripheral.
     
     This may not be called in the main thread.

     - parameter inDevice: The Peripheral device that was discovered.
     */
    func deviceDiscovered(_ inDevice: ITCB_Device_Peripheral_Protocol) {
    }
}
