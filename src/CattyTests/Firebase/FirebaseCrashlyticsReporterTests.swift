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

final class FirebaseCrashlyticsReporterTests: XCTestCase {

    var crashlytics: CrashlyticsMock?
    var reporter: FirebaseCrashlyticsReporter?

    override func setUp() {
        super.setUp()

        crashlytics = CrashlyticsMock(collectionEnabled: false)
        UserDefaults.standard.set(true, forKey: kFirebaseSendCrashReports)
        reporter = FirebaseCrashlyticsReporter(crashlytics: crashlytics!)
    }

    func testSetupCrashReportsEnabled() {
        XCTAssertTrue(crashlytics!.isCrashlyticsCollectionEnabled())
    }

    func testSetupCrashReportsDisabled() {
        UserDefaults.standard.set(false, forKey: kFirebaseSendCrashReports)

        crashlytics = CrashlyticsMock(collectionEnabled: false)
        _ = FirebaseCrashlyticsReporter(crashlytics: crashlytics!)
        XCTAssertFalse(crashlytics!.isCrashlyticsCollectionEnabled())
    }

    func testSettingsDisabledNotification() {
        NotificationCenter.default.post(name: .settingsCrashReportingChanged, object: NSNumber(0))
        XCTAssertFalse(crashlytics!.isCrashlyticsCollectionEnabled())
    }

    func testSettingsEnabledNotification() {
        UserDefaults.standard.set(false, forKey: kFirebaseSendCrashReports)

        NotificationCenter.default.post(name: .settingsCrashReportingChanged, object: NSNumber(1))
        XCTAssertTrue(crashlytics!.isCrashlyticsCollectionEnabled())
    }

    func testBaseTableViewControllerDidAppearNotification() {
        NotificationCenter.default.post(name: .baseTableViewControllerDidAppear, object: nil)

        XCTAssertEqual(1, crashlytics!.logs.count)
        XCTAssertEqual(0, crashlytics!.records.count)
    }

    func testBaseCollectionViewControllerDidAppearNotification() {
        NotificationCenter.default.post(name: .baseCollectionViewControllerDidAppear, object: nil)

        XCTAssertEqual(1, crashlytics!.logs.count)
        XCTAssertEqual(0, crashlytics!.records.count)
    }

    func testPaintViewControllerDidAppearNotification() {
        NotificationCenter.default.post(name: .paintViewControllerDidAppear, object: nil)

        XCTAssertEqual(1, crashlytics!.logs.count)
        XCTAssertEqual(0, crashlytics!.records.count)
    }

    func testFormulaEditorControllerDidAppearNotification() {
        NotificationCenter.default.post(name: .formulaEditorControllerDidAppear, object: nil)

        XCTAssertEqual(1, crashlytics!.logs.count)
        XCTAssertEqual(0, crashlytics!.records.count)
    }

    func testScenePresenterViewControllerDidAppearNotification() {
        NotificationCenter.default.post(name: .stagePresenterViewControllerDidAppear, object: nil)

        XCTAssertEqual(1, crashlytics!.logs.count)
        XCTAssertEqual(0, crashlytics!.records.count)
    }

    func testBrickSelectedNotification() {
        let brick = NoteBrick()
        NotificationCenter.default.post(name: .brickSelected, object: brick)

        XCTAssertEqual(1, crashlytics!.logs.count)
        XCTAssertEqual(0, crashlytics!.records.count)

        XCTAssertEqual("Brick selected: " + String(describing: type(of: brick)), crashlytics!.logs.first as String?)
    }

    func testBrickRemovedNotification() {
        NotificationCenter.default.post(name: .brickRemoved, object: nil)

        XCTAssertEqual(1, crashlytics!.logs.count)
        XCTAssertEqual(0, crashlytics!.records.count)
    }

    func testBrickEnabledNotification() {
        NotificationCenter.default.post(name: .brickEnabled, object: nil)

        XCTAssertEqual(1, crashlytics!.logs.count)
        XCTAssertEqual(0, crashlytics!.records.count)
    }

    func testBrickDisabledNotification() {
        NotificationCenter.default.post(name: .brickDisabled, object: nil)

        XCTAssertEqual(1, crashlytics!.logs.count)
        XCTAssertEqual(0, crashlytics!.records.count)
    }

    func testProjectInvalidVersionNotification() {
        NotificationCenter.default.post(name: .projectInvalidVersion, object: nil)

        XCTAssertEqual(0, crashlytics!.logs.count)
        XCTAssertEqual(1, crashlytics!.records.count)
    }

    func testProjectFetchFailureNotification() {
        let errorInfo = ProjectFetchFailureInfo(type: nil, url: "testurl", statusCode: nil, description: "Invalid API response while fetching project")

        let expectedErrorValue: String = "No value"
        let info: [String: Any] = ["type": expectedErrorValue,
                                   "url": errorInfo.url,
                                   "statusCode": expectedErrorValue,
                                   "description": errorInfo.description]

        let error = NSError(domain: "ProjectFetchError", code: 410, userInfo: info)

        NotificationCenter.default.post(name: .projectFetchFailure, object: errorInfo)

        XCTAssertEqual(0, crashlytics!.logs.count)
        XCTAssertEqual(1, crashlytics!.records.count)
        XCTAssertEqual(error.domain, (crashlytics!.records.first as NSError?)?.domain)
        XCTAssertEqual(error.userInfo as NSDictionary, (crashlytics!.records.first! as NSError).userInfo as NSDictionary)
    }

    func testProjectFetchDetailsFailureNotification() {
        NotificationCenter.default.post(name: .projectFetchDetailsFailure, object: nil)

        XCTAssertEqual(0, crashlytics!.logs.count)
        XCTAssertEqual(1, crashlytics!.records.count)
    }

    func testProjectSearchFailureNotification() {
        var errorInfo = ProjectFetchFailureInfo(url: "testUrl", statusCode: nil, description: "Invalid API response while fetching project", projectName: nil)

        let expectedErrorValue = "No value"
        var projectInfo: [String: Any] = ["description": errorInfo.description,
                                          "projectName": expectedErrorValue,
                                          "statusCode": expectedErrorValue,
                                          "url": errorInfo.url]

        var error = NSError(domain: "ProjectSearchError", code: 400, userInfo: projectInfo)

        NotificationCenter.default.post(name: .projectSearchFailure, object: errorInfo)

        XCTAssertEqual(0, crashlytics!.logs.count)
        XCTAssertEqual(1, crashlytics!.records.count)
        XCTAssertEqual(error.domain, (crashlytics!.records.first as NSError?)?.domain)
        XCTAssertEqual(error.userInfo as NSDictionary, (crashlytics!.records.first! as NSError).userInfo as NSDictionary)

        errorInfo = ProjectFetchFailureInfo(url: "testUrl", statusCode: 404, description: "Invalid API response while fetching project", projectName: "Galaxy")

        projectInfo["projectName"] = errorInfo.projectName
        projectInfo["statusCode"] = errorInfo.statusCode

        error = NSError(domain: "ProjectSearchError", code: 404, userInfo: projectInfo)

        NotificationCenter.default.post(name: .projectSearchFailure, object: errorInfo)

        XCTAssertEqual(0, crashlytics!.logs.count)
        XCTAssertEqual(2, crashlytics!.records.count)
        XCTAssertEqual(error.domain, (crashlytics!.records.last as NSError?)?.domain)
        XCTAssertEqual(error.userInfo as NSDictionary, (crashlytics!.records.last! as NSError).userInfo as NSDictionary)
    }

    func testMediaLibraryDownloadIndexFailureNotification() {
        let errorInfo = MediaLibraryDownloadFailureInfo(url: "testUrl", statusCode: 404, description: "Invalid Response while downloading media library index")

        let info: [String: Any] = ["url": errorInfo.url,
                                   "statusCode": errorInfo.statusCode as Any,
                                   "description": errorInfo.description]

        let error = NSError(domain: "MediaLibraryDownloadIndexError", code: 420, userInfo: info)

        NotificationCenter.default.post(name: .mediaLibraryDownloadIndexFailure, object: errorInfo)

        XCTAssertEqual(0, crashlytics!.logs.count)
        XCTAssertEqual(1, crashlytics!.records.count)
        XCTAssertEqual(error.domain, (crashlytics!.records.first as NSError?)?.domain)
        XCTAssertEqual(error.userInfo as NSDictionary, (crashlytics!.records.first! as NSError).userInfo as NSDictionary)
    }

    func testMediaLibraryDownloadDataFailureNotification() {
        let errorInfo = MediaLibraryDownloadFailureInfo(url: "testUrl", statusCode: 404, description: "Invalid Response while downloading media library data")

        let info: [String: Any] = ["url": errorInfo.url,
                                   "statusCode": errorInfo.statusCode as Any,
                                   "description": errorInfo.description]

        let error = NSError(domain: "MediaLibraryDownloadDataError", code: 430, userInfo: info)

        NotificationCenter.default.post(name: .mediaLibraryDownloadDataFailure, object: errorInfo)

        XCTAssertEqual(0, crashlytics!.logs.count)
        XCTAssertEqual(1, crashlytics!.records.count)
        XCTAssertEqual(error.domain, (crashlytics!.records.first as NSError?)?.domain)
        XCTAssertEqual(error.userInfo as NSDictionary, (crashlytics!.records.first! as NSError).userInfo as NSDictionary)
    }
}
