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

#import "MoveNStepsBrick.h"
#import "Formula.h"
#import "Util.h"
#import "Scene.h"
#import "GDataXMLNode.h"

@implementation MoveNStepsBrick

- (Formula*)getFormulaForLineNumber:(NSInteger)lineNumber AndParameterNumber:(NSInteger)paramNumber
{
    return self.steps;
}

- (NSString*)brickTitle
{
    return kBrickCellMotionTitleMoveNSteps;
}

-(void)performFromScript:(Script *)script
{
}

-(SKAction*)action
{
    return [SKAction runBlock:[self actionBlock]];
}

-(dispatch_block_t)actionBlock
{
    return ^{
        
        double steps = [self.steps interpretDoubleForSprite:self.object];
        double rotation = [self.object rotation]+90;
        while (rotation >= 360) {
            rotation -= 360;
        }
        rotation = rotation * M_PI / 180;
        int xPosition = (int)round(self.object.position.x + (steps * sin(rotation)));
        int yPosition = (int)round(self.object.position.y - (steps * cos(rotation)));
        self.object.position = CGPointMake(xPosition, yPosition);
    };
}

-(NSString*)description
{
    return [NSString stringWithFormat:@"MoveNStepsBrick: %f steps", [self.steps interpretDoubleForSprite:self.object] ];
}

- (GDataXMLElement*)toXMLforObject:(SpriteObject*)spriteObject
{
    GDataXMLElement *brickXMLElement = [super toXMLforObject:spriteObject];
    GDataXMLElement *stepsXMLElement = [GDataXMLNode elementWithName:@"steps"];
    [stepsXMLElement addChild:[self.steps toXMLforObject:spriteObject]];
    [brickXMLElement addChild:stepsXMLElement];
    return brickXMLElement;
}

@end
