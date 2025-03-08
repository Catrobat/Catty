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
import UIKit

class FormCheckTableViewCell: FormTableViewCell {

    override class var id: String {
        "FormCheckTableViewCell"
    }

    private var selectAction: (() -> Void)?

    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            selectAction?()
            self.accessoryType = .checkmark
        } else {
            self.accessoryType = .none
        }
    }

    override func configure(with formItem: FormItem) {
        super.configure(with: formItem)

        if let item = formItem as? FormCheckItem {
            selectAction = item.selectAction
        }
    }
}
