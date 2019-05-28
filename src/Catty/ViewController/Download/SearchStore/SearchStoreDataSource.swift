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

protocol SearchStoreDataSourceDelegate: AnyObject {
    func searchStoreTableDataSource(_ dataSource: SearchStoreDataSource, didSelectCellWith item: StoreProject)
}

protocol SelectedSearchStoreDataSource: AnyObject {
    func selectedCell(dataSource: SearchStoreDataSource, didSelectCellWith cell: SearchStoreCell)
    func showNoResultsAlert()
    func hideNoResultsAlert()
    func updateTableView()
    func errorAlertHandler(error: StoreProjectDownloaderError)
    func showLoadingIndicator()
    func hideLoadingIndicator()
}

class SearchStoreDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Properties

    weak var delegate: SelectedSearchStoreDataSource?

    let downloader: StoreProjectDownloaderProtocol
    var projects = [StoreProject]()
    var baseUrl = ""
    var lastSearchTerm = ""

    var isReloadingData: Bool = false

    // MARK: - Initializer

    fileprivate init(with downloader: StoreProjectDownloaderProtocol) {
        self.downloader = downloader
    }

    // MARK: - DataSource

    func fetchItems(searchTerm: String?, completion: @escaping (StoreProjectDownloaderError?) -> Void) {
        if let searchTerm: String = searchTerm {
            lastSearchTerm = searchTerm

            self.downloader.fetchSearchQuery(searchTerm: searchTerm) { items, error in
                guard searchTerm == self.lastSearchTerm else { return }
                guard let collection = items, error == nil else { completion(error); return }

                self.projects = collection.projects
                self.baseUrl = collection.information.baseUrl
                self.delegate?.updateTableView()
                completion(nil)
                if self.projects.isEmpty {
                    self.delegate?.showNoResultsAlert()
                } else {
                    self.delegate?.hideNoResultsAlert()
                }
            }
        }
    }

    static func dataSource(with downloader: StoreProjectDownloaderProtocol = StoreProjectDownloader()) -> SearchStoreDataSource {
        return SearchStoreDataSource(with: downloader)
    }

    func numberOfRows(in tableView: UITableView) -> Int {
        return projects.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return projects.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableUtil.heightForImageCell()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kSearchCell, for: indexPath)
        if let cell = cell as? SearchStoreCell {
            cell.tag = indexPath.row
            if projects.isEmpty == false && indexPath.row < self.projects.count {
                cell.searchImage = nil
                cell.searchTitle = self.projects[indexPath.row].projectName
                cell.project = self.projects[indexPath.row]

                DispatchQueue.global().async {
                    guard let screenshotSmall = self.projects[indexPath.row].screenshotSmall else { return }
                    guard let imageUrl = URL(string: self.baseUrl.appending(screenshotSmall)) else { return }
                    if let data = try? Data(contentsOf: imageUrl) {
                        DispatchQueue.main.async {
                            // this check is supposed to prevent setting an asynchronously downloaded
                            // image into a cell that has already been reused since then
                            guard cell.tag == indexPath.row else { return }
                            cell.searchImage = UIImage(data: data)
                        }
                    }
                }
            }
        }
        return cell
    }

    // MARK: - Delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell: SearchStoreCell? = tableView.cellForRow(at: indexPath) as? SearchStoreCell
        let timer = ExtendedTimer(timeInterval: TimeInterval(kConnectionTimeout),
                                  repeats: false,
                                  execOnMainRunLoop: false,
                                  startTimerImmediately: true) { timer in
            self.delegate?.errorAlertHandler(error: .timeout)
            timer.invalidate()
            self.delegate?.hideLoadingIndicator()
        }
        self.delegate?.showLoadingIndicator()

        guard let cellProject = cell?.project else { return }
        self.downloader.downloadProject(for: cellProject) { project, error in
            guard timer.isValid else { return }
            guard let StoreProject = project, error == nil else { return }
            guard let cell = cell else { return }
            cell.project = StoreProject
            self.delegate?.selectedCell(dataSource: self, didSelectCellWith: cell)
            timer.invalidate()
            self.delegate?.hideLoadingIndicator()
        }
    }
}
