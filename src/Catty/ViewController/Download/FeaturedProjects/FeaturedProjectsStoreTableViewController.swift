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

class FeaturedProjectsStoreTableViewController: UITableViewController, SelectedFeaturedProjectsDataSource {

    // MARK: - Properties

    private var dataSource: FeaturedProjectsStoreTableDataSource

    var loadingView: LoadingView?
    var shouldHideLoadingView = false
    var projectForSegue: StoreProject?
    var catrobatProject: StoreProject?

    // MARK: - Initializers

    required init?(coder aDecoder: NSCoder) {
        self.dataSource = FeaturedProjectsStoreTableDataSource.dataSource()
        super.init(coder: aDecoder)
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        shouldHideLoadingView = false
        dataSource.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == kSegueToProjectDetail {
            if let projectDetailStoreViewController = segue.destination as? ProjectDetailStoreViewController,
                let catrobatProject = projectForSegue {
                projectDetailStoreViewController.project = mapStoreProjectToCatrobatProject(project: catrobatProject)
            }
        }
    }

    // MARK: - Helper Methods

    private func mapStoreProjectToCatrobatProject(project: StoreProject) -> CatrobatProject {
        var projectDictionary = [String: Any]()
        projectDictionary["ProjectName"] = project.projectName
        projectDictionary["Author"] =  project.author
        projectDictionary["Description"] = project.description ?? ""
        projectDictionary["DownloadUrl"] = project.downloadUrl ?? ""
        projectDictionary["Downloads"] = project.downloads ?? 0
        projectDictionary["ProjectId"] = project.projectId
        projectDictionary["ProjectName"] = project.projectName
        projectDictionary["ProjectUrl"] = project.projectUrl ?? ""
        projectDictionary["ScreenshotBig"] = project.screenshotBig ?? ""
        projectDictionary["ScreenshotSmall"] = project.screenshotSmall ?? ""
        projectDictionary["FeaturedImage"] = project.featuredImage ?? ""
        projectDictionary["Uploaded"] = project.uploaded ?? 0
        projectDictionary["Version"] = project.version ?? ""
        projectDictionary["Views"] = project.views ?? 0
        projectDictionary["FileSize"] = project.fileSize ?? 0.0

        return CatrobatProject(dict: projectDictionary, andBaseUrl: kFeaturedImageBaseUrl)
    }

    private func setupTableView() {
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self.dataSource
    }

    private func fetchData() {
        if tableView.visibleCells.isEmpty {
            self.showLoadingView()
            self.dataSource.fetchItems { error in
                if error != nil {
                    self.shouldHideLoadingView = true
                    self.hideLoadingView()
                    self.showConnectionIssueAlertAndDismiss(error: error!)
                    return
                }
                self.tableView.reloadData()
                self.shouldHideLoadingView = true
                self.hideLoadingView()
            }
        } else {
            self.shouldHideLoadingView = true
            self.hideLoadingView()
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
            title = kLocalizedFeaturedProjectsLoadFailureTitle
            message = kLocalizedFeaturedProjectsLoadFailureMessage
        }

        AlertControllerBuilder.alert(title: title, message: message)
            .addDefaultAction(title: buttonTitle) { self.navigationController?.popViewController(animated: true) }.build()
            .showWithController(self)
    }

    func showLoadingView() {
        if loadingView == nil {
            loadingView = LoadingView()
            view.addSubview(loadingView!)
        }
        loadingView!.show()
        Util.setNetworkActivityIndicator(true)
    }

    func hideLoadingView() {
        if shouldHideLoadingView {
            loadingView!.hide()
            Util.setNetworkActivityIndicator(false)
            self.shouldHideLoadingView = false
        }
    }
}

extension FeaturedProjectsStoreTableViewController: FeaturedProjectsCellProtocol {

    func selectedCell(dataSource datasource: FeaturedProjectsStoreTableDataSource, didSelectCellWith cell: FeaturedProjectsCell) {
        if let project = cell.project {
            self.showLoadingView()
            projectForSegue = project
            performSegue(withIdentifier: kSegueToProjectDetail, sender: self)
        }
    }
}
