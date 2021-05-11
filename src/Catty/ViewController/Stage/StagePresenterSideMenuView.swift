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
    func shareDST()
    func isEmbroideryNeeded() -> Bool
}

enum SideMenuButtonType {
    case portrait
    case landscapeFirstColumn
    case landscapeSecondColumn
}

@objc class StagePresenterSideMenuView: UIView {

    @objc static let widthProportionalPortrait = 3
    @objc static let widthProportionalLandscape = 4
    @objc static let buttonInitialWidthAndHeight = 100.0
    @objc static let labelInitialWidthAndHeight = 100.0
    let font = SpriteKitDefines.defaultFont
    let fontSize = 14.0
    let marginTopBottom = CGFloat(20.0)
    let marginLabel = CGFloat(5.0)

    weak var delegate: StagePresenterSideMenuDelegate?
    var landscape: Bool
    var project: Project
    let numberOfButtons: Int
    var aspectRatioButton: UIButton?
    var aspectRatioLabel: UIButton?
    @objc var embroidery: Bool
    @objc var shareButton: UIButton?
    @objc var shareLabel: UIButton?

    @objc(initWithFrame:andStagePresenterViewController_:)
    init(frame: CGRect, delegate: StagePresenterSideMenuDelegate) {
        self.delegate = delegate
        self.landscape = delegate.project.header.landscapeMode
        self.embroidery = true
        self.project = delegate.project
        if embroidery {
            self.numberOfButtons = 8
        } else {
            self.numberOfButtons = 6
        }

        super.init(frame: frame)
        setupView()
        setupAspectRatio()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc(restartWithProject:)
    func restart(with project: Project) {
        self.landscape = project.header.landscapeMode
        self.project = project
        setupAspectRatio()
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
        if #available(iOS 11.0, *) {
            backButton.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: marginTopBottom).isActive = true
        } else {
            backButton.topAnchor.constraint(equalTo: self.topAnchor, constant: marginTopBottom).isActive = true
        }

        let backLabel = setupLabel(title: kLocalizedBack, selector: #selector(delegate?.stopAction))
        backLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: marginLabel).isActive = true

        let screenshotButton = setupButton(imageName: "stage_dialog_button_screenshot", selector: #selector(delegate?.takeScreenshotAction))
        let restartLabel = setupLabel(title: kLocalizedRestart, selector: #selector(delegate?.restartAction))

        if embroidery == true {
            screenshotButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -marginLabel).isActive = true

            restartLabel.bottomAnchor.constraint(equalTo: screenshotButton.topAnchor, constant: marginTopBottom * -1).isActive = true

        } else {
            screenshotButton.topAnchor.constraint(equalTo: self.centerYAnchor, constant: marginTopBottom - marginLabel).isActive = true

            restartLabel.bottomAnchor.constraint(equalTo: self.centerYAnchor, constant: marginLabel * -1).isActive = true
        }

        let restartButton = setupButton(imageName: "stage_dialog_button_restart", selector: #selector(delegate?.restartAction))
        restartButton.bottomAnchor.constraint(equalTo: restartLabel.topAnchor, constant: marginLabel * -1).isActive = true

        let continueLabel = setupLabel(title: kLocalizedContinue, selector: #selector(delegate?.continueAction))
        continueLabel.bottomAnchor.constraint(equalTo: restartButton.topAnchor, constant: marginTopBottom * -1).isActive = true

        let continueButton = setupButton(imageName: "stage_dialog_button_continue", selector: #selector(delegate?.continueAction))
        continueButton.bottomAnchor.constraint(equalTo: continueLabel.topAnchor, constant: marginLabel * -1).isActive = true

        let screenshotLabel = setupLabel(title: kLocalizedPreview, selector: #selector(delegate?.takeScreenshotAction))
        screenshotLabel.topAnchor.constraint(equalTo: screenshotButton.bottomAnchor, constant: marginLabel).isActive = true

        let axesButton = setupButton(imageName: "stage_dialog_button_toggle_axis", selector: #selector(delegate?.showHideAxisAction))
        axesButton.topAnchor.constraint(equalTo: screenshotLabel.bottomAnchor, constant: marginTopBottom).isActive = true

        let axesLabel = setupLabel(title: kLocalizedAxes, selector: #selector(delegate?.showHideAxisAction))
        axesLabel.topAnchor.constraint(equalTo: axesButton.bottomAnchor, constant: marginLabel).isActive = true

        if embroidery {
            let shareButton = setupButton(imageName: "square.and.arrow.up.reg", selector: #selector(delegate?.shareDST))
            shareButton.topAnchor.constraint(equalTo: axesLabel.bottomAnchor, constant: marginTopBottom - marginLabel).isActive = true

            let shareLabel = setupLabel(title: kLocalizedCategoryEmbroidery, selector: #selector(delegate?.shareDST))
            shareLabel.topAnchor.constraint(equalTo: shareButton.bottomAnchor, constant: marginLabel).isActive = true
        }

        let aspectRatioLabel = setupLabel(title: kLocalizedMaximize, selector: #selector(self.aspectRatioAction), target: self)
        aspectRatioLabel.translatesAutoresizingMaskIntoConstraints = false
        aspectRatioLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: (marginTopBottom - marginLabel) * -1).isActive = true
        self.aspectRatioLabel = aspectRatioLabel

        let aspectRatioButton = setupButton(imageName: "stage_dialog_button_aspect_ratio", selector: #selector(self.aspectRatioAction), target: self)
        aspectRatioButton.bottomAnchor.constraint(equalTo: aspectRatioLabel.topAnchor, constant: marginLabel * -1).isActive = true
        self.aspectRatioButton = aspectRatioButton
    }

    private func setUpButtonsLandscape() {
        let backButton = setupButton(imageName: "stage_dialog_button_back", selector: #selector(delegate?.stopAction), type: .landscapeFirstColumn)
        if #available(iOS 11.0, *) {
            backButton.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: marginTopBottom).isActive = true
        } else {
            backButton.topAnchor.constraint(equalTo: self.topAnchor, constant: marginTopBottom).isActive = true
        }

        let backLabel = setupLabel(title: kLocalizedBack, selector: #selector(delegate?.stopAction), type: .landscapeFirstColumn)
        backLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: marginLabel).isActive = true

        let continueButton = setupButton(imageName: "stage_dialog_button_continue", selector: #selector(delegate?.continueAction), type: .landscapeSecondColumn)
        if #available(iOS 11.0, *) {
            continueButton.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: marginTopBottom).isActive = true
        } else {
            continueButton.topAnchor.constraint(equalTo: self.topAnchor, constant: marginTopBottom).isActive = true
        }

        let continueLabel = setupLabel(title: kLocalizedContinue, selector: #selector(delegate?.continueAction), type: .landscapeSecondColumn)
        continueLabel.topAnchor.constraint(equalTo: continueButton.bottomAnchor, constant: marginLabel).isActive = true

        let restartButton = setupButton(imageName: "stage_dialog_button_restart", selector: #selector(delegate?.restartAction), type: .landscapeFirstColumn)
        restartButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: (marginTopBottom - marginLabel) * -1).isActive = true

        let restartLabel = setupLabel(title: kLocalizedRestart, selector: #selector(delegate?.restartAction), type: .landscapeFirstColumn)
        restartLabel.topAnchor.constraint(equalTo: restartButton.bottomAnchor, constant: marginLabel).isActive = true

        let screenshotButton = setupButton(imageName: "stage_dialog_button_screenshot", selector: #selector(delegate?.takeScreenshotAction), type: .landscapeSecondColumn)
        screenshotButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: (marginTopBottom - marginLabel) * -1).isActive = true

        let screenshotLabel = setupLabel(title: kLocalizedPreview, selector: #selector(delegate?.takeScreenshotAction), type: .landscapeSecondColumn)
        screenshotLabel.topAnchor.constraint(equalTo: screenshotButton.bottomAnchor, constant: marginLabel).isActive = true

        let axesLabel = setupLabel(title: kLocalizedAxes, selector: #selector(delegate?.showHideAxisAction), type: .landscapeFirstColumn)
        axesLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: (marginTopBottom - marginLabel) * -1).isActive = true

        let axesButton = setupButton(imageName: "stage_dialog_button_toggle_axis", selector: #selector(delegate?.showHideAxisAction), type: .landscapeFirstColumn)
        axesButton.bottomAnchor.constraint(equalTo: axesLabel.topAnchor, constant: marginLabel * -1).isActive = true

        let aspectRatioLabel = setupLabel(title: kLocalizedMaximize, selector: #selector(self.aspectRatioAction), target: self, type: .landscapeSecondColumn)
        aspectRatioLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: (marginTopBottom - marginLabel) * -1).isActive = true
        self.aspectRatioLabel = aspectRatioLabel

        let aspectRatioButton = setupButton(imageName: "stage_dialog_button_aspect_ratio", selector: #selector(self.aspectRatioAction), target: self, type: .landscapeSecondColumn)
        aspectRatioButton.bottomAnchor.constraint(equalTo: aspectRatioLabel.topAnchor, constant: marginLabel * -1).isActive = true
        self.aspectRatioButton = aspectRatioButton
    }

    @objc private func aspectRatioAction() {
        guard let aspectRatioButton = self.aspectRatioButton, let aspectRatioLabel = self.aspectRatioLabel else { return }

        if aspectRatioLabel.currentTitle == kLocalizedMaximize {
            aspectRatioLabel.setTitle(kLocalizedMinimize, for: .normal)
            setupImage("stage_dialog_button_aspect_ratio_close", for: aspectRatioButton)
         } else {
            aspectRatioLabel.setTitle(kLocalizedMaximize, for: .normal)
            setupImage("stage_dialog_button_aspect_ratio", for: aspectRatioButton)
         }

        self.delegate?.aspectRatioAction()
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

        if CGFloat(project.header.screenWidth.floatValue) == Util.screenWidth(true) && CGFloat(project.header.screenHeight.floatValue) == Util.screenHeight(true) {
            aspectRatioLabel.isHidden = true
            aspectRatioButton.isHidden = true
        } else {
            aspectRatioLabel.isHidden = false
            aspectRatioButton.isHidden = false
        }
    }

    private func setupButton(imageName: String, selector: Selector, target: Any? = nil, type: SideMenuButtonType = .portrait) -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: StagePresenterSideMenuView.buttonInitialWidthAndHeight, height: StagePresenterSideMenuView.buttonInitialWidthAndHeight))

        self.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false

        let target = target == nil ? self.delegate : target
        button.addTarget(target, action: selector, for: .touchUpInside)

        self.setupImage(imageName, for: button)

        switch type {
        case .portrait:
            button.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            button.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        case .landscapeFirstColumn:
            button.rightAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            button.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        case .landscapeSecondColumn:
            button.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            button.leftAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
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

        let target = target == nil ? self.delegate : target
        label.addTarget(target, action: selector, for: .touchUpInside)

        switch type {
        case .portrait:
            label.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        case .landscapeFirstColumn:
            label.rightAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        case .landscapeSecondColumn:
            label.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        }

        return label
    }

    private func setupImage(_ imageName: String, for button: UIButton) {
        let sizeFactor = landscape ? 1 : 2
        let dividingConstant = self.frame.size.width / (self.frame.size.height / (CGFloat(sizeFactor * (numberOfButtons + 2))))
        button.frame.size.width = CGFloat(StagePresenterSideMenuView.buttonInitialWidthAndHeight)
        button.frame.size.height = CGFloat(StagePresenterSideMenuView.buttonInitialWidthAndHeight)

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
        }    }
}
