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
extension UITextField {
    /*
     * https://medium.com/nyc-design/swift-4-add-icon-to-uitextfield-48f5ebf60aa1
     */
    func setIcon(_ image: UIImage) {
        if image.size.width > 0 && image.size.height > 0 {
            let iconView = UIImageView(frame: CGRect(x: 5, y: 5, width: 50, height: 50))
            iconView.image = image.withRenderingMode(.alwaysTemplate)
            let iconContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
            iconContainerView.addSubview(iconView)
            leftView = iconContainerView
            leftViewMode = .always
        }
    }
}
