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

@interface ChangeBrightnessByNBrickTests : AbstractBrickTests
@end

@implementation ChangeBrightnessByNBrickTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testChangeBrightnessByNBrick
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
    
    ChangeBrightnessByNBrick *brick = [[ChangeBrightnessByNBrick alloc] init];
    brick.script = script;
    [object.lookList addObject:look];
    [object.lookList addObject:look];
    object.spriteNode.currentLook = look;
    object.spriteNode.currentUIImageLook = [UIImage imageWithContentsOfFile:filePath];
    object.spriteNode.catrobatBrightness = 0.0;
    
    brick.changeBrightness = [[Formula alloc] initWithInteger:100];
    
    dispatch_block_t action = [brick actionBlock:self.formulaInterpreter];
    action();
    
    XCTAssertEqualWithAccuracy(100.0f, spriteNode.catrobatBrightness, 0.1f, @"ChangeBrightnessBrick - Brightness not correct");
    
    [Program removeProgramFromDiskWithProgramName:program.header.programName programID:program.header.programID];
}

- (void)testChangeBrightnessByNBrickWrongInput
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
    
    ChangeBrightnessByNBrick *brick = [[ChangeBrightnessByNBrick alloc] init];
    brick.script = script;
    [object.lookList addObject:look];
    [object.lookList addObject:look];
    object.spriteNode.currentLook = look;
    object.spriteNode.currentUIImageLook = [UIImage imageWithContentsOfFile:filePath];
    object.spriteNode.catrobatBrightness = 100.0;
    
    brick.changeBrightness = [[Formula alloc] initWithString:@"a"];
    
    dispatch_block_t action = [brick actionBlock:self.formulaInterpreter];
    action();
    
    XCTAssertEqualWithAccuracy(100.0f, spriteNode.catrobatBrightness, 0.1f, @"ChangeBrightnessBrick - Brightness not correct");
    
    [Program removeProgramFromDiskWithProgramName:program.header.programName programID:program.header.programID];
}

- (void)testChangeBrightnessByNBrickPositive
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
    
    ChangeBrightnessByNBrick* brick = [[ChangeBrightnessByNBrick alloc] init];
    brick.script = script;
    [object.lookList addObject:look];
    [object.lookList addObject:look];
    object.spriteNode.currentLook = look;
    object.spriteNode.currentUIImageLook = [UIImage imageWithContentsOfFile:filePath];
    object.spriteNode.catrobatBrightness = 0.0;
    
    brick.changeBrightness = [[Formula alloc] initWithInteger:50];
    
    dispatch_block_t action = [brick actionBlock:self.formulaInterpreter];
    action();
    
    XCTAssertEqualWithAccuracy(50.0f, spriteNode.catrobatBrightness, 0.1f, @"ChangeBrightnessBrick - Brightness not correct");
    
    [Program removeProgramFromDiskWithProgramName:program.header.programName programID:program.header.programID];
}

- (void)testChangeBrightnessByNBrickNegative
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
    
    ChangeBrightnessByNBrick* brick = [[ChangeBrightnessByNBrick alloc] init];
    brick.script = script;
    [object.lookList addObject:look];
    [object.lookList addObject:look];
    object.spriteNode.currentLook = look;
    object.spriteNode.currentUIImageLook = [UIImage imageWithContentsOfFile:filePath];
    object.spriteNode.catrobatBrightness = 100.0;
    
    brick.changeBrightness = [[Formula alloc] initWithInteger:-50];
    
    dispatch_block_t action = [brick actionBlock:self.formulaInterpreter];
    action();
    
    XCTAssertEqualWithAccuracy(50.0f, spriteNode.catrobatBrightness, 0.1f, @"ChangeBrightnessBrick - Brightness not correct");
    
    [Program removeProgramFromDiskWithProgramName:program.header.programName programID:program.header.programID];
}

@end
