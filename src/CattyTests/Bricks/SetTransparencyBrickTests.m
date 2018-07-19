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

@interface SetTransparencyBrickTests : AbstractBrickTests
@property (nonatomic, strong) TransparencySensor* transparencySensor;
@end

@implementation SetTransparencyBrickTests

- (void)setUp
{
    [super setUp];
    self.transparencySensor = [TransparencySensor new];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testSetTransparencyBrickPositve
{
    SpriteObject* object = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    CBScene *scene = [[CBScene alloc] init];
    [scene addChild:spriteNode];
    spriteNode.alpha = [self.transparencySensor convertToRawWithStandardizedValue:0.0];

    Formula *transparency =[[Formula alloc] init];
    FormulaElement *formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"20";
    transparency.formulaTree = formulaTree;

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    SetTransparencyBrick *brick = [[SetTransparencyBrick alloc]init];
    brick.script = script;
    brick.transparency = transparency;

    dispatch_block_t action = [brick actionBlock];
    action();
    
    CGFloat standardizedValue = [self.transparencySensor convertToStandardizedWithRawValue:spriteNode.alpha];
    XCTAssertEqualWithAccuracy(20.0f, standardizedValue, 0.01f, @"ChangeTransparencyBrick is not correctly calculated");
}

- (void)testSetTransparencyBrickNegative
{
    SpriteObject* object = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    CBScene *scene = [[CBScene alloc] init];
    [scene addChild:spriteNode];
    spriteNode.alpha = [self.transparencySensor convertToRawWithStandardizedValue:0.0];

    Formula* transparency =[[Formula alloc] init];
    FormulaElement* formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"-20";
    transparency.formulaTree = formulaTree;

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    SetTransparencyBrick *brick = [[SetTransparencyBrick alloc]init];
    brick.script = script;
    brick.transparency = transparency;
    
    dispatch_block_t action = [brick actionBlock];
    action();
    
    CGFloat standardizedValue = [self.transparencySensor convertToStandardizedWithRawValue:spriteNode.alpha];
    XCTAssertEqualWithAccuracy(0.0f, standardizedValue, 0.01f, @"ChangeTransparencyBrick is not correctly calculated");
}

- (void)testSetTransparencyBrickWronginput
{
    SpriteObject* object = [[SpriteObject alloc] init];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    CBScene *scene = [[CBScene alloc] init];
    [scene addChild:spriteNode];
    spriteNode.alpha = [self.transparencySensor convertToRawWithStandardizedValue:10.0];

    Formula* transparency =[[Formula alloc] init];
    FormulaElement* formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"a";
    transparency.formulaTree = formulaTree;

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    SetTransparencyBrick *brick = [[SetTransparencyBrick alloc]init];
    brick.script = script;
    brick.transparency = transparency;
    
    dispatch_block_t action = [brick actionBlock];
    action();
    
    CGFloat standardizedValue = [self.transparencySensor convertToStandardizedWithRawValue:spriteNode.alpha];
    XCTAssertEqualWithAccuracy(0.0f, standardizedValue, 0.01f, @"ChangeTransparencyBrick is not correctly calculated");
}

@end
