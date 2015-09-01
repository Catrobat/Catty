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

@interface ChangeSizeByNBrickTests : BrickTests
@end

@implementation ChangeSizeByNBrickTests

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

- (void)testChangeSizeByNBrickPositive
{
    SpriteObject* object = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    spriteNode.xScale = 10;
    spriteNode.yScale = 10;

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    ChangeSizeByNBrick* brick = [[ChangeSizeByNBrick alloc] init];
    brick.script = script;

    Formula* size = [[Formula alloc] init];
    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"30";
    size.formulaTree = formulaTree;
    brick.size = size;

    dispatch_block_t action = [brick actionBlock];
    action();

    XCTAssertEqualWithAccuracy([spriteNode scaleX], 1030.0f, 0.0001, @"X - Scale not correct");
    XCTAssertEqualWithAccuracy([spriteNode scaleY], 1030.0f, 0.0001, @"Y - Scale not correct");
}

- (void)testChangeSizeByNBrickNegative
{
    SpriteObject* object = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    spriteNode.xScale = 10;
    spriteNode.yScale = 10;

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    ChangeSizeByNBrick* brick = [[ChangeSizeByNBrick alloc] init];
    brick.script = script;

    Formula* size = [[Formula alloc] init];
    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"-30";
    size.formulaTree = formulaTree;
    brick.size = size;

    dispatch_block_t action = [brick actionBlock];
    action();

    XCTAssertEqualWithAccuracy(spriteNode.scaleX, 970.0f, 0.0001, @"X - Scale not correct");
    XCTAssertEqualWithAccuracy(spriteNode.scaleY, 970.0f, 0.0001, @"Y - Scale not correct");
}

- (void)testChangeSizeByNBrickWrongInput
{
    SpriteObject *object = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    spriteNode.xScale = 10;
    spriteNode.yScale = 10;

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    ChangeSizeByNBrick *brick = [[ChangeSizeByNBrick alloc] init];
    brick.script = script;

    Formula *size = [[Formula alloc] init];
    FormulaElement *formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"a";
    size.formulaTree = formulaTree;
    brick.size = size;

    dispatch_block_t action = [brick actionBlock];
    action();

    XCTAssertEqualWithAccuracy([spriteNode scaleX], 1000.0f, 0.0001, @"X - Scale not correct");
    XCTAssertEqualWithAccuracy([spriteNode scaleY], 1000.0f, 0.0001, @"Y - Scale not correct");
}

@end
