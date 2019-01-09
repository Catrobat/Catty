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

final class XMLParserBlackBoxTests096: XMLAbstractTest {

    func testAirFight() {
        self.compareProgram(firstProgramName: "Air_fight_0.5_095", withProgram: "Air_fight_0.5_096")
    }

    func testAirplaneWithShadow() {
        self.compareProgram(firstProgramName: "Airplane_with_shadow_095", withProgram: "Airplane_with_shadow_096")
    }

    func testCompass() {
        self.compareProgram(firstProgramName: "Compass_0.1_095", withProgram: "Compass_0.1_096")
    }

    func testDemonstration() {
        self.compareProgram(firstProgramName: "Demonstration_095", withProgram: "Demonstration_096")
    }

    func testDrinkMoreWater() {
        self.compareProgram(firstProgramName: "Drink_more_water_095", withProgram: "Drink_more_water_096")
    }

    func testFlapPacMan() {
        self.compareProgram(firstProgramName: "Flap_Pac_Man_095", withProgram: "Flap_Pac_Man_096")
    }

    func testFlappy() {
        self.compareProgram(firstProgramName: "Flappy_v3.0_095", withProgram: "Flappy_v3.0_096")
    }

    func testGalaxyWar() {
        self.compareProgram(firstProgramName: "Galaxy_War_095", withProgram: "Galaxy_War_096")
    }

    func testGossipGirl() {
        self.compareProgram(firstProgramName: "Gossip_Girl_095", withProgram: "Gossip_Girl_096")
    }

    func testMemory() {
        self.compareProgram(firstProgramName: "Memory_095", withProgram: "Memory_096")
    }

    func testMinecraftWorkInProgress() {
        self.compareProgram(firstProgramName: "Minecraft_Work_In_Progress_095", withProgram: "Minecraft_Work_In_Progress_096")
    }

    func testMinions() {
        self.compareProgram(firstProgramName: "Minions__095", withProgram: "Minions__096")
    }

    func testNyancat() {
        self.compareProgram(firstProgramName: "Nyancat_1.0_093", withProgram: "Nyancat_1.0_096")
    }

    func testPiano() {
        self.compareProgram(firstProgramName: "Piano_093", withProgram: "Piano_096")
    }

    func testPongStarter() {
        self.compareProgram(firstProgramName: "Pong_Starter_095", withProgram: "Pong_Starter_096")
    }

    func testPythagoreanTheorem() {
        self.compareProgram(firstProgramName: "Pythagorean_Theorem_095", withProgram: "Pythagorean_Theorem_096")
    }

    func testRockPaperScissors() {
        self.compareProgram(firstProgramName: "Rock_paper_scissors_095", withProgram: "Rock_paper_scissors_096")
    }

    func testSkydivingSteve() {
        self.compareProgram(firstProgramName: "Skydiving_Steve_095", withProgram: "Skydiving_Steve_096")
    }

    func testTicTacToeMaster() {
        self.compareProgram(firstProgramName: "Tic_Tac_Toe_Master_095", withProgram: "Tic_Tac_Toe_Master_096")
    }

    func testWordBalloonDemo() {
        self.compareProgram(firstProgramName: "Word_balloon_demo_095", withProgram: "Word_balloon_demo_096")
    }

    func testXRayPhone() {
        self.compareProgram(firstProgramName: "X_Ray_phone_095", withProgram: "X_Ray_phone_096")
    }

}
