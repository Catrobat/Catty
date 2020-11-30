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

import UIKit

class BrickCategoryOverviewCollectionViewCell: UICollectionViewCell {
    static let identifier = "BrickCategoryOverviewCollectionViewCell"

    private let categoryName: UILabel = {
        var categoryName = UILabel()
        categoryName.text = "category"
        categoryName.textColor = UIColor.white
        return categoryName
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(categoryName)
        contentView.clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        categoryName.frame = CGRect(x: 20,
                                    y: 0,
                                    width: contentView.frame.size.width,
                                    height: contentView.frame.size.height)
    }

    public func configure(label: String) {
        categoryName.text = label
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        categoryName.text = nil
    }
}
