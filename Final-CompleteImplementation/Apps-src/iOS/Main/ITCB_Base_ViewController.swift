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

import UIKit
import ITCB_SDK_IOS

/* ###################################################################################################################################### */
// MARK: - Base View Controller Class -
/* ###################################################################################################################################### */
/**
 This is a base class for all displayed View Controllers.
 */
class ITCB_Base_ViewController: UIViewController {
    /* ################################################################## */
    /**
     This is a shortcut to get the app delegate instance.
     */
    var appDelegate: ITCB_AppDelegate! {
        return ITCB_AppDelegate.appDelegate
    }
    
    /* ################################################################## */
    /**
     This will allow access to the singleton SDK instance as a generic SDK. This can return nil, if the SDK is not loaded.
     
     This can be used to set the SDK instance.
     */
    var deviceSDKInstance: ITCB_SDK_Protocol! {
        get {
            return appDelegate?.deviceSDKInstance
        }
        
        set {
            appDelegate?.deviceSDKInstance = newValue
        }
    }
    
    /* ################################################################## */
    /**
     This will allow access to the singleton SDK instance as a Central SDK. This will return nil, if the SDK is not a Central.
     
     This is read-only.
     */
    var getDeviceSDKInstanceAsCentral: ITCB_SDK_Central! {
        return deviceSDKInstance as? ITCB_SDK_Central
    }
    
    /* ################################################################## */
    /**
     This will allow access to the singleton SDK instance as a Peripheral SDK. This will return nil, if the SDK is not a Peripheral.
     
     This is read-only.
     */
    var getDeviceSDKInstanceAsPeripheral: ITCB_SDK_Peripheral! {
        return deviceSDKInstance as? ITCB_SDK_Peripheral
    }
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension ITCB_Base_ViewController {
    /* ################################################################## */
    /**
     This displays a simple alert, with an OK button.
     
     - parameter header: The header to display at the top.
     - parameter message: A String, containing whatever messge is to be displayed below the header.
     */
    func displayAlert(header inHeader: String, message inMessage: String = "") {
        ITCB_AppDelegate.displayAlert(header: inHeader, message: inMessage, presentedBy: self)
    }
}
