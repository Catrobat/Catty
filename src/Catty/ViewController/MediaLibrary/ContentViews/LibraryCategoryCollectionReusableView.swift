/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

class LibraryCategoryCollectionReusableView: UICollectionReusableView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var borderView: UIView!
    @IBOutlet private weak var borderThicknessConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.borderView.backgroundColor = UIColor.utilityTint
        self.borderThicknessConstraint.constant = UIDefines.defaultImageCellBorderWidth
    }

    var title: String {
        get {
            titleLabel.text!
        }
        set {
            titleLabel.text = newValue
        }
    }

    var titleColor: UIColor {
        get {
            titleLabel.textColor!
        }
        set {
            titleLabel.textColor = newValue
        }
    }
}
