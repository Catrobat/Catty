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

@interface XMLParserBlackBoxTests095 : XMLAbstractTest

@end

@implementation XMLParserBlackBoxTests095

- (void)testAirFight05
{
    [self compareProgram:@"Air_fight_0.5_093" withProgram:@"Air_fight_0.5_095"];
}

- (void)testAirplaneWithShadow
{
    [self compareProgram:@"Airplane_with_shadow_093" withProgram:@"Airplane_with_shadow_095"];
}

- (void)testCompass01
{
    [self compareProgram:@"Compass_0.1_093" withProgram:@"Compass_0.1_095"];
}

- (void)testDemonstration
{
    [self compareProgram:@"Demonstration_093" withProgram:@"Demonstration_095"];
}

- (void)testDrinkMoreWater
{
    [self compareProgram:@"Drink_more_water_093" withProgram:@"Drink_more_water_095"];
}

- (void)testFlapPacMan
{
    [self compareProgram:@"Flap_Pac_Man_093" withProgram:@"Flap_Pac_Man_095"];
}

- (void)testFlappy30
{
    [self compareProgram:@"Flappy_v3.0_093" withProgram:@"Flappy_v3.0_095"];
}

- (void)testGalaxyWar
{
    [self compareProgram:@"Galaxy_War_093" withProgram:@"Galaxy_War_093"];
}

- (void)testGossipGirl
{
    [self compareProgram:@"Gossip_Girl_091" withProgram:@"Gossip_Girl_095"];
}

- (void)testMemory
{
    [self compareProgram:@"Memory_093" withProgram:@"Memory_095"];
}

- (void)testMinecraftWorkInProgress
{
    [self compareProgram:@"Minecraft_Work_In_Progress_093" withProgram:@"Minecraft_Work_In_Progress_095"];
}

- (void)testMinions_
{
    [self compareProgram:@"Minions__093" withProgram:@"Minions__095"];
}

- (void)testPongStarter
{
    [self compareProgram:@"Pong_Starter_093" withProgram:@"Pong_Starter_095"];
}

- (void)testPythagoreanTheorem
{
    [self compareProgram:@"Pythagorean_Theorem_093" withProgram:@"Pythagorean_Theorem_095"];
}

- (void)testRockPaperScissors
{
    [self compareProgram:@"Rock_paper_scissors_093" withProgram:@"Rock_paper_scissors_095"];
}

- (void)testSkydivingSteve
{
    [self compareProgram:@"Skydiving_Steve_093" withProgram:@"Skydiving_Steve_095"];
}

- (void)testTicTacToeMaster
{
    [self compareProgram:@"Tic_Tac_Toe_Master_093" withProgram:@"Tic_Tac_Toe_Master_095"];
}

- (void)testWordBalloonDemo
{
    [self compareProgram:@"Word_balloon_demo_093" withProgram:@"Word_balloon_demo_095"];
}

- (void)testXRayPhone
{
    [self compareProgram:@"X_Ray_phone_093" withProgram:@"X_Ray_phone_095"];
}

@end
