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

@interface GoNStepsBackBrickTests : BrickTests
@end

@implementation GoNStepsBackBrickTests

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

- (void)testGoNStepsBackBrickSingle
{
    Program* program = [[Program alloc] init];
    SpriteObject* object1 = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode1 = [[CBSpriteNode alloc] initWithSpriteObject:object1];
    object1.spriteNode = spriteNode1;
    object1.program = program;
    spriteNode1.zPosition = 5;

    SpriteObject* object2 = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode2 = [[CBSpriteNode alloc] initWithSpriteObject:object2];
    object2.spriteNode = spriteNode2;
    spriteNode2.zPosition = 3;

    [program.objectList addObject:object1];
    [program.objectList addObject:object2];

    Script *script = [[WhenScript alloc] init];
    script.object = object1;

    GoNStepsBackBrick* brick = [[GoNStepsBackBrick alloc] init];
    brick.script = script;

    Formula* steps = [[Formula alloc] init];
    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"1";
    steps.formulaTree = formulaTree;
    brick.steps = steps;

    dispatch_block_t action = [brick actionBlock];
    action();
    XCTAssertEqual(spriteNode1.zPosition, (CGFloat)4.0, @"GoNStepsBack is not correctly calculated");
    XCTAssertEqual(spriteNode2.zPosition, (CGFloat)3.0, @"GoNStepsBack is not correctly calculated");
}

- (void)testGoNStepsBackBrickTwice
{
    Program *program = [[Program alloc] init];
    SpriteObject *object1 = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode1 = [[CBSpriteNode alloc] initWithSpriteObject:object1];
    object1.spriteNode = spriteNode1;
    object1.program = program;
    spriteNode1.zPosition = 6;

    SpriteObject *object2 = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode2 = [[CBSpriteNode alloc] initWithSpriteObject:object2];
    object2.spriteNode = spriteNode2;
    spriteNode2.zPosition = 3;

    [program.objectList addObject:object1];
    [program.objectList addObject:object2];

    Script *script = [[WhenScript alloc] init];
    script.object = object1;

    GoNStepsBackBrick *brick = [[GoNStepsBackBrick alloc] init];
    brick.script = script;

    Formula *steps = [[Formula alloc] init];
    FormulaElement *formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"2";
    steps.formulaTree = formulaTree;
    brick.steps = steps;

    dispatch_block_t action = [brick actionBlock];
    action();
    XCTAssertEqual(spriteNode1.zPosition, (CGFloat)4.0, @"GoNStepsBack is not correctly calculated");
    XCTAssertEqual(spriteNode2.zPosition, (CGFloat)3.0, @"GoNStepsBack is not correctly calculated");
}

- (void)testGoNStepsBackBrickComeToSameLayer
{
    Program *program = [[Program alloc] init];
    SpriteObject *object1 = [[SpriteObject alloc] init];
    object1.program = program;
    CBSpriteNode *spriteNode1 = [[CBSpriteNode alloc] initWithSpriteObject:object1];
    object1.spriteNode = spriteNode1;
    spriteNode1.zPosition = 5;

    SpriteObject *object2 = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode2 = [[CBSpriteNode alloc] initWithSpriteObject:object2];
    object2.spriteNode = spriteNode2;
    spriteNode2.zPosition = 3;

    [program.objectList addObject:object1];
    [program.objectList addObject:object2];

    Script *script = [[WhenScript alloc] init];
    script.object = object1;

    GoNStepsBackBrick *brick = [[GoNStepsBackBrick alloc] init];
    brick.script = script;

    Formula *steps = [[Formula alloc] init];
    FormulaElement *formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"2";
    steps.formulaTree = formulaTree;
    brick.steps = steps;

    dispatch_block_t action = [brick actionBlock];
    action();
    XCTAssertEqual(spriteNode1.zPosition, (CGFloat)3.0, @"GoNStepsBack is not correctly calculated");
    XCTAssertEqual(spriteNode2.zPosition, (CGFloat)4.0, @"GoNStepsBack is not correctly calculated");
}

- (void)testGoNStepsBackBrickOutOfRange
{
    Program *program = [[Program alloc] init];
    SpriteObject *object1 = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode1 = [[CBSpriteNode alloc] initWithSpriteObject:object1];
    object1.spriteNode = spriteNode1;
    object1.program = program;
    spriteNode1.zPosition = 5;

    SpriteObject *object2 = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode2 = [[CBSpriteNode alloc] initWithSpriteObject:object2];
    object2.spriteNode = spriteNode2;
    spriteNode2.zPosition = 3;

    [program.objectList addObject:object1];
    [program.objectList addObject:object2];

    Script *script = [[WhenScript alloc] init];
    script.object = object1;

    GoNStepsBackBrick *brick = [[GoNStepsBackBrick alloc] init];
    brick.script = script;

    Formula *steps = [[Formula alloc] init];
    FormulaElement *formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"10";
    steps.formulaTree = formulaTree;
    brick.steps = steps;

    dispatch_block_t action = [brick actionBlock];
    action();
    XCTAssertEqual(spriteNode1.zPosition, (CGFloat)1.0, @"GoNStepsBack is not correctly calculated");
    XCTAssertEqual(spriteNode2.zPosition, (CGFloat)4.0, @"GoNStepsBack is not correctly calculated");
}

- (void)testGoNStepsBackBrickWronginput
{
    Program *program = [[Program alloc] init];
    SpriteObject *object1 = [[SpriteObject alloc] init];
    object1.program = program;
    CBSpriteNode *spriteNode1 = [[CBSpriteNode alloc] initWithSpriteObject:object1];
    object1.spriteNode = spriteNode1;
    spriteNode1.zPosition = 5;

    SpriteObject *object2 = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode2 = [[CBSpriteNode alloc] initWithSpriteObject:object2];
    object2.spriteNode = spriteNode2;
    spriteNode2.zPosition = 3;

    [program.objectList addObject:object1];
    [program.objectList addObject:object2];

    Script *script = [[WhenScript alloc] init];
    script.object = object1;

    GoNStepsBackBrick* brick = [[GoNStepsBackBrick alloc] init];
    brick.script = script;

    Formula *steps = [[Formula alloc] init];
    FormulaElement *formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"a";
    steps.formulaTree = formulaTree;
    brick.steps = steps;

    dispatch_block_t action = [brick actionBlock];
    action();
    XCTAssertEqual(spriteNode1.zPosition, (CGFloat)5.0, @"GoNStepsBack is not correctly calculated");
    XCTAssertEqual(spriteNode2.zPosition, (CGFloat)3.0, @"GoNStepsBack is not correctly calculated");
}

@end
