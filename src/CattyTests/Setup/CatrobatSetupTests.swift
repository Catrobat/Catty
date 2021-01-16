/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

@testable import Pocket_Code

final class CatrobatSetupTests: XCTestCase {

    override func tearDown() {
        UserDefaults.standard.set(false, forKey: kUsePhiroBricks)
        UserDefaults.standard.set(false, forKey: kUseArduinoBricks)
    }

    func testRegisteredBricksPhiro() {
        UserDefaults.standard.set(false, forKey: kUsePhiroBricks)

        let bricks = CatrobatSetup.registeredBricks()

        UserDefaults.standard.set(true, forKey: kUsePhiroBricks)

        let bricksPhiroEnabled = CatrobatSetup.registeredBricks()
        XCTAssertTrue(bricksPhiroEnabled.count > bricks.count)
    }

    func testRegisteredBrickCategories() {
        UserDefaults.standard.set(false, forKey: kUsePhiroBricks)
        UserDefaults.standard.set(false, forKey: kUseArduinoBricks)

        let categories = CatrobatSetup.registeredBrickCategories()

        UserDefaults.standard.set(true, forKey: kUsePhiroBricks)

        let categoriesPhiroEnabled = CatrobatSetup.registeredBrickCategories()
        XCTAssertTrue(categoriesPhiroEnabled.count > categories.count)

        UserDefaults.standard.set(true, forKey: kUseArduinoBricks)

        let categoriesArduinoEnabled = CatrobatSetup.registeredBrickCategories()
        XCTAssertTrue(categoriesArduinoEnabled.count > categoriesPhiroEnabled.count)
    }
}
