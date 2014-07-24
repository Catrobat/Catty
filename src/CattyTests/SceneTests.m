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


#import "SceneTests.h"
#import "Scene.h"

@implementation SceneTests

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
    
    Scene* scene = [[Scene alloc] initWithSize:CGSizeMake(480, 800)];
    CGPoint pocketCodeCenter = CGPointMake(0, 0);
    CGPoint sceneCenter = CGPointMake(240, 400);
    CGPoint convertedCenter = [scene convertPointToScene:pocketCodeCenter];
    
    
   XCTAssertTrue(CGPointEqualToPoint(convertedCenter, sceneCenter), @"The Scene Center is not correctly calculated");
}

- (void)testPointConversionBottomLeft
{
    
    Scene* scene = [[Scene alloc] initWithSize:CGSizeMake(480, 800)];
    CGPoint pocketCodeBottomLeft = CGPointMake(-240, -400);
    CGPoint sceneBottomLeft = CGPointMake(0, 0);
    CGPoint convertedBottomLeft = [scene convertPointToScene:pocketCodeBottomLeft];
    
    XCTAssertTrue(CGPointEqualToPoint(convertedBottomLeft, sceneBottomLeft), @"The Bottom Left is not correctly calculated");
}

- (void)testPointConversionBottomRight
{
    Scene* scene = [[Scene alloc] initWithSize:CGSizeMake(480, 800)];
    CGPoint pocketCodeBottomRight = CGPointMake(240, -400);
    CGPoint sceneBottomRight = CGPointMake(480, 0);
    CGPoint convertedBottomRight = [scene convertPointToScene:pocketCodeBottomRight];
    
    XCTAssertTrue(CGPointEqualToPoint(convertedBottomRight, sceneBottomRight), @"The Bottom Right is not correctly calculated");
}

- (void)testPointConversionTopLeft
{
    Scene* scene = [[Scene alloc] initWithSize:CGSizeMake(480, 800)];
    CGPoint pocketCodeTopLeft = CGPointMake(-240, 400);
    CGPoint sceneTopLeft = CGPointMake(0, 800);
    CGPoint convertedTopLeft = [scene convertPointToScene:pocketCodeTopLeft];
    
    XCTAssertTrue(CGPointEqualToPoint(convertedTopLeft, sceneTopLeft), @"The Top Left is not correctly calculated");
}

- (void)testPointConversionTopRight
{
    Scene* scene = [[Scene alloc] initWithSize:CGSizeMake(480, 800)];
    CGPoint pocketCodeTopRight = CGPointMake(240, 400);
    CGPoint sceneTopRight = CGPointMake(480, 800);
    CGPoint convertedTopRight = [scene convertPointToScene:pocketCodeTopRight];
    
    XCTAssertTrue(CGPointEqualToPoint(convertedTopRight, sceneTopRight), @"The Top Right is not correctly calculated");
}

#pragma mark Scene to Pocked Code
- (void)testSceneConversionCenter
{
    
    Scene* scene = [[Scene alloc] initWithSize:CGSizeMake(480, 800)];
    CGPoint pocketCodeCenter = CGPointMake(0, 0);
    CGPoint sceneCenter = CGPointMake(240, 400);
    CGPoint convertedCenter = [scene convertPointToScene:pocketCodeCenter];
    
    XCTAssertTrue(CGPointEqualToPoint(convertedCenter, sceneCenter), @"The Scene Center is not correctly calculated");
}

- (void)testSceneConversionBottomLeft
{
    
    Scene* scene = [[Scene alloc] initWithSize:CGSizeMake(480, 800)];
    CGPoint pocketCodeBottomLeft = CGPointMake(-240, -400);
    CGPoint sceneBottomLeft = CGPointMake(0, 0);
    CGPoint convertedBottomLeft = [scene convertSceneCoordinateToPoint:sceneBottomLeft];
    
    XCTAssertTrue(CGPointEqualToPoint(convertedBottomLeft, pocketCodeBottomLeft), @"The Bottom Left is not correctly calculated");
}

- (void)testSceneConversionBottomRight
{
    Scene* scene = [[Scene alloc] initWithSize:CGSizeMake(480, 800)];
    CGPoint pocketCodeBottomRight = CGPointMake(240, -400);
    CGPoint sceneBottomRight = CGPointMake(480, 0);
    CGPoint convertedBottomRight = [scene convertSceneCoordinateToPoint:sceneBottomRight];
    
    XCTAssertTrue(CGPointEqualToPoint(convertedBottomRight, pocketCodeBottomRight), @"The Bottom Right is not correctly calculated");
}

- (void)testSceneConversionTopLeft
{
    Scene* scene = [[Scene alloc] initWithSize:CGSizeMake(480, 800)];
    CGPoint pocketCodeTopLeft = CGPointMake(-240, 400);
    CGPoint sceneTopLeft = CGPointMake(0, 800);
    CGPoint convertedTopLeft = [scene convertSceneCoordinateToPoint:sceneTopLeft];
    
    XCTAssertTrue(CGPointEqualToPoint(convertedTopLeft, pocketCodeTopLeft), @"The Top Left is not correctly calculated");
}

- (void)testSceneConversionTopRight
{
    Scene* scene = [[Scene alloc] initWithSize:CGSizeMake(480, 800)];
    CGPoint pocketCodeTopRight = CGPointMake(240, 400);
    CGPoint sceneTopRight = CGPointMake(480, 800);
    CGPoint convertedTopRight = [scene convertSceneCoordinateToPoint:sceneTopRight];
    
    XCTAssertTrue(CGPointEqualToPoint(convertedTopRight, pocketCodeTopRight), @"The Top Right is not correctly calculated");
}




@end
