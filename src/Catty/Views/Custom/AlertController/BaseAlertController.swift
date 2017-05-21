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


@objc public protocol AlertControllerProtocol {
    func showWithController(controller: UIViewController)
    func showWithController(controller: UIViewController, completion: () -> Void)

    func viewDidAppear(handler: (UIView) -> Void) -> AlertControllerProtocol
    func viewWillDisappear(handler: () -> Void) -> AlertControllerProtocol
}


@objc public protocol BuilderProtocol {
    func build() -> AlertControllerProtocol
}


protocol CustomAlertControllerDelegate {
    var viewDidAppear: ((UIView) -> Void)? { get set }
    var viewWillDisappear: (() -> Void)? { get set }
}


final class CustomAlertController: UIAlertController {
    private var delegate: CustomAlertControllerDelegate?

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        delegate?.viewDidAppear?(self.view)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        delegate?.viewWillDisappear?()
    }
}


class BaseAlertController: NSObject, AlertControllerProtocol, BuilderProtocol, CustomAlertControllerDelegate {
    let alertController: CustomAlertController
    var viewDidAppear: ((UIView) -> Void)?
    var viewWillDisappear: (() -> Void)?


    init(title: String?, message: String?, style: UIAlertControllerStyle) {
        alertController = CustomAlertController(title: title, message: message, preferredStyle: style)

        super.init()
        alertController.delegate = self
    }

    @objc func build() -> AlertControllerProtocol {
        alertController.view.tintColor = UIColor.globalTintColor()
        alertController.view.backgroundColor = UIColor.clearColor()
        return self
    }

    @objc func viewDidAppear(handler: (UIView) -> Void) -> AlertControllerProtocol {
        self.viewDidAppear = handler
        return self
    }

    @objc func viewWillDisappear(handler: () -> Void) -> AlertControllerProtocol {
        self.viewWillDisappear = handler
        return self
    }
    
    @objc func showWithController(controller: UIViewController) {
        showWithController(controller, completion: {})
    }

    @objc func showWithController(controller: UIViewController, completion: () -> Void) {
        guard !Util.activateTestMode(false) else {
            return
        }
        let presentingController = !controller.isViewLoaded() || controller.view.window == nil ?
                Util.topViewControllerInViewController(controller) : controller
        presentingController.presentViewController(alertController, animated: true, completion: completion)
    }
}
