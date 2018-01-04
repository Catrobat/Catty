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

@interface ComeToFrontBrickTests : AbstractBrickTests
@end

@implementation ComeToFrontBrickTests

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

- (void)testComeToFrontBrick
{
    Program *program = [[Program alloc] init];
    SpriteObject *background = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNodeBG = [[CBSpriteNode alloc] initWithSpriteObject:background];
    background.spriteNode = spriteNodeBG;
    background.program = program;

    SpriteObject* object1 = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode1 = [[CBSpriteNode alloc] initWithSpriteObject:object1];
    object1.spriteNode = spriteNode1;
    object1.program = program;
    spriteNode1.zPosition = 1;

    SpriteObject* object2 = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode2 = [[CBSpriteNode alloc] initWithSpriteObject:object2];
    object2.spriteNode = spriteNode2;
    spriteNode2.zPosition = 2;

    [program.objectList addObject:background];
    [program.objectList addObject:object1];
    [program.objectList addObject:object2];

    Script *script = [[WhenScript alloc] init];
    script.object = object1;
    ComeToFrontBrick* brick = [[ComeToFrontBrick alloc] init];
    brick.script = script;
    dispatch_block_t action = [brick actionBlock];
    action();
    XCTAssertEqual(spriteNode1.zPosition, (CGFloat)2.0, @"ComeToFront is not correctly calculated");
    XCTAssertEqual(spriteNode2.zPosition, (CGFloat)1.0, @"ComeToFront is not correctly calculated");
}

@end
