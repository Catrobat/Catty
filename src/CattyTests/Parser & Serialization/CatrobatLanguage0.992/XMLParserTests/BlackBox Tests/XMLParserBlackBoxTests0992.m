/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

#import <XCTest/XCTest.h>
#import "XMLAbstractTest.h"
#import "CBXMLParser.h"
#import "Parser.h"

@interface XMLParserBlackBoxTests0992 : XMLAbstractTest

@end

@implementation XMLParserBlackBoxTests0992

- (void)testAirFight
{
    [self compareProgram:@"Air_fight_0.5_098" withProgram:@"Air_fight_0.5_0992"];
}

- (void)testAirplaneWithShadow
{
    [self compareProgram:@"Airplane_with_shadow_098" withProgram:@"Airplane_with_shadow_0992"];
}

- (void)testCompass01
{
    [self compareProgram:@"Compass_0.1_098" withProgram:@"Compass_0.1_0992"];
}

- (void)testDemonstration
{
    [self compareProgram:@"Demonstration_098" withProgram:@"Demonstration_0992"];
}

- (void)testDrinkMoreWater
{
    [self compareProgram:@"Drink_more_water_098" withProgram:@"Drink_more_water_0992"];
}

- (void)testFlapPacMan
{
    [self compareProgram:@"Flap_Pac_Man_098" withProgram:@"Flap_Pac_Man_0992"];
}

- (void)testFlappy30
{
    [self compareProgram:@"Flappy_v3.0_098" withProgram:@"Flappy_v3.0_0992"];
}

- (void)testGalaxyWar
{
    [self compareProgram:@"Galaxy_War_098" withProgram:@"Galaxy_War_0992"];
}

- (void)testGossipGirl
{
    [self compareProgram:@"Gossip_Girl_098" withProgram:@"Gossip_Girl_0992"];
}

- (void)testMemory
{
    [self compareProgram:@"Memory_098" withProgram:@"Memory_0992"];
}

- (void)testMinecraftWorkInProgress
{
    [self compareProgram:@"Minecraft_Work_In_Progress_098" withProgram:@"Minecraft_Work_In_Progress_0992"];
}

- (void)testMinions_
{
    [self compareProgram:@"Minions__098" withProgram:@"Minions__0992"];
}

- (void)testNyancat10
{
    [self compareProgram:@"Nyancat_1.0_098" withProgram:@"Nyancat_1.0_0992"];
}

- (void)testPiano
{
    [self compareProgram:@"Piano_098" withProgram:@"Piano_0992"];
}

- (void)testPongStarter
{
    [self compareProgram:@"Pong_Starter_098" withProgram:@"Pong_Starter_0992"];
}

- (void)testPythagoreanTheorem
{
    [self compareProgram:@"Pythagorean_Theorem_098" withProgram:@"Pythagorean_Theorem_0992"];
}

- (void)testRockPaperScissors
{
    [self compareProgram:@"Rock_paper_scissors_098" withProgram:@"Rock_paper_scissors_0992"];
}

- (void)testSkydivingSteve
{
    [self compareProgram:@"Skydiving_Steve_098" withProgram:@"Skydiving_Steve_0992"];
}

- (void)testTicTacToeMaster
{
    [self compareProgram:@"Tic_Tac_Toe_Master_098" withProgram:@"Tic_Tac_Toe_Master_0992"];
}

- (void)testWordBalloonDemo
{
    [self compareProgram:@"Word_balloon_demo_098" withProgram:@"Word_balloon_demo_0992"];
}

- (void)testXRayPhone
{
    [self compareProgram:@"X_Ray_phone_098" withProgram:@"X_Ray_phone_0992"];
}

- (void)testSolarSystem
{
    [self compareProgram:@"Solar_System_v1.0_098" withProgram:@"Solar_System_v1.0_0992"];
}

- (void)testAirplaneWithShadow06
{
    [self compareProgram:@"Airplane_with_shadow_098" withProgram:@"Airplane_with_shadow_0992"];
}

- (void)testEncapsulated
{
    [self compareProgram:@"Encapsulated_098" withProgram:@"Encapsulated_0992"];
}


- (void)testValidProgramAllBricks
{
    [self compareProgram:@"ValidProgramAllBricks098" withProgram:@"ValidProgramAllBricks0992"];
}

- (void)testLedFlashBrick
{
    [self compareProgram:@"LedFlashBrick098" withProgram:@"LedFlashBrick0992"];
}

- (void)testNyancat
{
    [self compareProgram:@"Nyancat_1.0_098" withProgram:@"Nyancat_1.0_0992"];
}

- (void)testValidHeader
{
    [self compareProgram:@"ValidHeader098" withProgram:@"ValidHeader0992"];
}

- (void)testValidProgram
{
    [self compareProgram:@"ValidProgram098" withProgram:@"ValidProgram0992"];
}

@end
