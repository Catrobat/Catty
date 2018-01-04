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

@interface XMLParserBlackBoxTests098 : XMLAbstractTest

@end

@implementation XMLParserBlackBoxTests098

- (void)testAirFight
{
    [self compareProgram:@"Air_fight_0.5_095" withProgram:@"Air_fight_0.5_098"];
}

- (void)testAirplaneWithShadow
{
    [self compareProgram:@"Airplane_with_shadow_095" withProgram:@"Airplane_with_shadow_098"];
}

- (void)testCompass01
{
    [self compareProgram:@"Compass_0.1_095" withProgram:@"Compass_0.1_098"];
}

- (void)testDemonstration
{
    [self compareProgram:@"Demonstration_095" withProgram:@"Demonstration_098"];
}

- (void)testDrinkMoreWater
{
    [self compareProgram:@"Drink_more_water_095" withProgram:@"Drink_more_water_098"];
}

- (void)testFlapPacMan
{
    [self compareProgram:@"Flap_Pac_Man_095" withProgram:@"Flap_Pac_Man_098"];
}

- (void)testFlappy30
{
    [self compareProgram:@"Flappy_v3.0_095" withProgram:@"Flappy_v3.0_098"];
}

- (void)testGalaxyWar
{
    [self compareProgram:@"Galaxy_War_095" withProgram:@"Galaxy_War_098"];
}

- (void)testGossipGirl
{
    [self compareProgram:@"Gossip_Girl_095" withProgram:@"Gossip_Girl_098"];
}

- (void)testMemory
{
    [self compareProgram:@"Memory_095" withProgram:@"Memory_098"];
}

- (void)testMinecraftWorkInProgress
{
    [self compareProgram:@"Minecraft_Work_In_Progress_095" withProgram:@"Minecraft_Work_In_Progress_098"];
}

- (void)testMinions_
{
    [self compareProgram:@"Minions__095" withProgram:@"Minions__098"];
}

- (void)testNyancat10
{
    [self compareProgram:@"Nyancat_1.0_093" withProgram:@"Nyancat_1.0_098"];
}

- (void)testPiano
{
    [self compareProgram:@"Piano_093" withProgram:@"Piano_098"];
}

- (void)testPongStarter
{
    [self compareProgram:@"Pong_Starter_095" withProgram:@"Pong_Starter_098"];
}

- (void)testPythagoreanTheorem
{
    [self compareProgram:@"Pythagorean_Theorem_095" withProgram:@"Pythagorean_Theorem_098"];
}

- (void)testRockPaperScissors
{
    [self compareProgram:@"Rock_paper_scissors_095" withProgram:@"Rock_paper_scissors_098"];
}

- (void)testSkydivingSteve
{
    [self compareProgram:@"Skydiving_Steve_095" withProgram:@"Skydiving_Steve_098"];
}

- (void)testTicTacToeMaster
{
    [self compareProgram:@"Tic_Tac_Toe_Master_095" withProgram:@"Tic_Tac_Toe_Master_098"];
}

- (void)testWordBalloonDemo
{
    [self compareProgram:@"Word_balloon_demo_095" withProgram:@"Word_balloon_demo_098"];
}

- (void)testXRayPhone
{
    [self compareProgram:@"X_Ray_phone_095" withProgram:@"X_Ray_phone_098"];
}

- (void)testSolarSystem
{
    [self compareProgram:@"Solar_System_v1.0_092" withProgram:@"Solar_System_v1.0_098"];
}

@end
