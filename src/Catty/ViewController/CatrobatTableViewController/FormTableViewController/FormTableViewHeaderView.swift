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
import UIKit

class FormTableViewHeaderView: UITableViewHeaderFooterView {

    private let contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = .systemFont(ofSize: 13)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    static let id = "FormTableViewHeaderView"
    private var didSetupConstraints = false

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        self.contentView.addSubview(contentLabel)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            contentLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 25),
            contentLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -20),
            contentLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
            contentLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20)
        ])
    }

    override func updateConstraints() {
        if !didSetupConstraints {

            setupConstraints()
            didSetupConstraints = true
        }
        super.updateConstraints()
    }

    func configure(with text: String) {
        self.contentLabel.text = text
    }
}
