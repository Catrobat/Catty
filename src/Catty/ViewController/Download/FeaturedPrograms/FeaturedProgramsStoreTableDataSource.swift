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

protocol SelectedFeaturedProgramsDataSource: class {
     func selectedCell(dataSource: FeaturedProgramsStoreTableDataSource, didSelectCellWith cell: FeaturedProgramsCell)
}

class FeaturedProgramsStoreTableDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    weak var delegate: SelectedFeaturedProgramsDataSource?
    
    fileprivate let downloader: FeaturedProgramsStoreDownloaderProtocol
    fileprivate var programs = [CBProgram]()
    
    fileprivate init(with downloader: FeaturedProgramsStoreDownloaderProtocol) {
        self.downloader = downloader
    }
    
    static func dataSource(with downloader: FeaturedProgramsStoreDownloaderProtocol = FeaturedProgramsStoreDownloader()) -> FeaturedProgramsStoreTableDataSource {
        return LoadFeaturedProgramsStoreImage(with: downloader)
    }
    
    func fetchItems(completion: @escaping (FeaturedProgramsDownloadError?) -> Void) {
        self.downloader.fetchFeaturedPrograms() {items, error in
            guard let collection = items, error == nil else { completion(error); return }
            self.programs = collection.projects
            completion(nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.programs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kFeaturedCell, for: indexPath)
        if let cell = cell as? FeaturedProgramsCell {
            let imageUrl = URL(string: kFeaturedImageBaseUrl.appending(programs[indexPath.row].featuredImage!))
            let data = try? Data(contentsOf: imageUrl!)
            cell.featuredImage = UIImage(data: data!)
            cell.program = programs[indexPath.row]
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: FeaturedProgramsCell? = tableView.cellForRow(at: indexPath) as? FeaturedProgramsCell
        var newProgram: CBProgram = (cell?.program)!
        
        self.downloader.downloadProgram(for: newProgram) {program, error in
            guard let cbprogram = program, error == nil else { return }
            //self.programs = collection.projects
            newProgram = cbprogram
            let programid = cbprogram.projectId

        }
        //delegate?.selectedCell(dataSource: self, didSelectCellWith: cell!)
    }
}
    
final class LoadFeaturedProgramsStoreImage : FeaturedProgramsStoreTableDataSource {

    private func fetchData(for program: CBProgram, completion: @escaping (Data?) -> Void) {
        guard let downloadUrl = URL(string: program.downloadUrl!) else { return }

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

