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

class FormTextFieldTableViewCell: FormTableViewCell, UITextFieldDelegate {

    private let textField: UITextField = {
        let tf = UITextField()
        tf.clearButtonMode = .always
        tf.accessibilityIdentifier = "formTextField"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private var typeAction: ((String) -> Void)?
    private var returnAction: (() -> Void)?

    override class var id: String {
        "FormTextFieldTableViewCell"
    }

    override func setupViews() {
        super.setupViews()

        contentView.addSubview(textField)
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
    }

    @objc private func textFieldEditingChanged(_ textField: UITextField) {
        typeAction?(textField.text ?? "")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        returnAction?()
        return false
    }

    override func setupConstraints() {
        super.setupConstraints()

        NSLayoutConstraint.activate([
            textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

    override func configure(with formItem: FormItem) {
        super.configure(with: formItem)

        if let item = formItem as? FormTextFieldItem {
            typeAction = item.typeAction
            returnAction = item.returnAction
            textField.placeholder = item.placeholder
        }
    }
}
