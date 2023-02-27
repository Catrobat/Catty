/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

class FeaturedProjectsStoreTableDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Properties

    weak var delegate: FeaturedProjectsCellDelegate?

    fileprivate let downloader: StoreProjectDownloaderProtocol
    fileprivate var projects = [StoreFeaturedProject]()

    // MARK: - Initializer

    fileprivate init(with downloader: StoreProjectDownloaderProtocol) {
        self.downloader = downloader
    }

    static func dataSource(with downloader: StoreProjectDownloaderProtocol = StoreProjectDownloader()) -> FeaturedProjectsStoreTableDataSource {
        FeaturedProjectsStoreTableDataSource(with: downloader)
    }

    // MARK: - DataSource

    func fetchItems(completion: @escaping (StoreProjectDownloaderError?) -> Void) {
        self.downloader.fetchFeaturedProjects(offset: 0) {items, error in
            guard let collection = items, error == nil else { completion(error); return }
            self.projects = collection
            completion(nil)
        }
    }

    func numberOfRows(in tableView: UITableView) -> Int {
        self.projects.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.projects.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kFeaturedCell, for: indexPath)
        if let cell = cell as? FeaturedProjectsCell {
            cell.featuredImage = projects[indexPath.row].featuredImage
            cell.project = projects[indexPath.row]
        }

        return cell
    }

    // MARK: - Delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: FeaturedProjectsCell? = tableView.cellForRow(at: indexPath) as? FeaturedProjectsCell

        self.downloader.fetchProjectDetails(for: (cell?.project)!.id) { project, error in
            guard let storeProject = project, error == nil else { return }
            self.delegate?.openProject(storeProject)
        }
    }
}
