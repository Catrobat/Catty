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

class HelpWebViewController: UIViewController, UIWebViewDelegate, UIScrollViewDelegate, FileManagerDelegate {
    private var errorLoadingURL = false
    private var doneLoadingURL = false
    private var controlsHidden = false
    private var refreshButton: UIBarButtonItem?
    private var stopButton: UIBarButtonItem?
    private var topViewController: UIViewController?
    private var url: URL?
    private var touchHelperView: UIView?
    private var loadingView: LoadingView?
    var project: StoreProject?
    @objc var navigationUrl = ""
    @objc var setTitle = false

    @IBOutlet private weak var urlTitleLabel: UILabel!
    @IBOutlet private weak var progressView: UIProgressView!
    @IBOutlet private weak var webView: UIWebView!

    // MARK: - Init

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        url = nil
        webView.delegate = nil
        webView = nil
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if setTitle == true {
            title = kLocalizedHelp
            setupToolBar()
        }
        
        
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

        url = URL(string: navigationUrl)
        webView.scrollView.delegate = self
        webView.delegate = self
        webView.allowsInlineMediaPlayback = true
        webView.scalesPageToFit = true
        webView.backgroundColor = UIColor.background()
        webView.alpha = 0.0
        initUrlTitleLabel()
        if url != nil {
            if let url = url {
                webView.loadRequest(URLRequest(url: url))
            }
        }

        touchHelperView = UIView(frame: CGRect.zero)
        touchHelperView?.backgroundColor = UIColor.clear
        progressView.tintColor = UIColor.navTint()
        automaticallyAdjustsScrollViewInsets = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupToolbarItems()
        if let touchHelperView = touchHelperView {
            view.insertSubview(touchHelperView, aboveSubview: webView)
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
        webView.stopLoading()

        topViewController = navigationController?.topViewController
        navigationController?.hidesBarsOnSwipe = false
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        touchHelperView?.frame = CGRect(x: CGFloat(0.0),
                                        y: view.bounds.height - CGFloat(kToolbarHeight),
                                        width: view.bounds.width,
                                        height: CGFloat(kToolbarHeight))
    }

    // MARK: - WebViewDelegate

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
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

    func webViewDidFinishLoad(_ webView: UIWebView) {
        Util.setNetworkActivityIndicator(false)
        url = webView.request?.url
        setupToolbarItems()
        errorLoadingURL = false
        doneLoadingURL = true
        loadingView?.hide()
        setProgress(1.0)

        UIView.animate(withDuration: 0.25, animations: {
            self.webView.alpha = 1.0
        })
    }

    func webViewDidStartLoad(_ webView: UIWebView) {
        Util.setNetworkActivityIndicator(true)
        doneLoadingURL = false
        setProgress(0.2)
        setupToolbarItems()
    }

    func webView(_ webView: UIWebView,
                 shouldStartLoadWith request: URLRequest,
                 navigationType: UIWebView.NavigationType) -> Bool {
        if !((request.url?.absoluteString ?? "").contains(kDownloadUrl)) {
            return true
        }
        let urlWithoutParams: String? = request.url?.absoluteString
            .components(separatedBy: CharacterSet(charactersIn: "?"))[0]
        // extract project ID from URL => example: https://pocketcode.org/download/959.catrobat
        var urlParts = urlWithoutParams?.components(separatedBy: "/")
        if urlParts?.count == nil {
            Util.alert(withText: kLocalizedInvalidURLGiven)
            return false
        }
        // get last part of url and split by using separator "." => 959.catrobat
        urlParts = urlParts?.last?.components(separatedBy: ".")
        if urlParts?.count != 2 {
            Util.alert(withText: kLocalizedInvalidURLGiven)
            return false
        }
        // check if projectID is valid number
        let projectID = urlParts?.first
        if projectID == nil ||
            !(projectID == String(Int(projectID!)!)) {
            Util.alert(withText: kLocalizedInvalidURLGiven)
            return false
        }
        // get url parameters
        guard let urlComp = URLComponents(string: (request.url?.absoluteString)!) else {
            Util.alert(withText: kLocalizedInvalidURLGiven)
            return false
        }
        // parse project name
        let projectName: String? = urlComp.queryItems?
            .first(where: { $0.name == "fname" })?.value?
            .replacingOccurrences(of: "+", with: " ")
        if projectName == nil || projectName!.isEmpty {
            Util.alert(withText: kLocalizedInvalidURLGiven)
            return false
        }
        // check if project exists
        if projectName != nil && Project.projectExists(withProjectName: projectName!,
                                                       projectID: projectID!) {
            Util.alert(withText: kLocalizedProjectAlreadyDownloadedDescription)
            return false
        }

        let url = URL(string: urlWithoutParams ?? "")
        if let fileManager = CBFileManager.shared() {
            fileManager.delegate = self
            fileManager.downloadProject(from: url, withProjectID: projectID, andName: projectName)
            loadingView?.show()
        }
        return false
    }

    // MARK: - WebView Navigation

    @objc func goBack(_ sender: Any?) {
        if webView.canGoBack {
            webView.goBack()
        }
    }

    @objc func goForward(_ sender: Any?) {
        if webView.canGoForward {
            webView.goForward()
        }
    }

    @objc func refresh(_ sender: Any?) {
        if sender is UIBarButtonItem {
            if !errorLoadingURL {
                webView.reload()
            } else {
                if let url = url {
                    webView.loadRequest(URLRequest(url: url))
                }
            }
        }
    }

    @objc func stop(_ sender: Any?) {
        if sender is UIBarButtonItem {
            webView.stopLoading()
        }
    }

    // MARK: - Private

    private func initUrlTitleLabel() {
        urlTitleLabel.backgroundColor = UIColor.background()
        urlTitleLabel.font = UIFont.systemFont(ofSize: 13.0)
        urlTitleLabel.textColor = UIColor.globalTint()
        urlTitleLabel.textAlignment = .center
        urlTitleLabel.alpha = 0.6
    }

    private func setupToolBar() {
        navigationController?.isToolbarHidden = false
        navigationController?.toolbar.barStyle = .default
        navigationController?.toolbar.tintColor = UIColor.toolTint()
        navigationController?.toolbar.barTintColor = UIColor.toolBar()
        navigationController?.toolbar.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]

        let forward = UIBarButtonItem(image: UIImage(named: "webview_arrow_right"),
                                      style: .plain,
                                      target: self,
                                      action: #selector(HelpWebViewController.goForward(_:)))
        forward.isEnabled = webView.canGoForward

        let back = UIBarButtonItem(image: UIImage(named: "webview_arrow_left"),
                                   style: .plain,
                                   target: self,
                                   action: #selector(HelpWebViewController.goBack(_:)))
        back.isEnabled = webView.canGoBack
        let share = UIBarButtonItem(barButtonSystemItem: .action,
                                    target: self,
                                    action: #selector(HelpWebViewController.openInSafari))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                   target: self,
                                   action: nil)
        toolbarItems = [flex, back, flex, forward, flex, flex, share, flex]
    }

    private func setupToolbarItems() {
        let refreshOrStopButton: UIBarButtonItem? = webView.isLoading ? stopButton : refreshButton
        urlTitleLabel.text = "\(url?.host ?? "")\(url?.relativePath ?? "")"
        navigationItem.rightBarButtonItems = [refreshOrStopButton] as? [UIBarButtonItem]

        if setTitle == true {
            setupToolBar()
        }
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

    private func showDownloadedView() {
        let hud = BDKNotifyHUD(image: UIImage(named: "checkmark.png"),
                               text: kLocalizedDownloaded)
        hud?.destinationOpacity = CGFloat(kBDKNotifyHUDDestinationOpacity)
        hud?.center = CGPoint(x: view.center.x,
                              y: view.center.y + CGFloat(kBDKNotifyHUDCenterOffsetY))
        hud?.tag = Int(kSavedViewTag)
        view.addSubview(hud!)
        hud?.present(withDuration: CGFloat(kBDKNotifyHUDPresentationDuration),
                     speed: CGFloat(kBDKNotifyHUDPresentationSpeed),
                     in: view) {
                        hud?.removeFromSuperview()
        }
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

    // MARK: - FileManagerDelegate

    func downloadFinished(with url: URL?, andProjectLoadingInfo info: ProjectLoadingInfo?) {
        DispatchQueue.main.async(execute: {
            self.loadingView?.hide()
            self.showDownloadedView()
        })
    }

    func updateProgress(_ progress: Double) {
        if progress < 1.0 {
            doneLoadingURL = false
        } else {
            doneLoadingURL = true
        }
        setProgress(CGFloat(progress))
    }

    func timeoutReached() {
        setBackDownloadStatus()
        Util.defaultAlertForNetworkError()
    }

    func maximumFilesizeReached() {
        setBackDownloadStatus()
        Util.alert(withText: kLocalizedNotEnoughFreeMemoryDescription)
    }

    func fileNotFound() {
        setBackDownloadStatus()
        Util.alert(withText: kLocalizedProjectNotFound)
    }

    func invalidZip() {
        setBackDownloadStatus()
        Util.alert(withText: kLocalizedInvalidZip)
    }

    func setBackDownloadStatus() {
        //FileManagerDelegate (necessary)
    }
}
