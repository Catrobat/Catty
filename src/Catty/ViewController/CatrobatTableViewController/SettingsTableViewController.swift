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

class SettingsTableViewController: UITableViewController {

    static let unusedKey = "unused"

    let aboutPocketCodeViewController = AboutPocketCodeOptionTableViewController()
    let termsOfUseViewController = TermsOfUseOptionTableViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserDefaults.standard.synchronize()
    }

    fileprivate func setup() {
        self.title = kLocalizedSettings
        self.tableView.separatorStyle = .none
        self.tableView.register(AppSettingsTableViewCell.self, forCellReuseIdentifier: "AppSettingsTableViewCell")
    }

    @objc func changeFirebaseCrashReportSettings(_ sender: UISwitch?) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.settingsCrashReportingChanged), object: NSNumber(value: sender?.isOn ?? false))
    }

    fileprivate func presentAlertController(withTitle title: String?, message: String?) {
        Util.alert(withTitle: title, andText: message)
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
        Util.alert(withText: kLocalizedDisconnectBluetoothDevices)
    }

    fileprivate func removeKnownDevices() {
        BluetoothService.sharedInstance().removeKnownDevices()
        Util.alert(withText: kLocalizedRemovedKnownBluetoothDevices)
    }

    fileprivate func logoutUser() {
        UserDefaults.standard.setValue(false, forKey: NetworkDefines.kUserIsLoggedIn)
        UserDefaults.standard.setValue("", forKey: NetworkDefines.kUserLoginToken)
        UserDefaults.standard.setValue("", forKey: kcUsername)
    }
}

extension SettingsTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AppSettingsTableViewCell.identifier, for: indexPath) as! AppSettingsTableViewCell
        cell.selectionStyle = .none
        cell.delegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

extension SettingsTableViewController: AppSettingsDelegate {
    func didToggleArduinoExtension(isOn: Bool) {
        print(isOn)
    }
}
