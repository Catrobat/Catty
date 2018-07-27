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

protocol RecentProgramStoreDataSourceDelegate: class {
    func featuredProgramsStoreTableDataSource(_ dataSource: RecentProgramStoreDataSource, didSelectCellWith item: StoreProgram)
}

protocol SelectedRecentProgramsDataSource: class {
    func selectedCell(dataSource: RecentProgramStoreDataSource, didSelectCellWith cell: FeaturedProgramsCell)
}

class RecentProgramStoreDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties

    weak var delegate: SelectedRecentProgramsDataSource?

    fileprivate let downloader: StoreProgramDownloaderProtocol
    fileprivate var programs = [StoreProgram]()
    fileprivate var baseUrl = ""

    // MARK: - Initializer

    fileprivate init(with downloader: StoreProgramDownloaderProtocol) {
        self.downloader = downloader
    }

    static func dataSource(with downloader: StoreProgramDownloaderProtocol = StoreProgramDownloader()) -> RecentProgramStoreDataSource {
        return RecentProgramStoreDataSource(with: downloader)
    }

    // MARK: - DataSource

    func fetchItems(completion: @escaping (StoreProgramDownloaderError?) -> Void) {
        self.downloader.fetchPrograms(forType: .featured) {items, error in   // FIXME: change to other type
            guard let collection = items, error == nil else { completion(error); return }
            self.programs = collection.projects
            self.baseUrl = collection.information.baseUrl
            completion(nil)
        }
    }
    
    func numberOfRows(in tableView: UITableView) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kFeaturedCell, for: indexPath)
        if let cell = cell as? FeaturedProgramsCell {
            let imageUrl = URL(string: self.baseUrl.appending(programs[indexPath.row].featuredImage!))
            let data = try? Data(contentsOf: imageUrl!)
            cell.featuredImage = UIImage(data: data!)
            cell.program = programs[indexPath.row]
        }

        return cell
    }

    // MARK: - Delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: FeaturedProgramsCell? = tableView.cellForRow(at: indexPath) as? FeaturedProgramsCell

        self.downloader.downloadProgram(for: (cell?.program)!) { program, error in
            guard let StoreProgram = program, error == nil else { return }
            cell?.program = StoreProgram
            self.delegate?.selectedCell(dataSource: self, didSelectCellWith: cell!)
        }
    }
}

