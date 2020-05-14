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
// MARK: - The View Controller for a Central Mode Device Screen -
/* ###################################################################################################################################### */
/**
 */
class ITCB_Central_Peripheral_Device_ViewController: ITCB_Base_ViewController {
    /* ################################################################## */
    /**
     The stroryboard ID, for instantiating the class.
     */
    static let storyboardID = "central-peripheral-initial-view-controller"
    
    /* ################################################################## */
    /**
     This is here to satisfy the SDK Central Observer requirement.
     */
    var uuid: UUID = UUID()
    
    /* ################################################################## */
    /**
     Reference to the device instance for this controller.
     */
    var device: ITCB_Device_Peripheral_Protocol!
    
    /* ################################################################## */
    /**
     The device title label
     */
    @IBOutlet weak var titleLabel: NSTextField!
    
    /* ################################################################## */
    /**
     The text field, where the user enters the question.
     */
    @IBOutlet weak var enterQuestionText: NSTextField!
    
    /* ################################################################## */
    /**
     The send question to 8-ball button.
     */
    @IBOutlet weak var sendButton: NSButton!
    
    /* ################################################################## */
    /**
     The close the sheet button.
     */
    @IBOutlet weak var closeButton: NSButton!
    
    /* ################################################################## */
    /**
     The label that will display the returned answer.
     */
    @IBOutlet weak var answerLabel: NSTextField!
}

/* ###################################################################################################################################### */
// MARK: - IBAction Methods -
/* ###################################################################################################################################### */
extension ITCB_Central_Peripheral_Device_ViewController {
    /* ################################################################## */
    /**
     Called when the user hits the "SEND QUESTION" button, or ENTER while editing the text.
     
     - parameter: Ignored
     */
    @IBAction func sendQuestion(_: Any) {
        if  let question = enterQuestionText?.stringValue,
            !question.isEmpty {
            sendButton.isEnabled = false  // Disable until we receive an ack.
            device.sendQuestion(question)
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Override Methods -
/* ###################################################################################################################################### */
extension ITCB_Central_Peripheral_Device_ViewController {
    /* ################################################################## */
    /**
     Called when the view has completed loading.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        closeButton?.title = closeButton?.title.localizedVariant ?? "ERROR"
        sendButton?.title = sendButton?.title.localizedVariant ?? "ERROR"
        titleLabel?.stringValue = device?.name ?? "ERROR"
        enterQuestionText?.placeholderString = enterQuestionText?.placeholderString?.localizedVariant ?? "ERROR"
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
// MARK: - Text Field Delegate Methods -
/* ################################################################################################################################## */
extension ITCB_Central_Peripheral_Device_ViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        sendButton.isEnabled = !enterQuestionText.stringValue.isEmpty
    }
}

/* ################################################################################################################################## */
// MARK: - Observer protocol Methods
/* ################################################################################################################################## */
extension ITCB_Central_Peripheral_Device_ViewController: ITCB_Observer_Central_Protocol {
    /* ################################################################## */
    /**
     This is called when a Peripheral returns an answer to the Central.
     
     This may not be called in the main thread.

     - parameter inDevice: The Peripheral device that provided the answer (this will have both the question and answer in its properties).
     */
    func questionAnsweredByDevice(_ inDevice: ITCB_Device_Peripheral_Protocol) {
        let answer = inDevice.answer.localizedVariant
        // Remember that the answer may come in on a non-main thread, so we need to make sure that all UI-touched code is accessed via the Main Thread.
        DispatchQueue.main.async {
            self.answerLabel.stringValue += "\n•\n\(answer)"
        }
    }
    
    /* ################################################################## */
    /**
     This is called when a Central successfully asks a question of a peripheral.
     
     This may not be called in the main thread.

     - parameter inDevice: The Peripheral device that was asked the question (The question will be in the device properties).
     */
    func questionAskedOfDevice(_ inDevice: ITCB_Device_Peripheral_Protocol) {
        let question = inDevice.question.localizedVariant
        // Remember that the answer may come in on a non-main thread, so we need to make sure that all UI-touched code is accessed via the Main Thread.
        DispatchQueue.main.async {
            // We nuke the question from the edit box, and place it in the interaction space below the send button.
            self.enterQuestionText?.stringValue = ""
            self.answerLabel.stringValue = question
        }
    }

    /* ################################################################## */
    /**
     Called when an error condition is encountered by the SDK.
     We do not display an alert (That's handled by the main view).
     
     - parameter inError: The error code that occurred.
     - parameter sdk: The SDK instance that experienced the error.
     */
    func errorOccurred(_ inError: ITCB_Errors, sdk inSDKInstance: ITCB_SDK_Protocol) {
        DispatchQueue.main.async {
            self.answerLabel.stringValue += "\n" + "SLUG-ERROR".localizedVariant
        }
    }
    
    /* ################################################################## */
    /**
     This is called when a Central discovers and registers a peripheral.
     
     This may not be called in the main thread.

     - parameter inDevice: The Peripheral device that was discovered.
     */
    func deviceDiscovered(_ inDevice: ITCB_Device_Peripheral_Protocol) {
        print("A Peripheral Magic 8-Ball, named \"\(String(describing: inDevice.name)) has been discovered and added to the list.")
    }
}
