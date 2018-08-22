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

protocol SearchStoreDataSourceDelegate: class {
    func searchStoreTableDataSource(_ dataSource: SearchStoreDataSource, didSelectCellWith item: StoreProgram)
}

protocol SelectedSearchStoreDataSource: class {
    func selectedCell(dataSource: SearchStoreDataSource, didSelectCellWith cell: ChartProgramCell)
}

class SearchStoreDataSource: NSObject, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    weak var delegate: SelectedSearchStoreDataSource?
    weak var searchBarDelegate: UISearchBarDelegate?
    
    let downloader: StoreProgramDownloaderProtocol
    var programs = [StoreProgram]()
    var baseUrl = ""
    
    var searchBar = UISearchBar()
    
    fileprivate init(with downloader: StoreProgramDownloaderProtocol) {
        self.downloader = downloader
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.isEmpty == false {
            fetchItems(searchTerm: searchBar.text) { error in
                print("hello")
            }
        }
    }
    
    func fetchItems(searchTerm: String?, completion: @escaping (StoreProgramDownloaderError?) -> Void) {
        if let searchTerm: String = searchTerm {
            self.downloader.fetchSearchQuery(searchTerm: searchTerm) { items,error in
                guard let collection = items, error == nil else { completion(error); return }
                self.programs = collection.projects
                self.baseUrl = collection.information.baseUrl
                completion(nil)
            }
        }
    }
    
    static func dataSource(with downloader: StoreProgramDownloaderProtocol = StoreProgramDownloader()) -> SearchStoreDataSource {
        return SearchStoreDataSource(with: downloader)
    }
    
    func numberOfRows(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableUtil.heightForImageCell()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
