/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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
#import "Program.h"

@interface XMLSerializerBlackBoxTests : XMLAbstractTest

@end

@implementation XMLSerializerBlackBoxTests

- (void)testAirFight
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Air_fight_0.5_098"];
}

- (void)testInvalidAirFight
{
    Program *program095 = [self getProgramForXML:@"Air_fight_0.5_095"];
    SpriteObject *background = (SpriteObject*)[program095.objectList objectAtIndex:0];
    background.name = @"Invalid";
    BOOL equal = [self isProgram:program095 equalToXML:@"Air_fight_0.5_098"];
    XCTAssertFalse(equal, @"Serialized program and XML are not equal");
}

- (void)testAirplaneWithShadow06
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Airplane_with_shadow_098"];
}

- (void)testCompass01
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Compass_0.1_098"];
}

- (void)testDemonstration
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Demonstration_098"];
}

- (void)testDrinkMoreWater
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Drink_more_water_098"];
}

- (void)testEncapsulated
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Encapsulated_098"];
}

- (void)testFlapPacMan
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Flap_Pac_Man_098"];
}

- (void)testFlappy30
{
   [self testParseXMLAndSerializeProgramAndCompareXML:@"Flappy_v3.0_098"];
}

- (void)testGossipGirl
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Gossip_Girl_098"];
}

- (void)testMemory
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Memory_098"];
}

- (void)testMinecraftWorkInProgress
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Minecraft_Work_In_Progress_098"];
}

- (void)testMinions_
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Minions__098"];
}

- (void)testPongStarter
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Pong_Starter_098"];
}

- (void)testRockPaperScissors
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Rock_paper_scissors_098"];
}

- (void)testTicTacToeMaster
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Tic_Tac_Toe_Master_098"];
}

- (void)testWordBalloonDemo
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Word_balloon_demo_098"];
}

- (void)testXRayPhone
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"X_Ray_phone_098"];
}

- (void)testGalaxyWar
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Galaxy_War_098"];
}

- (void)testSkydivingSteve
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Skydiving_Steve_098"];
}

- (void)testPythagoreanTheorem
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Pythagorean_Theorem_098"];
}

- (void)testValidProgramAllBricks
{
    // TODO: test should pass after TurnRightSpeedBrick is implemented
    [self testParseXMLAndSerializeProgramAndCompareXML:@"ValidProgramAllBricks098"];
}

@end
