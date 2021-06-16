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

final class XMLParserBlackBoxTests098: XMLAbstractTest {

    func testAirFight() {
        self.compareProject(firstProjectName: "Air_fight_0.5_095", withProject: "Air_fight_0.5_098")
    }

    func testAirplaneWithShadow() {
        self.compareProject(firstProjectName: "Airplane_with_shadow_095", withProject: "Airplane_with_shadow_098")
    }

    func testCompass() {
        self.compareProject(firstProjectName: "Compass_0.1_095", withProject: "Compass_0.1_098")
    }

    func testDemonstration() {
        self.compareProject(firstProjectName: "Demonstration_095", withProject: "Demonstration_098")
    }

    func testDrinkMoreWater() {
        self.compareProject(firstProjectName: "Drink_more_water_095", withProject: "Drink_more_water_098")
    }

    func testFlapPacMan() {
        self.compareProject(firstProjectName: "Flap_Pac_Man_095", withProject: "Flap_Pac_Man_098")
    }

    func testFlappy30() {
        self.compareProject(firstProjectName: "Flappy_v3.0_095", withProject: "Flappy_v3.0_098")
    }

    func testGalaxyWar() {
        self.compareProject(firstProjectName: "Galaxy_War_095", withProject: "Galaxy_War_098")
    }

    func testGossipGirl() {
        self.compareProject(firstProjectName: "Gossip_Girl_095", withProject: "Gossip_Girl_098")
    }

    func testMemory() {
        self.compareProject(firstProjectName: "Memory_095", withProject: "Memory_098")
    }

    func testMinecraftWorkInProgress() {
        self.compareProject(firstProjectName: "Minecraft_Work_In_Progress_095", withProject: "Minecraft_Work_In_Progress_098")
    }

    func testMinions() {
        self.compareProject(firstProjectName: "Minions__095", withProject: "Minions__098")
    }

    func testNyancat10() {
        self.compareProject(firstProjectName: "Nyancat_1.0_093", withProject: "Nyancat_1.0_098")
    }

    func testPiano() {
        self.compareProject(firstProjectName: "Piano_093", withProject: "Piano_098")
    }

    func testPongStarter() {
        self.compareProject(firstProjectName: "Pong_Starter_095", withProject: "Pong_Starter_098")
    }

    func testPythagoreanTheorem() {
        self.compareProject(firstProjectName: "Pythagorean_Theorem_095", withProject: "Pythagorean_Theorem_098")
    }

    func testRockPaperScissors() {
        self.compareProject(firstProjectName: "Rock_paper_scissors_095", withProject: "Rock_paper_scissors_098")
    }

    func testSkydivingSteve() {
        self.compareProject(firstProjectName: "Skydiving_Steve_095", withProject: "Skydiving_Steve_098")
    }

    func testTicTacToeMaster() {
        self.compareProject(firstProjectName: "Tic_Tac_Toe_Master_095", withProject: "Tic_Tac_Toe_Master_098")
    }

    func testWordBalloonDemo() {
        self.compareProject(firstProjectName: "Word_balloon_demo_095", withProject: "Word_balloon_demo_098")
    }

    func testXRayPhone() {
        self.compareProject(firstProjectName: "X_Ray_phone_095", withProject: "X_Ray_phone_098")
    }

    func testSolarSystem() {
        self.compareProject(firstProjectName: "Solar_System_v1.0_092", withProject: "Solar_System_v1.0_098")
    }
}
