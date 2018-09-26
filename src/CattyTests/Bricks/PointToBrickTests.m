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
#import "PointToBrick.h"
#import "WhenScript.h"
#import "ProgramMock.h"
#import "Pocket_Code-Swift.h"

@interface PointToBrickTests : XCTestCase
@property(nonatomic, strong) CBScene *scene;
@end

@implementation PointToBrickTests

- (void)setUp
{
    [super setUp];
    self.scene = [[[SceneBuilder alloc] initWithProgram:[ProgramMock new]] build];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testPointToBrickZeroDegrees
{
    SpriteObject *firstObject = [[SpriteObject alloc] init];
    CBSpriteNode *firstSpriteNode = [[CBSpriteNode alloc] initWithSpriteObject:firstObject];
    firstObject.spriteNode = firstSpriteNode;
    SpriteObject *secondObject = [[SpriteObject alloc] init];
    CBSpriteNode *secondSpriteNode = [[CBSpriteNode alloc] initWithSpriteObject:secondObject];
    secondObject.spriteNode = secondSpriteNode;
    
    [self.scene addChild:firstSpriteNode];
    [self.scene addChild:secondSpriteNode];
    
    [firstSpriteNode setPosition:CGPointMake(0, 0)];
    [secondSpriteNode setPosition:CGPointMake(0, 10)];
    
    Script *script = [[WhenScript alloc] init];
    script.object = firstObject;
    
    PointToBrick *brick = [[PointToBrick alloc] init];
    brick.script = script;
    brick.pointedObject = secondObject;
    
    dispatch_block_t dispatchBlock = [brick actionBlock];
    dispatchBlock();
    
    XCTAssertEqualWithAccuracy(0, firstSpriteNode.catrobatRotation, 0.1f, @"PointToBrick not correct");
}

- (void)testPointToBrickSamePosition
{
    SpriteObject *firstObject = [[SpriteObject alloc] init];
    CBSpriteNode *firstSpriteNode = [[CBSpriteNode alloc] initWithSpriteObject:firstObject];
    firstObject.spriteNode = firstSpriteNode;
    SpriteObject *secondObject = [[SpriteObject alloc] init];
    CBSpriteNode *secondSpriteNode = [[CBSpriteNode alloc] initWithSpriteObject:secondObject];
    secondObject.spriteNode = secondSpriteNode;
    
    [self.scene addChild:firstSpriteNode];
    [self.scene addChild:secondSpriteNode];
    
    [firstSpriteNode setPosition:CGPointMake(0, 0)];
    [secondSpriteNode setPosition:CGPointMake(0, 0)];
    
    Script *script = [[WhenScript alloc] init];
    script.object = firstObject;
    PointToBrick *brick = [[PointToBrick alloc] init];
    brick.script = script;
    brick.pointedObject = secondObject;
    dispatch_block_t dispatchBlock = [brick actionBlock];
    dispatchBlock();
    
    XCTAssertEqualWithAccuracy(0, firstSpriteNode.catrobatRotation, 0.1f, @"PointToBrick not correct");
}

- (void)testPointToBrick45Degrees
{
    SpriteObject *firstObject = [[SpriteObject alloc] init];
    CBSpriteNode *firstSpriteNode = [[CBSpriteNode alloc] initWithSpriteObject:firstObject];
    firstObject.spriteNode = firstSpriteNode;
    SpriteObject *secondObject = [[SpriteObject alloc] init];
    CBSpriteNode *secondSpriteNode = [[CBSpriteNode alloc] initWithSpriteObject:secondObject];
    secondObject.spriteNode = secondSpriteNode;
    
    [self.scene addChild:firstSpriteNode];
    [self.scene addChild:secondSpriteNode];
    
    [firstSpriteNode setPosition:CGPointMake(0, 0)];
    [secondSpriteNode setPosition:CGPointMake(1, 1)];
    
    Script *script = [[WhenScript alloc] init];
    script.object = firstObject;
    
    PointToBrick *brick = [[PointToBrick alloc] init];
    brick.script = script;
    brick.pointedObject = secondObject;
    dispatch_block_t dispatchBlock = [brick actionBlock];
    dispatchBlock();
    
    XCTAssertEqualWithAccuracy(45.0, firstSpriteNode.catrobatRotation, 0.1f, @"PointToBrick not correct");
}

@end
