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

protocol SettingToggleDelegate: AnyObject {
    func didToggleSetting(isOn: Bool)
}

class SettingToggleView: UIView {

    private var toggle: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.addTarget(self, action: #selector(settingToggled), for: .valueChanged)
        return toggle
    }()

    private var settingTitle: UILabel = {
        let settingTitle = UILabel()
        settingTitle.translatesAutoresizingMaskIntoConstraints = false
        settingTitle.font = UIFont.systemFont(ofSize: 16)
        settingTitle.numberOfLines = 0
        return settingTitle
    }()

    private var settingDescription: UILabel = {
        let settingDescription = UILabel()
        settingDescription.font = UIFont.systemFont(ofSize: 11)
        settingDescription.numberOfLines = 0
        settingDescription.translatesAutoresizingMaskIntoConstraints = false
        settingDescription.textColor = UIColor.darkGray
        return settingDescription
    }()

    private var hStack: UIStackView = {
        let hStack = UIStackView()
        hStack.translatesAutoresizingMaskIntoConstraints = false
        hStack.axis = NSLayoutConstraint.Axis.horizontal
        hStack.alignment = UIStackView.Alignment.center
        hStack.spacing = 8
        hStack.distribution = UIStackView.Distribution.equalCentering
        return hStack
    }()

    private var vLabelStack: UIStackView = {
        let vLabelStack = UIStackView()
        vLabelStack.translatesAutoresizingMaskIntoConstraints = false
        vLabelStack.spacing = 2
        vLabelStack.axis = NSLayoutConstraint.Axis.vertical
        vLabelStack.distribution = UIStackView.Distribution.fill
        return vLabelStack
    }()

    public weak var delegate: SettingToggleDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(hStack)

        hStack.addArrangedSubview(vLabelStack)
        hStack.addArrangedSubview(toggle)

        vLabelStack.addArrangedSubview(settingTitle)
        vLabelStack.addArrangedSubview(settingDescription)

        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            hStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            hStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            hStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(title: String, description: String) {
        settingTitle.text = title
        settingDescription.text = description
    }

    public func setSwitchIsOn(isOn: Bool) {
        toggle.setOn(isOn, animated: false)
    }

    @objc fileprivate func settingToggled(_ sender: UISwitch) {
        delegate?.didToggleSetting(isOn: sender.isOn)
    }
}
