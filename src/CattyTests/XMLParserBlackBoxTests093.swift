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

final class XMLParserBlackBoxTests093: XMLAbstractTest {
    func testAirFight0() {
        self.compareProject(firstProjectName: "Air_fight_0.5_091", withProject: "Air_fight_0.5_093")
    }

    func testAirplaneWithShadow() {
        self.compareProject(firstProjectName: "Airplane_with_shadow_091", withProject: "Airplane_with_shadow_093")
    }

    func testCompass01() {
    self.compareProject(firstProjectName: "Compass_0.1_091", withProject: "Compass_0.1_093")
    }

    func testDemonstration() {
        self.compareProject(firstProjectName: "Demonstration_09", withProject: "Demonstration_093")
    }

    func testDrinkMoreWater() {
        self.compareProject(firstProjectName: "Drink_more_water_09", withProject: "Drink_more_water_093")
    }

    func testFlapPacMan() {
        self.compareProject(firstProjectName: "Flap_Pac_Man_091", withProject: "Flap_Pac_Man_093")
    }

    func testFlappy30() {
        self.compareProject(firstProjectName: "Flappy_v3.0_092", withProject: "Flappy_v3.0_093")
    }

    func testGalaxyWar() {
        self.compareProject(firstProjectName: "Galaxy_War_092", withProject: "Galaxy_War_093")
    }

    func testGossipGirl() {
        self.compareProject(firstProjectName: "Gossip_Girl_091", withProject: "Gossip_Girl_093")
    }

    func testMemory() {
        self.compareProject(firstProjectName: "Memory_09", withProject: "Memory_093")
    }

    func testMinecraftWorkInProgress() {
        self.compareProject(firstProjectName: "Minecraft_Work_In_Progress_092", withProject: "Minecraft_Work_In_Progress_093")
    }

    func testMinions() {
        self.compareProject(firstProjectName: "Minions__091", withProject: "Minions__093")
    }

    func testNyancat10() {
        self.compareProject(firstProjectName: "Nyancat_1.0_091", withProject: "Nyancat_1.0_093")
    }

    func testPiano() {
        self.compareProject(firstProjectName: "Piano_09", withProject: "Piano_093")
    }

    func testPongStarter() {
        self.compareProject(firstProjectName: "Pong_Starter_09", withProject: "Pong_Starter_093")
    }

    func testPythagoreanTheorem() {
        self.compareProject(firstProjectName: "Pythagorean_Theorem_092", withProject: "Pythagorean_Theorem_093")
    }

    func testRockPaperScissors() {
        self.compareProject(firstProjectName: "Rock_paper_scissors_091", withProject: "Rock_paper_scissors_093")
    }

    func testSkyPascal() {
        self.compareProject(firstProjectName: "SKYPASCAL_08", withProject: "SKYPASCAL_093")
    }

    func testSkydivingSteve() {
        self.compareProject(firstProjectName: "Skydiving_Steve_092", withProject: "Skydiving_Steve_093")
    }

    func testTicTacToeMaster() {
        self.compareProject(firstProjectName: "Tic_Tac_Toe_Master_091", withProject: "Tic_Tac_Toe_Master_093")
    }

    func testWordBalloonDemo() {
        self.compareProject(firstProjectName: "Word_balloon_demo_09", withProject: "Word_balloon_demo_093")
    }

    func testXRayPhone() {
        self.compareProject(firstProjectName: "X_Ray_phone_091", withProject: "X_Ray_phone_093")
    }

}
