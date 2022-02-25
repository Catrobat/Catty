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

@objc
class UIDefines: NSObject {
    @objc static let previewImageSize = CGSize(width: Int(kPreviewThumbnailWidth), height: Int(kPreviewThumbnailHeight))
    static let previewImageCornerRadius = 10.0
    static let previewImageBorderWidth = 1.0

    static let brickCategoryHeight = CGFloat(70)
    @objc static let brickCategorySectionInset = CGFloat(10.0)
    @objc static let brickCategoryBrickInset = CGFloat(5.0)

    static let formulaEditorComputeRefreshInterval = 1.0

    static let defaultScreenshots = ["catrobat", "elephant", "lynx", "panda", "pingu", "racoon"]

    static let playButtonAccessibilityLabel = "Play"
    @objc static let variablePickerAccessibilityLabel = "VariableView"
    @objc static let listPickerAccessibilityLabel = "ListView"
    @objc static let messagePickerAccessibilityLabel = "MessageView"
    @objc static let lookPickerAccessibilityLabel = "LookView"
    @objc static let backgroundPickerAccessibilityLabel = "BackgroundView"
    @objc static let iOS12OrLessAccessibilityLabel = "iOS 12.0 or less"

    static let recentlyUsedBricksMinSize = 1
    static let recentlyUsedBricksMaxSize = 10

    // Screen Sizes in Points
    @objc static let iPhone4ScreenHeight = CGFloat(480.0)
    @objc static let iPhone5ScreenHeight = CGFloat(568.0)
    @objc static let iPhone6PScreenHeight = CGFloat(736.0)
    @objc static let iPadScreenHeight = CGFloat(1028.0)

    // ScenePresenterViewController
    @objc static let slidingStartArea = 40
    @objc static let firstSwipeDuration = CGFloat(0.65)
    @objc static let hideMenuViewDelay = CGFloat(0.45)

    // Blocked characters for project names, object names, images names, sounds names and variable/list names
    @objc static let textFieldBlockedCharacters = ""

    @objc static let menuImageNameContinue = "continue"
    @objc static let menuImageNameNew = "new"
    @objc static let menuImageNameProjects = "projects"
    @objc static let menuImageNameHelp = "help"
    @objc static let menuImageNameExplore = "explore"
    @objc static let menuImageNameUpload = "upload"

    // view tag
    @objc static let savedViewTag = Int(99996)

    // delete button bricks
    @objc static let brickCellDeleteButtonWidthHeight = CGFloat(55.0)
    @objc static let selectButtonOffset = CGFloat(30.0)
    @objc static let selectButtonTranslationOffsetX = CGFloat(60.0)

    // UI Elements
    @objc static let toolbarHeight = CGFloat(44.0)

    //BDKNotifyHUD
    @objc static let bdkNotifyHUDDestinationOpacity = CGFloat(0.3)
    @objc static let bdkNotifyHUDCenterOffsetY = CGFloat(-20.0)
    @objc static let bdkNotifyHUDPresentationDuration = CGFloat(0.5)
    @objc static let bdkNotifyHUDPresentationSpeed = CGFloat(0.1)
    @objc static let bdkNotifyHUDCheckmarkImageName = "checkmark.png"

    // ---------------------- BRICK CONFIG ---------------------------------------
    @objc static let whenScriptDefaultAction = "Tapped" // at the moment Catrobat only supports this type of action for WhenScripts

    // brick heights
    @objc static let brickHeight1h = CGFloat(55.9)
    @objc static let brickHeight2h = CGFloat(75.9)
    @objc static let brickHeight3h = CGFloat(98.9)
    @objc static let brickHeightControl1h = CGFloat(72.4)
    @objc static let brickHeightControl2h = CGFloat(99.4)

    @objc static let brickOverlapHeight = CGFloat(-4.4)

    // brick subview const values
    @objc static let brickInlineViewOffsetX = CGFloat(54.0)
    @objc static let brickShapeNormalInlineViewOffsetY = CGFloat(4.0)
    @objc static let brickShapeRoundedSmallInlineViewOffsetY = CGFloat(20.7)
    @objc static let brickShapeRoundedBigInlineViewOffsetY = CGFloat(37.0)
    @objc static let brickShapeNormalMarginHeightDeduction = CGFloat(14.0)
    @objc static let brickShapeRoundedSmallMarginHeightDeduction = CGFloat(27.0)
    @objc static let brickShapeRoundedBigMarginHeightDeduction = CGFloat(47.0)
    @objc static let brickInlineViewCanvasOffsetX = CGFloat(0.0)
    @objc static let brickInlineViewCanvasOffsetY = CGFloat(0.0)

    @objc static let brickLabelFontSize = CGFloat(15.0)
    @objc static let brickTextFieldFontSize = CGFloat(15.0)
    @objc static let brickInputFieldHeight = CGFloat(28.0)
    @objc static let brickInputFieldMinWidth = CGFloat(40.0)
    @objc static let brickInputFieldMaxWidth = CGFloat(Util.screenWidth() / 2.0)
    @objc static let brickComboBoxWidth = CGFloat(Util.screenWidth() - 65)
    @objc static let brickInputFieldTopMargin = CGFloat(4.0)
    @objc static let brickInputFieldBottomMargin = CGFloat(5.0)
    @objc static let brickInputFieldLeftMargin = CGFloat(4.0)
    @objc static let brickInputFieldRightMargin = CGFloat(4.0)
    @objc static let brickInputFieldMinRowHeight = brickInputFieldHeight
    @objc static let defaultImageCellBorderWidth = CGFloat(0.5)
}
