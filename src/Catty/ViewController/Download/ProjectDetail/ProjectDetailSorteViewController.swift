/**
 *  Copyright (C) 2010-2019 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

import UIKit
import WebKit

class ProjectDetailStoreViewController: UIViewController, WKNavigationDelegate {
  
    // MARK: - Definitions for the connection
    let messageKey: String = "catty"

    // MARK: - Properties
    var webView: WKWebView!
    var project: StoreProject?
    var loadingView: LoadingView?

    // MARK: - Initializers
    func setupWebView() {
        guard let projectId = project?.projectId else { return }
        guard let url = URL(string: kDetailUrl + String(projectId)) else { return }
        let request = URLRequest(url: url)

        webView = WKWebView(frame: self.view.frame)
        webView.navigationDelegate = self
        webView.load(request)
        self.view.addSubview(webView)
        self.view.sendSubviewToBack(webView)
        
    }

    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        self.showLoadingView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = kLocalizedDetails
        setupWebView()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.hideLoadingView()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.hideLoadingView()
    }
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            //compute url
            if url.absoluteString == "http://someaction/" {
                //fetch data and download program
                print("Action trigure")
            } else {
                print("No action trigure")
            }
        }
        decisionHandler(.allow)
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let projectName = project?.projectName else { return }
        guard let projectId = project?.projectId else { return }
        print("\(message.body): \(projectName) - \(projectId)")
    }

    // MARK: - Loading View
    func showLoadingView() {
        if loadingView == nil {
            loadingView = LoadingView()
            view.addSubview(loadingView!)
        }
        loadingView!.show()
        Util.setNetworkActivityIndicator(true)
    }

    func hideLoadingView() {
        loadingView!.hide()
        Util.setNetworkActivityIndicator(false)
    }
}
