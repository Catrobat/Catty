/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

extension UIView {

    // MARK: Safe Area wrapper

    var safeTopAnchor: NSLayoutYAxisAnchor {
        safeAreaLayoutGuide.topAnchor
    }

    var safeLeftAnchor: NSLayoutXAxisAnchor {
        safeAreaLayoutGuide.leftAnchor
    }

    var safeRightAnchor: NSLayoutXAxisAnchor {
        safeAreaLayoutGuide.rightAnchor
    }

    var safeBottomAnchor: NSLayoutYAxisAnchor {
        safeAreaLayoutGuide.bottomAnchor
    }

    var safeSuperViewCenterXAnchor: NSLayoutXAxisAnchor {
        (self.superview?.safeAreaLayoutGuide.centerXAnchor)!
    }

    var safeSuperViewCenterYAnchor: NSLayoutYAxisAnchor {
        (self.superview?.safeAreaLayoutGuide.centerYAnchor)!
    }

    // MARK: View helper functions

    func setAnchors(
        top: NSLayoutYAxisAnchor?,
        left: NSLayoutXAxisAnchor?,
        right: NSLayoutXAxisAnchor?,
        bottom: NSLayoutYAxisAnchor?,
        topPadding: CGFloat = 0,
        leftPadding: CGFloat = 0,
        rightPadding: CGFloat = 0,
        bottomPadding: CGFloat = 0,
        width: CGFloat = 0,
        height: CGFloat = 0) {

        self.translatesAutoresizingMaskIntoConstraints = false

        if top != nil {
            self.topAnchor.constraint(equalTo: top!, constant: topPadding).isActive = true
        }
        if left != nil {
            self.leftAnchor.constraint(equalTo: left!, constant: leftPadding).isActive = true
        }
        if right != nil {
            self.rightAnchor.constraint(equalTo: right!, constant: -rightPadding).isActive = true
        }
        if bottom != nil {
            self.bottomAnchor.constraint(equalTo: bottom!, constant: -bottomPadding).isActive = true
        }
        if width != 0 {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if height != 0 {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }

    func centerView() {
        self.centerXAnchor.constraint(equalTo: self.safeSuperViewCenterXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: self.safeSuperViewCenterYAnchor).isActive = true
    }
}
