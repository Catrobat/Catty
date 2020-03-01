/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

protocol FeaturedProjectsStoreTableDataSourceDelegate: AnyObject {
    func featuredProjectsStoreTableDataSource(_ dataSource: FeaturedProjectsStoreTableDataSource, didSelectCellWith item: StoreProject)
}

protocol SelectedFeaturedProjectsDataSource: AnyObject {
    func selectedCell(dataSource: FeaturedProjectsStoreTableDataSource, didSelectCellWith cell: FeaturedProjectsCell)
}

class FeaturedProjectsStoreTableDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Properties

    weak var delegate: SelectedFeaturedProjectsDataSource?

    fileprivate let downloader: StoreProjectDownloaderProtocol
    fileprivate var projects = [StoreProject]()
    fileprivate var baseUrl = ""

    // MARK: - Initializer

    fileprivate init(with downloader: StoreProjectDownloaderProtocol) {
        self.downloader = downloader
    }

    static func dataSource(with downloader: StoreProjectDownloaderProtocol = StoreProjectDownloader()) -> FeaturedProjectsStoreTableDataSource {
        return FeaturedProjectsStoreTableDataSource(with: downloader)
    }

    // MARK: - DataSource

    func fetchItems(completion: @escaping (StoreProjectDownloaderError?) -> Void) {
        self.downloader.fetchProjects(forType: .featured, offset: 0) {items, error in
            guard let collection = items, error == nil else { completion(error); return }
            self.projects = collection.projects
            self.baseUrl = collection.information.baseUrl
            completion(nil)
        }
    }

    func numberOfRows(in tableView: UITableView) -> Int {
        return self.projects.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.projects.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kFeaturedCell, for: indexPath)
        if let cell = cell as? FeaturedProjectsCell {
            cell.featuredImage = self.baseUrl.appending(projects[indexPath.row].featuredImage!)
            cell.project = projects[indexPath.row]
        }

        return cell
    }

    // MARK: - Delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: FeaturedProjectsCell? = tableView.cellForRow(at: indexPath) as? FeaturedProjectsCell

        self.downloader.fetchProjectDetails(for: (cell?.project)!) { project, error in
            guard let StoreProject = project, error == nil else { return }
            cell?.project = StoreProject
            self.delegate?.selectedCell(dataSource: self, didSelectCellWith: cell!)
        }
    }
}
