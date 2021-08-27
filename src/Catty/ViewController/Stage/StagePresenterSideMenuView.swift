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

import UIKit

@objc protocol StagePresenterSideMenuDelegate {
    var project: Project { get }

    func stopAction()
    func continueAction()
    func restartAction()
    func takeScreenshotAction()
    func showHideAxisAction()
    func aspectRatioAction()
    func shareDSTAction()
}

enum SideMenuButtonType {
    case portrait
    case landscapeLarge
    case landscapeSmall
}

@objc class StagePresenterSideMenuView: UIView {

    @objc static let widthProportionalPortrait = 3
    @objc static let widthProportionalLandscape = 4
    @objc static let buttonInitialWidthAndHeight = 100.0
    @objc static let labelInitialWidthAndHeight = 100.0
    @objc static let buttonLandscapeSmallInitialWidthAndHeight = 40.0
    @objc static let labelLandscapeSmallInitialWidthAndHeight = 40.0
    @objc static let buttonLandscapeLargeInitialWidthAndHeight = 240.0
    @objc static let labelLandscapeLargeInitialWidthAndHeight = 240.0
    let font = SpriteKitDefines.defaultFont
    let fontSize = 14.0
    let marginTopBottom = CGFloat(20.0)
    let marginLabel = CGFloat(5.0)
    let insetsLabelTop = CGFloat(10.0)
    let minimumPaddingTopAndBottom = CGFloat(365.0)

    weak var delegate: StagePresenterSideMenuDelegate?
    var landscape: Bool
    var project: Project
    let numberOfButtons: Int
    var aspectRatioButton: UIButton?
    var aspectRatioLabel: UIButton?
    var aspectRatioLabelLandscape: String?
    var embroidery: Bool
    var landscapeMultiplier: Double

    @objc(initWithFrame:andStagePresenterViewController_:)
    init(frame: CGRect, delegate: StagePresenterSideMenuDelegate) {
        self.delegate = delegate
        self.landscape = delegate.project.header.landscapeMode
        self.project = delegate.project
        self.embroidery = self.project.getRequiredResources() & ResourceType.embroidery.rawValue > 0
        self.landscapeMultiplier = 2.0

        if embroidery {
            self.numberOfButtons = 7
        } else {
            self.numberOfButtons = 6
        }

        super.init(frame: frame)
        setupView()
        if self.landscape {
            setupAspectRatioLandscape()
        } else {
            setupAspectRatio()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc(restartWithProject:)
    func restart(with project: Project) {
        self.landscape = project.header.landscapeMode
        self.project = project
        if self.landscape {
            setupAspectRatioLandscape()
        } else {
            setupAspectRatio()
        }
    }

    private func setupView() {
        backgroundColor = UIColor.globalTint
        if landscape {
            setUpButtonsLandscape()
        } else {
            setUpButtonsPortrait()
        }
    }

    private func setUpButtonsPortrait() {
        let backButton = setupButton(imageName: "stage_dialog_button_back", selector: #selector(delegate?.stopAction))
        backButton.center = self.center
        backButton.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: marginTopBottom).isActive = true

        let backLabel = setupLabel(title: kLocalizedBack, selector: #selector(delegate?.stopAction))
        backLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 0).isActive = true

        let screenshotButton = setupButton(imageName: "stage_dialog_button_screenshot", selector: #selector(delegate?.takeScreenshotAction))
        let restartLabel = setupLabel(title: kLocalizedRestart, selector: #selector(delegate?.restartAction))

        if embroidery == true {
            screenshotButton.bottomAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true

            restartLabel.bottomAnchor.constraint(equalTo: screenshotButton.topAnchor, constant: marginTopBottom * -1).isActive = true

        } else {
            screenshotButton.topAnchor.constraint(equalTo: self.centerYAnchor, constant: marginTopBottom - 0).isActive = true

            restartLabel.bottomAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        }

        let restartButton = setupButton(imageName: "stage_dialog_button_restart", selector: #selector(delegate?.restartAction))
        restartButton.bottomAnchor.constraint(equalTo: restartLabel.topAnchor, constant: 0).isActive = true

        let continueLabel = setupLabel(title: kLocalizedContinue, selector: #selector(delegate?.continueAction))
        continueLabel.bottomAnchor.constraint(equalTo: restartButton.topAnchor, constant: marginTopBottom * -1).isActive = true

        let continueButton = setupButton(imageName: "stage_dialog_button_continue", selector: #selector(delegate?.continueAction))
        continueButton.bottomAnchor.constraint(equalTo: continueLabel.topAnchor, constant: 0).isActive = true

        let screenshotLabel = setupLabel(title: kLocalizedPreview, selector: #selector(delegate?.takeScreenshotAction))
        screenshotLabel.topAnchor.constraint(equalTo: screenshotButton.bottomAnchor, constant: 0).isActive = true

        let axesButton = setupButton(imageName: "stage_dialog_button_toggle_axis", selector: #selector(delegate?.showHideAxisAction))
        axesButton.topAnchor.constraint(equalTo: screenshotLabel.bottomAnchor, constant: marginTopBottom).isActive = true

        let axesLabel = setupLabel(title: kLocalizedAxes, selector: #selector(delegate?.showHideAxisAction))
        axesLabel.topAnchor.constraint(equalTo: axesButton.bottomAnchor, constant: 0).isActive = true

        if embroidery {
            let shareButton = setupButton(imageName: "square.and.arrow.up.reg", selector: #selector(delegate?.shareDSTAction))
            shareButton.topAnchor.constraint(equalTo: axesLabel.bottomAnchor, constant: marginTopBottom).isActive = true

            let shareLabel = setupLabel(title: kLocalizedCategoryEmbroidery, selector: #selector(delegate?.shareDSTAction))
            shareLabel.topAnchor.constraint(equalTo: shareButton.bottomAnchor, constant: 0).isActive = true
        }

        let aspectRatioLabel = setupLabel(title: kLocalizedMaximize, selector: #selector(self.aspectRatioAction), target: self)
        aspectRatioLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: (marginTopBottom) * -1).isActive = true
        self.aspectRatioLabel = aspectRatioLabel

        let aspectRatioButton = setupButton(imageName: "stage_dialog_button_aspect_ratio", selector: #selector(self.aspectRatioAction), target: self)
        aspectRatioButton.bottomAnchor.constraint(equalTo: aspectRatioLabel.topAnchor, constant: 0).isActive = true
        self.aspectRatioButton = aspectRatioButton
    }

    private func setUpButtonsLandscape() {
        if embroidery {
            self.landscapeMultiplier = 1.7
        }
        let backButton = setupButton(imageName: "stage_dialog_button_back", selector: #selector(delegate?.stopAction), type: .landscapeLarge)
        if #available(iOS 11.0, *) {
            backButton.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: marginTopBottom).isActive = true
        } else {
            backButton.topAnchor.constraint(equalTo: self.topAnchor, constant: marginTopBottom).isActive = true
        }

        let backLabel = setupLabel(title: kLocalizedBack, selector: #selector(delegate?.stopAction), type: .landscapeLarge)
        backLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor).isActive = true

        let continueButton = setupButton(imageName: "stage_dialog_button_continue", selector: #selector(delegate?.continueAction), type: .landscapeLarge)

        let continueLabel = setupLabel(title: kLocalizedContinue, selector: #selector(delegate?.continueAction), type: .landscapeLarge)

        let restartButton = setupButton(imageName: "stage_dialog_button_restart", selector: #selector(delegate?.restartAction), type: .landscapeLarge)

        let restartLabel = setupLabel(title: kLocalizedRestart, selector: #selector(delegate?.restartAction), type: .landscapeLarge)

        if embroidery {
            continueLabel.bottomAnchor.constraint(equalTo: self.centerYAnchor, constant: marginLabel * -7).isActive = true
            continueButton.bottomAnchor.constraint(equalTo: continueLabel.topAnchor, constant: 0).isActive = true
            restartButton.topAnchor.constraint(equalTo: self.centerYAnchor, constant: marginTopBottom * -1).isActive = true
            restartLabel.topAnchor.constraint(equalTo: restartButton.bottomAnchor, constant: 0).isActive = true

            let shareButton = setupButton(imageName: "square.and.arrow.up.reg", selector: #selector(delegate?.shareDSTAction), type: .landscapeLarge)
            shareButton.topAnchor.constraint(equalTo: restartLabel.bottomAnchor, constant: marginLabel * 3).isActive = true

            let shareLabel = setupLabel(title: kLocalizedCategoryEmbroidery, selector: #selector(delegate?.shareDSTAction), type: .landscapeLarge)
            shareLabel.topAnchor.constraint(equalTo: shareButton.bottomAnchor, constant: 0).isActive = true
        } else {
            continueLabel.bottomAnchor.constraint(equalTo: self.centerYAnchor, constant: marginLabel * -1).isActive = true
            continueButton.bottomAnchor.constraint(equalTo: continueLabel.topAnchor, constant: marginLabel * -1).isActive = true
            restartButton.topAnchor.constraint(equalTo: self.centerYAnchor, constant: marginTopBottom).isActive = true
            restartLabel.topAnchor.constraint(equalTo: restartButton.bottomAnchor, constant: marginLabel).isActive = true
        }

        let axesButton = setupButton(imageName: "stage_dialog_button_toggle_axis", selector: #selector(delegate?.showHideAxisAction), type: .landscapeSmall)
        axesButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: marginLabel * 5).isActive = true

        if hideAspectRatio() {
            axesButton.leftAnchor.constraint(equalTo: self.centerXAnchor, constant: marginLabel * 2).isActive = true
        } else {
            axesButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        }

        let screenshotButton = setupButton(imageName: "stage_dialog_button_screenshot", selector: #selector(delegate?.takeScreenshotAction), type: .landscapeSmall)
        screenshotButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: marginLabel * 5).isActive = true
        screenshotButton.rightAnchor.constraint(equalTo: axesButton.leftAnchor, constant: marginTopBottom * -1).isActive = true

        let aspectRatioButton = setupButton(imageName: "stage_dialog_button_aspect_ratio", selector: #selector(self.aspectRatioActionLandscape), target: self, type: .landscapeSmall)
        aspectRatioButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: marginLabel * 5).isActive = true
        aspectRatioButton.leftAnchor.constraint(equalTo: axesButton.rightAnchor, constant: marginTopBottom * 1).isActive = true
        self.aspectRatioButton = aspectRatioButton
        self.aspectRatioLabelLandscape = kLocalizedMaximize
    }

    @objc private func aspectRatioActionLandscape() {
        guard let aspectRatioButton = self.aspectRatioButton else { return }

        if self.aspectRatioLabelLandscape == kLocalizedMaximize {
            self.aspectRatioLabelLandscape = kLocalizedMinimize
            changeImage("stage_dialog_button_aspect_ratio_close", for: aspectRatioButton)
         } else {
            self.aspectRatioLabelLandscape = kLocalizedMaximize
            changeImage("stage_dialog_button_aspect_ratio", for: aspectRatioButton)
         }

        self.delegate?.aspectRatioAction()
    }

    @objc private func aspectRatioAction() {
        guard let aspectRatioButton = self.aspectRatioButton, let aspectRatioLabel = self.aspectRatioLabel else { return }

        if aspectRatioLabel.currentTitle == kLocalizedMaximize {
            aspectRatioLabel.setTitle(kLocalizedMinimize, for: .normal)
            changeImage("stage_dialog_button_aspect_ratio_close", for: aspectRatioButton)
         } else {
            aspectRatioLabel.setTitle(kLocalizedMaximize, for: .normal)
            changeImage("stage_dialog_button_aspect_ratio", for: aspectRatioButton)
         }

        self.delegate?.aspectRatioAction()
    }

    private func setupAspectRatioLandscape() {
        guard let aspectRatioButton = self.aspectRatioButton else { return }
        self.aspectRatioLabel = nil
        self.aspectRatioLabel?.removeFromSuperview()
        if project.header.screenMode == kCatrobatHeaderScreenModeMaximize {
            self.aspectRatioLabelLandscape = kLocalizedMinimize
            setupImage("stage_dialog_button_aspect_ratio_close", for: aspectRatioButton)
        } else {
            self.aspectRatioLabelLandscape = kLocalizedMaximize
            setupImage("stage_dialog_button_aspect_ratio", for: aspectRatioButton)
        }

        if hideAspectRatio() {
            aspectRatioButton.isHidden = true
        } else {
            aspectRatioButton.isHidden = false
        }
    }

    private func setupAspectRatio() {
        guard let aspectRatioButton = self.aspectRatioButton, let aspectRatioLabel = self.aspectRatioLabel else { return }

        if project.header.screenMode == kCatrobatHeaderScreenModeMaximize {
            aspectRatioLabel.setTitle(kLocalizedMinimize, for: .normal)
            setupImage("stage_dialog_button_aspect_ratio_close", for: aspectRatioButton)
        } else {
            aspectRatioLabel.setTitle(kLocalizedMaximize, for: .normal)
            setupImage("stage_dialog_button_aspect_ratio", for: aspectRatioButton)
        }

        if hideAspectRatio() {
            aspectRatioLabel.isHidden = true
            aspectRatioButton.isHidden = true
        } else {
            aspectRatioLabel.isHidden = false
            aspectRatioButton.isHidden = false
        }
    }

    private func hideAspectRatio() -> Bool {
        let screenHeight = Util.screenHeight(true)
        let screenWidth = Util.screenWidth(true)
        let projectWidth = CGFloat(project.header.screenWidth.floatValue)
        let projectHeight = CGFloat(project.header.screenHeight.floatValue)
        return landscape ? (projectWidth == screenHeight && projectHeight == screenWidth) : (projectWidth == screenWidth && projectHeight == screenHeight)
    }

    private func setupButton(imageName: String, selector: Selector, target: Any? = nil, type: SideMenuButtonType = .portrait) -> UIButton {
        var widthAndHeight = StagePresenterSideMenuView.buttonInitialWidthAndHeight
        if type == .landscapeLarge {
            widthAndHeight = StagePresenterSideMenuView.buttonLandscapeLargeInitialWidthAndHeight
        }

        if type == .landscapeSmall {
            widthAndHeight = StagePresenterSideMenuView.buttonLandscapeSmallInitialWidthAndHeight
        }

        let button = UIButton(frame: CGRect(x: 0, y: 0, width: widthAndHeight, height: widthAndHeight))

        self.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false

        let target = target == nil ? self.delegate : target
        button.addTarget(target, action: selector, for: .touchUpInside)

        self.setupImage(imageName, for: button, type: type)

        switch type {
        case .portrait:
            button.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            button.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        case .landscapeLarge:
            button.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            button.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        case .landscapeSmall:
            if #available(iOS 11.0, *) {
                button.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: marginTopBottom * -1).isActive = true
            } else {
                button.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: marginTopBottom * -1).isActive = true
            }
        }

        return button
    }

    private func setupLabel(title: String, selector: Selector, target: Any? = nil, type: SideMenuButtonType = .portrait) -> UIButton {
        let label = UIButton(frame: CGRect(x: 0, y: 0, width: StagePresenterSideMenuView.labelInitialWidthAndHeight, height: StagePresenterSideMenuView.labelInitialWidthAndHeight))

        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        label.setTitle(title, for: .normal)
        label.setTitleColor(UIColor.navBarButton, for: .normal)
        label.setTitleColor(UIColor.navBarButtonHighlighted, for: .highlighted)
        label.setTitleColor(UIColor.navBarButtonHighlighted, for: .selected)

        label.titleLabel?.font = UIFont(name: font, size: CGFloat(fontSize))
        label.titleLabel?.textAlignment = .center

        label.titleEdgeInsets = UIEdgeInsets(top: insetsLabelTop, left: 0, bottom: 0, right: 0)

        let target = target == nil ? self.delegate : target
        label.addTarget(target, action: selector, for: .touchUpInside)

        switch type {
        case .portrait:
            label.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        case .landscapeLarge:
            label.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        case .landscapeSmall:
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }

        return label
    }

    private func setupImage(_ imageName: String, for button: UIButton, type: SideMenuButtonType = .portrait) {
        let sizeFactor = landscape ? 1 : 2
        var dividingConstant = self.frame.size.width / (self.frame.size.height / (CGFloat(sizeFactor * (numberOfButtons + 2))))

        button.frame.size.width = CGFloat(StagePresenterSideMenuView.buttonInitialWidthAndHeight)
        button.frame.size.height = CGFloat(StagePresenterSideMenuView.buttonInitialWidthAndHeight)

        if type == .landscapeLarge && self.landscape == true {
            button.frame.size.width = CGFloat(StagePresenterSideMenuView.buttonInitialWidthAndHeight * landscapeMultiplier)
            button.frame.size.height = CGFloat(StagePresenterSideMenuView.buttonInitialWidthAndHeight * landscapeMultiplier)
        } else if self.landscape == false {
            let availableSpace = self.frame.size.height - (button.frame.size.height / dividingConstant) * CGFloat(numberOfButtons)
            if availableSpace < minimumPaddingTopAndBottom {
                dividingConstant *= 1.4
            }
        }

        UIGraphicsBeginImageContextWithOptions(CGSize(width: button.frame.size.width / dividingConstant, height: button.frame.size.width / dividingConstant), false, 0.0)

        let image = UIImage(named: imageName)
        image?.draw(in: CGRect(x: 0, y: 0, width: button.frame.size.width / dividingConstant, height: button.frame.size.width / dividingConstant))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let newImageHighlight = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        button.setImage(newImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.tintColor = UIColor.navBarButton
        if #available(iOS 13.0, *) {
            button.currentImage?.withTintColor(UIColor.navBarButton)
        }
        button.setImage(newImageHighlight?.withRenderingMode(.alwaysTemplate), for: .highlighted)
        button.setImage(newImageHighlight?.withRenderingMode(.alwaysTemplate), for: .selected)
        if #available(iOS 13.0, *) {
            button.currentImage?.withTintColor(UIColor.navBarButtonHighlighted)
        }

    }

    private func changeImage(_ imageName: String, for button: UIButton) {

        guard let currentImage = button.currentImage else { return }

        let width = currentImage.size.width
        let height = currentImage.size.height

        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0.0)

        let image = UIImage(named: imageName)
        image?.draw(in: CGRect(x: 0, y: 0, width: width, height: height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let newImageHighlight = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        button.setImage(newImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.tintColor = UIColor.navBarButton
        if #available(iOS 13.0, *) {
            button.currentImage?.withTintColor(UIColor.navBarButton)
        }
        button.setImage(newImageHighlight?.withRenderingMode(.alwaysTemplate), for: .highlighted)
        button.setImage(newImageHighlight?.withRenderingMode(.alwaysTemplate), for: .selected)
        if #available(iOS 13.0, *) {
            button.currentImage?.withTintColor(UIColor.navBarButtonHighlighted)
        }
    }
}
