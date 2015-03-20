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

#import "PointToBrick.h"
#import "Util.h"
#import "Scene.h"
#import "Script.h"

@implementation PointToBrick

#define kRotationDegreeOffset 90.0f

- (NSString*)brickTitle
{
    return kLocalizedPointTowards;
}

- (SKAction*)action
{
    return [SKAction runBlock:[self actionBlock]];        
}

- (SpriteObject*) pointedObject
{
    if(!_pointedObject)
        _pointedObject = self.script.object;
    return _pointedObject;
}

- (dispatch_block_t)actionBlock
{
    return ^{
        CGPoint objectPosition = [self.script.object position];
        CGPoint pointedObjectPosition = [self.pointedObject position];
        
        double rotationDegrees = 0;
        
        if (objectPosition.x == pointedObjectPosition.x && objectPosition.y == pointedObjectPosition.y) {
            rotationDegrees = 90.0f;
        } else if (objectPosition.x == pointedObjectPosition.x) {
            if (objectPosition.y > pointedObjectPosition.y) {
                rotationDegrees = 180.0f;
            } else {
                rotationDegrees = 0.0f;
            }
        } else if(objectPosition.y == pointedObjectPosition.y) {
            if (objectPosition.x > pointedObjectPosition.x) {
                rotationDegrees = 270.0f;
            } else {
                rotationDegrees = 90.0f;
            }
        } else {
            double base = fabs(objectPosition.y - pointedObjectPosition.y);
            double height = fabs(objectPosition.x - pointedObjectPosition.x);
            double value = atan(base/height) * 180 / M_PI;
            
            if (objectPosition.x < pointedObjectPosition.x) {
                if (objectPosition.y > pointedObjectPosition.y) {
                    rotationDegrees = 90.0f + value;
                } else {
                    rotationDegrees = 90.0f - value;
                }
            } else {
                if (objectPosition.y > pointedObjectPosition.y) {
                    rotationDegrees = 270.0f - value;
                } else {
                    rotationDegrees = 270.0f + value;
                }
            }
            
        }

        NSDebug(@"Performing: %@, Degreees: (%f), Pointed Object: Position: %@", self.description, rotationDegrees, NSStringFromCGPoint(self.pointedObject.position));
        
        rotationDegrees = [((Scene*)self.script.object.scene) convertDegreesToScene:(CGFloat)rotationDegrees] + kRotationDegreeOffset;
        
        if (rotationDegrees > 360.0f) {
            rotationDegrees -= 360.0f;
        }

        self.script.object.zRotation = (CGFloat)[Util degreeToRadians:rotationDegrees];
    };
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Point To Brick: %@", self.pointedObject];
}

- (BOOL)isEqualToBrick:(Brick*)brick
{
    if(![self.pointedObject.name isEqualToString:((PointToBrick*)brick).pointedObject.name])
        return NO;
    return YES;
}

#pragma mark - BrickObjectProtocol
- (void)setObject:(SpriteObject *)object ForLineNumber:(NSInteger)lineNumber AndParameterNumber:(NSInteger)paramNumber
{
    if(object)
        self.pointedObject = object;
}

- (SpriteObject*)objectForLineNumber:(NSInteger)lineNumber AndParameterNumber:(NSInteger)paramNumber
{
    return self.pointedObject;
}

@end
