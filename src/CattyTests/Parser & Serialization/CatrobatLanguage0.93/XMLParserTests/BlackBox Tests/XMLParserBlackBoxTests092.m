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

#import <XCTest/XCTest.h>
#import "XMLAbstractTest.h"
#import "CBXMLParser.h"
#import "Parser.h"

@interface XMLParserBlackBoxTests092 : XMLAbstractTest

@end

@implementation XMLParserBlackBoxTests092

- (void)testAirFight05
{
    [self compareProgram:@"Air_fight_0.5_091" withProgram:@"Air_fight_0.5_093"];
}

- (void)testAirplaneWithShadow
{
    [self compareProgram:@"Airplane_with_shadow_091" withProgram:@"Airplane_with_shadow_093"];
}

- (void)testCompass01
{
    [self compareProgram:@"Compass_0.1_091" withProgram:@"Compass_0.1_093"];
}

- (void)testDemonstration
{
    [self compareProgram:@"Demonstration_09" withProgram:@"Demonstration_093"];
}

- (void)testDrinkMoreWater
{
    [self compareProgram:@"Drink_more_water_09" withProgram:@"Drink_more_water_093"];
}

- (void)testFlapPacMan
{
    [self compareProgram:@"Flap_Pac_Man_091" withProgram:@"Flap_Pac_Man_093"];
}

- (void)testFlappy30
{
    [self compareProgram:@"Flappy_v3.0_092" withProgram:@"Flappy_v3.0_093"];
}

- (void)testGalaxyWar
{
    [self compareProgram:@"Galaxy_War_092" withProgram:@"Galaxy_War_093"];
}

- (void)testGossipGirl
{
    [self compareProgram:@"Gossip_Girl_091" withProgram:@"Gossip_Girl_093"];
}

- (void)testMemory
{
    [self compareProgram:@"Memory_09" withProgram:@"Memory_093"];
}

- (void)testMinecraftWorkInProgress
{
    [self compareProgram:@"Minecraft_Work_In_Progress_092" withProgram:@"Minecraft_Work_In_Progress_093"];
}

- (void)testMinions_
{
    [self compareProgram:@"Minions__091" withProgram:@"Minions__093"];
}

- (void)testNyancat10
{
    [self compareProgram:@"Nyancat_1.0_091" withProgram:@"Nyancat_1.0_093"];
}

- (void)testPiano
{
    [self compareProgram:@"Piano_09" withProgram:@"Piano_093"];
}

- (void)testPongStarter
{
    [self compareProgram:@"Pong_Starter_09" withProgram:@"Pong_Starter_093"];
}

- (void)testPythagoreanTheorem
{
    [self compareProgram:@"Pythagorean_Theorem_092" withProgram:@"Pythagorean_Theorem_093"];
}

- (void)testRockPaperScissors
{
    [self compareProgram:@"Rock_paper_scissors_091" withProgram:@"Rock_paper_scissors_093"];
}

- (void)testSkyPascal
{
    [self compareProgram:@"SKYPASCAL_08" withProgram:@"SKYPASCAL_093"];
}

- (void)testSkydivingSteve
{
    [self compareProgram:@"Skydiving_Steve_092" withProgram:@"Skydiving_Steve_093"];
}

- (void)testTicTacToeMaster
{
    [self compareProgram:@"Tic_Tac_Toe_Master_091" withProgram:@"Tic_Tac_Toe_Master_093"];
}

- (void)testWordBalloonDemo
{
    [self compareProgram:@"Word_balloon_demo_09" withProgram:@"Word_balloon_demo_093"];
}

- (void)testXRayPhone
{
    [self compareProgram:@"X_Ray_phone_091" withProgram:@"X_Ray_phone_093"];
}

@end
