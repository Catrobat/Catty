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

#import "Scene.h"
#import "Program.h"
#import "SpriteObject.h"
#import "StartScript.h"

@implementation Scene

- (id)initWithSize:(CGSize)size andProgram:(Program *)program
{
    if (self = [super initWithSize:size]) {
        self.program = program;
        self.backgroundColor = [UIColor whiteColor];
        self.numberOfObjectsWithoutBackground = 0;
    }
    return self;
}

-(void)dealloc
{
    NSDebug(@"Dealloc Scene");
}

- (void)willMoveFromView:(SKView *)view
{
    self.numberOfObjectsWithoutBackground = 0;
    [self removeAllChildren];
    [self removeAllActions];
}

- (void)didMoveToView:(SKView *)view
{
    [self startProgram];
}

- (void)startProgram
{
    CGFloat zPosition = 1.0f;
    [self removeAllChildren]; // just to ensure
    for (SpriteObject *obj in self.program.objectList) {
        [self addChild:obj];
        NSDebug(@"%f",zPosition);
        [obj start:zPosition];
        [obj setLook];
        obj.program = self.program;
        obj.userInteractionEnabled = YES;
        if (! ([obj isBackground])) {
            zPosition++;
            self.numberOfObjectsWithoutBackground++;
        }
    }
    // TODO: replace numberOfObjectsWithoutBackground-property by [obj.program numberOfNormalObjects]
    for (SpriteObject *obj in self.program.objectList) {
        obj.numberOfObjectsWithoutBackground = self.numberOfObjectsWithoutBackground;
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf startStartScript:obj];
        });
        
        
    }
}


-(void)startStartScript:(SpriteObject*)obj
{
    for (Script *script in obj.scriptList)
    {
        if ([script isKindOfClass:[StartScript class]]) {
            
            __weak typeof(SpriteObject*) weakSelf = obj;
//            dispatch_queue_t backgroundQueue = dispatch_queue_create("at.catrobat.startScript", 0);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [weakSelf startAndAddScript:script completion:^{
                    [weakSelf scriptFinished:script];
                    NSDebug(@"FINISHED");
                }];
            });
            
        }
    }
}

-(CGPoint)convertPointToScene:(CGPoint)point
{
    CGPoint scenePoint;
    scenePoint.x = [self convertXCoordinateToScene:point.x];
    scenePoint.y = [self convertYCoordinateToScene:point.y];
    
    return scenePoint;
}

-(CGFloat)convertYCoordinateToScene:(CGFloat)y
{
    return (self.size.height/2.0f + y);
}

-(CGFloat)convertXCoordinateToScene:(CGFloat)x
{
    return (self.scene.size.width/2.0f + x);
}

-(CGPoint)convertSceneCoordinateToPoint:(CGPoint)point
{
    CGFloat x = point.x - self.scene.size.width/2.0f;
    CGFloat y = point.y - self.scene.size.height/2.0f;
    return CGPointMake(x, y);
}

-(CGFloat) convertDegreesToScene:(CGFloat)degrees
{
    return 360.0f - degrees;
}

-(CGFloat) convertSceneToDegrees:(CGFloat)degrees
{
    return 360.0f + degrees;
}

-(BOOL)touchedwith:(NSSet*)touches withX:(CGFloat)x andY:(CGFloat)y
{
    NSDebug(@"StartTouchofScene");
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    NSDebug(@"x:%f,y:%f",location.x,location.y);
    BOOL foundObject = NO;
    NSArray *nodesAtPoint = [self nodesAtPoint:location];
    if ([nodesAtPoint count]==0) {
        return NO;
    }
    SpriteObject *obj1 = nodesAtPoint[[nodesAtPoint count]-1];
    NSInteger counter =[nodesAtPoint count]-2;
    NSDebug(@"How many nodes are touched: %ld",(long)counter);
    NSDebug(@"First Node:%@",obj1);
    if (!obj1.name) {
        return NO;
    }
    while (!foundObject) {
        CGPoint point = [touch locationInNode:obj1];
        if (!obj1.hidden) {
            if (![obj1 touchedwith:touches withX:point.x andY:point.y]) {
                CGFloat zPosition = obj1.zPosition;
                zPosition -= 1;
                if (zPosition == -1 || counter < 0) {
                    foundObject =  YES;
                    NSDebug(@"Found Object");
                }
                else
                {
                    obj1 = nodesAtPoint[counter];
                    NSDebug(@"NextNode: %@",obj1);
                    counter--;
                    
                }
            }
            else{
                foundObject = YES;
                NSDebug(@"Found Object");
            }

        }
        else{
            obj1 = nodesAtPoint[counter];
            NSDebug(@"NextNode: %@",obj1);
            counter--;
        }
    }
    return YES;

}

@end
