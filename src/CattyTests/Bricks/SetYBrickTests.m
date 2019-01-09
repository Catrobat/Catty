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

@interface SetYBrickTests : AbstractBrickTests
@end

@implementation SetYBrickTests

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


- (void)testSetYBrickPositive
{
    SpriteObject *object = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    
    [self.scene addChild:spriteNode];
    spriteNode.catrobatPosition = CGPointMake(0, 0);

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    SetYBrick* brick = [[SetYBrick alloc]init];
    brick.script = script;
    brick.yPosition = [[Formula alloc] initWithInteger:20];

    dispatch_block_t action = [brick actionBlock:self.formulaInterpreter];
    action();
    XCTAssertEqual(spriteNode.catrobatPosition.y, (CGFloat)20, @"SetyBrick is not correctly calculated");
}

- (void)testSetYBrickNegative
{
    SpriteObject* object = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    
    [self.scene addChild:spriteNode];
    spriteNode.catrobatPosition = CGPointMake(0, 0);

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    SetYBrick* brick = [[SetYBrick alloc]init];
    brick.script = script;
    brick.yPosition = [[Formula alloc] initWithInteger:-20];

    dispatch_block_t action = [brick actionBlock:self.formulaInterpreter];
    action();
    XCTAssertEqual(spriteNode.catrobatPosition.y, (CGFloat)-20, @"SetyBrick is not correctly calculated");
}

- (void)testSetYBrickOutOfRange
{
    SpriteObject* object = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    
    [self.scene addChild:spriteNode];
    spriteNode.catrobatPosition = CGPointMake(0, 0);

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    SetYBrick* brick = [[SetYBrick alloc]init];
    brick.script = script;
    brick.yPosition = [[Formula alloc] initWithInteger:50000];

    dispatch_block_t action = [brick actionBlock:self.formulaInterpreter];
    action();
    XCTAssertEqual(spriteNode.catrobatPosition.y, (CGFloat)50000, @"SetyBrick is not correctly calculated");
}

- (void)testSetYBrickWrongInput
{
    SpriteObject* object = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    
    [self.scene addChild:spriteNode];
    spriteNode.catrobatPosition = CGPointMake(0, 0);

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    SetYBrick* brick = [[SetYBrick alloc]init];
    brick.script = script;
    brick.yPosition = [[Formula alloc] initWithString:@"a"];

    dispatch_block_t action = [brick actionBlock:self.formulaInterpreter];
    action();
    XCTAssertEqual(spriteNode.catrobatPosition.y, (CGFloat)0, @"SetyBrick is not correctly calculated");
}

@end
