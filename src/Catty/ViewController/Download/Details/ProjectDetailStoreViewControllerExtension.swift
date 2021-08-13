/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

@objc extension ProjectDetailStoreViewController {

    static var height: CGFloat = Util.screenHeight()
    static var marginLeftPercentage: CGFloat = 15.0

    func createProjectDetailView(_ project: CatrobatProject, target: Any?) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: Util.screenWidth(), height: 0))
        view.backgroundColor = UIColor.clear
        view.autoresizingMask = .flexibleHeight
        self.addNameLabel(withProjectName: project.projectName, to: view)
        self.addAuthorLabel(withAuthor: project.author, to: view)
        self.addThumbnailImage(withImageUrlString: project.screenshotSmall, to: view)
        self.addDownloadButton(to: view, withTarget: target)
        self.addLoadingButton(to: view, withTarget: target)
        self.addOpenButton(to: view, withTarget: target)
        self.addDownloadAgainButton(to: view, withTarget: target)
        _ = self.addProjectDescriptionLabel(withDescription: project.projectDescription, to: view, target: target)
        let projectDouble = (project.uploaded as NSString).doubleValue
        let projectDate = Date(timeIntervalSince1970: TimeInterval(projectDouble))
        let uploaded = CatrobatProject.uploadDateFormatter().string(from: projectDate)
        self.addInformationLabel(to: view, withAuthor: project.author, downloads: project.downloads, uploaded: uploaded, version: project.size, views: project.views)
        self.addReportButton(to: view, withTarget: target)
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
        return view
    }

    private func addNameLabel(withProjectName projectName: String?, to view: UIView?) {
        let height = type(of: self).height
        let nameLabel = UILabel(frame: CGRect(x: (view?.frame.size.width ?? 0.0) / 2 - 10, y: height * 0.05, width: 155, height: 25))
        nameLabel.text = projectName
        nameLabel.lineBreakMode = .byWordWrapping
        nameLabel.numberOfLines = 2
        self.configureTitleLabel(nameLabel, andHeight: height)
        nameLabel.sizeToFit()
        self.setMaxHeightIfGreaterFor(view, withHeight: nameLabel.frame.origin.y + nameLabel.frame.size.height)

        view?.addSubview(nameLabel)
    }

    private func addAuthorLabel(withAuthor author: String?, to view: UIView?) {
        let height = ProjectDetailStoreViewController.self.height
        let authorLabel = UILabel(frame: CGRect(x: (view?.frame.size.width ?? 0.0) / 2 - 10, y: (view?.frame.size.height ?? 0.0) + 5, width: 155, height: 25))
        authorLabel.text = author
        self.configureAuthorLabel(authorLabel, andHeight: height)
        view?.addSubview(authorLabel)
        self.setMaxHeightIfGreaterFor(view, withHeight: authorLabel.frame.origin.y + authorLabel.frame.size.height)
    }

    private func addProjectDescriptionLabel(withDescription description: String, to view: UIView, target: Any?) -> CGFloat {
        var description = description
        let height = ProjectDetailStoreViewController.height
        self.addHorizontalLine(to: view, andHeight: height * 0.35 - 15)
        let descriptionTitleLabel = UILabel(frame: CGRect(x: view.frame.size.width / type(of: self).marginLeftPercentage, y: height * 0.35, width: 155, height: 25))
        self.configureTitleLabel(descriptionTitleLabel, andHeight: height)
        descriptionTitleLabel.text = kLocalizedDescription
        view.addSubview(descriptionTitleLabel)
        description = description.replacingOccurrences(of: "<br>", with: "")
        description = description.replacingOccurrences(of: "<br />", with: "")

        if description.isEmpty {
            description = kLocalizedNoDescriptionAvailable
        }

        let maximumLabelSize = CGSize(width: view.frame.size.width / 100 * (100 - type(of: self).marginLeftPercentage * 2), height: CGFloat(Int.max))
        var attributes: [AnyHashable: Any]?
        if height == UIDefines.iPadScreenHeight {
            attributes = [descriptionTitleLabel.font: UIFont.systemFont(ofSize: 20)]
        } else {
            attributes = [descriptionTitleLabel.font: UIFont.systemFont(ofSize: 14)]
        }

        let labelBounds = description.boundingRect(
            with: maximumLabelSize,
            options: .usesLineFragmentOrigin,
            attributes: attributes as? [NSAttributedString.Key: Any],
            context: nil)
        let x = labelBounds.size.width.rounded(.up)
        let y = labelBounds.size.height.rounded(.up)
        let expectedSize = CGSize(width: x, height: y)

        let descriptionLabel = ActiveLabel(frame: .zero)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: (view.frame.size.width) / type(of: self).marginLeftPercentage),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -(view.frame.size.width) / type(of: self).marginLeftPercentage),
            descriptionLabel.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 10),
            descriptionLabel.heightAnchor.constraint(equalToConstant: expectedSize.height)
        ])

        self.configureDescriptionLabel(descriptionLabel)
        descriptionLabel.text = description

        self.setMaxHeightIfGreaterFor(view, withHeight: height * 0.35 + 40 + expectedSize.height)
        return descriptionLabel.frame.size.height
    }

    private func addThumbnailImage(withImageUrlString imageUrlString: String?, to view: UIView?) {
        let imageView = UIImageView()
        let errorImage = UIImage(named: "thumbnail_large")
        imageView.frame = CGRect(x: (view?.frame.size.width ?? 0.0) / type(of: self).marginLeftPercentage,
                                 y: (view?.frame.size.height ?? 0.0) * 0.1,
                                 width: (view?.frame.size.width ?? 0.0) / 3,
                                 height: ProjectDetailStoreViewController.height / 4.5)
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
            activity.frame = CGRect(x: imageView.frame.size.width / 2.0 - 25.0 / 2.0, y: imageView.frame.size.height / 2.0 - 25.0 / 2.0, width: 25.0, height: 25.0)
            imageView.addSubview(activity)
            activity.startAnimating()
        }

        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8.0
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.utilityTint.cgColor
        imageView.layer.borderWidth = 1.0

        view?.addSubview(imageView)

    }
    private func addDownloadButton(to view: UIView?, withTarget target: Any?) {
        let x = (view?.frame.size.width ?? 0.0) - 75
        let result = (view?.frame.size.height ?? 0.0) * 0.1
        let y = result + ProjectDetailStoreViewController.height / 4.5 - 25
        let downloadButton = RoundBorderedButton(frame: CGRect(x: x, y: y, width: 70, height: 25)) as UIButton
        downloadButton.layer.borderWidth = 1
        downloadButton.layer.cornerRadius = 5
        downloadButton.layer.borderColor = UIColor.black.cgColor
        downloadButton.tag = Int(kDownloadButtonTag)
        downloadButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        downloadButton.titleLabel?.adjustsFontSizeToFitWidth = true
        downloadButton.titleLabel?.minimumScaleFactor = 0.4
        downloadButton.setTitle(kLocalizedDownload, for: .normal)
        downloadButton.tintColor = UIColor.buttonTint
        downloadButton.addTarget(target, action: #selector(self.downloadButtonPressed), for: .touchUpInside)

        let activity = UIActivityIndicatorView(style: .gray)
        activity.tag = Int(kActivityIndicator)
        activity.frame = CGRect(x: 5, y: 0, width: 25, height: 25)
        downloadButton.addSubview(activity)
        view?.addSubview(downloadButton)
    }

    private func addOpenButton(to view: UIView?, withTarget target: Any?) {
        let x = (view?.frame.size.width ?? 0.0) - 75
        let result = (view?.frame.size.height ?? 0.0) * 0.1
        let y = result + ProjectDetailStoreViewController.height / 4.5 - 25
        let openButton = RoundBorderedButton(frame: CGRect(x: x, y: y, width: 70, height: 25)) as UIButton
        openButton.layer.borderWidth = 1
        openButton.layer.cornerRadius = 5
        openButton.layer.borderColor = UIColor.black.cgColor
        openButton.tag = Int(kOpenButtonTag)
        openButton.isHidden = true
        openButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        openButton.titleLabel?.adjustsFontSizeToFitWidth = true
        openButton.titleLabel?.minimumScaleFactor = 0.4
        openButton.setTitle(kLocalizedOpen, for: .normal)
        openButton.addTarget(target, action: #selector(self.openButtonPressed(_:)), for: .touchUpInside)
        openButton.tintColor = UIColor.buttonTint
        view?.addSubview(openButton)
    }

    private func addDownloadAgainButton(to view: UIView?, withTarget target: Any?) {
        let x = (view?.frame.size.width ?? 0.0) / 2 - 10
        let result = (view?.frame.size.height ?? 0.0) * 0.1
        let y = result + ProjectDetailStoreViewController.height / 4.5 - 25
        let downloadAgainButton = RoundBorderedButton(frame: CGRect(x: x, y: y, width: 100, height: 25))
        downloadAgainButton.layer.borderWidth = 0
        downloadAgainButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        downloadAgainButton.setTitleColor(UIColor.buttonTint, for: .normal)
        downloadAgainButton.setTitleColor(UIColor.buttonHighlightedTint, for: .highlighted)
        downloadAgainButton.setTitle(kLocalizedDownload, for: .normal)
        downloadAgainButton.titleLabel?.adjustsFontSizeToFitWidth = true
        downloadAgainButton.titleLabel?.minimumScaleFactor = 0.4
        downloadAgainButton.addTarget(target, action: #selector(self.downloadAgain(_:)), for: .touchUpInside)
        downloadAgainButton.tag = Int(kDownloadAgainButtonTag)
        downloadAgainButton.isHidden = true

        view?.addSubview(downloadAgainButton)
    }

    private func addLoadingButton(to view: UIView?, withTarget target: Any?) {
        let button = EVCircularProgressView()
        button.tag = Int(kStopLoadingTag)
        button.tintColor = UIColor.buttonTint
        let x = (view?.frame.size.width ?? 0.0) - 40
        let result = (view?.frame.size.height ?? 0.0) * 0.1
        let y = result + ProjectDetailStoreViewController.height / 4.5 - 25
        button.frame = CGRect(x: x, y: y, width: 28, height: 28)
        button.isHidden = true
        button.addTarget(target, action: #selector(URLProtocol.stopLoading), for: .touchUpInside)
        view?.addSubview(button)
    }

    private func addInformationLabel(to view: UIView?, withAuthor author: String?, downloads: NSNumber?, uploaded: String?, version: String?, views: NSNumber?) {
        var version = version
        let height = ProjectDetailStoreViewController.height
        var offset = (view?.frame.size.height ?? 0.0) + height * 0.05
        self.addHorizontalLine(to: view, andHeight: offset - 15)
        let informationLabel = UILabel(frame: CGRect(x: (view?.frame.size.width ?? 0.0) / type(of: self).marginLeftPercentage, y: offset, width: 155, height: 25))
        informationLabel.text = kLocalizedInformation
        self.configureTitleLabel(informationLabel, andHeight: height)
        view?.addSubview(informationLabel)
        offset += height * 0.075

        version = version?.replacingOccurrences(of: "&lt;", with: "")
        version = (version ?? "") + " MB"

        let informationArray = [views?.stringValue ?? "", uploaded, version, downloads?.stringValue ?? ""]
        let informationTitleArray = [UIImage(named: "viewsIcon"), UIImage(named: "timeIcon"), UIImage(named: "sizeIcon"), UIImage(named: "downloadIcon")]
        var counter = 0
        for info in informationArray {
            let titleIcon = self.getInformationTitleLabel(withTitle: informationTitleArray[counter], atXPosition: (view?.frame.size.width ?? 0.0) / 12, atYPosition: offset, andHeight: height)
            if let titleIcon = titleIcon {
                view?.addSubview(titleIcon)
            }

            let infoLabel = self.getInformationDetailLabel(withTitle: info, atXPosition: (view?.frame.size.width ?? 0.0) / 12 + 25, atYPosition: offset, andHeight: height)
            if let infoLabel = infoLabel {
                view?.addSubview(infoLabel)
            }

            offset += +height * 0.04
            counter += 1
        }
        self.setMaxHeightIfGreaterFor(view, withHeight: offset)
    }

    private func addReportButton(to view: UIView, withTarget target: Any?) {
        let height = ProjectDetailStoreViewController.height
        self.addHorizontalLine(to: view, andHeight: (view.frame.size.height) + height * 0.01 - 15)
        let reportButton = RoundBorderedButton(frame: CGRect(x: view.frame.size.width / 15, y: view.frame.size.height + height * 0.01, width: 130, height: 25)) as UIButton
        reportButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        reportButton.titleLabel?.tintColor = UIColor.globalTint
        reportButton.setTitle(kLocalizedReportProject, for: .normal)
        reportButton.addTarget(target, action: #selector(self.reportProject(_:)), for: .touchUpInside)
        reportButton.sizeToFit()
        reportButton.tintColor = UIColor.buttonTint
        reportButton.setTitleColor(UIColor.buttonTint, for: .normal)
        view.addSubview(reportButton)
        self.setMaxHeightIfGreaterFor(view, withHeight: (view.frame.size.height) + reportButton.frame.size.height)
    }

    private func addHorizontalLine(to view: UIView?, andHeight height: CGFloat) {
        self.setMaxHeightIfGreaterFor(view, withHeight: height)
        let offset = (view?.frame.size.height ?? 0.0) + 1
        let lineView = UIView(frame: CGRect(x: (view?.frame.size.width ?? 0.0) / 15 - 10, y: offset, width: view?.frame.size.width ?? 0.0, height: 1))
        lineView.backgroundColor = UIColor.utilityTint
        view?.addSubview(lineView)
    }

    private func configureTitleLabel(_ label: UILabel?, andHeight height: CGFloat) {
        label?.backgroundColor = UIColor.clear
        if height == UIDefines.iPadScreenHeight {
            label?.font = UIFont.boldSystemFont(ofSize: 24)
        } else {
            label?.font = UIFont.boldSystemFont(ofSize: 17)
        }
        label?.textColor = UIColor.globalTint
        label?.layer.shadowColor = UIColor.white.cgColor
        label?.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    }

    private func configureTextLabel(_ label: UILabel?, andHeight height: CGFloat) {
        label?.backgroundColor = UIColor.clear
        if height == UIDefines.iPadScreenHeight {
            label?.font = UIFont.boldSystemFont(ofSize: 18)
        } else {
            label?.font = UIFont.boldSystemFont(ofSize: 12)
        }
        label?.textColor = UIColor.textTint
        label?.layer.shadowColor = UIColor.white.cgColor
        label?.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    }

    private func configureAuthorLabel(_ label: UILabel?, andHeight height: CGFloat) {
        label?.backgroundColor = UIColor.clear
        if height == UIDefines.iPadScreenHeight {
            label?.font = UIFont.boldSystemFont(ofSize: 18)
        } else {
            label?.font = UIFont.boldSystemFont(ofSize: 12)
        }
        label?.textColor = UIColor.textTint
        label?.layer.shadowColor = UIColor.white.cgColor
        label?.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    }

    private func createView(forProject project: CatrobatProject) -> UIView? {
        let view = self.createProjectDetailView(project, target: self)
        return view
    }

    private func getInformationTitleLabel(withTitle icon: UIImage?, atXPosition xPosition: CGFloat, atYPosition yPosition: CGFloat, andHeight height: CGFloat) -> UIImageView? {
        let titleInformation = UIImageView(frame: CGRect(x: xPosition, y: yPosition, width: 15, height: 15))
        titleInformation.image = icon

        return titleInformation
    }

    private func getInformationDetailLabel(withTitle title: String?, atXPosition xPosition: CGFloat, atYPosition yPosition: CGFloat, andHeight height: CGFloat) -> UILabel? {
        let detailInformationLabel = UILabel(frame: CGRect(x: xPosition, y: yPosition, width: 155, height: 25))
        detailInformationLabel.text = title?.stringByEscapingHTMLEntities()
        detailInformationLabel.textColor = UIColor.textTint
        if height == UIDefines.iPadScreenHeight {
            detailInformationLabel.font = UIFont.systemFont(ofSize: 18.0)
        } else {
            detailInformationLabel.font = UIFont.systemFont(ofSize: 14.0)
        }

        detailInformationLabel.backgroundColor = UIColor.clear
        detailInformationLabel.sizeToFit()
        return detailInformationLabel
    }

    func loadProject(_ project: CatrobatProject) {
        self.projectView?.removeFromSuperview()
        self.projectView = self.createView(forProject: project)

        if self.project.author == nil {
            self.showLoadingView()
            let button = self.projectView.viewWithTag(Int(kDownloadButtonTag)) as! UIButton
            button.isEnabled = false
        }

        self.scrollViewOutlet.addSubview(self.projectView)
        self.scrollViewOutlet.delegate = self
        var contentSize = self.projectView.bounds.size
        let minHeight = self.view.frame.size.height

        if contentSize.height < minHeight {
            contentSize.height = minHeight
        }
        contentSize.height += 30.0
        self.scrollViewOutlet.contentSize = contentSize
        self.scrollViewOutlet.contentInsetAdjustmentBehavior = .never
        self.scrollViewOutlet.isUserInteractionEnabled = true
    }

    private func setMaxHeightIfGreaterFor(_ view: UIView?, withHeight height: CGFloat) {
        var frame = view?.frame
        if (frame?.size.height ?? 0.0) < height {
            frame?.size.height = height
            view?.frame = frame ?? CGRect.zero
        }
    }

    private func configureDescriptionLabel(_ label: ActiveLabel) {
        let height = ProjectDetailStoreViewController.height
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 0
        self.configureTextLabel(label, andHeight: height)
        label.enabledTypes = [.url]
        label.URLColor = UIColor.navBar
        label.URLSelectedColor = UIColor.navTint

        label.handleURLTap { url in UIApplication.shared.open(url, options: [:], completionHandler: nil) }
    }

    func openButtonPressed() {
        guard let localProjectNames = self.projectManager.projectNames(for: project.projectID) else {
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

    private func openProject(withLocalName localProjectName: String?) {
        showLoadingView()

        DispatchQueue.global(qos: .userInitiated).async {
            guard let selectedProject = Project.init(loadingInfo: ProjectLoadingInfo.init(forProjectWithName: localProjectName, projectID: self.project.projectID)) else {
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
}
