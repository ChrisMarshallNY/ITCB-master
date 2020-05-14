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

import UIKit

/* ###################################################################################################################################### */
// MARK: - About This App View Controller -
/* ###################################################################################################################################### */
/**
 */
class ITCB_iOS_About_ViewController: UIViewController {
    /* ################################################################## */
    /**
     The main label at the top, displaying the app info.
     */
    @IBOutlet weak var mainLabel: UILabel!
    
    /* ################################################################## */
    /**
     The about info, in a text view.
     */
    @IBOutlet weak var aboutTextView: UITextView!

    /* ################################################################## */
    /**
     The button near the bottom, that leads to the series page.
     */
    @IBOutlet weak var seriesPageURIButton: UIButton!
    
    /* ################################################################## */
    /**
     The button near the bottom, that leads to the GitHub repo.
     */
    @IBOutlet weak var gitHubURIButton: UIButton!
    
    /* ################################################################## */
    /**
     */
    @IBAction func uriButtonHit(_ inButton: UIButton) {
        var uri: URL!
        
        if gitHubURIButton == inButton {
            uri = URL(string: "SLUG-GITHUB-URI".localizedVariant)
        } else {
            uri = URL(string: "SLUG-SERIES-URI".localizedVariant)
        }
        
        if let uri = uri {
            UIApplication.shared.open(uri, options: [:], completionHandler: nil)
        }
    }
    
    /* ################################################################## */
    /**
     Called after the view has loaded. We use this to set the title and localized strings.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        let dictionary = Bundle.main.infoDictionary!
        if let version = dictionary["CFBundleShortVersionString"] as? String,
            let build = dictionary["CFBundleVersion"] as? String,
            let name = dictionary["CFBundleName"] as? String {
            let displayName = dictionary["CFBundleDisplayName"] as? String
            let vName = ((displayName ?? "").isEmpty) ? name : displayName!
            
            mainLabel?.text = "\(vName), Version \(version).\(build)"
        }
        
        aboutTextView?.text = aboutTextView?.text.localizedVariant
        gitHubURIButton?.setTitle(gitHubURIButton?.title(for: .normal)?.localizedVariant, for: .normal)
        seriesPageURIButton?.setTitle(seriesPageURIButton?.title(for: .normal)?.localizedVariant, for: .normal)
    }
}
