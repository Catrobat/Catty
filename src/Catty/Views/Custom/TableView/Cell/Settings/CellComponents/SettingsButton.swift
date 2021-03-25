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

class SettingsButton: UIButton {

    static let defaultHeight: CGFloat = 40

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.imageView?.contentMode = .scaleAspectFit
        self.tintColor = UIColor.lightGray
        self.setTitleColor(UIColor.black, for: .normal)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        var leadingPadding: CGFloat!
        if imageView?.image != nil {
            self.imageEdgeInsets = UIEdgeInsets(
                top: 10,
                left: (self.bounds.width - 35),
                bottom: 10,
                right: 20)
            leadingPadding = 25
        } else {
            leadingPadding = 40
        }
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: -(self.bounds.width) + (self.titleLabel?.bounds.width ?? 0) + leadingPadding,
            bottom: 0,
            right: 0 )
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.semanticContentAttribute = .forceRightToLeft
    }

    public func configure(title: String?, rightIcon: UIImage? = nil) {
        self.setTitle(title, for: .normal)
        self.setImage(rightIcon, for: .normal)
    }

    public func setDefault(){
        self.setTitleColor(nil, for: .normal)
        self.tintColor = nil
    }
}
