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

import Foundation
import UIKit

@objc protocol VisualPlacementViewControllerDelegate {
    func doneVisualPlacement()
    func cancelVisualPlacement()
}

@objcMembers class VisualPlacementViewController: UIViewController {
    @IBOutlet private weak var objectImageView: UIImageView!
    @IBOutlet private weak var oldPositionObjectImageView: UIImageView!
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var doneButton: UIButton!
    @IBOutlet private weak var titleLabel: UILabel!

    weak var delegate: VisualPlacementViewControllerDelegate?
    static var lookScalingDictionary = [String: Double] ()
    var objectImage: UIImage?
    var backgroundImage: UIImage?
    var isDragging = false
    var imageWidth = 100.0
    var imageHeight = 100.0
    var scaleFactor = 1.0
    var oldPositionInView = CGPoint(x: 0.0, y: 0.0)
    var centerPositionInView = CGPoint(x: 0.0, y: 0.0)
    var centerPositionInStage = CGPoint(x: 0.0, y: 0.0)
    var stageSize = CGSize(width: 0.0, height: 0.0)
    var brick: BrickVisualPlacementProtocol!
    var object: SpriteObject!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let navigationController = navigationController else { return }
        navigationController.setNavigationBarHidden(true, animated: animated)
        navigationController.setToolbarHidden(true, animated: animated)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = [UIRectEdge.top, UIRectEdge.left, UIRectEdge.right, UIRectEdge.bottom]
        self.extendedLayoutIncludesOpaqueBars = true

        backgroundImageView.alpha = 0.5
        oldPositionObjectImageView.alpha = 0.5

        if let backgroundImage = backgroundImage {
            backgroundImageView.image = backgroundImage
        }
        self.setupObjectImageView(self.objectImageView)
        self.setupObjectImageView(self.oldPositionObjectImageView)
        self.setupNavigationBar()

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let navigationController = navigationController else { return }
        navigationController.setNavigationBarHidden(false, animated: animated)
        navigationController.setToolbarHidden(false, animated: animated)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    func initWith(brick: BrickVisualPlacementProtocol, andObject object: SpriteObject) {

        let screenshotFileName = object.projectPath() + kScreenshotAutoFullScreenFilename
        self.backgroundImage = UIImage.init(contentsOfFile: screenshotFileName)
        if self.backgroundImage == nil,
           let backgroundObject = object.scene.objects().first,
           let backgroundImagePath = backgroundObject.previewImagePath() {
            self.backgroundImage = UIImage.init(contentsOfFile: backgroundImagePath)
        }

        self.brick = brick
        self.centerPositionInStage.x = brick.xPosition.formulaTree.getSingleNumberFormulaValue()
        self.centerPositionInStage.y = brick.yPosition.formulaTree.getSingleNumberFormulaValue()
        self.object = object

        stageSize = CGSize(width: object.scene.project?.header.screenWidth.doubleValue ?? 0, height: object.scene.project?.header.screenHeight.doubleValue ?? 0)
        centerPositionInView = CBSceneHelper.convertPointToTouchCoordinate(point: centerPositionInStage, stageSize: stageSize)

        let screenSize = Util.screenSize(false)
        scaleFactor = (screenSize.width / stageSize.width)

        if let objectImagePath = object.previewImagePath() {
            self.objectImage = UIImage.init(contentsOfFile: objectImagePath)
        }
    }

    func setupNavigationBar() {
        cancelButton.setTitle(kLocalizedCancel, for: .normal)
        doneButton.setTitle(kLocalizedDone, for: .normal)
        titleLabel.text = kLocalizedPlaceVisually
    }

    func setupObjectImageView(_ imageView: UIImageView) {
        if let objectImage = objectImage {
            var catrobatScaling = 1.0
            if let scaling = VisualPlacementViewController.lookScalingDictionary[object.name] {
                catrobatScaling = scaling
            }
            catrobatScaling = catrobatScaling == 0 ? 1.0 : catrobatScaling
            imageWidth = objectImage.size.width * self.scaleFactor * catrobatScaling
            imageHeight = objectImage.size.height * self.scaleFactor * catrobatScaling
            imageView.image = objectImage
        }
        imageView.frame.size.width = imageWidth
        imageView.frame.size.height = imageHeight
        imageView.frame.origin.x = centerPositionInView.x - imageWidth / 2
        imageView.frame.origin.y = centerPositionInView.y - imageHeight / 2
    }

    @IBAction private func cancelTapped(_ sender: Any) {
        dismiss(animated: true) {
            if let delegate = self.delegate {
                delegate.cancelVisualPlacement()
            }
        }
    }

    @IBAction private func doneTapped(_ sender: Any) {
        let newPositionInStage = CBSceneHelper.convertTouchCoordinateToPoint(coordinate: self.centerPositionInView, stageSize: self.stageSize)
        brick.xPosition = Formula(integer: Int32(newPositionInStage.x))
        brick.yPosition = Formula(integer: Int32(newPositionInStage.y))
        guard let project = object.scene.project else { return }
        project.saveToDisk(withNotification: true) {
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                    if let delegate = self.delegate {
                        delegate.doneVisualPlacement()
                    }

                }
            }
        }
    }
}

extension VisualPlacementViewController {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: objectImageView)
        if objectImageView!.bounds.contains(touchLocation) {
            isDragging = true
            oldPositionInView = touchLocation
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDragging, let touch = touches.first else {
            return
        }

        let touchLocation = touch.location(in: view)
        objectImageView!.frame.origin.x = touchLocation.x - oldPositionInView.x
        objectImageView!.frame.origin.y = touchLocation.y - oldPositionInView.y
        centerPositionInView.x = objectImageView!.frame.origin.x + imageWidth / 2
        centerPositionInView.y = objectImageView!.frame.origin.y + imageHeight / 2
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = false
    }
}
