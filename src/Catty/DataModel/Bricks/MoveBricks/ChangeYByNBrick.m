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

#import "ChangeYByNBrick.h"
#import "Formula.h"
#import "Script.h"
#import "Pocket_Code-Swift.h"

@implementation ChangeYByNBrick

- (Formula*)formulaForLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    return self.yMovement;
}

- (void)setFormula:(Formula*)formula forLineNumber:(NSInteger)lineNumber andParameterNumber:(NSInteger)paramNumber
{
    self.yMovement = formula;
}

- (void)setDefaultValuesForObject:(SpriteObject*)spriteObject
{
    self.yMovement = [[Formula alloc] initWithInteger:10];
}

- (NSString*)brickTitle
{
    return kLocalizedChangeY;
}

- (SKAction*)action
{    
    return [SKAction runBlock:[self actionBlock]];
}

- (dispatch_block_t)actionBlock
{
    return ^{
        NSDebug(@"Performing: %@", self.description);
        float yMov = (float)[self.yMovement interpretDoubleForSprite:self.script.object];
        self.script.object.spriteNode.scenePosition = CGPointMake(self.script.object.spriteNode.scenePosition.x, self.script.object.spriteNode.scenePosition.y + yMov);
    };
}

#pragma mark - Description
- (NSString*)description
{
    double xMov = [self.yMovement interpretDoubleForSprite:self.script.object];
    return [NSString stringWithFormat:@"ChangeYBy (%f)", xMov];
}

@end
