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
#import "Formula.h"
#import "FormulaElement.h"
#import "Util.h"
#import "Math.h"

@interface FormulaFunctionsTest : XCTestCase

@end

@implementation FormulaFunctionsTest

const double DELTA = 0.001;

- (FormulaElement*)getFormulaElementForFunction:(Function)function WithLeftValue:(NSString*)leftValue AndRightValue:(NSString*)rightValue
{
    FormulaElement *leftElement = [[FormulaElement alloc] initWithType:@"NUMBER" value:leftValue leftChild:nil rightChild:nil parent:nil];
    FormulaElement *rightElement = nil;
    
    if(rightValue != nil)
        rightElement = [[FormulaElement alloc] initWithType:@"NUMBER" value:rightValue leftChild:nil rightChild:nil parent:nil];
    
    FormulaElement *formula = [[FormulaElement alloc] initWithType:@"FUNCTION" value:[Functions getName:function] leftChild:leftElement rightChild:rightElement parent:nil];
    
    return formula;
}

- (void)testSin
{
    FormulaElement *formula = [self getFormulaElementForFunction:SIN WithLeftValue:@"0" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(0, [[formula interpretRecursiveForSprite:nil] doubleValue], DELTA, @"Wrong result for sin(0)");
    
    formula = [self getFormulaElementForFunction:SIN WithLeftValue:@"90" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(1, [[formula interpretRecursiveForSprite:nil] doubleValue], DELTA, @"Wrong result for sin(90)");
    
    formula = [self getFormulaElementForFunction:SIN WithLeftValue:@"-90" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(-1, [[formula interpretRecursiveForSprite:nil] doubleValue], DELTA, @"Wrong result for sin(-90)");
    
    formula = [self getFormulaElementForFunction:SIN WithLeftValue:@"180" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(0, [[formula interpretRecursiveForSprite:nil] doubleValue], DELTA, @"Wrong result for sin(180)");
    
    formula = [self getFormulaElementForFunction:SIN WithLeftValue:@"-180" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(0, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for sin(-180)");
    
    formula = [self getFormulaElementForFunction:SIN WithLeftValue:@"360" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(0, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for sin(360)");
    
    formula = [self getFormulaElementForFunction:SIN WithLeftValue:@"750" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(0.5, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for sin(750)");
    
    formula = [self getFormulaElementForFunction:SIN WithLeftValue:@"-750" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(-0.5, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for sin(-750)");
    
}

- (void)testCos
{
    FormulaElement *formula = [self getFormulaElementForFunction:COS WithLeftValue:@"0" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(1, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for cos(0)");

    formula = [self getFormulaElementForFunction:COS WithLeftValue:@"90" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(0, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for cos(90)");
    
    formula = [self getFormulaElementForFunction:COS WithLeftValue:@"-90" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(0, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for cos(-90)");
    
    formula = [self getFormulaElementForFunction:COS WithLeftValue:@"180" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(-1, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for cos(180)");
    
    formula = [self getFormulaElementForFunction:COS WithLeftValue:@"-180" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(-1, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for cos(-180)");
    
    formula = [self getFormulaElementForFunction:COS WithLeftValue:@"360" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(1, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for cos(360)");

    formula = [self getFormulaElementForFunction:COS WithLeftValue:@"-360" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(1, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for cos(-360)");

    formula = [self getFormulaElementForFunction:COS WithLeftValue:@"750" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(0.86602540378, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for cos(750)");
    
    formula = [self getFormulaElementForFunction:COS WithLeftValue:@"-750" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(0.86602540378, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for cos(-750)");
}

- (void)testTan
{
    FormulaElement *formula = [self getFormulaElementForFunction:TAN WithLeftValue:@"0" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(0, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for tan(0)");
    
    // for tan(90) see http://math.stackexchange.com/questions/536144/why-does-the-google-calculator-give-tan-90-degrees-1-6331779e16
    formula = [self getFormulaElementForFunction:TAN WithLeftValue:@"90" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(1.633123935319537 * pow(10,16), [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for tan(90)");
    //XCTAssertEqualWithAccuracy(tan(1.57079637), [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for tan(90)");
    
    formula = [self getFormulaElementForFunction:TAN WithLeftValue:@"-90" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(-1.633123935319537 * pow(10,16), [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for tan(-90)");
    
    formula = [self getFormulaElementForFunction:TAN WithLeftValue:@"180" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(0, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for tan(180)");
    
    formula = [self getFormulaElementForFunction:TAN WithLeftValue:@"-180" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(0, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for tan(-180)");
    
    formula = [self getFormulaElementForFunction:TAN WithLeftValue:@"360" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(0, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for tan(360)");
    
    formula = [self getFormulaElementForFunction:TAN WithLeftValue:@"-360" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(0, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for tan(-360)");
    
    formula = [self getFormulaElementForFunction:TAN WithLeftValue:@"750" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(0.57735026919, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for tan(750)");
    
    formula = [self getFormulaElementForFunction:TAN WithLeftValue:@"-750" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(-0.57735026919, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for tan(-750)");
}

- (void)testArcSin
{
    FormulaElement *formula = [self getFormulaElementForFunction:ARCSIN WithLeftValue:@"0" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(0, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for arcsin(0)");
    
    double sin90 = sin([Util degreeToRadians:90]);
    formula = [self getFormulaElementForFunction:ARCSIN WithLeftValue:[NSString stringWithFormat:@"%f", sin90] AndRightValue:nil];
    XCTAssertEqualWithAccuracy(90, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for arcsin(sin(90))");
    
    double sinMinus90 = sin([Util degreeToRadians:-90]);
    formula = [self getFormulaElementForFunction:ARCSIN WithLeftValue:[NSString stringWithFormat:@"%f", sinMinus90] AndRightValue:nil];
    XCTAssertEqualWithAccuracy(-90, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for arcsin(sin(-90))");
    
    formula = [self getFormulaElementForFunction:ARCSIN WithLeftValue:@"1.5" AndRightValue:nil];
    double result = [[formula interpretRecursiveForSprite:nil]doubleValue];
    XCTAssertTrue(isnan(result), @"Wrong result for arcsin(1.5)");
}

- (void)testArcCos
{
    FormulaElement *formula = [self getFormulaElementForFunction:ARCCOS WithLeftValue:@"0" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(90, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for arccos(0)");
    
    formula = [self getFormulaElementForFunction:ARCCOS WithLeftValue:@"1" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(0, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for arccos(1)");
    
    formula = [self getFormulaElementForFunction:ARCCOS WithLeftValue:@"-1" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(180, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for arccos(-1)");
    
    double cos90 = cos([Util degreeToRadians:90]);
    formula = [self getFormulaElementForFunction:ARCCOS WithLeftValue:[NSString stringWithFormat:@"%f", cos90] AndRightValue:nil];
    XCTAssertEqualWithAccuracy(90, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for arccos(cos(90))");
    
    double cos180 = cos([Util degreeToRadians:180]);
    formula = [self getFormulaElementForFunction:ARCCOS WithLeftValue:[NSString stringWithFormat:@"%f", cos180] AndRightValue:nil];
    XCTAssertEqualWithAccuracy(180, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for arccos(cos(180))");
    
    formula = [self getFormulaElementForFunction:ARCCOS WithLeftValue:@"1.5" AndRightValue:nil];
    double result = [[formula interpretRecursiveForSprite:nil]doubleValue];
    XCTAssertTrue(isnan(result), @"Wrong result for arccos(1.5)");
}

- (void)testArcTan
{
    FormulaElement *formula = [self getFormulaElementForFunction:ARCTAN WithLeftValue:@"0" AndRightValue:nil];
    XCTAssertEqualWithAccuracy(0, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for arctan(0)");
    
    double tan60 = tan([Util degreeToRadians:60]);
    formula = [self getFormulaElementForFunction:ARCTAN WithLeftValue:[NSString stringWithFormat:@"%f", tan60] AndRightValue:nil];
    XCTAssertEqualWithAccuracy(60, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for arctan(tan(60))");
    
    double tanMinus60 = tan([Util degreeToRadians:-60]);
    formula = [self getFormulaElementForFunction:ARCTAN WithLeftValue:[NSString stringWithFormat:@"%f", tanMinus60] AndRightValue:nil];
    XCTAssertEqualWithAccuracy(-60, [[formula interpretRecursiveForSprite:nil]doubleValue], DELTA, @"Wrong result for arctan(tan(-60))");
}

@end
