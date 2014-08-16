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

#import "IfOnEdgeBounceBrick.h"
#import "Util.h"

@implementation IfOnEdgeBounceBrick

- (BOOL)isSelectableForObject
{
    return (! [self.object isBackground]);
}

- (NSString*)brickTitle
{
    return kBrickCellMotionTitleIfOnEdgeBounce;
}

- (void)performFromScript:(Script*)script;
{
    NSLog(@"Performing: %@", self.description);
    
    //[self.object ifOnEdgeBounce];
    
}

-(SKAction*)action
{
    
    return [SKAction runBlock:^{
        
        float width = self.object.size.width;
        float height = self.object.size.height;
        CGFloat xPosition = self.object.position.x;
        CGFloat yPosition = self.object.position.y;

        CGFloat virtualScreenWidth = self.object.scene.size.width/2.0f;
        CGFloat virtualScreenHeight = self.object.scene.size.height/2.0f;

        float rotation = [self.object rotation];

        if (xPosition < -virtualScreenWidth + width/2.0f) {
            if (rotation <= 180.0f) {
                rotation = (180.0f-rotation);
            } else {
                rotation = 270.0f + (270.0f - rotation);
            }
            xPosition = -virtualScreenWidth + (int) (width / 2.0f);

        } else if (xPosition > virtualScreenWidth - width / 2.0f) {

            if (rotation >= 0.0f && rotation < 90.0f) {
                rotation = 180.0f - rotation;
            } else {
                rotation = 180.0f + (360.0f - rotation);
            }

            xPosition = virtualScreenWidth - (int) (width / 2.0f);
        }

        if (yPosition > virtualScreenHeight - height / 2.0f) {

            rotation = -rotation;
            yPosition = virtualScreenHeight - (int) (height / 2.0f);

        } else if (yPosition < -virtualScreenHeight + height / 2.0f) {
            
            rotation = 360.0f - rotation;
            yPosition = -virtualScreenHeight + (int) (height / 2);
        }
        
        self.object.zRotation = (CGFloat)[Util degreeToRadians:rotation];
        self.object.position = CGPointMake(xPosition, yPosition);

    }];
    
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"IfOnEdgeBounceBrick"];
}

@end
