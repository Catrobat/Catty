/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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

import ActiveLabel
import Foundation
//import UIKit

class ProjectDetailStoreViewController: UIViewController, UIScrollViewDelegate {
    var project: CatrobatProject?
    @IBOutlet weak var scrollViewOutlet: UIScrollView!
    var storeProjectDownloader = StoreProjectDownloader(session: StoreProjectDownloader.defaultSession(), fileManager: CBFileManager.shared())
    var projectManager = ProjectManager.shared
    var projectView: UIView?
    private var loadingView = LoadingView()

    static var height: CGFloat = Util.screenHeight()
    static var inset: CGFloat = 25.0
    static var buttonHeight: CGFloat = 25.0
    static var spaceBetweenButtons: CGFloat = 5.0
    static var labelHeight: CGFloat = 25.0
    static var verticalNameLabelPadding: CGFloat = 5.0
    static var verticalLabelPadding: CGFloat = 10.0
    static var verticalSectionPadding: CGFloat = 20.0
    static var loadingButtonSize: CGFloat = 28.0

    static var fontSizeTitle: CGFloat = 17.0
    static var fontSizeInformationItem: CGFloat = 14.0
    static var fontSizeLabel: CGFloat = 12.0


    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        view.addSubview(loadingView)
        /* original
         - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
         {
             self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
             if (self) {
                 // Custom initialization
             }
             return self;
         }
         */
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        self.hidesBottomBarWhenPushed = true
        self.view.backgroundColor = UIColor.background
        guard project != nil else { return }
        //fatalError(kLocalizedErrorUnknown)
        loadProject(project!)
    }

    func loadProject(_ project: CatrobatProject) {
        guard project != nil else { return }
        guard projectView != nil else { return }

        self.projectView?.removeFromSuperview()
        self.projectView = self.createProjectDetailView(project, target: self)

        if self.project!.author == nil {
            self.showLoadingView()
            let button = self.projectView!.viewWithTag(Int(kDownloadButtonTag)) as! UIButton
            button.isEnabled = false
        }

        self.scrollViewOutlet.addSubview(self.projectView!)
        self.scrollViewOutlet.delegate = self

        self.scrollViewOutlet.contentInsetAdjustmentBehavior = .never
        self.scrollViewOutlet.isUserInteractionEnabled = true
    }

    func initNavigationBar() {
        navigationItem.title = kLocalizedDetails
        title = kLocalizedDetails
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hidesBottomBarWhenPushed = false
        NotificationCenter.default.removeObserver(self)

        /*
         [super viewWillDisappear:animated];
         self.hidesBottomBarWhenPushed = NO;
         [[NSNotificationCenter defaultCenter] removeObserver:self];
         */
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard self.navigationController != nil else {
            return
        }
        self.navigationController!.setToolbarHidden(true, animated: animated)

        /*
         [super viewWillAppear:animated];
         [self.navigationController setToolbarHidden:YES];
         */
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        //[super viewDidAppear:animated];
    }

    func back() {
        guard self.navigationController != nil else {
            return
        }
        self.navigationController!.popViewController(animated: true)

        // [self.navigationController popViewControllerAnimated:YES];
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard project != nil else { return }

        DispatchQueue.main.async(execute: { [self] in
            loadProject(project!)
            view.setNeedsDisplay()
        })

        /*
         -(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self loadProject:self.project];
                 [self.view setNeedsDisplay];
             });
         }
         */
    }

    deinit {
        scrollViewOutlet.removeFromSuperview()

        /*
        - (void)dealloc
        {
            [self setScrollViewOutlet:nil];
        }
         */
    }

    // MARK: Delegates

    @objc func openButtonPressed() {
        guard project != nil else { return }
        guard projectView != nil else { return }

        guard let localProjectNames = self.projectManager.projectNames(for: project!.projectID) else {
            Util.alert(text: kLocalizedUnableToLoadProject)
            return
        }

        if localProjectNames.count > 1 {
            let nameSelectionSheet = UIAlertController(title: kLocalizedOpen, message: nil, preferredStyle: .actionSheet)
            nameSelectionSheet.addAction(title: kLocalizedCancel, style: .cancel, handler: nil)

            for localProjectName in localProjectNames {
                nameSelectionSheet.addAction(title: localProjectName, style: .default, handler: { action in
                    self.openProject(withLocalName: action.title)
                })
            }

            self.present(nameSelectionSheet, animated: true, completion: nil)
        } else {
            openProject(withLocalName: localProjectNames.first)
        }
    }

    @objc func downloadButtonPressed() {
        guard project != nil else { return }
        guard projectView != nil else { return }

        let button = projectView!.viewWithTag(Int(kStopLoadingTag)) as? EVCircularProgressView
        projectView!.viewWithTag(Int(kDownloadButtonTag))?.isHidden = true
        button?.isHidden = false
        button?.progress = 0
        if let duplicateName = Util.uniqueName(project!.name, existingNames: Project.allProjectNames()) {
            download(name: duplicateName)
        }
    }

    @objc func downloadAgain() {
        guard project != nil else { return }
        guard projectView != nil else { return }

        let button = projectView!.viewWithTag(Int(kStopLoadingTag)) as? EVCircularProgressView
        projectView!.viewWithTag(Int(kOpenButtonTag))?.isHidden = true

        let downloadAgainButton = projectView!.viewWithTag(Int(kDownloadAgainButtonTag)) as? UIButton
        downloadAgainButton?.isEnabled = false
        button?.isHidden = false
        button?.progress = 0

        if let duplicateName = Util.uniqueName(project!.name, existingNames: Project.allProjectNames()) {
            download(name: duplicateName)
        }
    }

    func download(name: String) {
        guard project != nil else { return }

        storeProjectDownloader.download(
            projectId: self.project!.projectID,
            projectName: name,
            completion: { _, storeProjectDownloaderError in
                if let error = storeProjectDownloaderError {
                    switch error {
                    case .cancelled:
                        return
                    case .unexpectedError, .timeout:
                        Util.defaultAlertForNetworkError()
                    case .parse(error: _), .request(error: _, statusCode: _):
                        Util.alert(text: kLocalizedInvalidZip)
                    }

                    self.resetDownloadStatus()
                    return
                }

                self.downloadFinished()

            }, progression: { progress in
                self.updateProgress(Double(progress))
                self.reloadInputViews()
            })
    }

    private func downloadFinished() {
        guard project != nil else { return }

        self.project!.isdownloading = false

        if let button = self.view.viewWithTag(Int(kStopLoadingTag)) as? EVCircularProgressView {
            button.isHidden = true
            button.progress = 0
        }

        if let openButton = self.view.viewWithTag(Int(kOpenButtonTag)) {
            openButton.isHidden = false
        }

        if let downloadButton = self.view.viewWithTag(Int(kDownloadAgainButtonTag)) as? UIButton {
            downloadButton.isEnabled = true
            downloadButton.isHidden = false
        }

        Util.setNetworkActivityIndicator(false)
    }

    private func resetDownloadStatus() {
        self.view.viewWithTag(Int(kDownloadButtonTag))?.isHidden = false
        self.view.viewWithTag(Int(kOpenButtonTag))?.isHidden = true
        self.view.viewWithTag(Int(kStopLoadingTag))?.isHidden = true
        self.view.viewWithTag(Int(kDownloadAgainButtonTag))?.isHidden = true

        Util.setNetworkActivityIndicator(false)
    }

    private func updateProgress(_ progress: Double) {
        guard let button = self.view.viewWithTag(Int(kStopLoadingTag)) as? EVCircularProgressView else { return }
        button.setProgress(progress, animated: true)
    }

    // MARK: Loading View

    func showLoadingView() {
        loadingView.show()
    }

    func hideLoadingView() {
        loadingView.isHidden = true
    }



    // MARK: Actions

    func stopLoading() {
        guard project != nil else { return }

        storeProjectDownloader.cancelDownload(for: project!.projectID)

        let button = view.viewWithTag(Int(kStopLoadingTag)) as? EVCircularProgressView
        button?.isHidden = true
        button?.progress = 0

        if let downloadAgainButton = view.viewWithTag(Int(kDownloadAgainButtonTag)) as? UIButton {
            if downloadAgainButton.isEnabled {
                view.viewWithTag(Int(kDownloadAgainButtonTag))?.isHidden = false
            } else {
                view.viewWithTag(Int(kOpenButtonTag))?.isHidden = false
                downloadAgainButton.isEnabled = true
            }
        }

        Util.setNetworkActivityIndicator(false)
    }

    func createProjectDetailView(_ project: CatrobatProject, target: Any?) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: Util.screenWidth(), height: CGFloat.greatestFiniteMagnitude))
        view.backgroundColor = UIColor.clear

        let thumbnailView = self.addThumbnailImage(withImageUrlString: project.screenshotBig, to: view)

        let nameLabel = self.addNameLabel(project.projectName, to: view, thumbnailView: thumbnailView)
        self.addAuthorLabel(withAuthor: project.author, to: view, nameLabel: nameLabel)

        let openButton = self.addOpenButton(to: view, thumbnailView: thumbnailView, withTarget: target)
        self.addLoadingButton(to: view, openButton: openButton, withTarget: target)
        self.addDownloadButton(to: view, thumbnailView: thumbnailView, withTarget: target)
        self.addDownloadAgainButton(to: view, withTarget: target)

        let tagsView = self.addTags(to: view, thumbnailView: thumbnailView)
        let descriptionView = self.addProjectDescriptionLabel(project.projectDescription, to: view, tagsView: tagsView, target: target)

        let lastInformationItem = self.addInformationLabel(to: view, withDescriptionView: descriptionView)

        if Project.projectExists(withProjectID: project.projectID) {
            view.viewWithTag(Int(kDownloadButtonTag))?.isHidden = true
            view.viewWithTag(Int(kOpenButtonTag))?.isHidden = false
            view.viewWithTag(Int(kStopLoadingTag))?.isHidden = true
            view.viewWithTag(Int(kDownloadAgainButtonTag))?.isHidden = false
        } else if project.isdownloading {
            view.viewWithTag(Int(kDownloadButtonTag))?.isHidden = true
            view.viewWithTag(Int(kOpenButtonTag))?.isHidden = true
            view.viewWithTag(Int(kStopLoadingTag))?.isHidden = false
            view.viewWithTag(Int(kDownloadAgainButtonTag))?.isHidden = true
        }

        view.sizeToFit()
        return view
    }

    private func addTags(to view: UIView, thumbnailView: UIView) -> UIView {
        guard project != nil else { fatalError(kLocalizedErrorUnknown) }
        guard projectView != nil else { fatalError(kLocalizedErrorUnknown) }

        let tags = project!.tags ?? []
        let height = !tags.isEmpty ? type(of: self).buttonHeight : 0.0

        let offsetX = thumbnailView.frame.origin.x
        let offsetY = thumbnailView.frame.origin.y + thumbnailView.frame.height + type(of: self).verticalSectionPadding

        let stackView = UIStackView(frame: CGRect(x: offsetX, y: offsetY, width: type(of: self).height, height: height))
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = type(of: self).spaceBetweenButtons

        for tag in tags {
            let tagLabel = setupTagLabel(for: tag)
            stackView.addArrangedSubview(tagLabel)
        }

        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)

        stackView.addArrangedSubview(spacerView)
        view.addSubview(stackView)

        return stackView
    }

    private func setupTagLabel(for tag: String) -> PaddingLabel {
        let tagLabel = PaddingLabel(topInset: 10, bottomInset: 10, leftInset: 10, rightInset: 10)
        tagLabel.text = tag
        tagLabel.backgroundColor = UIColor.textViewBorderGray
        tagLabel.layer.cornerRadius = 12
        tagLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
        tagLabel.layer.masksToBounds = true
        tagLabel.sizeToFit()

        return tagLabel
    }

    private func addNameLabel(_ projectName: String, to view: UIView, thumbnailView: UIView) -> UILabel {
        let offsetX = thumbnailView.frame.origin.x + thumbnailView.frame.width + type(of: self).inset
        let offsetY = thumbnailView.frame.origin.y + type(of: self).verticalNameLabelPadding
        let width = view.frame.size.width - offsetX - type(of: self).inset

        let nameLabel = UILabel(frame: CGRect(x: offsetX, y: offsetY, width: width, height: type(of: self).labelHeight))
        nameLabel.text = projectName
        nameLabel.lineBreakMode = .byWordWrapping
        nameLabel.numberOfLines = 2
        self.configureTitleLabel(nameLabel)

        nameLabel.sizeToFit()
        view.addSubview(nameLabel)

        return nameLabel
    }

    private func addAuthorLabel(withAuthor author: String?, to view: UIView, nameLabel: UILabel) {
        let offsetX = nameLabel.frame.origin.x
        let offsetY = nameLabel.frame.origin.y + nameLabel.frame.height + type(of: self).verticalLabelPadding
        let width = view.frame.width - offsetX - type(of: self).inset

        let authorLabel = UILabel(frame: CGRect(x: offsetX, y: offsetY, width: width, height: type(of: self).labelHeight))
        authorLabel.text = author
        self.configureLabel(authorLabel)
        view.addSubview(authorLabel)
    }

    private func addProjectDescriptionLabel(_ description: String, to view: UIView, tagsView: UIView, target: Any?) -> UIView {
        let lineOffset = tagsView.frame.origin.y + tagsView.frame.size.height + type(of: self).verticalSectionPadding
        let labelOffset = lineOffset + type(of: self).verticalSectionPadding
        let labelWidth = view.frame.size.width - type(of: self).inset * 2

        self.addHorizontalLine(to: view, verticalOffset: lineOffset)

        let descriptionTitleLabel = UILabel(frame: CGRect(x: type(of: self).inset, y: labelOffset, width: labelWidth, height: type(of: self).labelHeight))
        self.configureTitleLabel(descriptionTitleLabel)
        descriptionTitleLabel.text = kLocalizedDescription
        view.addSubview(descriptionTitleLabel)

        var description = description
        description = description.replacingOccurrences(of: "<br>", with: "")
        description = description.replacingOccurrences(of: "<br />", with: "")
        if description.isEmpty {
            description = kLocalizedNoDescriptionAvailable
        }

        let descriptionOffset = descriptionTitleLabel.frame.origin.y + descriptionTitleLabel.frame.height + type(of: self).verticalLabelPadding

        let descriptionLabel = ActiveLabel(frame: CGRect(x: type(of: self).inset, y: descriptionOffset, width: labelWidth, height: CGFloat.greatestFiniteMagnitude))
        self.configureDescriptionLabel(descriptionLabel)
        descriptionLabel.text = description
        view.addSubview(descriptionLabel)

        descriptionLabel.sizeToFit()
        descriptionLabel.frame.origin.y = descriptionOffset

        return descriptionLabel
    }

    private func addThumbnailImage(withImageUrlString imageUrlString: String?, to view: UIView) -> UIImageView {
        let imageView = UIImageView()
        let errorImage = UIImage(named: "thumbnail_large")
        let imageHeightAndWidth = view.frame.size.width / 3
        imageView.frame = CGRect(x: type(of: self).inset, y: type(of: self).inset, width: imageHeightAndWidth, height: imageHeightAndWidth)
        imageView.image = UIImage(
            contentsOf: URL(string: imageUrlString ?? ""),
            placeholderImage: nil,
            errorImage: errorImage,
            onCompletion: { image in
                DispatchQueue.main.async(execute: {
                    imageView.viewWithTag(Int(kActivityIndicator))?.removeFromSuperview()
                    imageView.image = image
                })
            })

        if imageView.image == nil {
            let activity = UIActivityIndicatorView(style: .gray)
            activity.tag = Int(kActivityIndicator)
            activity.frame = CGRect(x: imageView.frame.size.width / 2.0 - type(of: self).buttonHeight / 2.0,
                                    y: imageView.frame.size.height / 2.0 - type(of: self).buttonHeight / 2.0,
                                    width: type(of: self).buttonHeight,
                                    height: type(of: self).buttonHeight)
            imageView.addSubview(activity)
            activity.startAnimating()
        }

        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8.0
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.utilityTint.cgColor
        imageView.layer.borderWidth = 1.0

        view.addSubview(imageView)
        return imageView
    }

    private func addDownloadButton(to view: UIView, thumbnailView: UIView, withTarget target: Any?) {
        let downloadButton = RoundBorderedButton(frame: self.createDownloadAndOpenButtonFrame(view: view, thumbnailView: thumbnailView), andInvertedColor: true) as UIButton
        downloadButton.tag = Int(kDownloadButtonTag)
        downloadButton.setTitle(kLocalizedDownload, for: .normal)
        downloadButton.addTarget(target, action: #selector(downloadButtonPressed), for: .touchUpInside)
        downloadButton.sizeToFit()

        let activity = UIActivityIndicatorView(style: .gray)
        activity.tag = Int(kActivityIndicator)
        activity.frame = CGRect(x: 5, y: 0, width: type(of: self).buttonHeight, height: type(of: self).buttonHeight)
        downloadButton.addSubview(activity)
        view.addSubview(downloadButton)
    }

    private func addOpenButton(to view: UIView, thumbnailView: UIView, withTarget target: Any?) -> UIButton {
        let openButton = RoundBorderedButton(frame: self.createDownloadAndOpenButtonFrame(view: view, thumbnailView: thumbnailView), andInvertedColor: true) as UIButton
        openButton.tag = Int(kOpenButtonTag)
        openButton.setTitle(kLocalizedOpen, for: .normal)
        openButton.addTarget(target, action: #selector(openButtonPressed), for: .touchUpInside)
        openButton.isHidden = true

        openButton.sizeToFit()
        view.addSubview(openButton)

        return openButton
    }

    private func addDownloadAgainButton(to view: UIView, withTarget target: Any?) {
        guard let openButton = view.viewWithTag(Int(kOpenButtonTag)) as? UIButton else { return }
        let openButtonRightBorder = openButton.frame.origin.x + openButton.frame.width
        let maxWidth = view.frame.size.width - openButtonRightBorder - type(of: self).spaceBetweenButtons - type(of: self).inset

        let downloadAgainButton = RoundBorderedButton(frame: self.createDownloadAgainButtonFrame(view: view, openButton: openButton))
        downloadAgainButton.setTitle(kLocalizedDownloadAgain, for: .normal)
        downloadAgainButton.addTarget(target, action: #selector(self.downloadAgain), for: .touchUpInside)
        downloadAgainButton.tag = Int(kDownloadAgainButtonTag)
        downloadAgainButton.isHidden = true
        downloadAgainButton.sizeToFit()

        if downloadAgainButton.frame.size.width > maxWidth {
            downloadAgainButton.frame.size.width = maxWidth
        }

        view.addSubview(downloadAgainButton)
    }


    private func addLoadingButton(to view: UIView, openButton: UIButton, withTarget target: Any?) {
        let button = EVCircularProgressView()
        button.tag = Int(kStopLoadingTag)
        button.tintColor = UIColor.buttonTint
        button.frame = self.createLoadingButtonFrame(view: view, openButton: openButton)
        button.isHidden = true
        button.addTarget(target, action: #selector(URLProtocol.stopLoading), for: .touchUpInside)
        view.addSubview(button)
    }

    private func addInformationLabel(to view: UIView, withDescriptionView descriptionView: UIView) -> UILabel {
        guard project != nil else { fatalError(kLocalizedErrorUnknown) }

        let projectDouble = (project!.uploaded as NSString).doubleValue
        let projectDate = Date(timeIntervalSince1970: TimeInterval(projectDouble))
        let uploaded = CatrobatProject.uploadDateFormatter().string(from: projectDate)
        let views = project!.views
        let downloads = project!.downloads
        var size = project!.size

        let offsetLine = descriptionView.frame.origin.y + descriptionView.frame.size.height + type(of: self).verticalSectionPadding
        let offsetLabel = offsetLine + type(of: self).verticalSectionPadding

        self.addHorizontalLine(to: view, verticalOffset: offsetLine)

        let informationLabel = UILabel(frame: CGRect(x: type(of: self).inset, y: offsetLabel, width: view.frame.width, height: type(of: self).labelHeight))
        informationLabel.text = kLocalizedInformation
        self.configureTitleLabel(informationLabel)
        view.addSubview(informationLabel)

        var offset = informationLabel.frame.origin.y + informationLabel.frame.height + type(of: self).verticalSectionPadding
        let height = type(of: self).buttonHeight

        size = size?.replacingOccurrences(of: "&lt;", with: "")
        size = (size ?? "") + " MB"

        let informationArray = [views?.stringValue ?? "", uploaded, size, downloads?.stringValue ?? ""]
        let informationTitleArray = [UIImage(named: "viewsIcon"), UIImage(named: "timeIcon"), UIImage(named: "sizeIcon"), UIImage(named: "downloadIcon")]
        var lastItem = informationLabel

        for (index, info) in informationArray.enumerated() {
            let titleIcon = self.getInformationTitleLabel(withTitle: informationTitleArray[index], atXPosition: type(of: self).inset, atYPosition: offset, andHeight: height)
            view.addSubview(titleIcon)

            let infoLabel = self.getInformationDetailLabel(withTitle: info, atXPosition: type(of: self).inset * 2, atYPosition: offset - 1, andHeight: height)
            view.addSubview(infoLabel)
            lastItem = infoLabel

            offset += height + type(of: self).spaceBetweenButtons
        }

        return lastItem
    }

    private func addHorizontalLine(to view: UIView, verticalOffset: CGFloat) {
        let width = view.frame.size.width - type(of: self).inset * 2
        let lineView = UIView(frame: CGRect(x: type(of: self).inset, y: verticalOffset, width: width, height: 1))
        lineView.backgroundColor = UIColor.utilityTint
        view.addSubview(lineView)
    }

    private func configureTitleLabel(_ label: UILabel) {
        label.backgroundColor = UIColor.clear
        label.font = UIFont.boldSystemFont(ofSize: type(of: self).fontSizeTitle)
        label.textColor = UIColor.globalTint
        label.layer.shadowColor = UIColor.white.cgColor
        label.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    }

    private func configureLabel(_ label: UILabel) {
        label.backgroundColor = UIColor.clear
        label.font = UIFont.boldSystemFont(ofSize: type(of: self).fontSizeLabel)
        label.textColor = UIColor.textTint
        label.layer.shadowColor = UIColor.white.cgColor
        label.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    }

    private func getInformationTitleLabel(withTitle icon: UIImage?, atXPosition xPosition: CGFloat, atYPosition yPosition: CGFloat, andHeight height: CGFloat) -> UIImageView {
        let titleInformation = UIImageView(frame: CGRect(x: xPosition, y: yPosition, width: 15, height: 15))
        titleInformation.image = icon

        return titleInformation
    }

    private func getInformationDetailLabel(withTitle title: String?, atXPosition xPosition: CGFloat, atYPosition yPosition: CGFloat, andHeight height: CGFloat) -> UILabel {
        let detailInformationLabel = UILabel(frame: CGRect(x: xPosition, y: yPosition, width: 155, height: type(of: self).labelHeight))
        detailInformationLabel.text = title?.stringByEscapingHTMLEntities()
        detailInformationLabel.textColor = UIColor.textTint
        detailInformationLabel.font = UIFont.systemFont(ofSize: type(of: self).fontSizeInformationItem)

        detailInformationLabel.backgroundColor = UIColor.clear
        detailInformationLabel.sizeToFit()
        return detailInformationLabel
    }

    private func configureDescriptionLabel(_ label: ActiveLabel) {
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 0
        self.configureLabel(label)
        label.enabledTypes = [.url]
        label.URLColor = UIColor.navBar
        label.URLSelectedColor = UIColor.navTint

        label.handleURLTap { url in UIApplication.shared.open(url, options: [:], completionHandler: nil) }
    }

    private func openProject(withLocalName localProjectName: String?) {
        guard project != nil else { return }
        showLoadingView()

        DispatchQueue.global(qos: .userInitiated).async {
            guard let selectedProject = Project.init(loadingInfo: ProjectLoadingInfo.init(forProjectWithName: localProjectName, projectID: self.project!.projectID)) else {
                DispatchQueue.main.async {
                    self.hideLoadingView()
                    Util.alert(text: kLocalizedUnableToLoadProject)
                }
                return
            }

            DispatchQueue.main.async {
                self.hideLoadingView()
                self.openProject(selectedProject)
            }
        }
    }

    private func createDownloadAndOpenButtonFrame(view: UIView, thumbnailView: UIView) -> CGRect {
        let offsetX = thumbnailView.frame.origin.x + thumbnailView.frame.width + type(of: self).inset
        let offsetY = thumbnailView.frame.origin.y + thumbnailView.frame.size.height - type(of: self).buttonHeight - type(of: self).verticalNameLabelPadding - 2

        return CGRect(x: offsetX, y: offsetY, width: view.frame.size.width, height: type(of: self).buttonHeight)
    }

    private func createDownloadAgainButtonFrame(view: UIView, openButton: UIButton) -> CGRect {
        let offsetX = openButton.frame.origin.x + openButton.frame.width + type(of: self).spaceBetweenButtons
        let offsetY = openButton.frame.origin.y

        return CGRect(x: offsetX, y: offsetY, width: view.frame.size.width, height: type(of: self).buttonHeight)
    }

    private func createLoadingButtonFrame(view: UIView, openButton: UIButton) -> CGRect {
        let offsetX = openButton.frame.origin.x + openButton.frame.width / 2 - type(of: self).loadingButtonSize / 2
        let offsetY = openButton.frame.origin.y

        return CGRect(x: offsetX, y: offsetY, width: type(of: self).loadingButtonSize, height: type(of: self).loadingButtonSize)
    }

}
