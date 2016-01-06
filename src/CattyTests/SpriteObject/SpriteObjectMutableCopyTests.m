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

#import "Program.h"
#import "XMLAbstractTest.h"
#import "CBMutableCopyContext.h"

@interface SpriteObjectMutableCopyTests : XMLAbstractTest

@end

@implementation SpriteObjectMutableCopyTests

- (void)testIfCopiedSpriteObjectsAreEqualToOriginalForValidProgramAllBricks
{
    [self compareSpriteObjectsWithIsEqualMethodForProgramWithXML:@"ValidProgramAllBricks"];
}

- (void)testIfCopiedSpriteObjectsAreEqualToOriginalForAirFight
{
    [self compareSpriteObjectsWithIsEqualMethodForProgramWithXML:@"Air_fight_0.5_093"];
}

- (void)testIfCopiedSpriteObjectsAreEqualToOriginalForAirplaneWithShadow
{
    [self compareSpriteObjectsWithIsEqualMethodForProgramWithXML:@"Airplane_with_shadow_093"];
}

- (void)testIfCopiedSpriteObjectsAreEqualToOriginalForCompass
{
    [self compareSpriteObjectsWithIsEqualMethodForProgramWithXML:@"Compass_0.1_093"];
}

- (void)testIfCopiedSpriteObjectsAreEqualToOriginalForDemonstration
{
    [self compareSpriteObjectsWithIsEqualMethodForProgramWithXML:@"Demonstration_093"];
}

- (void)testIfCopiedSpriteObjectsAreEqualToOriginalForDrinkMoreWater
{
    [self compareSpriteObjectsWithIsEqualMethodForProgramWithXML:@"Drink_more_water_093"];
}

- (void)testIfCopiedSpriteObjectsAreEqualToOriginalForFlappy
{
    [self compareSpriteObjectsWithIsEqualMethodForProgramWithXML:@"Flappy_v3.0_093"];
}

- (void)testIfCopiedSpriteObjectsAreEqualToOriginalForGalaxyWar
{
    [self compareSpriteObjectsWithIsEqualMethodForProgramWithXML:@"Galaxy_War_093"];
}

- (void)testIfCopiedSpriteObjectsAreEqualToOriginalForGossipGirl
{
    [self compareSpriteObjectsWithIsEqualMethodForProgramWithXML:@"Gossip_Girl_093"];
}

- (void)testIfCopiedSpriteObjectsAreEqualToOriginalForMemory
{
    [self compareSpriteObjectsWithIsEqualMethodForProgramWithXML:@"Memory_093"];
}

- (void)testIfCopiedSpriteObjectsAreEqualToOriginalForMinecraftWorkInProgress
{
    [self compareSpriteObjectsWithIsEqualMethodForProgramWithXML:@"Minecraft_Work_In_Progress_093"];
}

- (void)testIfCopiedSpriteObjectsAreEqualToOriginalForMinions
{
    [self compareSpriteObjectsWithIsEqualMethodForProgramWithXML:@"Minions__093"];
}

- (void)testIfCopiedSpriteObjectsAreEqualToOriginalForNyancat
{
    [self compareSpriteObjectsWithIsEqualMethodForProgramWithXML:@"Nyancat_1.0_093"];
}

- (void)testIfCopiedSpriteObjectsAreEqualToOriginalForPiano
{
    [self compareSpriteObjectsWithIsEqualMethodForProgramWithXML:@"Piano_093"];
}

- (void)testIfCopiedSpriteObjectsAreEqualToOriginalForPongStarter
{
    [self compareSpriteObjectsWithIsEqualMethodForProgramWithXML:@"Pong_Starter_093"];
}

- (void)testIfCopiedSpriteObjectsAreEqualToOriginalForPythagoreanTheorem
{
    [self compareSpriteObjectsWithIsEqualMethodForProgramWithXML:@"Pythagorean_Theorem_093"];
}

- (void)testIfCopiedSpriteObjectsAreEqualToOriginalForRockPaperScissors
{
    [self compareSpriteObjectsWithIsEqualMethodForProgramWithXML:@"Rock_paper_scissors_093"];
}

- (void)testIfCopiedSpriteObjectsAreEqualToOriginalForSkyPascal
{
    [self compareSpriteObjectsWithIsEqualMethodForProgramWithXML:@"SKYPASCAL_093"];
}

- (void)testIfCopiedSpriteObjectsAreEqualToOriginalForSkydivingSteve
{
    [self compareSpriteObjectsWithIsEqualMethodForProgramWithXML:@"Skydiving_Steve_093"];
}

- (void)testIfCopiedSpriteObjectsAreEqualToOriginalForTicTacToeMaster
{
    [self compareSpriteObjectsWithIsEqualMethodForProgramWithXML:@"Tic_Tac_Toe_Master_093"];
}

- (void)testIfCopiedSpriteObjectsAreEqualToOriginalForWordBalloonDemo
{
    [self compareSpriteObjectsWithIsEqualMethodForProgramWithXML:@"Word_balloon_demo_093"];
}

- (void)testIfCopiedSpriteObjectsAreEqualToOriginalForXRayPhone
{
    [self compareSpriteObjectsWithIsEqualMethodForProgramWithXML:@"X_Ray_phone_093"];
}

- (void)testIfCopiedSpriteObjectsAreEqualToOriginalForValidFormulaList
{
    [self compareSpriteObjectsWithIsEqualMethodForProgramWithXML:@"ValidFormulaList"];
}

- (void)testIfCopiedSpriteObjectsAreEqualToOriginalForValidProgram
{
    [self compareSpriteObjectsWithIsEqualMethodForProgramWithXML:@"ValidProgram"];
}

- (void)testIfCopiedSpriteObjectsAreEqualToOriginalForFlapPacMan
{
    [self compareSpriteObjectsWithIsEqualMethodForProgramWithXML:@"Flap_Pac_Man_093"];
}

#pragma mark - helpers
- (void)compareSpriteObjectsWithIsEqualMethodForProgramWithXML:(NSString*)xml
{
    Program *program = [self getProgramForXML:xml];
    XCTAssertTrue([program.objectList count] > 0, @"Invalid objectList");
    
    for(SpriteObject *spriteObject in program.objectList) {
        CBMutableCopyContext *context = [CBMutableCopyContext new];
        SpriteObject *copiedSpriteObject = [spriteObject mutableCopyWithContext:context];
        XCTAssertTrue([spriteObject isEqualToSpriteObject:copiedSpriteObject], "SpriteObjects are not equal");
    }
}


@end
