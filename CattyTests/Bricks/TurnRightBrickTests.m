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

@interface TurnRightBrickTests : AbstractBrickTests
@end

@implementation TurnRightBrickTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testTurnRightBrick
{
    //[self turnRightWithInitialRotation:0 andRotation:20.0f];
    //[self turnRightWithInitialRotation:40 andRotation:60.0f];
    [self turnRightWithInitialRotation:200 andRotation:80.0f];
}

- (void)testTurnRightBrickOver360
{
    [self turnRightWithInitialRotation:0 andRotation:400.0f];
    [self turnRightWithInitialRotation:-80 andRotation:400.0f];
}

- (void)testTurnRightBrickNegative
{
    [self turnRightWithInitialRotation:0 andRotation:-20.0f];
    [self turnRightWithInitialRotation:-80 andRotation:-20.0f];
    [self turnRightWithInitialRotation:-20 andRotation:-20.0f];
}

- (void)testTurnRightBrickNegativeOver360
{
    [self turnRightWithInitialRotation:0 andRotation:-400.0f];
    [self turnRightWithInitialRotation:-80 andRotation:-560.0f];
    [self turnRightWithInitialRotation:-20 andRotation:-400.0f];
}

- (void)testTurnRightBrickWithoutRotation
{
    //[self turnRightWithInitialRotation:0 andRotation:0.0f];
    //[self turnRightWithInitialRotation:-80 andRotation:0.0f];
    //[self turnRightWithInitialRotation:-180 andRotation:0.0f];
    [self turnRightWithInitialRotation:-190 andRotation:0.0f];
    //[self turnRightWithInitialRotation:290 andRotation:0.0f];
}

- (void)testTurnRightBrickWrongInput
{
    SpriteObject *object = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    spriteNode.catrobatRotation = 0.0;

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    TurnRightBrick *brick = [[TurnRightBrick alloc] init];
    brick.script = script;

    brick.degrees = [[Formula alloc] initWithString:@"a"];

    dispatch_block_t action = [brick actionBlock:self.formulaInterpreter];
    action();
    
    XCTAssertEqualWithAccuracy(0.0, spriteNode.catrobatRotation, 0.0001, @"TurnRightBrick not correct");
}

- (void)turnRightWithInitialRotation:(CGFloat)initialRotation andRotation:(CGFloat)rotation
{
    SpriteObject *object = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    
    spriteNode.catrobatRotation = initialRotation;
    
    Script *script = [[WhenScript alloc] init];
    script.object = object;
    
    TurnRightBrick* brick = [[TurnRightBrick alloc] init];
    brick.script = script;
    
    brick.degrees = [[Formula alloc] initWithFloat:rotation];
    
    dispatch_block_t action = [brick actionBlock:self.formulaInterpreter];
    action();
    
    if (initialRotation > 180.0f) {
        initialRotation = -360.0f + initialRotation;
    } else if (initialRotation < -180.0f) {
        initialRotation = initialRotation + 360.0f;
    }
    
    CGFloat expectedRawRotation = [[RotationSensor class] convertToRawWithUserInput:(initialRotation + rotation) for: object];
    XCTAssertEqualWithAccuracy(expectedRawRotation, spriteNode.zRotation, 0.0001, @"TurnRightBrick not correct");
}

@end
