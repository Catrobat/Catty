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

class FeaturedProgramsStoreTableDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    fileprivate let downloader: FeaturedProgramsStoreDownloaderProtocol
    fileprivate let programs: [CBProgram]
    
    let imageCellReuseIdentifier = "image"
    weak var delegete: FeaturedProgramsStoreTableDataSourceDelegete?
    
    /// MARK: - Properties
    fileprivate init(for programs: [CBProgram], with downloader: FeaturedProgramsStoreDownloaderProtocol) {
        self.downloader = downloader
        self.programs = programs
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.programs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        return cell
    }
    
    
//    func fetchItems(completion: @escaping (FeaturedProgramsDownloadError?) -> Void) {
//        self.downloader.downloadIndex(for: self.mediaType) { [weak self] items, error in
//            guard let items = items, error == nil else { completion(error); return }
//            self?.items = items
//            completion(nil)
//        }
//    }
    
    private func fetchData(for item: CBProgram, completion: @escaping (Data?) -> Void) {
        guard let downloadUrl = URL(string: item.downloadUrl!) else { return }
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
    }
}
