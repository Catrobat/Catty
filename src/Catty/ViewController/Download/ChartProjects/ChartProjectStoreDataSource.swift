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

protocol ChartProjectStoreDataSourceDelegate: AnyObject {
    func chartProjectsStoreTableDataSource(_ dataSource: ChartProjectStoreDataSource, didSelectCellWith item: StoreProject)
}

protocol SelectedChartProjectsDataSource: AnyObject {
    func selectedCell(dataSource: ChartProjectStoreDataSource, didSelectCellWith cell: ChartProjectCell)
    func scrollViewHandler()
    func errorAlertHandler(error: StoreProjectDownloaderError)
    func showLoadingIndicator(_ inTableFooter: Bool)
    func hideLoadingIndicator(_ inTableFooter: Bool)
}

class ChartProjectStoreDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Properties

    weak var delegate: SelectedChartProjectsDataSource?

    let downloader: StoreProjectDownloaderProtocol
    var baseUrl = ""
    var projectType: ProjectType

    var mostDownloadedProjects = [StoreProject]()
    var mostViewedProjects = [StoreProject]()
    var mostRecentProjects = [StoreProject]()

    var mostDownloadedOffset = 0
    var mostViewedOffset = 0
    var mostRecentOffset = 0

    var mostDownloadedScrollViewOffset = CGPoint(x: 0.0, y: 0.0)
    var mostViewedScrollViewOffset = CGPoint(x: 0.0, y: 0.0)
    var mostRecentScrollViewOffset = CGPoint(x: 0.0, y: 0.0)

    var scrollView = UIScrollView()
    var isReloadingData: Bool = false

    var projects: [StoreProject] {
        switch projectType {
        case .mostDownloaded:
            return mostDownloadedProjects
        case .mostViewed:
            return mostViewedProjects
        case .mostRecent:
            return mostRecentProjects
        default:
            return [StoreProject]()
        }
    }

    var projectOffset: Int {
        switch projectType {
        case .mostDownloaded:
            return mostDownloadedOffset
        case .mostViewed:
            return mostViewedOffset
        case .mostRecent:
            return mostRecentOffset
        default:
            return 0
        }
    }

    var scrollViewOffset: CGPoint {
        switch projectType {
        case .mostDownloaded:
            return mostDownloadedScrollViewOffset
        case .mostViewed:
            return mostViewedScrollViewOffset
        case .mostRecent:
            return mostRecentScrollViewOffset
        default:
            return CGPoint(x: 0, y: 0)
        }
    }

    // MARK: - Initializer

    fileprivate init(with downloader: StoreProjectDownloaderProtocol) {
        self.downloader = downloader
        self.projectType = .mostDownloaded
    }

    static func dataSource(with downloader: StoreProjectDownloaderProtocol = StoreProjectDownloader()) -> ChartProjectStoreDataSource {
        return ChartProjectStoreDataSource(with: downloader)
    }

    // MARK: - DataSource

    func fetchItems(type: ProjectType, completion: @escaping (StoreProjectDownloaderError?) -> Void) {

        projectType = type
        scrollView.setContentOffset(scrollViewOffset, animated: false)

        if self.projectOffset == projects.count || projects.isEmpty {
            self.downloader.fetchProjects(forType: type, offset: self.projectOffset) {items, error in

                guard let collection = items, error == nil else { completion(error); return }

                switch self.projectType {
                case .mostDownloaded:
                    self.mostDownloadedProjects.append(contentsOf: collection.projects)
                    self.mostDownloadedOffset += kRecentProjectsMaxResults
                case .mostViewed:
                    self.mostViewedProjects.append(contentsOf: collection.projects)
                    self.mostViewedOffset += kRecentProjectsMaxResults
                case .mostRecent:
                    self.mostRecentProjects.append(contentsOf: collection.projects)
                    self.mostRecentOffset += kRecentProjectsMaxResults
                default:
                    return
                }
                self.baseUrl = collection.information.baseUrl
                completion(nil)

            }
        } else {
            completion(nil)
        }
    }

    func numberOfRows(in tableView: UITableView) -> Int {
        return self.projects.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.projects.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableUtil.heightForImageCell()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kImageCell, for: indexPath)
        if let cell = cell as? ChartProjectCell {
            cell.tag = indexPath.row
            if projects.isEmpty == false && indexPath.row < self.projects.count {
                cell.chartImage = nil
                cell.chartTitle = projects[indexPath.row].projectName
                cell.project = projects[indexPath.row]

                DispatchQueue.global().async {
                    guard let screenshotSmall = self.projects[indexPath.row].screenshotSmall else { return }
                    guard let imageUrl = URL(string: self.baseUrl.appending(screenshotSmall)) else { return }
                    guard let data = try? Data(contentsOf: imageUrl) else { return }
                    DispatchQueue.main.async {
                        // this check is supposed to prevent setting an asynchronously downloaded
                        // image into a cell that has already been reused since then
                        guard cell.tag == indexPath.row else { return }
                        cell.chartImage = UIImage(data: data)
                    }
                }
            }
        }
        return cell
    }

    // MARK: - Delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? ChartProjectCell else { return }
        guard let cellProject = cell.project else { return }
        let timer = ExtendedTimer(timeInterval: TimeInterval(kConnectionTimeout),
                                  repeats: false,
                                  execOnMainRunLoop: false,
                                  startTimerImmediately: true) { timer in
            self.delegate?.errorAlertHandler(error: .timeout)
            timer.invalidate()
            self.delegate?.hideLoadingIndicator(false)
        }
        self.delegate?.showLoadingIndicator(false)

        self.downloader.downloadProject(for: cellProject) { project, error in
            guard timer.isValid else { return }
            guard let StoreProject = project, error == nil else { return }
            cell.project = StoreProject
            self.delegate?.selectedCell(dataSource: self, didSelectCellWith: cell)
            timer.invalidate()
            self.delegate?.hideLoadingIndicator(false)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        self.scrollView = scrollView

        switch projectType {
        case .mostDownloaded:
            mostDownloadedScrollViewOffset = scrollView.contentOffset
        case .mostViewed:
            mostViewedScrollViewOffset = scrollView.contentOffset
        case .mostRecent:
            mostRecentScrollViewOffset = scrollView.contentOffset
        default:
            return
        }
        let checkPoint = Float(scrollView.contentSize.height - TableUtil.heightForImageCell())
        let currentViewBottomEdge = Float(scrollView.contentOffset.y + scrollView.frame.size.height)

        if currentViewBottomEdge >= checkPoint && !isReloadingData {
            self.delegate?.showLoadingIndicator(true)
            self.isReloadingData = true

            self.fetchItems(type: self.projectType) { error in
                self.delegate?.hideLoadingIndicator(true)
                self.isReloadingData = false
                if error != nil {
                    self.delegate?.errorAlertHandler(error: error!)
                    self.delegate = nil
                }
            }
            self.delegate?.scrollViewHandler()
        }
    }
}
