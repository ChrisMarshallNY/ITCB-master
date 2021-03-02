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

import Cocoa

/* ###################################################################################################################################### */
// MARK: - The initial "Pick A Mode" View Controller -
/* ###################################################################################################################################### */
/**
 This is the first screen that is shown upon startup. It allows the user to select an operating mode for the app.
 
 Once the user selects a mode, this screen disappears until the next time the app is started.
 */
class ITCB_Mode_Selection_ViewController: ITCB_Base_ViewController {
    /* ################################################################## */
    /**
     The Central Mode selection button.
     */
    @IBOutlet weak var centralButton: NSButton!
    
    /* ################################################################## */
    /**
     The Peripheral Mode selection button.
     */
    @IBOutlet weak var periperalButton: NSButton!
}

/* ###################################################################################################################################### */
// MARK: - Base Class Override Methods -
/* ###################################################################################################################################### */
extension ITCB_Mode_Selection_ViewController {
    /* ################################################################## */
    /**
     Called when the view has completed loading.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        centralButton.title = centralButton.title.localizedVariant
        periperalButton.title = periperalButton.title.localizedVariant
        title = "SLUG-SELECT-MODE"
    }
}

/* ###################################################################################################################################### */
// MARK: - IBAction Methods -
/* ###################################################################################################################################### */
extension ITCB_Mode_Selection_ViewController {
    /* ################################################################## */
    /**
     Called when the user selects the "CENTRAL" button.
     
     This replaces the view controller with the one for Central mode.
     
     - parameter: Ignored
     */
    @IBAction func selectCentralMode(_: Any) {
        if let newCentralViewController = self.storyboard?.instantiateController(withIdentifier: ITCB_CENTRAL_Initial_ViewController.storyboardID) as? ITCB_CENTRAL_Initial_ViewController {
            view.window?.contentViewController = newCentralViewController
            setWindowTitle()
        }
    }
    
    /* ################################################################## */
    /**
     Called when the user selects the "PERIPHERAL" button.
     
     This replaces the view controller with the one for Peripheral mode.

     - parameter: Ignored
     */
    @IBAction func selectPeripheralMode(_: Any) {
        if let newPeripheralViewController = self.storyboard?.instantiateController(withIdentifier: ITCB_Peripheral_ViewController.storyboardID) as? ITCB_Peripheral_ViewController {
            view.window?.contentViewController = newPeripheralViewController
            setWindowTitle()
        }
    }
}
