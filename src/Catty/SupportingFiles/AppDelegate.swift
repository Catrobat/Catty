/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

import Siren

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        initNavigationBar()

        Siren.shared.wail()

        UITextField.appearance().keyboardAppearance = UIKeyboardAppearance.default

        let defaults = UserDefaults.standard
        let appDefaults = ["lockiphone": "YES"]
        defaults.register(defaults: appDefaults)

        if !Util.isPhiroActivated() {
            defaults.set(false, forKey: kUsePhiroBricks)
        }
        if !Util.isArduinoActivated() {
            defaults.set(false, forKey: kUseArduinoBricks)
        }
        defaults.synchronize()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        let vc = window?.rootViewController as? UINavigationController

        if vc?.topViewController is ScenePresenterViewController {
            let spvc = vc?.topViewController as? ScenePresenterViewController
            spvc?.continuePlayer()
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        let vc = window?.rootViewController as? UINavigationController

        if vc?.topViewController is ScenePresenterViewController {
            let spvc = vc?.topViewController as? ScenePresenterViewController
            spvc?.pausePlayer()
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        try? AVAudioSession.sharedInstance().setActive(false)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        let vc = window?.rootViewController as? UINavigationController

        if vc?.topViewController is ScenePresenterViewController {
            let spvc = vc?.topViewController as? ScenePresenterViewController
            spvc?.continuePlayer()
        }
    }

    func initNavigationBar() {
        UINavigationBar.appearance().barTintColor = UIColor.navBar()
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.navText()]
        window?.tintColor = UIColor.globalTint()
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let vc = window?.rootViewController as? UINavigationController
        vc?.popToRootViewController(animated: true)

        if vc?.topViewController is CatrobatTableViewController {
            let ctvc = vc?.topViewController as? CatrobatTableViewController
            ctvc?.addProjectFromInbox()
            return true
        }
        return false
    }
}
