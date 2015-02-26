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

#import "MoveNStepsBrick.h"
#import "Formula.h"
#import "Util.h"
#import "Scene.h"
#import "Script.h"

@implementation MoveNStepsBrick

- (Formula*)getFormulaForLineNumber:(NSInteger)lineNumber AndParameterNumber:(NSInteger)paramNumber
{
    return self.steps;
}

- (void)setFormula:(Formula*)formula ForLineNumber:(NSInteger)lineNumber AndParameterNumber:(NSInteger)paramNumber
{
    self.steps = formula;
}

- (NSString*)brickTitle
{
    return kLocalizedMoveNSteps;
}

- (void)performFromScript:(Script *)script
{
}

- (SKAction*)action
{
    return [SKAction runBlock:[self actionBlock]];
}

- (dispatch_block_t)actionBlock
{
    return ^{
        
        double steps = [self.steps interpretDoubleForSprite:self.script.object];
        double rotation = [self.script.object rotation]+90;
        while (rotation >= 360) {
            rotation -= 360;
        }
        rotation = rotation * M_PI / 180;
        int xPosition = (int)round(self.script.object.position.x + (steps * sin(rotation)));
        int yPosition = (int)round(self.script.object.position.y - (steps * cos(rotation)));
        self.script.object.position = CGPointMake(xPosition, yPosition);
    };
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"MoveNStepsBrick: %f steps", [self.steps interpretDoubleForSprite:self.script.object] ];
}

@end
