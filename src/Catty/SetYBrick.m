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

#import "Setybrick.h"
#import "Formula.h"
#import "GDataXMLNode.h"

@implementation SetYBrick

@synthesize yPosition = _yPosition;

- (Formula*)getFormulaForLineNumber:(NSInteger)lineNumber AndParameterNumber:(NSInteger)paramNumbers
{
    return self.yPosition;
}

- (void)setFormula:(Formula*)formula ForLineNumber:(NSInteger)lineNumber AndParameterNumber:(NSInteger)paramNumber
{
    self.yPosition = formula;
}

- (NSString*)brickTitle
{
    return kBrickCellMotionTitleSetY;
}

-(SKAction*)action
{
  return [SKAction runBlock:[self actionBlock]];
    
}
-(dispatch_block_t)actionBlock
{
  return ^{
    NSDebug(@"Performing: %@", self.description);
    float yPosition = [self.yPosition interpretDoubleForSprite:self.object];
    self.object.position = CGPointMake(self.object.xPosition, yPosition);
  };
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"SetYBrick (y-Pos:%f)", [self.yPosition interpretDoubleForSprite:self.object]];
}

- (GDataXMLElement*)toXMLforObject:(SpriteObject*)spriteObject
{
    GDataXMLElement *brickXMLElement = [super toXMLforObject:spriteObject];
    GDataXMLElement *yPositionFormulaXMLElement = [GDataXMLNode elementWithName:@"yPosition"];
    [yPositionFormulaXMLElement addChild:[self.yPosition toXMLforObject:spriteObject]];
    [brickXMLElement addChild:yPositionFormulaXMLElement];
    return brickXMLElement;
}

@end
