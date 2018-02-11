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

protocol MediaLibraryViewControllerImportDelegate: class {
    func mediaLibraryViewController(_ mediaLibraryViewController: MediaLibraryViewController, didPickItemsForImport items: [MediaItem])
}

final class MediaLibraryViewController: UICollectionViewController {

    // MARK: - Constants

    private let itemSize = CGSize(width: 80, height: 80)
    private let headerHeight: CGFloat = 59
    private let minimumSpacing: CGFloat = 10

    // MARK: - Properties

    weak var importDelegate: MediaLibraryViewControllerImportDelegate?

    private let dataSource: MediaLibraryCollectionViewDataSource
    private weak var loadingView: LoadingView!
    private var originalAudioSessionCategory: String?
    private var originalAudioSessionCategoryOptions: AVAudioSessionCategoryOptions?

    private var audioPlayer: AVAudioPlayer?
    private var audioPlayerDelegate: AudioPlayerFinishPlayingCompletionCaller?

    // MARK: - Initializers

    init(for mediaType: MediaType) {
        self.dataSource = MediaLibraryCollectionViewDataSource.dataSource(for: mediaType)
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        self.dataSource.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = kLocalizedMediaLibrary
        setupLoadingView()
        setupCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCollectionViewLayout()
        fetchData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableSoundInSilentMode()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        undoEnableSoundInSilentMode()
    }

    override func didReceiveMemoryWarning() {
        self.dataSource.reduceMemoryPressure()
        super.didReceiveMemoryWarning()
    }

    // MARK: - Helper Methods

    private func setupLoadingView() {
        let loadingView = LoadingView() // helper variable due to self.loadingView being a weak property
        self.loadingView = loadingView
        self.view.addSubview(loadingView)
    }

    private func setupCollectionView() {
        guard let collectionView = self.collectionView else { fatalError("unexpected view setup") }

        self.dataSource.registerContentViewClasses(collectionView)
        collectionView.dataSource = self.dataSource
        collectionView.delegate = self.dataSource
        collectionView.backgroundColor = .white
    }

    private func setupCollectionViewLayout() {
        guard let collectionView = self.collectionView, let layout = self.collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("unexpected collection view layout")
        }

        // subtract left and right spacing
        let availableWidth = collectionView.frame.width - 2 * self.minimumSpacing
        // calculate the number of columns
        let columnCount = (availableWidth / (self.itemSize.width + self.minimumSpacing)).rounded()
        // calculate the spacing between all items and use it as left and right spacing as well
        let spacing = (collectionView.frame.width - columnCount * self.itemSize.width) / (columnCount + 1)

        // apply sizes
        layout.headerReferenceSize = CGSize(width: collectionView.frame.width, height: self.headerHeight)
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.itemSize = self.itemSize
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
    }

    private func fetchData() {
        self.loadingView.show()
        self.dataSource.fetchItems { [weak self] error in
            self?.loadingView.hide()
            if let error = error {
                self?.showConnectionIssueAlertAndDismiss(error: error)
                return
            }
            self?.collectionView?.reloadData()
        }
    }

    private func showConnectionIssueAlertAndDismiss(error: MediaLibraryDownloadError) {
        let title = kLocalizedMediaLibraryConnectionIssueTitle
        let message = kLocalizedMediaLibraryConnectionIssueMessage
        let buttonTitle = kLocalizedOK

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(title: buttonTitle, style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        self.present(alertController, animated: true, completion: nil)
    }
}

extension MediaLibraryViewController: MediaLibraryCollectionViewDataSourceDelegate {
    func mediaLibraryCollectionViewDataSource(_ dataSource: MediaLibraryCollectionViewDataSource, didSelectCellWith item: MediaItem) {
        self.navigationController?.popViewController(animated: true)
        self.importDelegate?.mediaLibraryViewController(self, didPickItemsForImport: [item])
    }
}

extension MediaLibraryViewController: SoundsLibraryCollectionViewDataSourceDelegate {

    func soundsLibraryCollectionViewDataSource(_ dataSource: SoundsLibraryCollectionViewDataSource, didFailToLoadSoundOf item: MediaItem) {
        self.showSoundLoadingIssueAlert()
    }

    func soundsLibraryCollectionViewDataSource(_ dataSource: SoundsLibraryCollectionViewDataSource, didPlaySoundOf item: MediaItem, completion: (() -> Void)?) {
        guard let data = item.cachedData else { return }

        self.audioPlayer?.stop()
        do {
            let audioPlayerDelegate = AudioPlayerFinishPlayingCompletionCaller(completion)
            let audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer.delegate = audioPlayerDelegate
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            self.audioPlayer = audioPlayer
            self.audioPlayerDelegate = audioPlayerDelegate
        } catch {
            self.showSoundPlayingIssueAlert(error: error)
        }
    }

    func soundsLibraryCollectionViewDataSource(_ dataSource: SoundsLibraryCollectionViewDataSource, didStopSoundOf item: MediaItem) {
        self.audioPlayer?.stop()
        self.audioPlayer = nil
    }

    class AudioPlayerFinishPlayingCompletionCaller: NSObject, AVAudioPlayerDelegate {
        let completion: (() -> Void)?

        init(_ completion: (() -> Void)?) {
            self.completion = completion
        }

        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            self.completion?()
        }
    }

    private func showSoundLoadingIssueAlert() {
        let title = kLocalizedMediaLibrarySoundLoadFailureTitle
        let message = kLocalizedMediaLibrarySoundLoadFailureMessage
        let buttonTitle = kLocalizedOK

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(title: buttonTitle, style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        self.present(alertController, animated: true, completion: nil)
    }

    private func showSoundPlayingIssueAlert(error: Error) {
        let title = kLocalizedMediaLibrarySoundPlayFailureTitle
        let message = kLocalizedMediaLibrarySoundPlayFailureMessage
        let buttonTitle = kLocalizedOK

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(title: buttonTitle, style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        self.present(alertController, animated: true, completion: nil)
    }
}

extension MediaLibraryViewController {
    private func enableSoundInSilentMode() {
        let sharedAudioSession = AVAudioSession.sharedInstance()
        self.originalAudioSessionCategory = sharedAudioSession.category
        self.originalAudioSessionCategoryOptions = sharedAudioSession.categoryOptions
        try? sharedAudioSession.setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
    }

    private func undoEnableSoundInSilentMode() {
        if let category = self.originalAudioSessionCategory, let options = self.originalAudioSessionCategoryOptions {
            let sharedAudioSession = AVAudioSession.sharedInstance()
            try? sharedAudioSession.setCategory(category, with: options)
        }
    }
}
