/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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
class SelectButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        var unselectedImage = UIImage(named: "unselected_button")
        var selectedImage = UIImage(named: "selected_button")
        unselectedImage = unselectedImage?.withRenderingMode(.alwaysTemplate)
        selectedImage = selectedImage?.withRenderingMode(.alwaysTemplate)

        setBackgroundImage(unselectedImage, for: .normal)
        setBackgroundImage(selectedImage, for: .selected)

        tintColor = UIColor.globalTint
    }

    override func backgroundRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: self.frame.width / 4,
                      y: self.frame.height / 4,
                      width: self.frame.width / 2,
                      height: self.frame.height / 2)
    }
}
