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

final class XMLParserBlackBoxTests095: XMLAbstractTest {

    func testAirFight() {
        self.compareProject(firstProjectName: "Air_fight_0.5_093", withProject: "Air_fight_0.5_095")
    }

    func testAirplaneWithShadow() {
        self.compareProject(firstProjectName: "Airplane_with_shadow_093", withProject: "Airplane_with_shadow_095")
    }

    func testCompass() {
        self.compareProject(firstProjectName: "Compass_0.1_093", withProject: "Compass_0.1_095")
    }

    func testDemonstration() {
        self.compareProject(firstProjectName: "Demonstration_093", withProject: "Demonstration_095")
    }

    func testDrinkMoreWater() {
        self.compareProject(firstProjectName: "Drink_more_water_093", withProject: "Drink_more_water_095")
    }

    func testFlapPacMan() {
        self.compareProject(firstProjectName: "Flap_Pac_Man_093", withProject: "Flap_Pac_Man_095")
    }

    func testFlappy() {
        self.compareProject(firstProjectName: "Flappy_v3.0_093", withProject: "Flappy_v3.0_095")
    }

    func testGalaxyWar() {
        self.compareProject(firstProjectName: "Galaxy_War_093", withProject: "Galaxy_War_095")
    }

    func testGossipGirl() {
        self.compareProject(firstProjectName: "Gossip_Girl_091", withProject: "Gossip_Girl_095")
    }

    func testMemory() {
        self.compareProject(firstProjectName: "Memory_093", withProject: "Memory_095")
    }

    func testMinecraftWorkInProgress() {
        self.compareProject(firstProjectName: "Minecraft_Work_In_Progress_093", withProject: "Minecraft_Work_In_Progress_095")
    }

    func testMinions() {
        self.compareProject(firstProjectName: "Minions__093", withProject: "Minions__095")
    }

    func testPongStarter() {
        self.compareProject(firstProjectName: "Pong_Starter_093", withProject: "Pong_Starter_095")
    }

    func testPythagoreanTheorem() {
        self.compareProject(firstProjectName: "Pythagorean_Theorem_093", withProject: "Pythagorean_Theorem_095")
    }

    func testRockPaperScissors() {
        self.compareProject(firstProjectName: "Rock_paper_scissors_093", withProject: "Rock_paper_scissors_095")
    }

    func testSkydivingSteve() {
        self.compareProject(firstProjectName: "Skydiving_Steve_093", withProject: "Skydiving_Steve_095")
    }

    func testTicTacToeMaster() {
        self.compareProject(firstProjectName: "Tic_Tac_Toe_Master_093", withProject: "Tic_Tac_Toe_Master_095")
    }

    func testWordBalloonDemo() {
        self.compareProject(firstProjectName: "Word_balloon_demo_093", withProject: "Word_balloon_demo_095")
    }

    func testXRayPhone() {
        self.compareProject(firstProjectName: "X_Ray_phone_093", withProject: "X_Ray_phone_095")
    }

}
