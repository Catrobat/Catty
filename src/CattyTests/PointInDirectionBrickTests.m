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

@interface PointInDirectionBrickTests : BrickTests

@end

@implementation PointInDirectionBrickTests

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

-(void)testPointInDirectionBrick
{
    SpriteObject* object = [[SpriteObject alloc] init];
    object.position = CGPointMake(0, 0);
    
    Scene* scene = [[Scene alloc] init];
    [scene addChild:object];
    
    Formula* degrees =[[Formula alloc] init];
    FormulaElement* formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"20";
    degrees.formulaTree = formulaTree;

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    PointInDirectionBrick* brick = [[PointInDirectionBrick alloc]init];
    brick.script = script;
    brick.degrees = degrees;

    dispatch_block_t action = [brick actionBlock];
    action();
    XCTAssertEqual(object.zRotation, (float)((360-(-70))*M_PI/180), @"PointInDirectionBrick is not correctly calculated");
}

@end
