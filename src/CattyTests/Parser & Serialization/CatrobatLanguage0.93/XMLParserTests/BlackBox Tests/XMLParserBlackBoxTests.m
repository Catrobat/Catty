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
#import "XMLParserAbstractTest.h"
#import "CBXMLParser.h"
#import "Parser.h"

@interface XMLParserBlackBoxTests : XMLParserAbstractTest

@end

@implementation XMLParserBlackBoxTests

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
    [self compareProgram:@"Demonstration_091" withProgram:@"Demonstration_093"];
}

- (void)testDrinkMoreWater
{
    [self compareProgram:@"Drink_more_water_091" withProgram:@"Drink_more_water_093"];
}

- (void)testFlapPacMan
{
    [self compareProgram:@"Flap_Pac_Man_091" withProgram:@"Flap_Pac_Man_093"];
}

- (void)testFlappy30
{
    [self compareProgram:@"Flappy_v3.0_091" withProgram:@"Flappy_v3.0_093"];
}

- (void)testPythagoreanTheoremWithDifferentVersion
{
    [self compareProgram:@"Pythagorean_Theorem_092" withProgram:@"Pythagorean_Theorem_093"];
}

- (void)testGalaxyWarWithDifferentVersion
{
    [self compareProgram:@"Galaxy_War_092" withProgram:@"Galaxy_War_093"];
}

- (void)testSkydivingSteveWithDifferentVersion
{
    [self compareProgram:@"Skydiving_Steve_092" withProgram:@"Skydiving_Steve_093"];
}

@end
