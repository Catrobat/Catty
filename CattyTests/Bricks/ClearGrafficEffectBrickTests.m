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
#import "WhenScript.h"
#import "Pocket_Code-Swift.h"

@interface ClearGrafficEffectBrickTests : AbstractBrickTests
@end

@implementation ClearGrafficEffectBrickTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testClearGraphicEffectBrick
{
    SpriteObject *object = [[SpriteObject alloc] init];
    Project *project = [Project defaultProjectWithName:@"a" projectID:nil];
    object.project = project;
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    
    [self.scene addChild:spriteNode];
    spriteNode.catrobatPosition = CGPointMake(0.0f, 0.0f);

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *filePath = [bundle pathForResource:@"test.png" ofType:nil];
    NSData *imageData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:filePath]);
    Look* look = [[Look alloc] initWithName:@"test" andPath:@"test.png"];
    [imageData writeToFile:[NSString stringWithFormat:@"%@images/%@", [object projectPath], @"test.png"]atomically:YES];

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    SetTransparencyBrick *brick = [[SetTransparencyBrick alloc] init];
    brick.script = script;
    [object.lookList addObject:look];
    [object.lookList addObject:look];
    object.spriteNode.currentLook = look;
    object.spriteNode.currentUIImageLook = [UIImage imageWithContentsOfFile:filePath];
    object.spriteNode.catrobatBrightness = 10;
    object.spriteNode.catrobatTransparency = 10;
    brick.script = script;
    brick.transparency = [[Formula alloc] initWithInteger:20];
    
    XCTAssertNotEqualWithAccuracy(spriteNode.ciBrightness, BrightnessSensor.defaultRawValue, 0.0001f);
    XCTAssertNotEqualWithAccuracy(spriteNode.alpha, TransparencySensor.defaultRawValue, 0.0001f);

    dispatch_block_t action = [brick actionBlock:self.formulaInterpreter];
    action();

    ClearGraphicEffectBrick* clearBrick = [[ClearGraphicEffectBrick alloc]init];
    clearBrick.script = script;
    action = [clearBrick actionBlock];
    action();

    XCTAssertEqualWithAccuracy(spriteNode.alpha, TransparencySensor.defaultRawValue, 0.0001f, @"ClearGraphic alpha is not correctly calculated");
    XCTAssertEqualWithAccuracy(spriteNode.ciBrightness, BrightnessSensor.defaultRawValue, 0.0001f, @"ClearGraphic brightness is not correctly calculated");
    [Project removeProjectFromDiskWithProjectName:project.header.programName projectID:project.header.programID];
}

- (void)testClearGraphicEffectBrick2
{
    SpriteObject *object = [[SpriteObject alloc] init];
    Project *project = [Project defaultProjectWithName:@"a" projectID:nil];
    object.project = project;
    CBSpriteNode *spriteNode = [[CBSpriteNode alloc] initWithSpriteObject:object];
    object.spriteNode = spriteNode;
    
    [self.scene addChild:spriteNode];
    spriteNode.catrobatPosition = CGPointMake(0.0f, 0.0f);

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString * filePath = [bundle pathForResource:@"test.png" ofType:nil];
    NSData *imageData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:filePath]);
    Look* look = [[Look alloc] initWithName:@"test" andPath:@"test.png"];
    [imageData writeToFile:[NSString stringWithFormat:@"%@images/%@", [object projectPath], @"test.png"]atomically:YES];

    Formula *transparency = [[Formula alloc] init];
    FormulaElement *formulaTree  = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"-20";
    transparency.formulaTree = formulaTree;

    Script *script = [[WhenScript alloc] init];
    script.object = object;

    SetTransparencyBrick *brick = [[SetTransparencyBrick alloc]init];
    brick.script = script;
    [object.lookList addObject:look];
    [object.lookList addObject:look];
    object.spriteNode.currentLook = look;
    object.spriteNode.currentUIImageLook = [UIImage imageWithContentsOfFile:filePath];
    object.spriteNode.catrobatTransparency = 10;
    object.spriteNode.catrobatBrightness = 10;
    brick.script = script;
    brick.transparency = transparency;
    
    XCTAssertNotEqualWithAccuracy(spriteNode.alpha, TransparencySensor.defaultRawValue, 0.001f);
    XCTAssertNotEqualWithAccuracy(spriteNode.ciBrightness, BrightnessSensor.defaultRawValue, 0.001f);

    dispatch_block_t action = [brick actionBlock:self.formulaInterpreter];
    action();

    ClearGraphicEffectBrick* clearBrick = [[ClearGraphicEffectBrick alloc]init];
    clearBrick.script = script;

    action = [clearBrick actionBlock];
    action();

    XCTAssertEqualWithAccuracy(spriteNode.alpha, TransparencySensor.defaultRawValue, 0.0001f, @"ClearGraphic is not correctly calculated");
    XCTAssertEqualWithAccuracy(spriteNode.ciBrightness, BrightnessSensor.defaultRawValue, 0.0001f, @"ClearGraphic brightness is not correctly calculated");
    [Project removeProjectFromDiskWithProjectName:project.header.programName projectID:project.header.programID];
}

@end
