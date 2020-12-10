/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

import Firebase
import Siren
import UIKit

func uncaughtExceptionHandler(exception: NSException) {
    debugPrint("uncaught exception: ", exception.description)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var firebaseAnalyticsReporter: FirebaseAnalyticsReporter?
    var firebaseCrashlyticsReporter: FirebaseCrashlyticsReporter?
    var audioEngineHelper = AudioEngineHelper()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.setupFirebase()
        self.setupSiren()

        self.initNavigationBar()
        ThemesHelper.changeAppearance()
        let defaults = UserDefaults.standard
        let appDefaults = NSDictionary.init(dictionary: ["lockiphone": "YES"]) as! [String: Any]
        defaults.register(defaults: appDefaults)

        self.setDefaultUserDefaults(defaults: defaults)
        defaults.synchronize()
        if ProcessInfo.processInfo.arguments.contains("UITests") {
            UIApplication.shared.keyWindow?.layer.speed = 10.0
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        let vc = self.window?.rootViewController as! UINavigationController

        if let spvc = vc.topViewController as? StagePresenterViewController {
            spvc.pauseAction()
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        audioEngineHelper.deactivateAudioSession()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        let vc = self.window?.rootViewController as! UINavigationController
        if let _ = vc.topViewController as? StagePresenterViewController {
            audioEngineHelper.activateAudioSession()
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        let vc = window!.rootViewController as! UINavigationController
        if let spvc = vc.topViewController as? StagePresenterViewController {
            if !spvc.isPaused() {
                spvc.resumeAction()
            }
        }
    }

    func initNavigationBar() {
        UINavigationBar.appearance().barTintColor = UIColor.navBar
        UINavigationBar.appearance().tintColor = UIColor.navTint
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.navText]
        UINavigationBar.appearance().barStyle = UIBarStyle.black
        self.window?.tintColor = UIColor.globalTint
    }

    func setDefaultUserDefaults(defaults: UserDefaults) {

        if !Util.isPhiroActivated() {
            defaults.set(false, forKey: kUsePhiroBricks)
        }
        if !Util.isArduinoActivated() {
            defaults.set(false, forKey: kUseArduinoBricks)
        }

        if defaults.value(forKey: kFirebaseSendCrashReports) == nil {
            defaults.set(kFirebaseSendCrashReportsDefault, forKey: kFirebaseSendCrashReports)
        }
    }

    func setupFirebase() {
        #if !DEBUG
        FirebaseApp.configure()
        firebaseAnalyticsReporter = FirebaseAnalyticsReporter.init(analytics: Analytics.self)
        firebaseCrashlyticsReporter = FirebaseCrashlyticsReporter.init(crashlytics: Crashlytics.crashlytics())
        #endif
    }

    @objc func setupSiren() {
        Siren.shared.wail()
    }

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        let vc = self.window?.rootViewController as? UINavigationController
        vc?.setNavigationBarHidden(false, animated: false)
        vc?.popToRootViewController(animated: true)

        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL,
            let ctvc = vc?.topViewController as? CatrobatTableViewController else {
                return false
        }
        ctvc.openURL(url: url)
        return true
    }
}
