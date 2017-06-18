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

@interface XMLParserBlackBoxTests0991 : XMLAbstractTest

@end

@implementation XMLParserBlackBoxTests0991

- (void)testAirFight
{
    [self compareProgram:@"Air_fight_0.5_095" withProgram:@"Air_fight_0.5_0991"];
}

- (void)testAirplaneWithShadow
{
    [self compareProgram:@"Airplane_with_shadow_095" withProgram:@"Airplane_with_shadow_0991"];
}

- (void)testCompass01
{
    [self compareProgram:@"Compass_0.1_095" withProgram:@"Compass_0.1_0991"];
}

- (void)testDemonstration
{
    [self compareProgram:@"Demonstration_095" withProgram:@"Demonstration_0991"];
}

- (void)testDrinkMoreWater
{
    [self compareProgram:@"Drink_more_water_095" withProgram:@"Drink_more_water_0991"];
}

- (void)testFlapPacMan
{
    [self compareProgram:@"Flap_Pac_Man_095" withProgram:@"Flap_Pac_Man_0991"];
}

- (void)testFlappy30
{
    [self compareProgram:@"Flappy_v3.0_095" withProgram:@"Flappy_v3.0_0991"];
}

- (void)testGalaxyWar
{
    [self compareProgram:@"Galaxy_War_095" withProgram:@"Galaxy_War_0991"];
}

- (void)testGossipGirl
{
    [self compareProgram:@"Gossip_Girl_095" withProgram:@"Gossip_Girl_0991"];
}

- (void)testMemory
{
    [self compareProgram:@"Memory_095" withProgram:@"Memory_0991"];
}

- (void)testMinecraftWorkInProgress
{
    [self compareProgram:@"Minecraft_Work_In_Progress_095" withProgram:@"Minecraft_Work_In_Progress_0991"];
}

- (void)testMinions_
{
    [self compareProgram:@"Minions__095" withProgram:@"Minions__0991"];
}

- (void)testNyancat10
{
    [self compareProgram:@"Nyancat_1.0_093" withProgram:@"Nyancat_1.0_0991"];
}

- (void)testPiano
{
    [self compareProgram:@"Piano_093" withProgram:@"Piano_0991"];
}

- (void)testPongStarter
{
    [self compareProgram:@"Pong_Starter_095" withProgram:@"Pong_Starter_0991"];
}

- (void)testPythagoreanTheorem
{
    [self compareProgram:@"Pythagorean_Theorem_095" withProgram:@"Pythagorean_Theorem_0991"];
}

- (void)testRockPaperScissors
{
    [self compareProgram:@"Rock_paper_scissors_095" withProgram:@"Rock_paper_scissors_0991"];
}

- (void)testSkydivingSteve
{
    [self compareProgram:@"Skydiving_Steve_095" withProgram:@"Skydiving_Steve_0991"];
}

- (void)testTicTacToeMaster
{
    [self compareProgram:@"Tic_Tac_Toe_Master_095" withProgram:@"Tic_Tac_Toe_Master_0991"];
}

- (void)testWordBalloonDemo
{
    [self compareProgram:@"Word_balloon_demo_095" withProgram:@"Word_balloon_demo_0991"];
}

- (void)testXRayPhone
{
    [self compareProgram:@"X_Ray_phone_095" withProgram:@"X_Ray_phone_0991"];
}

- (void)testSolarSystem
{
    [self compareProgram:@"Solar_System_v1.0_092" withProgram:@"Solar_System_v1.0_0991"];
}

@end
