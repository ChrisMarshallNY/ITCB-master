//
//  InterfaceController.swift
//  Watch WatchKit Extension
//
//  Created by Chris Marshall on 2/11/20.
//  Copyright © 2020 Little Green Viper Software Development LLC. All rights reserved.
//

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
