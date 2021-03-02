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
// MARK: - Special "Replace" Segue -
/* ###################################################################################################################################### */
/**
 [This little trick came from here](https://stackoverflow.com/a/21942768/879365)
 */
class ITCB_Mode_Selection_ReplaceSegue: UIStoryboardSegue {
    /* ################################################################## */
    /**
     All we do, is completely replace the previous controller with the destination.
     */
    override func perform() {
        source.navigationController?.setViewControllers([destination], animated: true)
    }
}

/* ###################################################################################################################################### */
// MARK: - The Main Mode Selection Screen -
/* ###################################################################################################################################### */
/**
 This is the first screen that is shown upon startup. It allows the user to select an operating mode for the app.
 
 Once the user selects a mode, this screen disappears until the next time the app is started.
 */
class ITCB_Mode_Selection_ViewController: ITCB_Base_ViewController {
    /* ################################################################## */
    /**
     The segue ID for showing the Central operating mode.
     */
    static let centralSegueID = "show-central-mode"
    
    /* ################################################################## */
    /**
     The segue ID for showing the Peripheral operating mode.
     */
    static let peripheralSegueID = "show-peripheral-mode"
    
    /* ################################################################## */
    /**
     The text-based "Central" button.
     */
    @IBOutlet weak var centralTextButton: UIButton!

    /* ################################################################## */
    /**
     The text-based "Peripheral" button.
     */
    @IBOutlet weak var peripheralTextButton: UIButton!
}

/* ###################################################################################################################################### */
// MARK: - IBAction Methods -
/* ###################################################################################################################################### */
extension ITCB_Mode_Selection_ViewController {
    /* ################################################################## */
    /**
     Called when one of the Central buttons has been hit.
     
     - parameter: ignored
     */
    @IBAction func centralButtonHit(_ : Any) {
        performSegue(withIdentifier: Self.centralSegueID, sender: nil)
    }

    /* ################################################################## */
    /**
     Called when one of the Peripheral buttons has been hit.
     
     - parameter: ignored
     */
    @IBAction func peripheralButtonHit(_ : Any) {
        performSegue(withIdentifier: Self.peripheralSegueID, sender: nil)
    }
}

/* ###################################################################################################################################### */
// MARK: - Base Class Override Methods -
/* ###################################################################################################################################### */
extension ITCB_Mode_Selection_ViewController {
    /* ################################################################## */
    /**
     Called after the view has loaded. We use this to set our localized strings and whatnot.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        deviceSDKInstance = nil // Make sure we nuke any old instances
        appDelegate.modeSelectionViewController = self
        appDelegate.mainNavigationController = navigationController
        centralTextButton.setTitle(centralTextButton.title(for: .normal)?.localizedVariant, for: .normal)
        peripheralTextButton.setTitle(peripheralTextButton.title(for: .normal)?.localizedVariant, for: .normal)
    }
}
