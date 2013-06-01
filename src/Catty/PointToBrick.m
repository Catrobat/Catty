//
//  PointToBrick.m
//  Catty
//
//  Created by Dominik Ziegler on 5/2/13.
//
//

#import "PointToBrick.h"

@implementation Pointtobrick


- (void)performFromScript:(Script*)script
{
    
    
    
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
    
    [self.object pointInDirection:rotationDegrees];
    
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"Point To Brick: %@", self.pointedObject];
}


@end
