/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

@objc extension ProjectDetailStoreViewController {

    func height() -> CGFloat {
        Util.screenHeight()
    }

    func createProjectDetailView(_ project: CatrobatProject, target: Any) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: Util.screenWidth(), height: 0))
        view.backgroundColor = UIColor.clear
        view.autoresizingMask = .flexibleHeight
        addNameLabel(withProjectName: project.projectName, to: view)
        addAuthorLabel(withAuthor: project.author, to: view)
        addThumbnailImage(withImageUrlString: project.screenshotSmall, to: view)
        addDownloadButton(to: view, withTarget: target)
        addLoadingButton(to: view, withTarget: target)
        addOpenButton(to: view, withTarget: target)
        addDownloadAgainButton(to: view, withTarget: target)
        addProjectDescriptionLabel(withDescription: project.projectDescription, to: view, target: target)

        if let doubleValue = Double(project.uploaded) {
            let projectDate = Date(timeIntervalSince1970: TimeInterval(doubleValue))
            let uploaded = CatrobatProject.uploadDateFormatter().string(from: projectDate)
            addInformationLabel(
                to: view,
                withAuthor: project.author,
                downloads: project.downloads,
                uploaded: uploaded,
                version: project.size,
                views: project.views)
        }

        addReportButton(to: view, withTarget: target)
        return view
    }

    fileprivate func addNameLabel(withProjectName projectName: String, to view: UIView) {
        let height = self.height()
        let nameLabel = UILabel(frame: CGRect(x: (view.frame.size.width) / 2 - 10, y: height * 0.05, width: 155, height: 25))
        nameLabel.text = projectName
        nameLabel.lineBreakMode = .byWordWrapping
        nameLabel.numberOfLines = 2
        self.configureTitleLabel(nameLabel, andHeight: height)
        nameLabel.sizeToFit()
        self.setMaxHeightIfGreaterFor(
            view,
            withHeight: nameLabel.frame.origin.y + nameLabel.frame.size.height)

        view.addSubview(nameLabel)
    }

    fileprivate func addAuthorLabel(withAuthor author: String, to view: UIView) {
        let height = self.height()
        let authorLabel = UILabel(frame: CGRect(x: (view.frame.size.width) / 2 - 10, y: (view.frame.size.height) + 5, width: 155, height: 25))
        authorLabel.text = author
        self.configureTextLabel(authorLabel, andHeight: height)
        view.addSubview(authorLabel)
        self.setMaxHeightIfGreaterFor(
            view,
            withHeight: authorLabel.frame.origin.y + authorLabel.frame.size.height)
    }

    fileprivate func configureTitleLabel(_ label: UILabel, andHeight height: CGFloat) {
        label.backgroundColor = UIColor.clear
        if Float(height) == kIpadScreenHeight {
            label.font = UIFont.boldSystemFont(ofSize: 24)
        } else {
            label.font = UIFont.boldSystemFont(ofSize: 17)
        }
        label.textColor = UIColor.globalTint
        label.layer.shadowColor = UIColor.white.cgColor
        label.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    }

    fileprivate func configureTextLabel(_ label: UILabel, andHeight height: CGFloat) {
        label.backgroundColor = UIColor.clear
        if Float(height) == kIpadScreenHeight {
            label.font = UIFont.boldSystemFont(ofSize: 18)
        } else {
            label.font = UIFont.boldSystemFont(ofSize: 12)
        }
        label.textColor = UIColor.textTint
        label.layer.shadowColor = UIColor.white.cgColor
        label.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
    }

    fileprivate func setMaxHeightIfGreaterFor(_ view: UIView, withHeight height: CGFloat) {
        var frame = view.frame
        if (frame.size.height) < height {
            frame.size.height = height
            view.frame = frame
        }
    }

    fileprivate func configureDescriptionLabel(_ label: TTTAttributedLabel) {
        let height = self.height()
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 0
        self.configureTextLabel(label, andHeight: height)
        label.enabledTextCheckingTypes = NSTextCheckingAllTypes
        label.verticalAlignment = TTTAttributedLabelVerticalAlignment.top

        var mutableLinkAttributes: [AnyHashable: Any] = [: ]
        mutableLinkAttributes[kCTForegroundColorAttributeName as String] = UIColor.textTint
        mutableLinkAttributes[kCTUnderlineStyleAttributeName as String] = NSNumber(value: true)

        var mutableActiveLinkAttributes: [AnyHashable: Any] = [:]
        mutableActiveLinkAttributes[kCTForegroundColorAttributeName as String] = UIColor.brown
        mutableActiveLinkAttributes[kCTUnderlineStyleAttributeName as String] = NSNumber(value: false)
        label.linkAttributes = mutableLinkAttributes
        label.activeLinkAttributes = mutableActiveLinkAttributes
    }

    fileprivate func addHorizontalLine(to view: UIView, andHeight height: CGFloat) {
        self.setMaxHeightIfGreaterFor(view, withHeight: height)
        let offset = (view.frame.size.height) + 1
        let lineView = UIView(frame: CGRect(x: (view.frame.size.width) / 15 - 10, y: offset, width: view.frame.size.width, height: 1))
        lineView.backgroundColor = UIColor.utilityTint
        view.addSubview(lineView)
    }

    fileprivate func getInformationTitleLabel(withTitle icon: UIImage, atXPosition xPosition: CGFloat, atYPosition yPosition: CGFloat, andHeight height: CGFloat) -> UIImageView {

        let titleInformation = UIImageView(frame: CGRect(x: xPosition, y: yPosition, width: 15, height: 15))
        titleInformation.image = icon

        return titleInformation
    }

    fileprivate func getInformationDetailLabel( withTitle title: String, atXPosition xPosition: CGFloat, atYPosition yPosition: CGFloat, andHeight height: CGFloat) -> UILabel {

        let detailInformationLabel = UILabel(frame: CGRect(x: xPosition, y: yPosition, width: 155, height: 25))

        detailInformationLabel.text = NSString(string: title).stringByEscapingHTMLEntities()
        detailInformationLabel.textColor = UIColor.textTint
        if Float(height) == kIpadScreenHeight {
            detailInformationLabel.font = UIFont.systemFont(ofSize: 18.0)
        } else {
            detailInformationLabel.font = UIFont.systemFont(ofSize: 14.0)
        }

        detailInformationLabel.backgroundColor = UIColor.clear
        detailInformationLabel.sizeToFit()
        return detailInformationLabel
    }

    fileprivate func addReportButton(to view: UIView, withTarget target: Any) {
        let height = self.height()
        self.addHorizontalLine(to: view, andHeight: (view.frame.size.height) + height * 0.01 - 15)
        let reportButton = RoundBorderedButton(frame: CGRect(x: (view.frame.size.width) / 15, y: (view.frame.size.height) + height * 0.01, width: 130, height: 25), andBorder: false)

        if let reportButton = reportButton {
            reportButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            reportButton.titleLabel?.tintColor = UIColor.globalTint
            reportButton.setTitle(kLocalizedReportProject, for: .normal)
            reportButton.addTarget(target, action: #selector(reportProject), for: .touchUpInside)
            reportButton.sizeToFit()
            reportButton.tintColor = UIColor.buttonTint
            reportButton.setTitleColor(UIColor.buttonTint, for: .normal)
            view.addSubview(reportButton)
            setMaxHeightIfGreaterFor(view, withHeight: view.frame.size.height + reportButton.frame.size.height)
        }
    }

    fileprivate func addInformationLabel(to view: UIView, withAuthor author: String, downloads: NSNumber, uploaded: String, version: String, views: NSNumber) {
        var version = version
        let height = self.height()
        var offset = (view.frame.size.height) + height * 0.05
        self.addHorizontalLine(to: view, andHeight: offset - 15)
        let informationLabel = UILabel(frame: CGRect(x: (view.frame.size.width) / 15, y: offset, width: 155, height: 25))
        informationLabel.text = kLocalizedInformation
        self.configureTitleLabel(informationLabel, andHeight: height)
        view.addSubview(informationLabel)
        offset += height * 0.075

        version = version.replacingOccurrences(of: "&lt;", with: "")
        version += " MB"

        let informationArray = [views.stringValue, uploaded, version, downloads.stringValue]
        let informationTitleArray = [UIImage(named: "viewsIcon"), UIImage(named: "timeIcon"), UIImage(named: "sizeIcon"), UIImage(named: "downloadIcon")]
        var counter = 0
        for info in informationArray {

            if let informationTitle = informationTitleArray[counter] {
                let titleIcon = getInformationTitleLabel(
                withTitle: informationTitle,
                atXPosition: (view.frame.size.width) / 12,
                atYPosition: offset,
                andHeight: height)
                view.addSubview(titleIcon)
            }

            let infoLabel = getInformationDetailLabel(
                withTitle: info,
                atXPosition: (view.frame.size.width) / 12 + 25,
                atYPosition: offset,
                andHeight: height)
            view.addSubview(infoLabel)

            offset += +height * 0.04
            counter += 1
        }
        setMaxHeightIfGreaterFor(view, withHeight: offset)
    }

    fileprivate func addLoadingButton(to view: UIView, withTarget target: Any?) {
        let button = EVCircularProgressView()
        button.tag = Int(kStopLoadingTag)
        button.tintColor = UIColor.buttonTint
        let xPosition = (view.frame.size.width) - 40
        let yPosition = (view.frame.size.height) * 0.1 + Util.screenHeight() / 4.5
        button.frame = CGRect(x: xPosition, y: yPosition - 25, width: 28, height: 28)
        button.isHidden = true
        button.addTarget(target, action: #selector(URLProtocol.stopLoading), for: .touchUpInside)
        view.addSubview(button)
    }

    fileprivate func addDownloadAgainButton(to view: UIView, withTarget target: Any?) {
        let xPos = (view.frame.size.width) / 2 - 10
        let yPos = (view.frame.size.height) * 0.1 + Util.screenHeight() / 4.5
        let downloadAgainButton = RoundBorderedButton(frame: CGRect(x: xPos, y: yPos - 25, width: 100, height: 25), andBorder: false)

        if let downloadAgainButton = downloadAgainButton {
            downloadAgainButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            downloadAgainButton.setTitleColor(UIColor.buttonTint, for: .normal)
            downloadAgainButton.setTitleColor(UIColor.buttonHighlightedTint, for: .highlighted)
            downloadAgainButton.setTitle( kLocalizedDownload, for: .normal)
            downloadAgainButton.titleLabel?.adjustsFontSizeToFitWidth = true
            downloadAgainButton.titleLabel?.minimumScaleFactor = 0.4
            downloadAgainButton.addTarget(target, action: #selector(downloadAgain), for: .touchUpInside)
            downloadAgainButton.tag = Int(kDownloadAgainButtonTag)
            downloadAgainButton.isHidden = true
            view.addSubview(downloadAgainButton)
        }
    }

    fileprivate func addOpenButton(to view: UIView, withTarget target: Any?) {
        let xPos = (view.frame.size.width) - 75
        let yPos = (view.frame.size.height) * 0.1 + Util.screenHeight() / 4.5
        let openButton = RoundBorderedButton(frame: CGRect(x: xPos, y: yPos - 25, width: 70, height: 25), andBorder: true)

        if let openButton = openButton {
            openButton.tag = Int(kOpenButtonTag)
            openButton.isHidden = true
            openButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            openButton.titleLabel?.adjustsFontSizeToFitWidth = true
            openButton.titleLabel?.minimumScaleFactor = 0.4
            openButton.setTitle(kLocalizedOpen, for: .normal)
            openButton.addTarget(target, action: #selector(openButtonPressed(_:)), for: .touchUpInside)
            openButton.tintColor = UIColor.buttonTint
            view.addSubview(openButton)
        }
    }

    fileprivate func addDownloadButton(to view: UIView, withTarget target: Any?) {
        let xPos = (view.frame.size.width) - 75
        let yPos = (view.frame.size.height) * 0.1 + Util.screenHeight() / 4.5
        let downloadButton = RoundBorderedButton(frame: CGRect(x: xPos, y: yPos - 25, width: 70, height: 25), andBorder: true)

        if let downloadButton = downloadButton {
            downloadButton.tag = Int(kDownloadButtonTag)
            downloadButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            downloadButton.titleLabel?.adjustsFontSizeToFitWidth = true
            downloadButton.titleLabel?.minimumScaleFactor = 0.4
            downloadButton.setTitle(kLocalizedDownload, for: .normal)
            downloadButton.tintColor = UIColor.buttonTint

            downloadButton.addTarget(target, action: #selector(downloadButtonPressed), for: .touchUpInside)

            let activity = UIActivityIndicatorView(style: .gray)
            activity.tag = Int(kActivityIndicator)
            activity.frame = CGRect(x: 5, y: 0, width: 25, height: 25)
            downloadButton.addSubview(activity)

            view.addSubview(downloadButton)
        }
    }

    fileprivate func addThumbnailImage(withImageUrlString imageUrlString: String, to view: UIView) {
        let imageView = UIImageView()
        let errorImage = UIImage(named: "thumbnail_large")

        imageView.frame = CGRect(x: (view.frame.size.width) / 15, y: (view.frame.size.height) * 0.1, width: (view.frame.size.width) / 3, height: Util.screenHeight() / 4.5)
        imageView.image = UIImage(
            contentsOf: URL(string: imageUrlString),
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

        view.addSubview(imageView)
    }

    fileprivate func addProjectDescriptionLabel(withDescription description: String, to view: UIView, target: Any?) {
        var description = description
        let height = self.height()
        self.addHorizontalLine(to: view, andHeight: height * 0.35 - 15)
        let descriptionTitleLabel = UILabel(frame: CGRect(x: (view.frame.size.width) / 15, y: height * 0.35, width: 155, height: 25))
        self.configureTitleLabel(descriptionTitleLabel, andHeight: height)
        descriptionTitleLabel.text = kLocalizedDescription
        view.addSubview(descriptionTitleLabel)

        description = description.replacingOccurrences(of: "<br>", with: "")
        description = description.replacingOccurrences(of: "<br />", with: "")

        if description.isEmpty {
            description = kLocalizedNoDescriptionAvailable
        }

        let maximumLabelSize = CGSize(width: 296.0, height: Double(Float.greatestFiniteMagnitude))
        var attributes: [AnyHashable: Any]?
        if Float(height) == kIpadScreenHeight {
            attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)]
        } else {
            attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]
        }

        let labelBounds = description.boundingRect(
            with: maximumLabelSize,
            options: .usesLineFragmentOrigin,
            attributes: attributes as? [NSAttributedString.Key: Any],
            context: nil)

        let width = Float(labelBounds.size.width)
        let hight = Float(labelBounds.size.height)

        let expectedSize = CGSize(width: CGFloat(ceilf(width)), height: CGFloat(ceilf(hight)))

        let descriptionLabel = TTTAttributedLabel(frame: CGRect.zero)
        if Float(height) == kIpadScreenHeight {
            descriptionLabel.frame = CGRect(x: (view.frame.size.width) / 15, y: height * 0.35 + 40, width: 540, height: expectedSize.height)
        } else {
            descriptionLabel.frame = CGRect(x: (view.frame.size.width) / 15, y: height * 0.35 + 40, width: 280, height: expectedSize.height)
        }

        configureDescriptionLabel(descriptionLabel)
        descriptionLabel.delegate = target as? TTTAttributedLabelDelegate
        descriptionLabel.text = description

        descriptionLabel.frame = CGRect(x: descriptionLabel.frame.origin.x, y: descriptionLabel.frame.origin.y, width: descriptionLabel.frame.size.width, height: expectedSize.height)
        view.addSubview(descriptionLabel)
        setMaxHeightIfGreaterFor(view, withHeight: height * 0.35 + 40 + expectedSize.height)
    }
}
