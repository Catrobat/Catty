/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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
#import "Script.h"
#import "WhenScript.h"
#import "IfOnEdgeBounceBrick.h"
#import "Pocket_Code-Swift.h"

@interface IfOnEdgeBounceBrickTests : AbstractBrickTests

@property(nonatomic, strong) SpriteObject *spriteObject;
@property(nonatomic, strong) Script *script;
@property(nonatomic, strong) IfOnEdgeBounceBrick *brick;

@end

@implementation IfOnEdgeBounceBrickTests

#define SCREEN_WIDTH 480
#define SCREEN_HEIGHT 800
#define OBJECT_WIDTH 100
#define OBJECT_HEIGHT 100
#define TOP_BORDER_POSITION SCREEN_HEIGHT / 2
#define BOTTOM_BORDER_POSITION -TOP_BORDER_POSITION
#define RIGHT_BORDER_POSITION SCREEN_WIDTH / 2
#define LEFT_BORDER_POSITION -RIGHT_BORDER_POSITION
#define BOUNCE_TOP_POSITION TOP_BORDER_POSITION - (OBJECT_HEIGHT / 2)
#define BOUNCE_BOTTOM_POSITION -(BOUNCE_TOP_POSITION)
#define BOUNCE_RIGHT_POSITION RIGHT_BORDER_POSITION - (OBJECT_WIDTH / 2)
#define BOUNCE_LEFT_POSITION -(BOUNCE_RIGHT_POSITION)
#define EPSILON 0.001

- (void)setUp
{
    [super setUp];
    self.scene = [[CBScene alloc] initWithSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.spriteObject = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:self.spriteObject];
    [self.scene addChild:spriteNode];
    spriteNode.color = [UIColor blackColor];
    spriteNode.size = CGSizeMake(OBJECT_WIDTH, OBJECT_HEIGHT);
    self.spriteObject.spriteNode = spriteNode;
    spriteNode.scenePosition = CGPointMake(0, 0);
    self.spriteObject.name = @"Test";

    self.script = [[WhenScript alloc] init];
    self.script.object = self.spriteObject;

    self.brick = [[IfOnEdgeBounceBrick alloc] init];
    self.brick.script = self.script;
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testNoBounce
{
    [self setPosition:CGPointMake(0, 0) AndRotation:90];
    [self checkPosition:CGPointMake(0, 0) AndRotation:90];
}

- (void)testTopBounce
{
    NSArray *rotations = @[@[[NSNumber numberWithInteger:90], [NSNumber numberWithInteger:90]],
                           @[[NSNumber numberWithInteger:120], [NSNumber numberWithInteger:120]],
                           @[[NSNumber numberWithInteger:150], [NSNumber numberWithInteger:150]],
                           @[[NSNumber numberWithInteger:180], [NSNumber numberWithInteger:180]],
                           @[[NSNumber numberWithInteger:-150], [NSNumber numberWithInteger:-150]],
                           @[[NSNumber numberWithInteger:-120], [NSNumber numberWithInteger:-120]],
                           @[[NSNumber numberWithInteger:-90], [NSNumber numberWithInteger:-90]],
                           @[[NSNumber numberWithInteger:-60], [NSNumber numberWithInteger:-120]],
                           @[[NSNumber numberWithInteger:-30], [NSNumber numberWithInteger:-150]],
                           @[[NSNumber numberWithInteger:0], [NSNumber numberWithInteger:180]],
                           @[[NSNumber numberWithInteger:30], [NSNumber numberWithInteger:150]],
                           @[[NSNumber numberWithInteger:60], [NSNumber numberWithInteger:120]]];
    
      for (NSArray<NSNumber*> *rotation in rotations) {
          CGFloat rotationBefore = rotation[0].floatValue;
          CGFloat rotationAfter = rotation[1].floatValue;
          [self setPosition:CGPointMake(0, TOP_BORDER_POSITION) AndRotation:rotationBefore];
          [self checkPosition:CGPointMake(0, BOUNCE_TOP_POSITION) AndRotation:rotationAfter];
    }
}

- (void)testBottomBounce
{
    NSArray *rotations = @[@[[NSNumber numberWithInteger:90], [NSNumber numberWithInteger:90]],
                           @[[NSNumber numberWithInteger:120], [NSNumber numberWithInteger:60]],
                           @[[NSNumber numberWithInteger:150], [NSNumber numberWithInteger:30]],
                           @[[NSNumber numberWithInteger:180], [NSNumber numberWithInteger:0]],
                           @[[NSNumber numberWithInteger:-150], [NSNumber numberWithInteger:-30]],
                           @[[NSNumber numberWithInteger:-120], [NSNumber numberWithInteger:-60]],
                           @[[NSNumber numberWithInteger:-90], [NSNumber numberWithInteger:-90]],
                           @[[NSNumber numberWithInteger:-60], [NSNumber numberWithInteger:-60]],
                           @[[NSNumber numberWithInteger:-30], [NSNumber numberWithInteger:-30]],
                           @[[NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0]],
                           @[[NSNumber numberWithInteger:30], [NSNumber numberWithInteger:30]],
                           @[[NSNumber numberWithInteger:60], [NSNumber numberWithInteger:60]]];

    for (NSArray<NSNumber*> *rotation in rotations) {
        CGFloat rotationBefore = rotation[0].floatValue;
        CGFloat rotationAfter = rotation[1].floatValue;
        [self setPosition:CGPointMake(0, BOTTOM_BORDER_POSITION) AndRotation:rotationBefore];
        [self checkPosition:CGPointMake(0, BOUNCE_BOTTOM_POSITION) AndRotation:rotationAfter];
    }
}

- (void)testLeftBounce
{
    NSArray *rotations = @[@[[NSNumber numberWithInteger:90], [NSNumber numberWithInteger:90]],
                           @[[NSNumber numberWithInteger:120], [NSNumber numberWithInteger:120]],
                           @[[NSNumber numberWithInteger:150], [NSNumber numberWithInteger:150]],
                           @[[NSNumber numberWithInteger:180], [NSNumber numberWithInteger:180]],
                           @[[NSNumber numberWithInteger:-150], [NSNumber numberWithInteger:150]],
                           @[[NSNumber numberWithInteger:-120], [NSNumber numberWithInteger:120]],
                           @[[NSNumber numberWithInteger:-90], [NSNumber numberWithInteger:90]],
                           @[[NSNumber numberWithInteger:-60], [NSNumber numberWithInteger:60]],
                           @[[NSNumber numberWithInteger:-30], [NSNumber numberWithInteger:30]],
                           @[[NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0]],
                           @[[NSNumber numberWithInteger:30], [NSNumber numberWithInteger:30]],
                           @[[NSNumber numberWithInteger:60], [NSNumber numberWithInteger:60]]];

    for (NSArray<NSNumber*> *rotation in rotations) {
        CGFloat rotationBefore = rotation[0].floatValue;
        CGFloat rotationAfter = rotation[1].floatValue;
        [self setPosition:CGPointMake(LEFT_BORDER_POSITION, 0) AndRotation:rotationBefore];
        [self checkPosition:CGPointMake(BOUNCE_LEFT_POSITION, 0) AndRotation:rotationAfter];
    }
}

- (void)testRightBounce
{
    NSArray *rotations = @[@[[NSNumber numberWithInteger:90], [NSNumber numberWithInteger:-90]],
                           @[[NSNumber numberWithInteger:120], [NSNumber numberWithInteger:-120]],
                           @[[NSNumber numberWithInteger:150], [NSNumber numberWithInteger:-150]],
                           @[[NSNumber numberWithInteger:180], [NSNumber numberWithInteger:180]],
                           @[[NSNumber numberWithInteger:-150], [NSNumber numberWithInteger:-150]],
                           @[[NSNumber numberWithInteger:-120], [NSNumber numberWithInteger:-120]],
                           @[[NSNumber numberWithInteger:-90], [NSNumber numberWithInteger:-90]],
                           @[[NSNumber numberWithInteger:-60], [NSNumber numberWithInteger:-60]],
                           @[[NSNumber numberWithInteger:-30], [NSNumber numberWithInteger:-30]],
                           @[[NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0]],
                           @[[NSNumber numberWithInteger:30], [NSNumber numberWithInteger:-30]],
                           @[[NSNumber numberWithInteger:60], [NSNumber numberWithInteger:-60]]];
    
    for (NSArray<NSNumber*> *rotation in rotations) {
        CGFloat rotationBefore = rotation[0].floatValue;
        CGFloat rotationAfter = rotation[1].floatValue;
        [self setPosition:CGPointMake(RIGHT_BORDER_POSITION, 0) AndRotation:rotationBefore];
        [self checkPosition:CGPointMake(BOUNCE_RIGHT_POSITION, 0) AndRotation:rotationAfter];
    }
}

- (void)testUpLeftBounce
{
    [self setPosition:CGPointMake(LEFT_BORDER_POSITION, TOP_BORDER_POSITION) AndRotation:135];
    [self checkPosition:CGPointMake(BOUNCE_LEFT_POSITION, BOUNCE_TOP_POSITION) AndRotation:135];
    
    [self setPosition:CGPointMake(LEFT_BORDER_POSITION, TOP_BORDER_POSITION) AndRotation:-45];
    [self checkPosition:CGPointMake(BOUNCE_LEFT_POSITION, BOUNCE_TOP_POSITION) AndRotation:135];
}

- (void)testUpRightBounce
{
    [self setPosition:CGPointMake(RIGHT_BORDER_POSITION, TOP_BORDER_POSITION) AndRotation:-135];
    [self checkPosition:CGPointMake(BOUNCE_RIGHT_POSITION, BOUNCE_TOP_POSITION) AndRotation:-135];
    
    [self setPosition:CGPointMake(RIGHT_BORDER_POSITION, TOP_BORDER_POSITION) AndRotation:-45];
    [self checkPosition:CGPointMake(BOUNCE_RIGHT_POSITION, BOUNCE_TOP_POSITION) AndRotation:-135];
}

- (void)testBottomLeftBounce
{
    [self setPosition:CGPointMake(LEFT_BORDER_POSITION, BOTTOM_BORDER_POSITION) AndRotation:45];
    [self checkPosition:CGPointMake(BOUNCE_LEFT_POSITION, BOUNCE_BOTTOM_POSITION) AndRotation:45];
    
    [self setPosition:CGPointMake(LEFT_BORDER_POSITION, BOTTOM_BORDER_POSITION) AndRotation:-135];
    [self checkPosition:CGPointMake(BOUNCE_LEFT_POSITION, BOUNCE_BOTTOM_POSITION) AndRotation:45];
}

- (void)testBottomRightBounce
{
    [self setPosition:CGPointMake(RIGHT_BORDER_POSITION, BOTTOM_BORDER_POSITION) AndRotation:-45];
    [self checkPosition:CGPointMake(BOUNCE_RIGHT_POSITION, BOUNCE_BOTTOM_POSITION) AndRotation:-45];
    
    [self setPosition:CGPointMake(RIGHT_BORDER_POSITION, BOTTOM_BORDER_POSITION) AndRotation:135];
    [self checkPosition:CGPointMake(BOUNCE_RIGHT_POSITION, BOUNCE_BOTTOM_POSITION) AndRotation:-45];
}

- (void)testIsLookingDown
{
    XCTAssertFalse([self.brick isLookingDown:0], @"Brick should not be looking down");
    XCTAssertFalse([self.brick isLookingDown:360], @"Brick should not be looking down");
    XCTAssertFalse([self.brick isLookingDown:45], @"Brick should not be looking down");
    XCTAssertFalse([self.brick isLookingDown:-45], @"Brick should not be looking down");
    XCTAssertFalse([self.brick isLookingDown:315], @"Brick should not be looking down");
    XCTAssertFalse([self.brick isLookingDown:90], @"Brick should not be looking down");
    XCTAssertFalse([self.brick isLookingDown:-90], @"Brick should not be looking down");
    XCTAssertFalse([self.brick isLookingDown:270], @"Brick should not be looking down");
    XCTAssertTrue([self.brick isLookingDown:180], @"Brick should be looking down");
    XCTAssertTrue([self.brick isLookingDown:91], @"Brick should be looking down");
    XCTAssertTrue([self.brick isLookingDown:-91], @"Brick should be looking down");
    XCTAssertTrue([self.brick isLookingDown:150], @"Brick should be looking down");
    XCTAssertTrue([self.brick isLookingDown:179], @"Brick should be looking down");
}

- (void)testIsLookingUp
{
    XCTAssertFalse([self.brick isLookingUp:180], @"Brick should not be looking up");
    XCTAssertFalse([self.brick isLookingUp:540], @"Brick should not be looking up");
    XCTAssertFalse([self.brick isLookingUp:135], @"Brick should not be looking up");
    XCTAssertFalse([self.brick isLookingUp:-135], @"Brick should not be looking up");
    XCTAssertFalse([self.brick isLookingUp:225], @"Brick should not be looking up");
    XCTAssertFalse([self.brick isLookingUp:90], @"Brick should not be looking up");
    XCTAssertFalse([self.brick isLookingUp:-90], @"Brick should not be looking up");
    XCTAssertFalse([self.brick isLookingUp:270], @"Brick should not be looking up");
    XCTAssertTrue([self.brick isLookingUp:0], @"Brick should be looking up");
    XCTAssertTrue([self.brick isLookingUp:360], @"Brick should be looking up");
    XCTAssertTrue([self.brick isLookingUp:89], @"Brick should be looking up");
    XCTAssertTrue([self.brick isLookingUp:-89], @"Brick should be looking up");
    XCTAssertTrue([self.brick isLookingUp:1], @"Brick should be looking up");
}

- (void)testIsLookingLeft
{
    XCTAssertFalse([self.brick isLookingLeft:0], @"Brick should not be looking left");
    XCTAssertFalse([self.brick isLookingLeft:360], @"Brick should not be looking left");
    XCTAssertFalse([self.brick isLookingLeft:180], @"Brick should not be looking left");
    XCTAssertFalse([self.brick isLookingLeft:-180], @"Brick should not be looking left");
    XCTAssertFalse([self.brick isLookingLeft:45], @"Brick should not be looking left");
    XCTAssertFalse([self.brick isLookingLeft:135], @"Brick should not be looking left");
    XCTAssertFalse([self.brick isLookingLeft:-270], @"Brick should not be looking left");
    XCTAssertTrue([self.brick isLookingLeft:-10], @"Brick should be looking left");
    XCTAssertTrue([self.brick isLookingLeft:181], @"Brick should be looking left");
    XCTAssertTrue([self.brick isLookingLeft:359], @"Brick should be looking left");
    XCTAssertTrue([self.brick isLookingLeft:270], @"Brick should be looking left");
}

- (void)testIsLookingRight
{
    XCTAssertFalse([self.brick isLookingRight:0], @"Brick should not be looking right");
    XCTAssertFalse([self.brick isLookingRight:360], @"Brick should not be looking right");
    XCTAssertFalse([self.brick isLookingRight:180], @"Brick should not be looking right");
    XCTAssertFalse([self.brick isLookingRight:-180], @"Brick should not be looking right");
    XCTAssertFalse([self.brick isLookingRight:270], @"Brick should not be looking right");
    XCTAssertFalse([self.brick isLookingRight:-45], @"Brick should not be looking right");
    XCTAssertTrue([self.brick isLookingRight:1], @"Brick should not be looking right");
    XCTAssertTrue([self.brick isLookingRight:179], @"Brick should not be looking right");
    XCTAssertTrue([self.brick isLookingRight:-270], @"Brick should be looking right");
    XCTAssertTrue([self.brick isLookingRight:90], @"Brick should be looking right");
}

- (void)setPosition:(CGPoint)position AndRotation:(CGFloat)rotation
{
    self.spriteObject.spriteNode.scenePosition = position;
    self.spriteObject.spriteNode.rotation = rotation;
    dispatch_block_t action = [self.brick actionBlock];
    action();
}

- (void)checkPosition:(CGPoint)position AndRotation:(CGFloat)rotation
{
    XCTAssertEqualWithAccuracy(position.x, self.spriteObject.spriteNode.scenePosition.x, EPSILON, @"Wrong x after bounce");
    XCTAssertEqualWithAccuracy(position.y, self.spriteObject.spriteNode.scenePosition.y, EPSILON, @"Wrong y after bounce");
    XCTAssertEqualWithAccuracy(rotation, self.spriteObject.spriteNode.rotation, EPSILON, @"Wrong rotation after bounce");
}

@end
