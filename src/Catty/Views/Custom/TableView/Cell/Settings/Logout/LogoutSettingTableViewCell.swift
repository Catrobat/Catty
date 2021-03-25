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

protocol LogoutDelegate: AnyObject {
    func didTapLogout()
}

class LogoutSettingTableViewCell: SettingsTableViewCell {

    static let identifier = "LogoutSettingTableViewCell"

    private var topDivider: UIView!
    private var logoutButton: SettingsButton!

    weak var delegate: LogoutDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCell() {
        topDivider = UIView()
        contentView.addSubview(topDivider)
        topDivider.translatesAutoresizingMaskIntoConstraints = false
        topDivider.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)

        logoutButton = SettingsButton(type: .system)
        contentView.addSubview(logoutButton)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.addTarget(self, action: #selector(didTapLogout(_:)), for: .touchUpInside)
        logoutButton.setTitleColor(UIColor.variableBrickRed, for: .normal)
        logoutButton.setTitle(kLocalizedLogout, for: .normal)

        NSLayoutConstraint.activate([
            topDivider.heightAnchor.constraint(equalToConstant: 1),
            topDivider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topDivider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topDivider.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),

            logoutButton.topAnchor.constraint(equalTo: topDivider.topAnchor),
            logoutButton.heightAnchor.constraint(equalToConstant: SettingsButton.defaultHeight),
            logoutButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            logoutButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    @objc private func didTapLogout(_ sender: UIButton) {
        delegate?.didTapLogout()
    }

}
