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

@objc
class UIDefines: NSObject {
    @objc static let previewImageSize = CGSize(width: Int(kPreviewThumbnailWidth), height: Int(kPreviewThumbnailHeight))
    static let previewImageCornerRadius = 10.0
    static let previewImageBorderWidth = 1.0

    static let brickCategoryHeight = CGFloat(70)
    @objc static let brickCategorySectionInset = CGFloat(10.0)
    @objc static let brickCategoryBrickInset = CGFloat(5.0)

    static let defaultScreenshots = ["catrobat", "elephant", "lynx", "panda", "pingu", "racoon"]

    static let playButtonAccessibilityLabel = "Play"
    @objc static let variablePickerAccessibilityLabel = "VariableView"
    @objc static let listPickerAccessibilityLabel = "ListView"
    @objc static let messagePickerAccessibilityLabel = "MessageView"
    @objc static let lookPickerAccessibilityLabel = "LookView"
    @objc static let backgroundPickerAccessibilityLabel = "BackgroundView"
    @objc static var iOS12OrLessAccessibilityLabel = "iOS 12.0 or less"
}
