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

class TermsOfUseOptionTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = kLocalizedTermsOfUse
        setupTable()
    }

    func setupTable() {
        self.tableView.separatorStyle = .none
        self.tableView.register(TermsOfUseAndServiceTableViewCell.self, forCellReuseIdentifier: TermsOfUseAndServiceTableViewCell.identifier)
    }

    fileprivate func openLink(with url: String) {
        if let url = URL(string: url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension TermsOfUseOptionTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TermsOfUseAndServiceTableViewCell.identifier, for: indexPath) as! TermsOfUseAndServiceTableViewCell
        cell.delegate = self
        cell.selectionStyle = .none
        return cell
    }
}

extension TermsOfUseOptionTableViewController: TermsOfUseAndServiceDelegate {
    func didTapViewTOS(_ sender: SettingsButton) {
        openLink(with: NetworkDefines.termsOfUseUrl)
    }
}
