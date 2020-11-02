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

import XCTest

@testable import Pocket_Code

final class SoundTest: XCTestCase {

    func testPathForScene() {
        let project = Project()
        let scene = Scene(name: "testScene")
        project.scene = scene
        scene.project = project

        let sound = Sound(name: "testSound", fileName: "testSoundFile")

        let expectedPath = project.projectPath() + "testScene/sounds/testSoundFile"
        XCTAssertEqual(expectedPath, sound.path(for: scene))
    }

    func testIsEqualToSound() {
          let sound = Sound(name: "testSound", fileName: "testSoundFile")
          let equalSound = Sound(name: "testSound", fileName: "testSoundFile")
          let otherSound = Sound(name: "otherSound", fileName: "testSoundFile")

           XCTAssertTrue(sound.isEqual(to: equalSound))
           XCTAssertFalse(sound === equalSound)
           XCTAssertFalse(sound.isEqual(to: otherSound))
       }

       func testMutableCopyWithContext() {
           let sound = Sound(name: "testSound", fileName: "testSoundFile")
           let context = CBMutableCopyContext()

           let soundCopy = sound.mutableCopy(with: context) as! Sound

           XCTAssertEqual(sound.name, soundCopy.name)
           XCTAssertFalse(sound === soundCopy)
           XCTAssertEqual(sound.fileName, soundCopy.fileName)
       }

       func testInitWithName() {
           let bundle = Bundle(for: type(of: self))
           let param1 = "testSoundFile"
           let param2 = "testSound"
           let sound = Sound(name: param1, fileName: param2)

           XCTAssertNotNil(sound)
           XCTAssertEqual(sound.name, param1)
           XCTAssertEqual(sound.fileName, param2)
       }

}
