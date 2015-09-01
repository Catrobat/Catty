/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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
#import "BrickTests.h"
#import "WhenScript.h"
#import "Pocket_Code-Swift.h"

@interface TurnRightBrickTests : BrickTests
@end

@implementation TurnRightBrickTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testTurnrightBrick
{
    SpriteObject *object = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    spriteNode.zRotation = 0;

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    TurnRightBrick *brick = [[TurnRightBrick alloc] init];
    brick.script = script;

    Formula *degrees = [[Formula alloc] init];
    FormulaElement *formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"20";
    degrees.formulaTree = formulaTree;
    brick.degrees = degrees;

    dispatch_block_t action = [brick actionBlock];
    action();
    NSLog(@"Rotation: %f", spriteNode.rotation);
    XCTAssertEqualWithAccuracy(spriteNode.rotation, 360.0f + (-20.0f), 0.0001, @"TurnRightBrick not correct");
}

- (void)testTurnrightBrickOver360
{
    SpriteObject *object = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    spriteNode.zRotation = 0;

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    TurnRightBrick *brick = [[TurnRightBrick alloc] init];
    brick.script = script;

    Formula *degrees = [[Formula alloc] init];
    FormulaElement *formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"400";
    degrees.formulaTree = formulaTree;
    brick.degrees = degrees;

    dispatch_block_t action = [brick actionBlock];
    action();
    NSLog(@"Rotation: %f", spriteNode.rotation);
    XCTAssertEqualWithAccuracy(spriteNode.rotation, 360.0f + (-40.0f), 0.0001, @"TurnRightBrick not correct");
}

- (void)testTurnrightBrickNegative
{
    SpriteObject *object = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    spriteNode.zRotation = 0;

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    TurnRightBrick *brick = [[TurnRightBrick alloc] init];
    brick.script = script;

    Formula *degrees = [[Formula alloc] init];
    FormulaElement *formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"-20";
    degrees.formulaTree = formulaTree;
    brick.degrees = degrees;

    dispatch_block_t action = [brick actionBlock];
    action();
    NSLog(@"Rotation: %f", spriteNode.rotation);
    XCTAssertEqualWithAccuracy(spriteNode.rotation, 20.0f, 0.0001, @"TurnRightBrick not correct");
}

- (void)testTurnrightBrickNegativeOver360
{
    SpriteObject *object = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    spriteNode.zRotation = 0;

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    TurnRightBrick *brick = [[TurnRightBrick alloc] init];
    brick.script = script;

    Formula *degrees = [[Formula alloc] init];
    FormulaElement *formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"-400";
    degrees.formulaTree = formulaTree;
    brick.degrees = degrees;

    dispatch_block_t action = [brick actionBlock];
    action();
    NSLog(@"Rotation: %f", spriteNode.rotation);
    XCTAssertEqualWithAccuracy(spriteNode.rotation, 40.0f, 0.0001, @"TurnRightBrick not correct");
}

- (void)testTurnrightBrickWrongInput
{
    SpriteObject *object = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    spriteNode.zRotation = 0;

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    TurnRightBrick *brick = [[TurnRightBrick alloc] init];
    brick.script = script;

    Formula *degrees = [[Formula alloc] init];
    FormulaElement *formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"a";
    degrees.formulaTree = formulaTree;
    brick.degrees = degrees;

    dispatch_block_t action = [brick actionBlock];
    action();
    NSLog(@"Rotation: %f", spriteNode.rotation);
    XCTAssertEqualWithAccuracy(spriteNode.rotation, 0.0, 0.0001, @"TurnRightBrick not correct");
}

@end
