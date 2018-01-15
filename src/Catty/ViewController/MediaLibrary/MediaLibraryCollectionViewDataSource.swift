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

import Kingfisher // there is not much point in using Kingfisher unless the Media Library offers thumbnail preview images

protocol MediaLibraryCollectionViewDataSourceDelegate: class {
    func mediaLibraryCollectionViewDataSource(_ dataSource: MediaLibraryCollectionViewDataSource, didSelectCellWith item: MediaItem)
}

/// Media Library collection view data source base class
class MediaLibraryCollectionViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: - Constants

    private let headerViewReuseIdentifier = "category"
    private let headerViewNibName = String(describing: LibraryCategoryCollectionReusableView.self)

    // MARK: - Properties

    weak var delegate: MediaLibraryCollectionViewDataSourceDelegate?

    fileprivate let downloader: MediaLibraryDownloaderProtocol
    fileprivate let mediaType: MediaType

    /// A two dimensional list of categories and library items
    fileprivate var items = [[MediaItem]]()

    // MARK: - Initializer

    fileprivate init(for mediaType: MediaType, with downloader: MediaLibraryDownloaderProtocol) {
        self.downloader = downloader
        self.mediaType = mediaType
    }

    static func dataSource(for mediaType: MediaType,
                           with downloader: MediaLibraryDownloaderProtocol = MediaLibraryDownloader()) -> MediaLibraryCollectionViewDataSource {
        switch mediaType {
        case .backgrounds, .looks:
            return ImagesLibraryCollectionViewDataSource(for: mediaType, with: downloader)
        case .sounds:
            return SoundsLibraryCollectionViewDataSource(for: mediaType, with: downloader)
        }
    }

    // MARK: - DataSource

    func registerContentViewClasses(_ collectionView: UICollectionView) {
        let headerViewNib = UINib(nibName: self.headerViewNibName, bundle: nil)
        let headerKind = UICollectionElementKindSectionHeader
        let reuseIdentifier = self.headerViewReuseIdentifier
        collectionView.register(headerViewNib, forSupplementaryViewOfKind: headerKind, withReuseIdentifier: reuseIdentifier)
    }

    func fetchItems(completion: @escaping (MediaLibraryDownloadError?) -> Void) {
        self.downloader.downloadIndex(for: self.mediaType) { [weak self] items, error in
            guard let items = items, error == nil else { completion(error); return }
            self?.items = items
            completion(nil)
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.items.count
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: self.headerViewReuseIdentifier, for: indexPath)
        if let headerView = headerView as? LibraryCategoryCollectionReusableView {
            headerView.titleLabel.text = self.items[indexPath.section].first?.category
        }
        return headerView
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items[section].count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("collectionView(_:cellForItemAt:) must be overriden by subclasses")
    }

    func reduceMemoryPressure() { // the method might not be required with thumbnail previews from the API
        ImageCache.default.clearMemoryCache()
        for categoryIndex in 0..<self.items.count {
            for itemIndex in 0..<self.items[categoryIndex].count {
                self.items[categoryIndex][itemIndex].cachedData = nil
            }
        }
    }

    // MARK: - Delegate

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.items[indexPath].cachedData = nil
    }
}

final class ImagesLibraryCollectionViewDataSource: MediaLibraryCollectionViewDataSource {

    // MARK: - Constants

    let imageCellReuseIdentifier = "image"
    let imageCellNibName = String(describing: LibraryImageCollectionViewCell.self)

    // MARK: - DataSource

    override func registerContentViewClasses(_ collectionView: UICollectionView) {
        super.registerContentViewClasses(collectionView)

        let imageCellNib = UINib(nibName: self.imageCellNibName, bundle: nil)
        collectionView.register(imageCellNib, forCellWithReuseIdentifier: self.imageCellReuseIdentifier)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.imageCellReuseIdentifier, for: indexPath)
        if let cell = cell as? LibraryImageCollectionViewCell, let itemIndex = self.items.itemIndex(for: indexPath) {
            cell.tag = itemIndex

            // if image is cached, just display it
            if let data = self.items[indexPath].cachedData, let image = UIImage(data: data) {
                cell.state = .loaded(image: image)
                return cell
            }

            // otherwise fetch the image from cache or library first
            cell.state = .loading
            fetchData(for: self.items[indexPath]) { data in
                // this check is supposed to prevent setting an asynchronously downloaded
                // image into a cell that has already been reused since then
                guard cell.tag == itemIndex else { return }

                if let data = data, let image = UIImage(data: data) {
                    cell.state = .loaded(image: image)
                } else {
                    cell.state = .noImage
                }
            }
        }
        return cell
    }

    // MARK: - Delegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.items[indexPath].cachedData != nil {
            self.delegate?.mediaLibraryCollectionViewDataSource(self, didSelectCellWith: self.items[indexPath])
            return
        }

        // get the image data from the cache or from the library
        fetchData(for: self.items[indexPath]) { [weak self] data in
            guard let `self` = self else { return }
            self.items[indexPath].cachedData = data
            self.delegate?.mediaLibraryCollectionViewDataSource(self, didSelectCellWith: self.items[indexPath])
        }
    }

    // MARK: - Helper Methods

    private func fetchData(for item: MediaItem, completion: @escaping (Data?) -> Void) {
        // try to get the image from cache
        let resource = ImageResource(downloadURL: item.downloadURL)
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
        self.downloader.downloadData(for: item) { data, _ in
            DispatchQueue.main.async { completion(data) }
            if let data = data, let image = UIImage(data: data) {
                ImageCache.default.store(image, original: data, forKey: resource.cacheKey)
            }
        }
    }
}

protocol SoundsLibraryCollectionViewDataSourceDelegate: MediaLibraryCollectionViewDataSourceDelegate {
    func soundsLibraryCollectionViewDataSource(_ dataSource: SoundsLibraryCollectionViewDataSource, didFailToLoadSoundOf item: MediaItem)
    func soundsLibraryCollectionViewDataSource(_ dataSource: SoundsLibraryCollectionViewDataSource, didPlaySoundOf item: MediaItem, completion: (() -> Void)?)
    func soundsLibraryCollectionViewDataSource(_ dataSource: SoundsLibraryCollectionViewDataSource, didStopSoundOf item: MediaItem)
}

final class SoundsLibraryCollectionViewDataSource: MediaLibraryCollectionViewDataSource {

    // MARK: - Constants

    let soundCellReuseIdentifier = "sound"
    let soundCellNibName = String(describing: LibrarySoundCollectionViewCell.self)

    // MARK: - DataSource

    override func registerContentViewClasses(_ collectionView: UICollectionView) {
        super.registerContentViewClasses(collectionView)

        let soundCellNib = UINib(nibName: self.soundCellNibName, bundle: nil)
        collectionView.register(soundCellNib, forCellWithReuseIdentifier: self.soundCellReuseIdentifier)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.soundCellReuseIdentifier, for: indexPath)
        if let cell = cell as? LibrarySoundCollectionViewCell {
            let name = self.items[indexPath].name
            cell.title = name
            cell.tag = self.items.itemIndex(for: indexPath) ?? -1
            cell.delegate = self
        }
        return cell
    }

    // MARK: - Delegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.items[indexPath].cachedData != nil {
            self.delegate?.mediaLibraryCollectionViewDataSource(self, didSelectCellWith: self.items[indexPath])
            return
        }

        // download sound data
        self.downloader.downloadData(for: self.items[indexPath]) { [weak self] data, error in
            guard let `self` = self, let data = data, !data.isEmpty, error == nil else { return }
            self.items[indexPath].cachedData = data
            self.delegate?.mediaLibraryCollectionViewDataSource(self, didSelectCellWith: self.items[indexPath])
        }
    }
}

extension SoundsLibraryCollectionViewDataSource: LibrarySoundCollectionViewCellDelegate {

    func soundLibraryItemCollectionViewCellDidTapPlayOrStop(_ cell: LibrarySoundCollectionViewCell) {
        switch cell.state {
        case .stopped:
            playSound(of: cell)
        case .playing, .preparing:
            stopSound(of: cell)
        }
    }

    private func playSound(of cell: LibrarySoundCollectionViewCell) {
        guard let indexPath = self.items.indexPath(for: cell.tag),
            let delegate = self.delegate as? SoundsLibraryCollectionViewDataSourceDelegate
            else { return }

        if self.items[indexPath].cachedData != nil {
            cell.state = .playing
            delegate.soundsLibraryCollectionViewDataSource(self, didPlaySoundOf: self.items[indexPath]) {
                cell.state = .stopped
            }
            return
        }

        // need to retrieve the data
        cell.state = .preparing
        self.downloader.downloadData(for: self.items[indexPath]) { [weak self] data, error in
            // this check is supposed to prevent changing the state of a cell that is already
            // used by another media item after an asynchronous downloaded finished
            guard let itemIndex = self?.items.itemIndex(for: indexPath), cell.tag == itemIndex else { return }

            cell.state = .playing

            guard let `self` = self else { return }
            guard let data = data, !data.isEmpty, error == nil else {
                cell.state = .stopped
                delegate.soundsLibraryCollectionViewDataSource(self, didFailToLoadSoundOf: self.items[indexPath])
                return
            }

            self.items[indexPath].cachedData = data
            delegate.soundsLibraryCollectionViewDataSource(self, didPlaySoundOf: self.items[indexPath]) {
                cell.state = .stopped
            }
        }
    }

    private func stopSound(of cell: LibrarySoundCollectionViewCell) {
        guard let indexPath = self.items.indexPath(for: cell.tag) else { return }

        cell.state = .stopped
        let mediaType = self.items[indexPath]
        if let delegate = self.delegate as? SoundsLibraryCollectionViewDataSourceDelegate {
            delegate.soundsLibraryCollectionViewDataSource(self, didStopSoundOf: mediaType)
        }
    }
}

extension Array where Iterator.Element == [MediaItem] {

    subscript(indexPath: IndexPath) -> MediaItem {
        get {
            return self[indexPath.section][indexPath.item]
        }
        set {
            self[indexPath.section][indexPath.item] = newValue
        }
    }

    /// Calculates the absolute index of an item within all categories.
    func itemIndex(for indexPath: IndexPath) -> Int? {
        guard indexPath.section >= 0, indexPath.item >= 0 else { return nil }

        // iterate through the two-dim array, sum up the number of items in each
        // category and add the item index as soon as the final category is reached
        var itemIndex = 0
        for sectionIndex in 0..<self.count {
            if sectionIndex < indexPath.section {
                itemIndex += self[sectionIndex].count
                continue
            }
            if indexPath.item < self[sectionIndex].count {
                return itemIndex + indexPath.item
            }
            break
        }
        return nil
    }

    /// Calculates the index path of an item within all categories based on it's absolute index.
    func indexPath(for itemIndex: Int) -> IndexPath? {
        guard itemIndex >= 0 else { return nil }

        // iterate through the two-dim array and subtract the number
        // of items from the item index until the tag becomes zero
        var itemIndex = itemIndex
        for sectionIndex in 0..<self.count {
            if itemIndex >= self[sectionIndex].count {
                itemIndex -= self[sectionIndex].count
                continue
            }
            return IndexPath(item: itemIndex, section: sectionIndex)
        }
        return nil
    }
}
