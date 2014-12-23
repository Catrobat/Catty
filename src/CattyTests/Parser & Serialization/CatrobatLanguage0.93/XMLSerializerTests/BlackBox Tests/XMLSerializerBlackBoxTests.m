/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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
#import "XMLSerializerAbstractTest.h"
#import "Program.h"

@interface XMLSerializerBlackBoxTests : XMLSerializerAbstractTest

@end

@implementation XMLSerializerBlackBoxTests

- (void)testAirFight05
{
    Program *program093 = [self getProgramForXML:@"Air_fight_0.5_093"];
    [super saveProgram:program093]; // TODO: mustn't use saveToDisk! never throws exceptions => test always succeeds...
}

- (void)testAirplaneWithShadow
{
    Program *program093 = [self getProgramForXML:@"Airplane_with_shadow_093"];
    [super saveProgram:program093]; // TODO: mustn't use saveToDisk! never throws exceptions => test always succeeds...
}

- (void)testCompass01
{
    Program *program093 = [self getProgramForXML:@"Compass_0.1_093"];
    [super saveProgram:program093]; // TODO: mustn't use saveToDisk! never throws exceptions => test always succeeds...
}

- (void)testDemonstration
{
    Program *program093 = [self getProgramForXML:@"Demonstration_093"];
    [super saveProgram:program093]; // TODO: mustn't use saveToDisk! never throws exceptions => test always succeeds...
}

- (void)testDrinkMoreWater
{
    Program *program093 = [self getProgramForXML:@"Drink_more_water_093"];
    [super saveProgram:program093]; // TODO: mustn't use saveToDisk! never throws exceptions => test always succeeds...
}

- (void)testEncapsulated
{
    Program *program093 = [self getProgramForXML:@"Encapsulated"];
    [super saveProgram:program093]; // TODO: mustn't use saveToDisk! never throws exceptions => test always succeeds...
}

- (void)testFlapPacMan
{
    Program *program093 = [self getProgramForXML:@"Flap_Pac_Man_093"];
    [super saveProgram:program093]; // TODO: mustn't use saveToDisk! never throws exceptions => test always succeeds...
}

- (void)testFlappy30
{
    Program *program093 = [self getProgramForXML:@"Flappy_v3.0_093"];
    [super saveProgram:program093]; // TODO: mustn't use saveToDisk! never throws exceptions => test always succeeds...
}

- (void)testGalaxyWar
{
    Program *program093 = [self getProgramForXML:@"Galaxy_War_093"];
    [super saveProgram:program093]; // TODO: mustn't use saveToDisk! never throws exceptions => test always succeeds...
}

- (void)testGossipGirl
{
    Program *program093 = [self getProgramForXML:@"Gossip_Girl_093"];
    [super saveProgram:program093]; // TODO: mustn't use saveToDisk! never throws exceptions => test always succeeds...
}

- (void)testMemory
{
    Program *program093 = [self getProgramForXML:@"Memory_093"];
    [super saveProgram:program093]; // TODO: mustn't use saveToDisk! never throws exceptions => test always succeeds...
}

- (void)testMinecraftWorkInProgress
{
    Program *program093 = [self getProgramForXML:@"Minecraft_Work_In_Progress_093"];
    [super saveProgram:program093]; // TODO: mustn't use saveToDisk! never throws exceptions => test always succeeds...
}

- (void)testMinions_
{
    Program *program093 = [self getProgramForXML:@"Minions__093"];
    [super saveProgram:program093]; // TODO: mustn't use saveToDisk! never throws exceptions => test always succeeds...
}

- (void)testNyancat10
{
    Program *program093 = [self getProgramForXML:@"Nyancat_1.0_093"];
    [super saveProgram:program093]; // TODO: mustn't use saveToDisk! never throws exceptions => test always succeeds...
}

- (void)testPiano
{
    Program *program093 = [self getProgramForXML:@"Piano_093"];
    [super saveProgram:program093]; // TODO: mustn't use saveToDisk! never throws exceptions => test always succeeds...
}

- (void)testPongStarter
{
    Program *program093 = [self getProgramForXML:@"Pong_Starter_093"];
    [super saveProgram:program093]; // TODO: mustn't use saveToDisk! never throws exceptions => test always succeeds...
}

- (void)testPythagoreanTheorem
{
    Program *program093 = [self getProgramForXML:@"Pythagorean_Theorem_093"];
    [super saveProgram:program093]; // TODO: mustn't use saveToDisk! never throws exceptions => test always succeeds...
}

- (void)testRockPaperScissors
{
    Program *program093 = [self getProgramForXML:@"Rock_paper_scissors_093"];
    [super saveProgram:program093]; // TODO: mustn't use saveToDisk! never throws exceptions => test always succeeds...
}

- (void)testSkyPascal
{
    Program *program093 = [self getProgramForXML:@"SKYPASCAL_093"];
    [super saveProgram:program093]; // TODO: mustn't use saveToDisk! never throws exceptions => test always succeeds...
}

- (void)testSkydivingSteve
{
    Program *program093 = [self getProgramForXML:@"Skydiving_Steve_093"];
    [super saveProgram:program093]; // TODO: mustn't use saveToDisk! never throws exceptions => test always succeeds...
}

- (void)testTicTacToeMaster
{
    Program *program093 = [self getProgramForXML:@"Tic_Tac_Toe_Master_093"];
    [super saveProgram:program093]; // TODO: mustn't use saveToDisk! never throws exceptions => test always succeeds...
}

- (void)testWordBalloonDemo
{
    Program *program093 = [self getProgramForXML:@"Word_balloon_demo_093"];
    [super saveProgram:program093]; // TODO: mustn't use saveToDisk! never throws exceptions => test always succeeds...
}

- (void)testXRayPhone
{
    Program *program093 = [self getProgramForXML:@"X_Ray_phone_093"];
    [super saveProgram:program093]; // TODO: mustn't use saveToDisk! never throws exceptions => test always succeeds...
}

- (void)testValidProgramAllBricks
{
    Program *program093 = [self getProgramForXML:@"ValidProgramAllBricks"];
    [super saveProgram:program093]; // TODO: mustn't use saveToDisk! never throws exceptions => test always succeeds...
}

@end
