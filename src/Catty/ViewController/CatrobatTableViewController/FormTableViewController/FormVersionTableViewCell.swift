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

class FormVersionTableViewCell: FormTableViewCell {

    let versionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.textAlignment = .natural
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override class var id: String {
        "FormVersionTableViewCell"
    }

    override func setupViews() {
        super.setupViews()

        contentView.addSubview(versionLabel)
    }

    override func setupConstraints() {
        super.setupConstraints()

        NSLayoutConstraint.activate([
            versionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            versionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }

    override func configure(with formItem: FormItem) {
        super.configure(with: formItem)
        setupVersion()
    }

    private func setupVersion() {
        let object = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        var version = "\(object!) (\(Util.appBuildVersion()!))"

        #if DEBUG
            version = "\(String(describing: version)) (DEBUG)"
        #endif

        versionLabel.text = version
    }
}
