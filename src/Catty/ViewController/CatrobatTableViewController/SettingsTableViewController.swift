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

import Foundation

class SettingsTableViewController: BOTableViewController {

    static let unusedKey = "unused"

    let trustedDomainViewController = TrustedDomainTableViewController()
    let aboutPocketCodeViewController = AboutPocketCodeOptionTableViewController()
    let termsOfUseViewController = TermsOfUseOptionTableViewController()

    override func setup() {

        title = kLocalizedSettings
        view.backgroundColor = UIColor.background
        view.tintColor = UIColor.globalTint

        addSection(BOTableViewSection(headerTitle: "", handler: { section in
            if Util.isPhiroActivated() {
                section?.addCell(BOSwitchTableViewCell(title: kLocalizedPhiroBricks, key: kUsePhiroBricks, handler: { cell in
                    if let phiroBricksCellSwitch = cell as? BOSwitchTableViewCell {
                        phiroBricksCellSwitch.backgroundColor = UIColor.background
                        phiroBricksCellSwitch.mainColor = UIColor.globalTint
                        phiroBricksCellSwitch.toggleSwitch.tintColor = UIColor.globalTint
                        phiroBricksCellSwitch.toggleSwitch.onTintColor = UIColor.globalTint
                    }
                }))
            }

            if Util.isEmbroideryActivated() {
                section?.addCell(BOSwitchTableViewCell(title: kLocalizedEmbroideryBricks, key: kUseEmbroideryBricks, handler: { cell in
                    if let embroideryBricksCellSwitch = cell as? BOSwitchTableViewCell {
                        embroideryBricksCellSwitch.backgroundColor = UIColor.background
                        embroideryBricksCellSwitch.mainColor = UIColor.globalTint
                        embroideryBricksCellSwitch.toggleSwitch.tintColor = UIColor.globalTint
                        embroideryBricksCellSwitch.toggleSwitch.onTintColor = UIColor.globalTint
                        embroideryBricksCellSwitch.onFooterTitle = kLocalizedEmbroideryBricksDescription
                        embroideryBricksCellSwitch.offFooterTitle = kLocalizedEmbroideryBricksDescription
                    }
                }))
            }
        }))

        addSection(BOTableViewSection(headerTitle: "", handler: { section in
            if Util.isArduinoActivated() {
                section?.addCell(BOSwitchTableViewCell(title: kLocalizedArduinoBricks, key: kUseArduinoBricks, handler: { cell in
                    if let arduinoBricksCellSwitch = cell as? BOSwitchTableViewCell {
                        arduinoBricksCellSwitch.backgroundColor = UIColor.background
                        arduinoBricksCellSwitch.mainColor = UIColor.globalTint
                        arduinoBricksCellSwitch.toggleSwitch.tintColor = UIColor.globalTint
                        arduinoBricksCellSwitch.toggleSwitch.onTintColor = UIColor.globalTint
                        arduinoBricksCellSwitch.onFooterTitle = kLocalizedArduinoBricksDescription
                        arduinoBricksCellSwitch.offFooterTitle = kLocalizedArduinoBricksDescription
                    }
                }))
            }
        }))

        addSection(BOTableViewSection(headerTitle: "", handler: { section in
            section?.addCell(BOSwitchTableViewCell(title: kLocalizedSendCrashReports, key: kFirebaseSendCrashReports, handler: { cell in
                if let firebaseSendCrashReportsCellSwitch = cell as? BOSwitchTableViewCell {
                    firebaseSendCrashReportsCellSwitch.backgroundColor = UIColor.background
                    firebaseSendCrashReportsCellSwitch.mainColor = UIColor.globalTint
                    firebaseSendCrashReportsCellSwitch.toggleSwitch.tintColor = UIColor.globalTint
                    firebaseSendCrashReportsCellSwitch.toggleSwitch.onTintColor = UIColor.globalTint
                    firebaseSendCrashReportsCellSwitch.onFooterTitle = kLocalizedSendCrashReportsDescription
                    firebaseSendCrashReportsCellSwitch.offFooterTitle = kLocalizedSendCrashReportsDescription

                    firebaseSendCrashReportsCellSwitch.toggleSwitch.addTarget(self, action: #selector(self.changeFirebaseCrashReportSettings(_:)), for: .valueChanged)
                }
            }))
        }))

        let service = BluetoothService.sharedInstance()

        if Util.isPhiroActivated() || Util.isArduinoActivated() {
            addSection(BOTableViewSection(headerTitle: "", handler: { section in
                if service.phiro != nil || service.arduino != nil {
                    section?.addCell(BOButtonTableViewCell(title: kLocalizedDisconnectAllDevices, key: type(of: self).unusedKey, handler: { cell in
                        if let disconnectAllDevicesCellButton = cell as? BOButtonTableViewCell {
                            disconnectAllDevicesCellButton.backgroundColor = UIColor.background
                            disconnectAllDevicesCellButton.mainColor = UIColor.globalTint
                            disconnectAllDevicesCellButton.actionBlock = {
                                self.disconnect()
                            }
                        }
                    }))
                }
                let tempArray = UserDefaults.standard.array(forKey: "KnownBluetoothDevices")
                if tempArray?.count != nil {
                    section?.addCell(BOButtonTableViewCell(title: kLocalizedRemoveKnownDevices, key: type(of: self).unusedKey, handler: { cell in
                        if let removeKnownDevicesCellButton = cell as? BOButtonTableViewCell {
                            removeKnownDevicesCellButton.backgroundColor = UIColor.background
                            removeKnownDevicesCellButton.mainColor = UIColor.globalTint
                            removeKnownDevicesCellButton.actionBlock = {
                                self.removeKnownDevices()
                            }
                        }
                    }))
                }
            }))
        }

        if UserDefaults.standard.bool(forKey: kUseWebRequestBrick) {
            addSection(BOTableViewSection(headerTitle: "", handler: { section in
                section?.addCell(BOChoiceTableViewCell(title: kLocalizedWebAccess, key: type(of: self).unusedKey, handler: { cell in
                    if let aboutPocketCodeCellChoice = cell as? BOChoiceTableViewCell {
                        aboutPocketCodeCellChoice.destinationViewController = self.trustedDomainViewController
                        aboutPocketCodeCellChoice.backgroundColor = UIColor.background
                        aboutPocketCodeCellChoice.mainColor = UIColor.globalTint
                    }
                }))
            }))
        }

        if (UserDefaults.standard.value(forKey: NetworkDefines.kUserIsLoggedIn) as? NSNumber)?.boolValue ?? false {
            addSection(BOTableViewSection(headerTitle: "", handler: { section in
                section?.addCell(BOButtonTableViewCell(title: kLocalizedLogout, key: type(of: self).unusedKey, handler: { cell in
                    if let userIsLoggedInCellButton = cell as? BOButtonTableViewCell {
                        userIsLoggedInCellButton.backgroundColor = UIColor.background
                        userIsLoggedInCellButton.mainColor = UIColor.variableBrickRed
                        userIsLoggedInCellButton.actionBlock = {
                            self.logoutUser()
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }))
            }))
        }

        addSection(BOTableViewSection(headerTitle: "", handler: { section in
            section?.addCell(BOChoiceTableViewCell(title: kLocalizedAboutPocketCode, key: type(of: self).unusedKey, handler: { cell in
                if let aboutPocketCodeCellChoice = cell as? BOChoiceTableViewCell {
                    aboutPocketCodeCellChoice.destinationViewController = self.aboutPocketCodeViewController
                    aboutPocketCodeCellChoice.backgroundColor = UIColor.background
                    aboutPocketCodeCellChoice.mainColor = UIColor.globalTint
                }
            }))

            section?.addCell(BOChoiceTableViewCell(title: kLocalizedTermsOfUse, key: type(of: self).unusedKey, handler: { cell in
                if let termsOfUseCellChoice = cell as? BOChoiceTableViewCell {
                    termsOfUseCellChoice.destinationViewController = self.termsOfUseViewController
                    termsOfUseCellChoice.backgroundColor = UIColor.background
                    termsOfUseCellChoice.mainColor = UIColor.globalTint
                }
            }))
        }))

        addSection(BOTableViewSection(headerTitle: "", handler: { section in
            section?.addCell(BOButtonTableViewCell(title: kLocalizedPrivacySettings, key: type(of: self).unusedKey, handler: { cell in
                if let privacyCellButton = cell as? BOButtonTableViewCell {
                    privacyCellButton.backgroundColor = UIColor.background
                    privacyCellButton.mainColor = UIColor.globalTint
                    privacyCellButton.actionBlock = {
                        self.openPrivacySettings()
                    }
                }
            }))

            section?.addCell(BOButtonTableViewCell(title: kLocalizedRateUs, key: type(of: self).unusedKey, handler: { cell in
                if let rateUsCellButton = cell as? BOButtonTableViewCell {
                    rateUsCellButton.backgroundColor = UIColor.background
                    rateUsCellButton.mainColor = UIColor.globalTint
                    rateUsCellButton.actionBlock = {
                        self.openRateUsURL()
                    }
                }
            }))

            let object = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
            var version = "\(kLocalizedVersionLabel)\(object!) (\(Util.appBuildVersion()!))"

            #if DEBUG
                version = "\(String(describing: version))(\(kLocalizedDebugMode))"
            #endif

            section?.footerTitle = version
        }))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserDefaults.standard.synchronize()
    }

    @objc func changeFirebaseCrashReportSettings(_ sender: UISwitch?) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.settingsCrashReportingChanged), object: NSNumber(value: sender?.isOn ?? false))
    }

    fileprivate func presentAlertController(withTitle title: String?, message: String?) {
        Util.alert(title: title!, text: message!)
    }

    fileprivate func openRateUsURL() {
        if let url = URL(string: NetworkDefines.appStoreUrl) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    fileprivate func openPrivacySettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    fileprivate func disconnect() {
        BluetoothService.sharedInstance().disconnect()
        Util.alert(text: kLocalizedDisconnectBluetoothDevices)
    }

    fileprivate func removeKnownDevices() {
        BluetoothService.sharedInstance().removeKnownDevices()
        Util.alert(text: kLocalizedRemovedKnownBluetoothDevices)
    }

    fileprivate func logoutUser() {
        UserDefaults.standard.setValue(false, forKey: NetworkDefines.kUserIsLoggedIn)
        UserDefaults.standard.setValue("", forKey: NetworkDefines.kUserLoginToken)
        UserDefaults.standard.setValue("", forKey: kcUsername)
    }
}
