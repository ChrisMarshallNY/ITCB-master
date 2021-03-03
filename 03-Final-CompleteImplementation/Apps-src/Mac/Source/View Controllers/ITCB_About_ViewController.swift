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
// MARK: - The About View Controller -
/* ###################################################################################################################################### */
/**
 */
class ITCB_About_ViewController: ITCB_Base_ViewController {
    /* ################################################################## */
    /**
     This is the main app name/version label, at the top.
     */
    @IBOutlet weak var mainLabel: NSTextField!

    /* ################################################################## */
    /**
     This contains the about text.
     */
    @IBOutlet var mainDisplayTextView: NSTextView!
    
    /* ################################################################## */
    /**
     This button allows the user to go to the try! Swift site in their browser.
     */
    @IBOutlet weak var trySwiftLogoButton: NSButton!

    /* ################################################################## */
    /**
     This button allows the user to go to the try! Swift site in their browser.
     */
    @IBOutlet weak var seriesURIButton: NSButton!
    
    /* ################################################################## */
    /**
     This button allows the user to go to the GitHub repo in their browser.
     */
    @IBOutlet weak var githubURIButton: NSButton!

    /* ################################################################## */
    /**
     This is called when a URI button is hit. It parses the URI from the button name, and goes there.
     */
    @IBAction func uriButtonHit(_ inButton: NSButton) {
        if let url = URL(string: inButton.alternateTitle.localizedVariant) {
            NSWorkspace.shared.open(url)
        }
    }
    
    /* ################################################################## */
    /**
     Called when the view has completed loading.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        mainLabel?.stringValue = "\(Bundle.main.appDisplayName), Version \(Bundle.main.appVersionString).\(Bundle.main.appVersionBuildString)"
        mainDisplayTextView?.string = mainDisplayTextView?.string.localizedVariant ?? "ERROR"
        seriesURIButton?.title = seriesURIButton?.title.localizedVariant ?? "ERROR"
        githubURIButton?.title = githubURIButton?.title.localizedVariant ?? "ERROR"
        trySwiftLogoButton?.setAccessibilityLabel("SLUG-SERIES-URI-TEXT".localizedVariant)
        trySwiftLogoButton?.toolTip = "SLUG-SERIES-URI-TEXT".localizedVariant
    }
}
