/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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
import UIKit

class FormTableViewController: UITableViewController {

    var formItems: [[FormItem]] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }

    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(FormTableViewCell.self, forCellReuseIdentifier: FormTableViewCell.id)
        tableView.register(FormSwitchTableViewCell.self, forCellReuseIdentifier: FormSwitchTableViewCell.id)
        tableView.register(FormTextFieldTableViewCell.self, forCellReuseIdentifier: FormTextFieldTableViewCell.id)
        tableView.register(FormCheckTableViewCell.self, forCellReuseIdentifier: FormCheckTableViewCell.id)
    }

    // MARK: - TableView

    override func numberOfSections(in tableView: UITableView) -> Int {
        formItems.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        formItems[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let switchItem = formItems[indexPath.section][indexPath.row] as? FormSwitchItem,
            let cell = tableView.dequeueReusableCell(withIdentifier: FormSwitchTableViewCell.id) as? FormSwitchTableViewCell {
            cell.configure(with: switchItem)
            cell.needsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            return cell
        } else if let textFieldItem = formItems[indexPath.section][indexPath.row] as? FormTextFieldItem,
                  let cell = tableView.dequeueReusableCell(withIdentifier: FormTextFieldTableViewCell.id) as? FormTextFieldTableViewCell {
            cell.configure(with: textFieldItem)
            cell.needsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            return cell
        } else if let checkItem = formItems[indexPath.section][indexPath.row] as? FormCheckItem,
                  let cell = tableView.dequeueReusableCell(withIdentifier: FormCheckTableViewCell.id) as? FormCheckTableViewCell {
            cell.configure(with: checkItem)
            cell.needsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            return cell
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: FormTableViewCell.id) as? FormTableViewCell else {
            return FormTableViewCell()
        }

        cell.configure(with: formItems[indexPath.section][indexPath.row])
        cell.needsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
