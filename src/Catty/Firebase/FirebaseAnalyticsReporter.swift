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

class FirebaseAnalyticsReporter {
    @objc open var analytics: Analytics.Type

    @objc init(analytics: Analytics.Type) {
        self.analytics = analytics
        setupAnalytics()
    }

    private func setupAnalytics() {
        analytics.setAnalyticsCollectionEnabled(true)

        addObserver(selector: #selector(self.brickSelected(notification:)), name: .brickSelected)
        addObserver(selector: #selector(self.brickRemoved(notification:)), name: .brickRemoved)
        addObserver(selector: #selector(self.brickEnabled(notification:)), name: .brickEnabled)
        addObserver(selector: #selector(self.brickDisabled(notification:)), name: .brickDisabled)
        addObserver(selector: #selector(self.scriptEnabled(notification:)), name: .scriptEnabled)
        addObserver(selector: #selector(self.scriptDisabled(notification:)), name: .scriptDisabled)
    }

    @objc func brickSelected(notification: Notification) {
        let brickClass = getObjectClassName(for: notification)
        analytics.logEvent("brick_selected", parameters: [AnalyticsParameterItemName: brickClass])
    }

    @objc func brickRemoved(notification: Notification) {
        let brickClass = getObjectClassName(for: notification)
        analytics.logEvent("brick_removed", parameters: [AnalyticsParameterItemName: brickClass])
    }

    @objc func brickEnabled(notification: Notification) {
        let brickClass = getObjectClassName(for: notification)
        analytics.logEvent("brick_enabled", parameters: [AnalyticsParameterItemName: brickClass])
    }

    @objc func brickDisabled(notification: Notification) {
        let brickClass = getObjectClassName(for: notification)
        analytics.logEvent("brick_disabled", parameters: [AnalyticsParameterItemName: brickClass])
    }

    @objc func scriptEnabled(notification: Notification) {
        let scriptClass = getObjectClassName(for: notification)
        analytics.logEvent("script_enabled", parameters: [AnalyticsParameterItemName: scriptClass])
    }

    @objc func scriptDisabled(notification: Notification) {
        let scriptClass = getObjectClassName(for: notification)
        analytics.logEvent("script_disabled", parameters: [AnalyticsParameterItemName: scriptClass])
    }

    private func addObserver(selector aSelector: Selector, name notification: NSNotification.Name) {
        NotificationCenter.default.addObserver(self, selector: aSelector, name: notification, object: nil)
    }

    private func getObjectClassName(for notification: Notification) -> String {
        if let object = notification.object {
            return String(describing: type(of: object))
        }
        return ""
    }
}
