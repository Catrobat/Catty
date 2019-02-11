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

class ChartProjectsStoreViewController: UIViewController, SelectedChartProjectsDataSource {

    @IBOutlet private weak var chartProjectsTableView: UITableView!
    @IBOutlet private weak var chartProjectsSegmentedControl: UISegmentedControl!

    // MARK: - Properties

    private var dataSource: ChartProjectStoreDataSource

    var loadingView: LoadingView?
    var shouldHideLoadingView = false
    var projectForSegue: StoreProject?
    var catrobatProject: StoreProject?
    var loadingViewFlag = false

    // MARK: - Initializers

    required init?(coder aDecoder: NSCoder) {
        self.dataSource = ChartProjectStoreDataSource.dataSource()
        super.init(coder: aDecoder)
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        shouldHideLoadingView = false
        dataSource.delegate = self
        setupTableView()
        initSegmentedControl()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadingViewHandlerAfterFetchData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kSegueToAppInBroswer {
            if let inAppBrowserViewController = segue.destination as? InAppBrowserViewController,
                let catrobatProject = projectForSegue {
                inAppBrowserViewController.project = catrobatProject
                inAppBrowserViewController.navigationUrl = kBaseUrl + "program/\(String(describing: inAppBrowserViewController.project!.projectId))"
                inAppBrowserViewController.setTitleAndToolbar = false
            }
        }
    }

    @IBAction private func segmentTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            fetchData(type: .mostDownloaded)
        case 1:
            fetchData(type: .mostViewed)
        case 2:
            fetchData(type: .mostRecent)
        default:
            break
        }
    }

    // MARK: - Helper Methods

    func initSegmentedControl() {
        chartProjectsSegmentedControl?.setTitle(kLocalizedMostDownloaded, forSegmentAt: 0)
        chartProjectsSegmentedControl?.setTitle(kLocalizedMostViewed, forSegmentAt: 1)
        chartProjectsSegmentedControl?.setTitle(kLocalizedNewest, forSegmentAt: 2)
        fetchData(type: .mostDownloaded)

        if checkIphoneScreenSize() {
            let font = UIFont.systemFont(ofSize: 10)
            chartProjectsSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        }
    }

    // check iPhone4 or iphone5
    private func checkIphoneScreenSize() -> Bool {
        let screenHeight = Float(Util.screenHeight())
        return (((screenHeight - kIphone4ScreenHeight) == 0) || ((screenHeight - kIphone5ScreenHeight) == 0)) ? true : false
    }

    private func setupTableView() {
        self.chartProjectsTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.chartProjectsTableView.backgroundColor = UIColor.background()
        self.chartProjectsTableView.separatorColor = UIColor.globalTint()
        self.chartProjectsTableView.dataSource = self.dataSource
        self.chartProjectsTableView.delegate = self.dataSource
    }

    private func fetchData(type: ProjectType) {
        DispatchQueue.main.async {
            self.showLoadingView()
        }

        self.dataSource.fetchItems(type: type) { error in
            if error != nil {
                self.shouldHideLoadingView = true
                self.hideLoadingView()
                self.showConnectionIssueAlertAndDismiss(error: error!)
                self.chartProjectsTableView.separatorStyle = .singleLine
                return
            }
            self.chartProjectsTableView.reloadData()
            self.shouldHideLoadingView = true
            self.hideLoadingView()
            self.chartProjectsTableView.separatorStyle = .singleLine
        }
    }

    private func showConnectionIssueAlertAndDismiss(error: StoreProjectDownloaderError) {
        var title = ""
        var message = ""
        let buttonTitle = kLocalizedOK

        switch error {
        case .timeout:
            title = kLocalizedServerTimeoutIssueTitle
            message = kLocalizedServerTimeoutIssueMessage
        default:
            title = kLocalizedChartProjectsLoadFailureTitle
            message = kLocalizeChartProjectsLoadFailureMessage
        }

        DispatchQueue.main.async {
            AlertControllerBuilder.alert(title: title, message: message)
                .addDefaultAction(title: buttonTitle) { self.navigationController?.popViewController(animated: true) }.build()
                .showWithController(self)
        }
    }

    func loadingViewHandlerAfterFetchData() {
        if loadingViewFlag == false {
            self.showLoadingView()
            self.shouldHideLoadingView = true
            self.hideLoadingView()
        } else {
            self.shouldHideLoadingView = true
            self.hideLoadingView()
            loadingViewFlag = false
        }
    }

    func showLoadingView() {
        if loadingView == nil {
            loadingView = LoadingView()
            view.addSubview(loadingView!)
        }
        loadingView?.show()
        Util.setNetworkActivityIndicator(true)
    }

    func hideLoadingView() {
        if shouldHideLoadingView {
            loadingView?.hide()
            Util.setNetworkActivityIndicator(false)
            self.shouldHideLoadingView = false
        }
    }
}

extension ChartProjectsStoreViewController: ChartProjectCellProtocol {
    func selectedCell(dataSource datasource: ChartProjectStoreDataSource, didSelectCellWith cell: ChartProjectCell) {
        if let project = cell.project {
            self.showLoadingView()
            loadingViewFlag = true
            projectForSegue = project
            performSegue(withIdentifier: kSegueToAppInBroswer, sender: self)
        }
    }
}

extension ChartProjectsStoreViewController {
    func scrollViewHandler() {
        chartProjectsTableView.reloadData()
    }

    func errorAlertHandler(error: StoreProjectDownloaderError) {
        self.shouldHideLoadingView = true
        self.hideLoadingView()
        self.showConnectionIssueAlertAndDismiss(error: error)
        self.chartProjectsTableView.separatorStyle = .singleLine
        return
    }

    func showLoadingIndicator(_ inTableFooter: Bool = false) {
        DispatchQueue.main.async {
            if inTableFooter {
                let spinner = UIActivityIndicatorView(style: .gray)
                spinner.startAnimating()
                spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: self.chartProjectsTableView.bounds.width, height: CGFloat(44))

                self.chartProjectsTableView.tableFooterView = spinner
                self.chartProjectsTableView.tableFooterView?.isHidden = false
            } else {
                self.shouldHideLoadingView = false
                self.showLoadingView()
            }
        }
    }

    func hideLoadingIndicator(_ inTableFooter: Bool = false) {
        DispatchQueue.main.async {
            if inTableFooter {
                self.chartProjectsTableView.tableFooterView?.isHidden = true
            } else {
                self.shouldHideLoadingView = true
                self.hideLoadingView()
            }
        }
    }
}
