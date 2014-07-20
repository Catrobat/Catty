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


#import "Setxbrick.h"
#import "Formula.h"
#import "Logger.h"
#import "GDataXMLNode.h"

@implementation SetXBrick

@synthesize xPosition = _xPosition;

- (NSString*)brickTitle
{
    return kBrickCellMotionTitleSetX;
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
        
        self.object.position = CGPointMake(xPosition, self.object.yPosition);
    };
}

#pragma mark - Description
- (NSString*)description
{
    return [NSString stringWithFormat:@"SetXBrick (x-Pos:%f)", [self.xPosition interpretDoubleForSprite:self.object]];
}

- (GDataXMLElement*)toXMLforObject:(SpriteObject*)spriteObject
{
    GDataXMLElement *brickXMLElement = [super toXMLforObject:spriteObject];
    GDataXMLElement *xPositionFormulaXMLElement = [GDataXMLNode elementWithName:@"xPosition"];
    [xPositionFormulaXMLElement addChild:[self.xPosition toXMLforObject:spriteObject]];
    [brickXMLElement addChild:xPositionFormulaXMLElement];
    return brickXMLElement;
}

@end
