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

class SettingsPageCellHeaderView: UIView {

    static let defaultHeaderHeight: CGFloat = 60

    private var title: UILabel!

    private var divider: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDivider()
        setupHeading()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    private func setupHeading() {
        title = UILabel()
        self.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textColor = UIColor.gray
        title.font = UIFont.systemFont(ofSize: 12)

        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            title.bottomAnchor.constraint(equalTo: divider.bottomAnchor, constant: -8),
            title.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            title.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor, constant: 20)
        ])
    }

    private func setupDivider() {
        divider = UIView()
        self.addSubview(divider)
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)

        NSLayoutConstraint.activate([
            divider.heightAnchor.constraint(equalToConstant: 1),
            divider.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            divider.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    public func configure(title: String) {
        self.title.text = title
    }

}
