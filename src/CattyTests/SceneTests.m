/**
 *  Copyright (C) 2010-2013 The Catrobat Team
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

- (void)test_PointConversionCenter
{
    
    Scene* scene = [[Scene alloc] initWithSize:CGSizeMake(480, 800)];
    CGPoint pocketCodeCenter = CGPointMake(0, 0);
    CGPoint sceneCenter = CGPointMake(240, 400);
    CGPoint convertedCenter = [scene convertPointToScene:pocketCodeCenter];
    
    XCTAssertEquals(convertedCenter, sceneCenter, @"The Scene Center is not correctly calculated");
}

- (void)test_PointConversionBottomLeft
{
    
    Scene* scene = [[Scene alloc] initWithSize:CGSizeMake(480, 800)];
    CGPoint pocketCodeBottomLeft = CGPointMake(-240, -400);
    CGPoint sceneBottomLeft = CGPointMake(0, 0);
    CGPoint convertedBottomLeft = [scene convertPointToScene:pocketCodeBottomLeft];
    
    XCTAssertEquals(convertedBottomLeft, sceneBottomLeft, @"The Bottom Left is not correctly calculated");
}

- (void)test_PointConversionBottomRight
{
    Scene* scene = [[Scene alloc] initWithSize:CGSizeMake(480, 800)];
    CGPoint pocketCodeBottomRight = CGPointMake(240, -400);
    CGPoint sceneBottomRight = CGPointMake(480, 0);
    CGPoint convertedBottomRight = [scene convertPointToScene:pocketCodeBottomRight];
    
    XCTAssertEquals(convertedBottomRight, sceneBottomRight, @"The Bottom Right is not correctly calculated");
}

- (void)test_PointConversionTopLeft
{
    Scene* scene = [[Scene alloc] initWithSize:CGSizeMake(480, 800)];
    CGPoint pocketCodeTopLeft = CGPointMake(-240, 400);
    CGPoint sceneTopLeft = CGPointMake(0, 800);
    CGPoint convertedTopLeft = [scene convertPointToScene:pocketCodeTopLeft];
    
    XCTAssertEquals(convertedTopLeft, sceneTopLeft, @"The Top Left is not correctly calculated");
}

- (void)test_PointConversionTopRight
{
    Scene* scene = [[Scene alloc] initWithSize:CGSizeMake(480, 800)];
    CGPoint pocketCodeTopRight = CGPointMake(240, 400);
    CGPoint sceneTopRight = CGPointMake(480, 800);
    CGPoint convertedTopRight = [scene convertPointToScene:pocketCodeTopRight];
    
    XCTAssertEquals(convertedTopRight, sceneTopRight, @"The Top Right is not correctly calculated");
}

#pragma mark Scene to Pocked Code
- (void)test_SceneConversionCenter
{
    
    Scene* scene = [[Scene alloc] initWithSize:CGSizeMake(480, 800)];
    CGPoint pocketCodeCenter = CGPointMake(0, 0);
    CGPoint sceneCenter = CGPointMake(240, 400);
    CGPoint convertedCenter = [scene convertPointToScene:pocketCodeCenter];
    
    XCTAssertEquals(convertedCenter, sceneCenter, @"The Scene Center is not correctly calculated");
}

- (void)test_SceneConversionBottomLeft
{
    
    Scene* scene = [[Scene alloc] initWithSize:CGSizeMake(480, 800)];
    CGPoint pocketCodeBottomLeft = CGPointMake(-240, -400);
    CGPoint sceneBottomLeft = CGPointMake(0, 0);
    CGPoint convertedBottomLeft = [scene convertSceneCoordinateToPoint:sceneBottomLeft];
    
    XCTAssertEquals(convertedBottomLeft, pocketCodeBottomLeft, @"The Bottom Left is not correctly calculated");
}

- (void)test_SceneConversionBottomRight
{
    Scene* scene = [[Scene alloc] initWithSize:CGSizeMake(480, 800)];
    CGPoint pocketCodeBottomRight = CGPointMake(240, -400);
    CGPoint sceneBottomRight = CGPointMake(480, 0);
    CGPoint convertedBottomRight = [scene convertSceneCoordinateToPoint:sceneBottomRight];
    
    XCTAssertEquals(convertedBottomRight, pocketCodeBottomRight, @"The Bottom Right is not correctly calculated");
}

- (void)test_SceneConversionTopLeft
{
    Scene* scene = [[Scene alloc] initWithSize:CGSizeMake(480, 800)];
    CGPoint pocketCodeTopLeft = CGPointMake(-240, 400);
    CGPoint sceneTopLeft = CGPointMake(0, 800);
    CGPoint convertedTopLeft = [scene convertSceneCoordinateToPoint:sceneTopLeft];
    
    XCTAssertEquals(convertedTopLeft, pocketCodeTopLeft, @"The Top Left is not correctly calculated");
}

- (void)test_SceneConversionTopRight
{
    Scene* scene = [[Scene alloc] initWithSize:CGSizeMake(480, 800)];
    CGPoint pocketCodeTopRight = CGPointMake(240, 400);
    CGPoint sceneTopRight = CGPointMake(480, 800);
    CGPoint convertedTopRight = [scene convertSceneCoordinateToPoint:sceneTopRight];
    
    XCTAssertEquals(convertedTopRight, pocketCodeTopRight, @"The Top Right is not correctly calculated");
}




@end
