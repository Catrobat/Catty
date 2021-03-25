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

protocol TermsOfUseAndServiceDelegate: AnyObject {
   func didTapViewTOS(_ sender: SettingsButton)
}

class TermsOfUseAndServiceTableViewCell: SettingsTableViewCell {

    static let identifier = "TermsOfUseAndServiceTableViewCell"

    var termsOfUseAndService: UILabel!
    var viewTOSButton: SettingsButton!
    var centerTopDivider: UIView!

    weak var delegate: TermsOfUseAndServiceDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupDescription()
        setupTopCenterDivider()
        setupOpenCatrobatButton()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupDescription()
        setupTopCenterDivider()
        setupOpenCatrobatButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupDescription() {
        termsOfUseAndService = UILabel()
        termsOfUseAndService.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(termsOfUseAndService)
        termsOfUseAndService.font = UIFont.systemFont(ofSize: 12)
        termsOfUseAndService.textColor = UIColor.lightGray
        termsOfUseAndService.numberOfLines = 0
        termsOfUseAndService.text = kLocalizedTermsOfUseDescription
        NSLayoutConstraint.activate([
            termsOfUseAndService.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            termsOfUseAndService.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            termsOfUseAndService.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20)
        ])
    }

    private func setupTopCenterDivider() {
        centerTopDivider = UIView()
        contentView.addSubview(centerTopDivider)
        centerTopDivider.translatesAutoresizingMaskIntoConstraints = false
        centerTopDivider.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        NSLayoutConstraint.activate([
            centerTopDivider.heightAnchor.constraint(equalToConstant: 1),
            centerTopDivider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            centerTopDivider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            centerTopDivider.topAnchor.constraint(equalTo: termsOfUseAndService.bottomAnchor, constant: 20)
        ])
    }

    private func setupOpenCatrobatButton() {
        viewTOSButton = SettingsButton(type: .system)
        contentView.addSubview(viewTOSButton)
        viewTOSButton.translatesAutoresizingMaskIntoConstraints = false
        viewTOSButton.configure(title: kLocalizedViewTermsOfUse)
        viewTOSButton.setDefault()
        viewTOSButton.addTarget(self, action: #selector(didTapViewTOS(_:)), for: .touchUpInside)
        NSLayoutConstraint.activate([
            viewTOSButton.heightAnchor.constraint(equalToConstant: SettingsButton.defaultHeight),
            viewTOSButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            viewTOSButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            viewTOSButton.topAnchor.constraint(equalTo: centerTopDivider.bottomAnchor),
            viewTOSButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    @objc private func didTapViewTOS(_ sender: SettingsButton) {
        delegate?.didTapViewTOS(sender)
    }
}
