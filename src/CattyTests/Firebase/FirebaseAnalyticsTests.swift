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

import Firebase

@testable import Pocket_Code

import XCTest

final class FirebaseAnalyticsTests: XCTestCase {

    var analytics = AnalyticsMock.self
    var reporter: FirebaseAnalyticsReporter?

    override func setUp() {
        reporter = FirebaseAnalyticsReporter(analytics: analytics)
    }

    func testBrickSelectedNotification() {
        let previousCount = analytics.loggedEvents.count
        let brick = NoteBrick()
        NotificationCenter.default.post(name: .brickSelected, object: brick)

        XCTAssertEqual(analytics.loggedEvents.count, previousCount + 1)
        XCTAssertEqual(String(describing: type(of: brick)), analytics.loggedEvents["brick_selected"]??.first?.value as! String)
    }

    func testBrickRemovedNotification() {
        let previousCount = analytics.loggedEvents.count

        NotificationCenter.default.post(name: .brickRemoved, object: nil)

        XCTAssertEqual(analytics.loggedEvents.count, previousCount + 1)
    }

    func testBrickEnabledNotification() {
        let previousCount = analytics.loggedEvents.count

        NotificationCenter.default.post(name: .brickEnabled, object: nil)

        XCTAssertEqual(analytics.loggedEvents.count, previousCount + 1)
    }

    func testBrickDisabledNotification() {
        let previousCount = analytics.loggedEvents.count

        NotificationCenter.default.post(name: .brickDisabled, object: nil)

        XCTAssertEqual(analytics.loggedEvents.count, previousCount + 1)
    }

    func testScriptEnabledNotification() {
        let previousCount = analytics.loggedEvents.count
        let script = WhenScript()

        NotificationCenter.default.post(name: .scriptEnabled, object: script)

        XCTAssertEqual(analytics.loggedEvents.count, previousCount + 1)
        XCTAssertEqual(String(describing: type(of: script)), analytics.loggedEvents["script_enabled"]??.first?.value as! String)
    }

    func testScriptDisabledNotification() {
        let previousCount = analytics.loggedEvents.count
        let script = WhenScript()

        NotificationCenter.default.post(name: .scriptDisabled, object: script)

        XCTAssertEqual(analytics.loggedEvents.count, previousCount + 1)
        XCTAssertEqual(String(describing: type(of: script)), analytics.loggedEvents["script_disabled"]??.first?.value as! String)
    }

    func testFormulaSavedNotification() {
        let previousCount = analytics.loggedEvents.count
        let formula = Formula(string: "1234")!

        NotificationCenter.default.post(name: .formulaSaved, object: formula)

        XCTAssertEqual(analytics.loggedEvents.count, previousCount + 1)

        let event = analytics.loggedEvents["formula_saved"]!
        XCTAssertEqual(formula.getDisplayString(), event?[AnalyticsParameterItemName] as? String)
    }
}
