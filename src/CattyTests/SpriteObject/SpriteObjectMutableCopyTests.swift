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

final class SpriteObjectMutableCopyTests: XMLAbstractTest {

    func testIfCopiedSpriteObjectsAreEqualToOriginalForValidProjectAllBricks() {
        self.compareSpriteObjectsWithIsEqualMethodForProjectWithXML(xml: "ValidProjectAllBricks093")
    }

    func testIfCopiedSpriteObjectsAreEqualToOriginalForAirFight() {
        self.compareSpriteObjectsWithIsEqualMethodForProjectWithXML(xml: "Air_fight_0.5_093")
    }

    func testIfCopiedSpriteObjectsAreEqualToOriginalForAirplaneWithShadow() {
        self.compareSpriteObjectsWithIsEqualMethodForProjectWithXML(xml: "Airplane_with_shadow_093")
    }

    func testIfCopiedSpriteObjectsAreEqualToOriginalForDemonstration() {
        self.compareSpriteObjectsWithIsEqualMethodForProjectWithXML(xml: "Demonstration_093")
    }

    func testIfCopiedSpriteObjectsAreEqualToOriginalForFlappy() {
        self.compareSpriteObjectsWithIsEqualMethodForProjectWithXML(xml: "Flappy_v3.0_093")
    }

    func testIfCopiedSpriteObjectsAreEqualToOriginalForGalaxyWar() {
        self.compareSpriteObjectsWithIsEqualMethodForProjectWithXML(xml: "Galaxy_War_093")
    }

    func testIfCopiedSpriteObjectsAreEqualToOriginalForMemory() {
        self.compareSpriteObjectsWithIsEqualMethodForProjectWithXML(xml: "Memory_093")
    }

    func testIfCopiedSpriteObjectsAreEqualToOriginalForPiano() {
        self.compareSpriteObjectsWithIsEqualMethodForProjectWithXML(xml: "Piano_093")
    }

    func testIfCopiedSpriteObjectsAreEqualToOriginalForPongStarter() {
        self.compareSpriteObjectsWithIsEqualMethodForProjectWithXML(xml: "Pong_Starter_093")
    }

    func testIfCopiedSpriteObjectsAreEqualToOriginalForPythagoreanTheorem() {
        self.compareSpriteObjectsWithIsEqualMethodForProjectWithXML(xml: "Pythagorean_Theorem_093")
    }

    func testIfCopiedSpriteObjectsAreEqualToOriginalForSkyPascal() {
        self.compareSpriteObjectsWithIsEqualMethodForProjectWithXML(xml: "SKYPASCAL_093")
    }

    func testIfCopiedSpriteObjectsAreEqualToOriginalForTicTacToeMaster() {
        self.compareSpriteObjectsWithIsEqualMethodForProjectWithXML(xml: "Tic_Tac_Toe_Master_093")
    }

    func testIfCopiedSpriteObjectsAreEqualToOriginalForValidFormulaList() {
        self.compareSpriteObjectsWithIsEqualMethodForProjectWithXML(xml: "ValidFormulaList")
    }

    func testIfCopiedSpriteObjectsAreEqualToOriginalForValidProject() {
        self.compareSpriteObjectsWithIsEqualMethodForProjectWithXML(xml: "ValidProject")
    }

    func testIfCopiedSpriteObjectsAreEqualToOriginalForFlapPacMan() {
        self.compareSpriteObjectsWithIsEqualMethodForProjectWithXML(xml: "Flap_Pac_Man_093")
    }

    func compareSpriteObjectsWithIsEqualMethodForProjectWithXML(xml: String) {
        let project = self.getProjectForXML(xmlFile: xml)
        XCTAssertTrue(!(project.scenes[0] as! Scene).objects().isEmpty, "Invalid objectList")

        for spriteObject in (project.scenes[0] as! Scene).objects() {
            let context = CBMutableCopyContext()
            let copiedSpriteObject = spriteObject.mutableCopy(with: context) as! SpriteObject
            XCTAssertTrue(spriteObject.isEqual(to: copiedSpriteObject), "SpriteObjects are not equal")
        }
    }

    func testMutableCopyAndUpdateReferenceForLook() {
        let brick = SetLookBrick()
        let lookA = Look(name: "lookA", filePath: "look")
        let lookB = Look(name: "lookB", filePath: "look")

        brick.look = lookA

        let context = CBMutableCopyContext()
        context.updateReference(lookA, withReference: lookB)
        XCTAssertEqual(1, context.updatedReferences.count)

        let brickCopy = brick.mutableCopy(with: context) as! SetLookBrick

        XCTAssertEqual(brickCopy.look, lookB)
        XCTAssertNotEqual(brickCopy.look, lookA)
    }

    func testMutableCopyAndUpdateReferenceForBackground() {
        let brick = SetBackgroundBrick()
        let lookA = Look(name: "lookA", filePath: "look")
        let lookB = Look(name: "lookB", filePath: "look")

        brick.look = lookA

        let context = CBMutableCopyContext()
        context.updateReference(lookA, withReference: lookB)
        XCTAssertEqual(1, context.updatedReferences.count)

        let brickCopy = brick.mutableCopy(with: context) as! SetBackgroundBrick

        XCTAssertEqual(brickCopy.look, lookB)
        XCTAssertNotEqual(brickCopy.look, lookA)
    }

    func testMutableCopyAndUpdateReferenceForSound() {
        let brick = PlaySoundBrick()
        let soundA = Sound(name: "soundA", fileName: "soundA")
        let soundB = Sound(name: "soundB", fileName: "soundB")

        brick.sound = soundA

        let context = CBMutableCopyContext()
        context.updateReference(soundA, withReference: soundB)
        XCTAssertEqual(1, context.updatedReferences.count)

        let brickCopy = brick.mutableCopy(with: context) as! PlaySoundBrick

        XCTAssertEqual(brickCopy.sound, soundB)
        XCTAssertNotEqual(brickCopy.sound, soundA)
    }

    func testBrickCopyForLook() {
        let brick = SetLookBrick()
        let look = Look(name: "lookToCopy", filePath: "look")
        brick.look = look

        let context = CBMutableCopyContext()
        XCTAssertEqual(0, context.updatedReferences.count)

        let brickCopy = brick.mutableCopy(with: context) as! SetLookBrick

        XCTAssertEqual(brickCopy.look, look)
    }

    func testBrickCopyForBackground() {
        let brick = SetBackgroundBrick()
        let look = Look(name: "backgroundToCopy", filePath: "background")
        brick.look = look

        let context = CBMutableCopyContext()
        XCTAssertEqual(0, context.updatedReferences.count)

        let brickCopy = brick.mutableCopy(with: context) as! SetBackgroundBrick

        XCTAssertEqual(brickCopy.look, look)
    }

    func testBrickCopyForSound() {
        let brick = PlaySoundBrick()
        let sound = Sound(name: "soundToCopy", fileName: "sound")
        brick.sound = sound

        let context = CBMutableCopyContext()
        XCTAssertEqual(0, context.updatedReferences.count)

        let brickCopy = brick.mutableCopy(with: context) as! PlaySoundBrick

        XCTAssertEqual(brickCopy.sound, sound)
    }

    func testUserDataContainerCopyContainingList() {
        let list = UserList(name: "testList")

        let container = UserDataContainer()
        container.add(list)

        let object = SpriteObject()
        object.name = "testObject"
        object.userData = container

        let context = CBMutableCopyContext()
        let copyObject = object.mutableCopy(with: context) as! SpriteObject

        XCTAssertTrue(copyObject.userData.isEqual(object.userData))
        XCTAssertFalse(copyObject.userData === object.userData)
        XCTAssertEqual(1, copyObject.userData.lists().count)
        XCTAssertEqual("testList", (copyObject.userData.lists()[0]).name)
    }

    func testUserDataContainerCopyContainingVariable() {
        let variable = UserVariable(name: "testVariable")

        let container = UserDataContainer()
        container.add(variable)

        let object = SpriteObject()
        object.name = "testObject"
        object.userData = container

        let context = CBMutableCopyContext()
        let copyObject = object.mutableCopy(with: context) as! SpriteObject

        XCTAssertTrue(copyObject.userData.isEqual(object.userData))
        XCTAssertFalse(copyObject.userData === object.userData)
        XCTAssertEqual(1, copyObject.userData.variables().count)
        XCTAssertEqual("testVariable", (copyObject.userData.variables()[0]).name)
    }
}
