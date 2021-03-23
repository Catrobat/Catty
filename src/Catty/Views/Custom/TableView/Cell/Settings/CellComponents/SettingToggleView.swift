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

    private let topDivider: UIView = {
        let topDivider = UIView()
        topDivider.translatesAutoresizingMaskIntoConstraints = false
        topDivider.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        return topDivider
    }()

    private let bottomDivider: UIView = {
        let bottomDivider = UIView()
        bottomDivider.translatesAutoresizingMaskIntoConstraints = false
        bottomDivider.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        return bottomDivider
    }()

    private let toggle: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.addTarget(self, action: #selector(settingToggled), for: .valueChanged)
        return toggle
    }()

    private let settingTitle: UILabel = {
        let settingTitle = UILabel()
        settingTitle.translatesAutoresizingMaskIntoConstraints = false
        settingTitle.numberOfLines = 0
        return settingTitle
    }()

    private let settingDescription: UILabel = {
        let settingDescription = UILabel()
        settingDescription.font = UIFont.systemFont(ofSize: 12)
        settingDescription.numberOfLines = 0
        settingDescription.translatesAutoresizingMaskIntoConstraints = false
        settingDescription.textColor = UIColor.darkGray
        return settingDescription
    }()

    private let hStack: UIStackView = {
        let hStack = UIStackView()
        hStack.translatesAutoresizingMaskIntoConstraints = false
        hStack.axis = NSLayoutConstraint.Axis.horizontal
        hStack.alignment = UIStackView.Alignment.center
        hStack.spacing = 12
        hStack.distribution = UIStackView.Distribution.equalCentering
        return hStack
    }()

    private let vLabelStack: UIStackView = {
        let vLabelStack = UIStackView()
        vLabelStack.translatesAutoresizingMaskIntoConstraints = false
        vLabelStack.spacing = 2
        vLabelStack.axis = NSLayoutConstraint.Axis.vertical
        vLabelStack.distribution = UIStackView.Distribution.fillProportionally
        return vLabelStack
    }()

    public weak var delegate: SettingToggleDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(topDivider)
        self.addSubview(bottomDivider)
        self.addSubview(hStack)

        hStack.addArrangedSubview(vLabelStack)
        hStack.addArrangedSubview(toggle)

        vLabelStack.addArrangedSubview(settingTitle)
        vLabelStack.addArrangedSubview(settingDescription)

        NSLayoutConstraint.activate([
            topDivider.heightAnchor.constraint(equalToConstant: 1),
            topDivider.topAnchor.constraint(equalTo: self.topAnchor),
            topDivider.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            topDivider.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            hStack.topAnchor.constraint(equalTo: topDivider.bottomAnchor, constant: 8),
            hStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            hStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            bottomDivider.heightAnchor.constraint(equalToConstant: 1),
            bottomDivider.topAnchor.constraint(equalTo: hStack.bottomAnchor, constant: 8),
            bottomDivider.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bottomDivider.trailingAnchor.constraint(equalTo: self.trailingAnchor)
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

    @objc fileprivate func settingToggled(_ sender: UISwitch) {
        delegate?.didToggleSetting(isOn: sender.isOn)
    }
}
