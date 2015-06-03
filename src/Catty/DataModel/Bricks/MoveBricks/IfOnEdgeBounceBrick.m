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

#import "IfOnEdgeBounceBrick.h"
#import "Util.h"
#import "Script.h"
#import "Pocket_Code-Swift.h"

@implementation IfOnEdgeBounceBrick

- (BOOL)isSelectableForObject
{
    return (! [self.script.object isBackground]);
}

- (NSString*)brickTitle
{
    return kLocalizedIfIsTrueThenOnEdgeBounce;
}

- (void)performFromScript:(Script*)script;
{
    NSDebug(@"Performing: %@", self.description);
    
    //[self.script.object ifOnEdgeBounce];
    
}

- (SKAction*)action
{
    return [SKAction runBlock:[self actionBlock]];
}

- (dispatch_block_t)actionBlock
{
    return ^{
        float width = self.script.object.spriteNode.size.width;
        float height = self.script.object.spriteNode.size.height;
        CGFloat xPosition = self.script.object.spriteNode.scenePosition.x;
        CGFloat yPosition = self.script.object.spriteNode.scenePosition.y;
        
        CGFloat virtualScreenWidth = self.script.object.spriteNode.scene.size.width/2.0f;
        CGFloat virtualScreenHeight = self.script.object.spriteNode.scene.size.height/2.0f;
        
        CGFloat rotation = [self.script.object.spriteNode rotation];
        if (xPosition < -virtualScreenWidth + width/2.0f) {
            if (rotation > 90.0f && rotation < 270.0f) {
                rotation = (180.0f-rotation);
            }
            xPosition = -virtualScreenWidth + (int) (width / 2.0f);
            
        } else if (xPosition > virtualScreenWidth - width / 2.0f) {
            
            if ((rotation >= 0.0f && rotation < 90.0f) || (rotation > 270.0f && rotation <= 360.0f)) {
                rotation = 180.0f - rotation;
            }
            xPosition = virtualScreenWidth - (int) (width / 2.0f);
        }
        
        if(rotation < 0)
            rotation += 360.0f;
        
        if (yPosition > virtualScreenHeight - height / 2.0f) {
            if (rotation > 0.0f && rotation < 180.0f) {
                rotation = -rotation;
            }
            
            yPosition = virtualScreenHeight - (int) (height / 2.0f);

        } else if (yPosition < -virtualScreenHeight + height / 2.0f) {
            if (rotation > 180.0f && rotation < 360.0f) {
                rotation = 360.0f - rotation;
            }
            yPosition = -virtualScreenHeight + (int) (height / 2);
        }

        [self.script.object.spriteNode setRotation:rotation];
        self.script.object.spriteNode.scenePosition = CGPointMake(xPosition, yPosition);
    };
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"IfOnEdgeBounceBrick"];
}

@end
