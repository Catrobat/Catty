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

final class XMLSerializerBlackBoxTests: XMLAbstractTestSwift {
    func testAirFight() {
        self.testParseXMLAndSerializeProgramAndCompareXML(xmlFile: "Air_fight_0.5_0991")
    }
    
    func testInvalidAirFight() {
        let program095 = self.getProgramForXML(xmlFile: "Air_fight_0.5_095")
        let background = program095!.objectList.object(at: 0) as! SpriteObject
        background.name = "Invalid"
        let equal = self.isProgram(firstProgram: program095!, equalToXML: "Air_fight_0.5_0991")
        XCTAssertFalse(equal, "Serialized program and XML are not equal")
    }
    
    func testAirplaneWithShadow06() {
        self.testParseXMLAndSerializeProgramAndCompareXML(xmlFile: "Airplane_with_shadow_0991")
    }
    
    func testCompass01() {
        self.testParseXMLAndSerializeProgramAndCompareXML(xmlFile: "Compass_0.1_0991")
    }
    
    func testDemonstration() {
        self.testParseXMLAndSerializeProgramAndCompareXML(xmlFile: "Demonstration_0991")
    }
    
    func testDrinkMoreWater() {
        self.testParseXMLAndSerializeProgramAndCompareXML(xmlFile: "Drink_more_water_0991")
    }
    
    func testEncapsulated() {
        self.testParseXMLAndSerializeProgramAndCompareXML(xmlFile: "Encapsulated_0991")
    }
    
    func testFlapPacMan() {
        self.testParseXMLAndSerializeProgramAndCompareXML(xmlFile: "Flap_Pac_Man_0991")
    }
    
    func testFlappy30() {
        self.testParseXMLAndSerializeProgramAndCompareXML(xmlFile: "Flappy_v3.0_0991")
    }
    
    func testGossipGirl() {
        self.testParseXMLAndSerializeProgramAndCompareXML(xmlFile: "Gossip_Girl_0991")
    }
    
    func testMemory() {
        self.testParseXMLAndSerializeProgramAndCompareXML(xmlFile: "Memory_0991")
    }
    
    func testMinecraftWorkInProgress() {
        self.testParseXMLAndSerializeProgramAndCompareXML(xmlFile: "Minecraft_Work_In_Progress_0991")
    }
    
    func testMinions() {
        self.testParseXMLAndSerializeProgramAndCompareXML(xmlFile: "Minions__0991")
    }
    
    func testPongStarter() {
        self.testParseXMLAndSerializeProgramAndCompareXML(xmlFile: "Pong_Starter_0991")
    }
    
    func testRockPaperScissors() {
        self.testParseXMLAndSerializeProgramAndCompareXML(xmlFile: "Rock_paper_scissors_0991")
    }
    
    func testTicTacToeMaster() {
        self.testParseXMLAndSerializeProgramAndCompareXML(xmlFile: "Tic_Tac_Toe_Master_0991")
    }
    
    func testWordBalloonDemo() {
        self.testParseXMLAndSerializeProgramAndCompareXML(xmlFile: "Word_balloon_demo_0991")
    }
    
    func testXRayPhone() {
        self.testParseXMLAndSerializeProgramAndCompareXML(xmlFile: "X_Ray_phone_0991")
    }
    
    func testGalaxyWar() {
        self.testParseXMLAndSerializeProgramAndCompareXML(xmlFile: "Galaxy_War_0991")
    }
    
    func testSkydivingSteve() {
        self.testParseXMLAndSerializeProgramAndCompareXML(xmlFile: "Skydiving_Steve_0991")
    }
    
    func testPythagoreanTheorem() {
        self.testParseXMLAndSerializeProgramAndCompareXML(xmlFile: "Pythagorean_Theorem_0991")
    }
    
    func testValidProgramAllBricks() {
        self.testParseXMLAndSerializeProgramAndCompareXML(xmlFile: "ValidProgramAllBricks0991")
    }
    
    func testLogicBricks() {
        self.testParseXMLAndSerializeProgramAndCompareXML(xmlFile: "LogicBricks_0991")
    }
}
