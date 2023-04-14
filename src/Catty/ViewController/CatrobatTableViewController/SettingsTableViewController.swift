/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

@objc class SettingsTableViewController: FormTableViewController {

    private let sectionHeaders: [String?] = [
        kLocalizedExtensions, kLocalizedPrivacy, kLocalizedAbout, kLocalizedMore, nil
    ]

    private let sectionFooters: [String?] = [
        nil, nil, nil, nil, nil
    ]

    private var currentSectionHeaders: [String?] = []
    private var currentSectionFooters: [String?] = []

    private var featureItems: [FormItem] = []
    private var bluetoothItems: [FormItem] = []
    private var webAccessItems: [FormItem] = []
    private let authenticator = StoreAuthenticator()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupFormItems()
    }

    // MARK: - UI

    private func setupViews() {
        self.tableView.backgroundColor = .background
        self.navigationItem.title = kLocalizedSettings
    }

    // MARK: - TableView

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        currentSectionHeaders[section]
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        currentSectionFooters[section]
    }

    // MARK: - Functions

    private func setupFormItems() {
        self.currentSectionHeaders = self.sectionHeaders
        self.currentSectionFooters = self.sectionFooters

        setupFeatureItems()
        setupBluetoothItems()
        setupWebAccessItems()

        formItems = [ self.featureItems,
            [
                FormCrashReportsSwitchItem(switchAction: { isEnabled in
                    self.changeFirebaseCrashReportSettings(isEnabled: isEnabled)
                }),
                FormItem(title: kLocalizedPrivacySettings, titleColor: .globalTint, action: {
                    self.openPrivacySettings()
                })
            ],
            [
                FormItem(title: kLocalizedAboutUs, accessoryType: .disclosureIndicator, action: {
                    self.showAboutUs()
                })
            ],
            [
                FormVersionItem(),
                FormItem(title: kLocalizedTermsOfUse, accessoryType: .disclosureIndicator, action: {
                    self.showTermsOfUseAndService()
                }),
                FormItem(title: kLocalizedRateUs, titleColor: .globalTint, action: {
                    self.openRateUsURL()
                })
            ]
        ]

        if UserDefaults.standard.bool(forKey: kUseWebRequestBrick) {
            formItems.insert(self.webAccessItems, at: 1)
            currentSectionHeaders.insert(kLocalizedWebAccess, at: 1)
            currentSectionFooters.insert(nil, at: 1)
        }

        if UserDefaults.standard.bool(forKey: kUseArduinoBricks), !bluetoothItems.isEmpty {
            formItems.insert(self.bluetoothItems, at: 1)
            currentSectionHeaders.insert(kLocalizedArduinoBricks, at: 1)
            currentSectionFooters.insert(nil, at: 1)
        }

        if StoreAuthenticator.isLoggedIn() {
            formItems.append([
                FormItem(title: kLocalizedLogout, titleColor: .red, action: {
                    self.logout()
                }),
                FormItem(title: kLocalizedDeleteAccount, titleColor: .red, action: {
                    self.deleteAccount()
                })
            ])
        }
    }

    private func setupFeatureItems() {
        self.featureItems = []

        if Util.isPhiroActivated() {
            self.featureItems.append(FormPhiroSwitchItem())
        }

        if Util.isArduinoActivated() {
            self.featureItems.append(FormArduinoSwitchItem(switchAction: { _ in
                self.setupFormItems()
            }))
        }

        if Util.isEmbroideryActivated() {
            self.featureItems.append(FormEmbroiderySwitchItem())
        }
    }

    private func setupBluetoothItems() {
        self.bluetoothItems = []

        if BluetoothService.sharedInstance().phiro != nil || BluetoothService.sharedInstance().arduino != nil {
            self.bluetoothItems.append(
                FormItem(title: kLocalizedDisconnectAllDevices, action: {
                    self.disconnectAllBluetoothDevices()
                })
            )
        }

        if let knownDevices = UserDefaults.standard.array(forKey: kKnownBluetoothDevices), !knownDevices.isEmpty {
            self.bluetoothItems.append(
                FormItem(title: kLocalizedRemoveKnownDevices, action: {
                    self.removeKnownBluetoothDevices()
                })
            )
        }
    }

    private func setupWebAccessItems() {
        self.webAccessItems = [
            FormItem(title: kLocalizedTrustedDomains, accessoryType: .disclosureIndicator, action: {
                self.showTrustedDomains()
            })
        ]
    }

    func changeFirebaseCrashReportSettings(isEnabled: Bool) {
         NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: NotificationName.settingsCrashReportingChanged),
            object: NSNumber(value: isEnabled))
     }

    private func disconnectAllBluetoothDevices() {
        BluetoothService.sharedInstance().disconnect()
        Util.alert(text: kLocalizedDisconnectBluetoothDevices)
    }

    private func removeKnownBluetoothDevices() {
        BluetoothService.sharedInstance().removeKnownDevices()
        Util.alert(text: kLocalizedRemovedKnownBluetoothDevices)
    }

    private func openRateUsURL() {
        if let url = URL(string: NetworkDefines.appStoreUrl) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    private func openPrivacySettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    private func showTrustedDomains() {
        self.navigationController?.pushViewController(TrustedDomainTableViewController(), animated: true)
    }

    private func showTermsOfUseAndService() {
        self.navigationController?.pushViewController(TermsOfUseTableViewController(), animated: true)
    }

    private func showAboutUs() {
        self.navigationController?.pushViewController(AboutPocketCodeTableViewController(), animated: true)
    }

    private func logout() {
        StoreAuthenticator.logout()
        self.navigationController?.popViewController(animated: true)
    }

    private func deleteAccount() {
        let alertController = UIAlertController(title: kLocalizedDeleteAccount, message: kLocalizedDeleteAccountConfirm, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: kLocalizedCancel, style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: kLocalizedDelete, style: .destructive) { _ in
            self.authenticator.deleteUser { error in
                DispatchQueue.main.async(execute: {
                    switch error {
                    case .none:
                        self.navigationController?.popViewController(animated: true)
                        Util.alert(text: kLocalizedDeleteAccountSuccessful)
                    case .authentication:
                        Util.alert(text: kLocalizedAuthenticationFailed)
                    case .network, .timeout:
                        Util.defaultAlertForNetworkError()
                    default:
                        Util.alert(text: kLocalizedUnexpectedErrorMessage)
                    }
                })
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        present(alertController, animated: true, completion: nil)
    }
}
