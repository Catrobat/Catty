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

@interface SetGhostEffectBrickTests : BrickTests

@end

@implementation SetGhostEffectBrickTests

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

-(void)testSetGhostEffectBrickPositve
{
    SpriteObject* object = [[SpriteObject alloc] init];
    object.position = CGPointMake(0, 0);
    
    Scene* scene = [[Scene alloc] init];
    [scene addChild:object];
    
    Formula* transparency =[[Formula alloc] init];
    FormulaElement* formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"20";
    transparency.formulaTree = formulaTree;

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    SetGhostEffectBrick* brick = [[SetGhostEffectBrick alloc]init];
    brick.script = script;
    brick.transparency = transparency;
    
    dispatch_block_t action = [brick actionBlock];
    action();
    
    
    XCTAssertEqual(object.alpha, 0.8f, @"ShowBrick is not correctly calculated");
}

-(void)testSetGhostEffectBrickNegative
{
    SpriteObject* object = [[SpriteObject alloc] init];
    object.position = CGPointMake(0, 0);
    
    Scene* scene = [[Scene alloc] init];
    [scene addChild:object];
    
    Formula* transparency =[[Formula alloc] init];
    FormulaElement* formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"-20";
    transparency.formulaTree = formulaTree;

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    SetGhostEffectBrick* brick = [[SetGhostEffectBrick alloc]init];
    brick.script = script;
    brick.transparency = transparency;
    
    dispatch_block_t action = [brick actionBlock];
    action();
    
    
    XCTAssertEqual(object.alpha, 1.0f, @"ShowBrick is not correctly calculated");
}

- (void)testSetGhostEffectBrickWronginput
{
    SpriteObject* object = [[SpriteObject alloc] init];
    object.position = CGPointMake(0, 0);
    object.alpha = 1.0f;
    
    Scene* scene = [[Scene alloc] init];
    [scene addChild:object];
    
    Formula* transparency =[[Formula alloc] init];
    FormulaElement* formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"a";
    transparency.formulaTree = formulaTree;

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    SetGhostEffectBrick* brick = [[SetGhostEffectBrick alloc]init];
    brick.script = script;
    brick.transparency = transparency;
    
    dispatch_block_t action = [brick actionBlock];
    action();
    
    XCTAssertEqual(object.alpha, 1.0f, @"ShowBrick is not correctly calculated");
}


@end
