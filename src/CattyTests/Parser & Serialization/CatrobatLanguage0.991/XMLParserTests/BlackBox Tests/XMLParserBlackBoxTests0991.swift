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

final class XMLParserBlackBoxTests0991: XMLAbstractTest {

    func testAirFight() {
        self.compareProject(firstProjectName: "Air_fight_0.5_091", withProject: "Air_fight_0.5_0991")
        self.compareProject(firstProjectName: "Air_fight_0.5_093", withProject: "Air_fight_0.5_0991")
        self.compareProject(firstProjectName: "Air_fight_0.5_095", withProject: "Air_fight_0.5_0991")
        self.compareProject(firstProjectName: "Air_fight_0.5_096", withProject: "Air_fight_0.5_0991")
        self.compareProject(firstProjectName: "Air_fight_0.5_097", withProject: "Air_fight_0.5_0991")
        self.compareProject(firstProjectName: "Air_fight_0.5_098", withProject: "Air_fight_0.5_0991")
    }

    func testAirplaneWithShadow() {
        self.compareProject(firstProjectName: "Airplane_with_shadow_091", withProject: "Airplane_with_shadow_0991")
        self.compareProject(firstProjectName: "Airplane_with_shadow_093", withProject: "Airplane_with_shadow_0991")
        self.compareProject(firstProjectName: "Airplane_with_shadow_095", withProject: "Airplane_with_shadow_0991")
        self.compareProject(firstProjectName: "Airplane_with_shadow_096", withProject: "Airplane_with_shadow_0991")
        self.compareProject(firstProjectName: "Airplane_with_shadow_097", withProject: "Airplane_with_shadow_0991")
        self.compareProject(firstProjectName: "Airplane_with_shadow_098", withProject: "Airplane_with_shadow_0991")
    }

    func testCompass() {
        self.compareProject(firstProjectName: "Compass_0.1_091", withProject: "Compass_0.1_0991")
        self.compareProject(firstProjectName: "Compass_0.1_093", withProject: "Compass_0.1_0991")
        self.compareProject(firstProjectName: "Compass_0.1_095", withProject: "Compass_0.1_0991")
        self.compareProject(firstProjectName: "Compass_0.1_096", withProject: "Compass_0.1_0991")
        self.compareProject(firstProjectName: "Compass_0.1_097", withProject: "Compass_0.1_0991")
        self.compareProject(firstProjectName: "Compass_0.1_098", withProject: "Compass_0.1_0991")
    }

    func testDemonstration() {
        self.compareProject(firstProjectName: "Demonstration_09", withProject: "Demonstration_0991")
        self.compareProject(firstProjectName: "Demonstration_093", withProject: "Demonstration_0991")
        self.compareProject(firstProjectName: "Demonstration_095", withProject: "Demonstration_0991")
        self.compareProject(firstProjectName: "Demonstration_096", withProject: "Demonstration_0991")
        self.compareProject(firstProjectName: "Demonstration_097", withProject: "Demonstration_0991")
        self.compareProject(firstProjectName: "Demonstration_098", withProject: "Demonstration_0991")
    }

    func testDrinkMoreWater() {
        self.compareProject(firstProjectName: "Drink_more_water_09", withProject: "Drink_more_water_0991")
        self.compareProject(firstProjectName: "Drink_more_water_093", withProject: "Drink_more_water_0991")
        self.compareProject(firstProjectName: "Drink_more_water_095", withProject: "Drink_more_water_0991")
        self.compareProject(firstProjectName: "Drink_more_water_096", withProject: "Drink_more_water_0991")
        self.compareProject(firstProjectName: "Drink_more_water_097", withProject: "Drink_more_water_0991")
        self.compareProject(firstProjectName: "Drink_more_water_098", withProject: "Drink_more_water_0991")
    }

    func testFlapPacMan() {
        self.compareProject(firstProjectName: "Flap_Pac_Man_091", withProject: "Flap_Pac_Man_0991")
        self.compareProject(firstProjectName: "Flap_Pac_Man_093", withProject: "Flap_Pac_Man_0991")
        self.compareProject(firstProjectName: "Flap_Pac_Man_095", withProject: "Flap_Pac_Man_0991")
        self.compareProject(firstProjectName: "Flap_Pac_Man_096", withProject: "Flap_Pac_Man_0991")
        self.compareProject(firstProjectName: "Flap_Pac_Man_097", withProject: "Flap_Pac_Man_0991")
        self.compareProject(firstProjectName: "Flap_Pac_Man_098", withProject: "Flap_Pac_Man_0991")
    }

    func testFlappy30() {
        self.compareProject(firstProjectName: "Flappy_v3.0_092", withProject: "Flappy_v3.0_0991")
        self.compareProject(firstProjectName: "Flappy_v3.0_093", withProject: "Flappy_v3.0_0991")
        self.compareProject(firstProjectName: "Flappy_v3.0_095", withProject: "Flappy_v3.0_0991")
        self.compareProject(firstProjectName: "Flappy_v3.0_096", withProject: "Flappy_v3.0_0991")
        self.compareProject(firstProjectName: "Flappy_v3.0_097", withProject: "Flappy_v3.0_0991")
        self.compareProject(firstProjectName: "Flappy_v3.0_098", withProject: "Flappy_v3.0_0991")
    }

    func testGalaxyWar() {
        self.compareProject(firstProjectName: "Galaxy_War_092", withProject: "Galaxy_War_0991")
        self.compareProject(firstProjectName: "Galaxy_War_093", withProject: "Galaxy_War_0991")
        self.compareProject(firstProjectName: "Galaxy_War_095", withProject: "Galaxy_War_0991")
        self.compareProject(firstProjectName: "Galaxy_War_096", withProject: "Galaxy_War_0991")
        self.compareProject(firstProjectName: "Galaxy_War_097", withProject: "Galaxy_War_0991")
        self.compareProject(firstProjectName: "Galaxy_War_098", withProject: "Galaxy_War_0991")
    }

    func testGossipGirl() {
        self.compareProject(firstProjectName: "Gossip_Girl_091", withProject: "Gossip_Girl_0991")
        self.compareProject(firstProjectName: "Gossip_Girl_093", withProject: "Gossip_Girl_0991")
        self.compareProject(firstProjectName: "Gossip_Girl_095", withProject: "Gossip_Girl_0991")
        self.compareProject(firstProjectName: "Gossip_Girl_096", withProject: "Gossip_Girl_0991")
        self.compareProject(firstProjectName: "Gossip_Girl_097", withProject: "Gossip_Girl_0991")
        self.compareProject(firstProjectName: "Gossip_Girl_098", withProject: "Gossip_Girl_0991")
    }

    func testMemory() {
        self.compareProject(firstProjectName: "Memory_09", withProject: "Memory_0991")
        self.compareProject(firstProjectName: "Memory_093", withProject: "Memory_0991")
        self.compareProject(firstProjectName: "Memory_095", withProject: "Memory_0991")
        self.compareProject(firstProjectName: "Memory_096", withProject: "Memory_0991")
        self.compareProject(firstProjectName: "Memory_097", withProject: "Memory_0991")
        self.compareProject(firstProjectName: "Memory_098", withProject: "Memory_0991")
    }

    func testMinecraftWorkInProgress() {
        self.compareProject(firstProjectName: "Minecraft_Work_In_Progress_092", withProject: "Minecraft_Work_In_Progress_0991")
        self.compareProject(firstProjectName: "Minecraft_Work_In_Progress_093", withProject: "Minecraft_Work_In_Progress_0991")
        self.compareProject(firstProjectName: "Minecraft_Work_In_Progress_095", withProject: "Minecraft_Work_In_Progress_0991")
        self.compareProject(firstProjectName: "Minecraft_Work_In_Progress_096", withProject: "Minecraft_Work_In_Progress_0991")
        self.compareProject(firstProjectName: "Minecraft_Work_In_Progress_097", withProject: "Minecraft_Work_In_Progress_0991")
        self.compareProject(firstProjectName: "Minecraft_Work_In_Progress_098", withProject: "Minecraft_Work_In_Progress_0991")
    }

    func testMinions() {
        self.compareProject(firstProjectName: "Minions__091", withProject: "Minions__0991")
        self.compareProject(firstProjectName: "Minions__093", withProject: "Minions__0991")
        self.compareProject(firstProjectName: "Minions__095", withProject: "Minions__0991")
        self.compareProject(firstProjectName: "Minions__096", withProject: "Minions__0991")
        self.compareProject(firstProjectName: "Minions__097", withProject: "Minions__0991")
        self.compareProject(firstProjectName: "Minions__098", withProject: "Minions__0991")
    }

    func testNyancat10() {
        self.compareProject(firstProjectName: "Nyancat_1.0_091", withProject: "Nyancat_1.0_0991")
        self.compareProject(firstProjectName: "Nyancat_1.0_093", withProject: "Nyancat_1.0_0991")
        self.compareProject(firstProjectName: "Nyancat_1.0_096", withProject: "Nyancat_1.0_0991")
        self.compareProject(firstProjectName: "Nyancat_1.0_097", withProject: "Nyancat_1.0_0991")
        self.compareProject(firstProjectName: "Nyancat_1.0_098", withProject: "Nyancat_1.0_0991")
    }

    func testPiano() {
        self.compareProject(firstProjectName: "Piano_09", withProject: "Piano_0991")
        self.compareProject(firstProjectName: "Piano_093", withProject: "Piano_0991")
        self.compareProject(firstProjectName: "Piano_096", withProject: "Piano_0991")
        self.compareProject(firstProjectName: "Piano_097", withProject: "Piano_0991")
        self.compareProject(firstProjectName: "Piano_098", withProject: "Piano_0991")
    }

    func testPongStarter() {
        self.compareProject(firstProjectName: "Pong_Starter_09", withProject: "Pong_Starter_0991")
        self.compareProject(firstProjectName: "Pong_Starter_093", withProject: "Pong_Starter_0991")
        self.compareProject(firstProjectName: "Pong_Starter_095", withProject: "Pong_Starter_0991")
        self.compareProject(firstProjectName: "Pong_Starter_096", withProject: "Pong_Starter_0991")
        self.compareProject(firstProjectName: "Pong_Starter_097", withProject: "Pong_Starter_0991")
        self.compareProject(firstProjectName: "Pong_Starter_098", withProject: "Pong_Starter_0991")
    }

    func testPythagoreanTheorem() {
        self.compareProject(firstProjectName: "Pythagorean_Theorem_092", withProject: "Pythagorean_Theorem_0991")
        self.compareProject(firstProjectName: "Pythagorean_Theorem_093", withProject: "Pythagorean_Theorem_0991")
        self.compareProject(firstProjectName: "Pythagorean_Theorem_095", withProject: "Pythagorean_Theorem_0991")
        self.compareProject(firstProjectName: "Pythagorean_Theorem_096", withProject: "Pythagorean_Theorem_0991")
        self.compareProject(firstProjectName: "Pythagorean_Theorem_097", withProject: "Pythagorean_Theorem_0991")
        self.compareProject(firstProjectName: "Pythagorean_Theorem_098", withProject: "Pythagorean_Theorem_0991")
    }

    func testRockPaperScissors() {
        self.compareProject(firstProjectName: "Rock_paper_scissors_091", withProject: "Rock_paper_scissors_0991")
        self.compareProject(firstProjectName: "Rock_paper_scissors_093", withProject: "Rock_paper_scissors_0991")
        self.compareProject(firstProjectName: "Rock_paper_scissors_095", withProject: "Rock_paper_scissors_0991")
        self.compareProject(firstProjectName: "Rock_paper_scissors_096", withProject: "Rock_paper_scissors_0991")
        self.compareProject(firstProjectName: "Rock_paper_scissors_097", withProject: "Rock_paper_scissors_0991")
        self.compareProject(firstProjectName: "Rock_paper_scissors_098", withProject: "Rock_paper_scissors_0991")
    }

    func testSkydivingSteve() {
        self.compareProject(firstProjectName: "Skydiving_Steve_092", withProject: "Skydiving_Steve_0991")
        self.compareProject(firstProjectName: "Skydiving_Steve_093", withProject: "Skydiving_Steve_0991")
        self.compareProject(firstProjectName: "Skydiving_Steve_095", withProject: "Skydiving_Steve_0991")
        self.compareProject(firstProjectName: "Skydiving_Steve_096", withProject: "Skydiving_Steve_0991")
        self.compareProject(firstProjectName: "Skydiving_Steve_097", withProject: "Skydiving_Steve_0991")
        self.compareProject(firstProjectName: "Skydiving_Steve_098", withProject: "Skydiving_Steve_0991")
    }

    func testTicTacToeMaster() {
        self.compareProject(firstProjectName: "Tic_Tac_Toe_Master_091", withProject: "Tic_Tac_Toe_Master_0991")
        self.compareProject(firstProjectName: "Tic_Tac_Toe_Master_093", withProject: "Tic_Tac_Toe_Master_0991")
        self.compareProject(firstProjectName: "Tic_Tac_Toe_Master_095", withProject: "Tic_Tac_Toe_Master_0991")
        self.compareProject(firstProjectName: "Tic_Tac_Toe_Master_096", withProject: "Tic_Tac_Toe_Master_0991")
        self.compareProject(firstProjectName: "Tic_Tac_Toe_Master_097", withProject: "Tic_Tac_Toe_Master_0991")
        self.compareProject(firstProjectName: "Tic_Tac_Toe_Master_098", withProject: "Tic_Tac_Toe_Master_0991")
    }

    func testWordBalloonDemo() {
        self.compareProject(firstProjectName: "Word_balloon_demo_09", withProject: "Word_balloon_demo_0991")
        self.compareProject(firstProjectName: "Word_balloon_demo_093", withProject: "Word_balloon_demo_0991")
        self.compareProject(firstProjectName: "Word_balloon_demo_095", withProject: "Word_balloon_demo_0991")
        self.compareProject(firstProjectName: "Word_balloon_demo_096", withProject: "Word_balloon_demo_0991")
        self.compareProject(firstProjectName: "Word_balloon_demo_097", withProject: "Word_balloon_demo_0991")
        self.compareProject(firstProjectName: "Word_balloon_demo_098", withProject: "Word_balloon_demo_0991")
    }

    func testXRayPhone() {
        self.compareProject(firstProjectName: "X_Ray_phone_091", withProject: "X_Ray_phone_0991")
        self.compareProject(firstProjectName: "X_Ray_phone_093", withProject: "X_Ray_phone_0991")
        self.compareProject(firstProjectName: "X_Ray_phone_095", withProject: "X_Ray_phone_0991")
        self.compareProject(firstProjectName: "X_Ray_phone_096", withProject: "X_Ray_phone_0991")
        self.compareProject(firstProjectName: "X_Ray_phone_097", withProject: "X_Ray_phone_0991")
        self.compareProject(firstProjectName: "X_Ray_phone_098", withProject: "X_Ray_phone_0991")
    }

    func testSolarSystem() {
        self.compareProject(firstProjectName: "Solar_System_v1.0_092", withProject: "Solar_System_v1.0_0991")
        self.compareProject(firstProjectName: "Solar_System_v1.0_097", withProject: "Solar_System_v1.0_0991")
        self.compareProject(firstProjectName: "Solar_System_v1.0_098", withProject: "Solar_System_v1.0_0991")
    }
}
