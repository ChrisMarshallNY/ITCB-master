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

import UIKit
import ITCB_SDK_TVOS

/* ###################################################################################################################################### */
// MARK: - The Initial Central Mode View Controller -
/* ###################################################################################################################################### */
/**
 This view will display the question and answer screen for a single peripheral device.
 */
class ITCB_TVOS_Central_Device_ViewController: ITCB_Base_ViewController {
    /* ################################################################## */
    /**
     This is here to satisfy the SDK Central Observer requirement.
     */
    var uuid: UUID = UUID()
    
    /* ################################################################## */
    /**
     This is the Peripheral device associated with this screen.
     */
    var device: ITCB_Device_Peripheral_Protocol!

    /* ################################################################## */
    /**
     The navigation bar item. We have our own navbar, and use this to set the title.
     */
    @IBOutlet weak var mainLabel: UILabel!

    /* ################################################################## */
    /**
     This is the editable text field, where the user can ask a question.
     */
    @IBOutlet weak var askQuestionTextField: UITextField!
    
    /* ################################################################## */
    /**
     The button that the user touches to send the question.
     */
    @IBOutlet weak var sendQuestionButton: UIButton!
    
    /* ################################################################## */
    /**
     This is the text view that displays the interactions..
     */
    @IBOutlet weak var resultsTextView: UITextView!

    /* ################################################################## */
    /**
     This makes sure that we don't leave a dead link in the SDK observer pool.
     */
    deinit {
        deviceSDKInstance?.removeObserver(self)
    }
}

/* ###################################################################################################################################### */
// MARK: - IBAction Methods -
/* ###################################################################################################################################### */
extension ITCB_TVOS_Central_Device_ViewController {    
    /* ################################################################## */
    /**
     Called when the "SEND QUESTION TO 8-BALL" button is hit.
     
     - parameter: ignored. Can be omitted.
     */
    @IBAction func sendQuestion(_ : Any! = nil) {
        sendQuestionButton.isEnabled = false
        if  let text = askQuestionTextField?.text,
            !text.isEmpty {
            sendQuestionButton?.isEnabled = false
            device.sendQuestion(text)
            view?.layoutIfNeeded()
        }
    }
    
    /* ################################################################## */
    /**
     Called when text in the text box changes. We use this to enable/disable the send button.
     
     - parameter: ignored. Can be omitted.
     */
    @IBAction func questionTextChanged(_ : Any! = nil) {
        sendQuestionButton.isEnabled = !(askQuestionTextField?.text?.isEmpty ?? false)
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Override Methods -
/* ###################################################################################################################################### */
extension ITCB_TVOS_Central_Device_ViewController {
    /* ################################################################## */
    /**
     Called after the view has loaded. We use this to set the title and localized strings.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        mainLabel?.text = device.name
        askQuestionTextField?.placeholder = askQuestionTextField?.placeholder?.localizedVariant
        sendQuestionButton?.setTitle(sendQuestionButton?.title(for: .normal)?.localizedVariant, for: .normal)
        uuid = deviceSDKInstance.addObserver(self)
    }
}

/* ################################################################################################################################## */
// MARK: - Observer protocol Methods
/* ################################################################################################################################## */
extension ITCB_TVOS_Central_Device_ViewController: ITCB_Observer_Central_Protocol {
    /* ################################################################## */
    /**
     This is called when a Peripheral returns an answer to the Central.
     
     This may not be called in the main thread.

     - parameter inDevice: The Peripheral device that provided the answer (this will have both the question and answer in its properties).
     */
    func questionAnsweredByDevice(_ inDevice: ITCB_Device_Peripheral_Protocol) {
        let answer = (inDevice.answer ?? "").localizedVariant
        // Remember that the answer may come in on a non-main thread, so we need to make sure that all UI-touched code is accessed via the Main Thread.
        DispatchQueue.main.async {
            self.resultsTextView.text += "\n•\n\(answer)"
            self.questionTextChanged()  // Possibly re-enables the send button.
        }
    }
    
    /* ################################################################## */
    /**
     This is called when a Central successfully asks a question of a peripheral.
     
     This may not be called in the main thread.

     - parameter inDevice: The Peripheral device that was asked the question (The question will be in the device properties).
     */
    func questionAskedOfDevice(_ inDevice: ITCB_Device_Peripheral_Protocol) {
        let question = (inDevice.question ?? "").localizedVariant
        // Remember that the answer may come in on a non-main thread, so we need to make sure that all UI-touched code is accessed via the Main Thread.
        DispatchQueue.main.async {
            // We nuke the question from the edit box, and place it in the interaction space below the send button.
            self.resultsTextView.text = question
        }
    }

    /* ################################################################## */
    /**
     Called when an error condition is encountered by the SDK.
     
     - parameter inError: The error code that occurred.
     - parameter sdk: The SDK instance that experienced the error.
     */
    func errorOccurred(_ inError: ITCB_Errors, sdk inSDKInstance: ITCB_SDK_Protocol) {
        displayAlert(header: "SLUG-ERROR".localizedVariant, message: (ITCB_AppDelegate.unwindErrorReport(inError) ?? inError.localizedDescription).localizedVariant)
        DispatchQueue.main.async {
            self.resultsTextView.text += "\n•\n\("SLUG-ERROR".localizedVariant)"
            self.questionTextChanged()  // Possibly re-enables the send button.
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
