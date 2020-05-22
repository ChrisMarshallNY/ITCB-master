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
// MARK: - Bundle Extension -
/* ###################################################################################################################################### */
/**
 This extension adds a few simple accessors for some of the more common bundle items.
 */
extension Bundle {
    // MARK: General Stuff for common Apple-Supplied Items
    
    /* ################################################################## */
    /**
     The app name, as a string. It is required, and "ERROR" is returned if it is not present.
     */
    var appDisplayName: String { (object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? object(forInfoDictionaryKey: "CFBundleName") as? String) ?? "ERROR" }

    /* ################################################################## */
    /**
     The app version, as a string. It is required, and "ERROR" is returned if it is not present.
     */
    var appVersionString: String { object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "ERROR" }
    
    /* ################################################################## */
    /**
     The build version, as a string. It is required, and "ERROR" is returned if it is not present.
     */
    var appVersionBuildString: String { object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "ERROR" }
    
    /* ################################################################## */
    /**
     If there is a copyright string, it is returned here. It may be nil.
     */
    var copyrightString: String? { object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String }
}

/* ###################################################################################################################################### */
// MARK: 
/* ###################################################################################################################################### */
/**
 */
@NSApplicationMain
class ITCB_AppDelegate: NSObject, NSApplicationDelegate {
    /* ################################################################## */
    /**
     The About Menu Item. We access it, so we can change the name.
     */
    @IBOutlet weak var aboutMenuItem: NSMenuItem!
    
    /* ################################################################## */
    /**
     The Quit Menu Item. We access it, so we can change the name.
     */
    @IBOutlet weak var quitMenuItem: NSMenuItem!
    
    /* ################################################################## */
    /**
     This is a shortcut to get the app delegate instance as an instance of this class.
     */
    class var appDelegate: Self! {
        return NSApplication.shared.delegate as? Self
    }
    
    /* ################################################################## */
    /**
     This displays a simple alert, with an OK button.
     
     - parameter header: The header to display at the top.
     - parameter message: A String, containing whatever messge is to be displayed below the header.
     */
    class func displayAlert(header inHeader: String, message inMessage: String = "") {
        // This ensures that we are on the main thread.
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = inHeader.localizedVariant
            alert.informativeText = inMessage.localizedVariant
            alert.addButton(withTitle: "SLUG-OK-BUTTON-TEXT".localizedVariant)
            alert.runModal()
        }
    }
    
    /* ################################################################## */
    /**
     This unwinds our error report by parsing it for associated values.
     */
    class func unwindErrorReport(_ inError: Error) -> String? {
        var errorDesc: String?

        if let error = inError as? ITCB_Errors {
            switch error {
            case .sendFailed(let errorReport):
                if let errReport = errorReport {
                    errorDesc = unwindErrorReport(errReport)
                }
            case .coreBluetooth(let errorReport):
                if let errReport = errorReport {
                    errorDesc = unwindErrorReport(errReport)
                }
            default:
                errorDesc = error.localizedDescription
            }
        } else if let error = inError as? ITCB_RejectionReason {
            errorDesc = error.localizedDescription
        } else {
            errorDesc = inError.localizedDescription
        }
        
        return errorDesc
    }

    /* ################################################################## */
    /**
     This will hold our loaded SDK.
     We have a didSet observer, so we will assign a name upon it being set.
     */
    var deviceSDKInstance: ITCB_SDK_Protocol! {
        didSet {
            if  nil != deviceSDKInstance,
                let deviceName = Host.current().localizedName {
                self.deviceSDKInstance.localName = deviceName
            }
        }
    }
    
    /* ################################################################## */
    /**
     Called when the app has finished its launch setup.
     
     We use this to set our "About This App" menu item.
     
     - parameter: ignored
     */
    func applicationDidFinishLaunching(_: Notification) {
        aboutMenuItem?.title = String(format: aboutMenuItem.title.localizedVariant, Bundle.main.appDisplayName)
        quitMenuItem?.title = String(format: quitMenuItem.title.localizedVariant, Bundle.main.appDisplayName)
    }
}
