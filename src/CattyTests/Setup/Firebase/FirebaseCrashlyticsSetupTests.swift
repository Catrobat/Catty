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
@testable import Pocket_Code
import XCTest

final class FirebaseCrashlyticsSetupTests: XCTestCase {

    var app: AppDelegate?
    var crashlytics: CrashlyticsMock?

    override func setUp() {
        super.setUp()

        crashlytics = CrashlyticsMock(collectionEnabled: false)
        app = AppDelegateMock(crashlytics: crashlytics!)
    }

    func testSetupCrashReportsEnabled() {
        UserDefaults.standard.set(true, forKey: kFirebaseSendCrashReports)

        app?.setupCrashReports()
        XCTAssertTrue(crashlytics!.isCrashlyticsCollectionEnabled())
    }

    func testSetupCrashReportsDisabled() {
        UserDefaults.standard.set(false, forKey: kFirebaseSendCrashReports)

        app?.setupCrashReports()
        XCTAssertFalse(crashlytics!.isCrashlyticsCollectionEnabled())
    }

    func testSettingsDisabledNotification() {
        UserDefaults.standard.set(true, forKey: kFirebaseSendCrashReports)
        app?.setupCrashReports()

        NotificationCenter.default.post(name: .settingsCrashReportingChanged, object: NSNumber(0))
        XCTAssertFalse(crashlytics!.isCrashlyticsCollectionEnabled())
    }

    func testSettingsEnabledNotification() {
        UserDefaults.standard.set(false, forKey: kFirebaseSendCrashReports)
        app?.setupCrashReports()

        NotificationCenter.default.post(name: .settingsCrashReportingChanged, object: NSNumber(1))
        XCTAssertTrue(crashlytics!.isCrashlyticsCollectionEnabled())
    }

    func testBaseTableViewControllerDidAppearNotification() {
        UserDefaults.standard.set(true, forKey: kFirebaseSendCrashReports)
        app?.setupCrashReports()

        NotificationCenter.default.post(name: .baseTableViewControllerDidAppear, object: nil)

        XCTAssertEqual(1, crashlytics!.logs.count)
        XCTAssertEqual(0, crashlytics!.records.count)
    }

    func testBaseCollectionViewControllerDidAppearNotification() {
        UserDefaults.standard.set(true, forKey: kFirebaseSendCrashReports)
        app?.setupCrashReports()

        NotificationCenter.default.post(name: .baseCollectionViewControllerDidAppear, object: nil)

        XCTAssertEqual(1, crashlytics!.logs.count)
        XCTAssertEqual(0, crashlytics!.records.count)
    }

    func testPaintViewControllerDidAppearNotification() {
        UserDefaults.standard.set(true, forKey: kFirebaseSendCrashReports)
        app?.setupCrashReports()

        NotificationCenter.default.post(name: .paintViewControllerDidAppear, object: nil)

        XCTAssertEqual(1, crashlytics!.logs.count)
        XCTAssertEqual(0, crashlytics!.records.count)
    }

    func testFormulaEditorControllerDidAppearNotification() {
        UserDefaults.standard.set(true, forKey: kFirebaseSendCrashReports)
        app?.setupCrashReports()

        NotificationCenter.default.post(name: .formulaEditorControllerDidAppear, object: nil)

        XCTAssertEqual(1, crashlytics!.logs.count)
        XCTAssertEqual(0, crashlytics!.records.count)
    }

    func testScenePresenterViewControllerDidAppearNotification() {
        UserDefaults.standard.set(true, forKey: kFirebaseSendCrashReports)
        app?.setupCrashReports()

        NotificationCenter.default.post(name: .scenePresenterViewControllerDidAppear, object: nil)

        XCTAssertEqual(1, crashlytics!.logs.count)
        XCTAssertEqual(0, crashlytics!.records.count)
    }

    func testBrickSelectedNotification() {
        UserDefaults.standard.set(true, forKey: kFirebaseSendCrashReports)
        app?.setupCrashReports()

        NotificationCenter.default.post(name: .brickSelected, object: nil)

        XCTAssertEqual(1, crashlytics!.logs.count)
        XCTAssertEqual(0, crashlytics!.records.count)
    }

    func testProjectInvalidVersionNotification() {
        UserDefaults.standard.set(true, forKey: kFirebaseSendCrashReports)
        app?.setupCrashReports()

        NotificationCenter.default.post(name: .projectInvalidVersion, object: nil)

        XCTAssertEqual(0, crashlytics!.logs.count)
        XCTAssertEqual(1, crashlytics!.records.count)
    }

    func testProjectFetchDetailsFailureNotification() {
        UserDefaults.standard.set(true, forKey: kFirebaseSendCrashReports)
        app?.setupCrashReports()

        NotificationCenter.default.post(name: .projectFetchDetailsFailure, object: nil)

        XCTAssertEqual(0, crashlytics!.logs.count)
        XCTAssertEqual(1, crashlytics!.records.count)
    }
}
