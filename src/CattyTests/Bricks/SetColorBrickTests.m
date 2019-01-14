/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

@interface SetColorBrickTests : AbstractBrickTests
@end

@implementation SetColorBrickTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testSetColorBrickLower
{
    SpriteObject* object = [[SpriteObject alloc] init];
    Project *project = [Project defaultProjectWithName:@"a" projectID:nil];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    object.project = project;
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString * filePath = [bundle pathForResource:@"test.png" ofType:nil];
    NSData *imageData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:filePath]);
    Look* look = [[Look alloc] initWithName:@"test" andPath:@"test.png"];
    [imageData writeToFile:[NSString stringWithFormat:@"%@images/%@", [object projectPath], @"test.png"]atomically:YES];
    
    Script *script = [[WhenScript alloc] init];
    script.object = object;
    SetColorBrick *brick = [[SetColorBrick alloc] init];
    brick.script = script;
    [object.lookList addObject:look];
    [object.lookList addObject:look];
    object.spriteNode.currentLook = look;
    object.spriteNode.currentUIImageLook = [UIImage imageWithContentsOfFile:filePath];
    object.spriteNode.catrobatColor = 0.0;
    
    brick.color = [[Formula alloc] initWithInteger:-60];
    
    dispatch_block_t action = [brick actionBlock:self.formulaInterpreter];
    action();
    
    XCTAssertEqualWithAccuracy(200.0-60.0f, spriteNode.catrobatColor, 0.1f, @"SetColorBrick - Color not correct");
    
    [Project removeProjectFromDiskWithProjectName:project.header.programName projectID:project.header.programID];
}

- (void)testSetColorBrickHigher
{
    SpriteObject* object = [[SpriteObject alloc] init];
    Project *project = [Project defaultProjectWithName:@"a" projectID:nil];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    object.project = project;
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString * filePath = [bundle pathForResource:@"test.png" ofType:nil];
    NSData *imageData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:filePath]);
    Look* look = [[Look alloc] initWithName:@"test" andPath:@"test.png"];
    [imageData writeToFile:[NSString stringWithFormat:@"%@images/%@", [object projectPath], @"test.png"]atomically:YES];
    
    Script *script = [[WhenScript alloc] init];
    script.object = object;
    SetColorBrick *brick = [[SetColorBrick alloc] init];
    brick.script = script;
    [object.lookList addObject:look];
    [object.lookList addObject:look];
    object.spriteNode.currentLook = look;
    object.spriteNode.currentUIImageLook = [UIImage imageWithContentsOfFile:filePath];
    object.spriteNode.catrobatColor = 0.0;
    
    brick.color = [[Formula alloc] initWithInteger:140];
    
    dispatch_block_t action = [brick actionBlock:self.formulaInterpreter];
    action();
    
    XCTAssertEqualWithAccuracy(140.0f, spriteNode.catrobatColor, 0.1f, @"SetColorBrick - Color not correct");
    
    [Project removeProjectFromDiskWithProjectName:project.header.programName projectID:project.header.programID];
}

- (void)testSetColorBrickMoreThan2Pi
{
    SpriteObject* object = [[SpriteObject alloc] init];
    Project *project = [Project defaultProjectWithName:@"a" projectID:nil];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    object.project = project;
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString * filePath = [bundle pathForResource:@"test.png" ofType:nil];
    NSData *imageData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:filePath]);
    Look* look = [[Look alloc] initWithName:@"test" andPath:@"test.png"];
    [imageData writeToFile:[NSString stringWithFormat:@"%@images/%@", [object projectPath], @"test.png"]atomically:YES];
    
    Script *script = [[WhenScript alloc] init];
    script.object = object;
    SetColorBrick *brick = [[SetColorBrick alloc] init];
    brick.script = script;
    [object.lookList addObject:look];
    [object.lookList addObject:look];
    object.spriteNode.currentLook = look;
    object.spriteNode.currentUIImageLook = [UIImage imageWithContentsOfFile:filePath];
    object.spriteNode.catrobatColor = 0.0;
    
    brick.color = [[Formula alloc] initWithInteger:230];
    
    dispatch_block_t action = [brick actionBlock:self.formulaInterpreter];
    action();
    
    XCTAssertEqualWithAccuracy(30.0f, spriteNode.catrobatColor, 0.1f, @"SetColorBrick - Color not correct");
    [Project removeProjectFromDiskWithProjectName:project.header.programName projectID:project.header.programID];
}

- (void)testSetColorBrickWrongInput
{
    SpriteObject *object = [[SpriteObject alloc] init];
    Project *project = [Project defaultProjectWithName:@"a" projectID:nil];
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    object.project = project;
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = [bundle pathForResource:@"test.png" ofType:nil];
    NSData *imageData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:filePath]);
    Look *look = [[Look alloc] initWithName:@"test" andPath:@"test.png"];
    [imageData writeToFile:[NSString stringWithFormat:@"%@images/%@", [object projectPath], @"test.png"] atomically:YES];
    
    Script *script = [[WhenScript alloc] init];
    script.object = object;
    
    SetColorBrick *brick = [[SetColorBrick alloc] init];
    brick.script = script;
    [object.lookList addObject:look];
    [object.lookList addObject:look];
    object.spriteNode.currentLook = look;
    object.spriteNode.currentUIImageLook = [UIImage imageWithContentsOfFile:filePath];
    
    brick.color = [[Formula alloc] initWithString:@"a"];
    
    dispatch_block_t action = [brick actionBlock:self.formulaInterpreter];
    action();
    
    XCTAssertEqualWithAccuracy(0.0f, spriteNode.catrobatColor, 0.1f, @"SetColorBrick - Color not correct");
    
    [Project removeProjectFromDiskWithProjectName:project.header.programName projectID:project.header.programID];
}

@end
