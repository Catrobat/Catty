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

class TrustedDomainTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView = UITableView()
    var addButton = UIBarButtonItem()
    var trustedDomainManager = TrustedDomainManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    private func setupTableView() {
        tableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(tableView)

        self.navigationItem.title = kLocalizedWebAccess

        self.addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addButtonTapped))
        self.addButton.tintColor = .light
        self.navigationItem.rightBarButtonItem = self.addButton

        self.tableView.tableFooterView = UIView()
    }

    @objc func addButtonTapped() {
        let alert = UIAlertController(title: kLocalizedAddTrustedDomain, message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in
            textField.text = ""
        })
        alert.addAction(UIAlertAction(title: kLocalizedAdd, style: .default, handler: { _ in
            _ = self.trustedDomainManager?.add(url: alert.textFields?.first?.text ?? "")
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: kLocalizedCancel, style: .cancel, handler: nil))
        alert.becomeFirstResponder()
        self.present(alert, animated: false)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.trustedDomainManager?.userTrustedDomains.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = self.trustedDomainManager?.userTrustedDomains[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: kLocalizedEditTrustedDomain, message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in
            textField.text = self.trustedDomainManager?.userTrustedDomains[indexPath.row]
        })
        alert.addAction(UIAlertAction(title: kLocalizedDone, style: .default, handler: { _ in
            self.trustedDomainManager?.userTrustedDomains[indexPath.row] = alert.textFields?.first?.text ?? ""
            _ = self.trustedDomainManager?.storeUserTrustedDomains()
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: kLocalizedCancel, style: .cancel, handler: nil))
        alert.becomeFirstResponder()
        self.present(alert, animated: false)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.trustedDomainManager?.userTrustedDomains.remove(at: indexPath.row)
            _ = self.trustedDomainManager?.storeUserTrustedDomains()
            self.tableView.reloadData()
        }
    }
}
