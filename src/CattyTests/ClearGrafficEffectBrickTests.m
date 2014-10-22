/**
 *  Copyright (C) 2010-2014 The Catrobat Team
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

@interface ClearGrafficEffectBrickTests : BrickTests

@end

@implementation ClearGrafficEffectBrickTests

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

-(void)testClearGraphicEffectBrick
{
    
    SpriteObject* object = [[SpriteObject alloc] init];
    Program *program = [Program defaultProgramWithName:@"a" programID:nil];
    object.program = program;
    object.position = CGPointMake(0.0f, 0.0f);
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString * filePath = [bundle pathForResource:@"test.png"
                                           ofType:nil];
    NSData *imageData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:filePath]);
    Look* look = [[Look alloc] initWithName:@"test" andPath:@"test.png"];
    [imageData writeToFile:[NSString stringWithFormat:@"%@images/%@", [object projectPath], @"test.png"]atomically:YES];
    
    Formula* transparency =[[Formula alloc] init];
    FormulaElement* formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"20";
    transparency.formulaTree = formulaTree;
    
    
    SetGhostEffectBrick* brick = [[SetGhostEffectBrick alloc]init];
    brick.object = object;
    [object.lookList addObject:look];
    [object.lookList addObject:look];
    object.currentLook = look;
    object.currentUIImageLook = [UIImage imageWithContentsOfFile:filePath];
    object.currentLookBrightness = 1.0f;
    brick.object = object;
    brick.transparency = transparency;
    
    
    
    dispatch_block_t action = [brick actionBlock];
    
    action();
    
    ClearGraphicEffectBrick* clearBrick = [[ClearGraphicEffectBrick alloc]init];
    clearBrick.object = object;

    action = [clearBrick actionBlock];
    action();

    
    XCTAssertEqualWithAccuracy([object alpha], 1.0,0.0001f, @"ClearGraphic is not correctly calculated");
    [Program removeProgramFromDiskWithProgramName:program.header.programName programID:program.header.programID];
}

-(void)testClearGraphicEffectBrick2
{
    SpriteObject* object = [[SpriteObject alloc] init];
    Program *program = [Program defaultProgramWithName:@"a" programID:program.header.programID];
    object.program = program;
    object.position = CGPointMake(0.0f, 0.0f);
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString * filePath = [bundle pathForResource:@"test.png"
                                           ofType:nil];
    NSData *imageData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:filePath]);
    Look* look = [[Look alloc] initWithName:@"test" andPath:@"test.png"];
    [imageData writeToFile:[NSString stringWithFormat:@"%@images/%@", [object projectPath], @"test.png"]atomically:YES];
    
    Formula* transparency =[[Formula alloc] init];
    FormulaElement* formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"-20";
    transparency.formulaTree = formulaTree;
    
    
    SetGhostEffectBrick* brick = [[SetGhostEffectBrick alloc]init];
    brick.object = object;
    [object.lookList addObject:look];
    [object.lookList addObject:look];
    object.currentLook = look;
    object.currentUIImageLook = [UIImage imageWithContentsOfFile:filePath];
    object.currentLookBrightness = 1.0f;
    brick.object = object;
    brick.transparency = transparency;
    
    
    
    dispatch_block_t action = [brick actionBlock];
    
    action();
    
    ClearGraphicEffectBrick* clearBrick = [[ClearGraphicEffectBrick alloc]init];
    clearBrick.object = object;
    
    action = [clearBrick actionBlock];
    action();
    
    
    XCTAssertEqualWithAccuracy([object alpha], 1.0,0.0001f, @"ClearGraphic is not correctly calculated");
    [Program removeProgramFromDiskWithProgramName:program.header.programName programID:program.header.programID];
}


-(void)testClearGraphicEffectBrick3
{
    SpriteObject* object = [[SpriteObject alloc] init];
    Program *program = [Program defaultProgramWithName:@"a" programID:nil];
    object.program = program;
    object.position = CGPointMake(0.0f, 0.0f);
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString * filePath = [bundle pathForResource:@"test.png"
                                           ofType:nil];
    NSData *imageData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:filePath]);
    Look* look = [[Look alloc] initWithName:@"test" andPath:@"test.png"];
    [imageData writeToFile:[NSString stringWithFormat:@"%@images/%@", [object projectPath], @"test.png"]atomically:YES];
    
    Formula* brightness =[[Formula alloc] init];
    FormulaElement* formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"50";
    brightness.formulaTree = formulaTree;
    
    
    SetBrightnessBrick* brick = [[SetBrightnessBrick alloc]init];
    brick.object = object;
    [object.lookList addObject:look];
    [object.lookList addObject:look];
    object.currentLook = look;
    object.currentUIImageLook = [UIImage imageWithContentsOfFile:filePath];
    object.currentLookBrightness = 1.0f;
    brick.object = object;
    brick.brightness = brightness;
    
    
    dispatch_block_t action = [brick actionBlock];
    
    action();
    
    ClearGraphicEffectBrick* clearBrick = [[ClearGraphicEffectBrick alloc]init];
    clearBrick.object = object;
    
    action = [clearBrick actionBlock];
    action();
    
    
    XCTAssertEqualWithAccuracy([object brightness], 0.0f,0.0001f, @"ClearGraphic is not correctly calculated");
    [Program removeProgramFromDiskWithProgramName:program.header.programName programID:program.header.programID];
}

@end
