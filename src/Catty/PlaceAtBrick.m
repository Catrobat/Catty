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

#import "Placeatbrick.h"
#import "Formula.h"
#import "GDataXMLNode.h"

@implementation PlaceAtBrick

- (NSString*)brickTitle
{
    return kBrickCellMotionTitlePlaceAt;
}

- (SKAction*)action
{
  return [SKAction runBlock:[self actionBlock]];
}

- (dispatch_block_t)actionBlock
{
  return ^{
    NSDebug(@"Performing: %@", self.description);
    double xPosition = [self.xPosition interpretDoubleForSprite:self.object];
    double yPosition = [self.yPosition interpretDoubleForSprite:self.object];
    self.object.position = CGPointMake(xPosition, yPosition);
  };
}

#pragma mark - Description
- (NSString*)description
{
    double xPosition = [self.xPosition interpretDoubleForSprite:self.object];
    double yPosition = [self.yPosition interpretDoubleForSprite:self.object];
    return [NSString stringWithFormat:@"PlaceAt (Position: %f/%f)", xPosition, yPosition];
}

- (GDataXMLElement*)toXMLforObject:(SpriteObject*)spriteObject
{
    GDataXMLElement *brickXMLElement = [super toXMLforObject:spriteObject];

    if (self.xPosition) {
        GDataXMLElement *xPositionXMLElement = [GDataXMLNode elementWithName:@"xPosition"];
        [xPositionXMLElement addChild:[self.xPosition toXMLforObject:spriteObject]];
        [brickXMLElement addChild:xPositionXMLElement];
    }

    if (self.yPosition) {
        GDataXMLElement *yPositionXMLElement = [GDataXMLNode elementWithName:@"yPosition"];
        [yPositionXMLElement addChild:[self.yPosition toXMLforObject:spriteObject]];
        [brickXMLElement addChild:yPositionXMLElement];
    }

    if ((! self.xPosition) && (! self.yPosition)) {
        // remove object reference
        [brickXMLElement removeChild:[[brickXMLElement children] firstObject]];
    }

    return brickXMLElement;
}

@end
