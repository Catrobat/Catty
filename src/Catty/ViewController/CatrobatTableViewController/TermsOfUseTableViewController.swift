/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

class TermsOfUseTableViewController: FormTableViewController {

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupFormItems()
    }

    // MARK: - UI

    private func setupViews() {
        self.navigationItem.title = kLocalizedTermsOfUse

        self.tableView.backgroundColor = .background
        self.tableView.register(FormTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: FormTableViewHeaderView.id)
    }

    // MARK: - TableView

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: FormTableViewHeaderView.id) as? FormTableViewHeaderView else {
            return FormTableViewHeaderView()
        }
        header.configure(with: kLocalizedTermsOfUseDescription)
        header.needsUpdateConstraints()
        header.updateConstraintsIfNeeded()
        return header
    }

    // MARK: - Functions

    private func setupFormItems() {
        formItems = [
            [
                FormItem(title: kLocalizedViewTermsOfUse, titleColor: .globalTint, action: {
                    self.openTermsOfUseURL()
                })
            ]
        ]
    }

    func openTermsOfUseURL() {
        if let url = URL(string: NetworkDefines.termsOfUseUrl) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
