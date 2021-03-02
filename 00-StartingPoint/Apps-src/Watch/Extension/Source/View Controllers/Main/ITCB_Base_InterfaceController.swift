/*
© Copyright 2021, Little Green Viper Software Development LLC

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
// MARK: - Base Class for the Extension Screens -
/* ###################################################################################################################################### */
/**
 This is a base class for the handler screens.
 */
class ITCB_Watch_Base_InterfaceController: WKInterfaceController {
    /* ################################################################## */
    /**
     This is an instance-based accessor to the extension's SINGLETON of the device SDK.
     
     Each subclass will instantiate the proper type.
     */
    var deviceSDKInstance: ITCB_SDK_Protocol! {
        get {
            return ITCB_ExtensionDelegate.extensionDelegate?.deviceSDKInstance
        }
        
        set {
            ITCB_ExtensionDelegate.extensionDelegate?.deviceSDKInstance = newValue
        }
    }
    
    /* ################################################################## */
    /**
     Displays the given message and title in an alert with an "OK" button.
     
     - parameter inTitle: a string to be displayed as the title of the alert. It is localized by this method.
     - parameter message: a string to be displayed as the message of the alert. It is localized by this method.
     */
    func displayAlert(header inTitle: String, message inMessage: String) {
        DispatchQueue.main.async {  // In case we're called off-thread...
            let okAction = WKAlertAction(title: "SLUG-OK-BUTTON-TEXT".localizedVariant, style: WKAlertActionStyle.default) { }
            self.presentAlert(withTitle: inTitle.localizedVariant, message: inMessage.localizedVariant, preferredStyle: WKAlertControllerStyle.alert, actions: [okAction])
        }
    }
}
