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

class NavigationControllerMock: UINavigationController {

    var currentViewController: UIViewController?
    var navigationBarFrame = CGRect.zero
    var toolbarFrame = CGRect.zero

    override var navigationBar: UINavigationBar {
        let navigationBar = UINavigationBar()
        navigationBar.frame = self.navigationBarFrame
        return navigationBar
    }

    override var toolbar: UIToolbar {
        let toolbar = UIToolbar()
        toolbar.frame = self.toolbarFrame
        return toolbar
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        self.currentViewController = viewController
    }

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        self.currentViewController = viewControllerToPresent
    }
}
