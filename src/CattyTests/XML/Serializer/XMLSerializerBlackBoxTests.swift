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

final class XMLSerializerBlackBoxTests: XMLAbstractTest {
    func testAirFight() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Air_fight_0.5_0996")
    }

    func testInvalidAirFight() {
        let project095 = self.getProjectForXML(xmlFile: "Air_fight_0.5_096")
        let background = project095.scene.object(at: 0)!
        background.name = "Invalid"
        let equal = self.isProject(firstProject: project095, equalToXML: "Air_fight_0.5_0996")
        XCTAssertFalse(equal, "Serialized project and XML are not equal")
    }

    func testAirplaneWithShadow06() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Airplane_with_shadow_0996")
    }

    func testDemonstration() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Demonstration_0996")
    }

    func testEncapsulated() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Encapsulated_0996")
    }

    func testFlapPacMan() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Flap_Pac_Man_0996")
    }

    func testFlappy30() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Flappy_v3.0_0996")
    }

    func testMemory() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Memory_0996")
    }

    func testPongStarter() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Pong_Starter_0996")
    }

    func testTicTacToeMaster() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Tic_Tac_Toe_Master_0996")
    }

    func testGalaxyWar() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Galaxy_War_0996")
    }

    func testPythagoreanTheorem() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Pythagorean_Theorem_0996")
    }

    func testValidProjectAllBricks() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "ValidProjectAllBricks0996")
    }

    func testLogicBricks() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "LogicBricks_0996")
    }

    func testDisabledBricks() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "DisabledBricks_0996")
    }

    func testUserData() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "UserData_0996")
    }

    func testGoToBrickWithNotYetSerializedSpriteObject() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "GoToBrick_0996")
    }

    func testFunctions() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "Functions_0996")
    }

    func testCollisionFormulaSerialization() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "collisionTest0996")
    }

    func testEscapingChars() {
        self.testParseXMLAndSerializeProjectAndCompareXML(xmlFile: "EscapingChars_0996")
    }
}
