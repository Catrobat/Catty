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

final class XMLParserBlackBoxTests: XMLAbstractTest {

    func testAirFight() {
        self.compareProject(firstProjectName: "Air_fight_0.5_091", withProject: "Air_fight_0.5_093")
        self.compareProject(firstProjectName: "Air_fight_0.5_093", withProject: "Air_fight_0.5_095")
        self.compareProject(firstProjectName: "Air_fight_0.5_095", withProject: "Air_fight_0.5_096")
        self.compareProject(firstProjectName: "Air_fight_0.5_096", withProject: "Air_fight_0.5_097")
        self.compareProject(firstProjectName: "Air_fight_0.5_097", withProject: "Air_fight_0.5_098")
        self.compareProject(firstProjectName: "Air_fight_0.5_098", withProject: "Air_fight_0.5_0991")
        self.compareProject(firstProjectName: "Air_fight_0.5_0991", withProject: "Air_fight_0.5_0992")
        self.compareProject(firstProjectName: "Air_fight_0.5_0992", withProject: "Air_fight_0.5_0993")
        self.compareProject(firstProjectName: "Air_fight_0.5_0993", withProject: "Air_fight_0.5_0994")
        self.compareProject(firstProjectName: "Air_fight_0.5_0994", withProject: "Air_fight_0.5_0995")
        self.compareProject(firstProjectName: "Air_fight_0.5_0995", withProject: "Air_fight_0.5_0996")
        self.compareProject(firstProjectName: "Air_fight_0.5_0996", withProject: "Air_fight_0.5_0998")
        self.compareProject(firstProjectName: "Air_fight_0.5_0998", withProject: "Air_fight_0.5_0999")
        self.compareProject(firstProjectName: "Air_fight_0.5_0999", withProject: "Air_fight_0.5_09993")
    }

    func testAirplaneWithShadow() {
        self.compareProject(firstProjectName: "Airplane_with_shadow_091", withProject: "Airplane_with_shadow_093")
        self.compareProject(firstProjectName: "Airplane_with_shadow_093", withProject: "Airplane_with_shadow_095")
        self.compareProject(firstProjectName: "Airplane_with_shadow_095", withProject: "Airplane_with_shadow_096")
        self.compareProject(firstProjectName: "Airplane_with_shadow_096", withProject: "Airplane_with_shadow_097")
        self.compareProject(firstProjectName: "Airplane_with_shadow_097", withProject: "Airplane_with_shadow_098")
        self.compareProject(firstProjectName: "Airplane_with_shadow_098", withProject: "Airplane_with_shadow_0991")
        self.compareProject(firstProjectName: "Airplane_with_shadow_0991", withProject: "Airplane_with_shadow_0992")
        self.compareProject(firstProjectName: "Airplane_with_shadow_0992", withProject: "Airplane_with_shadow_0993")
        self.compareProject(firstProjectName: "Airplane_with_shadow_0993", withProject: "Airplane_with_shadow_0994")
        self.compareProject(firstProjectName: "Airplane_with_shadow_0994", withProject: "Airplane_with_shadow_0995")
        self.compareProject(firstProjectName: "Airplane_with_shadow_0995", withProject: "Airplane_with_shadow_0996")
        self.compareProject(firstProjectName: "Airplane_with_shadow_0996", withProject: "Airplane_with_shadow_0998")
        self.compareProject(firstProjectName: "Airplane_with_shadow_0998", withProject: "Airplane_with_shadow_0999")
        self.compareProject(firstProjectName: "Airplane_with_shadow_0999", withProject: "Airplane_with_shadow_09993")
    }

    func testDemonstration() {
        self.compareProject(firstProjectName: "Demonstration_09", withProject: "Demonstration_093")
        self.compareProject(firstProjectName: "Demonstration_093", withProject: "Demonstration_095")
        self.compareProject(firstProjectName: "Demonstration_095", withProject: "Demonstration_096")
        self.compareProject(firstProjectName: "Demonstration_096", withProject: "Demonstration_097")
        self.compareProject(firstProjectName: "Demonstration_097", withProject: "Demonstration_098")
        self.compareProject(firstProjectName: "Demonstration_098", withProject: "Demonstration_0991")
        self.compareProject(firstProjectName: "Demonstration_0991", withProject: "Demonstration_0992")
        self.compareProject(firstProjectName: "Demonstration_0992", withProject: "Demonstration_0993")
        self.compareProject(firstProjectName: "Demonstration_0993", withProject: "Demonstration_0994")
        self.compareProject(firstProjectName: "Demonstration_0994", withProject: "Demonstration_0995")
        self.compareProject(firstProjectName: "Demonstration_0995", withProject: "Demonstration_0996")
        self.compareProject(firstProjectName: "Demonstration_0996", withProject: "Demonstration_0998")
        self.compareProject(firstProjectName: "Demonstration_0998", withProject: "Demonstration_0999")
        self.compareProject(firstProjectName: "Demonstration_0999", withProject: "Demonstration_09993")
    }

    func testFlapPacMan() {
        self.compareProject(firstProjectName: "Flap_Pac_Man_091", withProject: "Flap_Pac_Man_093")
        self.compareProject(firstProjectName: "Flap_Pac_Man_093", withProject: "Flap_Pac_Man_095")
        self.compareProject(firstProjectName: "Flap_Pac_Man_095", withProject: "Flap_Pac_Man_096")
        self.compareProject(firstProjectName: "Flap_Pac_Man_096", withProject: "Flap_Pac_Man_097")
        self.compareProject(firstProjectName: "Flap_Pac_Man_097", withProject: "Flap_Pac_Man_098")
        self.compareProject(firstProjectName: "Flap_Pac_Man_098", withProject: "Flap_Pac_Man_0991")
        self.compareProject(firstProjectName: "Flap_Pac_Man_0991", withProject: "Flap_Pac_Man_0992")
        self.compareProject(firstProjectName: "Flap_Pac_Man_0992", withProject: "Flap_Pac_Man_0993")
        self.compareProject(firstProjectName: "Flap_Pac_Man_0993", withProject: "Flap_Pac_Man_0994")
        self.compareProject(firstProjectName: "Flap_Pac_Man_0994", withProject: "Flap_Pac_Man_0995")
        self.compareProject(firstProjectName: "Flap_Pac_Man_0995", withProject: "Flap_Pac_Man_0996")
        self.compareProject(firstProjectName: "Flap_Pac_Man_0996", withProject: "Flap_Pac_Man_0998")
        self.compareProject(firstProjectName: "Flap_Pac_Man_0998", withProject: "Flap_Pac_Man_0999")
        self.compareProject(firstProjectName: "Flap_Pac_Man_0999", withProject: "Flap_Pac_Man_09993")
    }

    func testFlappy() {
        self.compareProject(firstProjectName: "Flappy_v3.0_092", withProject: "Flappy_v3.0_093")
        self.compareProject(firstProjectName: "Flappy_v3.0_093", withProject: "Flappy_v3.0_095")
        self.compareProject(firstProjectName: "Flappy_v3.0_095", withProject: "Flappy_v3.0_096")
        self.compareProject(firstProjectName: "Flappy_v3.0_096", withProject: "Flappy_v3.0_097")
        self.compareProject(firstProjectName: "Flappy_v3.0_097", withProject: "Flappy_v3.0_098")
        self.compareProject(firstProjectName: "Flappy_v3.0_098", withProject: "Flappy_v3.0_0991")
        self.compareProject(firstProjectName: "Flappy_v3.0_0991", withProject: "Flappy_v3.0_0992")
        self.compareProject(firstProjectName: "Flappy_v3.0_0992", withProject: "Flappy_v3.0_0993")
        self.compareProject(firstProjectName: "Flappy_v3.0_0993", withProject: "Flappy_v3.0_0994")
        self.compareProject(firstProjectName: "Flappy_v3.0_0994", withProject: "Flappy_v3.0_0995")
        self.compareProject(firstProjectName: "Flappy_v3.0_0995", withProject: "Flappy_v3.0_0996")
        self.compareProject(firstProjectName: "Flappy_v3.0_0996", withProject: "Flappy_v3.0_0998")
        self.compareProject(firstProjectName: "Flappy_v3.0_0998", withProject: "Flappy_v3.0_0999")
        self.compareProject(firstProjectName: "Flappy_v3.0_0999", withProject: "Flappy_v3.0_09993")
    }

    func testGalaxyWar() {
        self.compareProject(firstProjectName: "Galaxy_War_092", withProject: "Galaxy_War_093")
        self.compareProject(firstProjectName: "Galaxy_War_093", withProject: "Galaxy_War_095")
        self.compareProject(firstProjectName: "Galaxy_War_095", withProject: "Galaxy_War_096")
        self.compareProject(firstProjectName: "Galaxy_War_096", withProject: "Galaxy_War_097")
        self.compareProject(firstProjectName: "Galaxy_War_097", withProject: "Galaxy_War_098")
        self.compareProject(firstProjectName: "Galaxy_War_098", withProject: "Galaxy_War_0991")
        self.compareProject(firstProjectName: "Galaxy_War_0991", withProject: "Galaxy_War_0992")
        self.compareProject(firstProjectName: "Galaxy_War_0992", withProject: "Galaxy_War_0993")
        self.compareProject(firstProjectName: "Galaxy_War_0993", withProject: "Galaxy_War_0994")
        self.compareProject(firstProjectName: "Galaxy_War_0994", withProject: "Galaxy_War_0995")
        self.compareProject(firstProjectName: "Galaxy_War_0995", withProject: "Galaxy_War_0996")
        self.compareProject(firstProjectName: "Galaxy_War_0996", withProject: "Galaxy_War_0998")
        self.compareProject(firstProjectName: "Galaxy_War_0998", withProject: "Galaxy_War_0999")
        self.compareProject(firstProjectName: "Galaxy_War_0999", withProject: "Galaxy_War_09993")
    }

    func testMemory() {
        self.compareProject(firstProjectName: "Memory_09", withProject: "Memory_093")
        self.compareProject(firstProjectName: "Memory_093", withProject: "Memory_095")
        self.compareProject(firstProjectName: "Memory_095", withProject: "Memory_096")
        self.compareProject(firstProjectName: "Memory_096", withProject: "Memory_097")
        self.compareProject(firstProjectName: "Memory_097", withProject: "Memory_098")
        self.compareProject(firstProjectName: "Memory_098", withProject: "Memory_0991")
        self.compareProject(firstProjectName: "Memory_0991", withProject: "Memory_0992")
        self.compareProject(firstProjectName: "Memory_0992", withProject: "Memory_0993")
        self.compareProject(firstProjectName: "Memory_0993", withProject: "Memory_0994")
        self.compareProject(firstProjectName: "Memory_0994", withProject: "Memory_0995")
        self.compareProject(firstProjectName: "Memory_0995", withProject: "Memory_0996")
        self.compareProject(firstProjectName: "Memory_0996", withProject: "Memory_0998")
        self.compareProject(firstProjectName: "Memory_0998", withProject: "Memory_0999")
        self.compareProject(firstProjectName: "Memory_0999", withProject: "Memory_09993")
    }

    func testPiano() {
        self.compareProject(firstProjectName: "Piano_09", withProject: "Piano_093")
        self.compareProject(firstProjectName: "Piano_093", withProject: "Piano_096")
        self.compareProject(firstProjectName: "Piano_096", withProject: "Piano_097")
        self.compareProject(firstProjectName: "Piano_097", withProject: "Piano_098")
        self.compareProject(firstProjectName: "Piano_098", withProject: "Piano_0991")
        self.compareProject(firstProjectName: "Piano_0991", withProject: "Piano_0992")
        self.compareProject(firstProjectName: "Piano_0992", withProject: "Piano_0993")
        self.compareProject(firstProjectName: "Piano_0993", withProject: "Piano_0994")
        self.compareProject(firstProjectName: "Piano_0994", withProject: "Piano_0995")
        self.compareProject(firstProjectName: "Piano_0995", withProject: "Piano_0996")
        self.compareProject(firstProjectName: "Piano_0996", withProject: "Piano_0998")
        self.compareProject(firstProjectName: "Piano_0998", withProject: "Piano_0999")
        self.compareProject(firstProjectName: "Piano_0999", withProject: "Piano_09993")
    }

    func testPongStarter() {
        self.compareProject(firstProjectName: "Pong_Starter_09", withProject: "Pong_Starter_093")
        self.compareProject(firstProjectName: "Pong_Starter_093", withProject: "Pong_Starter_095")
        self.compareProject(firstProjectName: "Pong_Starter_095", withProject: "Pong_Starter_096")
        self.compareProject(firstProjectName: "Pong_Starter_096", withProject: "Pong_Starter_097")
        self.compareProject(firstProjectName: "Pong_Starter_097", withProject: "Pong_Starter_098")
        self.compareProject(firstProjectName: "Pong_Starter_098", withProject: "Pong_Starter_0991")
        self.compareProject(firstProjectName: "Pong_Starter_0991", withProject: "Pong_Starter_0992")
        self.compareProject(firstProjectName: "Pong_Starter_0992", withProject: "Pong_Starter_0993")
        self.compareProject(firstProjectName: "Pong_Starter_0993", withProject: "Pong_Starter_0994")
        self.compareProject(firstProjectName: "Pong_Starter_0994", withProject: "Pong_Starter_0995")
        self.compareProject(firstProjectName: "Pong_Starter_0995", withProject: "Pong_Starter_0996")
        self.compareProject(firstProjectName: "Pong_Starter_0996", withProject: "Pong_Starter_0998")
        self.compareProject(firstProjectName: "Pong_Starter_0998", withProject: "Pong_Starter_0999")
        self.compareProject(firstProjectName: "Pong_Starter_0999", withProject: "Pong_Starter_09993")
    }

    func testPythagoreanTheorem() {
        self.compareProject(firstProjectName: "Pythagorean_Theorem_092", withProject: "Pythagorean_Theorem_093")
        self.compareProject(firstProjectName: "Pythagorean_Theorem_093", withProject: "Pythagorean_Theorem_095")
        self.compareProject(firstProjectName: "Pythagorean_Theorem_095", withProject: "Pythagorean_Theorem_096")
        self.compareProject(firstProjectName: "Pythagorean_Theorem_096", withProject: "Pythagorean_Theorem_097")
        self.compareProject(firstProjectName: "Pythagorean_Theorem_097", withProject: "Pythagorean_Theorem_098")
        self.compareProject(firstProjectName: "Pythagorean_Theorem_098", withProject: "Pythagorean_Theorem_0991")
        self.compareProject(firstProjectName: "Pythagorean_Theorem_0991", withProject: "Pythagorean_Theorem_0992")
        self.compareProject(firstProjectName: "Pythagorean_Theorem_0992", withProject: "Pythagorean_Theorem_0993")
        self.compareProject(firstProjectName: "Pythagorean_Theorem_0993", withProject: "Pythagorean_Theorem_0994")
        self.compareProject(firstProjectName: "Pythagorean_Theorem_0994", withProject: "Pythagorean_Theorem_0995")
        self.compareProject(firstProjectName: "Pythagorean_Theorem_0995", withProject: "Pythagorean_Theorem_0996")
        self.compareProject(firstProjectName: "Pythagorean_Theorem_0996", withProject: "Pythagorean_Theorem_0998")
        self.compareProject(firstProjectName: "Pythagorean_Theorem_0998", withProject: "Pythagorean_Theorem_0999")
        self.compareProject(firstProjectName: "Pythagorean_Theorem_0999", withProject: "Pythagorean_Theorem_09993")
    }

    func testTicTacToeMaster() {
        self.compareProject(firstProjectName: "Tic_Tac_Toe_Master_091", withProject: "Tic_Tac_Toe_Master_093")
        self.compareProject(firstProjectName: "Tic_Tac_Toe_Master_093", withProject: "Tic_Tac_Toe_Master_095")
        self.compareProject(firstProjectName: "Tic_Tac_Toe_Master_095", withProject: "Tic_Tac_Toe_Master_096")
        self.compareProject(firstProjectName: "Tic_Tac_Toe_Master_096", withProject: "Tic_Tac_Toe_Master_097")
        self.compareProject(firstProjectName: "Tic_Tac_Toe_Master_097", withProject: "Tic_Tac_Toe_Master_098")
        self.compareProject(firstProjectName: "Tic_Tac_Toe_Master_098", withProject: "Tic_Tac_Toe_Master_0991")
        self.compareProject(firstProjectName: "Tic_Tac_Toe_Master_0991", withProject: "Tic_Tac_Toe_Master_0992")
        self.compareProject(firstProjectName: "Tic_Tac_Toe_Master_0992", withProject: "Tic_Tac_Toe_Master_0993")
        self.compareProject(firstProjectName: "Tic_Tac_Toe_Master_0993", withProject: "Tic_Tac_Toe_Master_0994")
        self.compareProject(firstProjectName: "Tic_Tac_Toe_Master_0994", withProject: "Tic_Tac_Toe_Master_0995")
        self.compareProject(firstProjectName: "Tic_Tac_Toe_Master_0995", withProject: "Tic_Tac_Toe_Master_0996")
        self.compareProject(firstProjectName: "Tic_Tac_Toe_Master_0996", withProject: "Tic_Tac_Toe_Master_0998")
        self.compareProject(firstProjectName: "Tic_Tac_Toe_Master_0998", withProject: "Tic_Tac_Toe_Master_0999")
        self.compareProject(firstProjectName: "Tic_Tac_Toe_Master_0999", withProject: "Tic_Tac_Toe_Master_09993")
    }

    func testUserVariables() {
        self.compareProject(firstProjectName: "UserVariables_091", withProject: "UserVariables_0991")
        self.compareProject(firstProjectName: "UserVariables_0991", withProject: "UserVariables_0993")
        self.compareProject(firstProjectName: "UserVariables_0993", withProject: "UserVariables_0994")
        self.compareProject(firstProjectName: "UserVariables_0994", withProject: "UserVariables_0995")
        self.compareProject(firstProjectName: "UserVariables_0995", withProject: "UserVariables_0996")
        self.compareProject(firstProjectName: "UserVariables_0996", withProject: "UserVariables_0998")
        self.compareProject(firstProjectName: "UserVariables_0998", withProject: "UserVariables_0999")
        self.compareProject(firstProjectName: "UserVariables_0999", withProject: "UserVariables_09993")
    }

    func testUserLists() {
        self.compareProject(firstProjectName: "UserLists_0996", withProject: "UserLists_0998")
        self.compareProject(firstProjectName: "UserLists_0998", withProject: "UserLists_0999")
        self.compareProject(firstProjectName: "UserLists_0999", withProject: "UserLists_09993")
    }

    func testEscapingChars() {
        self.compareProject(firstProjectName: "EscapingChars_0991", withProject: "EscapingChars_0992")
        self.compareProject(firstProjectName: "EscapingChars_0992", withProject: "EscapingChars_0993")
        self.compareProject(firstProjectName: "EscapingChars_0993", withProject: "EscapingChars_0994")
        self.compareProject(firstProjectName: "EscapingChars_0994", withProject: "EscapingChars_0995")
        self.compareProject(firstProjectName: "EscapingChars_0995", withProject: "EscapingChars_0996")
        self.compareProject(firstProjectName: "EscapingChars_0996", withProject: "EscapingChars_0998")
        self.compareProject(firstProjectName: "EscapingChars_0998", withProject: "EscapingChars_0999")
        self.compareProject(firstProjectName: "EscapingChars_0999", withProject: "EscapingChars_09993")
    }

    func testEncapsulatedObject() {
        self.compareProject(firstProjectName: "Encapsulated_097", withProject: "Encapsulated_098")
        self.compareProject(firstProjectName: "Encapsulated_0991", withProject: "Encapsulated_0992")
        self.compareProject(firstProjectName: "Encapsulated_0992", withProject: "Encapsulated_0993")
        self.compareProject(firstProjectName: "Encapsulated_0993", withProject: "Encapsulated_0994")
        self.compareProject(firstProjectName: "Encapsulated_0994", withProject: "Encapsulated_0995")
        self.compareProject(firstProjectName: "Encapsulated_0995", withProject: "Encapsulated_0996")
        self.compareProject(firstProjectName: "Encapsulated_0996", withProject: "Encapsulated_0998")
        self.compareProject(firstProjectName: "Encapsulated_0998", withProject: "Encapsulated_0999")
        self.compareProject(firstProjectName: "Encapsulated_0999", withProject: "Encapsulated_09993")
    }

    func testDisabledBricks() {
        self.compareProject(firstProjectName: "DisabledBricks_0991", withProject: "DisabledBricks_0992")
        self.compareProject(firstProjectName: "DisabledBricks_0992", withProject: "DisabledBricks_0993")
        self.compareProject(firstProjectName: "DisabledBricks_0993", withProject: "DisabledBricks_0994")
        self.compareProject(firstProjectName: "DisabledBricks_0994", withProject: "DisabledBricks_0995")
        self.compareProject(firstProjectName: "DisabledBricks_0995", withProject: "DisabledBricks_0996")
        self.compareProject(firstProjectName: "DisabledBricks_0996", withProject: "DisabledBricks_0998")
        self.compareProject(firstProjectName: "DisabledBricks_0998", withProject: "DisabledBricks_0999")
        self.compareProject(firstProjectName: "DisabledBricks_0999", withProject: "DisabledBricks_09993")
    }

    func testGoToEncapsulatedObject() {
        self.compareProject(firstProjectName: "GoToBrick_0992", withProject: "GoToBrick_0993")
        self.compareProject(firstProjectName: "GoToBrick_0993", withProject: "GoToBrick_0994")
        self.compareProject(firstProjectName: "GoToBrick_0994", withProject: "GoToBrick_0995")
        self.compareProject(firstProjectName: "GoToBrick_0995", withProject: "GoToBrick_0996")
        self.compareProject(firstProjectName: "GoToBrick_0996", withProject: "GoToBrick_0998")
        self.compareProject(firstProjectName: "GoToBrick_0998", withProject: "GoToBrick_0999")
        self.compareProject(firstProjectName: "GoToBrick_0999", withProject: "GoToBrick_09993")
      }
}
