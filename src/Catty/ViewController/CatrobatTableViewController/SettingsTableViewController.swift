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

    lazy var aboutPocketCodeViewController = AboutPocketCodeTableViewController()
    lazy var termsOfUseViewController = TermsOfUseOptionTableViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = kLocalizedSettings
        setupTable()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserDefaults.standard.synchronize()
    }

    fileprivate func setupTable() {
        self.tableView.separatorStyle = .none
        self.tableView.register(AppSettingsTableViewCell.self, forCellReuseIdentifier: AppSettingsTableViewCell.identifier)
        self.tableView.register(PrivacySettingsTableViewCell.self, forCellReuseIdentifier: PrivacySettingsTableViewCell.identifier)
        self.tableView.register(AboutUsTableViewCell.self, forCellReuseIdentifier: AboutUsTableViewCell.identifier)
        self.tableView.register(MoreSettingsTableViewCell.self, forCellReuseIdentifier: MoreSettingsTableViewCell.identifier)
        self.tableView.register(LogoutSettingTableViewCell.self, forCellReuseIdentifier: LogoutSettingTableViewCell.identifier)
    }

    func changeFirebaseCrashReportSettings(isOn: Bool) {
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: NotificationName.settingsCrashReportingChanged),
            object: NSNumber(value: isOn))
        UserDefaults.standard.setValue(isOn, forKey: kFirebaseSendCrashReports)
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

    fileprivate func logoutUser() {
        UserDefaults.standard.setValue(false, forKey: NetworkDefines.kUserIsLoggedIn)
        UserDefaults.standard.setValue("", forKey: NetworkDefines.kUserLoginToken)
        UserDefaults.standard.setValue("", forKey: kcUsername)
        navigationController?.popViewController(animated: true)
    }

    fileprivate func push(vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SettingsTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        UserDefaults.standard.bool(forKey: NetworkDefines.kUserIsLoggedIn) ? 5 : 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: AppSettingsTableViewCell.identifier, for: indexPath) as! AppSettingsTableViewCell
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: PrivacySettingsTableViewCell.identifier, for: indexPath) as! PrivacySettingsTableViewCell
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: AboutUsTableViewCell.identifier, for: indexPath) as! AboutUsTableViewCell
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: MoreSettingsTableViewCell.identifier, for: indexPath) as! MoreSettingsTableViewCell
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: LogoutSettingTableViewCell.identifier, for: indexPath) as! LogoutSettingTableViewCell
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension SettingsTableViewController: AppSettingsDelegate {
    func didToggleArduinoExtension(isOn: Bool) {
        UserDefaults.standard.set(isOn, forKey: kUseArduinoBricks)
    }
}

extension SettingsTableViewController: PrivacySettingsDelegate {
    func didToggleCrashReports(isOn: Bool) {
        changeFirebaseCrashReportSettings(isOn: isOn)
    }

    func didTapPrivacyPolicyButton(_ sender: SettingsButton) {
        openPrivacySettings()
    }
}

extension SettingsTableViewController: AboutUsDelegate {
    func didTapAboutUs(_ sender: SettingsButton) {
        push(vc: aboutPocketCodeViewController)
    }
}

extension SettingsTableViewController: MoreSettingsDelegate {
    func didTapTOS(_ sender: SettingsButton) {
        push(vc: termsOfUseViewController)
    }

    func didTapRateUs(_ sender: SettingsButton) {
        openRateUsURL()
    }
}

extension SettingsTableViewController: LogoutDelegate {
    func didTapLogout() {
        logoutUser()
    }
}
