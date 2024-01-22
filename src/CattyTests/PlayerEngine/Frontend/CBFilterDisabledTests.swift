/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

final class CBFilterDisabledTests: XCTestCase {

    func testFrontendFilterForDisabledBricks() {
        let startScript = StartScript()
        let waitBrick = WaitBrick()
        waitBrick.timeToWaitInSeconds = Formula(integer: 2)
        let setVariableBrick = SetVariableBrick()
        let changeVariableBrick = ChangeVariableBrick()
        startScript.brickList = [waitBrick, setVariableBrick, changeVariableBrick]
        changeVariableBrick.isDisabled = true

       let f = CBFilterDisabled()
        guard let filteredBrickList = f.filter(startScript) else {
            XCTFail("Could not filter Script")
            return
        }

        guard let brickList = startScript.brickList as? [Brick] else {
            XCTFail("Could not cast brickList into array of Brick elements")
            return
        }

        XCTAssertEqual(brickList.count, 3)
        XCTAssertEqual(filteredBrickList.count, 2)

        XCTAssertTrue(brickList.contains(changeVariableBrick))
        XCTAssertFalse(filteredBrickList.contains(changeVariableBrick))
    }

    func testFrontendFilterForDisabledScript() {
        let startScript = StartScript()
        let waitBrick = WaitBrick()
        waitBrick.timeToWaitInSeconds = Formula(integer: 2)
        startScript.brickList = [waitBrick]

        startScript.isDisabled = true

        let f = CBFilterDisabled()

        let filteredBrickList = f.filter(startScript)

        guard let brickList = startScript.brickList as? [Brick] else {
            XCTFail("Could not cast brickList into array of Brick elements")
            return
        }

        XCTAssertEqual(brickList.count, 1)
        XCTAssertNil(filteredBrickList)
    }
}
