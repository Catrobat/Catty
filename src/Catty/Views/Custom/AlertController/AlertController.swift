/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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


@objc public protocol AlertActionAdding {
    func addDefaultActionWithTitle(title: String, handler: (() -> Void)?) -> AlertControllerBuilding
    func addDestructiveActionWithTitle(title: String, handler: (() -> Void)?) -> AlertControllerBuilding
    func addCancelActionWithTitle(title: String, handler: (() -> Void)?) -> AlertControllerBuilding
}


@objc public protocol AlertControllerBuilding: BuilderProtocol, AlertActionAdding { }


final class AlertController: BaseAlertController, AlertControllerBuilding {
    @objc func addCancelActionWithTitle(title: String, handler: (() -> Void)?) -> AlertControllerBuilding {
        alertController.addAction(UIAlertAction(title: title, style: .Cancel) {_ in handler?() })
        return self
    }

    @objc func addDefaultActionWithTitle(title: String, handler: (() -> Void)?) -> AlertControllerBuilding {
        alertController.addAction(UIAlertAction(title: title, style: .Default) {_ in handler?() })
        return self
    }

    @objc func addDestructiveActionWithTitle(title: String, handler: (() -> Void)?) -> AlertControllerBuilding {
        alertController.addAction(UIAlertAction(title: title, style: .Destructive) {_ in handler?() })
        return self
    }
}
