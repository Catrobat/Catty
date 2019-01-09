/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

@interface ChangeSizeByNBrickTests : AbstractBrickTests
@end

@implementation ChangeSizeByNBrickTests

- (void)setUp
{
    [super setUp];
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
    spriteNode.catrobatSize = 10.0;

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    ChangeSizeByNBrick* brick = [[ChangeSizeByNBrick alloc] init];
    brick.script = script;
    
    brick.size = [[Formula alloc] initWithInteger:30];

    dispatch_block_t action = [brick actionBlock:self.formulaInterpreter];
    action();

    XCTAssertEqualWithAccuracy(40.0f, spriteNode.catrobatSize, 0.0001, @"Size not correct");
}

- (void)testChangeSizeByNBrickNegative
{
    SpriteObject* object = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    spriteNode.catrobatSize = 50.0;

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    ChangeSizeByNBrick* brick = [[ChangeSizeByNBrick alloc] init];
    brick.script = script;

    brick.size = [[Formula alloc] initWithInteger:-30];

    dispatch_block_t action = [brick actionBlock:self.formulaInterpreter];
    action();

    XCTAssertEqualWithAccuracy(20.0f, spriteNode.catrobatSize, 0.0001, @"Size not correct");
}

- (void)testChangeSizeByNBrickWrongInput
{
    SpriteObject *object = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    spriteNode.catrobatSize = 10.0;

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    ChangeSizeByNBrick *brick = [[ChangeSizeByNBrick alloc] init];
    brick.script = script;

    brick.size = [[Formula alloc] initWithString:@"a"];

    dispatch_block_t action = [brick actionBlock:self.formulaInterpreter];
    action();

    XCTAssertEqualWithAccuracy(10.0f, spriteNode.catrobatSize, 0.0001, @"Size not correct");
}

@end
