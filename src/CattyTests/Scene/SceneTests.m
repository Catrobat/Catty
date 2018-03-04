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

#import "SceneTests.h"
#import "Pocket_Code-Swift.h"

@interface SceneTests()
@property (nonatomic, strong) CBScene *scene;
@property (nonatomic) CGSize screenSize;

@property (nonatomic) CGPoint pocketCodeCenter;
@property (nonatomic) CGPoint pocketCodeBottomLeft;
@property (nonatomic) CGPoint pocketCodeBottomRight;
@property (nonatomic) CGPoint pocketCodeTopLeft;
@property (nonatomic) CGPoint pocketCodeTopRight;

@property (nonatomic) CGPoint sceneCenter;
@property (nonatomic) CGPoint sceneBottomLeft;
@property (nonatomic) CGPoint sceneBottomRight;
@property (nonatomic) CGPoint sceneTopLeft;
@property (nonatomic) CGPoint sceneTopRight;
@end

@implementation SceneTests

#define EPSILON 0.001

- (void)setUp
{
    [super setUp];
    self.scene = [[CBScene alloc] initWithSize:CGSizeMake(480, 800)];
    self.screenSize = [Util screenSize];
    
    self.pocketCodeCenter = CGPointMake(0, 0);
    self.pocketCodeBottomLeft = CGPointMake(-240, -400);
    self.pocketCodeBottomRight = CGPointMake(240, -400);
    self.pocketCodeTopLeft = CGPointMake(-240, 400);
    self.pocketCodeTopRight = CGPointMake(240, 400);
    
    self.sceneCenter = CGPointMake(240, 400);
    self.sceneBottomLeft = CGPointMake(0, 0);
    self.sceneBottomRight = CGPointMake(480, 0);
    self.sceneTopLeft = CGPointMake(0, 800);
    self.sceneTopRight = CGPointMake(480, 800);
}

- (void)tearDown
{
    [super tearDown];
}

#pragma mark - Coordinate System
#pragma mark Pocket Code to Scene

- (void)testPointConversionCenter
{
    CGPoint convertedCenter = [[CBSceneHelper class] convertPointToScene:self.pocketCodeCenter sceneSize:self.scene.size];
    XCTAssertTrue(CGPointEqualToPoint(convertedCenter, self.sceneCenter), @"The Scene Center is not correctly calculated");
}

- (void)testPointConversionBottomLeft
{
    CGPoint convertedBottomLeft = [[CBSceneHelper class] convertPointToScene:self.pocketCodeBottomLeft sceneSize:self.scene.size];
    XCTAssertTrue(CGPointEqualToPoint(convertedBottomLeft, self.sceneBottomLeft), @"The Bottom Left is not correctly calculated");
}

- (void)testPointConversionBottomRight
{
    CGPoint convertedBottomRight = [[CBSceneHelper class] convertPointToScene:self.pocketCodeBottomRight sceneSize:self.scene.size];
    XCTAssertTrue(CGPointEqualToPoint(convertedBottomRight, self.sceneBottomRight), @"The Bottom Right is not correctly calculated");
}

- (void)testPointConversionTopLeft
{
    CGPoint convertedTopLeft = [[CBSceneHelper class] convertPointToScene:self.pocketCodeTopLeft sceneSize:self.scene.size];
    XCTAssertTrue(CGPointEqualToPoint(convertedTopLeft, self.sceneTopLeft), @"The Top Left is not correctly calculated");
}

- (void)testPointConversionTopRight
{
    CGPoint convertedTopRight = [[CBSceneHelper class] convertPointToScene:self.pocketCodeTopRight sceneSize:self.scene.size];
    XCTAssertTrue(CGPointEqualToPoint(convertedTopRight, self.sceneTopRight), @"The Top Right is not correctly calculated");
}

#pragma mark Scene to Pocked Code
- (void)testSceneConversionCenter
{
    CGPoint convertedCenter = [[CBSceneHelper class] convertPointToScene:self.pocketCodeCenter sceneSize:self.scene.size];
    XCTAssertTrue(CGPointEqualToPoint(convertedCenter, self.sceneCenter), @"The Scene Center is not correctly calculated");
}

- (void)testSceneConversionBottomLeft
{
    CGPoint convertedBottomLeft = [[CBSceneHelper class] convertSceneCoordinateToPoint:self.sceneBottomLeft sceneSize:self.scene.size];
    XCTAssertTrue(CGPointEqualToPoint(convertedBottomLeft, self.pocketCodeBottomLeft), @"The Bottom Left is not correctly calculated");
}

- (void)testSceneConversionBottomRight
{
    CGPoint convertedBottomRight = [[CBSceneHelper class] convertSceneCoordinateToPoint:self.sceneBottomRight sceneSize:self.scene.size];
    XCTAssertTrue(CGPointEqualToPoint(convertedBottomRight, self.pocketCodeBottomRight), @"The Bottom Right is not correctly calculated");
}

- (void)testSceneConversionTopLeft
{
    CGPoint convertedTopLeft = [[CBSceneHelper class] convertSceneCoordinateToPoint:self.sceneTopLeft sceneSize:self.scene.size];
    XCTAssertTrue(CGPointEqualToPoint(convertedTopLeft, self.pocketCodeTopLeft), @"The Top Left is not correctly calculated");
}

- (void)testSceneConversionTopRight
{
    CGPoint convertedTopRight = [[CBSceneHelper class] convertSceneCoordinateToPoint:self.sceneTopRight sceneSize:self.scene.size];
    XCTAssertTrue(CGPointEqualToPoint(convertedTopRight, self.pocketCodeTopRight), @"The Top Right is not correctly calculated");
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
    XCTAssertEqual(135, [[CBSceneHelper class] convertSceneToDegrees:-45], @"Conversion between scene and degrees is not correctly calculated");
    XCTAssertEqual(135, [[CBSceneHelper class] convertSceneToDegrees:-405], @"Conversion between scene and degrees is not correctly calculated");
    XCTAssertEqual(-90, [[CBSceneHelper class] convertSceneToDegrees:180], @"Conversion between scene and degrees is not correctly calculated");
    XCTAssertEqual(-180, [[CBSceneHelper class] convertSceneToDegrees:-90], @"Conversion between scene and degrees is not correctly calculated");
    XCTAssertEqual(0, [[CBSceneHelper class] convertSceneToDegrees:-270], @"Conversion between scene and degrees is not correctly calculated");
    XCTAssertEqual(180, [[CBSceneHelper class] convertSceneToDegrees:270], @"Conversion between scene and degrees is not correctly calculated");
    XCTAssertEqual(180, [[CBSceneHelper class] convertSceneToDegrees:630], @"Conversion between scene and degrees is not correctly calculated");
}

#pragma mark Touch to Pocked Code
- (void)testTouchConversionCenter
{
    CBScene *scaledScene = [[CBScene alloc] initWithSize:CGSizeMake(self.screenSize.width * 2, self.screenSize.height * 2)];
    CGPoint scaledSceneCenter = CGPointMake(self.screenSize.width/2, self.screenSize.height/2);
    CGPoint convertedCenter = [CBSceneHelper convertTouchCoordinateToPointWithCoordinate:scaledSceneCenter sceneSize:scaledScene.size];
    
    XCTAssertTrue(CGPointEqualToPoint(convertedCenter, self.pocketCodeCenter), @"The Scene Center is not correctly calculated");
}

- (void)testTouchConversionCenterNoScale
{
    CBScene *scaledScene = [[CBScene alloc] initWithSize:CGSizeMake(self.screenSize.width, self.screenSize.height)];
    CGPoint scaledSceneCenter = CGPointMake(self.screenSize.width/2, self.screenSize.height/2);
    CGPoint convertedCenter = [CBSceneHelper convertTouchCoordinateToPointWithCoordinate:scaledSceneCenter sceneSize:scaledScene.size];
    
    XCTAssertTrue(CGPointEqualToPoint(convertedCenter, self.pocketCodeCenter), @"The Scene Center is not correctly calculated");
}

- (void)testTouchConversionBottomLeft
{
    CBScene *scaledScene = [[CBScene alloc] initWithSize:CGSizeMake(self.screenSize.width * 2, self.screenSize.height * 2)];
    CGPoint scaledSceneBottomLeft = CGPointMake(0, self.screenSize.height);
    CGPoint pocketCodeBottomLeft = CGPointMake(scaledScene.size.width / 2 * -1, scaledScene.size.height / 2 * -1);
    CGPoint convertedBottomLeft = [CBSceneHelper convertTouchCoordinateToPointWithCoordinate:scaledSceneBottomLeft sceneSize:scaledScene.size];
    XCTAssertTrue(CGPointEqualToPoint(convertedBottomLeft, pocketCodeBottomLeft), @"The Bottom Left is not correctly calculated");
}

- (void)testTouchConversionBottomRight
{
    CBScene *scaledScene = [[CBScene alloc] initWithSize:CGSizeMake(self.screenSize.width * 2, self.screenSize.height * 2)];
    CGPoint scaledSceneBottomRight = CGPointMake(self.screenSize.width, self.screenSize.height);
    CGPoint pocketCodeBottomRight = CGPointMake(scaledScene.size.width / 2, scaledScene.size.height / 2 * -1);
    CGPoint convertedBottomRight = [CBSceneHelper convertTouchCoordinateToPointWithCoordinate:scaledSceneBottomRight sceneSize:scaledScene.size];
    XCTAssertTrue(CGPointEqualToPoint(convertedBottomRight, pocketCodeBottomRight), @"The Bottom Right is not correctly calculated");
}

- (void)testTouchConversionTopLeft
{
    CBScene *scaledScene = [[CBScene alloc] initWithSize:CGSizeMake(self.screenSize.width * 2, self.screenSize.height * 2)];
    CGPoint scaledSceneTopLeft = CGPointMake(0, 0);
    CGPoint pocketCodeTopLeft = CGPointMake(scaledScene.size.width / 2 * -1, scaledScene.size.height / 2);
    CGPoint convertedTopLeft = [CBSceneHelper convertTouchCoordinateToPointWithCoordinate:scaledSceneTopLeft sceneSize:scaledScene.size];
    XCTAssertTrue(CGPointEqualToPoint(convertedTopLeft, pocketCodeTopLeft), @"The Top Left is not correctly calculated");
}

- (void)testTouchConversionTopRight
{
    CBScene *scaledScene = [[CBScene alloc] initWithSize:CGSizeMake(self.screenSize.width * 2, self.screenSize.height * 2)];
    CGPoint scaledSceneTopRight = CGPointMake(self.screenSize.width, 0);
    CGPoint pocketCodeTopRight = CGPointMake(scaledScene.size.width / 2, scaledScene.size.height / 2);
    CGPoint convertedTopRight = [CBSceneHelper convertTouchCoordinateToPointWithCoordinate:scaledSceneTopRight sceneSize:scaledScene.size];
    XCTAssertTrue(CGPointEqualToPoint(convertedTopRight, pocketCodeTopRight), @"The Top Right is not correctly calculated");
}

@end
