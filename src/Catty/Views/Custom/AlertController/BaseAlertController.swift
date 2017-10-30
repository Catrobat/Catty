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
import UIKit


@objc public protocol AlertControllerProtocol {
    func showWithController(_ controller: UIViewController)
    func showWithController(_ controller: UIViewController, completion: @escaping () -> Void)

    func viewDidAppear(_ handler: @escaping (UIView) -> Void) -> AlertControllerProtocol
    func viewWillDisappear(_ handler: @escaping () -> Void) -> AlertControllerProtocol
}


@objc public protocol BuilderProtocol {
    func build() -> AlertControllerProtocol
}


protocol CustomAlertControllerDelegate {
    var viewDidAppear: ((UIView) -> Void)? { get set }
    var viewWillDisappear: (() -> Void)? { get set }
}


final class CustomAlertController: UIAlertController {
    fileprivate var delegate: CustomAlertControllerDelegate?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        delegate?.viewDidAppear?(self.view)
    }

    override func viewWillDisappear(_ animated: Bool) {
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
        alertController.view.tintColor = UIColor.globalTint()
        alertController.view.backgroundColor = UIColor.clear
        return self
    }

    @objc func viewDidAppear(_ handler: @escaping (UIView) -> Void) -> AlertControllerProtocol {
        self.viewDidAppear = handler
        return self
    }

    @objc func viewWillDisappear(_ handler: @escaping () -> Void) -> AlertControllerProtocol {
        self.viewWillDisappear = handler
        return self
    }
    
    @objc func showWithController(_ controller: UIViewController) {
        showWithController(controller, completion: {})
    }

    @objc func showWithController(_ controller: UIViewController, completion: @escaping () -> Void) {
        guard !Util.activateTestMode(false) else {
            return
        }
        let presentingController = !controller.isViewLoaded || controller.view.window == nil ?
                Util.topViewController(in: controller) : controller
        presentingController?.present(alertController, animated: true, completion: completion)
    }
}
