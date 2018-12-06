/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

class SearchStoreViewController: UIViewController, SelectedSearchStoreDataSource, UISearchBarDelegate {

    @IBOutlet private weak var searchStoreTableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!

    // MARK: - Properties

    private var dataSource: SearchStoreDataSource

    var loadingView: LoadingView?
    var shouldHideLoadingView = false
    var programForSegue: StoreProgram?
    var catrobatProject: StoreProgram?
    var loadingViewFlag = false
    var noSearchResultsLabel: UILabel!

    // MARK: - Initializers

    required init?(coder aDecoder: NSCoder) {
        self.dataSource = SearchStoreDataSource.dataSource()
        super.init(coder: aDecoder)
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        initNoSearchResultsLabel()
        shouldHideLoadingView = false
        dataSource.delegate = self
        searchStoreTableView.tableFooterView = UIView(frame: CGRect.zero)
        searchBar.becomeFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadingViewHandlerAfterFetchData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kSegueToProgramDetail {
            if let programDetailStoreViewController = segue.destination as? ProgramDetailStoreViewController,
                let catrobatProject = programForSegue {
                programDetailStoreViewController.project = mapStoreProgramToCatrobatProgram(program: catrobatProject)
            }
        }
    }

    // MARK: - Helper Methods

    private func mapStoreProgramToCatrobatProgram(program: StoreProgram) -> CatrobatProgram {
        var programDictionary = [String: Any]()
        programDictionary["ProjectName"] = program.projectName
        programDictionary["Author"] =  program.author
        programDictionary["Description"] = program.description ?? ""
        programDictionary["DownloadUrl"] = program.downloadUrl ?? ""
        programDictionary["Downloads"] = program.downloads ?? 0
        programDictionary["ProjectId"] = program.projectId
        programDictionary["ProjectName"] = program.projectName
        programDictionary["ProjectUrl"] = program.projectUrl ?? ""
        programDictionary["ScreenshotBig"] = program.screenshotBig ?? ""
        programDictionary["ScreenshotSmall"] = program.screenshotSmall ?? ""
        programDictionary["FeaturedImage"] = program.featuredImage ?? ""
        programDictionary["Uploaded"] = program.uploaded ?? 0
        programDictionary["Version"] = program.version ?? ""
        programDictionary["Views"] = program.views ?? 0
        programDictionary["FileSize"] = program.fileSize ?? 0.0

        return CatrobatProgram(dict: programDictionary, andBaseUrl: kFeaturedImageBaseUrl)
    }

    func initNoSearchResultsLabel() {
        DispatchQueue.main.async {
            self.noSearchResultsLabel = UILabel(frame: self.view.frame)
            self.noSearchResultsLabel.text = kLocalizedNoSearchResults
            self.noSearchResultsLabel.textAlignment = .center
            self.noSearchResultsLabel.textColor = UIColor.globalTint()
            self.noSearchResultsLabel.tintColor = UIColor.globalTint()
            self.noSearchResultsLabel.isHidden = true
            self.view.addSubview(self.noSearchResultsLabel)
        }
    }

    private func showConnectionIssueAlertAndDismiss(error: StoreProgramDownloaderError) {
        var title = ""
        var message = ""
        let buttonTitle = kLocalizedOK

        switch error {
        case .timeout:
            title = kLocalizedServerTimeoutIssueTitle
            message = kLocalizedServerTimeoutIssueMessage
        default:
            title = kLocalizedUnexpectedErrorTitle
            message = kLocalizedUnexpectedErrorMessage
        }

        AlertControllerBuilder.alert(title: title, message: message)
            .addDefaultAction(title: buttonTitle) { self.navigationController?.popViewController(animated: true) }.build()
            .showWithController(self)
    }

    private func setupTableView() {
        self.searchStoreTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.searchStoreTableView.backgroundColor = UIColor.background()
        self.searchStoreTableView.separatorColor = UIColor.globalTint()
        self.searchStoreTableView.dataSource = self.dataSource
        self.searchStoreTableView.delegate = self.dataSource
        self.searchBar.delegate = self
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
        loadingIndicator(true)
    }

    func hideLoadingView() {
        if shouldHideLoadingView {
            loadingView?.hide()
            loadingIndicator(false)
            self.shouldHideLoadingView = false
        }
    }

    func loadingIndicator(_ value: Bool) {
        let app = UIApplication.shared
        app.isNetworkActivityIndicatorVisible = value
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 2 {
            hideNoResultsAlert()

            showLoadingView()
            self.dataSource.fetchItems(searchTerm: searchText) { error in
                if error != nil {
                    self.shouldHideLoadingView = true
                    self.hideLoadingView()
                    self.showConnectionIssueAlertAndDismiss(error: error!)
                    return
                }
                self.searchStoreTableView.reloadData()
                self.shouldHideLoadingView = true
                self.hideLoadingView()
                self.searchStoreTableView.separatorStyle = .singleLine
            }
        } else {
            self.dataSource.programs.removeAll()
            self.updateTableView()
        }
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension SearchStoreViewController: SearchStoreCellProtocol {
    func selectedCell(dataSource: SearchStoreDataSource, didSelectCellWith cell: SearchStoreCell) {
        if let program = cell.program {
            self.showLoadingView()
            programForSegue = program
            performSegue(withIdentifier: kSegueToProgramDetail, sender: self)
        }
    }
}

extension SearchStoreViewController {

    func updateTableView() {
        self.searchStoreTableView.reloadData()
        self.searchStoreTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }

    func showNoResultsAlert() {
        self.searchStoreTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        noSearchResultsLabel.isHidden = false
    }

    func hideNoResultsAlert() {
        noSearchResultsLabel.isHidden = true
    }

    func errorAlertHandler(error: StoreProgramDownloaderError) {
        self.shouldHideLoadingView = true
        self.hideLoadingView()
        self.showConnectionIssueAlertAndDismiss(error: error)
        self.searchStoreTableView.separatorStyle = .singleLine
        return
    }

    func showLoadingIndicator() {
        DispatchQueue.main.async {
            self.shouldHideLoadingView = false
            self.showLoadingView()
        }
    }

    func hideLoadingIndicator() {
        DispatchQueue.main.async {
            self.shouldHideLoadingView = true
            self.hideLoadingView()
        }
    }
}
