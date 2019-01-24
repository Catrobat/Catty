/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

import Bohr
import StoreKit

class SettingsTableViewController: BOTableViewController {

    override func setup() {
        title = kLocalizedSettings
        view.backgroundColor = UIColor.background()
        view.tintColor = UIColor.globalTint()

        addSection(BOTableViewSection(headerTitle: "",
                                      handler: { section in
            if Util.isPhiroActivated() {
                section?.addCell(BOSwitchTableViewCell(title: kLocalizedPhiroBricks,
                                                       key: kUsePhiroBricks,
                                                       handler: { cell in
                    let sectionCell = cell as! BOSwitchTableViewCell?
                    sectionCell?.backgroundColor = UIColor.background()
                    sectionCell?.mainColor = UIColor.globalTint()
                    sectionCell?.toggleSwitch.tintColor = UIColor.globalTint()
                    sectionCell?.toggleSwitch.onTintColor = UIColor.globalTint()
                }))
            }

            if Util.isArduinoActivated() {
                section?.addCell(BOSwitchTableViewCell(title: kLocalizedArduinoBricks,
                                                       key: kUseArduinoBricks,
                                                       handler: { cell in
                    let sectionCell = cell as! BOSwitchTableViewCell?
                    sectionCell?.backgroundColor = UIColor.background()
                    sectionCell?.mainColor = UIColor.globalTint()
                    sectionCell?.toggleSwitch.tintColor = UIColor.globalTint()
                    sectionCell?.toggleSwitch.onTintColor = UIColor.globalTint()
                }))
            }
        }))

        let service = BluetoothService.sharedInstance()
        if Util.isPhiroActivated() || Util.isArduinoActivated() {
            addSection(BOTableViewSection(headerTitle: "", handler: { section in
                if service.phiro != nil || service.arduino != nil {
                    section?.addCell(BOButtonTableViewCell(title: kLocalizedDisconnectAllDevices,
                                                           key: nil,
                                                           handler: { cell in
                        let sectionCell = cell as! BOButtonTableViewCell?
                        sectionCell?.backgroundColor = UIColor.background()
                        sectionCell?.mainColor = UIColor.globalTint()
                        sectionCell?.actionBlock = {
                            self.disconnect()
                        }
                    }))
                }

                let tempArray = UserDefaults.standard.array(forKey: "KnownBluetoothDevices")
                if tempArray?.count != nil {
                    section?.addCell(BOButtonTableViewCell(title: kLocalizedRemoveKnownDevices,
                                                           key: nil,
                                                           handler: { cell in
                        let sectionCell = cell as! BOButtonTableViewCell?
                        sectionCell?.backgroundColor = UIColor.background()
                        sectionCell?.mainColor = UIColor.globalTint()
                        sectionCell?.actionBlock = {
                            self.removeKnownDevices()
                        }
                    }))
                }
            }))
        }

        if (UserDefaults.standard.value(forKey: kUserIsLoggedIn) as? NSNumber)?.boolValue ?? false {
            addSection(BOTableViewSection(headerTitle: "",
                                          handler: { section in
                section?.addCell(BOButtonTableViewCell(title: kLocalizedLogout,
                                                       key: nil,
                                                       handler: { cell in
                    let sectionCell = cell as! BOButtonTableViewCell?
                    sectionCell?.backgroundColor = UIColor.background()
                    sectionCell?.mainColor = UIColor.varibaleBrickRed()
                    sectionCell?.actionBlock = {
                        self.logoutUser()
                        self.navigationController?.popViewController(animated: true)
                    }
                }))
            }))
        }

        addSection(BOTableViewSection(headerTitle: "", handler: { section in
            section?.addCell(BOChoiceTableViewCell(title: kLocalizedAboutPocketCode,
                                                   key: "choice_1",
                                                   handler: { cell in
                let sectionCell = cell as! BOChoiceTableViewCell?
                sectionCell?.destinationViewController = AboutPocketCodeOptionTableViewController()
                sectionCell?.backgroundColor = UIColor.background()
                sectionCell?.mainColor = UIColor.globalTint()
            }))
            section?.addCell(BOChoiceTableViewCell(title: kLocalizedTermsOfUse,
                                                   key: "choice_2",
                                                   handler: { cell in
                let sectionCell = cell as! BOChoiceTableViewCell?
                sectionCell?.destinationViewController = TermsOfUseOptionTableViewController()
                sectionCell?.backgroundColor = UIColor.background()
                sectionCell?.mainColor = UIColor.globalTint()
            }))
        }))

        addSection(BOTableViewSection(headerTitle: "",
                                      handler: { section in
            section?.addCell(BOButtonTableViewCell(title: kLocalizedPrivacySettings, key: nil, handler: { cell in
                let sectionCell = cell as! BOButtonTableViewCell?
                sectionCell?.backgroundColor = UIColor.background()
                sectionCell?.mainColor = UIColor.globalTint()
                sectionCell?.actionBlock = {
                    self.openPrivacySettings()
                }
            }))
            section?.addCell(BOButtonTableViewCell(title: kLocalizedRateUs,
                                                   key: nil,
                                                   handler: { cell in
                let sectionCell = cell as! BOButtonTableViewCell?
                sectionCell?.backgroundColor = UIColor.background()
                sectionCell?.mainColor = UIColor.globalTint()
                sectionCell?.actionBlock = {
                    if #available(iOS 10.3, *) {
                        SKStoreReviewController.requestReview()
                    } else {
                        self.openRateUsURL()
                    }
                }
            }))
            var version: String?
            if let object = Bundle.main.infoDictionary?["CFBundleShortVersionString"] {
                version = "\(kLocalizedVersionLabel)\(object)"
            }
            section?.footerTitle = version
        }))
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserDefaults.standard.synchronize()
    }

    func openRateUsURL() {
        if let url = URL(string: kAppStoreURL) {
            UIApplication.shared.openURL(url)
        }
    }

    func openPrivacySettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.openURL(url)
        }
    }

    func disconnect() {
        BluetoothService.sharedInstance().disconnect()
        Util.alert(withText: kLocalizedDisconnectBluetoothDevices)
    }

    func removeKnownDevices() {
        BluetoothService.sharedInstance().removeKnownDevices()
        Util.alert(withText: kLocalizedRemovedKnownBluetoothDevices)
    }

    func logoutUser() {
        UserDefaults.standard.setValue(false, forKey: kUserIsLoggedIn)
        UserDefaults.standard.setValue("", forKey: kUserLoginToken)
        UserDefaults.standard.setValue("", forKey: kcUsername)
    }
}
