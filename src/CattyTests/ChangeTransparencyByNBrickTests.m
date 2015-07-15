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

@interface ChangeTransparencyByNBrickTests : BrickTests
@end

@implementation ChangeTransparencyByNBrickTests

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

- (void)testChangeGhostEffectByNBrickPositive
{
    SpriteObject *object = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    spriteNode = spriteNode;
    CBPlayerScene *scene = [[CBPlayerScene alloc] init];
    [scene addChild:spriteNode];
    spriteNode.scenePosition = CGPointMake(0, 0);

    Formula* transparency =[[Formula alloc] init];
    FormulaElement* formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"20";
    transparency.formulaTree = formulaTree;

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    ChangeTransparencyByNBrick *brick = [[ChangeTransparencyByNBrick alloc]init];
    brick.script = script;
    brick.changeGhostEffect = transparency;

    dispatch_block_t action = [brick actionBlock];
    action();
    XCTAssertEqual(spriteNode.alpha, 0.8f, @"ChangeGhostEffectBrick is not correctly calculated");
}


- (void)testChangeGhostEffectByNBrickNegative
{
    SpriteObject* object = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    CBPlayerScene *scene = [[CBPlayerScene alloc] init];
    [scene addChild:spriteNode];
    spriteNode.scenePosition = CGPointMake(0, 0);
    spriteNode.alpha = 0.4;

    Formula *transparency =[[Formula alloc] init];
    FormulaElement *formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"-20";
    transparency.formulaTree = formulaTree;

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    ChangeTransparencyByNBrick *brick = [[ChangeTransparencyByNBrick alloc]init];
    brick.script = script;
    brick.changeGhostEffect = transparency;

    dispatch_block_t action = [brick actionBlock];
    action();
    XCTAssertEqual(spriteNode.alpha, 0.6f, @"ChangeGhostEffectBrick is not correctly calculated");
}


- (void)testChangeGhostEffectByNBrickOutOfRange
{
    SpriteObject* object = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    CBPlayerScene *scene = [[CBPlayerScene alloc] init];
    [scene addChild:spriteNode];
    spriteNode.scenePosition = CGPointMake(0, 0);
    spriteNode.alpha = 0.4;

    Formula* transparency =[[Formula alloc] init];
    FormulaElement* formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"150";
    transparency.formulaTree = formulaTree;

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    ChangeTransparencyByNBrick *brick = [[ChangeTransparencyByNBrick alloc]init];
    brick.script = script;
    brick.changeGhostEffect = transparency;

    dispatch_block_t action = [brick actionBlock];
    action();
    XCTAssertEqual(spriteNode.alpha, 0.0f, @"ChangeGhostEffectBrick is not correctly calculated");
}

- (void)testChangeGhostEffectByNBrickWrongInput
{
    SpriteObject* object = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    CBPlayerScene *scene = [[CBPlayerScene alloc] init];
    [scene addChild:spriteNode];
    spriteNode.scenePosition = CGPointMake(0, 0);

    Formula* transparency =[[Formula alloc] init];
    FormulaElement* formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"a";
    transparency.formulaTree = formulaTree;

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    ChangeTransparencyByNBrick *brick = [[ChangeTransparencyByNBrick alloc]init];
    brick.script = script;
    brick.changeGhostEffect = transparency;

    dispatch_block_t action = [brick actionBlock];
    action();
    XCTAssertEqual(spriteNode.alpha, 1.0f, @"ChangeGhostEffectBrick is not correctly calculated");
}

@end
