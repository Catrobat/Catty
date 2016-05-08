/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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

#import "SceneTests.h"
#import "Pocket_Code-Swift.h"

@implementation SceneTests

#define EPSILON 0.001

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

#pragma mark - Coordinate System
#pragma mark Pocket Code to Scene

- (void)testPointConversionCenter
{
    CBScene *scene = [[CBScene alloc] initWithSize:CGSizeMake(480, 800)];
    CGPoint pocketCodeCenter = CGPointMake(0, 0);
    CGPoint sceneCenter = CGPointMake(240, 400);
    CGPoint convertedCenter = [[CBSceneHelper class] convertPointToScene:pocketCodeCenter sceneSize:scene.size];
    XCTAssertTrue(CGPointEqualToPoint(convertedCenter, sceneCenter), @"The Scene Center is not correctly calculated");
}

- (void)testPointConversionBottomLeft
{
    CBScene *scene = [[CBScene alloc] initWithSize:CGSizeMake(480, 800)];
    CGPoint pocketCodeBottomLeft = CGPointMake(-240, -400);
    CGPoint sceneBottomLeft = CGPointMake(0, 0);
    CGPoint convertedBottomLeft = [[CBSceneHelper class] convertPointToScene:pocketCodeBottomLeft sceneSize:scene.size];
    
    XCTAssertTrue(CGPointEqualToPoint(convertedBottomLeft, sceneBottomLeft), @"The Bottom Left is not correctly calculated");
}

- (void)testPointConversionBottomRight
{
    CBScene *scene = [[CBScene alloc] initWithSize:CGSizeMake(480, 800)];
    CGPoint pocketCodeBottomRight = CGPointMake(240, -400);
    CGPoint sceneBottomRight = CGPointMake(480, 0);
    CGPoint convertedBottomRight = [[CBSceneHelper class] convertPointToScene:pocketCodeBottomRight sceneSize:scene.size];
    XCTAssertTrue(CGPointEqualToPoint(convertedBottomRight, sceneBottomRight), @"The Bottom Right is not correctly calculated");
}

- (void)testPointConversionTopLeft
{
    CBScene *scene = [[CBScene alloc] initWithSize:CGSizeMake(480, 800)];
    CGPoint pocketCodeTopLeft = CGPointMake(-240, 400);
    CGPoint sceneTopLeft = CGPointMake(0, 800);
    CGPoint convertedTopLeft = [[CBSceneHelper class] convertPointToScene:pocketCodeTopLeft sceneSize:scene.size];
    XCTAssertTrue(CGPointEqualToPoint(convertedTopLeft, sceneTopLeft), @"The Top Left is not correctly calculated");
}

- (void)testPointConversionTopRight
{
    CBScene *scene = [[CBScene alloc] initWithSize:CGSizeMake(480, 800)];
    CGPoint pocketCodeTopRight = CGPointMake(240, 400);
    CGPoint sceneTopRight = CGPointMake(480, 800);
    CGPoint convertedTopRight = [[CBSceneHelper class] convertPointToScene:pocketCodeTopRight sceneSize:scene.size];
    XCTAssertTrue(CGPointEqualToPoint(convertedTopRight, sceneTopRight), @"The Top Right is not correctly calculated");
}

#pragma mark Scene to Pocked Code
- (void)testSceneConversionCenter
{
    CBScene *scene = [[CBScene alloc] initWithSize:CGSizeMake(480, 800)];
    CGPoint pocketCodeCenter = CGPointMake(0, 0);
    CGPoint sceneCenter = CGPointMake(240, 400);
    CGPoint convertedCenter = [[CBSceneHelper class] convertPointToScene:pocketCodeCenter sceneSize:scene.size];
    
    XCTAssertTrue(CGPointEqualToPoint(convertedCenter, sceneCenter), @"The Scene Center is not correctly calculated");
}

- (void)testSceneConversionBottomLeft
{
    CBScene *scene = [[CBScene alloc] initWithSize:CGSizeMake(480, 800)];
    CGPoint pocketCodeBottomLeft = CGPointMake(-240, -400);
    CGPoint sceneBottomLeft = CGPointMake(0, 0);
    CGPoint convertedBottomLeft = [[CBSceneHelper class] convertSceneCoordinateToPoint:sceneBottomLeft sceneSize:scene.size];
    XCTAssertTrue(CGPointEqualToPoint(convertedBottomLeft, pocketCodeBottomLeft), @"The Bottom Left is not correctly calculated");
}

- (void)testSceneConversionBottomRight
{
    CBScene *scene = [[CBScene alloc] initWithSize:CGSizeMake(480, 800)];
    CGPoint pocketCodeBottomRight = CGPointMake(240, -400);
    CGPoint sceneBottomRight = CGPointMake(480, 0);
    CGPoint convertedBottomRight = [[CBSceneHelper class] convertSceneCoordinateToPoint:sceneBottomRight sceneSize:scene.size];
    XCTAssertTrue(CGPointEqualToPoint(convertedBottomRight, pocketCodeBottomRight), @"The Bottom Right is not correctly calculated");
}

- (void)testSceneConversionTopLeft
{
    CBScene *scene = [[CBScene alloc] initWithSize:CGSizeMake(480, 800)];
    CGPoint pocketCodeTopLeft = CGPointMake(-240, 400);
    CGPoint sceneTopLeft = CGPointMake(0, 800);
    CGPoint convertedTopLeft = [[CBSceneHelper class] convertSceneCoordinateToPoint:sceneTopLeft sceneSize:scene.size];
    XCTAssertTrue(CGPointEqualToPoint(convertedTopLeft, pocketCodeTopLeft), @"The Top Left is not correctly calculated");
}

- (void)testSceneConversionTopRight
{
    CBScene *scene = [[CBScene alloc] initWithSize:CGSizeMake(480, 800)];
    CGPoint pocketCodeTopRight = CGPointMake(240, 400);
    CGPoint sceneTopRight = CGPointMake(480, 800);
    CGPoint convertedTopRight = [[CBSceneHelper class] convertSceneCoordinateToPoint:sceneTopRight sceneSize:scene.size];
    XCTAssertTrue(CGPointEqualToPoint(convertedTopRight, pocketCodeTopRight), @"The Top Right is not correctly calculated");
}

- (void)testDegreesToScene
{
    XCTAssertEqual(90, [[CBSceneHelper class] convertDegreesToScene:0], @"Conversion between degrees and scene is not correctly calculated");
    XCTAssertEqual(0, [[CBSceneHelper class] convertDegreesToScene:90], @"Conversion between degrees and scene is not correctly calculated");
    XCTAssertEqual(45, [[CBSceneHelper class] convertDegreesToScene:45], @"Conversion between degrees and scene is not correctly calculated");
    XCTAssertEqual(-225, [[CBSceneHelper class] convertDegreesToScene:-45], @"Conversion between degrees and scene is not correctly calculated");
    XCTAssertEqual(-225, [[CBSceneHelper class] convertDegreesToScene:-405], @"Conversion between degrees and scene is not correctly calculated");
    XCTAssertEqual(270, [[CBSceneHelper class] convertDegreesToScene:180], @"Conversion between degrees and scene is not correctly calculated");
    XCTAssertEqual(-180, [[CBSceneHelper class] convertDegreesToScene:-90], @"Conversion between degrees and scene is not correctly calculated");
    XCTAssertEqual(0, [[CBSceneHelper class] convertDegreesToScene:-270], @"Conversion between degrees and scene is not correctly calculated");
    XCTAssertEqual(180, [[CBSceneHelper class] convertDegreesToScene:270], @"Conversion between degrees and scene is not correctly calculated");
    XCTAssertEqual(180, [[CBSceneHelper class] convertDegreesToScene:630], @"Conversion between degrees and scene is not correctly calculated");
}

- (void)testSceneToDegrees
{
    XCTAssertEqual(90, [[CBSceneHelper class] convertSceneToDegrees:0], @"Conversion between scene and degrees is not correctly calculated");
    XCTAssertEqual(0, [[CBSceneHelper class] convertSceneToDegrees:90], @"Conversion between scene and degrees is not correctly calculated");
    XCTAssertEqual(45, [[CBSceneHelper class] convertSceneToDegrees:45], @"Conversion between scene and degrees is not correctly calculated");
    XCTAssertEqual(-225, [[CBSceneHelper class] convertSceneToDegrees:-45], @"Conversion between scene and degrees is not correctly calculated");
    XCTAssertEqual(-225, [[CBSceneHelper class] convertSceneToDegrees:-405], @"Conversion between scene and degrees is not correctly calculated");
    XCTAssertEqual(-90, [[CBSceneHelper class] convertSceneToDegrees:180], @"Conversion between scene and degrees is not correctly calculated");
    XCTAssertEqual(-180, [[CBSceneHelper class] convertSceneToDegrees:-90], @"Conversion between scene and degrees is not correctly calculated");
    XCTAssertEqual(0, [[CBSceneHelper class] convertSceneToDegrees:-270], @"Conversion between scene and degrees is not correctly calculated");
    XCTAssertEqual(180, [[CBSceneHelper class] convertSceneToDegrees:270], @"Conversion between scene and degrees is not correctly calculated");
    XCTAssertEqual(180, [[CBSceneHelper class] convertSceneToDegrees:630], @"Conversion between scene and degrees is not correctly calculated");
}

@end
