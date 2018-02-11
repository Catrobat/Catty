/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

@objc
public final class AlertControllerBuilder: NSObject {
    @objc(alertWithTitle:message:)
    public static func alert(title: String?, message: String?) -> AlertActionAdding {
        return AlertController(title: title, message: message, style: .alert)
    }

    @objc(actionSheetWithTitle:)
    public static func actionSheet(title: String) -> AlertActionAdding {
        return AlertController(title: title, message: nil, style: .actionSheet)
    }

    @objc(textFieldAlertWithTitle:message:)
    public static func textFieldAlert(title: String?, message: String?) -> TextFieldAlertDefining {
        return TextFieldAlertController(title: title, message: message)
    }
}
