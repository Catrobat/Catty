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



@interface Scene()

@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;

@end


@implementation Scene

- (id) initWithSize:(CGSize)size andProgram:(Program *)program
{
    if (self = [super initWithSize:size]) {
        self.program = program;
        self.backgroundColor = [UIColor whiteColor];
        [self startProgram];
    }
    return self;
}

-(void)dealloc
{
    NSDebug(@"Dealloc Scene");
}

-(void)startProgram
{
    CGFloat zPosition = 1;
    for (SpriteObject *obj in self.program.objectList) {
        [self addChild:obj];
         //NSDebug(@"%f",zPosition);
        [obj start:zPosition];
        [obj setLook];
        [obj setProgram:self.program];
        [obj setUserInteractionEnabled:YES];
        zPosition++;
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
    return 360.0 - degrees;
}

-(CGFloat) convertSceneToDegrees:(CGFloat)degrees
{
    return 360.0 + degrees;
}



@end
