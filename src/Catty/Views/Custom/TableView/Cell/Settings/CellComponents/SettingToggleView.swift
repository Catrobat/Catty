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

    private var toggle: UISwitch!
    private var settingTitle: UILabel!
    private var settingDescription: UILabel!
    private var hStack: UIStackView!
    private var vLabelStack: UIStackView!

    public weak var delegate: SettingToggleDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHStack()
        setupVLabelStack()
        setupSettingTitle()
        setupSettingDescripton()
        setupToggle()
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

    private func setupVLabelStack() {
        vLabelStack = UIStackView()
        vLabelStack.translatesAutoresizingMaskIntoConstraints = false
        vLabelStack.spacing = 2
        vLabelStack.axis = NSLayoutConstraint.Axis.vertical
        vLabelStack.distribution = UIStackView.Distribution.fill
        hStack.addArrangedSubview(vLabelStack)
    }

    private func setupHStack() {
        hStack = UIStackView()
        self.addSubview(hStack)
        hStack.translatesAutoresizingMaskIntoConstraints = false
        hStack.axis = NSLayoutConstraint.Axis.horizontal
        hStack.alignment = UIStackView.Alignment.center
        hStack.spacing = 8
        hStack.distribution = UIStackView.Distribution.equalCentering
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            hStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            hStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            hStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
        ])
    }

    private func setupToggle() {
        toggle = UISwitch()
        toggle.isAccessibilityElement = true
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.addTarget(self, action: #selector(settingToggled), for: .valueChanged)
        hStack.addArrangedSubview(toggle)
    }

    func setupToggleAccessibilityLabel(label : String){
        toggle.accessibilityLabel = label
    }

    private func setupSettingTitle() {
        settingTitle = UILabel()
        settingTitle.translatesAutoresizingMaskIntoConstraints = false
        settingTitle.font = UIFont.systemFont(ofSize: 16)
        settingTitle.numberOfLines = 0
        vLabelStack.addArrangedSubview(settingTitle)
    }

    private func setupSettingDescripton() {
        settingDescription = UILabel()
        settingDescription.font = UIFont.systemFont(ofSize: 11)
        settingDescription.numberOfLines = 0
        settingDescription.translatesAutoresizingMaskIntoConstraints = false
        settingDescription.textColor = UIColor.darkGray
        vLabelStack.addArrangedSubview(settingDescription)
    }
}
