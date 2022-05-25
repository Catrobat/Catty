/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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

import XCTest

class SettingsTVCTests: XCTestCase {

    func testSettings() {
        let app = launchApp()
        app.navigationBars.buttons[PocketCodeMainScreenTests.settingsButtonLabel].tap()

        XCTAssert(app.navigationBars[kLocalizedSettings].exists)
        app.switches[kLocalizedCategoryArduino].tap()
        app.switches[kLocalizedSendCrashReports].tap()

        app.staticTexts[kLocalizedAboutUs].tap()
        XCTAssert(app.navigationBars[kLocalizedAboutPocketCode].exists)
        app.navigationBars.buttons[kLocalizedSettings].tap()

        app.staticTexts[kLocalizedTermsOfUse].tap()
        XCTAssert(app.navigationBars[kLocalizedTermsOfUse].exists)

        app.navigationBars.buttons[kLocalizedSettings].tap()
        XCTAssert(app.navigationBars[kLocalizedSettings].exists)
    }

    func testArduinoSettings() {
        let app = launchApp()
        app.navigationBars.buttons[PocketCodeMainScreenTests.settingsButtonLabel].tap()

        if app.switches[kLocalizedCategoryArduino].value as! String == "0" {
            app.switches[kLocalizedCategoryArduino].tap()
        }

        app.navigationBars.buttons[kLocalizedPocketCode].tap()
        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        app.tables.staticTexts[kLocalizedMyFirstProject].tap()
        app.tables.staticTexts["Mole 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        app.toolbars.buttons[kLocalizedUserListAdd].tap()
        findBrickSection(kLocalizedCategoryArduino, in: app)

        XCTAssertTrue(app.navigationBars[kLocalizedCategoryArduino].exists)
    }

    func testArduinoRemoveKnownDevices() {
        let app = launchApp(with: XCTestCase.defaultLaunchArguments + ["-KnownBluetoothDevices", "(c607572a-abdb-4f9d-ba08-7c0565944621,52809a73-fc49-4de8-9857-be3a9a0b2f5e)"])
        app.navigationBars.buttons[PocketCodeMainScreenTests.settingsButtonLabel].tap()

        if app.switches[kLocalizedCategoryArduino].value as! String == "0" {
            app.switches[kLocalizedCategoryArduino].tap()
        }

        XCTAssert(app.tables.staticTexts[kLocalizedArduinoBricks].exists)

        app.tables.staticTexts[kLocalizedRemoveKnownDevices].tap()
        XCTAssert(app.alerts.staticTexts[kLocalizedRemovedKnownBluetoothDevices].exists)
    }

    func testArduinoNoneKnownDevice() {
        let app = launchApp(with: XCTestCase.defaultLaunchArguments + ["-KnownBluetoothDevices", "()"])
        app.navigationBars.buttons[PocketCodeMainScreenTests.settingsButtonLabel].tap()

        if app.switches[kLocalizedCategoryArduino].value as! String == "0" {
            app.switches[kLocalizedCategoryArduino].tap()
        }

        XCTAssertFalse(app.tables.staticTexts[kLocalizedArduinoBricks].exists)
        XCTAssertFalse(app.tables.staticTexts[kLocalizedRemoveKnownDevices].exists)
    }

    func testArduinoExtensionHidden() {
        let app = launchApp()
        app.navigationBars.buttons[PocketCodeMainScreenTests.settingsButtonLabel].tap()

        if app.switches[kLocalizedCategoryArduino].value as! String == "1" {
            app.switches[kLocalizedCategoryArduino].tap()
        }

        XCTAssertFalse(app.tables.staticTexts[kLocalizedArduinoBricks].exists)
        XCTAssertFalse(app.tables.staticTexts[kLocalizedRemoveKnownDevices].exists)
    }

    func testWebAccessShown() {
        let app = launchApp(with: XCTestCase.defaultLaunchArguments + ["-useWebRequestBrick", "true"])
        app.navigationBars.buttons[PocketCodeMainScreenTests.settingsButtonLabel].tap()
        XCTAssert(app.tables.staticTexts[kLocalizedWebAccess].exists)

        app.tables.staticTexts[kLocalizedTrustedDomains].tap()
        XCTAssert(app.navigationBars.staticTexts[kLocalizedWebAccess].exists)
    }
}
