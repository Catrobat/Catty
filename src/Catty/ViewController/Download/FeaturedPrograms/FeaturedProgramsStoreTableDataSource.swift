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

import Kingfisher

protocol FeaturedProgramsStoreTableDataSourceDelegete: class {
    func featuredProgramsStoreTableDataSource(_ dataSource: FeaturedProgramsStoreTableDataSource, didSelectCellWith item: CBProgram)
}

/// Featured Program table view data source base class
class FeaturedProgramsStoreTableDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    

    // MARK: - Properties
    
    weak var delegete: FeaturedProgramsStoreTableDataSourceDelegete?
    
    fileprivate let downloader: FeaturedProgramsStoreDownloaderProtocol
    fileprivate var programs = [CBProgram]()
    
    // MARK: - Initializer
    
    fileprivate init(with downloader: FeaturedProgramsStoreDownloaderProtocol) {
        self.downloader = downloader
    }
    
    static func dataSource(with downloader: FeaturedProgramsStoreDownloaderProtocol = FeaturedProgramsStoreDownloader()) -> FeaturedProgramsStoreTableDataSource {
        return LoadFeaturedProgramsStoreImage(with: downloader)
    }
    
    //MARK: - DataSource
    
    func fetchItems(completion: @escaping (FeaturedProgramsDownloadError?) -> Void) {
        self.downloader.fetchFeaturedPrograms() {items, error in
            guard let _ = items, error == nil else { completion(error); return }
            completion(nil)
        }
    } /// !!! FIXME !!!

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.programs.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.programs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }
}
    
final class LoadFeaturedProgramsStoreImage : FeaturedProgramsStoreTableDataSource
{
    private func fetchData(for program: CBProgram, completion: @escaping (Data?) -> Void) {
        guard let downloadUrl = URL(string: program.downloadUrl!) else { return }
        // try to get the image from cache
        let resource = ImageResource(downloadURL: downloadUrl)
        let options: KingfisherOptionsInfo = [.onlyFromCache]
        if ImageCache.default.imageCachedType(forKey: resource.cacheKey).cached {
            ImageCache.default.retrieveImage(forKey: resource.cacheKey, options: options) { image, _ in
                guard let image = image else { completion(nil); return }
                DispatchQueue.global().async {
                    let data = UIImagePNGRepresentation(image)
                    DispatchQueue.main.async {
                        completion(data)
                    }
                }
            }
            return
        }
        // download from the library
        self.downloader.downloadProgram(for: program) { data, _ in
            DispatchQueue.main.async { completion(data) }
            if let data = data, let image = UIImage(data: data) {
                ImageCache.default.store(image, original: data, forKey: resource.cacheKey)
            }
        }
    }
}
