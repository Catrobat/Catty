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

import XCTest
@testable import Pocket_Code
import Kingfisher

private let exampleData = Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAEElEQVR42gEFAPr/AP////8J+wP9vTv7fQAAAABJRU5ErkJggg==")! // 1x1 png image

class MediaLibraryCollectionViewDataSourceTests: XCTestCase {

    let exampleCategories = [
        [MediaItem(name: "a", category: "A", cachedData: exampleData)],
        [MediaItem(category: "B"), MediaItem(category: "B")],
        [MediaItem(category: "C"), MediaItem(category: "C"), MediaItem(category: "C")]
    ]

    var downloaderMock: MediaLibraryDownloaderMock!
    var collectionView: UICollectionView!
    
    override func setUp() {
        super.setUp()
        self.downloaderMock = MediaLibraryDownloaderMock()
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    override func tearDown() {
        self.downloaderMock = nil
        self.collectionView = nil
        super.tearDown()
    }

    // MARK: - MediaLibraryCollectionViewDataSource Tests

    func testItemsNotFetched() {
        let dataSource = MediaLibraryCollectionViewDataSource.dataSource(for: .looks, with: self.downloaderMock)
        XCTAssertEqual(dataSource.numberOfSections(in: self.collectionView), 0)
    }

    func testItemsEmpty() {
        self.downloaderMock.categories = []
        let dataSource = MediaLibraryCollectionViewDataSource.dataSource(for: .looks, with: self.downloaderMock)
        let expectation = XCTestExpectation(description: "Fetch items from data source")

        dataSource.fetchItems { [unowned self] error in
            XCTAssertNil(error)
            XCTAssertEqual(dataSource.numberOfSections(in: self.collectionView), 0)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testSectionAndItemCount() {
        self.downloaderMock.categories = self.exampleCategories
        let dataSource = MediaLibraryCollectionViewDataSource.dataSource(for: .looks, with: self.downloaderMock)
        let expectation = XCTestExpectation(description: "Fetch items from data source")

        dataSource.fetchItems { [unowned self] error in
            XCTAssertNil(error)
            XCTAssertEqual(dataSource.numberOfSections(in: self.collectionView), 3)
            XCTAssertEqual(dataSource.collectionView(self.collectionView, numberOfItemsInSection: 0), 1)
            XCTAssertEqual(dataSource.collectionView(self.collectionView, numberOfItemsInSection: 1), 2)
            XCTAssertEqual(dataSource.collectionView(self.collectionView, numberOfItemsInSection: 2), 3)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testHeaderViewTitle() {
        guard #available(iOS 11, *) else { return }

        self.downloaderMock.categories = self.exampleCategories
        let dataSource = MediaLibraryCollectionViewDataSource.dataSource(for: .looks, with: self.downloaderMock)
        self.collectionView.dataSource = dataSource
        dataSource.registerContentViewClasses(self.collectionView)
        let expectation = XCTestExpectation(description: "Fetch items from data source")

        dataSource.fetchItems { [unowned self] error in
            XCTAssertNil(error)
            self.collectionView.layoutSubviews()
            self.collectionView.reloadData()

            let headerKind = UICollectionElementKindSectionHeader
            var view = dataSource.collectionView(self.collectionView, viewForSupplementaryElementOfKind: headerKind, at: IndexPath(item: 0, section: 0)) as! LibraryCategoryCollectionReusableView
            XCTAssertEqual(view.titleLabel.text, "A")

            view = dataSource.collectionView(self.collectionView, viewForSupplementaryElementOfKind: headerKind, at: IndexPath(item: 0, section: 1)) as! LibraryCategoryCollectionReusableView
            XCTAssertEqual(view.titleLabel.text, "B")

            view = dataSource.collectionView(self.collectionView, viewForSupplementaryElementOfKind: headerKind, at: IndexPath(item: 0, section: 2)) as! LibraryCategoryCollectionReusableView
            XCTAssertEqual(view.titleLabel.text, "C")

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - ImagesLibraryCollectionViewDataSource

    func testImageCellContentFromCachedData() {
        self.downloaderMock.categories = self.exampleCategories
        let dataSource = MediaLibraryCollectionViewDataSource.dataSource(for: .looks, with: self.downloaderMock)
        self.collectionView.dataSource = dataSource
        dataSource.registerContentViewClasses(self.collectionView)
        let expectation = XCTestExpectation(description: "Fetch items from data source")

        dataSource.fetchItems { [unowned self] _ in
            self.collectionView.layoutSubviews()
            self.collectionView.reloadData()

            let cell = dataSource.collectionView(self.collectionView, cellForItemAt: IndexPath(item: 0, section: 0)) as! LibraryImageCollectionViewCell
            XCTAssertEqual(cell.state, .loaded(image: UIImage()), "cached image not loaded in cell") // the actual image is ignored, see the Equatable extension
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testImageCellContentFromMediaLibrary() {
        clearKingfisherCache()
        self.downloaderMock.categories = self.exampleCategories
        self.downloaderMock.data = exampleData
        let dataSource = MediaLibraryCollectionViewDataSource.dataSource(for: .looks, with: self.downloaderMock)
        self.collectionView.dataSource = dataSource
        dataSource.registerContentViewClasses(self.collectionView)
        let expectation = XCTestExpectation(description: "Fetch items from data source")

        dataSource.fetchItems { [unowned self] _ in
            self.collectionView.layoutSubviews()
            self.collectionView.reloadData()

            // Kingfisher cache is clear, the image will be fetched from the library
            let cell = dataSource.collectionView(self.collectionView, cellForItemAt: IndexPath(item: 0, section: 1)) as! LibraryImageCollectionViewCell
            XCTAssertEqual(cell.state, .loading, "cell doesn't show loading state")

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                XCTAssertEqual(cell.state, .loaded(image: UIImage()), "cached image not loaded in cell") // the actual image is ignored, see the Equatable extension
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testImageCellFetchesContentFromKingfisherCache() {
        self.downloaderMock.categories = self.exampleCategories
        let dataSource = MediaLibraryCollectionViewDataSource.dataSource(for: .looks, with: self.downloaderMock)
        self.collectionView.dataSource = dataSource
        dataSource.registerContentViewClasses(self.collectionView)

        // store image in cache
        let indexPath = IndexPath(item: 0, section: 1)
        let resource = ImageResource(downloadURL: self.exampleCategories[indexPath].downloadURL)
        ImageCache.default.store(UIImage(data: exampleData)!, forKey: resource.cacheKey)

        let expectation = XCTestExpectation(description: "Fetch looks")

        dataSource.fetchItems { [unowned self] _ in
            self.collectionView.layoutSubviews()
            self.collectionView.reloadData()

            // Kingfisher cache is clear, the image will be fetched from the library
            let cell = dataSource.collectionView(self.collectionView, cellForItemAt: indexPath) as! LibraryImageCollectionViewCell
            XCTAssertEqual(cell.state, .loading, "cell doesn't show loading state")

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                XCTAssertEqual(cell.state, .loaded(image: UIImage()), "cached image not loaded in cell") // the actual image is ignored, see the Equatable extension
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testSelectingImageCellProvidesCachedData() {
        clearKingfisherCache()
        self.downloaderMock.categories = self.exampleCategories
        self.downloaderMock.data = exampleData
        let dataSource = MediaLibraryCollectionViewDataSource.dataSource(for: .looks, with: self.downloaderMock) as! ImagesLibraryCollectionViewDataSource
        self.collectionView.dataSource = dataSource
        dataSource.registerContentViewClasses(self.collectionView)
        populateCollectionView(dataSource)

        // cached data in media item
        var expectation = XCTestExpectation(description: "Selecting cell triggers delegate method with media item and cached data")
        var delegateMock = MediaLibraryCollectionViewDataSourceDelegateMock(didSelectCell: { mediaItem in
            XCTAssertNotNil(mediaItem.cachedData)
            expectation.fulfill()
        })
        dataSource.delegate = delegateMock
        dataSource.collectionView(self.collectionView, didSelectItemAt: IndexPath(item: 0, section: 0))
        wait(for: [expectation], timeout: 1.0)

        // data retrieved from media library
        expectation = XCTestExpectation(description: "Selecting cell downloads data and provides it in the delegate call")
        delegateMock = MediaLibraryCollectionViewDataSourceDelegateMock(didSelectCell: { mediaItem in
            XCTAssertNotNil(mediaItem.cachedData)
            expectation.fulfill()
        })
        dataSource.delegate = delegateMock
        dataSource.collectionView(self.collectionView, didSelectItemAt: IndexPath(item: 0, section: 1))
        wait(for: [expectation], timeout: 1.0)

        // data retrieved from Kingfisher cache
        self.downloaderMock.data = nil
        expectation = XCTestExpectation(description: "Selecting cell fetches data from cache and provides it in the delegate call")
        delegateMock = MediaLibraryCollectionViewDataSourceDelegateMock(didSelectCell: { mediaItem in
            XCTAssertNotNil(mediaItem.cachedData)
            expectation.fulfill()
        })
        dataSource.delegate = delegateMock
        dataSource.collectionView(self.collectionView, didSelectItemAt: IndexPath(item: 0, section: 1))
        wait(for: [expectation], timeout: 1.0)
    }

    func testImageCellClearCacheAfterBeingHidden() {
        self.downloaderMock.categories = self.exampleCategories
        let dataSource = MediaLibraryCollectionViewDataSource.dataSource(for: .looks, with: self.downloaderMock)
        self.collectionView.dataSource = dataSource
        dataSource.registerContentViewClasses(self.collectionView)
        populateCollectionView(dataSource)

        let indexPath = IndexPath(item: 0, section: 0)
        var cell = dataSource.collectionView(self.collectionView, cellForItemAt: indexPath) as! LibraryImageCollectionViewCell
        XCTAssertEqual(cell.state, .loaded(image: UIImage()), "cached image not loaded in cell") // the actual image is ignored, see the Equatable extension

        clearKingfisherCache()
        dataSource.collectionView(self.collectionView, didEndDisplaying: cell, forItemAt: indexPath)
        cell = dataSource.collectionView(self.collectionView, cellForItemAt: indexPath) as! LibraryImageCollectionViewCell
        XCTAssertEqual(cell.state, .loading)
    }

    // MARK: - SoundsLibraryCollectionViewDataSource

    func testSoundCellStateAndTitle() {
        self.downloaderMock.categories = self.exampleCategories
        let dataSource = MediaLibraryCollectionViewDataSource.dataSource(for: .sounds, with: self.downloaderMock)
        self.collectionView.dataSource = dataSource
        dataSource.registerContentViewClasses(self.collectionView)
        let expectation = XCTestExpectation(description: "Fetch sounds")

        dataSource.fetchItems { [unowned self] _ in
            self.collectionView.layoutSubviews()
            self.collectionView.reloadData()

            let cell = dataSource.collectionView(self.collectionView, cellForItemAt: IndexPath(item: 0, section: 0)) as! LibrarySoundCollectionViewCell
            XCTAssertEqual(cell.title, "a")
            XCTAssertEqual(cell.state, .stopped, "cell not in stopped state")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testSoundCellPlayAndStopCachedSound() {
        self.downloaderMock.categories = self.exampleCategories
        let dataSource = MediaLibraryCollectionViewDataSource.dataSource(for: .sounds, with: self.downloaderMock)
        self.collectionView.dataSource = dataSource
        dataSource.registerContentViewClasses(self.collectionView)
        populateCollectionView(dataSource)

        let cell = dataSource.collectionView(self.collectionView, cellForItemAt: IndexPath(item: 0, section: 0)) as! LibrarySoundCollectionViewCell
        let delegateMock = SoundsLibraryCollectionViewDataSourceDelegateMock()
        dataSource.delegate = delegateMock

        XCTAssertEqual(cell.state, .stopped)
        cell.playOrStop()
        XCTAssertEqual(cell.state, .playing)
        cell.playOrStop()
        XCTAssertEqual(cell.state, .stopped)
    }

    func testSoundCellFinishPlayReturnsToStoppedState() {
        self.downloaderMock.categories = self.exampleCategories
        let dataSource = MediaLibraryCollectionViewDataSource.dataSource(for: .sounds, with: self.downloaderMock)
        self.collectionView.dataSource = dataSource
        dataSource.registerContentViewClasses(self.collectionView)
        populateCollectionView(dataSource)

        let cell = dataSource.collectionView(self.collectionView, cellForItemAt: IndexPath(item: 0, section: 0)) as! LibrarySoundCollectionViewCell
        let delegateMock = SoundsLibraryCollectionViewDataSourceDelegateMock(didPlaySound: { _, completion in
            completion?() // finish immediately
        })
        dataSource.delegate = delegateMock

        XCTAssertEqual(cell.state, .stopped)
        cell.playOrStop() // will immediately finish
        XCTAssertEqual(cell.state, .stopped)
    }

    func testSoundCellFailToFetchSound() {
        self.downloaderMock.categories = self.exampleCategories
        let dataSource = MediaLibraryCollectionViewDataSource.dataSource(for: .sounds, with: self.downloaderMock)
        self.collectionView.dataSource = dataSource
        dataSource.registerContentViewClasses(self.collectionView)
        populateCollectionView(dataSource)

        let expectation = XCTestExpectation(description: "reach state .playing after sound is fetched")
        let delegateMock = SoundsLibraryCollectionViewDataSourceDelegateMock(didFailToLoadSound: { _ in
            expectation.fulfill()
        })
        dataSource.delegate = delegateMock

        let cell = dataSource.collectionView(self.collectionView, cellForItemAt: IndexPath(item: 0, section: 1)) as! LibrarySoundCollectionViewCell
        XCTAssertEqual(cell.state, .stopped)
        cell.playOrStop()
        XCTAssertEqual(cell.state, .preparing)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(cell.state, .stopped)
    }

    func testSoundCellFetchAndPlaySound() {
        self.downloaderMock.categories = self.exampleCategories
        self.downloaderMock.data = exampleData
        let dataSource = MediaLibraryCollectionViewDataSource.dataSource(for: .sounds, with: self.downloaderMock)
        self.collectionView.dataSource = dataSource
        dataSource.registerContentViewClasses(self.collectionView)
        populateCollectionView(dataSource)

        let expectation0 = XCTestExpectation(description: "reach state .playing after sound is fetched")
        let expectation1 = XCTestExpectation(description: "reach state .stopped after sound is fetched and finished playing")
        let delegateMock = SoundsLibraryCollectionViewDataSourceDelegateMock(didPlaySound: { _, completion in
            expectation0.fulfill()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                completion?()
                expectation1.fulfill()
            }
        })
        dataSource.delegate = delegateMock

        let cell = dataSource.collectionView(self.collectionView, cellForItemAt: IndexPath(item: 0, section: 1)) as! LibrarySoundCollectionViewCell
        XCTAssertEqual(cell.state, .stopped)
        cell.playOrStop()
        XCTAssertEqual(cell.state, .preparing)
        wait(for: [expectation0], timeout: 1.0)
        XCTAssertEqual(cell.state, .playing)
        wait(for: [expectation1], timeout: 1.0)
        XCTAssertEqual(cell.state, .stopped)
    }

    func testSelectingSoundCellProvidesCachedData() {
        self.downloaderMock.categories = self.exampleCategories
        self.downloaderMock.data = exampleData
        let dataSource = MediaLibraryCollectionViewDataSource.dataSource(for: .sounds, with: self.downloaderMock) as! SoundsLibraryCollectionViewDataSource
        self.collectionView.dataSource = dataSource
        dataSource.registerContentViewClasses(self.collectionView)
        populateCollectionView(dataSource)

        // cached data in media item
        var expectation = XCTestExpectation(description: "Selecting cell triggers delegate method with media item and cached data")
        var delegateMock = MediaLibraryCollectionViewDataSourceDelegateMock(didSelectCell: { mediaItem in
            XCTAssertNotNil(mediaItem.cachedData)
            expectation.fulfill()
        })
        dataSource.delegate = delegateMock
        dataSource.collectionView(self.collectionView, didSelectItemAt: IndexPath(item: 0, section: 0))
        wait(for: [expectation], timeout: 1.0)

        // data retrieved from media library
        expectation = XCTestExpectation(description: "Selecting cell downloads data and provides it in the delegate call")
        delegateMock = SoundsLibraryCollectionViewDataSourceDelegateMock(didSelectCell: { mediaItem in
            XCTAssertNotNil(mediaItem.cachedData)
            expectation.fulfill()
        })
        dataSource.delegate = delegateMock
        dataSource.collectionView(self.collectionView, didSelectItemAt: IndexPath(item: 0, section: 1))
        wait(for: [expectation], timeout: 1.0)
    }

    // MARK: - Extension

    func testItemIndex() {
        // out of lower bounds
        XCTAssertNil(self.exampleCategories.itemIndex(for: IndexPath(item: -1, section: 0)))
        XCTAssertNil(self.exampleCategories.itemIndex(for: IndexPath(item: 0, section: -1)))
        XCTAssertNil(self.exampleCategories.itemIndex(for: IndexPath(item: -1, section: -1)))

        // sequential item indexes and out of bounds
        XCTAssertEqual(self.exampleCategories.itemIndex(for: IndexPath(item: 0, section: 0)), 0)
        XCTAssertNil(self.exampleCategories.itemIndex(for: IndexPath(item: 1, section: 0)))
        XCTAssertEqual(self.exampleCategories.itemIndex(for: IndexPath(item: 0, section: 1)), 1)
        XCTAssertEqual(self.exampleCategories.itemIndex(for: IndexPath(item: 1, section: 1)), 2)
        XCTAssertNil(self.exampleCategories.itemIndex(for: IndexPath(item: 2, section: 1)))
        XCTAssertEqual(self.exampleCategories.itemIndex(for: IndexPath(item: 0, section: 2)), 3)
        XCTAssertEqual(self.exampleCategories.itemIndex(for: IndexPath(item: 1, section: 2)), 4)
        XCTAssertEqual(self.exampleCategories.itemIndex(for: IndexPath(item: 2, section: 2)), 5)

        // out of upper bounds
        XCTAssertNil(self.exampleCategories.itemIndex(for: IndexPath(item: 3, section: 2)))
        XCTAssertNil(self.exampleCategories.itemIndex(for: IndexPath(item: 0, section: 3)))
    }

    func testIndexPath() {
        XCTAssertNil(self.exampleCategories.indexPath(for: -1))
        XCTAssertEqual(self.exampleCategories.indexPath(for: 0), IndexPath(item: 0, section: 0))
        XCTAssertEqual(self.exampleCategories.indexPath(for: 1), IndexPath(item: 0, section: 1))
        XCTAssertEqual(self.exampleCategories.indexPath(for: 2), IndexPath(item: 1, section: 1))
        XCTAssertEqual(self.exampleCategories.indexPath(for: 3), IndexPath(item: 0, section: 2))
        XCTAssertEqual(self.exampleCategories.indexPath(for: 4), IndexPath(item: 1, section: 2))
        XCTAssertEqual(self.exampleCategories.indexPath(for: 5), IndexPath(item: 2, section: 2))
        XCTAssertNil(self.exampleCategories.indexPath(for: 6))
    }

    // MARK: - Helper Methods

    private func clearKingfisherCache() {
        let expectation = XCTestExpectation(description: "Clear Kingfisher cache")
        ImageCache.default.clearMemoryCache()
        ImageCache.default.clearDiskCache {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    private func populateCollectionView(_ dataSource: MediaLibraryCollectionViewDataSource) {
        let expectation = XCTestExpectation(description: "Fetch items")
        dataSource.fetchItems { [unowned self] _ in
            self.collectionView.layoutSubviews()
            self.collectionView.reloadData()
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Extensions

private extension MediaItem {
    init(name: String = "", fileExtension: String = "", category: String = "", relativePath: String = "", cachedData: Data? = nil) {
        self.name = name
        self.fileExtension = fileExtension
        self.category = category
        self.relativePath = relativePath
        self.cachedData = cachedData
    }
}

// Equatable conformance is added here in order to be able to check a cell's state easily. The image of the
// state .loaded is not taken into conisderation.
extension LibraryImageCollectionViewCell.State: Equatable {
    public static func ==(lhs: LibraryImageCollectionViewCell.State, rhs: LibraryImageCollectionViewCell.State) -> Bool {
        switch (lhs, rhs) {
        case (.noImage, .noImage), (.loading, .loading), (.loaded, .loaded):
            return true
        default:
            return false
        }
    }
}
