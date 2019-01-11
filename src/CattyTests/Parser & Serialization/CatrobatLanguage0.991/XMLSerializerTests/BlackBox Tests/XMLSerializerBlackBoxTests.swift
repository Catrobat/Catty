/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

final class XMLSerializerBlackBoxTests: XMLAbstractTest {
    func testAirFight() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Air_fight_0.5_0991")
    }

    func testInvalidAirFight() {
        let project095 = self.getProjectForXML(xmlFile: "Air_fight_0.5_095")
        let background = project095.objectList.object(at: 0) as! SpriteObject
        background.name = "Invalid"
        let equal = self.isProject(firstProject: project095, equalToXML: "Air_fight_0.5_0991")
        XCTAssertFalse(equal, "Serialized project and XML are not equal")
    }

    func testAirplaneWithShadow06() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Airplane_with_shadow_0991")
    }

    func testCompass01() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Compass_0.1_0991")
    }

    func testDemonstration() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Demonstration_0991")
    }

    func testDrinkMoreWater() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Drink_more_water_0991")
    }

    func testEncapsulated() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Encapsulated_0991")
    }

    func testFlapPacMan() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Flap_Pac_Man_0991")
    }

    func testFlappy30() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Flappy_v3.0_0991")
    }

    func testGossipGirl() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Gossip_Girl_0991")
    }

    func testMemory() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Memory_0991")
    }

    func testMinecraftWorkInProgress() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Minecraft_Work_In_Progress_0991")
    }

    func testMinions() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Minions__0991")
    }

    func testPongStarter() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Pong_Starter_0991")
    }

    func testRockPaperScissors() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Rock_paper_scissors_0991")
    }

    func testTicTacToeMaster() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Tic_Tac_Toe_Master_0991")
    }

    func testWordBalloonDemo() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Word_balloon_demo_0991")
    }

    func testXRayPhone() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "X_Ray_phone_0991")
    }

    func testGalaxyWar() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Galaxy_War_0991")
    }

    func testSkydivingSteve() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Skydiving_Steve_0991")
    }

    func testPythagoreanTheorem() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Pythagorean_Theorem_0991")
    }

    func testValidProjectAllBricks() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "ValidProjectAllBricks0991")
    }

    func testLogicBricks() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "LogicBricks_0991")
    }
}
