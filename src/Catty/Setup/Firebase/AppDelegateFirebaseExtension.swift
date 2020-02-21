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

extension AppDelegate {

    @objc open var crashlytics: Crashlytics { Crashlytics.crashlytics() }

    var sendCrashReports: Bool { UserDefaults.standard.bool(forKey: kFirebaseSendCrashReports) }
    static let logNoValue = "No value"

    @objc func setupFirebase() {
        #if !DEBUG
        FirebaseApp.configure()
        setupCrashReports()
        #endif
    }

    @objc public func setupCrashReports() {
        if self.sendCrashReports {
            crashlytics.setCrashlyticsCollectionEnabled(true)

            addObserver(selector: #selector(self.baseTableViewControllerDidAppear(notification:)), name: .baseTableViewControllerDidAppear)
            addObserver(selector: #selector(self.baseCollectionViewControllerDidAppear(notification:)), name: .baseCollectionViewControllerDidAppear)
            addObserver(selector: #selector(self.alertDidAppear(notification:)), name: .alertDidAppear)
            addObserver(selector: #selector(self.paintViewControllerDidAppear(notification:)), name: .paintViewControllerDidAppear)
            addObserver(selector: #selector(self.formulaEditorViewControllerDidAppear(notification:)), name: .formulaEditorControllerDidAppear)
            addObserver(selector: #selector(self.scenePresenterViewControllerDidAppear(notification:)), name: .scenePresenterViewControllerDidAppear)
            addObserver(selector: #selector(self.brickSelected(notification:)), name: .brickSelected)
            addObserver(selector: #selector(self.projectInvalidVersion(notification:)), name: .projectInvalidVersion)
            addObserver(selector: #selector(self.projectInvalidXml(notification:)), name: .projectInvalidXml)
            addObserver(selector: #selector(self.projectFetchDetailsFailure(notification:)), name: .projectFetchDetailsFailure)
        }

        addObserver(selector: #selector(self.settingsCrashReportingChanged(notification:)), name: .settingsCrashReportingChanged)
    }

    @objc func settingsCrashReportingChanged(notification: Notification) {
        let enabled = (notification.object as? NSNumber)?.boolValue ?? false
        crashlytics.setCrashlyticsCollectionEnabled(enabled)
    }

    @objc func baseTableViewControllerDidAppear(notification: Notification) {
        let controllerClass = getObjectClassName(for: notification)
        let title = (notification.object as? UITableViewController)?.title ?? type(of: self).logNoValue
        crashlytics.log("BaseTableViewController (" + controllerClass + ") did appear with title: \"" + title + "\"")
    }

    @objc func baseCollectionViewControllerDidAppear(notification: Notification) {
        let controllerClass = getObjectClassName(for: notification)
        let title = (notification.object as? UICollectionViewController)?.title ?? type(of: self).logNoValue
        crashlytics.log("BaseCollectionViewController (" + controllerClass + ") did appear with title: \"" + title + "\"")
    }

    @objc func alertDidAppear(notification: Notification) {
        let title = (notification.object as? CustomAlertController)?.title ?? type(of: self).logNoValue
        crashlytics.log("Alert did appear with title: \"" + title + "\"")
    }

    @objc func paintViewControllerDidAppear(notification: Notification) {
        crashlytics.log("Paint started")
    }

    @objc func formulaEditorViewControllerDidAppear(notification: Notification) {
        crashlytics.log("FormulaEditor started")
    }

    @objc func scenePresenterViewControllerDidAppear(notification: Notification) {
        let projectName = (notification.object as? ScenePresenterViewController)?.project?.header.programName ?? type(of: self).logNoValue
        let projectId = (notification.object as? ScenePresenterViewController)?.project?.header.programID ?? type(of: self).logNoValue
        crashlytics.log("Scene started with Project: \"" + projectName + "\" (" + projectId + ")")
    }

    @objc func brickSelected(notification: Notification) {
        let controllerClass = getObjectClassName(for: notification)
        crashlytics.log("Brick selected: " + controllerClass)
    }

    @objc func projectInvalidVersion(notification: Notification) {
        let projectName = (notification.object as? ProjectLoadingInfo)?.visibleName ?? type(of: self).logNoValue
        let projectId = (notification.object as? ProjectLoadingInfo)?.projectID ?? type(of: self).logNoValue
        let userInfo = ["description": "Unsupported CatrobatLanguageVersion or code.xml not found for Project",
                        "projectId": projectId,
                        "projectName": projectName]

        let error = NSError(domain: "ProjectParserError", code: 500, userInfo: userInfo)
        crashlytics.record(error: error)
    }

    @objc func projectInvalidXml(notification: Notification) {
        let projectName = (notification.object as? ProjectLoadingInfo)?.visibleName ?? type(of: self).logNoValue
        let projectId = (notification.object as? ProjectLoadingInfo)?.projectID ?? type(of: self).logNoValue
        let userInfo = ["description": "Invalid XML for Project",
                        "projectId": projectId,
                        "projectName": projectName]

        let error = NSError(domain: "ProjectParserError", code: 501, userInfo: userInfo)
        crashlytics.record(error: error)
    }

    @objc func projectFetchDetailsFailure(notification: Notification) {
        let error = NSError(domain: "ProjectFetchDetailsError", code: 400, userInfo: notification.userInfo as? [String: Any] ?? [:])
        crashlytics.record(error: error)
    }

    private func getObjectClassName(for notification: Notification) -> String {
        if let object = notification.object {
            return String(describing: type(of: object))
        }
        return ""
    }

    private func addObserver(selector aSelector: Selector, name notification: NSNotification.Name) {
        NotificationCenter.default.addObserver(self, selector: aSelector, name: notification, object: nil)
    }
}
