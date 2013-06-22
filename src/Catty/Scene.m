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

#import "Scene.h"
#import "Program.h"
#import "SpriteObject.h"
#import "Script.h"


#define kMinTimeInterval (1.0f / 60.0f)


@interface Scene()

@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;

@end


@implementation Scene


- (id) initWithSize:(CGSize)size andProgram:(Program *)program
{
    if (self = [super initWithSize:size]) {
        self.program = program;
        [self startProgram];
    }
    return self;
}



-(void) startProgram
{
    
    for (SpriteObject *obj in self.program.objectList) {
        [self addChild:obj];
        [obj start];
        [obj setUserInteractionEnabled:YES];
    }    
}


-(void)update:(CFTimeInterval)currentTime {
        
//    // Handle time delta.
//    // If we drop below 60fps, we still want everything to move the same distance.
//    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
//    self.lastUpdateTimeInterval = currentTime;
//    if (timeSinceLast > 1) { // more than a second since last update
//        timeSinceLast = kMinTimeInterval;
//        self.lastUpdateTimeInterval = currentTime;
//    }
//    
//    [self updateWithTimeSinceLastUpdate:timeSinceLast];
}

#pragma mark - Loop Update
- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {

    // Update the caves (and in turn, their goblins).
    for (SpriteObject *obj in self.program.objectList) {
        [obj updateWithTimeSinceLastUpdate:timeSinceLast];
    }
}


-(CGPoint)convertPointToScene:(CGPoint)point
{
    CGPoint scenePoint;
    scenePoint.x = [self convertXCoordinateToScene:point.x];
    scenePoint.y = [self convertYCoordinateToScene:point.y];
    
    return scenePoint;
}

-(float)convertYCoordinateToScene:(float)y {
    return (self.size.height/2.0f + y);
}

-(float)convertXCoordinateToScene:(float)x {
    return (self.scene.size.width/2.0f + x);
}

-(CGPoint)convertSceneCoordinateToPoint:(CGPoint)point
{
    float x = point.x - self.scene.size.width/2.0f;
    float y = point.y - self.scene.size.height/2.0f;
    return CGPointMake(x, y);
}

-(CGFloat) convertDegreesToScene:(CGFloat)degrees
{
    
    degrees = fmodf(degrees, 360.0);
    if((degrees >= 0.0 && degrees < 90.0) || (degrees >= 180.0 && degrees < 270.0)) {
        return degrees + 90.0;
        
    }
    if((degrees >= 90.0 && degrees < 180.0) || (degrees >= 270.0 && degrees < 360.0)) {
        return degrees - 90.0;
    }
    
    return 0.0;
}


@end
