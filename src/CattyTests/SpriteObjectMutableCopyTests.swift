/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

final class SpriteObjectMutableCopyTests: XMLAbstractTestSwift {
    
    func testIfCopiedSpriteObjectsAreEqualToOriginalForValidProgramAllBricks() {
        self.compareSpriteObjectsWithIsEqualMethodForProgramWithXML(xml: "ValidProgramAllBricks093")
    }
    
    func testIfCopiedSpriteObjectsAreEqualToOriginalForAirFight() {
        self.compareSpriteObjectsWithIsEqualMethodForProgramWithXML(xml: "Air_fight_0.5_093")
    }
    
    func testIfCopiedSpriteObjectsAreEqualToOriginalForAirplaneWithShadow() {
        self.compareSpriteObjectsWithIsEqualMethodForProgramWithXML(xml: "Airplane_with_shadow_093")
    }
    
    func testIfCopiedSpriteObjectsAreEqualToOriginalForCompass() {
        self.compareSpriteObjectsWithIsEqualMethodForProgramWithXML(xml: "Compass_0.1_093")
    }
    
    func testIfCopiedSpriteObjectsAreEqualToOriginalForDemonstration() {
        self.compareSpriteObjectsWithIsEqualMethodForProgramWithXML(xml: "Demonstration_093")
    }
    
    func testIfCopiedSpriteObjectsAreEqualToOriginalForDrinkMoreWater() {
        self.compareSpriteObjectsWithIsEqualMethodForProgramWithXML(xml: "Drink_more_water_093")
    }
    
    func testIfCopiedSpriteObjectsAreEqualToOriginalForFlappy() {
        self.compareSpriteObjectsWithIsEqualMethodForProgramWithXML(xml: "Flappy_v3.0_093")
    }
    
    func testIfCopiedSpriteObjectsAreEqualToOriginalForGalaxyWar() {
        self.compareSpriteObjectsWithIsEqualMethodForProgramWithXML(xml: "Galaxy_War_093")
    }
    
    func testIfCopiedSpriteObjectsAreEqualToOriginalForGossipGirl() {
        self.compareSpriteObjectsWithIsEqualMethodForProgramWithXML(xml: "Gossip_Girl_093")
    }
    
    func testIfCopiedSpriteObjectsAreEqualToOriginalForMemory() {
        self.compareSpriteObjectsWithIsEqualMethodForProgramWithXML(xml: "Memory_093")
    }
    
    func testIfCopiedSpriteObjectsAreEqualToOriginalForMinecraftWorkInProgress() {
        self.compareSpriteObjectsWithIsEqualMethodForProgramWithXML(xml: "Minecraft_Work_In_Progress_093")
    }
    
    func testIfCopiedSpriteObjectsAreEqualToOriginalForMinions() {
        self.compareSpriteObjectsWithIsEqualMethodForProgramWithXML(xml: "Minions__093")
    }
    
    func testIfCopiedSpriteObjectsAreEqualToOriginalForNyancat() {
        self.compareSpriteObjectsWithIsEqualMethodForProgramWithXML(xml: "Nyancat_1.0_093")
    }
    
    func testIfCopiedSpriteObjectsAreEqualToOriginalForPiano() {
        self.compareSpriteObjectsWithIsEqualMethodForProgramWithXML(xml: "Piano_093")
    }
    
    func testIfCopiedSpriteObjectsAreEqualToOriginalForPongStarter() {
        self.compareSpriteObjectsWithIsEqualMethodForProgramWithXML(xml: "Pong_Starter_093")
    }
    
    func testIfCopiedSpriteObjectsAreEqualToOriginalForPythagoreanTheorem() {
        self.compareSpriteObjectsWithIsEqualMethodForProgramWithXML(xml: "Pythagorean_Theorem_093")
    }
    
    func testIfCopiedSpriteObjectsAreEqualToOriginalForRockPaperScissors() {
        self.compareSpriteObjectsWithIsEqualMethodForProgramWithXML(xml: "Rock_paper_scissors_093")
    }
    
    func testIfCopiedSpriteObjectsAreEqualToOriginalForSkyPascal() {
        self.compareSpriteObjectsWithIsEqualMethodForProgramWithXML(xml: "SKYPASCAL_093")
    }
    
    func testIfCopiedSpriteObjectsAreEqualToOriginalForSkydivingSteve() {
        self.compareSpriteObjectsWithIsEqualMethodForProgramWithXML(xml: "Skydiving_Steve_093")
    }
    
    func testIfCopiedSpriteObjectsAreEqualToOriginalForTicTacToeMaster() {
        self.compareSpriteObjectsWithIsEqualMethodForProgramWithXML(xml: "Tic_Tac_Toe_Master_093")
    }
    
    func testIfCopiedSpriteObjectsAreEqualToOriginalForWordBalloonDemo() {
        self.compareSpriteObjectsWithIsEqualMethodForProgramWithXML(xml: "Word_balloon_demo_093")
    }
    
    func testIfCopiedSpriteObjectsAreEqualToOriginalForXRayPhone() {
        self.compareSpriteObjectsWithIsEqualMethodForProgramWithXML(xml: "X_Ray_phone_093")
    }
    
    func testIfCopiedSpriteObjectsAreEqualToOriginalForValidFormulaList() {
        self.compareSpriteObjectsWithIsEqualMethodForProgramWithXML(xml: "ValidFormulaList")
    }
    
    func testIfCopiedSpriteObjectsAreEqualToOriginalForValidProgram() {
        self.compareSpriteObjectsWithIsEqualMethodForProgramWithXML(xml: "ValidProgram")
    }
    
    func testIfCopiedSpriteObjectsAreEqualToOriginalForFlapPacMan() {
        self.compareSpriteObjectsWithIsEqualMethodForProgramWithXML(xml: "Flap_Pac_Man_093")
    }
    
    func compareSpriteObjectsWithIsEqualMethodForProgramWithXML(xml: String) {
        let program = self.getProgramForXML(xmlFile: xml)
        XCTAssertTrue(program!.objectList.count > 0, "Invalid objectList")
    
        for object in program!.objectList {
            let spriteObject = object as! SpriteObject
            let context = CBMutableCopyContext()
            let copiedSpriteObject = spriteObject.mutableCopy(with: context) as! SpriteObject
            XCTAssertTrue(spriteObject.isEqual(to: copiedSpriteObject), "SpriteObjects are not equal")
        }
    }
    
}
