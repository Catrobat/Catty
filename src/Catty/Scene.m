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

#import "Scene.H"
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
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        
        myLabel.text = @"Hello, World!";
        myLabel.fontSize = 30;
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                       CGRectGetMidY(self.frame));
        
        [self addChild:myLabel];
                
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
    
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = kMinTimeInterval;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
}

#pragma mark - Loop Update
- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {

    // Update the caves (and in turn, their goblins).
    for (SpriteObject *obj in self.program.objectList) {
        [obj updateWithTimeSinceLastUpdate:timeSinceLast];
    }
}


-(CGPoint)sceneCoordinatesForPoint:(CGPoint)point
{
    CGPoint scenePoint;
    scenePoint.x = [self sceneCoordinateForXCoordinate:point.x];
    scenePoint.y = [self sceneCoordinateForYCoordinate:point.y];
    
    return scenePoint;
}

-(float)sceneCoordinateForYCoordinate:(float)y {
    return (self.size.height/2.0f - y);
}

-(float)sceneCoordinateForXCoordinate:(float)x {
    return (self.scene.size.width  / 2.0f + x);
}


@end
