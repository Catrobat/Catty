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

class FormTableViewCell: UITableViewCell {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .natural
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    class var id: String {
        "FormTableViewCell"
    }

    private var didSetupConstraints = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        self.selectionStyle = .none
        contentView.addSubview(titleLabel)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
    }

    override func updateConstraints() {
        if !didSetupConstraints {
            setupConstraints()
        }

        super.updateConstraints()
    }

    func configure(with formItem: FormItem) {
        titleLabel.text = formItem.title
        titleLabel.textColor = formItem.titleColor
        self.accessoryType = formItem.accessoryType

        if self.accessoryType == .disclosureIndicator {
            addTintedDisclosureIndicator()
        } else {
            removeTintedDisclosureIndicator()
        }

        if formItem.action != nil {
            self.selectionStyle = .default
        }
    }

    private func addTintedDisclosureIndicator() {
        if #available(iOS 13.0, *) {
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
            let symbolImage = UIImage(systemName: "chevron.right",
                                      withConfiguration: symbolConfiguration)

            let imageView = UIImageView(image: symbolImage)
            imageView.tintColor = .globalTint
            self.accessoryView = imageView
        }
    }

    private func removeTintedDisclosureIndicator() {
        self.accessoryView = nil
    }
}
