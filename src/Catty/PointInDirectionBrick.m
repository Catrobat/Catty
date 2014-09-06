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

#import "PointInDirectionBrick.h"
#import "Formula.h"
#import "Util.h"
#import "Scene.h"
#import "GDataXMLNode.h"

#define kRotationDegreeOffset 90.0

@implementation PointInDirectionBrick

- (NSString*)brickTitle
{
    return kLocalizedPointInDirection;
}

-(SKAction*)action
{
  return [SKAction runBlock:[self actionBlock]];
}

-(dispatch_block_t)actionBlock
{
  return ^{
    NSDebug(@"Performing: %@", self.description);
    double degrees = [self.degrees interpretDoubleForSprite:self.object] - kRotationDegreeOffset;
    degrees = [((Scene*)self.object.scene) convertDegreesToScene:(CGFloat)degrees];
    double rad = [Util degreeToRadians:degrees];
    self.object.zRotation = (CGFloat)rad;
  };
}



#pragma mark - Description
- (NSString*)description
{
    double deg = [self.degrees interpretDoubleForSprite:self.object];
    return [NSString stringWithFormat:@"PointInDirection: %f", deg];
}

- (GDataXMLElement*)toXMLforObject:(SpriteObject*)spriteObject
{
    GDataXMLElement *brickXMLElement = [super toXMLforObject:spriteObject];

    if (self.degrees) {
        GDataXMLElement *degreesXMLElement = [GDataXMLNode elementWithName:@"degrees"];
        [degreesXMLElement addChild:[self.degrees toXMLforObject:spriteObject]];
        [brickXMLElement addChild:degreesXMLElement];
    } else {
        // remove object reference
        [brickXMLElement removeChild:[[brickXMLElement children] firstObject]];
    }
    return brickXMLElement;
}

@end
