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
#import "AbstractBrickTests.h"
#import "WhenScript.h"
#import "Pocket_Code-Swift.h"

@interface SetXBrickTests : AbstractBrickTests
@end

@implementation SetXBrickTests

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

- (void)testSetXBrickPositive
{
    SpriteObject *object = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    CBScene *scene = [[CBScene alloc] init];
    [scene addChild:spriteNode];
    spriteNode.catrobatPosition = CGPointMake(0, 0);

    Formula *xPosition = [[Formula alloc] init];
    FormulaElement *formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"20";
    xPosition.formulaTree = formulaTree;

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    SetXBrick *brick = [[SetXBrick alloc]init];
    brick.script = script;
    brick.xPosition = xPosition;

    dispatch_block_t action = [brick actionBlock];
    action();
    XCTAssertEqual(spriteNode.catrobatPosition.x, (CGFloat)20, @"SetxBrick is not correctly calculated");
}

- (void)testSetXBrickNegative
{
    SpriteObject* object = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    CBScene *scene = [[CBScene alloc] init];
    [scene addChild:spriteNode];
    spriteNode.catrobatPosition = CGPointMake(0, 0);

    Formula* xPosition =[[Formula alloc] init];
    FormulaElement* formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"-20";
    xPosition.formulaTree = formulaTree;

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    SetXBrick* brick = [[SetXBrick alloc]init];
    brick.script = script;
    brick.xPosition = xPosition;

    dispatch_block_t action = [brick actionBlock];
    action();
    XCTAssertEqual(spriteNode.catrobatPosition.x, (CGFloat)-20, @"SetxBrick is not correctly calculated");
}

- (void)testSetXBrickOutOfRange
{
    SpriteObject* object = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    CBScene *scene = [[CBScene alloc] init];
    [scene addChild:spriteNode];
    spriteNode.catrobatPosition = CGPointMake(0, 0);

    Formula *xPosition =[[Formula alloc] init];
    FormulaElement *formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"50000";
    xPosition.formulaTree = formulaTree;

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    SetXBrick* brick = [[SetXBrick alloc]init];
    brick.script = script;
    brick.xPosition = xPosition;

    dispatch_block_t action = [brick actionBlock];
    action();
    XCTAssertEqual(spriteNode.catrobatPosition.x, (CGFloat)50000, @"SetxBrick is not correctly calculated");
}

- (void)testSetXBrickWrongInput
{
    SpriteObject* object = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    CBScene *scene = [[CBScene alloc] init];
    [scene addChild:spriteNode];
    spriteNode.catrobatPosition = CGPointMake(0, 0);

    Formula* xPosition =[[Formula alloc] init];
    FormulaElement* formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"a";
    xPosition.formulaTree = formulaTree;

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    SetXBrick* brick = [[SetXBrick alloc]init];
    brick.script = script;
    brick.xPosition = xPosition;

    dispatch_block_t action = [brick actionBlock];
    action();
    XCTAssertEqual(spriteNode.catrobatPosition.x, (CGFloat)0, @"SetxBrick is not correctly calculated");
}

@end
