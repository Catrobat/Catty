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

protocol MoreSettingsDelegate: AnyObject {
    func didTapTOS(_ sender: SettingsButton)
    func didTapRateUs(_ sender: SettingsButton)
}

class MoreSettingsTableViewCell: SettingsTableViewCell {

    static let identifier = "MoreSettingsTableViewCell"

    var cellTitle: SettingsPageCellHeaderView!
    var versionTitle: UILabel!
    var versionTag: UILabel!
    var versionInfoStack: UIStackView!
    var tosButton: SettingsButton!
    var rateButton: SettingsButton!
    var topCenterDivider: UIView!
    var bottomCenterDivider: UIView!

    weak var delegate: MoreSettingsDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCellHeader()
        setupVersionInfo()
        setupTopCenterDivider()
        setupTOS()
        setupBottomCenterDivider()
        setupRateButton()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellHeader()
        setupVersionInfo()
        setupTopCenterDivider()
        setupTOS()
        setupBottomCenterDivider()
        setupRateButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCellHeader() {
        cellTitle = SettingsPageCellHeaderView()
        contentView.addSubview(cellTitle)
        cellTitle.translatesAutoresizingMaskIntoConstraints = false
        cellTitle.configure(title: kLocalizedMore)
        NSLayoutConstraint.activate([
            cellTitle.heightAnchor.constraint(equalToConstant: SettingsPageCellHeaderView.defaultHeaderHeight),
            cellTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellTitle.topAnchor.constraint(equalTo: contentView.topAnchor)
        ])
    }

    private func setupVersionInfo() {
        versionInfoStack = UIStackView()
        contentView.addSubview(versionInfoStack)
        versionInfoStack.translatesAutoresizingMaskIntoConstraints = false
        versionInfoStack.axis = .horizontal
        versionInfoStack.distribution = UIStackView.Distribution.equalCentering

        versionTitle = UILabel()
        versionTitle.font = UIFont.systemFont(ofSize: 16)
        contentView.addSubview(versionTitle)
        versionTitle.translatesAutoresizingMaskIntoConstraints = false
        versionTitle.text = kLocalizedVersion

        versionTag = UILabel()
        versionTag.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        contentView.addSubview(versionTag)
        versionTag.translatesAutoresizingMaskIntoConstraints = false

        let object = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        var version = "\(kLocalizedVersionLabel)\(object!) (\(Util.appBuildVersion()!))"
        #if DEBUG
            version = "\(String(describing: version))(\(kLocalizedDebugMode))"
        #endif
        versionTag.text = version

        versionInfoStack.addArrangedSubview(versionTitle)
        versionInfoStack.addArrangedSubview(versionTag)

        NSLayoutConstraint.activate([
            versionInfoStack.heightAnchor.constraint(equalToConstant: 40),
            versionInfoStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            versionInfoStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            versionInfoStack.topAnchor.constraint(equalTo: cellTitle.bottomAnchor)
        ])
    }

    private func setupTopCenterDivider() {
        topCenterDivider = UIView()
        contentView.addSubview(topCenterDivider)
        topCenterDivider.translatesAutoresizingMaskIntoConstraints = false
        topCenterDivider.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        NSLayoutConstraint.activate([
            topCenterDivider.heightAnchor.constraint(equalToConstant: 1),
            topCenterDivider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            topCenterDivider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            topCenterDivider.topAnchor.constraint(equalTo: versionInfoStack.bottomAnchor)
        ])
    }

    private func setupTOS() {
        tosButton = SettingsButton(type: .system)
        contentView.addSubview(tosButton)
        tosButton.translatesAutoresizingMaskIntoConstraints = false
        tosButton.configure(title: kLocalizedTermsOfUse, rightIcon: UIImage(named: "continue"))
        tosButton.addTarget(self, action: #selector(didTapTOS(_:)), for: .touchUpInside)
        NSLayoutConstraint.activate([
            tosButton.heightAnchor.constraint(equalToConstant: SettingsButton.defaultHeight),
            tosButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tosButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tosButton.topAnchor.constraint(equalTo: topCenterDivider.bottomAnchor)
        ])
    }

    private func setupBottomCenterDivider() {
        bottomCenterDivider = UIView()
        contentView.addSubview(bottomCenterDivider)
        bottomCenterDivider.translatesAutoresizingMaskIntoConstraints = false
        bottomCenterDivider.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        NSLayoutConstraint.activate([
            bottomCenterDivider.heightAnchor.constraint(equalToConstant: 1),
            bottomCenterDivider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bottomCenterDivider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            bottomCenterDivider.topAnchor.constraint(equalTo: tosButton.bottomAnchor)
        ])
    }

    private func setupRateButton() {
        rateButton = SettingsButton(type: .system)
        contentView.addSubview(rateButton)
        rateButton.translatesAutoresizingMaskIntoConstraints = false
        rateButton.configure(title: kLocalizedRateUs)
        rateButton.addTarget(self, action: #selector(didTapRateUs(_:)), for: .touchUpInside)
        NSLayoutConstraint.activate([
            rateButton.heightAnchor.constraint(equalToConstant: SettingsButton.defaultHeight),
            rateButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            rateButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            rateButton.topAnchor.constraint(equalTo: bottomCenterDivider.bottomAnchor),
            rateButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    @objc private func didTapTOS(_ sender: SettingsButton) {
        delegate?.didTapTOS(sender)
    }

    @objc private func didTapRateUs(_ sender: SettingsButton) {
        delegate?.didTapRateUs(sender)
    }
}
