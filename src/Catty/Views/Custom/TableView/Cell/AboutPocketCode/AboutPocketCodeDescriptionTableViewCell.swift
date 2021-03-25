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

protocol AboutPocketCodeDelegate: AnyObject {
    func didTapOpenCatrobatWebsite(_ sender: SettingsButton)
    func didTapSourceCodeLicense(_ sender: SettingsButton)
}

class AboutPocketCodeDescriptionTableViewCell: SettingsTableViewCell {

    static let identifier = "AboutPocketCodeDescriptionTableViewCell"

    var aboutDescription: UILabel!
    var openCatrobatWebsiteButton: SettingsButton!
    var sourceCodeLicenseButton: SettingsButton!
    var centerTopDivider: UIView!
    var centerBottomDivider: UIView!

    weak var delegate: AboutPocketCodeDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupDescription()
        setupTopCenterDivider()
        setupOpenCatrobatButton()
        setupBottomCenterDivider()
        setupSourceCodeLicenceButton()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupDescription()
        setupTopCenterDivider()
        setupOpenCatrobatButton()
        setupBottomCenterDivider()
        setupSourceCodeLicenceButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupDescription() {
        aboutDescription = UILabel()
        aboutDescription.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(aboutDescription)
        aboutDescription.font = UIFont.systemFont(ofSize: 12)
        aboutDescription.textColor = UIColor.lightGray
        aboutDescription.numberOfLines = 0
        aboutDescription.text = kLocalizedAboutPocketCodeDescription
        NSLayoutConstraint.activate([
            aboutDescription.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            aboutDescription.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            aboutDescription.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20)
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
            centerTopDivider.topAnchor.constraint(equalTo: aboutDescription.bottomAnchor, constant: 20)
        ])
    }

    private func setupOpenCatrobatButton() {
        openCatrobatWebsiteButton = SettingsButton(type: .system)
        contentView.addSubview(openCatrobatWebsiteButton)
        openCatrobatWebsiteButton.translatesAutoresizingMaskIntoConstraints = false
        openCatrobatWebsiteButton.configure(title: kLocalizedOpenCatrobatWebsite)
        openCatrobatWebsiteButton.setDefault()
        openCatrobatWebsiteButton.addTarget(self, action: #selector(didTapOpenCatrobatWebsite(_:)), for: .touchUpInside)
        NSLayoutConstraint.activate([
            openCatrobatWebsiteButton.heightAnchor.constraint(equalToConstant: SettingsButton.defaultHeight),
            openCatrobatWebsiteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            openCatrobatWebsiteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            openCatrobatWebsiteButton.topAnchor.constraint(equalTo: centerTopDivider.bottomAnchor)
        ])
    }

    private func setupBottomCenterDivider() {
        centerBottomDivider = UIView()
        contentView.addSubview(centerBottomDivider)
        centerBottomDivider.translatesAutoresizingMaskIntoConstraints = false
        centerBottomDivider.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        NSLayoutConstraint.activate([
            centerBottomDivider.heightAnchor.constraint(equalToConstant: 1),
            centerBottomDivider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            centerBottomDivider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            centerBottomDivider.topAnchor.constraint(equalTo: openCatrobatWebsiteButton.bottomAnchor)
        ])
    }

    private func setupSourceCodeLicenceButton() {
        sourceCodeLicenseButton = SettingsButton(type: .system)
        contentView.addSubview(sourceCodeLicenseButton)
        sourceCodeLicenseButton.translatesAutoresizingMaskIntoConstraints = false
        sourceCodeLicenseButton.configure(title: kLocalizedSourceCodeLicenseButtonLabel)
        sourceCodeLicenseButton.setDefault()
        sourceCodeLicenseButton.addTarget(self, action: #selector(didTapSourceCodeLicense(_:)), for: .touchUpInside)
        NSLayoutConstraint.activate([
            sourceCodeLicenseButton.heightAnchor.constraint(equalToConstant: SettingsButton.defaultHeight),
            sourceCodeLicenseButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            sourceCodeLicenseButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            sourceCodeLicenseButton.topAnchor.constraint(equalTo: centerBottomDivider.bottomAnchor),
            sourceCodeLicenseButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    @objc private func didTapOpenCatrobatWebsite(_ sender: SettingsButton) {
        delegate?.didTapOpenCatrobatWebsite(sender)
    }

    @objc private func didTapSourceCodeLicense(_ sender: SettingsButton) {
        delegate?.didTapSourceCodeLicense(sender)
    }
}
