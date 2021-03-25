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

protocol AboutUsDelegate: AnyObject {
    func didTapAboutUs(_ sender: SettingsButton)
}

class AboutUsTableViewCell: UITableViewCell {

    static let identifier = "AboutUsTableViewCell"

    private var cellTitle: SettingsPageCellHeaderView!
    private var aboutUsButton: SettingsButton!
    private var topDivider: UIView!
    private var bottomDivider: UIView!

    weak var delegate: AboutUsDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCellTitle()
        setupAboutUsButton()
        setupBottomSeperator()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellTitle()
        setupAboutUsButton()
        setupBottomSeperator()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCellTitle() {
        cellTitle = SettingsPageCellHeaderView()
        contentView.addSubview(cellTitle)
        cellTitle.translatesAutoresizingMaskIntoConstraints = false
        cellTitle.configure(title: kLocalizedAboutSection)
        NSLayoutConstraint.activate([
            cellTitle.heightAnchor.constraint(equalToConstant: SettingsPageCellHeaderView.defaultHeaderHeight),
            cellTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellTitle.topAnchor.constraint(equalTo: contentView.topAnchor)
        ])
    }

    func setupAboutUsButton() {
        aboutUsButton = SettingsButton(type: .system)
        contentView.addSubview(aboutUsButton)
        aboutUsButton.translatesAutoresizingMaskIntoConstraints = false
        aboutUsButton.addTarget(self, action: #selector(didTapAboutUsButton(_:)), for: .touchUpInside)
        aboutUsButton.configure(
            title: kLocalizedAboutUs,
            rightIcon: UIImage(named: "continue")
        )
        NSLayoutConstraint.activate([
            aboutUsButton.heightAnchor.constraint(equalToConstant: SettingsButton.defaultHeight),
            aboutUsButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            aboutUsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            aboutUsButton.topAnchor.constraint(equalTo: cellTitle.bottomAnchor)
        ])
    }

    func setupBottomSeperator() {
        bottomDivider = UIView()
        contentView.addSubview(bottomDivider)
        bottomDivider.translatesAutoresizingMaskIntoConstraints = false
        bottomDivider.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        NSLayoutConstraint.activate([
            bottomDivider.heightAnchor.constraint(equalToConstant: 1),
            bottomDivider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomDivider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomDivider.topAnchor.constraint(equalTo: aboutUsButton.bottomAnchor),
            bottomDivider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    @objc func didTapAboutUsButton(_ sender: SettingsButton) {
        delegate?.didTapAboutUs(sender)
    }

}
