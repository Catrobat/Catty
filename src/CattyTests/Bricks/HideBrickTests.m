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

@interface HideBrickTests : BrickTests
@end

@implementation HideBrickTests

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

- (void)testHideBrick
{
    SpriteObject *object = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    CBPlayerScene *scene = [[CBPlayerScene alloc] init];
    [scene addChild:spriteNode];
    spriteNode.scenePosition = CGPointMake(0, 0);

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    HideBrick* brick = [[HideBrick alloc]init];
    brick.script = script;

    dispatch_block_t action = [brick actionBlock];
    action();
    XCTAssertEqual(spriteNode.hidden, YES, @"HideBrick is not correctly calculated");
}

@end
