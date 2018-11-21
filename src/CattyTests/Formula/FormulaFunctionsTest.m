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
#import "Formula.h"
#import "FormulaElement.h"
#import "Util.h"
#import "Pocket_Code-Swift.h"

@interface FormulaFunctionsTest : XCTestCase
@property (nonatomic, strong) FormulaManager *formulaManager;
@property (nonatomic, strong) SpriteObject *spriteObject;
@end

@implementation FormulaFunctionsTest

const double EPSILON = 0.001;

- (void)setUp
{
    self.formulaManager = [[FormulaManager alloc] initWithSceneSize:[Util screenSize:true]];
    self.spriteObject = [SpriteObject new];
}

- (Formula*)getFormulaForFunction:(NSString*)tag WithLeftValue:(NSString*)leftValue AndRightValue:(NSString*)rightValue
{
    FormulaElement *leftElement = [[FormulaElement alloc] initWithType:@"NUMBER" value:leftValue leftChild:nil rightChild:nil parent:nil];
    FormulaElement *rightElement = nil;
    
    if(rightValue != nil)
        rightElement = [[FormulaElement alloc] initWithType:@"NUMBER" value:rightValue leftChild:nil rightChild:nil parent:nil];
    
    FormulaElement *formulaElement = [[FormulaElement alloc] initWithType:@"FUNCTION" value:tag leftChild:leftElement rightChild:rightElement parent:nil];
    
    Formula *formula = [[Formula alloc] initWithFormulaElement:formulaElement];
    return formula;
}

- (void)testSin
{
    Formula *formula = [self getFormulaForFunction:@"SIN" WithLeftValue:@"0" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(0, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for sin(0)");
    
    formula = [self getFormulaForFunction:@"SIN" WithLeftValue:@"90" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(1, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for sin(90)");
    
    formula = [self getFormulaForFunction:@"SIN" WithLeftValue:@"-90" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(-1, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for sin(-90)");
    
    formula = [self getFormulaForFunction:@"SIN" WithLeftValue:@"180" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(0, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for sin(180)");
    
    formula = [self getFormulaForFunction:@"SIN" WithLeftValue:@"-180" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(0, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for sin(-180)");
    
    formula = [self getFormulaForFunction:@"SIN" WithLeftValue:@"360" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(0, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for sin(360)");
    
    formula = [self getFormulaForFunction:@"SIN" WithLeftValue:@"750" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(0.5, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for sin(750)");
    
    formula = [self getFormulaForFunction:@"SIN" WithLeftValue:@"-750" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(-0.5, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for sin(-750)");
}

- (void)testCos
{
    Formula *formula = [self getFormulaForFunction:@"COS" WithLeftValue:@"0" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(1, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for cos(0)");

    formula = [self getFormulaForFunction:@"COS" WithLeftValue:@"90" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(0, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for cos(90)");
    
    formula = [self getFormulaForFunction:@"COS" WithLeftValue:@"-90" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(0, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for cos(-90)");
    
    formula = [self getFormulaForFunction:@"COS" WithLeftValue:@"180" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(-1, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for cos(180)");
    
    formula = [self getFormulaForFunction:@"COS" WithLeftValue:@"-180" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(-1, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for cos(-180)");
    
    formula = [self getFormulaForFunction:@"COS" WithLeftValue:@"360" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(1, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for cos(360)");

    formula = [self getFormulaForFunction:@"COS" WithLeftValue:@"-360" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(1, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for cos(-360)");

    formula = [self getFormulaForFunction:@"COS" WithLeftValue:@"750" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(0.86602540378, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for cos(750)");
    
    formula = [self getFormulaForFunction:@"COS" WithLeftValue:@"-750" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(0.86602540378, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for cos(-750)");
}

- (void)testTan
{
    Formula *formula = [self getFormulaForFunction:@"TAN" WithLeftValue:@"0" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(0, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for tan(0)");
    
    // for tan(90) see http://math.stackexchange.com/questions/536144/why-does-the-google-calculator-give-tan-90-degrees-1-6331779e16
    formula = [self getFormulaForFunction:@"TAN" WithLeftValue:@"90" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(1.633123935319537 * pow(10,16), [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for tan(90)");
    //XCTAssertEqualWithAccuracy(tan(1.57079637), [[formula interpretRecursiveForSprite:nil]doubleValue], EPSILON, @"Wrong result for tan(90)");
    
    formula = [self getFormulaForFunction:@"TAN" WithLeftValue:@"-90" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(-1.633123935319537 * pow(10,16), [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for tan(-90)");
    
    formula = [self getFormulaForFunction:@"TAN" WithLeftValue:@"180" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(0, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for tan(180)");
    
    formula = [self getFormulaForFunction:@"TAN" WithLeftValue:@"-180" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(0, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for tan(-180)");
    
    formula = [self getFormulaForFunction:@"TAN" WithLeftValue:@"360" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(0, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for tan(360)");
    
    formula = [self getFormulaForFunction:@"TAN" WithLeftValue:@"-360" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(0, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for tan(-360)");
    
    formula = [self getFormulaForFunction:@"TAN" WithLeftValue:@"750" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(0.57735026919, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for tan(750)");
    
    formula = [self getFormulaForFunction:@"TAN" WithLeftValue:@"-750" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(-0.57735026919, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for tan(-750)");
}

- (void)testArcSin
{
    Formula *formula = [self getFormulaForFunction:@"ASIN" WithLeftValue:@"0" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(0, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for arcsin(0)");
    
    double sin90 = sin([Util degreeToRadians:90]);
    formula = [self getFormulaForFunction:@"ASIN" WithLeftValue:[NSString stringWithFormat:@"%f", sin90] AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(90, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for arcsin(sin(90))");
    
    double sinMinus90 = sin([Util degreeToRadians:-90]);
    formula = [self getFormulaForFunction:@"ASIN" WithLeftValue:[NSString stringWithFormat:@"%f", sinMinus90] AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(-90, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for arcsin(sin(-90))");
    
    formula = [self getFormulaForFunction:@"ASIN" WithLeftValue:@"1.5" AndRightValue:nil]; // TODO use Function property
    double result = [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject];
    XCTAssertTrue(isnan(result), @"Wrong result for arcsin(1.5)");
}

- (void)testArcCos
{
    Formula *formula = [self getFormulaForFunction:@"ACOS" WithLeftValue:@"0" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(90, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for arccos(0)");
    
    formula = [self getFormulaForFunction:@"ACOS" WithLeftValue:@"1" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(0, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for arccos(1)");
    
    formula = [self getFormulaForFunction:@"ACOS" WithLeftValue:@"-1" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(180, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for arccos(-1)");
    
    double cos90 = cos([Util degreeToRadians:90]);
    formula = [self getFormulaForFunction:@"ACOS" WithLeftValue:[NSString stringWithFormat:@"%f", cos90] AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(90, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for arccos(cos(90))");
    
    double cos180 = cos([Util degreeToRadians:180]);
    formula = [self getFormulaForFunction:@"ACOS" WithLeftValue:[NSString stringWithFormat:@"%f", cos180] AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(180, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for arccos(cos(180))");
    
    formula = [self getFormulaForFunction:@"ACOS" WithLeftValue:@"1.5" AndRightValue:nil]; // TODO use Function property
    double result = [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject];
    XCTAssertTrue(isnan(result), @"Wrong result for arccos(1.5)");
}

- (void)testArcTan
{
    Formula *formula = [self getFormulaForFunction:@"ATAN" WithLeftValue:@"0" AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(0, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for arctan(0)");
    
    double tan60 = tan([Util degreeToRadians:60]);
    formula = [self getFormulaForFunction:@"ATAN" WithLeftValue:[NSString stringWithFormat:@"%f", tan60] AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(60, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for arctan(tan(60))");
    
    double tanMinus60 = tan([Util degreeToRadians:-60]);
    formula = [self getFormulaForFunction:@"ATAN" WithLeftValue:[NSString stringWithFormat:@"%f", tanMinus60] AndRightValue:nil]; // TODO use Function property
    XCTAssertEqualWithAccuracy(-60, [self.formulaManager interpretDouble:formula forSpriteObject:self.spriteObject], EPSILON, @"Wrong result for arctan(tan(-60))");
}

@end
