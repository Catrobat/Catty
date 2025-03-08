/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

import WebKit

class HelpWebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UIScrollViewDelegate {
    private var errorLoadingURL = false
    private var doneLoadingURL = false
    private var controlsHidden = false
    private var refreshButton: UIBarButtonItem?
    private var stopButton: UIBarButtonItem?
    private var topViewController: UIViewController?
    private var url: URL?
    private var touchHelperView: UIView?
    private var loadingView: LoadingView?
    private var webView: WKWebView?

    @IBOutlet private weak var urlTitleLabel: UILabel!
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var viewForWebView: UIView!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true

        let webView = WKWebView(frame: self.viewForWebView.bounds, configuration: webConfiguration)
        self.webView = webView
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false

        viewForWebView.addSubview(webView)

        viewForWebView.addConstraint(NSLayoutConstraint(item: webView, attribute: .leading, relatedBy: .equal, toItem: viewForWebView, attribute: .leading, multiplier: 1.0, constant: 0.0))
        viewForWebView.addConstraint(NSLayoutConstraint(item: webView, attribute: .trailing, relatedBy: .equal, toItem: viewForWebView, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        viewForWebView.addConstraint(NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: viewForWebView, attribute: .top, multiplier: 1.0, constant: 0.0))
        viewForWebView.addConstraint(NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem: viewForWebView, attribute: .bottom, multiplier: 1.0, constant: 0.0))

        title = kLocalizedHelp

        setupToolBar()

        refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh,
                                        target: self,
                                        action: #selector(HelpWebViewController.refresh(_:)))
        stopButton = UIBarButtonItem(barButtonSystemItem: .stop,
                                     target: self,
                                     action: #selector(HelpWebViewController.stop(_:)))

        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self,
                                                           action: #selector(handleSwipe(recognizer:)))
        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self,
                                                            action: #selector(handleSwipe(recognizer:)))
        swipeLeftRecognizer.direction = .left
        swipeRightRecognizer.direction = .right

        webView.addGestureRecognizer(swipeLeftRecognizer)
        webView.addGestureRecognizer(swipeRightRecognizer)

        url = URL(string: NetworkDefines.helpUrl)
        webView.scrollView.delegate = self
        webView.uiDelegate = self
        webView.backgroundColor = UIColor.background
        webView.alpha = 0.0
        initUrlTitleLabel()
        if let url = url {
            webView.load(URLRequest(url: url))
        }

        touchHelperView = UIView(frame: CGRect.zero)
        touchHelperView?.backgroundColor = UIColor.clear
        progressView.tintColor = UIColor.navTint
        webView.scrollView.contentInsetAdjustmentBehavior = .never
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupToolbarItems()
        if let touchHelperView = touchHelperView {
            if let webView = webView {
                view.insertSubview(touchHelperView, aboveSubview: webView)
            }
        }

        if loadingView == nil {
            loadingView = LoadingView()
            if let loadingView = loadingView {
                view.addSubview(loadingView)
            }
            loadingView?.show()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView?.stopLoading()

        topViewController = navigationController?.topViewController
        navigationController?.hidesBarsOnSwipe = false
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        touchHelperView?.frame = CGRect(x: CGFloat(0.0),
                                        y: view.bounds.height - UIDefines.toolbarHeight,
                                        width: view.bounds.width,
                                        height: UIDefines.toolbarHeight)
    }

    // MARK: - WebViewDelegate
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        Util.setNetworkActivityIndicator(false)
        setupToolbarItems()
        errorLoadingURL = true
        doneLoadingURL = false
        setProgress(0.0)
        DispatchQueue.main.async(execute: {
            self.loadingView?.hide()
        })
        if Util.isNetworkError(error) {
            Util.defaultAlertForNetworkError()
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Util.setNetworkActivityIndicator(false)
        url = webView.url
        setupToolbarItems()
        errorLoadingURL = false
        doneLoadingURL = true
        DispatchQueue.main.async(execute: {
            self.loadingView?.hide()
        })
        setProgress(1.0)

        UIView.animate(withDuration: 0.25, animations: {
            self.webView?.alpha = 1.0
        })
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        Util.setNetworkActivityIndicator(true)
        doneLoadingURL = false
        setProgress(0.2)
        setupToolbarItems()
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        guard let requestUrl = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        if requestUrl.absoluteString.components(separatedBy: CharacterSet(charactersIn: "/")).count <= 1 {
            decisionHandler(.cancel)
            return
        }

        if requestUrl.absoluteString.contains(NetworkDefines.shareUrl),
           let projectId = requestUrl.catrobatProjectId {
            self.openProjectDetails(projectId: projectId)
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
        return
    }

    // MARK: - WebView Navigation

    @objc func goBack(_ sender: Any?) {
        if webView?.canGoBack == true {
            webView?.goBack()
        }
    }

    @objc func goForward(_ sender: Any?) {
        if webView?.canGoForward == true {
            webView?.goForward()
        }
    }

    @objc func refresh(_ sender: Any?) {
        if sender is UIBarButtonItem {
            if !errorLoadingURL {
                webView?.reload()
            } else {
                if let url = url {
                    webView?.load(URLRequest(url: url))
                }
            }
        }
    }

    @objc func stop(_ sender: Any?) {
        if sender is UIBarButtonItem {
            webView?.stopLoading()
        }
    }

    // MARK: - Private

    private func initUrlTitleLabel() {
        urlTitleLabel.backgroundColor = UIColor.background
        urlTitleLabel.font = UIFont.systemFont(ofSize: 13.0)
        urlTitleLabel.textColor = UIColor.globalTint
        urlTitleLabel.textAlignment = .center
        urlTitleLabel.alpha = 0.6
    }

    private func setupToolBar() {
        navigationController?.isToolbarHidden = false
        navigationController?.toolbar.barStyle = .default
        navigationController?.toolbar.tintColor = UIColor.toolTint
        navigationController?.toolbar.barTintColor = UIColor.toolBar
        navigationController?.toolbar.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]

        let forward = UIBarButtonItem(image: UIImage(named: "chevron.right"),
                                      style: .plain,
                                      target: self,
                                      action: #selector(HelpWebViewController.goForward(_:)))
        forward.isEnabled = webView?.canGoForward ?? false

        let back = UIBarButtonItem(image: UIImage(named: "chevron.left"),
                                   style: .plain,
                                   target: self,
                                   action: #selector(HelpWebViewController.goBack(_:)))
        back.isEnabled = webView?.canGoBack ?? false

        let share = UIBarButtonItem(barButtonSystemItem: .action,
                                    target: self,
                                    action: #selector(HelpWebViewController.openInSafari))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                   target: self,
                                   action: nil)
        toolbarItems = [flex, back, flex, forward, flex, flex, share, flex]
    }

    private func setupToolbarItems() {
        urlTitleLabel.text = "\(url?.host ?? "")\(url?.relativePath ?? "")"
        if let refreshOrStopButton = webView?.isLoading ?? false ? stopButton : refreshButton {
            navigationItem.rightBarButtonItems = [refreshOrStopButton]
        }

        setupToolBar()
    }

    private func setProgress(_ progress: CGFloat) {
        progressView.progress = Float(progress)
        updateURLBarVisibility()
    }

    private func updateURLBarVisibility() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.progressView.isHidden = self.doneLoadingURL
            self.urlTitleLabel.isHidden = self.doneLoadingURL
        })
    }

    // MARK: - Handler

    @objc func openInSafari() {
        if let url = url {
            Util.openUrlExternal(url)
        }
    }

    @objc private func handleSwipe(recognizer: UISwipeGestureRecognizer) {
        switch recognizer.direction {
        case .left:
            goForward(recognizer)
        case .right:
            goBack(recognizer)
        default:
            break
        }
    }
}
