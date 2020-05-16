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
import ITCB_SDK_Watch

/* ###################################################################################################################################### */
// MARK: The WatchKit Extension Main Delegate
/* ###################################################################################################################################### */
class ITCB_ExtensionDelegate: NSObject, WKExtensionDelegate {
    /* ################################################################## */
    /**
     This is a shortcut to get the extension delegate instance as an instance of this class.
     */
    class var extensionDelegate: Self! {
        return WKExtension.shared().delegate as? Self
    }
    
    /* ################################################################## */
    /**
     This will hold our loaded SDK.
     We have a didSet observer, so we will assign a name upon it being set.
     */
    var deviceSDKInstance: ITCB_SDK_Protocol! {
        didSet {
            if  nil != deviceSDKInstance {
                self.deviceSDKInstance.localName = WKInterfaceDevice.current().name
            }
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
     The dispatcher for the various app extension states.
     
     - parameter inBackgroundTasks: The extension's current background tasks. We iterate this.
     */
    func handle(_ inBackgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in inBackgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

}
