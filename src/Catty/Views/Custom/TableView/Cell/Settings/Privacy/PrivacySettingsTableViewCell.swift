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

protocol PrivacySettingsDelegate: AnyObject {
    func didTapPrivacyPolicyButton(_ sender: SettingsButton)
    func didToggleCrashReports(isOn: Bool)
}

class PrivacySettingsTableViewCell: SettingsTableViewCell {

    static let identifier = "PrivacySettingsTableViewCell"

    private var cellTitle: SettingsPageCellHeaderView!
    private var privacySetting: SettingToggleView!
    private var privacyPolicyButton: SettingsButton!
    private var centerDivider: UIView!
    private var bottomDivider: UIView!

    weak var delegate: PrivacySettingsDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCellTitle()
        setupAnonCrashReportsToggle()
        setupCenterDivider()
        setupPrivacyPolicyButton()
//        setupBottomDivider()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellTitle()
        setupAnonCrashReportsToggle()
        setupCenterDivider()
        setupPrivacyPolicyButton()
//        setupBottomDivider()
//        layoutSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupCellTitle() {
        cellTitle = SettingsPageCellHeaderView()
        contentView.addSubview(cellTitle)
        cellTitle.translatesAutoresizingMaskIntoConstraints = false
        cellTitle.configure(title: kLocalizedPrivacySection)
        NSLayoutConstraint.activate([
            cellTitle.heightAnchor.constraint(equalToConstant: SettingsPageCellHeaderView.defaultHeaderHeight),
            cellTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellTitle.topAnchor.constraint(equalTo: contentView.topAnchor)
        ])
    }

    func setupAnonCrashReportsToggle() {
        privacySetting = SettingToggleView()
        contentView.addSubview(privacySetting)
        privacySetting.translatesAutoresizingMaskIntoConstraints = false
        privacySetting.delegate = self
        privacySetting.setupToggleAccessibilityLabel(label: kLocalizedSendCrashReports)
        privacySetting.configure(
            title: kLocalizedSendCrashReports,
            description: kLocalizedSendCrashReportsDescription
        )
        NSLayoutConstraint.activate([
            privacySetting.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            privacySetting.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            privacySetting.topAnchor.constraint(equalTo: cellTitle.bottomAnchor)
        ])

        if UserDefaults.standard.bool(forKey: kFirebaseSendCrashReports) {
            privacySetting.setSwitchIsOn(isOn: true)
            return
        }
        privacySetting.setSwitchIsOn(isOn: false)
    }

    func setupCenterDivider() {
        centerDivider = UIView()
        contentView.addSubview(centerDivider)
        centerDivider.translatesAutoresizingMaskIntoConstraints = false
        centerDivider.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        NSLayoutConstraint.activate([
            centerDivider.heightAnchor.constraint(equalToConstant: 1),
            centerDivider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            centerDivider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            centerDivider.topAnchor.constraint(equalTo: privacySetting.bottomAnchor)
        ])
    }

    func setupPrivacyPolicyButton() {
        privacyPolicyButton = SettingsButton(type: .system)
        contentView.addSubview(privacyPolicyButton)
        privacyPolicyButton.translatesAutoresizingMaskIntoConstraints = false
        privacyPolicyButton.addTarget(self, action: #selector(didTapPrivacyPrivacy(_:)), for: .touchUpInside)
        privacyPolicyButton.configure(
            title: "Privacy Policy"
        )
        NSLayoutConstraint.activate([
            privacyPolicyButton.heightAnchor.constraint(equalToConstant: SettingsButton.defaultHeight),
            privacyPolicyButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            privacyPolicyButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            privacyPolicyButton.topAnchor.constraint(equalTo: centerDivider.bottomAnchor),
            privacyPolicyButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    func setupBottomDivider() {
        bottomDivider = UIView()
        contentView.addSubview(bottomDivider)
        bottomDivider.translatesAutoresizingMaskIntoConstraints = false
        bottomDivider.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        NSLayoutConstraint.activate([
            bottomDivider.heightAnchor.constraint(equalToConstant: 1),
            bottomDivider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomDivider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomDivider.topAnchor.constraint(equalTo: privacyPolicyButton.bottomAnchor),
            bottomDivider.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    @objc fileprivate func didTapPrivacyPrivacy(_ sender: SettingsButton) {
        delegate?.didTapPrivacyPolicyButton(sender)
    }

}

extension PrivacySettingsTableViewCell: SettingToggleDelegate {
    func didToggleSetting(isOn: Bool) {
        delegate?.didToggleCrashReports(isOn: isOn)
    }
}
