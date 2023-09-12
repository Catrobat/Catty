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

import Foundation
import XCTest

@testable import Pocket_Code

class ParseMultipleScenesTests: XMLAbstractTest {

    func testBasicTwoSceneFile() {
        let project = self.getProjectForXML(xmlFile: "MultipleScenes")
        XCTAssertEqual(project.scenes.count, 2)

        let scene1 = project.scenes[0] as! Scene
        XCTAssertEqual(scene1.name, "Scene 1")
        XCTAssertEqual(scene1.objects().count, 1)

        let obj1 = scene1.objects()[0]
        XCTAssertEqual(obj1.name, "Background")
        XCTAssertEqual(obj1.lookList.count, 1)
        XCTAssertEqual(obj1.scriptList.count, 0)
        XCTAssertEqual(obj1.soundList.count, 0)

        let look1 = obj1.lookList[0] as! Look
        XCTAssertEqual(look1.name, "automatic_screenshot")
        XCTAssertEqual(look1.fileName, "5235c2eecb956adf8c3ff3e3e9f295e9_automatic_screenshot.png")

        let scene2 = project.scenes[1] as! Scene
        XCTAssertEqual(scene2.name, "Scene 2")
        XCTAssertEqual(scene2.objects().count, 1)

        let obj2 = scene2.objects()[0]
        XCTAssertEqual(obj2.name, "Background")
        XCTAssertEqual(obj2.lookList.count, 1)
        XCTAssertEqual(obj2.scriptList.count, 0)
        XCTAssertEqual(obj2.soundList.count, 0)

        let look2 = obj2.lookList[0] as! Look
        XCTAssertEqual(look2.name, "North Pole")
        XCTAssertEqual(look2.fileName, "8ada7bc98ee101e3877ceb3bc9bcc254_North Pole.png")
    }
}
