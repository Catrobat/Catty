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

protocol AppSettingsDelegate: AnyObject {
    func didToggleArduinoExtension(isOn: Bool)
}

class AppSettingsTableViewCell: SettingsTableViewCell {
    static let identifier = "AppSettingsTableViewCell"

    private var cellTitle: SettingsPageCellHeaderView!
    private var arduinoAppSetting: SettingToggleView!

    public weak var delegate: AppSettingsDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupCellHeader()
        setupArduinoSettings()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCellHeader()
        setupArduinoSettings()
    }

    func setupCellHeader() {
        cellTitle = SettingsPageCellHeaderView()
        contentView.addSubview(cellTitle)
        cellTitle.translatesAutoresizingMaskIntoConstraints = false
        cellTitle.configure(title: kLocalizedAppSettingSection)
        NSLayoutConstraint.activate([
            cellTitle.heightAnchor.constraint(equalToConstant: SettingsPageCellHeaderView.defaultHeaderHeight),
            cellTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellTitle.topAnchor.constraint(equalTo: contentView.topAnchor)
        ])
    }

    func setupArduinoSettings() {
        arduinoAppSetting = SettingToggleView()
        contentView.addSubview(arduinoAppSetting)
        arduinoAppSetting.translatesAutoresizingMaskIntoConstraints = false
        arduinoAppSetting.configure(
            title: kLocalizedArduinoBricks,
            description: kLocalizedArduinoBricksDescription
        )
        arduinoAppSetting.setupToggleAccessibilityLabel(label : kLocalizedArduinoBricks)
        arduinoAppSetting.delegate = self
        NSLayoutConstraint.activate([
            arduinoAppSetting.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            arduinoAppSetting.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            arduinoAppSetting.topAnchor.constraint(equalTo: cellTitle.bottomAnchor, constant: 0),
            arduinoAppSetting.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        if UserDefaults.standard.bool(forKey: kUseArduinoBricks) {
            arduinoAppSetting.setSwitchIsOn(isOn: true)
            return
        }
        arduinoAppSetting.setSwitchIsOn(isOn: false)
    }

}

extension AppSettingsTableViewCell: SettingToggleDelegate {
    func didToggleSetting(isOn: Bool) {
        delegate?.didToggleArduinoExtension(isOn: isOn)
    }
}
