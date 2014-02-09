/**
 *  Copyright (C) 2010-2013 The Catrobat Team
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

@interface SetBrightnessBrickTests : BrickTests

@end

@implementation SetBrightnessBrickTests

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


-(void)testSetBrightnessBrickDarker
{
#warning Problem with texture -> don't have a image to test
    //    SpriteObject* object = [[SpriteObject alloc] init];
    //
    //    SetBrightnessBrick* brick = [[SetBrightnessBrick alloc] init];
    //    brick.object = object;
    //    object.texture = [SKTexture textureWithImageNamed:@"icon.png"];
    //
    //
    //    Formula* brightness = [[Formula alloc] init];
    //    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    //    formulaTree.type = NUMBER;
    //    formulaTree.value = @"30";
    //    brightness.formulaTree = formulaTree;
    //    brick.brightness = brightness;
    //
    //    dispatch_block_t action = [brick actionBlock];
    //
    //    action();
    //
    //    XCTAssertEqual([object currentLookBrightness], -70f, @"SetBrightnessBrick - Brightness not correct");
}

-(void)testSetBrightnessBrickBrighter
{
    
    //    SpriteObject* object = [[SpriteObject alloc] init];
    //
    //
    //    SetBrightnessBrick* brick = [[SetBrightnessBrick alloc] init];
    //    brick.object = object;
    //
    //    Formula* brightness = [[Formula alloc] init];
    //    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    //    formulaTree.type = NUMBER;
    //    formulaTree.value = @"130";
    //    brightness.formulaTree = formulaTree;
    //    brick.brightness = brightness;
    //
    //    dispatch_block_t action = [brick actionBlock];
    //
    //    action();
    //
    //    XCTAssertEqual([object currentLookBrightness], 130f, @"SetBrightnessBrick - Brightness not correct");
}
-(void)testSetBrightnessBrickTooBright
{
    
    //        SpriteObject* object = [[SpriteObject alloc] init];
    //
    //        SetBrightnessBrick* brick = [[SetBrightnessBrick alloc] init];
    //        brick.object = object;
    //
    //        Formula* brightness = [[Formula alloc] init];
    //        FormulaElement* formulaTree = [[FormulaElement alloc] init];
    //        formulaTree.type = NUMBER;
    //        formulaTree.value = @"-80";
    //        brightness.formulaTree = formulaTree;
    //        brick.brightness = brightness;
    //
    //    dispatch_block_t action = [brick actionBlock];
    //
    //    action();
    //    XCTAssertEqual([object currentLookBrightness], -100f, @"SetBrightnessBrick - Brightness not correct");
}
-(void)testSetBrightnessBrickTooDark
{
    
    //    SpriteObject* object = [[SpriteObject alloc] init];
    //
    //
    //    SetBrightnessBrick* brick = [[SetBrightnessBrick alloc] init];
    //    brick.object = object;
    //
    //    Formula* brightness = [[Formula alloc] init];
    //    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    //    formulaTree.type = NUMBER;
    //    formulaTree.value = @"300";
    //    brightness.formulaTree = formulaTree;
    //    brick.brightness = brightness;
    //
    //    dispatch_block_t action = [brick actionBlock];
    //
    //    action();
    //
    //    XCTAssertEqual([object currentLookBrightness], 100f, @"SetBrightnessBrick - Brightness not correct");
}
-(void)testSetBrightnessBrickWrongInput
{
    
    //    SpriteObject* object = [[SpriteObject alloc] init];
    //
    //
    //    SetBrightnessBrick* brick = [[SetBrightnessBrick alloc] init];
    //    brick.object = object;
    //
    //    Formula* brightness = [[Formula alloc] init];
    //    FormulaElement* formulaTree = [[FormulaElement alloc] init];
    //    formulaTree.type = NUMBER;
    //    formulaTree.value = @"a";
    //    brightness.formulaTree = formulaTree;
    //    brick.brightness = brightness;
    //
    //    dispatch_block_t action = [brick actionBlock];
    //
    //    action();
    //
    //    XCTAssertEqual([object currentLookBrightness], 0.0f, @"SetBrightnessBrick - Brightness not correct");
}




@end
