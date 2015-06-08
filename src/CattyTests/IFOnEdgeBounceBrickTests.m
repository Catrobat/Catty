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
#import "Script.h"
#import "WhenScript.h"
#import "IfOnEdgeBounceBrick.h"
#import "Pocket_Code-Swift.h"

@interface IfOnEdgeBounceBrickTests : BrickTests

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
#define ROTATION_DEGREE_OFFSET 90.0
#define EPSILON 0.001

- (void)setUp
{
    [super setUp];
    self.scene = [[CBPlayerScene alloc] initWithSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT)];
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
    [self setPosition:CGPointMake(0, 0) AndRotation:[self convertCBToSKDegrees:90]];
    [self checkPosition:CGPointMake(0, 0) AndRotation:[self convertCBToSKDegrees:90]];
}

- (void)testTopBounce
{
    NSArray *rotations = @[@[[self convertCBToSKDegrees:90], [self convertCBToSKDegrees:90]],
                           @[[self convertCBToSKDegrees:120], [self convertCBToSKDegrees:120]],
                           @[[self convertCBToSKDegrees:150], [self convertCBToSKDegrees:150]],
                           @[[self convertCBToSKDegrees:180], [self convertCBToSKDegrees:180]],
                           @[[self convertCBToSKDegrees:-150], [self convertCBToSKDegrees:-150]],
                           @[[self convertCBToSKDegrees:-120], [self convertCBToSKDegrees:-120]],
                           @[[self convertCBToSKDegrees:-90], [self convertCBToSKDegrees:-90]],
                           @[[self convertCBToSKDegrees:-60], [self convertCBToSKDegrees:-120]],
                           @[[self convertCBToSKDegrees:-30], [self convertCBToSKDegrees:-150]],
                           @[[self convertCBToSKDegrees:0], [self convertCBToSKDegrees:180]],
                           @[[self convertCBToSKDegrees:30], [self convertCBToSKDegrees:150]],
                           @[[self convertCBToSKDegrees:60], [self convertCBToSKDegrees:120]]];
    
      for (NSArray *rotation in rotations) {
          NSNumber *rotationBefore = rotation[0];
          NSNumber *rotationAfter = rotation[1];
          [self setPosition:CGPointMake(0, TOP_BORDER_POSITION) AndRotation:rotationBefore];
          [self checkPosition:CGPointMake(0, BOUNCE_TOP_POSITION) AndRotation:rotationAfter];
    }
}

- (void)testBottomBounce
{
    NSArray *rotations = @[@[[self convertCBToSKDegrees:90], [self convertCBToSKDegrees:90]],
                           @[[self convertCBToSKDegrees:120], [self convertCBToSKDegrees:60]],
                           @[[self convertCBToSKDegrees:150], [self convertCBToSKDegrees:30]],
                           @[[self convertCBToSKDegrees:180], [self convertCBToSKDegrees:0]],
                           @[[self convertCBToSKDegrees:-150], [self convertCBToSKDegrees:-30]],
                           @[[self convertCBToSKDegrees:-120], [self convertCBToSKDegrees:-60]],
                           @[[self convertCBToSKDegrees:-90], [self convertCBToSKDegrees:-90]],
                           @[[self convertCBToSKDegrees:-60], [self convertCBToSKDegrees:-60]],
                           @[[self convertCBToSKDegrees:-30], [self convertCBToSKDegrees:-30]],
                           @[[self convertCBToSKDegrees:0], [self convertCBToSKDegrees:0]],
                           @[[self convertCBToSKDegrees:30], [self convertCBToSKDegrees:30]],
                           @[[self convertCBToSKDegrees:60], [self convertCBToSKDegrees:60]]];

    for (NSArray *rotation in rotations) {
        NSNumber *rotationBefore = rotation[0];
        NSNumber *rotationAfter = rotation[1];
        [self setPosition:CGPointMake(0, BOTTOM_BORDER_POSITION) AndRotation:rotationBefore];
        [self checkPosition:CGPointMake(0, BOUNCE_BOTTOM_POSITION) AndRotation:rotationAfter];
    }
}

- (void)testLeftBounce
{
    NSArray *rotations = @[@[[self convertCBToSKDegrees:90], [self convertCBToSKDegrees:90]],
                           @[[self convertCBToSKDegrees:120], [self convertCBToSKDegrees:120]],
                           @[[self convertCBToSKDegrees:150], [self convertCBToSKDegrees:150]],
                           @[[self convertCBToSKDegrees:180], [self convertCBToSKDegrees:180]],
                           @[[self convertCBToSKDegrees:-150], [self convertCBToSKDegrees:150]],
                           @[[self convertCBToSKDegrees:-120], [self convertCBToSKDegrees:120]],
                           @[[self convertCBToSKDegrees:-90], [self convertCBToSKDegrees:90]],
                           @[[self convertCBToSKDegrees:-60], [self convertCBToSKDegrees:60]],
                           @[[self convertCBToSKDegrees:-30], [self convertCBToSKDegrees:30]],
                           @[[self convertCBToSKDegrees:0], [self convertCBToSKDegrees:0]],
                           @[[self convertCBToSKDegrees:30], [self convertCBToSKDegrees:30]],
                           @[[self convertCBToSKDegrees:60], [self convertCBToSKDegrees:60]]];

    for (NSArray *rotation in rotations) {
        NSNumber *rotationBefore = rotation[0];
        NSNumber *rotationAfter = rotation[1];
        [self setPosition:CGPointMake(LEFT_BORDER_POSITION, 0) AndRotation:rotationBefore];
        [self checkPosition:CGPointMake(BOUNCE_LEFT_POSITION, 0) AndRotation:rotationAfter];
    }
}

- (void)testRightBounce
{
    NSArray *rotations = @[@[[self convertCBToSKDegrees:90], [self convertCBToSKDegrees:-90]],
                           @[[self convertCBToSKDegrees:120], [self convertCBToSKDegrees:-120]],
                           @[[self convertCBToSKDegrees:150], [self convertCBToSKDegrees:-150]],
                           @[[self convertCBToSKDegrees:180], [self convertCBToSKDegrees:180]],
                           @[[self convertCBToSKDegrees:-150], [self convertCBToSKDegrees:-150]],
                           @[[self convertCBToSKDegrees:-120], [self convertCBToSKDegrees:-120]],
                           @[[self convertCBToSKDegrees:-90], [self convertCBToSKDegrees:-90]],
                           @[[self convertCBToSKDegrees:-60], [self convertCBToSKDegrees:-60]],
                           @[[self convertCBToSKDegrees:-30], [self convertCBToSKDegrees:-30]],
                           @[[self convertCBToSKDegrees:0], [self convertCBToSKDegrees:0]],
                           @[[self convertCBToSKDegrees:30], [self convertCBToSKDegrees:-30]],
                           @[[self convertCBToSKDegrees:60], [self convertCBToSKDegrees:-60]]];
    
    for (NSArray *rotation in rotations) {
        NSNumber *rotationBefore = rotation[0];
        NSNumber *rotationAfter = rotation[1];
        [self setPosition:CGPointMake(RIGHT_BORDER_POSITION, 0) AndRotation:rotationBefore];
        [self checkPosition:CGPointMake(BOUNCE_RIGHT_POSITION, 0) AndRotation:rotationAfter];
    }
}

- (void)testUpLeftBounce
{
    [self setPosition:CGPointMake(LEFT_BORDER_POSITION, TOP_BORDER_POSITION) AndRotation:[self convertCBToSKDegrees:135]];
    [self checkPosition:CGPointMake(BOUNCE_LEFT_POSITION, BOUNCE_TOP_POSITION) AndRotation:[self convertCBToSKDegrees:135]];
    
    [self setPosition:CGPointMake(LEFT_BORDER_POSITION, TOP_BORDER_POSITION) AndRotation:[self convertCBToSKDegrees:-45]];
    [self checkPosition:CGPointMake(BOUNCE_LEFT_POSITION, BOUNCE_TOP_POSITION) AndRotation:[self convertCBToSKDegrees:135]];
}

- (void)testUpRightBounce
{
    [self setPosition:CGPointMake(RIGHT_BORDER_POSITION, TOP_BORDER_POSITION) AndRotation:[self convertCBToSKDegrees:-135]];
    [self checkPosition:CGPointMake(BOUNCE_RIGHT_POSITION, BOUNCE_TOP_POSITION) AndRotation:[self convertCBToSKDegrees:-135]];
    
    [self setPosition:CGPointMake(RIGHT_BORDER_POSITION, TOP_BORDER_POSITION) AndRotation:[self convertCBToSKDegrees:-45]];
    [self checkPosition:CGPointMake(BOUNCE_RIGHT_POSITION, BOUNCE_TOP_POSITION) AndRotation:[self convertCBToSKDegrees:-135]];
}

- (void)testBottomLeftBounce
{
    [self setPosition:CGPointMake(LEFT_BORDER_POSITION, BOTTOM_BORDER_POSITION) AndRotation:[self convertCBToSKDegrees:45]];
    [self checkPosition:CGPointMake(BOUNCE_LEFT_POSITION, BOUNCE_BOTTOM_POSITION) AndRotation:[self convertCBToSKDegrees:45]];
    
    [self setPosition:CGPointMake(LEFT_BORDER_POSITION, BOTTOM_BORDER_POSITION) AndRotation:[self convertCBToSKDegrees:-135]];
    [self checkPosition:CGPointMake(BOUNCE_LEFT_POSITION, BOUNCE_BOTTOM_POSITION) AndRotation:[self convertCBToSKDegrees:45]];
}

- (void)testBottomRightBounce
{
    [self setPosition:CGPointMake(RIGHT_BORDER_POSITION, BOTTOM_BORDER_POSITION) AndRotation:[self convertCBToSKDegrees:-45]];
    [self checkPosition:CGPointMake(BOUNCE_RIGHT_POSITION, BOUNCE_BOTTOM_POSITION) AndRotation:[self convertCBToSKDegrees:-45]];
    
    [self setPosition:CGPointMake(RIGHT_BORDER_POSITION, BOTTOM_BORDER_POSITION) AndRotation:[self convertCBToSKDegrees:135]];
    [self checkPosition:CGPointMake(BOUNCE_RIGHT_POSITION, BOUNCE_BOTTOM_POSITION) AndRotation:[self convertCBToSKDegrees:-45]];
}

- (NSNumber*)convertCBToSKDegrees:(CGFloat)degrees
{
    double deg = degrees - ROTATION_DEGREE_OFFSET;
    NSNumber *test = [NSNumber numberWithFloat:fmodf([(CBPlayerScene*)self.scene convertDegreesToScene:(CGFloat)deg], 360.0f)];
    NSLog(@"%f CB = %f IOS", degrees, [test floatValue]);
    return test;
}

- (void)setPosition:(CGPoint)position AndRotation:(NSNumber*)rotation
{
    self.spriteObject.spriteNode.scenePosition = position;
    self.spriteObject.spriteNode.rotation = rotation.floatValue;
    dispatch_block_t action = [self.brick actionBlock];
    action();
}

- (void)checkPosition:(CGPoint)position AndRotation:(NSNumber*)rotation
{
    XCTAssertEqualWithAccuracy(position.x, self.spriteObject.spriteNode.scenePosition.x, EPSILON, @"Wrong x after bounce");
    XCTAssertEqualWithAccuracy(position.y, self.spriteObject.spriteNode.scenePosition.y, EPSILON, @"Wrong y after bounce");
    if ((rotation.floatValue != 0.0f) || (fabs(self.spriteObject.spriteNode.rotation - 360.0f) > EPSILON)) {
        XCTAssertEqualWithAccuracy(rotation.floatValue, self.spriteObject.spriteNode.rotation, EPSILON, @"Wrong rotation after bounce");
    }
}

@end
