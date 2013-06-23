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

#import "PointToBrick.h"
#import "Util.h"

@implementation PointToBrick


- (SKAction*)action
{
    
    
    return [SKAction runBlock:^{
        CGPoint objectPosition = [self.object position];
        CGPoint pointedObjectPosition = [self.pointedObject position];
        
        double rotationDegrees = 0;
        
        if(objectPosition.x == pointedObjectPosition.x && objectPosition.y == pointedObjectPosition.y) {
            
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
            
        }else {
            
            
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
        
        self.object.zRotation = [Util degreeToRadians:rotationDegrees];
        
    }];
        
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Point To Brick: %@", self.pointedObject];
}


@end
