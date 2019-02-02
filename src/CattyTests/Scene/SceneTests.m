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

#import "SceneTests.h"
#import "ProjectMock.h"
#import "Pocket_Code-Swift.h"

@interface SceneTests()
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

- (void)setUp
{
    [super setUp];
    self.screenSize = [Util screenSize: false];
    
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

#pragma mark Touch to Pocked Code
- (void)testTouchConversionCenter
{
    CBScene *scaledScene = [[[SceneBuilder alloc] initWithProject:[[ProjectMock alloc] initWithWidth:self.screenSize.width * 2 andHeight: self.screenSize.height * 2]] build];
    CGPoint scaledSceneCenter = CGPointMake(self.screenSize.width/2, self.screenSize.height/2);
    CGPoint convertedCenter = [CBSceneHelper convertTouchCoordinateToPointWithCoordinate:scaledSceneCenter sceneSize:scaledScene.size];
    
    XCTAssertTrue(CGPointEqualToPoint(convertedCenter, self.pocketCodeCenter), @"The Scene Center is not correctly calculated");
}

- (void)testTouchConversionCenterNoScale
{
    CBScene *scaledScene = [[[SceneBuilder alloc] initWithProject:[[ProjectMock alloc] initWithWidth:self.screenSize.width andHeight: self.screenSize.height]] build];
    CGPoint scaledSceneCenter = CGPointMake(self.screenSize.width/2, self.screenSize.height/2);
    CGPoint convertedCenter = [CBSceneHelper convertTouchCoordinateToPointWithCoordinate:scaledSceneCenter sceneSize:scaledScene.size];
    
    XCTAssertTrue(CGPointEqualToPoint(convertedCenter, self.pocketCodeCenter), @"The Scene Center is not correctly calculated");
}

- (void)testTouchConversionBottomLeft
{
    CBScene *scaledScene = [[[SceneBuilder alloc] initWithProject:[[ProjectMock alloc] initWithWidth:self.screenSize.width * 2 andHeight: self.screenSize.height * 2]] build];
    CGPoint scaledSceneBottomLeft = CGPointMake(0, self.screenSize.height);
    CGPoint pocketCodeBottomLeft = CGPointMake(scaledScene.size.width / 2 * -1, scaledScene.size.height / 2 * -1);
    CGPoint convertedBottomLeft = [CBSceneHelper convertTouchCoordinateToPointWithCoordinate:scaledSceneBottomLeft sceneSize:scaledScene.size];
    XCTAssertTrue(CGPointEqualToPoint(convertedBottomLeft, pocketCodeBottomLeft), @"The Bottom Left is not correctly calculated");
}

- (void)testTouchConversionBottomRight
{
    CBScene *scaledScene = [[[SceneBuilder alloc] initWithProject:[[ProjectMock alloc] initWithWidth:self.screenSize.width * 2 andHeight: self.screenSize.height * 2]] build];
    CGPoint scaledSceneBottomRight = CGPointMake(self.screenSize.width, self.screenSize.height);
    CGPoint pocketCodeBottomRight = CGPointMake(scaledScene.size.width / 2, scaledScene.size.height / 2 * -1);
    CGPoint convertedBottomRight = [CBSceneHelper convertTouchCoordinateToPointWithCoordinate:scaledSceneBottomRight sceneSize:scaledScene.size];
    XCTAssertTrue(CGPointEqualToPoint(convertedBottomRight, pocketCodeBottomRight), @"The Bottom Right is not correctly calculated");
}

- (void)testTouchConversionTopLeft
{
    CBScene *scaledScene = [[[SceneBuilder alloc] initWithProject:[[ProjectMock alloc] initWithWidth:self.screenSize.width * 2 andHeight: self.screenSize.height * 2]] build];
    CGPoint scaledSceneTopLeft = CGPointMake(0, 0);
    CGPoint pocketCodeTopLeft = CGPointMake(scaledScene.size.width / 2 * -1, scaledScene.size.height / 2);
    CGPoint convertedTopLeft = [CBSceneHelper convertTouchCoordinateToPointWithCoordinate:scaledSceneTopLeft sceneSize:scaledScene.size];
    XCTAssertTrue(CGPointEqualToPoint(convertedTopLeft, pocketCodeTopLeft), @"The Top Left is not correctly calculated");
}

- (void)testTouchConversionTopRight
{
    CBScene *scaledScene = [[[SceneBuilder alloc] initWithProject:[[ProjectMock alloc] initWithWidth:self.screenSize.width * 2 andHeight: self.screenSize.height * 2]] build];
    CGPoint scaledSceneTopRight = CGPointMake(self.screenSize.width, 0);
    CGPoint pocketCodeTopRight = CGPointMake(scaledScene.size.width / 2, scaledScene.size.height / 2);
    CGPoint convertedTopRight = [CBSceneHelper convertTouchCoordinateToPointWithCoordinate:scaledSceneTopRight sceneSize:scaledScene.size];
    XCTAssertTrue(CGPointEqualToPoint(convertedTopRight, pocketCodeTopRight), @"The Top Right is not correctly calculated");
}

- (void)testVariableLabel
{
    Project *project = [[ProjectMock alloc] initWithWidth:self.screenSize.width andHeight: self.screenSize.height];
    CBScene *scene = [[[SceneBuilder alloc] initWithProject:project] build];
    
    UserVariable *userVariable = [[UserVariable alloc] init];
    [project.variables.programVariableList addObject:userVariable];
    
    XCTAssertNil(userVariable.textLabel);
    
    bool isStarted = [scene startProject];
    
    XCTAssertTrue(isStarted);
    XCTAssertNotNil(userVariable.textLabel);
    XCTAssertTrue(userVariable.textLabel.isHidden);
    XCTAssertEqual(SKLabelHorizontalAlignmentModeLeft, userVariable.textLabel.horizontalAlignmentMode);
    XCTAssertEqual(kSceneLabelFontSize, userVariable.textLabel.fontSize);
    XCTAssertEqual(0, [userVariable.textLabel.text length]);
}

@end
