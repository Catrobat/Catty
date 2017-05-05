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
#import "BrickTests.h"
#import "Script.h"
#import "WhenScript.h"
#import "MoveNStepsBrick.h"
#import "Pocket_Code-Swift.h"

@interface MoveNStepsBrickTests : BrickTests

@property(nonatomic, strong) CBSpriteNode *spriteNode;
@property(nonatomic, strong) Script *script;
@property(nonatomic, strong) MoveNStepsBrick *brick;

@end

@implementation MoveNStepsBrickTests

#define SCREEN_WIDTH 480
#define SCREEN_HEIGHT 800
#define OBJECT_WIDTH 100
#define OBJECT_HEIGHT 100
#define EPSILON 0.001

- (void)setUp
{
    [super setUp];
    self.scene = [[CBScene alloc] initWithSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    SpriteObject *spriteObject = [[SpriteObject alloc] init];
    
    self.spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:spriteObject];
    self.spriteNode.color = [UIColor blackColor];
    self.spriteNode.size = CGSizeMake(OBJECT_WIDTH, OBJECT_HEIGHT);
    [self.scene addChild:self.spriteNode];
    
    spriteObject.spriteNode = self.spriteNode;
    self.spriteNode.scenePosition = CGPointMake(0, 0);
    spriteObject.name = @"Test";
    
    self.script = [[WhenScript alloc] init];
    self.script.object = spriteObject;
    
    self.brick = [[MoveNStepsBrick alloc] init];
    self.brick.script = self.script;
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testMoveNStepsBrickUp
{
    [self setPosition:CGPointMake(20, 20) andRotation:0 andMoveSteps:10];
    [self checkPosition:CGPointMake(20, 30)];
    
    [self setPosition:CGPointMake(20, 20) andRotation:0 andMoveSteps:-10];
    [self checkPosition:CGPointMake(20, 10)];
    
    [self setPosition:CGPointMake(SCREEN_WIDTH/2, -SCREEN_HEIGHT/2) andRotation:0 andMoveSteps:10];
    [self checkPosition:CGPointMake(SCREEN_WIDTH/2, -SCREEN_HEIGHT/2+10)];
}

- (void)testMoveNStepsBrickDown
{
    [self setPosition:CGPointMake(20, 20) andRotation:180 andMoveSteps:10];
    [self checkPosition:CGPointMake(20, 10)];
    
    [self setPosition:CGPointMake(20, 20) andRotation:180 andMoveSteps:-10];
    [self checkPosition:CGPointMake(20, 30)];
    
    [self setPosition:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2) andRotation:180 andMoveSteps:10];
    [self checkPosition:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2-10)];
}

- (void)testMoveNStepsBrickLeft
{
    [self setPosition:CGPointMake(20, 20) andRotation:270 andMoveSteps:10];
    [self checkPosition:CGPointMake(10, 20)];
    
    [self setPosition:CGPointMake(20, 20) andRotation:270 andMoveSteps:-10];
    [self checkPosition:CGPointMake(30, 20)];
    
    [self setPosition:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2) andRotation:270 andMoveSteps:10];
    [self checkPosition:CGPointMake(SCREEN_WIDTH/2-10, SCREEN_HEIGHT/2)];
}

- (void)testMoveNStepsBrickRight
{
    [self setPosition:CGPointMake(20, 20) andRotation:90 andMoveSteps:10];
    [self checkPosition:CGPointMake(30, 20)];
    
    [self setPosition:CGPointMake(20, 20) andRotation:90 andMoveSteps:-10];
    [self checkPosition:CGPointMake(10, 20)];
    
    [self setPosition:CGPointMake(-SCREEN_WIDTH/2, SCREEN_HEIGHT/2) andRotation:90 andMoveSteps:10];
    [self checkPosition:CGPointMake(-SCREEN_WIDTH/2+10, SCREEN_HEIGHT/2)];
}

- (void)testMoveNStepsBrickLeftUp
{
    [self setPosition:CGPointMake(SCREEN_WIDTH/2, -SCREEN_HEIGHT/2) andRotation:280 andMoveSteps:10];
    
    CGFloat rotation = [Util degreeToRadians:280];
    CGFloat xPosition = SCREEN_WIDTH/2 + 10 * sin(rotation);
    CGFloat yPosition = -SCREEN_HEIGHT/2 + 10 * cos(rotation);
    
    [self checkPosition:CGPointMake(xPosition, yPosition)];
}

- (void)testMoveNStepsBrickRightUp
{
    [self setPosition:CGPointMake(-SCREEN_WIDTH/2, -SCREEN_HEIGHT/2) andRotation:80 andMoveSteps:10];
    
    CGFloat rotation = [Util degreeToRadians:80];
    CGFloat xPosition = -SCREEN_WIDTH/2 + 10 * sin(rotation);
    CGFloat yPosition = -SCREEN_HEIGHT/2 + 10 * cos(rotation);
    
    [self checkPosition:CGPointMake(xPosition, yPosition)];
}

- (void)testMoveNStepsBrickLeftDown
{
    [self setPosition:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2) andRotation:200 andMoveSteps:10];
    
    CGFloat rotation = [Util degreeToRadians:200];
    CGFloat xPosition = SCREEN_WIDTH/2 + 10 * sin(rotation);
    CGFloat yPosition = SCREEN_HEIGHT/2 + 10 * cos(rotation);
    
    [self checkPosition:CGPointMake(xPosition, yPosition)];
}

- (void)testMoveNStepsBrickRightDown
{
    [self setPosition:CGPointMake(-SCREEN_WIDTH/2, SCREEN_HEIGHT/2) andRotation:110 andMoveSteps:10];
    
    CGFloat rotation = [Util degreeToRadians:110];
    CGFloat xPosition = -SCREEN_WIDTH/2 + 10 * sin(rotation);
    CGFloat yPosition = SCREEN_HEIGHT/2 + 10 * cos(rotation);
    
    [self checkPosition:CGPointMake(xPosition, yPosition)];
}

- (void)setPosition:(CGPoint)position andRotation:(CGFloat)rotation andMoveSteps:(CGFloat)steps
{
    self.spriteNode.scenePosition = position;
    self.spriteNode.rotation = rotation;
    
    Formula* stepFormula = [[Formula alloc] init];
    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = [[NSNumber numberWithFloat:steps] stringValue];
    stepFormula.formulaTree = formulaTree;
    
    self.brick.steps = stepFormula;
    
    dispatch_block_t action = [self.brick actionBlock];
    action();
}

- (void)checkPosition:(CGPoint)position
{
    XCTAssertEqualWithAccuracy(position.x, self.spriteNode.scenePosition.x, EPSILON, @"Wrong x after MoveNStepsBrick");
    XCTAssertEqualWithAccuracy(position.y, self.spriteNode.scenePosition.y, EPSILON, @"Wrong y after MoveNStepsBrick");
}

- (void)testTitleSingular
{
    MoveNStepsBrick* brick = [[MoveNStepsBrick alloc] init];
    brick.steps = [[Formula alloc] initWithDouble:1];
    XCTAssertTrue([[kLocalizedMove stringByAppendingString:[@"%@ " stringByAppendingString:kLocalizedStep]] isEqualToString:[brick brickTitle]], @"Wrong brick title");
}

- (void)testTitlePlural
{
    MoveNStepsBrick* brick = [[MoveNStepsBrick alloc] init];
    brick.steps = [[Formula alloc] initWithDouble:2];
    XCTAssertTrue([[kLocalizedMove stringByAppendingString:[@"%@ " stringByAppendingString:kLocalizedSteps]] isEqualToString:[brick brickTitle]], @"Wrong brick title");
}

@end
