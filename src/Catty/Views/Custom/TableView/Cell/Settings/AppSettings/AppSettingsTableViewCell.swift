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

class AppSettingsTableViewCell: UITableViewCell {
    static let identifier = "AppSettingsTableViewCell"

    public weak var delegate: AppSettingsDelegate?
    private let cellTitle: SettingsPageCellHeaderView = {
        let cellTitle = SettingsPageCellHeaderView()
        cellTitle.translatesAutoresizingMaskIntoConstraints = false
        cellTitle.configure(title: kLocalizedAppSettingSection)
        return cellTitle
    }()

    private let arduinoAppSetting: SettingToggleView = {
        let arduinoAppSetting = SettingToggleView()
        arduinoAppSetting.translatesAutoresizingMaskIntoConstraints = false
        arduinoAppSetting.configure(
            title: "Arduino extension",
            description: "Allow the app to control arduino extentions"
        )
        return arduinoAppSetting
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }

    func initialize() {
        contentView.addSubview(cellTitle)
        contentView.addSubview(arduinoAppSetting)
        arduinoAppSetting.delegate = self

        NSLayoutConstraint.activate([
            cellTitle.heightAnchor.constraint(equalToConstant: 40),
            cellTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellTitle.topAnchor.constraint(equalTo: contentView.topAnchor),

            arduinoAppSetting.heightAnchor.constraint(equalToConstant: 60),
            arduinoAppSetting.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            arduinoAppSetting.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            arduinoAppSetting.topAnchor.constraint(equalTo: cellTitle.bottomAnchor, constant: 8),
            arduinoAppSetting.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

}

extension AppSettingsTableViewCell: SettingToggleDelegate {
    func didToggleSetting(isOn: Bool) {
        delegate?.didToggleArduinoExtension(isOn: isOn)
    }
}
