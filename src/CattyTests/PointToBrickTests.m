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
#import "PointToBrick.h"
#import "WhenScript.h"
#import "Pocket_Code-Swift.h"

@interface PointToBrickTests : BrickTests
@end

@implementation PointToBrickTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPointToBrick90Degrees
{
    SpriteObject *firstObject = [[SpriteObject alloc] init];
    CBSpriteNode *firstSpriteNode = [[CBSpriteNode alloc] initWithSpriteObject:firstObject];
    firstObject.spriteNode = firstSpriteNode;
    SpriteObject *secondObject = [[SpriteObject alloc] init];
    CBSpriteNode *secondSpriteNode = [[CBSpriteNode alloc] initWithSpriteObject:secondObject];
    secondObject.spriteNode = secondSpriteNode;

    CBPlayerScene *scene = [[CBPlayerScene alloc] init];
    [scene addChild:firstSpriteNode];
    [scene addChild:secondSpriteNode];

    [firstSpriteNode setPosition:CGPointMake(0, 0)];
    [secondSpriteNode setPosition:CGPointMake(0, 10)];

    Script *script = [[WhenScript alloc] init];
    script.object = firstObject;

    PointToBrick *brick = [[PointToBrick alloc] init];
    brick.script = script;
    brick.pointedObject = secondObject;

    dispatch_block_t dispatchBlock = [brick actionBlock];
    dispatchBlock();

    // SpriteKit coordinates: 0/0 => center instead of top left corner
    // SpriteKit: +90 degrees is turn left / -90degrees is turn right
    // Catrabot: 90 degrees shifted
    XCTAssertEqualWithAccuracy(firstSpriteNode.rotation, 90.0f, 0.1f, @"PointToBrick not correct");
}

- (void)testPointToBrickZeroDegrees
{
    SpriteObject *firstObject = [[SpriteObject alloc] init];
    CBSpriteNode *firstSpriteNode = [[CBSpriteNode alloc] initWithSpriteObject:firstObject];
    firstObject.spriteNode = firstSpriteNode;
    SpriteObject *secondObject = [[SpriteObject alloc] init];
    CBSpriteNode *secondSpriteNode = [[CBSpriteNode alloc] initWithSpriteObject:secondObject];
    secondObject.spriteNode = secondSpriteNode;

    CBPlayerScene *scene = [[CBPlayerScene alloc] init];
    [scene addChild:firstSpriteNode];
    [scene addChild:secondSpriteNode];

    [firstSpriteNode setPosition:CGPointMake(0, 0)];
    [secondSpriteNode setPosition:CGPointMake(0, 0)];

    Script *script = [[WhenScript alloc] init];
    script.object = firstObject;
    PointToBrick *brick = [[PointToBrick alloc] init];
    brick.script = script;
    brick.pointedObject = secondObject;
    dispatch_block_t dispatchBlock = [brick actionBlock];
    dispatchBlock();
    XCTAssertEqualWithAccuracy(firstSpriteNode.rotation, 0.0f, 0.1f, @"PointToBrick not correct");
}

- (void)testPointToBrick45Degrees
{
    SpriteObject *firstObject = [[SpriteObject alloc] init];
    CBSpriteNode *firstSpriteNode = [[CBSpriteNode alloc] initWithSpriteObject:firstObject];
    firstObject.spriteNode = firstSpriteNode;
    SpriteObject *secondObject = [[SpriteObject alloc] init];
    CBSpriteNode *secondSpriteNode = [[CBSpriteNode alloc] initWithSpriteObject:secondObject];
    secondObject.spriteNode = secondSpriteNode;

    CBPlayerScene *scene = [[CBPlayerScene alloc] init];
    [scene addChild:firstSpriteNode];
    [scene addChild:secondSpriteNode];

    [firstSpriteNode setPosition:CGPointMake(0, 0)];
    [secondSpriteNode setPosition:CGPointMake(1, 1)];

    Script *script = [[WhenScript alloc] init];
    script.object = firstObject;

    PointToBrick *brick = [[PointToBrick alloc] init];
    brick.script = script;
    brick.pointedObject = secondObject;
    dispatch_block_t dispatchBlock = [brick actionBlock];
    dispatchBlock();
    XCTAssertEqualWithAccuracy(firstSpriteNode.rotation, 45.0f, 0.1f, @"PointToBrick not correct");
}

@end
