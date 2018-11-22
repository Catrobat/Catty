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

final class XMLParserBlackBoxTests093: XMLAbstractTest {
    func testAirFight0() {
        self.compareProgram(firstProgramName: "Air_fight_0.5_091", withProgram: "Air_fight_0.5_093")
    }
    
    func testAirplaneWithShadow()
    {
        self.compareProgram(firstProgramName: "Airplane_with_shadow_091", withProgram: "Airplane_with_shadow_093")
    }
    
    func testCompass01()
    {
    self.compareProgram(firstProgramName: "Compass_0.1_091", withProgram: "Compass_0.1_093")
    }
    
    func testDemonstration()
    {
        self.compareProgram(firstProgramName: "Demonstration_09", withProgram:"Demonstration_093")
    }
    
    func testDrinkMoreWater()
    {
        self.compareProgram(firstProgramName: "Drink_more_water_09", withProgram:"Drink_more_water_093")
    }
    
    func testFlapPacMan()
    {
        self.compareProgram(firstProgramName: "Flap_Pac_Man_091", withProgram:"Flap_Pac_Man_093")
    }
    
    func testFlappy30()
    {
        self.compareProgram(firstProgramName: "Flappy_v3.0_092", withProgram:"Flappy_v3.0_093")
    }
    
    func testGalaxyWar()
    {
        self.compareProgram(firstProgramName: "Galaxy_War_092", withProgram:"Galaxy_War_093")
    }
    
    func testGossipGirl()
    {
        self.compareProgram(firstProgramName: "Gossip_Girl_091", withProgram:"Gossip_Girl_093")
    }
    
    func testMemory()
    {
        self.compareProgram(firstProgramName: "Memory_09", withProgram:"Memory_093")
    }
    
    func testMinecraftWorkInProgress()
    {
        self.compareProgram(firstProgramName: "Minecraft_Work_In_Progress_092", withProgram:"Minecraft_Work_In_Progress_093")
    }
    
    func testMinions()
    {
        self.compareProgram(firstProgramName: "Minions__091", withProgram:"Minions__093")
    }
    
    func testNyancat10()
    {
        self.compareProgram(firstProgramName: "Nyancat_1.0_091", withProgram:"Nyancat_1.0_093")
    }
    
    func testPiano()
    {
        self.compareProgram(firstProgramName: "Piano_09", withProgram:"Piano_093")
    }
    
    func testPongStarter()
    {
        self.compareProgram(firstProgramName: "Pong_Starter_09", withProgram:"Pong_Starter_093")
    }
    
    func testPythagoreanTheorem()
    {
        self.compareProgram(firstProgramName: "Pythagorean_Theorem_092", withProgram:"Pythagorean_Theorem_093")
    }
    
    func testRockPaperScissors()
    {
        self.compareProgram(firstProgramName: "Rock_paper_scissors_091", withProgram:"Rock_paper_scissors_093")
    }
    
    func testSkyPascal()
    {
        self.compareProgram(firstProgramName: "SKYPASCAL_08", withProgram:"SKYPASCAL_093")
    }
    
    func testSkydivingSteve()
    {
        self.compareProgram(firstProgramName: "Skydiving_Steve_092", withProgram:"Skydiving_Steve_093")
    }
    
    func testTicTacToeMaster()
    {
        self.compareProgram(firstProgramName: "Tic_Tac_Toe_Master_091", withProgram:"Tic_Tac_Toe_Master_093")
    }
    
    func testWordBalloonDemo()
    {
        self.compareProgram(firstProgramName: "Word_balloon_demo_09", withProgram:"Word_balloon_demo_093")
    }
    
    func testXRayPhone()
    {
        self.compareProgram(firstProgramName: "X_Ray_phone_091", withProgram:"X_Ray_phone_093")
    }

}
