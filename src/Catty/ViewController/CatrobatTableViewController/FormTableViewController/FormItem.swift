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

class FormItem {
    var title: String?
    var titleColor: UIColor = .black
    var accessoryType: UITableViewCell.AccessoryType = .none
    var action: (() -> Void)?
    var cellType: FormTableViewCell.Type = FormTableViewCell.self

    init(title: String? = nil, titleColor: UIColor = .black, accessoryType: UITableViewCell.AccessoryType = .none, action: (() -> Void)? = nil) {
        self.title = title
        self.titleColor = titleColor
        self.accessoryType = accessoryType
        self.action = action
    }
}

class FormSwitchItem: FormItem {
    var switchAction: ((Bool) -> Void)?

    init(title: String? = nil, switchAction: ((Bool) -> Void)? = nil) {
        super.init(title: title)

        self.switchAction = switchAction
        self.cellType = FormSwitchTableViewCell.self
    }
}

class FormArduinoSwitchItem: FormSwitchItem {
    init(switchAction: ((Bool) -> Void)? = nil) {
        super.init(title: kLocalizedCategoryArduino, switchAction: switchAction)

        self.cellType = FormArduinoSwitchTableViewCell.self
    }
}

class FormEmbroiderySwitchItem: FormSwitchItem {
    init() {
        super.init(title: kLocalizedCategoryEmbroidery)

        self.cellType = FormEmbroiderySwitchTableViewCell.self
    }
}

class FormPhiroSwitchItem: FormSwitchItem {
    init() {
        super.init(title: kLocalizedCategoryPhiro)

        self.cellType = FormPhiroSwitchTableViewCell.self
    }
}

class FormCrashReportsSwitchItem: FormSwitchItem {
    init(switchAction: ((Bool) -> Void)? = nil) {
        super.init(title: kLocalizedSendCrashReports, switchAction: switchAction)

        self.cellType = FormCrashReportsSwitchTableViewCell.self
    }
}

class FormTextFieldItem: FormItem {
    var placeholder: String?
    var typeAction: ((String) -> Void)?
    var returnAction: (() -> Void)?
    var focus = false

    init(typeAction: ((String) -> Void)? = nil, returnAction: (() -> Void)? = nil, placeholder: String?, focus: Bool) {
        super.init()

        self.placeholder = placeholder
        self.typeAction = typeAction
        self.returnAction = returnAction
        self.cellType = FormTextFieldTableViewCell.self
        self.focus = focus
    }
}

class FormCheckItem: FormItem {
    var selectAction: (() -> Void)?

    init(title: String? = nil, selectAction: (() -> Void)? = nil) {
        super.init(title: title)

        self.selectAction = selectAction
        self.cellType = FormCheckTableViewCell.self
    }
}

class FormVersionItem: FormItem {
    init() {
        super.init(title: kLocalizedVersion)

        self.cellType = FormVersionTableViewCell.self
    }
}
