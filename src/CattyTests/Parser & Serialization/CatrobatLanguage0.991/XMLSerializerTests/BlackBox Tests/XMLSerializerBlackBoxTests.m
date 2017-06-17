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
#import "Program.h"

@interface XMLSerializerBlackBoxTests : XMLAbstractTest

@end

@implementation XMLSerializerBlackBoxTests

- (void)testAirFight
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Air_fight_0.5_0991"];
}

- (void)testInvalidAirFight
{
    Program *program095 = [self getProgramForXML:@"Air_fight_0.5_095"];
    SpriteObject *background = (SpriteObject*)[program095.objectList objectAtIndex:0];
    background.name = @"Invalid";
    BOOL equal = [self isProgram:program095 equalToXML:@"Air_fight_0.5_0991"];
    XCTAssertFalse(equal, @"Serialized program and XML are not equal");
}

- (void)testAirplaneWithShadow06
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Airplane_with_shadow_0991"];
}

- (void)testCompass01
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Compass_0.1_0991"];
}

- (void)testDemonstration
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Demonstration_0991"];
}

- (void)testDrinkMoreWater
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Drink_more_water_0991"];
}

- (void)testEncapsulated
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Encapsulated_0991"];
}

- (void)testFlapPacMan
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Flap_Pac_Man_0991"];
}

- (void)testFlappy30
{
   [self testParseXMLAndSerializeProgramAndCompareXML:@"Flappy_v3.0_0991"];
}

- (void)testGossipGirl
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Gossip_Girl_0991"];
}

- (void)testMemory
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Memory_0991"];
}

- (void)testMinecraftWorkInProgress
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Minecraft_Work_In_Progress_0991"];
}

- (void)testMinions_
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Minions__0991"];
}

- (void)testPongStarter
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Pong_Starter_0991"];
}

- (void)testRockPaperScissors
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Rock_paper_scissors_0991"];
}

- (void)testTicTacToeMaster
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Tic_Tac_Toe_Master_0991"];
}

- (void)testWordBalloonDemo
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Word_balloon_demo_0991"];
}

- (void)testXRayPhone
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"X_Ray_phone_0991"];
}

- (void)testGalaxyWar
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Galaxy_War_0991"];
}

- (void)testSkydivingSteve
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Skydiving_Steve_0991"];
}

- (void)testPythagoreanTheorem
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"Pythagorean_Theorem_0991"];
}

- (void)testValidProgramAllBricks
{
    [self testParseXMLAndSerializeProgramAndCompareXML:@"ValidProgramAllBricks0991"];
}

@end
