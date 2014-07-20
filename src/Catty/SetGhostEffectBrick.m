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

#import "Setghosteffectbrick.h"
#import "Formula.h"
#import "GDataXMLNode.h"

@implementation SetGhostEffectBrick

@synthesize transparency = _transparency;

- (NSString*)brickTitle
{
    return kBrickCellLookTitleSetGhostEffect;
}

- (SKAction*)action
{
  return [SKAction runBlock:[self actionBlock]];
}

- (dispatch_block_t)actionBlock
{
  return ^{
    NSDebug(@"Performing: %@", self.description);
    double transparency = [self.transparency interpretDoubleForSprite:self.object];
      double alpha = 1.0-transparency/100.0f;
      if (alpha < 0) {
          self.object.alpha = 0;

      }
      else if (alpha > 1){
          self.object.alpha = 1;
      }
      else{
          self.object.alpha = alpha;
      }
      };
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"SetGhostEffect (%f%%)", [self.transparency interpretDoubleForSprite:self.object]];
}

- (GDataXMLElement*)toXMLforObject:(SpriteObject*)spriteObject
{
    GDataXMLElement *brickXMLElement = [super toXMLforObject:spriteObject];
    if (self.transparency) {
        GDataXMLElement *transparencyXMLElement = [GDataXMLNode elementWithName:@"transparency"];
        [transparencyXMLElement addChild:[self.transparency toXMLforObject:spriteObject]];
        [brickXMLElement addChild:transparencyXMLElement];
    }
    return brickXMLElement;
}

@end
