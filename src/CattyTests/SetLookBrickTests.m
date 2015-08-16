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
#import "Pocket_Code-Swift.h"

@interface SetLookBrickTests : BrickTests
@end

@implementation SetLookBrickTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSetLookBrick
{
//    SpriteObject *object = [[SpriteObject alloc] init];
//    Program *program = [Program defaultProgramWithName:@"a" programID:nil];
//    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
//    object.spriteNode = spriteNode;
//    CBPlayerScene *scene = [[CBPlayerScene alloc] init];
//    [scene addChild:spriteNode];
//    object.program = program;
//
//    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
//    NSString * filePath = [bundle pathForResource:@"test.png" ofType:nil];
//    NSData *imageData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:filePath]);
//    Look *look = [[Look alloc] initWithName:@"test" andPath:@"test.png"];
//    [imageData writeToFile:[NSString stringWithFormat:@"%@images/%@", [object projectPath], @"test.png"]atomically:YES];
//    Look *look1 = [[Look alloc] initWithName:@"test2" andPath:@"test2.png"];
//    [imageData writeToFile:[NSString stringWithFormat:@"%@images/%@", [object projectPath], @"test2.png"]atomically:YES];
//
//    Script *script = [[WhenScript alloc] init];
//    script.object = object;
//    NextLookBrick *brick = [[NextLookBrick alloc] init];
//    brick.script = script;
//    [object.lookList addObject:look];
//    [object.lookList addObject:look1];
//    object.spriteNode.currentLook = nil;
//    object.spriteNode.currentUIImageLook = [UIImage imageWithContentsOfFile:filePath];
//    object.spriteNode.currentLookBrightness = 0.0f;
//    dispatch_block_t action = [brick actionBlock];
//    action();
//    XCTAssertEqual(spriteNode.currentLook, look, @"NextLookBrick not correct");
//    [Program removeProgramFromDiskWithProgramName:program.header.programName programID:program.header.programID];
}

- (void)testSetLookBrick2
{
//    SpriteObject* object = [[SpriteObject alloc] init];
//    Program *program = [Program defaultProgramWithName:@"a" programID:nil];
//    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
//    object.spriteNode = spriteNode;
//    CBPlayerScene *scene = [[CBPlayerScene alloc] init];
//    [scene addChild:spriteNode];
//    object.program = program;
//
//    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
//    NSString *filePath = [bundle pathForResource:@"test.png" ofType:nil];
//    NSData *imageData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:filePath]);
//    Look* look = [[Look alloc] initWithName:@"test" andPath:@"test.png"];
//    [imageData writeToFile:[NSString stringWithFormat:@"%@images/%@", [object projectPath], @"test.png"]atomically:YES];
//    Look* look1 = [[Look alloc] initWithName:@"test2" andPath:@"test2.png"];
//    [imageData writeToFile:[NSString stringWithFormat:@"%@images/%@", [object projectPath], @"test2.png"]atomically:YES];
//
//    Script *script = [[WhenScript alloc] init];
//    script.object = object;
//
//    NextLookBrick* brick = [[NextLookBrick alloc] init];
//    brick.script = script;
//    [object.lookList addObject:look1];
//    [object.lookList addObject:look];
//    spriteNode.currentLook = nil;
//    spriteNode.currentUIImageLook = [UIImage imageWithContentsOfFile:filePath];
//    spriteNode.currentLookBrightness = 0.0f;
//
//    dispatch_block_t action = [brick actionBlock];
//    action();
//    XCTAssertEqual(spriteNode.currentLook,look1, @"NextLookBrick not correct");
//    [Program removeProgramFromDiskWithProgramName:program.header.programName programID:program.header.programID];
}

@end
