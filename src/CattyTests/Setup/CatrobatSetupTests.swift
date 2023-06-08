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
        UserDefaults.standard.set(false, forKey: kUseEmbroideryBricks)

        var categories = CatrobatSetup.registeredBrickCategories()

        UserDefaults.standard.set(true, forKey: kUsePhiroBricks)

        let categoriesPhiroEnabled = CatrobatSetup.registeredBrickCategories()
        XCTAssertEqual(categoriesPhiroEnabled.count, categories.count + 1)

        for category in categories where category.name == kLocalizedCategoryEmbroidery || category.name == kLocalizedCategoryArduino {
            XCTAssertEqual(category.enabled, false)
        }

        UserDefaults.standard.set(true, forKey: kUseArduinoBricks)
        UserDefaults.standard.set(true, forKey: kUseEmbroideryBricks)

        categories = CatrobatSetup.registeredBrickCategories()

        for category in categories where category.name == kLocalizedCategoryEmbroidery || category.name == kLocalizedCategoryArduino {
            XCTAssertEqual(category.enabled, true)
        }
    }
}
