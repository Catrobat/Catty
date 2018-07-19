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
#import "Look.h"
#import "WhenScript.h"
#import "Pocket_Code-Swift.h"

@interface SetBrightnessBrickTests : AbstractBrickTests
@property (nonatomic, strong) BrightnessSensor* brightnessSensor;
@end

@implementation SetBrightnessBrickTests

- (void)setUp
{
    [super setUp];
    self.brightnessSensor = [BrightnessSensor new];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testSetBrightnessBrick
{
    SpriteObject* object = [[SpriteObject alloc] init];
    Program *program = [Program defaultProgramWithName:@"a" programID:nil];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    object.program = program;

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString * filePath = [bundle pathForResource:@"test.png" ofType:nil];
    NSData *imageData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:filePath]);
    Look* look = [[Look alloc] initWithName:@"test" andPath:@"test.png"];
    [imageData writeToFile:[NSString stringWithFormat:@"%@images/%@", [object projectPath], @"test.png"]atomically:YES];

    Script *script = [[WhenScript alloc] init];
    script.object = object;
    SetBrightnessBrick *brick = [[SetBrightnessBrick alloc] init];
    brick.script = script;
    [object.lookList addObject:look];
    [object.lookList addObject:look];
    object.spriteNode.currentLook = look;
    object.spriteNode.currentUIImageLook = [UIImage imageWithContentsOfFile:filePath];

    Formula *brightness = [[Formula alloc] init];
    FormulaElement *formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"180";
    brightness.formulaTree = formulaTree;
    brick.brightness = brightness;

    dispatch_block_t action = [brick actionBlock];
    action();
    
    CGFloat userInput = [self.brightnessSensor convertToStandardizedWithRawValue:spriteNode.ciBrightness];
    XCTAssertEqualWithAccuracy(180.0f, userInput, 0.1f, @"SetBrightnessBrick - Brightness not correct");
    [Program removeProgramFromDiskWithProgramName:program.header.programName programID:program.header.programID];
}

- (void)testSetBrightnessBrickNegative
{
    SpriteObject *object = [[SpriteObject alloc] init];
    Program *program = [Program defaultProgramWithName:@"a" programID:nil];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    object.program = program;

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = [bundle pathForResource:@"test.png" ofType:nil];
    NSData *imageData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:filePath]);
    Look* look = [[Look alloc] initWithName:@"test" andPath:@"test.png"];
    [imageData writeToFile:[NSString stringWithFormat:@"%@images/%@", [object projectPath], @"test.png"] atomically:YES];

    Script *script = [[WhenScript alloc] init];
    script.object = object;
    SetBrightnessBrick *brick = [[SetBrightnessBrick alloc] init];
    brick.script = script;
    [object.lookList addObject:look];
    [object.lookList addObject:look];
    object.spriteNode.currentLook = look;
    object.spriteNode.currentUIImageLook = [UIImage imageWithContentsOfFile:filePath];

    Formula *brightness = [[Formula alloc] init];
    FormulaElement *formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"-10";
    brightness.formulaTree = formulaTree;
    brick.brightness = brightness;

    dispatch_block_t action = [brick actionBlock];
    action();
    
    CGFloat userInput = [self.brightnessSensor convertToStandardizedWithRawValue:spriteNode.ciBrightness];
    XCTAssertEqualWithAccuracy(0.0f, userInput, 0.1f ,@"SetBrightnessBrick - Brightness not correct");
    [Program removeProgramFromDiskWithProgramName:program.header.programName programID:program.header.programID];
}

- (void)testSetBrightnessBrickTooBright
{
    SpriteObject *object = [[SpriteObject alloc] init];
    Program *program = [Program defaultProgramWithName:@"a" programID:nil];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    object.program = program;

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = [bundle pathForResource:@"test.png" ofType:nil];
    NSData *imageData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:filePath]);
    Look *look = [[Look alloc] initWithName:@"test" andPath:@"test.png"];
    [imageData writeToFile:[NSString stringWithFormat:@"%@images/%@", [object projectPath], @"test.png"]atomically:YES];

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    SetBrightnessBrick *brick = [[SetBrightnessBrick alloc] init];
    brick.script = script;
    [object.lookList addObject:look];
    [object.lookList addObject:look];
    object.spriteNode.currentLook = look;
    object.spriteNode.currentUIImageLook = [UIImage imageWithContentsOfFile:filePath];
    
    Formula *brightness = [[Formula alloc] init];
    FormulaElement *formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"210";
    brightness.formulaTree = formulaTree;
    brick.brightness = brightness;

    dispatch_block_t action = [brick actionBlock];
    action();
    
    CGFloat userInput = [self.brightnessSensor convertToStandardizedWithRawValue:spriteNode.ciBrightness];
    XCTAssertEqualWithAccuracy(200.0f, userInput, 0.1f, @"SetBrightnessBrick - Brightness not correct");
    [Program removeProgramFromDiskWithProgramName:program.header.programName programID:program.header.programID];
}

- (void)testSetBrightnessBrickWrongInput
{
    SpriteObject *object = [[SpriteObject alloc] init];
    Program *program = [Program defaultProgramWithName:@"a" programID:nil];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    object.program = program;

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = [bundle pathForResource:@"test.png" ofType:nil];
    NSData *imageData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:filePath]);
    Look *look = [[Look alloc] initWithName:@"test" andPath:@"test.png"];
    [imageData writeToFile:[NSString stringWithFormat:@"%@images/%@", [object projectPath], @"test.png"] atomically:YES];

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    SetBrightnessBrick *brick = [[SetBrightnessBrick alloc] init];
    brick.script = script;
    [object.lookList addObject:look];
    [object.lookList addObject:look];
    object.spriteNode.currentLook = look;
    object.spriteNode.currentUIImageLook = [UIImage imageWithContentsOfFile:filePath];
    object.spriteNode.ciBrightness = [self.brightnessSensor convertToRawWithStandardizedValue:100];

    Formula *brightness = [[Formula alloc] init];
    FormulaElement *formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"a";
    brightness.formulaTree = formulaTree;
    brick.brightness = brightness;

    dispatch_block_t action = [brick actionBlock];
    action();
    
    CGFloat userInput = [self.brightnessSensor convertToStandardizedWithRawValue:spriteNode.ciBrightness];
    XCTAssertEqualWithAccuracy(0.0f, userInput, 0.1f, @"SetBrightnessBrick - Brightness not correct");
    
    [Program removeProgramFromDiskWithProgramName:program.header.programName programID:program.header.programID];
}

@end
