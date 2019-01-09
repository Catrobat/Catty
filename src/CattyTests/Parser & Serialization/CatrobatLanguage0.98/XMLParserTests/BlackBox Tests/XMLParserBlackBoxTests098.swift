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

final class XMLParserBlackBoxTests098: XMLAbstractTest {

    func testAirFight() {
        self.compareProgram(firstProgramName: "Air_fight_0.5_095", withProgram: "Air_fight_0.5_098")
    }

    func testAirplaneWithShadow() {
        self.compareProgram(firstProgramName: "Airplane_with_shadow_095", withProgram: "Airplane_with_shadow_098")
    }

    func testCompass() {
        self.compareProgram(firstProgramName: "Compass_0.1_095", withProgram: "Compass_0.1_098")
    }

    func testDemonstration() {
        self.compareProgram(firstProgramName: "Demonstration_095", withProgram: "Demonstration_098")
    }

    func testDrinkMoreWater() {
        self.compareProgram(firstProgramName: "Drink_more_water_095", withProgram: "Drink_more_water_098")
    }

    func testFlapPacMan() {
        self.compareProgram(firstProgramName: "Flap_Pac_Man_095", withProgram: "Flap_Pac_Man_098")
    }

    func testFlappy30() {
        self.compareProgram(firstProgramName: "Flappy_v3.0_095", withProgram: "Flappy_v3.0_098")
    }

    func testGalaxyWar() {
        self.compareProgram(firstProgramName: "Galaxy_War_095", withProgram: "Galaxy_War_098")
    }

    func testGossipGirl() {
        self.compareProgram(firstProgramName: "Gossip_Girl_095", withProgram: "Gossip_Girl_098")
    }

    func testMemory() {
        self.compareProgram(firstProgramName: "Memory_095", withProgram: "Memory_098")
    }

    func testMinecraftWorkInProgress() {
        self.compareProgram(firstProgramName: "Minecraft_Work_In_Progress_095", withProgram: "Minecraft_Work_In_Progress_098")
    }

    func testMinions() {
        self.compareProgram(firstProgramName: "Minions__095", withProgram: "Minions__098")
    }

    func testNyancat10() {
        self.compareProgram(firstProgramName: "Nyancat_1.0_093", withProgram: "Nyancat_1.0_098")
    }

    func testPiano() {
        self.compareProgram(firstProgramName: "Piano_093", withProgram: "Piano_098")
    }

    func testPongStarter() {
        self.compareProgram(firstProgramName: "Pong_Starter_095", withProgram: "Pong_Starter_098")
    }

    func testPythagoreanTheorem() {
        self.compareProgram(firstProgramName: "Pythagorean_Theorem_095", withProgram: "Pythagorean_Theorem_098")
    }

    func testRockPaperScissors() {
        self.compareProgram(firstProgramName: "Rock_paper_scissors_095", withProgram: "Rock_paper_scissors_098")
    }

    func testSkydivingSteve() {
        self.compareProgram(firstProgramName: "Skydiving_Steve_095", withProgram: "Skydiving_Steve_098")
    }

    func testTicTacToeMaster() {
        self.compareProgram(firstProgramName: "Tic_Tac_Toe_Master_095", withProgram: "Tic_Tac_Toe_Master_098")
    }

    func testWordBalloonDemo() {
        self.compareProgram(firstProgramName: "Word_balloon_demo_095", withProgram: "Word_balloon_demo_098")
    }

    func testXRayPhone() {
        self.compareProgram(firstProgramName: "X_Ray_phone_095", withProgram: "X_Ray_phone_098")
    }

    func testSolarSystem() {
        self.compareProgram(firstProgramName: "Solar_System_v1.0_092", withProgram: "Solar_System_v1.0_098")
    }
}
