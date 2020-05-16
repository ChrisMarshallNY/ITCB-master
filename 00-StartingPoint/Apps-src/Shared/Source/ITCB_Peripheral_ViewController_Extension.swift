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

/// This file contains an extension that can be shared between the Mac and iOS (not Watch or TV, though -remember that Peripheral Mode is only supported for Mac and iOS).

import Foundation

// We need to include the appropriate module for our platform.
#if os(OSX)
    import ITCB_SDK_Mac
#else
    #if os(iOS)
        import ITCB_SDK_IOS
    #endif
#endif

/* ################################################################################################################################## */
// MARK: - Observer protocol Methods -
/* ################################################################################################################################## */
extension ITCB_Peripheral_ViewController: ITCB_Observer_Peripheral_Protocol {
    /* ################################################################## */
    /**
     This is called when a Central asks a Peripheral a question.
     
     This may not be called in the main thread.

     - parameter inDevice: The Central device that provided the question.
     - parameter question: The question that was asked by the Central.
     */
    public func questionAskedByDevice(_ inDevice: ITCB_Device_Central_Protocol, question inQuestion: String) {
        if  !workingWithQuestion {
            workingWithQuestion = true
            DispatchQueue.main.async {
                self.displayQuestion(inQuestion)
            }
        } else if workingWithQuestion { // If we are busy with a previous question, we reject the connection.
            inDevice.rejectConnectionBecause(.deviceBusy)
        }
    }
    
    /* ################################################################## */
    /**
     This is called when a Peripheral successfully answers a Central's question.
     
     This may not be called in the main thread.
     
     - parameter inDevice: The Central device that provided the question.
     - parameter answer: The answer that was sent to the Central.
     - parameter toQuestion: The question that was asked by the Central.
     */
    public func answerSentToDevice(_ inDevice: ITCB_Device_Central_Protocol, answer inAnswer: String, toQuestion inToQuestion: String) {
        workingWithQuestion = false
        displayAlert(header: inToQuestion.localizedVariant, message: inAnswer.localizedVariant)
    }

    /* ################################################################## */
    /**
     Called when an error condition is encountered by the SDK.
     
     - parameter inError: The error code that occurred.
     - parameter sdk: The SDK instance that experienced the error.
     */
    public func errorOccurred(_ inError: ITCB_Errors, sdk inSDKInstance: ITCB_SDK_Protocol) {
        workingWithQuestion = false
        displayAlert(header: "SLUG-ERROR".localizedVariant, message: (ITCB_AppDelegate.unwindErrorReport(inError) ?? inError.localizedDescription).localizedVariant)
    }
}
